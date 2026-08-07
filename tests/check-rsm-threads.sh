# check-rsm-threads.sh
#
# Verifies rsm-threads: it lists past Claude conversations (title + folder) across a
# projects tree, falls back to the last prompt when a thread has no ai-title, sorts
# newest-first, and prints the correct `cd <folder> && claude --resume <id>` command.
# The interactive fzf menu is not exercised here (no TTY); the --list/--print/--preview
# modes cover the logic. Run in the dev shell (rsm-threads on PATH):
#   nix develop -c bash tests/check-rsm-threads.sh
set -uo pipefail

fail=0
ok()  { printf '  \033[32mok\033[0m   %s\n' "$1"; }
bad() { printf '  \033[31mFAIL\033[0m %s\n' "$1"; fail=1; }

command -v rsm-threads >/dev/null 2>&1 || { echo "rsm-threads not on PATH (run inside the dev shell)"; exit 1; }

tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' EXIT
proj="$tmp/projects"; mkdir -p "$proj/projA" "$proj/projB" "$proj/projC"

# Thread A: has an ai-title + prompts + a folder
cat > "$proj/projA/sessA.jsonl" <<'J'
{"type":"user","cwd":"/tmp/projA","timestamp":"2026-08-01T00:00:00Z","message":{"role":"user","content":"first prompt A"}}
{"type":"ai-title","aiTitle":"Test Thread A","sessionId":"sessA"}
{"type":"last-prompt","lastPrompt":"latest A","sessionId":"sessA"}
J
# Thread B: NO ai-title -> title should fall back to the last prompt
cat > "$proj/projB/sessB.jsonl" <<'J'
{"type":"user","cwd":"/tmp/projB","message":{"role":"user","content":"only prompt B"}}
{"type":"last-prompt","lastPrompt":"fallback title B","sessionId":"sessB"}
J
# Thread C: no cwd at all -> resume command must omit the `cd`
printf '{"type":"last-prompt","lastPrompt":"no folder here"}\n' > "$proj/projC/sessC.jsonl"

touch -d '2026-08-02 10:00' "$proj/projA/sessA.jsonl" 2>/dev/null || touch -t 202608021000 "$proj/projA/sessA.jsonl"
touch -d '2026-08-01 10:00' "$proj/projB/sessB.jsonl" 2>/dev/null || touch -t 202608011000 "$proj/projB/sessB.jsonl"

export CLAUDE_PROJECTS_DIR="$proj"

echo "== --list: title, folder, fallback, newest-first =="
list="$(rsm-threads --list)"
echo "$list" | grep -q 'Test Thread A'   && ok "shows the ai-title"                  || bad "ai-title missing from list"
echo "$list" | grep -q 'fallback title B' && ok "falls back to last-prompt (no title)" || bad "no last-prompt fallback for a title-less thread"
echo "$list" | grep -q '/tmp/projA'       && ok "shows the thread's folder"           || bad "folder missing from list"
la=$(echo "$list" | grep -n 'Test Thread A'   | head -1 | cut -d: -f1)
lb=$(echo "$list" | grep -n 'fallback title B' | head -1 | cut -d: -f1)
[ -n "$la" ] && [ -n "$lb" ] && [ "$la" -lt "$lb" ] && ok "newest thread listed first" || bad "list is not newest-first ($la vs $lb)"

echo "== --print: cd + claude --resume =="
pr="$(rsm-threads --print sessA)"
[ "$pr" = "cd /tmp/projA && claude --resume sessA" ] && ok "prints cd + resume for a thread with a folder" || bad "--print wrong: [$pr]"
pc="$(rsm-threads --print sessC)"
[ "$pc" = "claude --resume sessC" ] && ok "omits cd when the thread has no folder" || bad "--print (no cwd) wrong: [$pc]"

echo "== --preview: title + the human prompts =="
pv="$(rsm-threads --preview sessA)"
echo "$pv" | grep -q 'Title : Test Thread A' && ok "preview shows the title"   || bad "preview missing title"
echo "$pv" | grep -q 'first prompt A'         && ok "preview shows the prompts" || bad "preview missing prompts"

[ "$fail" -eq 0 ] && echo "rsm-threads check passed." || { echo "rsm-threads check FAILED." >&2; exit 1; }
