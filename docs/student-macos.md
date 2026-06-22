

<!-- generated from docs/src/student-macos.qmd — edit the .qmd, then run docs/src/render-docs.sh -->

# Installing the RSM-MSBA computing environment on macOS (Apple Silicon)

> This is the **Nix flake** version of the RSM-MSBA environment. Instead
> of Docker Desktop and a multi-gigabyte container image, you install
> native Nix and get the exact same Python, Quarto, PostgreSQL, and
> Spark toolchain built reproducibly on your own machine. There is **no
> Docker**, no container to start, and nothing littered across your
> system — everything lives in the Nix store and one workspace folder
> (`~/rsm-msba`) that you can delete to fully reset.

The computing environment is consistent across all students and faculty,
easy to update, and easy to remove. These instructions are for Macs with
an Apple Silicon chip. The installer supports Apple Silicon only.

## Automated installer

``` bash
curl -fsSL https://raw.githubusercontent.com/radiant-ai-hub/rsm-nix/main/install/macos-arm-install-rsm-nix.sh | bash
```

The installer sets up VS Code, Determinate Nix, `direnv` + `nix-direnv`,
clones the workspace to `~/rsm-msba`, runs `rsm-setup`, and runs the
smoke checks.

The manual steps below are kept as a fallback and for troubleshooting.

------------------------------------------------------------------------

## Install the macOS command line developer tools

Open the **Terminal** app, run the command below, and follow the prompts
until the software is installed. Nix needs these tools to build some
packages.

``` bash
xcode-select --install
```

## Install Nix (Determinate Systems installer)

We use the Determinate Systems installer because it enables flakes by
default, plays well with macOS upgrades, and has a clean uninstaller.

``` bash
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
```

When it finishes, **quit and reopen your terminal** so the `nix` command
is on your `PATH`. Verify with `nix --version`.

> The installer adds Nix to a managed block in `/etc/zshrc`. It does
> **not** modify your personal `~/.zshrc`.

## Enable direnv (recommended)

`direnv` activates the environment automatically whenever you `cd` into
your workspace (and any course subfolder), including inside VS Code
terminals.

``` bash
nix profile install nixpkgs#direnv nixpkgs#nix-direnv
mkdir -p ~/.config/direnv
echo 'source ~/.nix-profile/share/nix-direnv/direnvrc' >> ~/.config/direnv/direnvrc
echo 'eval "$(direnv hook zsh)"' >> ~/.zshrc
```

Reopen your terminal afterward. The `~/.zshrc` line is the **only** edit
to your personal shell config.

> Prefer not to touch `~/.zshrc`? Skip direnv and run `nix develop`
> manually from `~/rsm-msba` each time instead.

## Install VS Code

Download and install VS Code from
<https://code.visualstudio.com/docs/?dv=darwinarm64>, then install the
extensions we rely on:

``` bash
code --install-extension ms-python.python
code --install-extension ms-toolsai.jupyter
code --install-extension quarto.quarto
code --install-extension mkhl.direnv
```

If you get a `code: command not found` error, open VS Code, press
`Cmd+Shift+P`, run **“Shell Command: Install ‘code’ command in PATH”**,
then retry.

## Get the workspace and build it

``` bash
git clone https://github.com/radiant-ai-hub/rsm-nix.git ~/rsm-nix
nix develop ~/rsm-nix -c rsm-setup   # creates ~/rsm-msba + .envrc + nix-uv env + folders
direnv allow ~/rsm-msba              # if you enabled direnv
```

`rsm-setup` is safe to re-run any time. The very first run can take a
few minutes while it downloads Python packages.

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
management. There are two patterns.

### Add to the shared nix-uv environment

The `nix-uv` environment (`~/rsm-msba/.rsm-msba/envs/nix-uv`) holds the
course-core packages and is already active in the dev shell. To
experiment with an extra package for the current session:

``` bash
uv pip install mlxtend
```

> Packages added with `uv pip install` are not tracked in the lockfile.
> To make the nix-uv environment match the official package list again,
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
