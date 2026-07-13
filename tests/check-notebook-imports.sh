# check-notebook-imports.sh
#
# Prove the NOTEBOOK path: the "Python (nix-uv)" Jupyter kernel can import
# xgboost even when the LAUNCHER (VS Code / plain jupyter / a SIP-protected shell
# on macOS) passes NOTHING useful through -- because rsm-setup bakes the
# native-library search var into kernel.json.
#
# Two assertions, both cross-platform:
#   A. The real kernel boots and imports xgboost (kernelspec is actually usable).
#   B. Spawn the kernel's python with the ambient native-lib var REMOVED but
#      kernel.json's own `env` overlaid -- i.e. exactly "launcher provides
#      nothing, kernel.json provides everything". xgboost must still import.
#
# The native-lib var is per-OS:
#   macOS -> DYLD_FALLBACK_LIBRARY_PATH   Linux -> LD_LIBRARY_PATH
#
#   nix develop -c bash tests/check-notebook-imports.sh
#
# Exits non-zero if the notebook kernel cannot import xgboost from kernel.json alone.

set -euo pipefail

: "${RSM_WORKSPACE:=$PWD}"
: "${RSMBASE:=$RSM_WORKSPACE/.rsm-msba}"
: "${RSM_UV_ENV:=$RSMBASE/envs/nix-uv}"
: "${JUPYTER_DATA_DIR:=$RSMBASE/jupyter}"
: "${JUPYTER_PATH:=$RSMBASE/jupyter}"
export JUPYTER_DATA_DIR JUPYTER_PATH

py="$RSM_UV_ENV/bin/python"
kj="$JUPYTER_DATA_DIR/kernels/nix-uv/kernel.json"

if [ ! -x "$py" ]; then
  echo "check-notebook: FAIL — $py missing (run rsm-setup first)" >&2
  exit 1
fi
if [ ! -f "$kj" ]; then
  echo "check-notebook: FAIL — kernelspec not installed at $kj (run rsm-setup)" >&2
  exit 1
fi

# A. The real kernel boots and imports xgboost (launcher keeps its env here).
"$py" - "$kj" <<'PY'
import sys, queue
from jupyter_client.manager import start_new_kernel

km, kc = start_new_kernel(kernel_name="nix-uv")
ok = False
try:
    kc.execute("import xgboost; print('KERNEL_XGB_OK', xgboost.__version__)")
    while True:
        try:
            msg = kc.get_iopub_msg(timeout=90)
        except queue.Empty:
            break
        t = msg["msg_type"]; c = msg.get("content", {})
        if t == "stream" and "KERNEL_XGB_OK" in c.get("text", ""):
            ok = True; print("  A. real kernel:", c["text"].strip())
        if t == "error":
            print("  KERNEL ERROR:", "\n".join(c.get("traceback", [])), file=sys.stderr)
        if t == "status" and c.get("execution_state") == "idle":
            break
finally:
    kc.stop_channels(); km.shutdown_kernel(now=True)
sys.exit(0 if ok else 1)
PY
echo "check-notebook: PASS (A) — the nix-uv kernel boots and imports xgboost"

# B. Simulate a launcher that provides NOTHING: strip the ambient native-lib var,
#    overlay ONLY kernel.json's baked env, run the kernel's python -c import.
"$py" - "$kj" <<'PY'
import json, os, subprocess, sys

spec = json.load(open(sys.argv[1]))
kpy = spec["argv"][0]
kenv = dict(spec.get("env", {}))

var = "DYLD_FALLBACK_LIBRARY_PATH" if sys.platform == "darwin" else "LD_LIBRARY_PATH"
if var not in kenv:
    print(f"check-notebook: FAIL (B) — kernel.json does not bake {var}; a notebook "
          f"would break whenever the launcher omits it. rsm-setup must run inside "
          f"the dev shell so nativeEnvHook has set {var}.", file=sys.stderr)
    sys.exit(1)

# Ambient env with the native-lib var(s) removed = launcher passes nothing;
# then overlay kernel.json's env (the fallback under test).
base = {k: v for k, v in os.environ.items()
        if k not in ("LD_LIBRARY_PATH", "DYLD_FALLBACK_LIBRARY_PATH")}
base.update(kenv)

r = subprocess.run(
    [kpy, "-c", "import xgboost; print('OK', xgboost.__version__)"],
    env=base, capture_output=True, text=True,
)
if r.returncode != 0 or "OK" not in r.stdout:
    print("check-notebook: FAIL (B) — kernel.json env alone cannot import xgboost",
          file=sys.stderr)
    print(r.stderr.strip()[-800:], file=sys.stderr)
    sys.exit(1)
print(f"  B. kernel.json env only ({var} baked): xgboost {r.stdout.split()[1]}")

# Negative control: without kernel.json's env AND the native var stripped, it
# should fail -- otherwise the assertion above proves nothing. Warn if it passes.
neg = subprocess.run([kpy, "-c", "import xgboost"], env={
    k: v for k, v in os.environ.items()
    if k not in ("LD_LIBRARY_PATH", "DYLD_FALLBACK_LIBRARY_PATH")
}, capture_output=True, text=True)
if neg.returncode == 0:
    print("check-notebook: WARN (B) — xgboost imported even without the baked env; "
          "the native lib is independently resolvable here.", file=sys.stderr)
PY
echo "check-notebook: PASS (B) — notebook kernel imports xgboost from kernel.json alone"
