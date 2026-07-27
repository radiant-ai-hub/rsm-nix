# check-mkdir.sh
#
# Verifies rsm-mkdir (which absorbed the former rsm-new-project) does the
# per-folder work directly. Run in the dev shell (rsm-mkdir + rsm-vscode-settings
# + direnv on PATH):
#   nix develop -c bash tests/check-mkdir.sh
#
# Covers: multi-path, a nested folder (source_up), the current folder (`.`), a
# standalone folder (use flake), --venv (own pyproject + .venv interpreter), and
# NOT clobbering a repo's own .envrc.
set -uo pipefail

fail=0
ok()  { printf '  \033[32mok\033[0m   %s\n' "$1"; }
bad() { printf '  \033[31mFAIL\033[0m %s\n' "$1"; fail=1; }

command -v rsm-mkdir >/dev/null 2>&1 || { echo "rsm-mkdir not on PATH (run inside the dev shell)"; exit 1; }

# Hermetic temp workspace so the real ~/rsm-msba is untouched. RSM_FLAKE stays as
# the dev-shell value (the checkout) so vscode/{settings,keybindings}.json resolve.
tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' EXIT
export RSM_WORKSPACE="$tmp/ws"
export RSMBASE="$RSM_WORKSPACE/.rsm-msba"
export RSM_UV_ENV="$RSMBASE/envs/nix-uv"
mkdir -p "$RSM_WORKSPACE" "$RSMBASE/zsh"
cd "$RSM_WORKSPACE"

echo "== multi-path: nested folders get source_up + full .vscode =="
rsm-mkdir a b c >/dev/null 2>&1
for d in a b c; do
  if [ -f "$d/.envrc" ] && grep -q '^source_up' "$d/.envrc"; then ok "$d/.envrc (source_up)"; else bad "$d/.envrc not source_up"; fi
  for vf in settings.json extensions.json keybindings.json; do
    [ -f "$d/.vscode/$vf" ] && ok "$d/.vscode/$vf" || bad "missing $d/.vscode/$vf"
  done
done

echo "== current folder: rsm-mkdir . =="
mkdir -p sub
( cd sub && rsm-mkdir . >/dev/null 2>&1 )
if [ -f sub/.envrc ] && grep -q '^source_up' sub/.envrc; then ok "sub/.envrc via 'rsm-mkdir .'"; else bad "'rsm-mkdir .' did not set up the current folder"; fi

echo "== standalone folder (outside the workspace): use flake =="
ext="$tmp/outside/proj"
rsm-mkdir "$ext" >/dev/null 2>&1
if [ -f "$ext/.envrc" ] && grep -q 'use flake' "$ext/.envrc"; then ok "standalone .envrc uses 'use flake'"; else bad "standalone folder not set up with use flake"; fi

echo "== --venv: own pyproject + .venv interpreter, .envrc auto-activates a venv =="
rsm-mkdir --venv analysis >/dev/null 2>&1
[ -f analysis/pyproject.toml ] && ok "analysis/pyproject.toml written" || bad "missing analysis/pyproject.toml"
grep -q 'UV_PROJECT_ENVIRONMENT' analysis/.envrc && ok ".envrc auto-activates a local .venv" || bad ".envrc missing the .venv auto-activation block"
if grep -q '\.venv/bin/python' analysis/.vscode/settings.json 2>/dev/null; then ok "interpreter points at ./.venv"; else bad "interpreter not pointed at ./.venv"; fi

echo "== non-destructive: keeps a repo's OWN .envrc =="
mkdir -p custom
printf '# my own env\nexport FOO=bar\n' > custom/.envrc
rsm-mkdir custom >/dev/null 2>&1
if grep -q 'FOO=bar' custom/.envrc && ! grep -q '^source_up' custom/.envrc; then ok "kept the repo's own .envrc"; else bad "clobbered the repo's own .envrc"; fi

echo "== multiple paths in one call all get set up =="
n=0
for d in a b c; do [ -f "$d/.vscode/keybindings.json" ] && n=$((n+1)); done
[ "$n" -eq 3 ] && ok "all 3 folders from the multi-path call are set up" || bad "only $n/3 folders set up"

[ "$fail" -eq 0 ] && echo "mkdir check passed." || { echo "mkdir check FAILED." >&2; exit 1; }
