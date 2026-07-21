#!/usr/bin/env bash
# check-reexec.sh
#
# Tests rsm_maybe_reexec (bin/rsm-env.sh): after a flake `git pull` brings NEW
# commits, rsm-setup must hand off to the freshly-pulled rsm-setup EXACTLY once
# (so a single `rsm-update` applies changes to rsm-setup itself), guarded against
# a loop, and be a no-op when nothing changed. RSM_SETUP_REEXEC_CMD stands in for
# the real `nix develop ... rsm-setup` hand-off, so no nix is needed. Pure bash:
#   bash tests/check-reexec.sh
set -euo pipefail

HERE="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck disable=SC1091
source "$HERE/bin/rsm-env.sh"    # provides rsm_maybe_reexec

fail=0
ok()  { printf '  \033[32mok\033[0m   %s\n' "$1"; }
bad() { printf '  \033[31mFAIL\033[0m %s\n' "$1"; fail=1; }

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
marker="$tmp/marker"

# Stand-ins for the freshly-pulled rsm-setup: record that they ran.
ok_cmd="$tmp/handoff-ok.sh";   printf '#!/usr/bin/env bash\necho ran > "%s"\nexit 0\n' "$marker" > "$ok_cmd"
bad_cmd="$tmp/handoff-fail.sh"; printf '#!/usr/bin/env bash\necho ran > "%s"\nexit 1\n' "$marker" > "$bad_cmd"
chmod +x "$ok_cmd" "$bad_cmd"

echo "== 1) new commits => hands off to the new version =="
rm -f "$marker"
# the hand-off calls `exit 0` on success, so run it in a subshell to keep going
( RSM_SETUP_REEXEC_CMD="$ok_cmd" rsm_maybe_reexec "AAA" "BBB" ) || true
[ -f "$marker" ] && ok "handed off on new commits" || bad "did NOT hand off on new commits"

echo "== 2) loop guard: we ARE the re-run => does NOT hand off =="
rm -f "$marker"
RSM_SETUP_REEXECED=1 RSM_SETUP_REEXEC_CMD="$ok_cmd" rsm_maybe_reexec "AAA" "BBB"
[ -f "$marker" ] && bad "loop guard failed (re-ran)" || ok "loop guard: did not re-run"

echo "== 3) no new commits (HEAD unchanged) => does NOT hand off =="
rm -f "$marker"
RSM_SETUP_REEXEC_CMD="$ok_cmd" rsm_maybe_reexec "SAME" "SAME"
[ -f "$marker" ] && bad "ran despite HEAD unchanged" || ok "no new commits: did not re-run"

echo "== 4) hand-off fails => falls back and continues (no exit) =="
rm -f "$marker"
cont="no"
RSM_SETUP_REEXEC_CMD="$bad_cmd" rsm_maybe_reexec "AAA" "BBB" && cont="yes"
[ "$cont" = "yes" ] && ok "continued with current version after a failed hand-off" || bad "did not continue on hand-off failure"

[ "$fail" -eq 0 ] && echo "reexec check passed." || { echo "reexec check FAILED." >&2; exit 1; }
