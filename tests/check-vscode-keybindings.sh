#!/usr/bin/env bash
# check-vscode-keybindings.sh
#
# Guards bin/rsm-vscode-keybindings, which merges the curated VS Code keybindings
# (vscode/keybindings.json) into a User keybindings.json. Requirements:
#   * fresh dir  -> writes exactly the curated bindings
#   * idempotent -> a second run does NOT duplicate anything
#   * additive   -> a binding the student added is KEPT; ours are still applied
#   * override   -> our version of a (key,command,when) replaces a stale one
#   * safe       -> a User file with // comments (JSONC) is left UNTOUCHED
# Uses the repo's real vscode/keybindings.json and a system python3. Pure bash:
#   bash tests/check-vscode-keybindings.sh
set -uo pipefail

HERE="$(cd "$(dirname "$0")/.." && pwd)"
SCRIPT="$HERE/bin/rsm-vscode-keybindings"
CURATED="$HERE/vscode/keybindings.json"

fail=0
ok()  { printf '  \033[32mok\033[0m   %s\n' "$1"; }
bad() { printf '  \033[31mFAIL\033[0m %s\n' "$1"; fail=1; }

command -v python3 >/dev/null 2>&1 || { echo "python3 required for this test" >&2; exit 1; }

tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' EXIT
export RSM_FLAKE="$HERE"          # curated file resolved as $RSM_FLAKE/vscode/keybindings.json
export RSM_UV_ENV="$tmp/no-such"  # force the python3 fallback path

# jq-free JSON query via python3: prints len / a boolean / a count.
pyq() { python3 -c "$1" "$2"; }

N_CURATED="$(python3 -c 'import json,sys; print(len(json.load(open(sys.argv[1]))))' "$CURATED")"

echo "== fresh dir: writes exactly the curated bindings =="
d1="$tmp/fresh"
bash "$SCRIPT" "$d1" >/dev/null 2>&1
f1="$d1/keybindings.json"
if [ -f "$f1" ]; then
  n="$(python3 -c 'import json,sys; print(len(json.load(open(sys.argv[1]))))' "$f1")"
  [ "$n" = "$N_CURATED" ] && ok "wrote $N_CURATED bindings" || bad "expected $N_CURATED, got $n"
  python3 -c 'import json,sys; d=json.load(open(sys.argv[1])); sys.exit(0 if any(b.get("command")=="runCommands" for b in d) else 1)' "$f1" \
    && ok "contains the curated runCommands binding" || bad "missing the curated binding"
else
  bad "no keybindings.json written"
fi

echo "== idempotent: a second run does not grow/duplicate the file =="
bash "$SCRIPT" "$d1" >/dev/null 2>&1
n2="$(python3 -c 'import json,sys; print(len(json.load(open(sys.argv[1]))))' "$f1")"
[ "$n2" = "$N_CURATED" ] && ok "still $N_CURATED bindings after re-run" || bad "re-run changed count to $n2 (not idempotent)"

echo "== additive: keeps a student's own binding, still applies ours =="
d2="$tmp/withuser"; mkdir -p "$d2"
cat > "$d2/keybindings.json" <<'JSON'
[
  { "key": "cmd+k cmd+t", "command": "workbench.action.selectTheme" }
]
JSON
bash "$SCRIPT" "$d2" >/dev/null 2>&1
f2="$d2/keybindings.json"
python3 -c 'import json,sys; d=json.load(open(sys.argv[1])); sys.exit(0 if any(b.get("command")=="workbench.action.selectTheme" for b in d) else 1)' "$f2" \
  && ok "kept the student binding" || bad "dropped the student binding"
python3 -c 'import json,sys; d=json.load(open(sys.argv[1])); sys.exit(0 if any(b.get("command")=="runCommands" for b in d) else 1)' "$f2" \
  && ok "added the curated bindings alongside" || bad "did not add curated bindings"
n3="$(python3 -c 'import json,sys; print(len(json.load(open(sys.argv[1]))))' "$f2")"
[ "$n3" = "$((N_CURATED + 1))" ] && ok "count = curated + 1 student binding" || bad "unexpected count $n3"

echo "== override: our (key,command,when) replaces a stale duplicate =="
d3="$tmp/stale"; mkdir -p "$d3"
# Same key+command+when as a curated binding but different args -> must be replaced
# by ours (no duplicate), so the count equals the curated count, not +1.
cat > "$d3/keybindings.json" <<'JSON'
[
  { "key": "ctrl+alt+i", "command": "quarto.insertCodeCell", "when": "editorTextFocus && !findInputFocussed && !replaceInputFocussed && editorLangId == 'quarto'", "args": {"stale": true} }
]
JSON
bash "$SCRIPT" "$d3" >/dev/null 2>&1
n4="$(python3 -c 'import json,sys; print(len(json.load(open(sys.argv[1]))))' "$d3/keybindings.json")"
[ "$n4" = "$N_CURATED" ] && ok "replaced the stale binding (no duplicate)" || bad "stale binding not deduped (count $n4)"
python3 -c 'import json,sys
d=json.load(open(sys.argv[1]))
m=[b for b in d if b.get("command")=="quarto.insertCodeCell" and b.get("key")=="ctrl+alt+i"]
sys.exit(0 if len(m)==1 and "stale" not in m[0].get("args",{}) else 1)' "$d3/keybindings.json" \
  && ok "kept OUR version, dropped the stale args" || bad "did not take our version"

echo "== safe: a User file with // comments is left untouched =="
d4="$tmp/jsonc"; mkdir -p "$d4"
cat > "$d4/keybindings.json" <<'JSONC'
// My custom keybindings
[
  { "key": "cmd+j", "command": "workbench.action.togglePanel" }
]
JSONC
before="$(cat "$d4/keybindings.json")"
out="$(bash "$SCRIPT" "$d4" 2>&1)"
after="$(cat "$d4/keybindings.json")"
[ "$before" = "$after" ] && ok "did not clobber the JSONC file" || bad "clobbered a file with // comments"
printf '%s' "$out" | grep -qi "untouched" && ok "warned that it was left untouched" || bad "no untouched warning"

[ "$fail" -eq 0 ] && echo "vscode-keybindings check passed." || { echo "vscode-keybindings check FAILED." >&2; exit 1; }
