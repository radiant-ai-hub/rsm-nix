#!/usr/bin/env bash
# RSM-MSBA Claude Code status line:
#
#   host | ~/folder (branch) | Model | ctx NN% left | 5h NN% left, resets in Xh | 7d NN% left, resets in Xd
#
# All percentages are REMAINING ("left"): context memory still free, and the
# 5-hour / 7-day usage-limit headroom (5h/7d appear on Claude Pro/Max only, with
# a countdown to when that window resets).
#
# Claude Code runs this with a MINIMAL PATH, so `jq` may not be on it (on NixOS
# jq lives only in the Nix profile, never in /usr/bin). We locate jq by absolute
# path, and derive host/folder/branch/time with bash builtins so no other
# command is assumed to be on PATH.

input=$(cat)

# --- locate jq (PATH, then Nix / system / Homebrew) ------------------------
_jq=""
if command -v jq >/dev/null 2>&1; then
  _jq="jq"
else
  for _c in \
    "/etc/profiles/per-user/${USER:-$(id -un 2>/dev/null)}/bin/jq" \
    "$HOME/.nix-profile/bin/jq" \
    "/run/current-system/sw/bin/jq" \
    "/nix/var/nix/profiles/default/bin/jq" \
    "/opt/homebrew/bin/jq" \
    "/usr/local/bin/jq" \
    "/usr/bin/jq"; do
    [ -x "$_c" ] && { _jq="$_c"; break; }
  done
fi
if [ -z "$_jq" ]; then
  printf 'RSM status line: jq not found'
  exit 0
fi
_get() { printf '%s' "$input" | "$_jq" -r "$1 // empty" 2>/dev/null; }

# --- fields from Claude Code's JSON ----------------------------------------
model=$(_get '.model.display_name')
cwd=$(_get '.workspace.current_dir // .cwd')
repo=$(_get '.workspace.repo | if . then "\(.owner)/\(.name)" else empty end')
c_rem=$(_get '.context_window.remaining_percentage')
c_used=$(_get '.context_window.used_percentage')
f_used=$(_get '.rate_limits.five_hour.used_percentage')
f_reset=$(_get '.rate_limits.five_hour.resets_at')
w_used=$(_get '.rate_limits.seven_day.used_percentage')
w_reset=$(_get '.rate_limits.seven_day.resets_at')

# --- host / folder / branch (bash builtins; no external commands) ----------
host="${HOSTNAME%%.*}"
[ -z "$host" ] && host="$(hostname -s 2>/dev/null)"

short_cwd="$cwd"
case "$cwd" in
  "$HOME")   short_cwd="~" ;;
  "$HOME"/*) short_cwd="~/${cwd#"$HOME"/}" ;;
esac

branch=""
_d="$cwd"
while [ -n "$_d" ] && [ "$_d" != "/" ]; do
  if [ -f "$_d/.git/HEAD" ]; then
    IFS= read -r _head < "$_d/.git/HEAD" 2>/dev/null
    case "$_head" in
      "ref: refs/heads/"*) branch="${_head#ref: refs/heads/}" ;;
      ?*) branch="${_head:0:7}" ;;   # detached HEAD -> short sha
    esac
    break
  fi
  _d="${_d%/*}"
done

# --- helpers ---------------------------------------------------------------
_now=$(printf '%(%s)T' -1 2>/dev/null)          # current epoch, bash builtin
_int() { [ -n "$1" ] && printf '%.0f' "$1"; }   # round
_left() { local u; u="$(_int "$1")"; [ -n "$u" ] && printf '%d' "$(( 100 - u ))"; }
_reset() {                                       # epoch -> "2h13m" / "5d6h" / "45m"
  [ -n "$1" ] && [ -n "$_now" ] || return
  local s=$(( $1 - _now )); [ "$s" -lt 0 ] && s=0
  local d=$(( s/86400 )) h=$(( (s%86400)/3600 )) m=$(( (s%3600)/60 ))
  if   [ "$d" -gt 0 ]; then printf '%dd%dh' "$d" "$h"
  elif [ "$h" -gt 0 ]; then printf '%dh%dm' "$h" "$m"
  else printf '%dm' "$m"; fi
}

# context "left": prefer the JSON's remaining_percentage, else 100 - used
ctx_left="$(_int "$c_rem")"; [ -z "$ctx_left" ] && ctx_left="$(_left "$c_used")"
f_left="$(_left "$f_used")"; f_in="$(_reset "$f_reset")"
w_left="$(_left "$w_used")"; w_in="$(_reset "$w_reset")"

# --- assemble --------------------------------------------------------------
parts=()
[ -n "$host" ] && parts+=("$host")
if   [ -n "$short_cwd" ] && [ -n "$branch" ]; then parts+=("$short_cwd ($branch)")
elif [ -n "$short_cwd" ];                    then parts+=("$short_cwd")
elif [ -n "$repo" ] && [ -n "$branch" ];     then parts+=("$repo ($branch)")
fi
[ -n "$model" ]    && parts+=("$model")
[ -n "$ctx_left" ] && parts+=("ctx ${ctx_left}% left")
[ -n "$f_left" ]   && parts+=("5h ${f_left}% left${f_in:+, resets in $f_in}")
[ -n "$w_left" ]   && parts+=("7d ${w_left}% left${w_in:+, resets in $w_in}")

out=""
for p in "${parts[@]}"; do out="${out:+$out | }$p"; done
printf '%s' "$out"
