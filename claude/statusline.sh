#!/usr/bin/env bash
# RSM-MSBA Claude Code status line:
#
#   host | ~/folder (branch*) | direnv | Model | ctx NN% left | 5h, NN% left (Xh Ym) | 7d, NN% left (Xd Yh)
#   (the value in parentheses is the time until that limit window resets)
#
# The `*` after a branch means the working tree has uncommitted changes -- a
# nudge for the commit you meant to make. `direnv!` (rather than `direnv`)
# means an .envrc governs this folder but has NOT been allowed, so none of its
# settings are active; that is the usual cause of "my venv/packages vanished",
# and the fix is `direnv allow`.
#
# All percentages are REMAINING ("left"): context memory still free, and the
# 5-hour / 7-day usage-limit headroom (5h/7d appear on Claude Pro/Max only, with
# a countdown to when that window resets).
#
# Claude Code runs this with a MINIMAL PATH, so `jq` may not be on it (on NixOS
# jq lives only in the Nix profile, never in /usr/bin). We locate jq by absolute
# path, and derive host/folder/branch/time with bash builtins so no other
# command is assumed to be on PATH.
#
# The dirty marker and direnv segment are the only parts that shell out. Both
# are optional by construction: each is skipped silently when its binary is not
# found, and each is bounded by `timeout` so a huge tree or a stalled network
# mount can never wedge the prompt. The line always renders.

# Read stdin with a bash builtin rather than `cat`: this script exists because
# PATH may be minimal, and `cat` was the last thing it assumed. `-d ''` reads to
# EOF and returns non-zero there, which is expected, hence the `|| true`.
IFS= read -r -d '' input || true

# --- locate jq (PATH, then Nix / system / Homebrew) ------------------------
# Same search order for every helper we need, since none of them can be assumed
# on PATH: PATH first, then Nix (user, system, default), Homebrew, system dirs.
_find() {
  local n="$1" c
  if command -v "$n" >/dev/null 2>&1; then printf '%s' "$n"; return 0; fi
  for c in \
    "/etc/profiles/per-user/${USER:-$(id -un 2>/dev/null)}/bin/$n" \
    "$HOME/.nix-profile/bin/$n" \
    "/run/current-system/sw/bin/$n" \
    "/nix/var/nix/profiles/default/bin/$n" \
    "/opt/homebrew/bin/$n" \
    "/usr/local/bin/$n" \
    "/usr/bin/$n" \
    "/bin/$n"; do
    [ -x "$c" ] && { printf '%s' "$c"; return 0; }
  done
  return 1
}

_jq="$(_find jq)"
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

# --- optional helpers, located once ----------------------------------------
_to="$(_find timeout)" || _to=""

# --- uncommitted changes: a `*` after the branch ---------------------------
# Bounded and optional. `git diff --quiet HEAD` checks staged and unstaged in a
# single pass and stops at the first difference, which is far cheaper than
# `git status --porcelain` walking the whole tree.
#
# Exit codes matter here: git diff --quiet returns 0 for clean, 1 for "there
# are differences", and anything else (including 124 from timeout) for an error
# we did not resolve. Only 1 earns the marker -- on error or timeout we show
# nothing rather than assert a state we never verified.
dirty=""
if [ -n "$branch" ]; then
  _git="$(_find git)" || _git=""
  if [ -n "$_git" ]; then
    if [ -n "$_to" ]; then
      "$_to" 0.4 "$_git" -C "$cwd" --no-optional-locks diff --no-ext-diff \
        --quiet --ignore-submodules HEAD -- >/dev/null 2>&1
    else
      "$_git" -C "$cwd" --no-optional-locks diff --no-ext-diff \
        --quiet --ignore-submodules HEAD -- >/dev/null 2>&1
    fi
    [ "$?" = 1 ] && dirty="*"
  fi
fi

# --- direnv: present, and actually allowed? --------------------------------
# `direnv` means an .envrc governs this folder. `direnv!` means it is there but
# has not been allowed, so nothing in it is in effect -- the usual explanation
# for a project's packages or environment variables mysteriously missing, and
# the fix is `direnv allow`.
#
# We key on the .envrc that governs the folder, NOT on whether it is loaded in
# this process: the status line runs in a subprocess that inherits no DIRENV_*
# variables, so a "is it loaded" test could never fire.
direnv_seg=""
_direnv="$(_find direnv)" || _direnv=""
if [ -n "$_direnv" ] && [ -d "$cwd" ]; then
  if [ -n "$_to" ]; then
    _ds=$(cd "$cwd" 2>/dev/null && "$_to" 0.4 "$_direnv" status --json 2>/dev/null)
  else
    _ds=$(cd "$cwd" 2>/dev/null && "$_direnv" status --json 2>/dev/null)
  fi
  if [ -n "$_ds" ]; then
    _found=$(printf '%s' "$_ds" | "$_jq" -r '.state.foundRC.path // empty' 2>/dev/null)
    if [ -n "$_found" ]; then
      # direnv reports allowed as a number: 0 = allowed, non-zero = not.
      _allowed=$(printf '%s' "$_ds" | "$_jq" -r '.state.foundRC.allowed // empty' 2>/dev/null)
      case "$_allowed" in
        0|true|"") direnv_seg="direnv" ;;
        *)         direnv_seg="direnv!" ;;
      esac
    fi
  fi
fi

# --- helpers ---------------------------------------------------------------
_now=$(printf '%(%s)T' -1 2>/dev/null)          # current epoch (bash builtin, bash 4.2+)
[ -z "$_now" ] && _now=$(date +%s 2>/dev/null)  # fallback for old bash (macOS /bin/bash 3.2)
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
if   [ -n "$short_cwd" ] && [ -n "$branch" ]; then parts+=("$short_cwd ($branch$dirty)")
elif [ -n "$short_cwd" ];                    then parts+=("$short_cwd")
elif [ -n "$repo" ] && [ -n "$branch" ];     then parts+=("$repo ($branch$dirty)")
fi
[ -n "$direnv_seg" ] && parts+=("$direnv_seg")
[ -n "$model" ]    && parts+=("$model")
[ -n "$ctx_left" ] && parts+=("ctx ${ctx_left}% left")
[ -n "$f_left" ]   && parts+=("5h, ${f_left}% left${f_in:+ ($f_in)}")
[ -n "$w_left" ]   && parts+=("7d, ${w_left}% left${w_in:+ ($w_in)}")

out=""
for p in "${parts[@]}"; do out="${out:+$out | }$p"; done
printf '%s' "$out"
