#!/usr/bin/env bash
# check-shell-ls.sh
#
# The rsm shell defines ls/lsa/lt as functions that use eza when it is on PATH
# and fall back to the system `ls` when it is not -- so `ls` never breaks with
# "command not found: eza" (before the Nix env loads, or after you cd OUT of the
# workspace and direnv unloads eza). This extracts the REAL function definitions
# from shell/zdotdir/zshrc and exercises both paths. Pure bash (the functions are
# POSIX-compatible):
#   bash tests/check-shell-ls.sh
set -euo pipefail

HERE="$(cd "$(dirname "$0")/.." && pwd)"
ZSHRC="$HERE/shell/zdotdir/zshrc"

REAL_LS="$(command -v ls)"   # capture the real `ls` BEFORE we define the function

# Extract the marked ls/lsa/lt function block from the zshrc and define them here.
fn_block="$(sed -n '/>>> rsm-ls-functions >>>/,/<<< rsm-ls-functions <<</p' "$ZSHRC")"
printf '%s' "$fn_block" | grep -q 'ls()' || { echo "check-shell-ls: could not extract ls functions from $ZSHRC" >&2; exit 1; }
eval "$fn_block"

fail=0
ok()  { printf '  \033[32mok\033[0m   %s\n' "$1"; }
bad() { printf '  \033[31mFAIL\033[0m %s\n' "$1"; fail=1; }

tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' EXIT
touch "$tmp/afile.txt"
mkdir "$tmp/ezabin" "$tmp/sysbin"
printf '#!/bin/sh\necho EZA-RAN\n' > "$tmp/ezabin/eza"; chmod +x "$tmp/ezabin/eza"
ln -s "$REAL_LS" "$tmp/sysbin/ls"

echo "== eza present => ls/lsa/lt use eza =="
for f in ls lsa lt; do
  out="$( export PATH="$tmp/ezabin:$tmp/sysbin"; "$f" "$tmp" 2>&1 )" || true
  echo "$out" | grep -q 'EZA-RAN' && ok "$f uses eza when present" || bad "$f did not use eza: [$out]"
done

echo "== eza ABSENT => fall back to system ls, no error =="
for f in ls lsa lt; do
  if out="$( export PATH="$tmp/sysbin"; "$f" "$tmp" 2>&1 )"; then
    if echo "$out" | grep -qiE 'not found'; then bad "$f errored on missing eza: [$out]"
    elif echo "$out" | grep -q 'afile.txt'; then ok "$f falls back to system ls"
    else bad "$f produced unexpected fallback output: [$out]"; fi
  else
    bad "$f returned non-zero when eza is absent"
  fi
done

[ "$fail" -eq 0 ] && echo "shell-ls check passed." || { echo "shell-ls check FAILED." >&2; exit 1; }
