"""RSM native-library preload — installed at $RSMBASE/pythonpath/sitecustomize.py.

Why this exists
---------------
The xgboost wheel dlopen()s ``@rpath/libomp.dylib`` and only rpaths Homebrew
paths, so on macOS it needs an OpenMP runtime it can find. We ship one from Nix
and point ``DYLD_FALLBACK_LIBRARY_PATH`` at it — which works in a Jupyter kernel
(``kernel.json`` injects the var straight into the kernel process) but NOT in a
terminal: macOS System Integrity Protection strips every ``DYLD_*`` variable
from the environment a SIP-protected shell (the default ``/bin/zsh``) hands to
its children, so the variable is gone before ``python`` starts. That is the
"``import xgboost`` works in a notebook but fails in the terminal" bug.

The fix
-------
Preload libomp by ABSOLUTE path at every Python startup. Once the image is
resident under its install name (``@rpath/libomp.dylib``), xgboost's later
dlopen resolves against the already-loaded copy — no ``DYLD_*`` needed, so it
works in the terminal, in scripts, and in notebooks alike, and no
``brew install libomp`` is ever required. Python auto-imports ``sitecustomize``
from any dir on ``sys.path``; rsm-setup puts this on ``PYTHONPATH`` (a
non-``DYLD_*`` var that SIP keeps), which is what carries the fix across the
shell -> python hop.

The lib directory is read from ``RSM_OMP_LIBDIR`` (set by the flake's
nativeEnvHook) with a literal path baked in by rsm-setup as a fallback.
"""

import os
import sys

# Filled in by rsm-setup (sed-substituted). The live env var wins; this is only
# a fallback for the rare case the env var is absent. Left as the sentinel when
# not substituted (e.g. on Linux, where no preload is needed).
_BAKED_LIBDIR = "@RSM_OMP_LIBDIR@"


def _preload_openmp():
    # Only macOS is affected: Linux has no SIP, so LD_LIBRARY_PATH already
    # reaches python in a terminal, and Windows is not a target here.
    if sys.platform != "darwin":
        return

    import ctypes

    candidates = []

    # Primary: the copy installed next to this file by rsm-setup, whose install
    # name was rewritten to `@rpath/libomp.dylib`. Once it is resident under that
    # name, xgboost/lightgbm's later `dlopen("@rpath/libomp.dylib")` reuses it --
    # which the stock Nix libomp (absolute-store-path install name) cannot do.
    here = os.path.dirname(os.path.abspath(__file__))
    candidates.append(os.path.join(here, "libomp.dylib"))

    # Fallback: the raw Nix OpenMP dir(s). Preloading is harmless; on its own it
    # does NOT satisfy an `@rpath/libomp.dylib` request, but it covers the rare
    # case the @rpath copy above is missing.
    for source in (os.environ.get("RSM_OMP_LIBDIR", ""), _BAKED_LIBDIR):
        if not source or source.startswith("@"):
            continue
        for d in source.split(os.pathsep):
            if d:
                candidates.append(os.path.join(d, "libomp.dylib"))

    seen = set()
    for lib in candidates:
        if lib in seen or not os.path.exists(lib):
            continue
        seen.add(lib)
        try:
            ctypes.CDLL(lib, mode=ctypes.RTLD_GLOBAL)
        except OSError:
            continue
        return  # first successful load wins (the @rpath copy is tried first)


try:
    _preload_openmp()
except Exception:
    # A preload failure must never break interpreter startup — worst case the
    # student sees the original xgboost error, which is what we had before.
    pass
