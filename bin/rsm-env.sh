# Shared RSM environment resolution.
# Sourced by the rsm-* wrapper scripts so they work both inside the dev shell
# (where these are already exported) and standalone via `nix run`.
#
# Everything resolves relative to the workspace root, which defaults to the
# current directory. The intended root is ~/rsm-msba.

RSM_WORKSPACE="${RSM_WORKSPACE:-$PWD}"
RSMBASE="${RSMBASE:-$RSM_WORKSPACE/.rsm-msba}"
RSM_UV_ENV="${RSM_UV_ENV:-$RSMBASE/envs/base}"

export RSM_WORKSPACE RSMBASE RSM_UV_ENV
export UV_CACHE_DIR="${UV_CACHE_DIR:-$RSMBASE/uv-cache}"
export UV_LINK_MODE="${UV_LINK_MODE:-copy}"
export UV_PROJECT_ENVIRONMENT="${UV_PROJECT_ENVIRONMENT:-$RSM_UV_ENV}"
export UV_PYTHON_PREFERENCE="${UV_PYTHON_PREFERENCE:-only-system}"
export JUPYTER_PATH="${JUPYTER_PATH:-$RSMBASE/jupyter}"
export JUPYTER_DATA_DIR="${JUPYTER_DATA_DIR:-$RSMBASE/jupyter}"

export PGDATA="${PGDATA:-$RSMBASE/postgres/data}"
export PGHOST="${PGHOST:-$RSMBASE/postgres/socket}"
export PGPORT="${PGPORT:-8765}"
export PGDATABASE="${PGDATABASE:-rsm-msba}"
export PGUSER="${PGUSER:-$(id -un)}"
