

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

### Manual path (any platform)

``` bash
# 1. install Nix (Determinate Systems installer)
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install

# 2. clone the workspace and build it
git clone https://github.com/radiant-ai-hub/rsm-nix.git ~/rsm-msba
cd ~/rsm-msba
nix develop          # or: direnv allow  (with direnv + nix-direnv)
rsm-setup            # uv env + Jupyter kernel + course folders
```

## Recommended folder structure

Everything lives under `~/rsm-msba`. Because direnv cascades into
subfolders, the environment is active in every course/project folder
automatically — no per-folder setup.

``` text
~/rsm-msba/                  <- the workspace (flake.nix, .envrc)
├── .rsm-msba/               <- RSM-owned state (Python env, Postgres, caches)
│   ├── envs/base/           <- the uv "base" Python environment
│   ├── postgres/            <- your local PostgreSQL cluster
│   └── jupyter/             <- the "Python (RSM-MSBA)" notebook kernel
├── mgta403/                 <- a course folder (created by rsm-setup)
├── mgta464/                 <- a course folder
└── my_project/              <- make as many as you like
```

Create more course/project folders any time:

``` bash
rsm-new-course mgta455 mgta495
```

(or edit `courses.txt` and re-run `rsm-setup`).

In VS Code, use **File → Open Folder** and open `~/rsm-msba` (or a
specific course folder). With the direnv extension installed, the
integrated terminal and notebook kernels activate automatically. For
notebooks, pick the **“Python (RSM-MSBA)”** kernel.

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
    kernel picker (top-right), and choose **Python (RSM-MSBA)**. For
    `.py` files the interpreter is already set to
    `~/rsm-msba/.rsm-msba/envs/base/bin/python`; VS Code remembers your
    choice per folder.

That’s it. Open a notebook or script in any course folder and run — no
activation step needed.

> Tip: keep one VS Code window open on `~/rsm-msba` so every course
> folder shares the same Explorer, environment, PostgreSQL, and kernel.
> Reopen the folder (or run **Developer: Reload Window**) after
> `rsm-setup` so the new kernel and interpreter are detected.

## Using UV for Python packages

The environment uses [uv](https://docs.astral.sh/uv/) for Python package
management. There are two patterns.

### Add to the shared base environment

The base environment (`~/rsm-msba/.rsm-msba/envs/base`) holds the
course-core packages. To experiment with an extra package for the
current session:

``` bash
sbase                 # activate the base env (alias for: source .../envs/base/bin/activate)
uv pip install mlxtend
```

> Packages added with `uv pip install` are not tracked in the lockfile.
> To make the base environment match the official package list again,
> run `rsm-python-sync`.

### Create a project-specific environment

For packages a specific class or project needs (persisted in that
folder):

``` bash
cd ~/rsm-msba/my_project
uv init .
uv venv --python 3.12
sp                    # alias for: source .venv/bin/activate
uv add polars==1.1.0
python -c "import polars as pl; print(pl.__version__)"
```

To remove a project environment, delete `.venv` (and the `uv init`
scaffolding) or the whole project folder.

## PostgreSQL

A workspace-local PostgreSQL instance is included — no system service,
no Docker. Data lives under `~/rsm-msba/.rsm-msba/postgres`.

``` bash
rsm-pg-start                       # start (initializes on first run)
rsm-pg-psql                        # open psql on the rsm-msba database
rsm-pg-psql -c "SELECT version();" # run one statement
rsm-pgweb                          # browse at http://127.0.0.1:8282
rsm-pg-status                      # is it running?
rsm-pg-stop                        # stop it
```

Connection details: host = socket under `.rsm-msba/postgres/socket` (or
`127.0.0.1`), port = `8765`, databases = `rsm-msba` and your username.

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
cd ~/rsm-msba
git pull                           # get the latest environment definition
direnv reload                      # or: re-run `nix develop`
rsm-python-sync                    # refresh Python packages from the lockfile
```

## Cleanup / full reset

To rebuild your environment from scratch, delete the workspace state
(this does **not** remove your coursework, which lives in the course
folders):

``` bash
rsm-pg-stop 2>/dev/null
rm -rf ~/rsm-msba/.rsm-msba
cd ~/rsm-msba && rsm-setup
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
  (RSM-MSBA)”** kernel, and run `rsm-python-sync` if it’s a course-core
  package.
- **PostgreSQL won’t start** — run `rsm-pg-status`; check the log at
  `~/rsm-msba/.rsm-msba/postgres/postgres.log`.
- **Still stuck?** — run the smoke check and share the output:
  `nix develop ~/rsm-msba -c bash ~/rsm-msba/tests/check-default.sh`
