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
packages, use `rsm-mkdir`:

```bash
rsm-mkdir mgta455              # set up ./mgta455 (nested under ~/rsm-msba)
rsm-mkdir .                    # set up the CURRENT folder (shared nix-uv Python)
rsm-mkdir ~/projects/thesis    # a standalone folder anywhere (created if needed)
rsm-mkdir --venv analysis      # give ./analysis its OWN reproducible .venv
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
interpreter, run `rsm-mkdir .` in it once (or `rsm-mkdir <name>`). Add
`--venv` to give that folder its **own** isolated packages (`uv add …`,
checked with `rsm-project-check`) — the conda alternative. You can also
just ask Claude in the editor; the `rsm-project` skill handles setting
up folders and adding/verifying packages.

> Tip: keep one VS Code window open on `~/rsm-msba` so every course
> folder shares the same Explorer, environment, PostgreSQL, and kernel.
> Reopen the folder (or run **Developer: Reload Window**) after
> `rsm-setup` so the new kernel and interpreter are detected.

## Using Claude Code

[Claude Code](https://www.claude.com/product/claude-code) is installed
for you and runs in the RSM-MSBA environment. The goal is to help you
**go faster _and_ understand more** — use AI as a capable assistant
while you stay the engineer who reviews, tests, and understands the
result. Start it by typing `claude` in the VS Code integrated terminal
of any course folder.

**What’s already set up in your course folders.** When the environment
sets up a folder (`rsm-setup`, `rsm-mkdir`, or `rsm-clone`), it drops a
small Claude Code “agentic engineering” harness into it so good habits
are the default:

- **Skills** — Claude automatically uses these when relevant. Ask for
  help with a broken push/merge and the **git-workflow** skill walks you
  through it from your real repo state; ask “is this right?” or “review
  this” and the **verify-ai-code** skill runs a structured
  read-and-verify pass.

- **Slash commands** — type these in Claude Code:

  | Command            | What it does                                                           |
  | ------------------ | ---------------------------------------------------------------------- |
  | `/run-tests`       | Run the test suite and report results.                                 |
  | `/review`          | Review your current diff — flags bugs, missing tests, style. No edits. |
  | `/add-function`    | Add a new function **with** its tests, in one shot.                    |
  | `/explain <thing>` | Beginner-friendly explanation of a file, function, or concept.         |

- **A `CLAUDE.md`** of house rules that Claude reads every session, and
  a single **`justfile`** at your `~/rsm-msba` root that `just` finds
  from any subfolder (running in the folder you are in): `just test`,
  `just check` (tests + lint), `just review` (show your diff),
  `just save "msg"` (checkpoint commit), `just verify` (tests, then the
  diff to read).

- **See the guardrails for yourself** — `just hooks-off` /
  `just hooks-on` toggle the hooks for a folder (restart Claude Code to
  apply) so you can watch the difference, and `just status-line` adds a
  status bar showing which computer and folder you’re in, your model,
  and how much of your context and (on Claude Pro/Max) your 5-hour /
  7-day limits you have **left** — with a countdown to when those limits
  reset. (Restart Claude Code after turning it on.)

- **Gentle guardrails** — before every `git commit`, Claude scans staged
  files for secrets (API keys, `.env` files) and pauses if it finds one;
  it uses `uv` for packages (not `pip`); and it nudges you to run your
  tests when code has changed.

**Run Claude in the right folder, and point it at files.** Claude can
only see files under the folder where you started it (its working
directory), and that same folder decides which `CLAUDE.md` and settings
apply and which past conversations you can resume. A few things worth
knowing:

- **Start in the intended folder.** In VS Code, open the project folder
  you want to work in (File \> Open Folder, or the Remote-SSH folder
  picker) so the integrated terminal opens there, then run `claude`. If
  you started in the wrong place, quit Claude and restart it from the
  right folder. The status line (`just status-line`) shows which folder
  you are in.
- **Resume a past conversation** instead of starting over.
  `claude --continue` (or `claude -c`) jumps straight back into your
  most recent conversation; `claude --resume` (or `claude -r`) opens a
  list to pick from; and `/resume` does the same from inside a session.
  These lists are **per folder**, so start Claude in the same folder you
  used before or that conversation will not show up (inside the picker,
  `Ctrl-A` widens the list to every project).
- **Let Claude look in another folder.** To give Claude access to files
  outside its working directory (a shared data folder, a sibling
  project), add the folder with `/add-dir /absolute/path/to/folder` (add
  several if you like, or start Claude with
  `claude --add-dir /path/a /path/b`). Your `CLAUDE.md`, settings, and
  hooks still come only from the folder you launched in, not from added
  folders.
- **Hand Claude a specific file** in your prompt, three easy ways:
  - Type `@` and start typing the name; Claude autocompletes paths
    relative to your folder, e.g. `explain @rfm.qmd` or
    `what is in @data/bbb.parquet?`.
  - Drag the file from the VS Code Explorer (or Finder) into the
    terminal; the shell pastes its full path into your prompt.
  - Right-click the file in the VS Code Explorer, choose **Copy Relative
    Path** (or Copy Path), and paste it into your prompt.

**Suggestions — get the most out of it without switching your brain
off:**

1.  **You own the review.** Read the diff (`git diff HEAD` or `/review`)
    before you commit. If you can’t explain a change in plain English,
    don’t commit it — ask `/explain` first.
2.  **Verify, don’t assume.** Passing tests do not prove the code is
    right. Run the thing on a real input and look at the output
    yourself.
3.  **Work in small steps.** Commit early and often, one idea at a time
    — git is your safety net (`just save "msg"`).
4.  **Tests are how you tell Claude what “done” means.** Ask for the
    test first, watch it fail, then make it pass.
5.  **Ask it to teach you.** `/explain` a function or concept you don’t
    follow — use AI to learn faster, not to skip the learning.

> **Note on privacy.** In **course repositories** (the `rsm-msba-*`
> GitHub org), Claude Code writes a short activity log (your prompts + a
> summary of each tool call — never file contents or output) that is
> committed with your work for instructor review. **Nothing is logged in
> your personal repositories.** See `.claude/usage-log/README.md` in a
> course folder for details.

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

## Optional: GPUs (deep learning)

The Rady servers have NVIDIA GPUs; laptops generally do not. The same
commands work in both places — they detect what the machine actually
has, so you do not need a different notebook for the server.

### Check what you have

```bash
cd ~/rsm-msba
nix run .#check-gpu
```

On a GPU server this lists the GPUs and confirms CUDA is reachable. On a
laptop it says there is no NVIDIA driver and that PyTorch will run on
CPU — that is a normal answer, not an error.

### Make a course folder with PyTorch

```bash
rsm-gpu-init deep-learning        # picks the right PyTorch for this machine
```

This creates a normal RSM project folder with its own `.venv`, then
installs the PyTorch build that matches the machine: the CUDA build
where there is a GPU, the CPU build where there is not. Open the folder
in VS Code and pick the `.venv` interpreter, as with any other project.

The GPU download is large (several GB) because the CUDA libraries ship
inside the PyTorch wheel. On a laptop you can force the much smaller CPU
build:

```bash
rsm-gpu-init --cpu experiment
```

### Confirm your code can see the GPU

```python
import torch
torch.cuda.is_available()      # True on the server
torch.cuda.device_count()      # how many GPUs you can use
torch.cuda.get_device_name(0)
```

If `is_available()` is `False` **on the server**, the usual cause is
that you started Python outside the RSM environment. The environment is
what points PyTorch at the system GPU driver; a bare `python` from a
plain terminal will not find it. Open the folder in VS Code (which loads
the environment through direnv), or run `cd ~/rsm-msba && nix develop`
first, and try again.

### Sharing the servers

The GPUs and the memory are shared with everyone else on the machine. A
few things follow from that:

- **Memory is capped per user.** If you exceed the cap your job is
  stopped rather than the whole machine going down. If work dies
  unexpectedly and you were loading a very large dataset, this is the
  likely cause — load it in chunks, or ask about the current limit.
- **Free the GPU when you are done.** Shut down notebook kernels you are
  not using; an idle kernel keeps holding GPU memory and blocks other
  people. `nvidia-smi` shows what is currently running.
- **Ask before taking every GPU.** `torch.cuda.device_count()` may
  report several, but using all of them means nobody else can work.

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
