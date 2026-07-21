<!-- generated from docs/src/readme.qmd — edit the .qmd, then run docs/src/render-docs.sh -->

# RSM-MSBA computing environment

The computing environment for the Rady MSBA program — Python, Quarto,
PostgreSQL, and the course packages — **the same computing environment
on your laptop and on the Rady MSBA server**.

## A. On your own laptop

One command installs everything — VS Code, the environment, and your
workspace at `~/rsm-msba`. Follow the guide for your computer:

- **macOS (Apple Silicon — M1/M2/M3/M4):**
  **[docs/student-macos.md](docs/student-macos.md)**
- **Windows 11:** **[docs/student-wsl2.md](docs/student-wsl2.md)**
- **Linux (Ubuntu/Debian or NixOS):**
  **[docs/student-linux.md](docs/student-linux.md)**

You do **not** need to install VS Code, Nix, or anything else by hand —
the all-in-one-installer does it for you. When it’s done, you open the
`~/rsm-msba` folder in VS Code and pick the **Python (nix-uv)** kernel
for notebooks.

## B. On the Rady server

Use the Rady MSBA server through VS Code on your laptop. You connect
over **Tailscale** and compute runs on the server.

Full walkthrough covers Tailscale setup, and the campus VPN option:
**[docs/connect-server.md](docs/connect-server.md)**

---

# Using the environment

## Layout

```text
~/rsm-nix/      the flake (a git repo) — update with: cd ~/rsm-nix && git pull
~/rsm-msba/     your workspace
├── .envrc      generated; loads the flake from ~/rsm-nix
├── .rsm-msba/  state: envs/nix-uv, postgres, jupyter (survives flake updates)
├── mgta403/    a course folder — can be its own git repo
└── mgta464/
```

The flake (`~/rsm-nix`) is pure machinery you `git pull`; your
coursework and built `nix-uv` environment live under `~/rsm-msba`, which
is **not** a git repo, so each course folder can be its own. Nothing is
written to host dotfiles (`~/.zshrc`, `~/.bashrc`). To fully reset,
delete `~/rsm-msba/.rsm-msba`.

### Organizing project folders

Everything under `~/rsm-msba` shares the one `nix-uv` environment —
direnv activates it automatically in every subfolder, at any depth, so
most coursework needs nothing extra. To open a single folder
**directly** in VS Code (e.g. an assignment that is its own git repo)
with the right interpreter, or to give a folder its **own** isolated
packages, use `rsm-new-project`:

```bash
rsm-new-project                   # set up the CURRENT folder (shared nix-uv Python)
rsm-new-project ~/projects/thesis # a standalone folder anywhere (created if needed)
rsm-new-project --venv            # give this folder its OWN reproducible .venv
```

`--venv` is the alternative to a conda environment: a project-local
`.venv` you grow with `uv add …` and check with `rsm-project-check`,
layered on the flake’s system tools (Python, Quarto, PostgreSQL, Node).
In VS Code you can also just ask Claude — the `rsm-project` skill drives
all of this for you.

## Using VS Code

The smoothest workflow uses the **direnv** VS Code extension so the
RSM-MSBA environment activates automatically — no manual interpreter
selection, no venv juggling. This repository ships a `.vscode/` config,
so when you open `~/rsm-msba` VS Code offers to install the right
extensions and points Python at the base environment for you.

1.  **Open the workspace** — in VS Code use **File → Open Folder…** and
    choose `~/rsm-msba` (the per-OS guides walk through this step). From
    a terminal you can also run `code ~/rsm-msba`, or open a single
    course folder, e.g. `code ~/rsm-msba/mgta403` — direnv finds the
    environment by walking up to `~/rsm-msba/.envrc`.

2.  **Extensions are already installed** by the all-in-one installer (on
    a server, run `rsm-vscode-ext` once in the connected window). If VS
    Code ever shows a prompt — “This workspace has extension
    recommendations” — click **Install All**. The key ones are
    **direnv** (`mkhl.direnv`), **Python** (`ms-python.python`),
    **Jupyter** (`ms-toolsai.jupyter`), and **Quarto**
    (`quarto.quarto`).

3.  **Allow direnv** — the direnv extension asks to allow `.envrc` the
    first time; click **Allow** (or run `direnv allow` once in the
    integrated terminal). From then on, every integrated terminal and
    the Python/Jupyter tooling use the RSM-MSBA environment
    automatically — `python`, `quarto`, `rsm-pg-*`, etc. are already on
    `PATH`.

4.  **Pick the kernel for notebooks** — open a `.ipynb`, click the
    kernel picker (top-right), and choose **Python (nix-uv)**. For `.py`
    files the interpreter is already set to
    `~/rsm-msba/.rsm-msba/envs/nix-uv/bin/python`; VS Code remembers
    your choice per folder.

That’s it. Open a notebook or script in any course folder and run — no
activation step needed.

**Opening one folder on its own.** To open a single course/assignment
folder directly (its own VS Code window and git repo) with the right
interpreter, run `rsm-new-project` in it once. Add `--venv` to give that
folder its **own** isolated packages (`uv add …`, checked with
`rsm-project-check`) — the conda alternative. You can also just ask
Claude in the editor; the `rsm-project` skill handles setting up folders
and adding/verifying packages.

> Tip: keep one VS Code window open on `~/rsm-msba` so every course
> folder shares the same Explorer, environment, PostgreSQL, and kernel.
> Reopen the folder (or run **Developer: Reload Window**) after
> `rsm-setup` so the new kernel and interpreter are detected.

## The terminal toolkit

Inside `~/rsm-msba` you get a configured zsh shell (oh-my-zsh +
powerlevel10k) with autosuggestions, syntax highlighting, and a few
conveniences. It loads automatically when you enter the workspace, in VS
Code **or** a plain SSH terminal.

**Getting around**

- `z <name>` — jump to a folder you’ve visited before
  (e.g. `z mgta403`); powered by
  [zoxide](https://github.com/ajeetdsouza/zoxide).
- `..`, `...`, `....` — go up 1 / 2 / 3 directories.
- `ls`, `lsa`, `lt` — directory listings via [eza](https://eza.rocks);
  `lt` is a 2-level tree with git status.

**Python environment**

- The `nix-uv` environment is active automatically — you’ll see
  `(nix-uv)` in the prompt, and `python` / `jupyter` resolve to it.
- `sbase` — re-activate the nix-uv environment if you ever need to.
- `sp` — activate a project-local `.venv` (after `uv venv`); `de` —
  deactivate.

**Git and GitHub**

- `rsm-github` — one-time setup of your Git identity and a GitHub SSH
  key (run once; `github` also works but a shell alias can shadow it, so
  prefer `rsm-github`).
- `gh` — the GitHub CLI (`gh repo clone …`, `gh auth login`, …).

**PostgreSQL**

- `pg` — database status plus a menu of all the commands (see PostgreSQL
  below).

**Personal tweaks (optional)**

Put personal zsh settings in `~/.rsm-local.zsh` — it’s sourced last and
survives a workspace reset. For example, to use vi keybindings:

```bash
echo 'bindkey -v' >> ~/.rsm-local.zsh
```

## Using UV for Python packages

The environment uses [uv](https://docs.astral.sh/uv/) for Python package
management. The shared `nix-uv` environment
(`~/rsm-msba/.rsm-msba/envs/nix-uv`) already has the course-core
packages and is active in the dev shell.

### Add a package for a class or project

When a project needs an extra package, add it **to that project with
`uv add`** (not `uv pip install`) so it is tracked in the project’s
`pyproject.toml` and `uv.lock`:

```bash
cd ~/rsm-msba/my_project
uv init .                 # once — creates pyproject.toml
uv add polars             # add a package (tracked + locked)
uv run python -c "import polars as pl; print(pl.__version__)"
```

`uv run` executes inside the project’s environment; `uv add` /
`uv remove` keep `pyproject.toml` and `uv.lock` in sync. To remove a
project environment, delete its `.venv` (and the `uv init` scaffolding)
or the whole folder.

### Change the shared course-core packages

The `nix-uv` package list is defined in the flake’s `pyproject.toml`
(`~/rsm-nix/pyproject.toml`). To add or pin a package for **everyone**,
edit that file and re-sync the environment:

```bash
# edit ~/rsm-nix/pyproject.toml (add the package under dependencies), then:
rsm-python-sync           # rebuild the nix-uv env to match the list
```

## PostgreSQL

A workspace-local PostgreSQL instance is included — no system service,
no Docker. Data lives under `~/rsm-msba/.rsm-msba/postgres`.

```bash
pg                                 # overview: status + all the commands below
rsm-pg-start                       # start (initializes on first run)
rsm-pg-psql                        # open psql on the rsm-msba database
rsm-pg-psql -c "SELECT version();" # run one statement
rsm-pgweb                          # browse at http://127.0.0.1:8282
rsm-pg-status                      # is it running?
rsm-pg-stop                        # stop it
```

Run **`pg`** any time for a quick status (running? which port?) plus a
reminder of these commands.

Connection details: host = socket under `.rsm-msba/postgres/socket` (or
`127.0.0.1`), port = **`$PGPORT`** (run `echo $PGPORT`), databases =
`rsm-msba` and your username. On your own machine the port is stable; on
a shared server it is derived per-user (so students don’t collide on one
port) — always read it from `$PGPORT` rather than hard-coding `8765`.

## Quarto

Quarto (pinned to 1.9.13 for everyone) is included and configured to
render with the base Python environment:

```bash
quarto --version
quarto render report.qmd
```

## Example notebooks and scripts

`~/rsm-msba/examples` has small, runnable checks — open any of them in
VS Code.

- **Notebooks** (`.ipynb`) — open and **Run All** to confirm the
  `Python (nix-uv)` kernel works:
  - `notebook_intro.ipynb` — numpy, Polars, and an inline plot
  - `notebook_pyrsm.ipynb` — a `pyrsm` regression with a plot
  - `notebook_postgres.ipynb` — query PostgreSQL into a Polars frame
  - `notebook_random_check.ipynb` — seeded random numbers + a
    fingerprint to compare across macOS / Windows / Linux
- **Scripts** (`.py` with `# %%` cells, also runnable as notebooks):
  `check_environment.py`, `python_data_stack.py`, `pyrsm_example.py`,
  `random_check.py`, `postgres_python.py`, `spark_pyspark.py`, and
  `quarto_report.qmd`.

Run the non-interactive checks all at once:

```bash
bash examples/run-examples.sh
```

## Optional: Spark / Hadoop

Scalable-analytics work uses a separate, larger profile. The first
activation downloads Spark and Hadoop, so expect a wait.

```bash
cd ~/rsm-msba
nix develop .#spark-hadoop
rsm-spark-hadoop-proof             # Hadoop + Spark + a local PySpark session
```

## Updating the environment

Everything (Python packages, tools, examples, the shell) is defined in
the flake, so updating is one command:

```bash
rsm-update                         # pull the latest environment + rebuild
```

`rsm-update` fast-forwards `~/rsm-nix` to the latest and refreshes the
Python environment, kernel, examples, and shell (it’s the same as
`rsm-setup`, and also bumps Claude Code to the latest). It is safe to
re-run any time and does **not** touch your coursework. direnv reloads
the workspace automatically.

To see exactly which version you’re on — useful for confirming you and a
classmate match before debugging — run:

```bash
rsm-version                        # e.g. "rsm-nix version: 7ff499b0c (2026-06-28)"
```

The version is the flake’s git commit, so two machines reporting the
same code have the same environment. `rsm-setup` / `rsm-update` print it
when they finish.

## Cleanup / full reset

To rebuild the environment **state** from scratch while **keeping your
coursework** (the course folders under `~/rsm-msba`):

```bash
rsm-pg-stop 2>/dev/null
rm -rf ~/rsm-msba/.rsm-msba        # removes only the RSM-owned state
rsm-setup
```

To reset **everything** from nothing (⚠️ this also deletes the course
folders in `~/rsm-msba` — back up any coursework first):

```bash
rm -rf ~/rsm-msba ~/rsm-nix
rsm-setup                          # re-clones the flake and rebuilds
```

To reclaim disk space from old Nix builds:

```bash
nix store gc
```

To uninstall Nix entirely (Determinate installer):

```bash
/nix/nix-installer uninstall
```

## Troubleshooting

- **`nix: command not found`** — reopen your terminal after installing
  Nix (or run
  `. /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh`).
- **VS Code terminal isn’t activated** — make sure the `mkhl.direnv`
  extension is installed and you ran `direnv allow` in `~/rsm-msba`.
- **A notebook can’t import a package** — select the **“Python
  (nix-uv)”** kernel, and run `rsm-python-sync` if it’s a course-core
  package.
- **PostgreSQL won’t start** — run `rsm-pg-status`; check the log at
  `~/rsm-msba/.rsm-msba/postgres/postgres.log`.
- **Not sure which environment you’re in?** — run
  `python examples/check_environment.py`. It confirms `python` is the
  RSM/Nix base env and flags a leaked `VIRTUAL_ENV` (e.g. an old
  `/opt/base-uv` that a server auto-activates). See
  `examples/README.md`.
- **Still stuck?** — run the smoke check and share the output:
  `nix develop ~/rsm-msba -c bash ~/rsm-msba/tests/check-default.sh`

---

_Instructors / developers:_ the flake interfaces, the full command list,
and the server configuration are in **[README-tech.md](README-tech.md)**
and the [`docs/`](docs/) guides.
