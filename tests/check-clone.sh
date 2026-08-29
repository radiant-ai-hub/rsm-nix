# check-clone.sh
#
# Verifies rsm-clone: it clones, then hands the clone to rsm-mkdir with the
# RIGHT Python decision. Run in the dev shell (rsm-clone + rsm-mkdir + git on
# PATH):
#   nix develop -c bash tests/check-clone.sh
#
# The decision is the point of this test. A repo that COMMITS a pyproject.toml
# wants its own pinned env; if it is put on the shared nix-uv env instead, the
# student's next command (`uv sync`) resolves that repo's lockfile INTO the
# shared env and prunes everything the repo does not list -- silently breaking
# Python for every other course folder. So: auto-detect, both overrides, and a
# direct assertion that the shared env was never written.
set -uo pipefail

fail=0
ok()  { printf '  \033[32mok\033[0m   %s\n' "$1"; }
bad() { printf '  \033[31mFAIL\033[0m %s\n' "$1"; fail=1; }

command -v rsm-clone >/dev/null 2>&1 || { echo "rsm-clone not on PATH (run inside the dev shell)"; exit 1; }

# Hermetic temp workspace so the real ~/rsm-msba is untouched. RSM_FLAKE stays as
# the dev-shell value (the checkout) so vscode/{settings,keybindings}.json resolve.
tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' EXIT
export RSM_WORKSPACE="$tmp/ws"
export RSMBASE="$RSM_WORKSPACE/.rsm-msba"
export RSM_UV_ENV="$RSMBASE/envs/nix-uv"
mkdir -p "$RSM_WORKSPACE" "$RSMBASE/zsh" "$RSM_UV_ENV/bin"
# A stand-in for the shared env: if rsm-clone/rsm-mkdir ever sync INTO it, this
# marker file's mtime and the dir's contents change. That is the regression.
: > "$RSM_UV_ENV/bin/python"
_shared_before="$(find "$RSM_UV_ENV" | sort | md5sum)"

# --- source repos to clone from (local paths; git clone handles them fine) ---
mk_repo() { # mk_repo NAME [pyproject]
  local r="$tmp/src/$1"
  mkdir -p "$r"
  ( cd "$r" && git init -q . && git config user.email t@t && git config user.name t
    printf 'x\n' > README.md
    if [ "${2:-}" = "pyproject" ]; then
      printf '[project]\nname = "%s"\nversion = "0.1.0"\nrequires-python = ">=3.13"\ndependencies = []\n\n[tool.uv]\npackage = false\n' "$1" > pyproject.toml
    fi
    git add -A && git commit -qm init )
}
mk_repo withpy pyproject
mk_repo nopy

cd "$RSM_WORKSPACE"

echo "== auto-detect: a repo that ships pyproject.toml gets its OWN .venv =="
rsm-clone "$tmp/src/withpy" >/dev/null 2>&1
[ -d withpy/.venv ] && ok "withpy/.venv created" || bad "withpy got no local .venv"
if grep -q '\.venv/bin/python' withpy/.vscode/settings.json 2>/dev/null; then
  ok "interpreter points at ./.venv"; else bad "interpreter not pointed at ./.venv"; fi
if grep -q 'name = "withpy"' withpy/pyproject.toml; then
  ok "the repo's OWN pyproject.toml was kept"; else bad "clobbered the repo's pyproject.toml"; fi

echo "== auto-detect: a repo with no pyproject stays on the shared nix-uv env =="
rsm-clone "$tmp/src/nopy" >/dev/null 2>&1
[ ! -d nopy/.venv ] && ok "nopy has no local .venv" || bad "nopy got a .venv it did not ask for"
if grep -q "$RSM_UV_ENV/bin/python" nopy/.vscode/settings.json 2>/dev/null; then
  ok "interpreter points at the shared nix-uv env"; else bad "interpreter not pointed at nix-uv"; fi

echo "== --no-venv overrides auto-detect on a pyproject repo =="
rsm-clone --no-venv "$tmp/src/withpy" forced-shared >/dev/null 2>&1
[ ! -d forced-shared/.venv ] && ok "--no-venv suppressed the local .venv" || bad "--no-venv still made a .venv"

echo "== --venv forces a local .venv on a repo with no pyproject =="
rsm-clone --venv "$tmp/src/nopy" forced-venv >/dev/null 2>&1
[ -d forced-venv/.venv ] && ok "--venv created a local .venv" || bad "--venv made no .venv"
[ -f forced-venv/pyproject.toml ] && ok "starter pyproject.toml written" || bad "no starter pyproject.toml"

echo "== DIR argument and default-name behaviour =="
rsm-clone "$tmp/src/nopy" custom-name >/dev/null 2>&1
[ -d custom-name/.git ] && ok "explicit DIR honoured" || bad "explicit DIR ignored"
[ -d nopy/.git ] && ok "default DIR is the repo basename" || bad "default DIR wrong"

echo "== argument handling =="
expect_exit() { # expect_exit WANT LABEL cmd...
  local want="$1" label="$2" got=0; shift 2
  if "$@" >/dev/null 2>&1; then got=0; else got="$?"; fi
  if [ "$got" -eq "$want" ]; then ok "$label (exit $got)"; else bad "$label: wanted exit $want, got $got"; fi
}
expect_exit 2 "unknown flag" rsm-clone --nope "$tmp/src/nopy"
expect_exit 1 "no args"      rsm-clone
expect_exit 1 "too many args" rsm-clone a b c
expect_exit 0 "--help"       rsm-clone --help
expect_exit 1 "existing dir refused" rsm-clone "$tmp/src/nopy" nopy

echo "== the shared nix-uv env was never written to =="
if [ "$(find "$RSM_UV_ENV" | sort | md5sum)" = "$_shared_before" ]; then
  ok "shared env untouched by every clone above"
else
  bad "shared env was modified -- this is the bug rsm-clone --venv exists to prevent"
fi

[ "$fail" -eq 0 ] && echo "clone check passed." || { echo "clone check FAILED." >&2; exit 1; }
