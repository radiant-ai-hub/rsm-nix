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

# Put the uv base environment first on PATH so `python`, `ipython`, `jupyter`,
# etc. resolve to the course-core environment once rsm-setup has run.
if [ -d "$RSM_UV_ENV/bin" ]; then
  case ":$PATH:" in
    *":$RSM_UV_ENV/bin:"*) ;;
    *) PATH="$RSM_UV_ENV/bin:$PATH" ;;
  esac
  export PATH
fi

# Quarto should render with the course-core interpreter.
export QUARTO_PYTHON="${QUARTO_PYTHON:-$RSM_UV_ENV/bin/python}"

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
