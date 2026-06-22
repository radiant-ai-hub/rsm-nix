#!/usr/bin/env python3
"""Import the full course-core stack and print versions for a few anchors.

Run with the uv base interpreter, e.g.:
    "$RSM_UV_ENV/bin/python" tests/check-python.py
Exits non-zero if any required package fails to import.
"""
from __future__ import annotations

import importlib
import sys

# (import name, friendly label)
MODULES = [
    # notebooks
    ("IPython", "ipython"),
    ("ipykernel", "ipykernel"),
    ("jupyter_client", "jupyter-client"),
    ("nbclient", "nbclient"),
    ("nbconvert", "nbconvert"),
    ("jupytext", "jupytext"),
    ("ipywidgets", "ipywidgets"),
    # data
    ("numpy", "numpy"),
    ("pandas", "pandas"),
    ("scipy", "scipy"),
    ("sklearn", "scikit-learn"),
    ("statsmodels", "statsmodels"),
    ("linearmodels", "linearmodels"),
    ("polars", "polars"),
    ("pyarrow", "pyarrow"),
    ("openpyxl", "openpyxl"),
    ("xlrd", "xlrd"),
    # database
    ("sqlalchemy", "sqlalchemy"),
    ("psycopg2", "psycopg2"),
    ("connectorx", "connectorx"),
    # viz / utils
    ("plotnine", "plotnine"),
    ("graphviz", "graphviz"),
    ("folium", "folium"),
    ("networkx", "networkx"),
    ("markdown", "markdown"),
    ("dotenv", "python-dotenv"),
    ("tqdm", "tqdm"),
    ("requests", "requests"),
    # rsm / course
    ("pyrsm", "pyrsm"),
    ("xgboost", "xgboost"),
    ("skmisc", "scikit-misc"),
    # text / nlp
    ("bs4", "beautifulsoup4"),
    ("nltk", "nltk"),
    ("spacy", "spacy"),
    ("textblob", "textblob"),
]

failures: list[str] = []
for mod, label in MODULES:
    try:
        importlib.import_module(mod)
    except Exception as exc:  # noqa: BLE001
        failures.append(f"{label} ({mod}): {exc}")

for anchor in ("numpy", "pandas", "sklearn", "xgboost"):
    try:
        m = importlib.import_module(anchor)
        print(f"  {anchor:<12} {getattr(m, '__version__', '?')}")
    except Exception:  # noqa: BLE001
        pass

if failures:
    print("\nFAILED imports:", file=sys.stderr)
    for f in failures:
        print(f"  - {f}", file=sys.stderr)
    sys.exit(1)

print(f"\nAll {len(MODULES)} course-core imports succeeded.")
