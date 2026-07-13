# check-macos-omp.sh
#
# Regression guard for the "import xgboost works in a notebook but FAILS in a
# terminal" bug on macOS. xgboost dlopen()s @rpath/libomp.dylib; we supply the
# OpenMP runtime from Nix. In a terminal, macOS SIP strips DYLD_* from the
# environment a protected shell hands to python, so the DYLD_-based path does not
# survive -- the fix is the sitecustomize preload on PYTHONPATH
# (shell/rsm-sitecustomize.py, installed by rsm-setup).
#
# This test RE-CREATES the terminal/SIP condition by explicitly removing
# DYLD_FALLBACK_LIBRARY_PATH, then asserts xgboost still imports. macOS-only;
# a no-op on Linux (there is no SIP there).
#
#   nix develop -c bash tests/check-macos-omp.sh
#
# Exits non-zero if xgboost cannot load libomp without DYLD_*.

set -euo pipefail

: "${RSM_WORKSPACE:=$PWD}"
: "${RSMBASE:=$RSM_WORKSPACE/.rsm-msba}"
: "${RSM_UV_ENV:=$RSMBASE/envs/nix-uv}"

if [ "$(uname -s)" != "Darwin" ]; then
  echo "check-macos-omp: skipped (not macOS — no SIP DYLD stripping)"
  exit 0
fi

py="$RSM_UV_ENV/bin/python"
if [ ! -x "$py" ]; then
  echo "check-macos-omp: FAIL — $py missing (run rsm-setup first)" >&2
  exit 1
fi

# The preload file must actually be installed, or the fix isn't wired up.
if [ ! -f "$RSMBASE/pythonpath/sitecustomize.py" ]; then
  echo "check-macos-omp: FAIL — preload not installed at $RSMBASE/pythonpath/sitecustomize.py" >&2
  echo "                 (rsm-setup step '2b' did not run)" >&2
  exit 1
fi

# Negative control: with the preload disabled AND DYLD stripped, xgboost should
# FAIL. If it unexpectedly succeeds, libomp is resolvable some other way on this
# host and the positive test below cannot prove the fix — warn, don't hard-fail.
if env -u DYLD_FALLBACK_LIBRARY_PATH -u RSM_OMP_LIBDIR PYTHONPATH="" \
     "$py" -c "import xgboost" >/dev/null 2>&1; then
  echo "check-macos-omp: WARN — xgboost imported with the preload disabled;"
  echo "                 libomp is independently resolvable here, so this run"
  echo "                 cannot fully prove the sitecustomize fix." >&2
else
  echo "check-macos-omp: ok — xgboost FAILS without the preload (expected baseline)"
fi

# The real assertion: DYLD stripped exactly as SIP does it, preload active via
# PYTHONPATH -> xgboost must import.
if env -u DYLD_FALLBACK_LIBRARY_PATH \
     "$py" -c "import xgboost; print('  xgboost', xgboost.__version__, 'imported without DYLD_*')"; then
  echo "check-macos-omp: PASS — xgboost loads libomp in a terminal without DYLD_*"
else
  echo "check-macos-omp: FAIL — xgboost cannot load libomp without DYLD_* (terminal would break)" >&2
  exit 1
fi
