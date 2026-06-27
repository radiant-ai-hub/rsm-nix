# %% [markdown]
# # Am I in the RSM-MSBA (Nix/direnv) environment?
#
# Open this file in VS Code and click **Run Cell** (or run
# `python examples/check_environment.py` in a terminal). It verifies that you are
# using the Nix/direnv environment — and *only* that one — and not a stray
# virtualenv such as an old `/opt/base-uv` on a server.

# %%
import os
import shutil
import sys

ok, warn = [], []


def _norm(p):
    return os.path.realpath(p) if p else p


def check(label, cond, detail=""):
    (ok if cond else warn).append((label, detail))
    mark = "ok  " if cond else "WARN"
    print(f"[{mark}] {label}" + (f"  ->  {detail}" if detail else ""))


print("== interpreter ==")
# Use sys.executable / sys.prefix as-is — do NOT resolve the symlink, or the
# venv path collapses to the underlying Nix-store python and the check misfires.
exe = sys.executable
prefix = sys.prefix
rsm_env = os.environ.get("RSM_UV_ENV", "")
print(f"  sys.executable = {exe}")
print(f"  sys.prefix     = {prefix}")
print(f"  RSM_UV_ENV     = {rsm_env or '(unset)'}")

# The nix-uv environment lives under <workspace>/.rsm-msba/envs/nix-uv;
# sys.prefix is that venv root.
in_rsm_env = ".rsm-msba/envs/nix-uv" in prefix or (bool(rsm_env) and _norm(prefix) == _norm(rsm_env))
check("python is the nix-uv environment", bool(in_rsm_env), prefix)

# %%
print("\n== no foreign virtualenv leaking in ==")
venv = os.environ.get("VIRTUAL_ENV", "")
print(f"  VIRTUAL_ENV = {venv or '(empty)'}")
check(
    "VIRTUAL_ENV is empty or the RSM env (not /opt/base-uv or another venv)",
    (venv == "") or (rsm_env and venv == rsm_env),
    venv or "(empty)",
)
path = os.environ.get("PATH", "")
check("PATH does not contain /opt/base-uv", "/opt/base-uv" not in path)

# %%
print("\n== tools resolve to the Nix/RSM environment ==")
for tool in ["python", "uv", "quarto", "psql", "git", "gh"]:
    p = shutil.which(tool) or "(not found)"
    good = ("/nix/store/" in p) or (rsm_env and p.startswith(rsm_env))
    check(f"{tool:7s} -> {p}", bool(good), "")

# %%
print("\n== RSM environment variables (set by the dev shell) ==")
for var in ["RSM_FLAKE", "RSM_WORKSPACE", "RSMBASE", "RSM_UV_ENV", "PGUSER", "PGPORT", "PGDATABASE", "QUARTO_PYTHON"]:
    print(f"  {var:14s} = {os.environ.get(var, '(unset)')}")
check("RSM_WORKSPACE is set", bool(os.environ.get("RSM_WORKSPACE")))

# %%
print("\n== a few key packages import and report versions ==")
import importlib

for mod, label in [("numpy", "numpy"), ("polars", "polars"), ("sklearn", "scikit-learn"),
                   ("xgboost", "xgboost"), ("sqlalchemy", "sqlalchemy"), ("psycopg2", "psycopg2"),
                   ("pyrsm", "pyrsm")]:
    try:
        m = importlib.import_module(mod)
        check(f"import {label}", True, getattr(m, "__version__", "?"))
    except Exception as exc:  # noqa: BLE001
        check(f"import {label}", False, str(exc))

# %%
print("\n" + "=" * 60)
if not warn:
    print("ALL GOOD — you are in the RSM-MSBA Nix/direnv environment.")
else:
    print(f"{len(warn)} WARNING(S) — you may not be fully in the RSM environment:")
    for label, detail in warn:
        print(f"  - {label}  {detail}")
    print("\nIf VIRTUAL_ENV points at /opt/base-uv (a server's old base env),")
    print("see examples/README.md -> 'Server: the old /opt/base-uv leak'.")
print("=" * 60)
