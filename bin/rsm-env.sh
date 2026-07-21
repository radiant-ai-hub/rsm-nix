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
# pgweb's web UI port, per-user for the same reason as PGPORT (on a shared server
# every student would otherwise collide on one 127.0.0.1 port). Kept clear of the
# PGPORT range (8765-9764) so a student's pgweb port can never clash with another
# student's Postgres port. VS Code Remote-SSH auto-forwards it to the laptop.
export PGWEB_PORT="${PGWEB_PORT:-$(( 9800 + $(id -u) % 1000 ))}"

# Claude Code (and any other npm global) installs into a USER-WRITABLE prefix so
# students and Claude can upgrade it themselves. It is intentionally NOT pinned
# by the flake — it ships updates very frequently and self-updates — while Node
# itself IS pinned by the flake. Put the prefix's bin on PATH so `claude` works.
export NPM_CONFIG_PREFIX="${NPM_CONFIG_PREFIX:-$RSMBASE/npm}"
# Keep the npm cache/logs workspace-local too, so npm never writes to ~/.npm
# (preserves the "no host mutation" guarantee and stays per-user on the server).
export NPM_CONFIG_CACHE="${NPM_CONFIG_CACHE:-$RSMBASE/npm-cache}"
case ":$PATH:" in
  *":$NPM_CONFIG_PREFIX/bin:"*) ;;
  *) PATH="$NPM_CONFIG_PREFIX/bin:$PATH"; export PATH ;;
esac

# Make the RSM sitecustomize (native-library preload) importable at EVERY Python
# startup. PYTHONPATH is not a DYLD_* var, so macOS SIP keeps it across the
# shell -> python hop where it strips DYLD_FALLBACK_LIBRARY_PATH -- that is what
# lets xgboost find libomp in a TERMINAL, not only in a notebook. The file is
# installed by rsm-setup; a missing dir is harmless (python just skips it).
# See shell/rsm-sitecustomize.py.
case ":${PYTHONPATH:-}:" in
  *":$RSMBASE/pythonpath:"*) ;;
  *) PYTHONPATH="$RSMBASE/pythonpath${PYTHONPATH:+:$PYTHONPATH}"; export PYTHONPATH ;;
esac

# rsm_seed_dir SRC DST: seed files from SRC into DST WITHOUT overwriting anything
# already in DST. Used to drop the flake's starter folders (e.g. data/) into the
# workspace on first setup and to add newly-shipped files on later runs, while
# never clobbering a student's own files. Creates DST as needed; a missing SRC is
# a no-op. Best-effort: it never fails the caller.
rsm_seed_dir() {
  [ -d "$1" ] || return 0
  mkdir -p "$2" || return 0
  cp -Rn "$1/." "$2/" 2>/dev/null || true
  return 0
}

# rsm_maybe_reexec HEAD_BEFORE HEAD_AFTER: if a `git pull` of the flake brought
# NEW commits, hand off to the freshly-pulled rsm-setup so a SINGLE `rsm-update`
# applies everything -- including changes to rsm-setup/rsm-env.sh themselves. The
# running copy can't apply those (a program can't swap its own code mid-run), so
# we re-run the new build via `nix develop`. On a successful hand-off this EXITS
# and never returns. It is a no-op (returns 0) when:
#   - we ARE already the re-run (RSM_SETUP_REEXECED set) -- the loop guard,
#   - no new commits were pulled (HEAD unchanged),
#   - or the new version can't be built/run (falls back to the current one).
# RSM_SETUP_REEXEC_CMD overrides the hand-off command (used by the tests only).
rsm_maybe_reexec() {
  if [ -n "${RSM_SETUP_REEXECED:-}" ]; then return 0; fi   # we are the re-run
  if [ "$1" = "$2" ]; then return 0; fi                     # no new commits
  if [ -n "${RSM_SETUP_REEXEC_CMD:-}" ]; then
    set -- "$RSM_SETUP_REEXEC_CMD"                           # test hook
  elif command -v nix >/dev/null 2>&1; then
    set -- nix develop "$RSM_FLAKE" -c rsm-setup
  else
    return 0                                                 # can't rebuild; keep going
  fi
  echo "==> A newer version was downloaded -- applying it now (one moment)..."
  if RSM_SETUP_REEXECED=1 "$@"; then
    exit 0
  fi
  echo "    (could not run the new version; continuing with the current one)" >&2
  return 0
}
