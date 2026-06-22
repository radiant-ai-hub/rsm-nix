# RSM-MSBA examples & quick functionality tests

Small, runnable files to confirm the environment works — and that you are using
the **Nix/direnv** environment (not a stray one). Open any `.py` file in VS Code
and click **Run Cell** (the `# %%` markers make them interactive notebooks), or
run them from a workspace terminal.

| File | What it checks | How to run |
|---|---|---|
| `check_environment.py` | **Are you in the RSM/Nix env only?** interpreter, no foreign `VIRTUAL_ENV`, tools, versions | `python examples/check_environment.py` |
| `python_data_stack.py` | numpy/pandas/sklearn/statsmodels/xgboost/polars/plotnine | `python examples/python_data_stack.py` |
| `postgres_python.py` | PostgreSQL via SQLAlchemy + pandas | `rsm-pg-start` then run it |
| `postgres_vscode.pgsql` | PostgreSQL via the VS Code SQL extension | see comments in the file |
| `quarto_report.qmd` | Quarto renders with the RSM Python | `quarto render examples/quarto_report.qmd` |
| `spark_pyspark.py` | optional Spark/Hadoop profile | `nix develop .#spark-hadoop` then run it |

Run everything at once (starts Postgres, runs the Python + Quarto checks):

```bash
nix develop -c bash examples/run-examples.sh
```

## Start here: "Which environment am I in?"

```bash
python examples/check_environment.py
```

`python` should resolve to `…/rsm-msba/.rsm-msba/envs/base/bin/python`,
`VIRTUAL_ENV` should be empty (or that same path), and `/opt/base-uv` must not be
on `PATH`. If you see warnings, read the next section.

## Server: the old `/opt/base-uv` leak

On a server you may have used the **old** container/host setup whose default
environment is `/opt/base-uv`. Some of those servers ship an
`/etc/zsh/zshrc` snippet (`_uv_auto_activate`) that **auto-activates
`/opt/base-uv/.venv` on every shell and every `cd`**. Because `nix develop` is
impure by default (it inherits the parent shell's environment) and nix-direnv
does not support a pure mode, that stray `VIRTUAL_ENV` can leak into the dev
shell. That is the "base-uv" you may see even while in the Nix/direnv env.

The dev shell now neutralizes a foreign `VIRTUAL_ENV` on load, but the cleanest
fix is to stop the old auto-activation:

- **Per user (no root)** — add to `~/.zshrc`:

  ```bash
  # Disable the legacy /opt/base-uv auto-activation from /etc/zsh/zshrc
  autoload -Uz add-zsh-hook
  add-zsh-hook -d chpwd _uv_auto_activate 2>/dev/null
  unfunction _uv_auto_activate 2>/dev/null
  [[ "${VIRTUAL_ENV:-}" == "/opt/base-uv/.venv" ]] && deactivate 2>/dev/null
  ```

- **Whole server (root, recommended)** — remove the `_uv_auto_activate`
  function and its `add-zsh-hook chpwd …` / final call from `/etc/zsh/zshrc`.
  It is a leftover from the old container era and conflicts with the Nix flake.

> "Pure mode" is **not** the fix: nix-direnv ignores `--pure`, and a truly pure
> `nix develop --ignore-environment` strips `HOME`, `TERM`, `LANG`, and
> `SSH_AUTH_SOCK`, which breaks VS Code Remote-SSH and interactive shells.
