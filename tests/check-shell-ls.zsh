#!/usr/bin/env zsh
# check-shell-ls.zsh
#
# Guards the ls/lsa/lt block in shell/zdotdir/zshrc against the regression that
# broke the workspace shell:
#   * oh-my-zsh sets `alias ls='ls --color=tty'`. With that alias live, a bare
#     `ls() { ... }` alias-EXPANDS to `ls --color=tty () { ... }` and fails to
#     PARSE -- which aborted the REST of .zshrc (p10k config included). The block
#     must `unalias` first so it sources cleanly even when ls is aliased.
#   * After sourcing, ls/lsa/lt must be FUNCTIONS (so they override the alias and
#     use eza), and must fall back to the system `ls` when eza is off PATH.
# Must run under zsh (the bug is zsh alias expansion); `zsh -n` cannot catch it
# because it never executes the earlier `source oh-my-zsh.sh`.
emulate -L zsh

HERE="${0:A:h}/.."
ZSHRC="$HERE/shell/zdotdir/zshrc"
REAL_LS="$(whence -p ls)"                 # the external ls, ignoring aliases/functions

integer fail=0
ok()  { print -P "  %F{green}ok%f   $1" }
bad() { print -P "  %F{red}FAIL%f $1"; fail=1 }

tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT
# Extract the marked block and append a marker so we can tell it sourced fully.
sed -n '/>>> rsm-ls-functions >>>/,/<<< rsm-ls-functions <<</p' "$ZSHRC" > "$tmp/block.zsh"
print -r -- 'print SOURCED_MARKER' >> "$tmp/block.zsh"

# Reproduce oh-my-zsh's aliases -- the exact thing that broke parsing.
alias ls='ls --color=tty'
alias lsa='ls -A'
alias lt='ls'

print "== sources cleanly even when ls/lsa/lt are aliased (the p10k-breaking bug) =="
# Source in the CURRENT shell (not $(...) -- a subshell would discard the
# functions), capturing output to a file so a parse error is contained.
if source "$tmp/block.zsh" > "$tmp/out" 2>&1 && grep -q SOURCED_MARKER "$tmp/out"; then
  ok "block sourced fully (no parse error)"
else
  bad "block FAILED to source with ls aliased: $(cat "$tmp/out")"
fi

print "== ls/lsa/lt are functions afterward (override the alias) =="
for f in ls lsa lt; do
  [[ "$(whence -w $f)" == *function* ]] && ok "$f is a function" || bad "$f is not a function: $(whence -w $f)"
done

# fake eza that announces itself; a sysbin with only the real ls
mkdir -p "$tmp/ezabin" "$tmp/sysbin"; touch "$tmp/afile.txt"
{ print '#!/bin/sh'; print 'echo EZA-RAN' } > "$tmp/ezabin/eza"; chmod +x "$tmp/ezabin/eza"
ln -s "$REAL_LS" "$tmp/sysbin/ls"

print "== eza present => uses eza; eza absent => falls back to system ls =="
for f in ls lsa lt; do
  out="$( export PATH="$tmp/ezabin:$tmp/sysbin"; $f "$tmp" 2>&1 )"
  [[ "$out" == *EZA-RAN* ]] && ok "$f uses eza when present" || bad "$f did not use eza: [$out]"
done
for f in ls lsa lt; do
  if out="$( export PATH="$tmp/sysbin"; $f "$tmp" 2>&1 )"; then
    if [[ "$out" == *"not found"* ]]; then bad "$f errored on missing eza: [$out]"
    elif [[ "$out" == *afile.txt* ]]; then ok "$f falls back to system ls"
    else bad "$f unexpected fallback output: [$out]"; fi
  else
    bad "$f returned non-zero when eza is absent"
  fi
done

(( fail == 0 )) && { print "shell-ls check passed."; exit 0 } || { print "shell-ls check FAILED." >&2; exit 1 }
