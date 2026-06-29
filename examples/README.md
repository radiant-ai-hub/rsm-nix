# RSM-MSBA examples & quick checks

Small, runnable files that confirm your environment works. They're the fastest way
to check that Python, the packages, notebooks, PostgreSQL, and Quarto are all set
up correctly.

**Three ways to run them** (any of these works):

- Open a notebook (`.ipynb`) in VS Code and click **Run All**.
- Open a script (`.py`) in VS Code and click **Run Cell** above a `# %%` marker
  (these files double as notebooks).
- Run from a terminal in `~/rsm-msba`, e.g. `python examples/check_environment.py`.

> New here? Start with `check_environment.py` (below) — it should print
> **ALL GOOD**. If a notebook can't find the kernel, pick **Python (nix-uv)** from
> the kernel picker (top-right), or run `rsm-setup` in a terminal and reload the
> window.

## Notebooks (`.ipynb`) — open in VS Code and **Run All**

| Notebook | What it checks |
|---|---|
| `notebook_intro.ipynb` | the **Python (nix-uv)** kernel: numpy, Polars, an inline plot |
| `notebook_pyrsm.ipynb` | a **pyrsm** regression (formula interface) + a plot |
| `notebook_postgres.ipynb` | PostgreSQL → Polars (run `rsm-pg-start` first) |
| `notebook_random_check.ipynb` | seeded random numbers + a **fingerprint** to compare across macOS / Windows / Linux |

## Scripts

| File | What it checks | How to run |
|---|---|---|
| `check_environment.py` | **Are you in the RSM/Nix env only?** interpreter, no foreign `VIRTUAL_ENV`, tools, versions | `python examples/check_environment.py` |
| `python_data_stack.py` | numpy/**polars**/**duckdb**/sklearn/statsmodels/xgboost/plotnine | `python examples/python_data_stack.py` |
| `pyrsm_example.py` | **pyrsm** linear + logistic regression (Polars data) | `python examples/pyrsm_example.py` |
| `random_check.py` | seeded RNG + a one-line fingerprint to compare across platforms | `python examples/random_check.py` |
| `postgres_python.py` | PostgreSQL via SQLAlchemy + **Polars** | `rsm-pg-start` then run it |
| `postgres_vscode.pgsql` | PostgreSQL via the VS Code SQL extension | see comments in the file |
| `postgres-createdb.sh` | load two practice databases (**Northwind**, **WestCoastImporters**) into PostgreSQL | `bash examples/postgres-createdb.sh` |
| `quarto_report.qmd` | Quarto renders with the RSM Python | `quarto render examples/quarto_report.qmd` |
| `spark_pyspark.py` | optional Spark/Hadoop profile | `nix develop .#spark-hadoop` then run it |

Run everything at once (starts PostgreSQL, runs the Python + Quarto checks and the
notebooks):

```bash
bash examples/run-examples.sh
```

## Comparing random numbers across platforms

`random_check.py` (and the matching `notebook_random_check.ipynb`) generate seeded
random numbers and print a short **`OVERALL fingerprint`**. Run it on macOS,
Windows (WSL), and Linux and compare that one string. With the same package
versions, NumPy's modern generators are platform-independent, so the fingerprints
should match. (Historically, R's random numbers could differ across platforms —
this check makes it easy to see whether that happens here.)

## Practice SQL databases (Northwind + WestCoastImporters)

To get two ready-made databases to practice SQL on, run:

```bash
bash examples/postgres-createdb.sh
```

It starts PostgreSQL (if needed) and loads **Northwind** and
**WestCoastImporters** from the SQL dumps in `examples/sql/` (they ship with the
repo, so it works offline). It's safe to re-run — existing databases are skipped.
When it finishes, connect with `rsm-pg-psql -d Northwind` (or
`-d WestCoastImporters`), browse them with `rsm-pgweb`, or open them from VS Code's
SQL tools.

## "Which environment am I in?"

```bash
python examples/check_environment.py
```

`python` should resolve to `…/rsm-msba/.rsm-msba/envs/nix-uv/bin/python`,
`VIRTUAL_ENV` should be empty (or that same path), and `/opt/base-uv` must not be
on `PATH`. If you see warnings, read the advanced note below.

---

## Advanced (servers): the old `/opt/base-uv` leak

*You can skip this on a laptop.* On some older Rady servers a leftover snippet in
`/etc/zsh/zshrc` (`_uv_auto_activate`) auto-activates `/opt/base-uv/.venv` on every
shell and every `cd`. Because `nix develop` is impure by default (it inherits the
parent shell's environment) and nix-direnv has no pure mode, that stray
`VIRTUAL_ENV` can leak into the dev shell — that's the "base-uv" you may see even
while in the Nix/direnv env.

The dev shell now neutralizes a foreign `VIRTUAL_ENV` on load, but the cleanest fix
is to stop the old auto-activation:

- **Per user (no root)** — add to `~/.zshrc`:

  ```bash
  # Disable the legacy /opt/base-uv auto-activation from /etc/zsh/zshrc
  autoload -Uz add-zsh-hook
  add-zsh-hook -d chpwd _uv_auto_activate 2>/dev/null
  unfunction _uv_auto_activate 2>/dev/null
  [[ "${VIRTUAL_ENV:-}" == "/opt/base-uv/.venv" ]] && deactivate 2>/dev/null
  ```

- **Whole server (root, recommended)** — remove the `_uv_auto_activate` function
  and its `add-zsh-hook chpwd …` / final call from `/etc/zsh/zshrc`. It is a
  leftover from the old container era and conflicts with the Nix flake.

> "Pure mode" is **not** the fix: nix-direnv ignores `--pure`, and a truly pure
> `nix develop --ignore-environment` strips `HOME`, `TERM`, `LANG`, and
> `SSH_AUTH_SOCK`, which breaks VS Code Remote-SSH and interactive shells.
