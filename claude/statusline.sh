#!/usr/bin/env bash
# RSM-MSBA Claude Code status line.
#
# Installed by `just status-line` into ~/.claude/settings.json (statusLine.command).
# Claude Code pipes a JSON blob on stdin; we print one line for the status bar:
#
#   <model> | ctx NN% used | 5h NN% | 7d NN%
#
# The 5h / 7d figures are the rolling rate-limit windows and appear only for
# Claude.ai Pro/Max sessions (API-key sessions omit them). Needs `jq` on PATH —
# it is in the RSM env, so launch `claude` from the RSM terminal.

input=$(cat)
_get() { printf '%s' "$input" | jq -r "$1 // empty" 2>/dev/null; }

model=$(_get '.model.display_name')
used=$(_get '.context_window.used_percentage')
five=$(_get '.rate_limits.five_hour.used_percentage')
week=$(_get '.rate_limits.seven_day.used_percentage')

parts=()
[ -n "$model" ] && parts+=("$model")
[ -n "$used" ]  && parts+=("ctx $(printf '%.0f' "$used")% used")
[ -n "$five" ]  && parts+=("5h $(printf '%.0f' "$five")%")
[ -n "$week" ]  && parts+=("7d $(printf '%.0f' "$week")%")

out=""
for p in "${parts[@]}"; do
  out="${out:+$out | }$p"
done
printf '%s' "$out"
