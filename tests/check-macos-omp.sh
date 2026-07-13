# check-macos-omp.sh
#
# Regression guard for the "import xgboost works in a notebook but FAILS in a
# terminal" bug on macOS, across EVERY way a student runs Python in a terminal:
#
#   1. the shared nix-uv environment (~/rsm-msba)
#   2. an isolated per-project .venv (rsm-new-project --venv, sub-dir or standalone)
#
# xgboost dlopen()s @rpath/libomp.dylib; we supply the OpenMP runtime from Nix.
# In a terminal, macOS SIP strips DYLD_* from the environment a protected shell
# hands to python, so the DYLD_-based path does not survive. The fix is the
# sitecustomize preload on PYTHONPATH (shell/rsm-sitecustomize.py, installed by
# rsm-setup) -- and because it preloads libomp into the *process* (not into a
# specific venv), it fixes ANY interpreter that inherits the RSM env, including a
# project's own .venv with its own xgboost wheel.
#
# This test RE-CREATES the terminal/SIP condition by removing
# DYLD_FALLBACK_LIBRARY_PATH, then asserts xgboost still imports. macOS-only; a
# no-op on Linux (there is no SIP there and LD_LIBRARY_PATH already reaches a
# terminal).
#
#   nix develop -c bash tests/check-macos-omp.sh
#
# Exits non-zero if xgboost cannot load libomp without DYLD_* in any case.

set -euo pipefail

: "${RSM_WORKSPACE:=$PWD}"
: "${RSMBASE:=$RSM_WORKSPACE/.rsm-msba}"
: "${RSM_UV_ENV:=$RSMBASE/envs/nix-uv}"

if [ "$(uname -s)" != "Darwin" ]; then
  echo "check-macos-omp: skipped (not macOS — no SIP DYLD stripping)"
  exit 0
fi

ppath="$RSMBASE/pythonpath"
if [ ! -f "$ppath/sitecustomize.py" ]; then
  echo "check-macos-omp: FAIL — preload not installed at $ppath/sitecustomize.py" >&2
  echo "                 (rsm-setup step '2b' did not run)" >&2
  exit 1
fi

fail=0

# assert_import <label> <python> : xgboost must import with DYLD_ stripped
# (as SIP does) but the preload active via PYTHONPATH.
assert_import() {
  local label="$1" py="$2"
  if env -u DYLD_FALLBACK_LIBRARY_PATH PYTHONPATH="$ppath" \
       "$py" -c "import xgboost" >/dev/null 2>&1; then
    echo "check-macos-omp: PASS — $label: xgboost imports without DYLD_*"
  else
    echo "check-macos-omp: FAIL — $label: xgboost cannot load libomp without DYLD_*" >&2
    fail=1
  fi
  # Negative control: preload disabled AND DYLD_ stripped -> should FAIL. If it
  # succeeds, libomp is resolvable some other way here and this run can't fully
  # prove the fix -- warn, don't hard-fail.
  if env -u DYLD_FALLBACK_LIBRARY_PATH -u RSM_OMP_LIBDIR PYTHONPATH="" \
       "$py" -c "import xgboost" >/dev/null 2>&1; then
    echo "check-macos-omp: WARN — $label: xgboost imported with the preload disabled;" >&2
    echo "                 libomp is independently resolvable here." >&2
  fi
}

# --- Case 1: the shared nix-uv environment ---------------------------------
shared_py="$RSM_UV_ENV/bin/python"
if [ -x "$shared_py" ]; then
  assert_import "shared nix-uv env" "$shared_py"
else
  echo "check-macos-omp: FAIL — $shared_py missing (run rsm-setup first)" >&2
  fail=1
fi

# --- Case 2: an isolated per-project .venv (rsm-new-project --venv) ---------
# Emulate a project venv: a fresh uv venv (its own site-packages) with its own
# xgboost wheel. The direnv env still exports PYTHONPATH + RSM_OMP_LIBDIR (the
# --venv override re-points only PATH/VIRTUAL_ENV), so this .venv's python must
# preload libomp too. This case doubles as the isolated-venv NOTEBOOK case: a
# VS Code notebook on that interpreter inherits the same direnv env.
proj="$(mktemp -d)"
trap 'rm -rf "$proj"' EXIT
if uv venv --python "$shared_py" "$proj/.venv" >/dev/null 2>&1 &&
   uv pip install --python "$proj/.venv/bin/python" --quiet xgboost >/dev/null 2>&1; then
  assert_import "isolated project .venv" "$proj/.venv/bin/python"
else
  echo "check-macos-omp: WARN — could not build an isolated venv (uv/network?); skipping case 2" >&2
fi

exit "$fail"
