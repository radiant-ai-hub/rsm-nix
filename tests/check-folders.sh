# check-folders.sh
#
# Verifies the recommended workspace layout exists after rsm-setup. Run from
# the workspace root inside the dev shell:
#   nix develop -c bash tests/check-folders.sh

set -euo pipefail

: "${RSM_WORKSPACE:=$PWD}"
: "${RSMBASE:=$RSM_WORKSPACE/.rsm-msba}"

fail=0
ok()  { printf '  \033[32mok\033[0m   %s\n' "$1"; }
bad() { printf '  \033[31mFAIL\033[0m %s\n' "$1"; fail=1; }

echo "== workspace marker files =="
for f in flake.nix pyproject.toml courses.txt .envrc; do
  if [ -e "$RSM_WORKSPACE/$f" ]; then ok "$f"; else bad "missing $f"; fi
done

echo "== state directories =="
for d in envs uv-cache jupyter postgres zsh logs; do
  if [ -d "$RSMBASE/$d" ]; then ok ".rsm-msba/$d"; else bad "missing .rsm-msba/$d"; fi
done

echo "== course folders from courses.txt =="
if [ -f "$RSM_WORKSPACE/courses.txt" ]; then
  while IFS= read -r course || [ -n "$course" ]; do
    course="${course%%#*}"; course="$(printf '%s' "$course" | tr -d '[:space:]')"
    [ -z "$course" ] && continue
    if [ -d "$RSM_WORKSPACE/$course" ]; then ok "$course/"; else bad "missing course folder $course/ (run rsm-setup)"; fi
  done < "$RSM_WORKSPACE/courses.txt"
fi

[ "$fail" -eq 0 ] && echo "Folder layout looks good." || { echo "Folder layout check FAILED." >&2; exit 1; }
