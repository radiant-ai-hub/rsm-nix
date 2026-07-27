<!-- generated from docs/src/student-macos.qmd — edit the .qmd, then run docs/src/render-docs.sh -->

# Installing the RSM-MSBA computing environment on macOS (Apple Silicon)

This guide is for **Apple Silicon** Macs (the M1/M2/M3/M4 chips — every
Mac sold since late 2020). It assumes you have **not** used a terminal,
VS Code, or any of these tools before. Follow the steps in order and you
will end up with a complete Python / Quarto / PostgreSQL setup that is
identical to your classmates’ and to the Rady server.

> Not sure which chip you have? Click the Apple menu (top-left) →
> **About This Mac**. If it says **Apple M1/M2/M3/M4**, you’re set.
> (Older “Intel” Macs are not supported — use the Rady server instead,
> see [connect-server.md](connect-server.md).)

> This is the **Nix flake** version of the RSM-MSBA environment. Instead
> of Docker Desktop and a multi-gigabyte container image, you install
> native Nix and get the exact same Python, Quarto, PostgreSQL, and
> Spark toolchain built reproducibly on your own machine. There is **no
> Docker**, no container to start, and nothing littered across your
> system — everything lives in the Nix store and one workspace folder
> (`~/rsm-msba`) that you can delete to fully reset.

## Step 1 — Open the Terminal app

The **Terminal** is a window where you type commands instead of clicking
buttons. To open it:

1.  Press **Cmd + Space** (this opens Spotlight search).
2.  Type **Terminal** and press **Return**.

A window with a text prompt appears. You’ll paste one command into it in
the next step.

## Step 2 — Run the installer

Copy the line below, paste it into the Terminal window (**Cmd + V**),
and press **Return**:

```bash
curl -fsSL https://raw.githubusercontent.com/radiant-ai-hub/rsm-nix/main/install/macos-arm-install-rsm-nix.sh | bash
```

This one command does **everything** — you do **not** need to download
or install VS Code, Nix, or anything else separately. It installs:

- **VS Code** — the editor you’ll write and run code in.
- The **MesloLGS Nerd Font** (so the terminal prompt shows its icons).
- **Determinate Nix** + **direnv** — the machinery that builds the
  environment.
- **Tailscale** — used later to reach the Rady server from any network
  (you sign in and accept the invite separately; see
  [connect-server.md](connect-server.md)).
- Your **workspace** at `~/rsm-msba`, then it runs `rsm-setup` and a
  quick check.

What to expect while it runs:

- It will ask for **your Mac login password** once or twice (for the Nix
  install and to copy VS Code into Applications). Typing shows nothing
  on screen — that’s normal; just type it and press Return.
- If it says the **Command Line Developer Tools** need to be installed,
  click **Install** in the popup, wait for it to finish, then re-run the
  command above.
- The **first** run downloads a few GB of Python packages and can take
  **10–20 minutes**. Later runs are fast. Leave it until you see
  **“Installation complete.”**

## Step 3 — Open VS Code and then open your workspace folder

VS Code is now in your Applications. Open it (Cmd + Space → type
**Visual Studio Code** → Return).

Now you need to **open your workspace folder**. This is the single most
important VS Code concept: _opening a folder_ tells VS Code which
project you’re working on — it is **not** the same as typing in a
terminal. Do this:

1.  In the top menu bar, click **File → Open Folder…** (keyboard
    shortcut: **Cmd + O**).
2.  A file picker opens. Press **Cmd + Shift + H** to jump to your
    **Home** folder.
3.  Click the folder named **`rsm-msba`** once to select it, then click
    **Open**.

VS Code reloads with `rsm-msba` as your project. You’ll see your course
folders (`mgta403`, `mgta464`, …) and an `examples` folder in the
**Explorer** panel on the left.

> **“Open Folder” vs. the Terminal — what’s the difference?** _Open
> Folder_ (this step) sets the project VS Code shows on the left and
> where its built-in terminal starts. The _Terminal_ (Step 4) is a
> command line **inside** VS Code for typing commands. You open a folder
> once per project; you use the terminal whenever you need to run a
> command.

The first time, a small popup may ask to **allow direnv** for this
folder — click **Allow** (or **trust**). This is what makes Python and
the other tools turn on automatically. You only do this once.

## Step 4 — Run something

- **A notebook:** open `examples/notebook_intro.ipynb`, and at the
  top-right click the **kernel picker** and choose **Python (nix-uv)**.
  Then click **Run All**. You should see package versions, a small
  table, and a plot.

- **A terminal:** open one with **Terminal → New Terminal** (top menu).
  You’ll see `(nix-uv)` in the prompt, meaning the environment is
  active. Try:

  ```bash
  python examples/check_environment.py     # should print: ALL GOOD
  ```

That’s it — you’re ready to work. Put your coursework in the matching
course folder (e.g. `mgta403`).

## Keeping it up to date (and checking your version)

From a terminal in `~/rsm-msba`:

```bash
rsm-update      # pull the latest environment + rebuild (safe to run any time)
rsm-version     # print your version, e.g. "rsm-nix version: 7ff499b0c (2026-06-28)"
```

`rsm-version` prints a short code that identifies your exact setup. If
something works for a classmate but not for you, compare this code — you
may just need to run `rsm-update`. Updating never touches your
coursework.

## Folders: the flake vs your coursework

Two separate places, so the environment can be updated with `git`
without touching your work — and each course folder can be its own git
repo:

```text
~/rsm-nix/                   the flake (a git repo) — RSM machinery only
                             update it with:  cd ~/rsm-nix && git pull

~/rsm-msba/                  your workspace (NOT a git repo)
├── .envrc                   generated; loads the flake from ~/rsm-nix
├── .rsm-msba/               RSM state (survives flake updates / re-clones)
│   ├── envs/nix-uv/         the "nix-uv" Python environment
│   ├── postgres/            your local PostgreSQL cluster
│   └── jupyter/             the "Python (nix-uv)" notebook kernel
├── examples/                link to the flake's examples
├── mgta403/                 a course folder — can be its own git repo
├── mgta464/
└── my_project/
```

direnv cascades the environment into every folder under `~/rsm-msba`, so
the tools are active in each course folder automatically. Because
`~/rsm-msba` is **not** a git repo, you can `git init` (or `git clone`)
inside `mgta403` with no nesting conflict.

Create more course/project folders any time:

```bash
rsm-mkdir mgta455 mgta495
```

In VS Code, **File → Open Folder** on `~/rsm-msba`. With the direnv
extension, terminals and notebook kernels activate automatically. For
notebooks, pick the **“Python (nix-uv)”** kernel.

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

## Manual install (fallback / advanced)

You should not need this — the installer above does it all. It is kept
for troubleshooting or if you prefer to run the steps yourself.

```bash
# 1. Apple command line tools (Nix needs these to build some packages)
xcode-select --install

# 2. Determinate Nix (enables flakes; clean uninstaller). Reopen the terminal after.
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install

# 3. direnv + nix-direnv (auto-activates the environment when you enter ~/rsm-msba)
nix profile add nixpkgs#direnv nixpkgs#nix-direnv
mkdir -p ~/.config/direnv
echo 'source ~/.nix-profile/share/nix-direnv/direnvrc' >> ~/.config/direnv/direnvrc
echo 'eval "$(direnv hook zsh)"' >> ~/.zshrc

# 4. clone the flake and build the workspace
git clone https://github.com/radiant-ai-hub/rsm-nix.git ~/rsm-nix
nix develop ~/rsm-nix -c rsm-setup   # creates ~/rsm-msba + .envrc + nix-uv env + folders
direnv allow ~/rsm-msba
```

VS Code, if you install it manually, is at
<https://code.visualstudio.com/docs/?dv=darwinarm64>. If `code` isn’t
found in the terminal, open VS Code, press **Cmd+Shift+P**, and run
**“Shell Command: Install ‘code’ command in PATH”**.
