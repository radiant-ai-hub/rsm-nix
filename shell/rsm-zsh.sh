# rsm-zsh.sh
#
# OPTIONAL zsh niceties for students who prefer zsh inside the dev shell.
# This is NOT auto-loaded. To use it, run `nix develop` and then:
#
#     exec zsh
#     source "$RSM_WORKSPACE/shell/rsm-zsh.sh"
#
# All history/cache is kept under $RSMBASE/zsh; nothing touches host dotfiles.

: "${RSMBASE:=${RSM_WORKSPACE:-$PWD}/.rsm-msba}"
: "${RSM_UV_ENV:=$RSMBASE/envs/base}"

mkdir -p "$RSMBASE/zsh/.cache" 2>/dev/null || true

HISTFILE="$RSMBASE/zsh/.zsh_history"
HISTSIZE=50000
SAVEHIST=50000
setopt append_history extended_history hist_ignore_dups hist_ignore_space \
  hist_reduce_blanks inc_append_history share_history 2>/dev/null || true

ZSH_COMPDUMP="$RSMBASE/zsh/.cache/.zcompdump"

alias c="clear"
alias sbase="source \"$RSM_UV_ENV/bin/activate\""
alias sp="source .venv/bin/activate"
alias pgweb="rsm-pgweb"

# Simple, dependency-free prompt marker.
autoload -Uz colors 2>/dev/null && colors 2>/dev/null || true
PROMPT='%F{cyan}[RSM-MSBA]%f %~ %# '

# uv shell completion, if available.
if command -v uv >/dev/null 2>&1; then
  eval "$(uv generate-shell-completion zsh)" 2>/dev/null || true
fi

# Personal customizations persisted in the workspace state dir.
if [ -r "$RSMBASE/zsh/local.zsh" ]; then
  source "$RSMBASE/zsh/local.zsh"
fi
