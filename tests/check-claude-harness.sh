# check-claude-harness.sh
#
# Verifies the Claude Code "agentic engineering" harness: the per-folder
# generator (rsm-claude-settings) deploys the right files, the hooks behave, and
# usage-logging is scoped to course-org repos only. Run in the dev shell
# (rsm-claude-settings + jq + just + ruff + git on PATH, RSM_FLAKE = checkout):
#   nix develop -c bash tests/check-claude-harness.sh
#
# Each behavioral check is written so it FAILS if the corresponding hook logic is
# removed (mutation-tested), not just "runs without error".
set -uo pipefail

fail=0
ok()  { printf '  \033[32mok\033[0m   %s\n' "$1"; }
bad() { printf '  \033[31mFAIL\033[0m %s\n' "$1"; fail=1; }

command -v rsm-claude-settings >/dev/null 2>&1 || { echo "rsm-claude-settings not on PATH (run inside the dev shell)"; exit 1; }
SRC="${RSM_FLAKE:-$HOME/rsm-nix}/claude"
[ -d "$SRC" ] || { echo "FAIL: \$RSM_FLAKE/claude not found ($SRC) — point RSM_FLAKE at the checkout"; exit 1; }

tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' EXIT

echo "== deploy: rsm-claude-settings writes the full harness =="
proj="$tmp/proj"; mkdir -p "$proj"
rsm-claude-settings "$proj" >/dev/null 2>&1
for f in .claude/settings.json .claude/usage-log/README.md CLAUDE.md .gitignore; do
  [ -f "$proj/$f" ] && ok "wrote $f" || bad "missing $f"
done
for h in _common secret-scan usage-log auto-stage-log save-test-time check-stale-tests ruff-check ruff-format; do
  [ -f "$proj/.claude/hooks/$h.sh" ] && ok "hook $h.sh" || bad "missing hook $h.sh"
done
# commands + justfile are NO LONGER per-folder (user-level commands + one workspace justfile)
[ ! -e "$proj/.claude/commands" ] && ok "no per-folder .claude/commands (commands are user-level)" || bad "rsm-claude-settings still writes per-folder commands"
[ ! -e "$proj/justfile" ] && ok "no per-folder justfile (single workspace justfile)" || bad "rsm-claude-settings still writes a per-folder justfile"
[ -x "$proj/.claude/hooks/secret-scan.sh" ] && ok "hooks are executable" || bad "hooks not executable"
grep -q '_rsmManaged' "$proj/.claude/settings.json" && ok "settings has _rsmManaged marker" || bad "settings missing marker"
grep -q 'Bash(pip:\*)' "$proj/.claude/settings.json" && ok "settings deny pip (uv-only policy)" || bad "settings missing deny pip"
grep -q 'usage-log.sh' "$proj/.claude/settings.json" && ok "hooks wired in settings" || bad "hooks not wired"
for ig in '.claude/.last-test-time' '.claude/usage-log/.github-user'; do
  grep -qxF "$ig" "$proj/.gitignore" && ok "gitignore: $ig" || bad "gitignore missing $ig"
done

echo "== skills: source present + deploy cleanly (mirrors rsm-setup 6b) =="
skills_src="${RSM_FLAKE:-$HOME/rsm-nix}/skills"
fakehome="$tmp/home/.claude/skills"; mkdir -p "$fakehome"
for sd in "$skills_src"/*/; do
  [ -d "$sd" ] || continue
  nm="$(basename "$sd")"; rm -rf "${fakehome:?}/$nm"; cp -R "$sd" "$fakehome/$nm"
done
for s in git-workflow verify-ai-code rsm-project; do
  sm="$skills_src/$s/SKILL.md"
  if [ -f "$sm" ] && grep -q "^name: $s" "$sm"; then ok "skill source $s well-formed"; else bad "skill source $s missing/malformed"; fi
  [ -f "$fakehome/$s/SKILL.md" ] && ok "skill $s deploys cleanly" || bad "skill $s did not deploy"
done
[ -f "$skills_src/git-workflow/scripts/git_state.sh" ] && ok "git-workflow ships git_state.sh" || bad "git-workflow missing git_state.sh"

echo "== commands: user-level source present + deploys cleanly (mirrors rsm-setup 6b2) =="
cmd_src="${RSM_FLAKE:-$HOME/rsm-nix}/claude/commands"
fakecmd="$tmp/home/.claude/commands"; mkdir -p "$fakecmd"
for _cf in "$cmd_src"/*.md; do [ -e "$_cf" ] && cp -f "$_cf" "$fakecmd/"; done
for c in review explain run-tests add-function; do
  [ -f "$cmd_src/$c.md" ] && ok "command source /$c present" || bad "command source /$c missing"
  [ -f "$fakecmd/$c.md" ] && ok "command /$c deploys user-level" || bad "command /$c did not deploy user-level"
done

echo "== secret-scan: flags a key on git commit, silent when clean =="
srepo="$tmp/secret"; mkdir -p "$srepo"; ( cd "$srepo" && git init -q )
rsm-claude-settings "$srepo" >/dev/null 2>&1
# a plausible Anthropic-style key in a non-suspicious filename -> content match
printf 'token = "sk-ant-api03-%s"\n' "AbCdEf0123456789AbCdEf0123456789xyz" > "$srepo/config.py"
( cd "$srepo" && git add config.py )
out=$(printf '{"tool_input":{"command":"git commit -m test"}}' | ( cd "$srepo" && bash .claude/hooks/secret-scan.sh ) )
echo "$out" | grep -q '"permissionDecision": *"ask"' && ok "secret-scan asks on a key" || bad "secret-scan did NOT flag a key"
# clean file -> no output
( cd "$srepo" && git reset -q >/dev/null 2>&1; rm -f config.py; printf 'x = 1\n' > clean.py; git add clean.py )
out2=$(printf '{"tool_input":{"command":"git commit -m ok"}}' | ( cd "$srepo" && bash .claude/hooks/secret-scan.sh ) )
[ -z "$out2" ] && ok "secret-scan silent on clean commit" || bad "secret-scan false-positive on clean file"
# non-commit command -> no output
out3=$(printf '{"tool_input":{"command":"ls -la"}}' | ( cd "$srepo" && bash .claude/hooks/secret-scan.sh ) )
[ -z "$out3" ] && ok "secret-scan ignores non-commit commands" || bad "secret-scan fired on a non-commit command"

echo "== telemetry scope: logs ONLY in course-org (rsm-msba-*) repos =="
mk_repo() { mkdir -p "$1"; ( cd "$1" && git init -q && { [ -n "$2" ] && git remote add origin "$2" || true; } ); rsm-claude-settings "$1" >/dev/null 2>&1; }
logged() { ls "$1"/.claude/usage-log/*.jsonl >/dev/null 2>&1; }

course="$tmp/course"; mk_repo "$course" "git@github.com:rsm-msba-26-27/asn.git"
printf '{"session_id":"s1","prompt":"hello world"}' | ( cd "$course" && bash .claude/hooks/usage-log.sh )
logged "$course" && ok "course repo: prompt IS logged" || bad "course repo: prompt was NOT logged"

personal="$tmp/personal"; mk_repo "$personal" "git@github.com:somestudent/my-side-project.git"
printf '{"session_id":"s1","prompt":"secret personal idea"}' | ( cd "$personal" && bash .claude/hooks/usage-log.sh )
logged "$personal" && bad "PERSONAL repo was logged (privacy leak!)" || ok "personal repo: NOT logged"

noorigin="$tmp/noorigin"; mk_repo "$noorigin" ""
printf '{"session_id":"s1","prompt":"no remote"}' | ( cd "$noorigin" && bash .claude/hooks/usage-log.sh )
logged "$noorigin" && bad "no-origin repo was logged" || ok "no-origin repo: NOT logged"

echo "== stale-tests: nudges when a .py is newer than the last test run =="
st="$tmp/stale"; mkdir -p "$st/tests"; rsm-claude-settings "$st" >/dev/null 2>&1
printf 'def test_x():\n    assert True\n' > "$st/tests/test_x.py"
touch -t 202001010000 "$st/.claude/.last-test-time"   # last run: long ago; the .py is newer
o=$(bash "$st/.claude/hooks/check-stale-tests.sh")
echo "$o" | grep -q 'systemMessage' && ok "stale nudge fires when tests are behind" || bad "stale nudge did NOT fire"
touch -t 202001010000 "$st/tests/test_x.py"; touch "$st/.claude/.last-test-time"  # tests now older than last run
o2=$(bash "$st/.claude/hooks/check-stale-tests.sh")
[ -z "$o2" ] && ok "no nudge when tests are fresh" || bad "nudge fired even though tests are fresh"

echo "== ruff-format: formats a Python file Claude edited =="
rf="$tmp/ruff"; mkdir -p "$rf"; rsm-claude-settings "$rf" >/dev/null 2>&1
printf 'x=1\ny =2\n' > "$rf/bad.py"
printf '{"tool_input":{"file_path":"%s"}}' "$rf/bad.py" | bash "$rf/.claude/hooks/ruff-format.sh"
if grep -q 'x = 1' "$rf/bad.py"; then ok "ruff-format reformatted the file"; else bad "ruff-format did not format"; fi

echo "== justfile: single workspace file, upward-search + invocation_directory =="
jf_src="${RSM_FLAKE:-$HOME/rsm-nix}/claude/justfile"
grep -q '_rsmManaged' "$jf_src" && ok "justfile has _rsmManaged marker" || bad "justfile missing _rsmManaged marker"
grep -q 'invocation_directory()' "$jf_src" && ok "justfile uses invocation_directory" || bad "justfile missing invocation_directory"
# deploy ONE justfile at a fake workspace root; run `just` from a DEEP subfolder
ws="$tmp/ws"; mkdir -p "$ws/sub/deep"; cp "$jf_src" "$ws/justfile"
recipes=$( cd "$ws/sub/deep" && just --list 2>/dev/null )   # found via just's upward search
for r in test check review save verify hooks-off hooks-on hooks-status status-line status-line-off; do
  echo "$recipes" | grep -qw "$r" && ok "justfile recipe: $r" || bad "justfile missing recipe: $r"
done
here=$( cd "$ws/sub/deep" && just --evaluate _here 2>/dev/null )
[ "$here" = "$ws/sub/deep" ] && ok "just from a subfolder targets the invocation dir" || bad "invocation_directory wrong: [$here] != [$ws/sub/deep]"
# hooks toggle must run in the INVOCATION dir (writes settings.local.json there, not at the justfile)
( cd "$ws/sub/deep" && just hooks-off >/dev/null 2>&1 )
grep -q '"disableAllHooks"[[:space:]]*:[[:space:]]*true' "$ws/sub/deep/.claude/settings.local.json" 2>/dev/null \
  && ok "just hooks-off writes to the invocation dir" || bad "hooks-off did not target the invocation dir"
[ ! -e "$ws/.claude/settings.local.json" ] && ok "hooks-off did NOT write to the justfile's own dir" || bad "hooks-off wrote to the justfile dir, not the invocation dir"
( cd "$ws/sub/deep" && just hooks-on >/dev/null 2>&1 )
[ ! -f "$ws/sub/deep/.claude/settings.local.json" ] && ok "just hooks-on clears the override" || bad "hooks-on left settings.local.json behind"
# statusline.sh renders model + context/limits as REMAINING (left) + reset countdown
sl="${RSM_FLAKE:-$HOME/rsm-nix}/claude/statusline.sh"
[ -f "$sl" ] && ok "statusline.sh present" || bad "statusline.sh missing"
_r=$(( $(date +%s 2>/dev/null || printf '%(%s)T' -1) + 8000 ))
slout=$(printf '%s' '{"model":{"display_name":"Opus X"},"workspace":{"current_dir":"'"$HOME"'/x"},"context_window":{"remaining_percentage":60},"rate_limits":{"five_hour":{"used_percentage":10,"resets_at":'"$_r"'},"seven_day":{"used_percentage":50}}}' | bash "$sl" 2>/dev/null)
{ echo "$slout" | grep -q 'Opus X' \
    && echo "$slout" | grep -qE '5h, 90% left \(' \
    && echo "$slout" | grep -q '7d, 50% left'; } \
  && ok "statusline.sh renders model + limits-left + reset" || bad "statusline.sh output wrong: [$slout]"

echo "== non-destructive: rsm-claude-settings keeps a folder's OWN CLAUDE.md / settings.json =="
g="$tmp/guard"; mkdir -p "$g/.claude"
printf '# my own rules\n' > "$g/CLAUDE.md"
printf '{"permissions":{"allow":["Bash(ls:*)"]}}\n' > "$g/.claude/settings.json"
rsm-claude-settings "$g" >/dev/null 2>&1
grep -q 'my own rules' "$g/CLAUDE.md" && ok "kept foreign CLAUDE.md" || bad "clobbered foreign CLAUDE.md"
{ grep -q 'Bash(ls' "$g/.claude/settings.json" && ! grep -q '_rsmManaged' "$g/.claude/settings.json"; } \
  && ok "kept foreign .claude/settings.json" || bad "clobbered foreign settings.json"

echo "== workspace justfile deploy: refresh RSM-managed, keep a user's own (mirrors rsm-setup 1b3) =="
_deploy_wsjf() {  # mirrors the deploy decision in bin/rsm-setup step 1b3
  _wsdir="$1"; _jf="$1/justfile"
  [ -e "$_wsdir/Justfile" ] && return 0
  if [ ! -e "$_jf" ] || grep -qE '_rsmManaged|Provided by the RSM-MSBA environment' "$_jf" 2>/dev/null; then
    cp -f "$jf_src" "$_jf"
  fi
}
d1="$tmp/wsjf-absent"; mkdir -p "$d1"; _deploy_wsjf "$d1"
grep -q '_rsmManaged' "$d1/justfile" 2>/dev/null && ok "deploys the justfile when absent" || bad "did not deploy when absent"
d2="$tmp/wsjf-old"; mkdir -p "$d2"
printf '# Common commands.\n# (Provided by the RSM-MSBA environment as a simple, editable starting point.)\ntest:\n\tuv run pytest\n' > "$d2/justfile"
_deploy_wsjf "$d2"
grep -q 'invocation_directory()' "$d2/justfile" && ok "upgrades an old RSM justfile" || bad "did not upgrade an old RSM justfile"
d3="$tmp/wsjf-foreign"; mkdir -p "$d3"; printf 'mine:\n\t@echo hi\n' > "$d3/justfile"
_deploy_wsjf "$d3"
{ grep -q '^mine:' "$d3/justfile" && ! grep -q '_rsmManaged' "$d3/justfile"; } \
  && ok "keeps a user's own workspace justfile" || bad "clobbered a user's own workspace justfile"

[ "$fail" -eq 0 ] && echo "claude-harness check passed." || { echo "claude-harness check FAILED." >&2; exit 1; }
