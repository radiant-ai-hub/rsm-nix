

<!-- generated from docs/src/getting-started.qmd — edit the .qmd, then run docs/src/render-docs.sh -->

# Getting started with the RSM-MSBA computing environment

> This is the **Nix flake** version of the RSM-MSBA environment. Instead
> of Docker Desktop and a multi-gigabyte container image, you install
> native Nix and get the exact same Python, Quarto, PostgreSQL, and
> Spark toolchain built reproducibly on your own machine. There is **no
> Docker**, no container to start, and nothing littered across your
> system — everything lives in the Nix store and one workspace folder
> (`~/rsm-msba`) that you can delete to fully reset.

The computing environment is consistent across all students and faculty,
easy to update, and easy to remove. This is the cross-platform guide;
for OS-specific notes see [student-macos.md](student-macos.md) (Apple
Silicon), [student-wsl2.md](student-wsl2.md) (Windows), or the server
guides.

## Installation

### macOS (Apple Silicon)

``` bash
curl -fsSL https://raw.githubusercontent.com/radiant-ai-hub/rsm-nix/main/install/macos-arm-install-rsm-nix.sh | bash
```

The installer sets up VS Code, Determinate Nix, `direnv` + `nix-direnv`,
clones the workspace to `~/rsm-msba`, runs `rsm-setup`, and runs the
smoke checks.

### Windows 11 (WSL2 + Ubuntu 26.04)

Run PowerShell **as Administrator** for the first WSL install:

``` powershell
powershell -NoProfile -ExecutionPolicy Bypass -Command "iwr -useb https://raw.githubusercontent.com/radiant-ai-hub/rsm-nix/main/install/windows-install-rsm-nix.ps1 | iex"
```

The installer sets up VS Code on Windows, Ubuntu 26.04 on WSL2,
Determinate Nix inside Ubuntu, `direnv` + `nix-direnv`, and the
`~/rsm-msba` workspace.

### Linux / server (bare Ubuntu, or a Remote-SSH server)

``` bash
curl -fsSL https://raw.githubusercontent.com/radiant-ai-hub/rsm-nix/main/install/linux-install-rsm-nix.sh | bash
```

Installs Determinate Nix (if missing), configures `direnv` +
`nix-direnv` for your login shell (zsh or bash), clones the workspace to
`~/rsm-msba`, and runs `rsm-setup`. It does not install VS Code —
connect from your laptop with the **Remote - SSH** + **mkhl.direnv**
extensions.

### Manual path (any platform)

``` bash
# 1. install Nix (Determinate Systems installer)
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install

# 2. clone the flake, then bootstrap your workspace
git clone https://github.com/radiant-ai-hub/rsm-nix.git ~/rsm-nix
nix develop ~/rsm-nix -c rsm-setup   # creates ~/rsm-msba + .envrc + nix-uv env + folders
direnv allow ~/rsm-msba              # if using direnv (recommended)
```

The flake lives at `~/rsm-nix` (update with `cd ~/rsm-nix && git pull`);
your coursework + state live at `~/rsm-msba`.

## Folders: the flake vs your coursework

Two separate places, so the environment can be updated with `git`
without touching your work — and each course folder can be its own git
repo:

``` text
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

``` bash
rsm-new-course mgta455 mgta495
```

In VS Code, **File → Open Folder** on `~/rsm-msba`. With the direnv
extension, terminals and notebook kernels activate automatically. For
notebooks, pick the **“Python (nix-uv)”** kernel.

## First-time setup

After installing, build the Python environment, install the Jupyter
kernel, and create your course folders:

``` bash
cd ~/rsm-msba
rsm-setup
```

`rsm-setup` is safe to re-run any time. The very first run can take a
few minutes while it downloads Python packages.

## VS Code and direnv

Install VS Code, then add the extensions we rely on (Python, Jupyter,
Quarto, and the direnv integration so VS Code terminals and notebook
kernels pick up the environment automatically):

``` bash
code --install-extension ms-python.python
code --install-extension ms-toolsai.jupyter
code --install-extension quarto.quarto
code --install-extension mkhl.direnv
```

`direnv` activates the environment automatically whenever you `cd` into
your workspace (and any course subfolder), including inside VS Code
terminals. Install it and hook it into your shell — this one line is the
only edit to your personal shell config:

``` bash
nix profile install nixpkgs#direnv nixpkgs#nix-direnv
mkdir -p ~/.config/direnv
echo 'source ~/.nix-profile/share/nix-direnv/direnvrc' >> ~/.config/direnv/direnvrc
# add the hook for your shell (zsh on macOS, bash on WSL2/Ubuntu):
echo 'eval "$(direnv hook zsh)"'  >> ~/.zshrc     # zsh
echo 'eval "$(direnv hook bash)"' >> ~/.bashrc    # bash
```

Reopen your terminal, then run `direnv allow` once in `~/rsm-msba`.

> Prefer not to touch your shell config? Skip direnv and run
> `nix develop` manually from `~/rsm-msba` each time instead.

## Using VS Code (the convenient way)

The smoothest workflow uses the **direnv** VS Code extension so the
RSM-MSBA environment activates automatically — no manual interpreter
selection, no venv juggling. This repository ships a `.vscode/` config,
so when you open `~/rsm-msba` VS Code offers to install the right
extensions and points Python at the base environment for you.

1.  **Open the workspace** — from a terminal:

    ``` bash
    code ~/rsm-msba
    ```

    (You can also open a single course folder,
    e.g. `code ~/rsm-msba/mgta403` — direnv finds the environment by
    walking up to `~/rsm-msba/.envrc`.)

2.  **Install the recommended extensions** — VS Code shows a prompt
    (“This workspace has extension recommendations”); click **Install
    All**. They are `mkhl.direnv`, `ms-python.python`,
    `ms-toolsai.jupyter`, and `quarto.quarto`.

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

``` bash
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

``` bash
# edit ~/rsm-nix/pyproject.toml (add the package under dependencies), then:
rsm-python-sync           # rebuild the nix-uv env to match the list
```

## PostgreSQL

A workspace-local PostgreSQL instance is included — no system service,
no Docker. Data lives under `~/rsm-msba/.rsm-msba/postgres`.

``` bash
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

``` bash
quarto --version
quarto render report.qmd
```

## Optional: Spark / Hadoop

Scalable-analytics work uses a separate, larger profile. The first
activation downloads Spark and Hadoop, so expect a wait.

``` bash
cd ~/rsm-msba
nix develop .#spark-hadoop
rsm-spark-hadoop-proof             # Hadoop + Spark + a local PySpark session
```

## Updating the environment

``` bash
cd ~/rsm-nix && git pull            # get the latest environment definition
rsm-python-sync                     # refresh Python packages from the lockfile
```

direnv reloads the workspace automatically (the `.envrc` watches the
flake), or re-open the `~/rsm-msba` folder in VS Code.

## Cleanup / full reset

To rebuild your environment from scratch, delete the workspace state
(this does **not** remove your coursework, which lives in the course
folders):

``` bash
rsm-pg-stop 2>/dev/null
rm -rf ~/rsm-msba/.rsm-msba
nix develop ~/rsm-nix -c rsm-setup
```

To reclaim disk space from old Nix builds:

``` bash
nix store gc
```

To uninstall Nix entirely (Determinate installer):

``` bash
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
