# check-default.sh
#
# Self-contained smoke checks for the default dev shell. Safe to run two ways:
#   nix develop -c bash tests/check-default.sh     # from the workspace root
#   nix run .#check                                # bundled, runs anywhere
#
# Exits non-zero if any required check fails.

# Resolve workspace/state defaults if not already exported by the dev shell.
: "${RSM_WORKSPACE:=$PWD}"
: "${RSMBASE:=$RSM_WORKSPACE/.rsm-msba}"
: "${RSM_UV_ENV:=$RSMBASE/envs/nix-uv}"

here="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" 2>/dev/null && pwd || true)"

pass=0
fail=0
ok()   { printf '  \033[32mok\033[0m   %s\n' "$1"; pass=$((pass + 1)); }
bad()  { printf '  \033[31mFAIL\033[0m %s\n' "$1"; fail=$((fail + 1)); }
have() { command -v "$1" >/dev/null 2>&1; }

echo "== toolchain =="
check_cmd() {
  local label="$1"; shift
  if "$@" >/dev/null 2>&1; then ok "$label"; else bad "$label ($*)"; fi
}
check_cmd "quarto --version"   quarto --version
check_cmd "gh --version"       gh --version
check_cmd "git --version"      git --version
check_cmd "git lfs version"    git lfs version
check_cmd "uv --version"       uv --version
check_cmd "psql --version"     psql --version
check_cmd "pgweb --version"    pgweb --version

echo "== node / claude code =="
# Node is pinned by the flake; npm is how Claude Code is installed/updated.
check_cmd "node --version"     node --version
check_cmd "npm --version"      npm --version
# Claude Code is installed per-user by rsm-setup (not part of the Nix env), so
# verify it only when present — this catches a broken Node/Claude combo in CI
# (where rsm-setup has run) without failing a bare check before setup.
if have claude; then
  # NON-FATAL: Claude Code is a per-user npm install, not part of the core RSM
  # Nix environment, and depends on the network/registry. A broken 'claude' must
  # not fail the whole environment install/validation — warn instead. Set
  # RSM_STRICT_CLAUDE=1 (e.g. in CI) to make it a hard check again.
  if claude --version >/dev/null 2>&1; then
    ok "claude --version"
  elif [ "${RSM_STRICT_CLAUDE:-0}" = "1" ]; then
    bad "claude --version (claude --version)"
  else
    printf '  \033[33mwarn\033[0m %s\n' "claude present but 'claude --version' failed — not required for the RSM env; run 'rsm-update' to reinstall Claude Code"
  fi
else
  printf '  \033[33mskip\033[0m %s\n' "claude not installed yet (run rsm-setup / rsm-update)"
fi

echo "== rsm commands present =="
for c in rsm-setup rsm-python-sync rsm-pg-init rsm-pg-start rsm-pg-stop \
         rsm-pg-status rsm-pg-psql rsm-pgweb rsm-mkdir rsm-clone; do
  if have "$c"; then ok "$c"; else bad "$c not on PATH"; fi
done

echo "== python (uv base env) =="
py="$RSM_UV_ENV/bin/python"
if [ -x "$py" ]; then
  if [ -n "$here" ] && [ -f "$here/check-python.py" ]; then
    if "$py" "$here/check-python.py"; then ok "course-core imports"; else bad "course-core imports"; fi
  else
    if "$py" - <<'PY'
import IPython, requests, numpy, scipy, sklearn, xgboost, pandas
import statsmodels, polars, pyarrow, sqlalchemy, psycopg2, plotnine
print("inline imports ok")
PY
    then ok "core imports (inline)"; else bad "core imports (inline)"; fi
  fi
else
  printf '  \033[33mskip\033[0m %s\n' "uv base env not built yet (run rsm-setup)"
fi

echo "== no host dotfile mutation =="
for p in "$HOME/.config/rsm-podman" "$HOME/.local/state/rsm-podman"; do
  if [ -e "$p" ]; then bad "unexpected host path exists: $p"; else ok "absent: $p"; fi
done
case "$RSMBASE" in
  "$RSM_WORKSPACE"/*) ok "state dir is workspace-local ($RSMBASE)";;
  *) bad "RSMBASE is not under the workspace: $RSMBASE";;
esac

echo
echo "== summary: $pass passed, $fail failed =="
[ "$fail" -eq 0 ]
