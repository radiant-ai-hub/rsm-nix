# check-refresh.sh
#
# Verifies rsm-refresh-folders repairs folders that ALREADY exist. Run in the
# dev shell:
#   nix develop -c bash tests/check-refresh.sh
#
# This is the migration path: rsm-mkdir writes a folder's .envrc once, so a fix
# to that template (pinning UV_PROJECT_ENVIRONMENT to ./.venv, which is what
# stops `uv sync` rewriting the shared nix-uv env) would never reach folders
# created before the fix. Covers: an old managed .envrc is repaired, a student's
# OWN .envrc is left alone, a --venv project keeps its local interpreter, and
# nested folders at depth are found.
set -uo pipefail

fail=0
ok()  { printf '  \033[32mok\033[0m   %s\n' "$1"; }
bad() { printf '  \033[31mFAIL\033[0m %s\n' "$1"; fail=1; }

command -v rsm-refresh-folders >/dev/null 2>&1 || { echo "rsm-refresh-folders not on PATH (run inside the dev shell)"; exit 1; }

tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' EXIT
export RSM_WORKSPACE="$tmp/ws"
export RSMBASE="$RSM_WORKSPACE/.rsm-msba"
export RSM_UV_ENV="$RSMBASE/envs/nix-uv"
mkdir -p "$RSM_WORKSPACE" "$RSMBASE/zsh" "$RSM_UV_ENV/bin"
: > "$RSM_UV_ENV/bin/python"
cd "$RSM_WORKSPACE"

# The pre-fix .envrc: the pin lived INSIDE the conditional, so a folder without a
# .venv had nothing pinned and uv fell through to the shared env.
old_envrc() {
  mkdir -p "$1"
  cat > "$1/.envrc" <<'EOF'
# rsm-msba (managed) -- loads the RSM environment from the parent workspace.
source_up

watch_file .venv/bin/activate
if [ -f "$PWD/.venv/bin/activate" ]; then
  export UV_PROJECT_ENVIRONMENT="$PWD/.venv"
  export VIRTUAL_ENV="$PWD/.venv"
  PATH_add "$PWD/.venv/bin"
fi
EOF
}

old_envrc plain
old_envrc nested/deep/course           # must be found at depth
old_envrc venvproj                     # a --venv project, below
mkdir -p venvproj/.venv/bin && : > venvproj/.venv/bin/activate
printf '[project]\nname = "venvproj"\nversion = "0.1.0"\n' > venvproj/pyproject.toml

# A student's own .envrc -- no managed marker. Must be left completely alone.
mkdir -p mine
printf '# my own env\nexport FOO=bar\n' > mine/.envrc

rsm-refresh-folders "$RSM_WORKSPACE" >/dev/null 2>&1

echo "== an old managed .envrc is repaired =="
for d in plain nested/deep/course; do
  if grep -q 'export UV_PROJECT_ENVIRONMENT="$PWD/.venv"' "$d/.envrc" \
     && awk '/^export UV_PROJECT_ENVIRONMENT/{if(!pin)pin=NR}
             /^if \[ -f "\$PWD\/\.venv\/bin\/activate" \]/{if(!cond)cond=NR}
             END{exit !(pin>0 && cond>0 && pin<cond)}' "$d/.envrc"; then
    ok "$d/.envrc pin hoisted out of the conditional"
  else
    bad "$d/.envrc was not repaired"
  fi
done

echo "== a student's OWN .envrc is untouched =="
if grep -q 'FOO=bar' mine/.envrc && ! grep -q 'source_up' mine/.envrc; then
  ok "foreign .envrc left alone"
else
  bad "clobbered a foreign .envrc"
fi

echo "== a --venv project keeps its LOCAL interpreter (not reset to nix-uv) =="
# The trap: refreshing with plain rsm-mkdir would point VS Code back at the
# shared env and silently undo the project's own venv.
if grep -q '\.venv/bin/python' venvproj/.vscode/settings.json 2>/dev/null; then
  ok "venvproj interpreter still points at ./.venv"
else
  bad "venvproj interpreter was reset away from ./.venv"
fi
if grep -q 'name = "venvproj"' venvproj/pyproject.toml; then
  ok "the project's own pyproject.toml was kept"
else
  bad "clobbered the project's pyproject.toml"
fi

echo "== a plain folder still gets the shared nix-uv interpreter =="
if grep -q "$RSM_UV_ENV/bin/python" plain/.vscode/settings.json 2>/dev/null; then
  ok "plain folder points at nix-uv (the default we want to keep)"
else
  bad "plain folder no longer points at nix-uv"
fi

echo "== idempotent: a second run changes nothing =="
before="$(find "$RSM_WORKSPACE" -name .envrc -exec md5sum {} + | sort | md5sum)"
rsm-refresh-folders "$RSM_WORKSPACE" >/dev/null 2>&1
after="$(find "$RSM_WORKSPACE" -name .envrc -exec md5sum {} + | sort | md5sum)"
[ "$before" = "$after" ] && ok "second run is a no-op" || bad "not idempotent"

echo "== reports what it skipped =="
if rsm-refresh-folders "$RSM_WORKSPACE" 2>/dev/null | grep -q "own .envrc"; then
  ok "reports the foreign folder it kept"
else
  bad "did not report the skipped folder"
fi

[ "$fail" -eq 0 ] && echo "refresh check passed." || { echo "refresh check FAILED." >&2; exit 1; }
