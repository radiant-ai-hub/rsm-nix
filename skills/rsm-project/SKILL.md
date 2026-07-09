---
name: rsm-project
description: >-
  Set up and manage RSM-MSBA Python project folders (direnv + uv + venv) — the
  alternative to conda. Use when a student wants to open a folder directly in VS
  Code with the right interpreter, give a folder its own isolated packages, or
  add/remove/verify Python packages in a project.
---

# RSM project environments

RSM-MSBA students do coursework in `~/rsm-msba`, where every subfolder shares one
big `nix-uv` Python environment (direnv activates it automatically at any depth).
The `rsm-here` command sets up an individual folder so it can be opened
**directly** in VS Code (or a terminal) with the full Nix toolchain and the right
Python — and, optionally, its **own** isolated packages (like a conda env).

Use this skill when the student wants to start/organize a project folder, or to
install / remove / check Python packages in one.

## Set up a folder

```bash
rsm-here                    # the CURRENT folder, using the shared nix-uv Python
rsm-here PATH               # that folder instead (created if needed); may be
                            #   nested under ~/rsm-msba OR standalone anywhere
rsm-here --venv [PATH]      # also give the folder its OWN reproducible .venv
                            #   (pyproject.toml + uv.lock) — the conda alternative
```

`rsm-here` writes `.envrc`, `.vscode/` settings (interpreter + terminal), and — with
`--venv` — a starter `pyproject.toml` (minimal: just `ipykernel`) and `.gitignore`,
then `direnv allow`s it. Open the folder in VS Code; the interpreter/kernel is
already selected. With `--venv` the prompt shows `(folder)` and `python` is the
local `./.venv`.

Guidance:

- **Shared env (no `--venv`)** — the default for coursework. One environment, all
  the data-science packages, nothing to manage.
- **`--venv`** — reach for this when the student needs isolation or a package set
  that shouldn't touch the shared environment. Works anywhere, including outside
  `~/rsm-msba`.

## Add or remove packages (a `--venv` folder)

Run these **inside the folder** so they target its local `.venv`:

```bash
uv add polars duckdb        # install + record in pyproject.toml / uv.lock
uv remove duckdb
```

direnv re-syncs on the next prompt; if a change isn't picked up, run
`direnv reload`. Prefer `uv add` over `pip install` so the dependency is recorded
and reproducible.

## Verify the environment (the doctor)

```bash
rsm-project-check
```

It imports every declared dependency and reports each one:

- `ok` — imports fine.
- `missing` — declared but not installed → run `uv sync` (or `uv add`).
- `FAIL` — installed but won't load. Usually a **missing system library**
  (the error mentions a `.so` file). This is an advanced case: the package needs
  a native dependency the base environment doesn't provide. Tell the student and,
  if appropriate, help them find the right system library (most data-science
  wheels — polars, duckdb, xgboost, torch — are self-contained and won't hit
  this).

## Notes

- A `--venv` folder uses the flake's Nix `python313`, so it's reproducible and no
  separate Python is downloaded.
- A standalone folder outside `~/rsm-msba` gets the full compute environment via
  direnv, but the fancy `p10k` prompt only auto-loads inside `~/rsm-msba`
  (cosmetic).
