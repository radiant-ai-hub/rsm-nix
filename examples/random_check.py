# %% [markdown]
# # Random-number reproducibility check
#
# Generates seeded random numbers and prints a short **SHA-256 fingerprint** for
# each, so you can compare results across **macOS**, **Windows (WSL)**, and
# **Linux (NixOS)**. With identical package versions, NumPy's modern generators
# are platform-independent, so the fingerprints *should* match everywhere. If the
# `OVERALL fingerprint` differs between two machines, the platform (or a package
# version) is the cause — historically this is what happened with R's RNG.
#
# Run it as a script (`python examples/random_check.py`) or open it / the
# matching `notebook_random_check.ipynb` and **Run All**.

# %%
import hashlib
import platform
import random
import sys

import numpy as np

print("platform :", platform.platform())
print("python   :", sys.version.split()[0])
print("numpy    :", np.__version__)


def fingerprint(arr):
    """Stable 16-hex-char SHA-256 of an array's raw float64 bytes."""
    a = np.ascontiguousarray(arr, dtype=np.float64)
    return hashlib.sha256(a.tobytes()).hexdigest()[:16]


# Python's built-in RNG (seeded).
random.seed(42)
py = [random.random() for _ in range(5)]
print("\npython random.random() x5:")
print("  ", [round(x, 12) for x in py])

# NumPy legacy global RNG (Mersenne Twister).
np.random.seed(42)
mt = np.random.rand(5)
print("\nnumpy legacy np.random.rand(5):")
print("  ", np.array2string(mt, precision=12, floatmode="fixed"))
print("   fingerprint:", fingerprint(mt))

# NumPy modern Generator (PCG64) — the recommended API.
rng = np.random.default_rng(42)
g_uniform = rng.random(5)
g_normal = rng.standard_normal(5)
g_ints = rng.integers(0, 1_000_000, 5)
print("\nnumpy default_rng(42).random(5):")
print("  ", np.array2string(g_uniform, precision=12, floatmode="fixed"))
print("   fingerprint:", fingerprint(g_uniform))
print("numpy default_rng(42).standard_normal(5):")
print("  ", np.array2string(g_normal, precision=12, floatmode="fixed"))
print("   fingerprint:", fingerprint(g_normal))
print("numpy default_rng(42).integers(0, 1e6, 5):")
print("  ", g_ints.tolist())

# One fingerprint over everything, for an at-a-glance cross-platform comparison.
overall = hashlib.sha256(
    (
        repr([round(x, 12) for x in py])
        + fingerprint(mt)
        + fingerprint(g_uniform)
        + fingerprint(g_normal)
        + repr(g_ints.tolist())
    ).encode()
).hexdigest()[:16]
print("\n==> OVERALL fingerprint:", overall)
print("    Compare this one string across macOS / Windows-WSL / Linux.")
