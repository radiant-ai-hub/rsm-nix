#!/usr/bin/env bash
# check-vscode-settings.sh
#
# Guards bin/rsm-vscode-settings -- the shared helper that writes a folder's
# .vscode/{settings,extensions,keybindings}.json (used by rsm-setup,
# rsm-new-project, rsm-mkdir, rsm-clone). Requirements:
#   * writes .vscode/keybindings.json byte-identical to the curated
#     vscode/keybindings.json (so every created folder carries the RSM bindings)
#   * still writes settings.json + extensions.json
#   * refreshes keybindings.json on a re-run (stale copy replaced)
# Pure bash:  bash tests/check-vscode-settings.sh
set -uo pipefail

HERE="$(cd "$(dirname "$0")/.." && pwd)"
SCRIPT="$HERE/bin/rsm-vscode-settings"
CURATED="$HERE/vscode/keybindings.json"

fail=0
ok()  { printf '  \033[32mok\033[0m   %s\n' "$1"; }
bad() { printf '  \033[31mFAIL\033[0m %s\n' "$1"; fail=1; }

tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' EXIT
export RSM_FLAKE="$HERE"
export RSM_UV_ENV="$tmp/no-such"   # force the settings.json shell fallback (no python needed)

run() { bash "$SCRIPT" "$1" --interp '${workspaceFolder}/x/python' --zdotdir '${workspaceFolder}/z'; }

echo "== writes all three .vscode files, keybindings identical to the curated set =="
d="$tmp/folder"
run "$d" >/dev/null 2>&1
for f in settings.json extensions.json keybindings.json; do
  [ -f "$d/.vscode/$f" ] && ok "wrote .vscode/$f" || bad ".vscode/$f missing"
done
if [ -f "$d/.vscode/keybindings.json" ]; then
  if cmp -s "$CURATED" "$d/.vscode/keybindings.json"; then
    ok "keybindings.json matches vscode/keybindings.json byte-for-byte"
  else
    bad "keybindings.json differs from the curated file"
  fi
fi

echo "== refreshes a stale keybindings.json on re-run =="
echo '[ {"key":"ctrl+q","command":"stale"} ]' > "$d/.vscode/keybindings.json"
run "$d" >/dev/null 2>&1
cmp -s "$CURATED" "$d/.vscode/keybindings.json" \
  && ok "stale keybindings.json replaced with the curated set" \
  || bad "did not refresh keybindings.json"

[ "$fail" -eq 0 ] && echo "vscode-settings check passed." || { echo "vscode-settings check FAILED." >&2; exit 1; }
