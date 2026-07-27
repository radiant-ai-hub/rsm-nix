# check-folders.sh
#
# Verifies the split flake/workspace layout exists after rsm-setup. Run inside
# the dev shell:
#   nix develop -c bash tests/check-folders.sh

set -euo pipefail

: "${RSM_FLAKE:=$PWD}"
: "${RSM_WORKSPACE:=$HOME/rsm-msba}"
: "${RSMBASE:=$RSM_WORKSPACE/.rsm-msba}"
: "${RSM_UV_ENV:=$RSMBASE/envs/nix-uv}"

fail=0
ok()  { printf '  \033[32mok\033[0m   %s\n' "$1"; }
bad() { printf '  \033[31mFAIL\033[0m %s\n' "$1"; fail=1; }

echo "== flake repo ($RSM_FLAKE) =="
for f in flake.nix pyproject.toml uv.lock courses.txt; do
  if [ -e "$RSM_FLAKE/$f" ]; then ok "$f"; else bad "missing $RSM_FLAKE/$f"; fi
done

echo "== workspace ($RSM_WORKSPACE) =="
if [ -e "$RSM_WORKSPACE/.envrc" ]; then ok ".envrc"; else bad "missing $RSM_WORKSPACE/.envrc (run rsm-setup)"; fi
case "$RSMBASE" in
  "$RSM_WORKSPACE"/*) ok "state is workspace-local (not in the flake repo)";;
  *) bad "RSMBASE is not under the workspace: $RSMBASE";;
esac

echo "== state directories =="
for d in envs uv-cache jupyter postgres zsh logs; do
  if [ -d "$RSMBASE/$d" ]; then ok ".rsm-msba/$d"; else bad "missing .rsm-msba/$d"; fi
done
if [ -x "$RSM_UV_ENV/bin/python" ]; then ok "nix-uv env (envs/nix-uv)"; else bad "missing nix-uv env (run rsm-setup)"; fi

echo "== course folders from courses.txt (first-class, like rsm-mkdir) =="
if [ -f "$RSM_FLAKE/courses.txt" ]; then
  while IFS= read -r course || [ -n "$course" ]; do
    course="${course%%#*}"; course="$(printf '%s' "$course" | tr -d '[:space:]')"
    [ -z "$course" ] && continue
    cdir="$RSM_WORKSPACE/$course"
    if [ ! -d "$cdir" ]; then bad "missing course folder $course/ (run rsm-setup)"; continue; fi
    ok "$course/"
    # Set up like rsm-mkdir: a source_up .envrc (inherits nix-uv) + full .vscode
    # so the folder opens directly in VS Code with the RSM config.
    if [ -f "$cdir/.envrc" ] && grep -q '^source_up' "$cdir/.envrc"; then
      ok "$course/.envrc (source_up -> shared nix-uv)"
    else
      bad "$course/.envrc missing or not source_up (course folder not first-class)"
    fi
    for vf in settings.json keybindings.json; do
      if [ -f "$cdir/.vscode/$vf" ]; then ok "$course/.vscode/$vf"; else bad "missing $course/.vscode/$vf"; fi
    done
  done < "$RSM_FLAKE/courses.txt"
fi

echo "== data folder seeded from the flake (under the workspace) =="
if [ -d "$RSM_FLAKE/data" ]; then
  if [ -d "$RSM_WORKSPACE/data" ]; then ok "data/"; else bad "missing $RSM_WORKSPACE/data (run rsm-setup)"; fi
  # every file shipped in the flake's data/ should be present in the workspace
  while IFS= read -r rel; do
    if [ -e "$RSM_WORKSPACE/data/$rel" ]; then ok "data/$rel"; else bad "missing data/$rel in the workspace"; fi
  done < <(cd "$RSM_FLAKE/data" && find . -type f | sed 's#^\./##')
fi

[ "$fail" -eq 0 ] && echo "Folder layout looks good." || { echo "Folder layout check FAILED." >&2; exit 1; }
