# check-quarto-render.sh
#
# Exercise the ACTUAL Session-4 workflow end-to-end: `quarto render` of a .qmd
# with a {python} chunk. This drives the whole toolchain at once -- the pinned
# quarto, its jupyter engine, the nix-uv python it spawns, and the native
# libraries a chunk pulls in (xgboost -> libomp/libstdc++). Import-only checks
# never touched this path.
#
# Assertions:
#   0. quarto is the PINNED build and QUARTO_PYTHON is the nix-uv interpreter
#      (guards the "/opt/base-uv leaked QUARTO_PYTHON" and PATH-shadow regressions).
#   A. render a .qmd with a python chunk -> HTML is produced and contains the
#      chunk's output.
#   B. macOS only: the same render with DYLD_FALLBACK_LIBRARY_PATH stripped (the
#      SIP terminal condition) still succeeds -- proving the sitecustomize
#      preload reaches the kernel quarto spawns, not just a bare `python`.
#
#   nix develop -c bash tests/check-quarto-render.sh
#
# Exits non-zero on any failure.

set -euo pipefail

: "${RSM_WORKSPACE:=$PWD}"
: "${RSMBASE:=$RSM_WORKSPACE/.rsm-msba}"
: "${RSM_UV_ENV:=$RSMBASE/envs/nix-uv}"

fail=0

# 0. Toolchain identity ------------------------------------------------------
if ! command -v quarto >/dev/null 2>&1; then
  echo "check-quarto: FAIL — quarto not on PATH" >&2
  exit 1
fi
qbin="$(command -v quarto)"
case "$qbin" in
  /nix/store/*) echo "check-quarto: ok — quarto from the Nix env ($qbin)" ;;
  *) echo "check-quarto: FAIL — quarto resolves to $qbin, not the pinned Nix build" >&2
     echo "             (a system/Homebrew quarto is shadowing it on PATH)" >&2
     fail=1 ;;
esac

want_py="$RSM_UV_ENV/bin/python"
if [ "${QUARTO_PYTHON:-}" != "$want_py" ]; then
  echo "check-quarto: FAIL — QUARTO_PYTHON is '${QUARTO_PYTHON:-<unset>}', expected $want_py" >&2
  echo "             (a foreign QUARTO_PYTHON, e.g. /opt/base-uv, is leaking in)" >&2
  fail=1
else
  echo "check-quarto: ok — QUARTO_PYTHON is the nix-uv interpreter"
fi

# render <extra-env-stripping...> : render report.qmd in a temp dir, assert the
# HTML exists and carries the chunk output marker. Extra args are prepended to
# the quarto invocation via `env` (used to strip DYLD on macOS).
render_case() {
  local label="$1"; shift
  local d; d="$(mktemp -d)"
  cat > "$d/report.qmd" <<'QMD'
---
title: "render smoke test"
format: html
---

## Hello Quarto

```{python}
import pandas as pd
import numpy as np
import xgboost

print("RENDER_MARKER xgboost", xgboost.__version__)
pd.DataFrame({"x": [1, 2, 3], "y": [4, 5, 6]}).describe()
```
QMD
  local log="$d/quarto.log"
  if ( cd "$d" && "$@" quarto render report.qmd --to html >"$log" 2>&1 ) &&
     [ -f "$d/report.html" ] &&
     grep -q "RENDER_MARKER xgboost" "$d/report.html"; then
    echo "check-quarto: PASS ($label) — .qmd rendered; python chunk executed and xgboost loaded"
  else
    echo "check-quarto: FAIL ($label) — render did not produce expected HTML output" >&2
    tail -25 "$log" >&2 || true
    fail=1
  fi
  rm -rf "$d"
}

if [ ! -x "$want_py" ]; then
  echo "check-quarto: FAIL — $want_py missing (run rsm-setup first)" >&2
  exit 1
fi

# A. normal render (all platforms)
render_case "normal"

# B. macOS: render with DYLD stripped, as a SIP-protected shell would launch it.
if [ "$(uname -s)" = "Darwin" ]; then
  render_case "DYLD stripped (SIP)" env -u DYLD_FALLBACK_LIBRARY_PATH
fi

exit "$fail"
