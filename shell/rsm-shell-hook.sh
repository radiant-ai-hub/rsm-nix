# rsm-shell-hook.sh
#
# Sourced from the default devShell's shellHook (and therefore by direnv).
# Assumes the RSM env header (bin/rsm-env.sh) has already run, so RSMBASE,
# RSM_UV_ENV, PG*, JUPYTER_* etc. are exported.
#
# This must stay cheap and idempotent: it runs on every `nix develop` and on
# every direnv reload. It NEVER writes to host dotfiles (~/.zshrc, ~/.bashrc).

# Create RSM-owned state directories (cheap, idempotent).
mkdir -p \
  "$RSMBASE/envs" \
  "$RSMBASE/uv-cache" \
  "$RSMBASE/jupyter" \
  "$RSMBASE/postgres" \
  "$RSMBASE/zsh" \
  "$RSMBASE/logs" 2>/dev/null || true

# Repair a POISONED UV_PROJECT_ENVIRONMENT inherited from the parent shell.
#
# It used to be defaulted to the shared nix-uv env (bin/rsm-env.sh), which is
# what let a `uv sync` in a course folder rewrite the environment every folder
# shares. That default is gone -- but removing it does not help a shell (or a
# VS Code window) that was ALREADY RUNNING when the fix landed: the old value
# lives in that process's environment and is inherited by everything it starts,
# including new integrated terminals. Clear it here, so entering the RSM
# environment repairs the shell instead of carrying the hazard forward.
#
# Deliberately NOT in bin/rsm-env.sh: that header is also prepended to the `uv`
# guard, where unsetting the variable would silently redirect an explicit
# `UV_PROJECT_ENVIRONMENT=$RSM_UV_ENV uv sync` to ./.venv instead of refusing it
# with an explanation. Only shells get repaired; uv still reports the refusal.
if [ "${UV_PROJECT_ENVIRONMENT:-}" = "$RSM_UV_ENV" ]; then
  unset UV_PROJECT_ENVIRONMENT
fi

# Neutralize any foreign, pre-activated Python virtualenv inherited from the
# parent (login) shell. `nix develop` is IMPURE by default (it inherits the
# calling shell's environment), and nix-direnv does not support pure mode, so a
# stray VIRTUAL_ENV — e.g. an old /opt/base-uv that a server's /etc/zsh/zshrc
# auto-activates — would otherwise leak in and could send `pip`/`uv` installs to
# the wrong place. Make the RSM-MSBA environment the only active one.
if [ -n "${VIRTUAL_ENV:-}" ] && [ "${VIRTUAL_ENV:-}" != "$RSM_UV_ENV" ]; then
  _rsm_stale_bin="$VIRTUAL_ENV/bin"
  _rsm_newpath=""
  _rsm_ifs="$IFS"; IFS=":"
  for _rsm_p in $PATH; do
    [ "$_rsm_p" = "$_rsm_stale_bin" ] && continue
    _rsm_newpath="${_rsm_newpath:+$_rsm_newpath:}$_rsm_p"
  done
  IFS="$_rsm_ifs"
  PATH="$_rsm_newpath"; export PATH
  unset VIRTUAL_ENV VIRTUAL_ENV_PROMPT _rsm_stale_bin _rsm_newpath _rsm_p _rsm_ifs
fi

# Activate the nix-uv environment the way a normal venv would: put it first on
# PATH and mark it active via VIRTUAL_ENV. Setting VIRTUAL_ENV (not just PATH) is
# what makes the environment visibly "on" — `which python` points at it, uv
# targets it, and prompt frameworks (powerlevel10k's virtualenv segment) show
# `(nix-uv)`. direnv snapshots the environment, so leaving the workspace cleanly
# reverts all of this — exactly like sourcing/deactivating a venv.
if [ -d "$RSM_UV_ENV/bin" ]; then
  case ":$PATH:" in
    *":$RSM_UV_ENV/bin:"*) ;;
    *) PATH="$RSM_UV_ENV/bin:$PATH" ;;
  esac
  export PATH
  export VIRTUAL_ENV="$RSM_UV_ENV"
  export VIRTUAL_ENV_PROMPT="(nix-uv) "
fi

# Quarto must render with the course-core interpreter. FORCE it (not a ":-"
# default): a QUARTO_PYTHON leaked from the login shell — e.g. a server's
# deprecated /opt/base-uv that /etc/zsh/zshrc auto-activates — would otherwise
# hijack every render, silently, whenever its packages happen to overlap. A
# project-local venv re-exports QUARTO_PYTHON AFTER this hook (see
# rsm-mkdir), so per-project overrides still win.
export QUARTO_PYTHON="$RSM_UV_ENV/bin/python"

# Convenience aliases (available under `nix develop`; bash).
alias c="clear"
alias sbase="source \"$RSM_UV_ENV/bin/activate\""
alias sp="source .venv/bin/activate"
alias pgweb="rsm-pgweb"

# Lightweight prompt marker, without clobbering an existing custom PS1.
if [ -n "${BASH_VERSION:-}" ]; then
  case "${PS1:-}" in
    *'[RSM-MSBA]'*) ;;
    *) export PS1="[RSM-MSBA] ${PS1:-\\w\\$ }" ;;
  esac
fi

# One-time-per-session banner (suppress with RSM_QUIET=1).
if [ -z "${RSM_QUIET:-}" ] && [ -z "${RSM_BANNER_SHOWN:-}" ]; then
  export RSM_BANNER_SHOWN=1
  printf '%s\n' "==================================================="
  printf '%s\n' " RSM-MSBA computing environment (Nix flake)"
  printf '%s\n' "   workspace : $RSM_WORKSPACE"
  printf '%s\n' "   state     : $RSMBASE"
  if [ ! -x "$RSM_UV_ENV/bin/python" ]; then
    printf '%s\n' "   next step : run 'rsm-setup' to build the Python environment"
  else
    printf '%s\n' "   python    : $RSM_UV_ENV"
  fi
  printf '%s\n' "   db        : rsm-pg-start | rsm-pg-psql | rsm-pgweb"
  printf '%s\n' "==================================================="
fi
