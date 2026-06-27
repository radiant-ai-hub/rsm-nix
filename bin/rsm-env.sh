# Shared RSM environment resolution.
# Prepended to the rsm-* wrapper scripts and sourced by the dev-shell hook, so
# the same locations are used whether a command runs in the dev shell, via
# direnv, or standalone via `nix run`.
#
# The flake and your coursework are intentionally SEPARATE so the flake can be
# updated/re-cloned with git without disturbing your work or built environment:
#
#   RSM_FLAKE     the flake repo you `git pull`         (default ~/rsm-nix)
#   RSM_WORKSPACE your coursework + state live here     (default ~/rsm-msba)
#   RSMBASE       RSM-owned state under the workspace   ($RSM_WORKSPACE/.rsm-msba)
#   RSM_UV_ENV    the "nix-uv" Python environment       ($RSMBASE/envs/nix-uv)
#
# The generated ~/rsm-msba/.envrc sets RSM_WORKSPACE explicitly; these defaults
# cover bootstrap (rsm-setup) and standalone use.

RSM_FLAKE="${RSM_FLAKE:-$HOME/rsm-nix}"
RSM_WORKSPACE="${RSM_WORKSPACE:-$HOME/rsm-msba}"
RSMBASE="${RSMBASE:-$RSM_WORKSPACE/.rsm-msba}"
RSM_UV_ENV="${RSM_UV_ENV:-$RSMBASE/envs/nix-uv}"

export RSM_FLAKE RSM_WORKSPACE RSMBASE RSM_UV_ENV
export UV_CACHE_DIR="${UV_CACHE_DIR:-$RSMBASE/uv-cache}"
export UV_LINK_MODE="${UV_LINK_MODE:-copy}"
export UV_PROJECT_ENVIRONMENT="${UV_PROJECT_ENVIRONMENT:-$RSM_UV_ENV}"
export UV_PYTHON_PREFERENCE="${UV_PYTHON_PREFERENCE:-only-system}"
export JUPYTER_PATH="${JUPYTER_PATH:-$RSMBASE/jupyter}"
export JUPYTER_DATA_DIR="${JUPYTER_DATA_DIR:-$RSMBASE/jupyter}"

export PGDATA="${PGDATA:-$RSMBASE/postgres/data}"
export PGHOST="${PGHOST:-$RSMBASE/postgres/socket}"
# Per-user default TCP port: on a shared server every student would otherwise
# bind 8765 and collide. id -u is stable per user, so this is deterministic.
# Override by exporting PGPORT yourself before entering the env.
export PGPORT="${PGPORT:-$(( 8765 + $(id -u) % 1000 ))}"
export PGDATABASE="${PGDATABASE:-rsm-msba}"
export PGUSER="${PGUSER:-$(id -un)}"
