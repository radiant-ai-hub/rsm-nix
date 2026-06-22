

<!-- generated from docs/src/student-wsl2.qmd — edit the .qmd, then run docs/src/render-docs.sh -->

# Installing the RSM-MSBA computing environment on Windows 11

Windows uses **WSL2 with Ubuntu 26.04**. The RSM-MSBA tools run inside
Ubuntu with the same Determinate Nix setup used on macOS. Windows itself
is used for VS Code and the WSL integration.

> This is the **Nix flake** version of the RSM-MSBA environment. Instead
> of Docker Desktop and a multi-gigabyte container image, you install
> native Nix and get the exact same Python, Quarto, PostgreSQL, and
> Spark toolchain built reproducibly on your own machine. There is **no
> Docker**, no container to start, and nothing littered across your
> system — everything lives in the Nix store and one workspace folder
> (`~/rsm-msba`) that you can delete to fully reset.

## Automated installer

Open **PowerShell as Administrator** and run:

``` powershell
powershell -NoProfile -ExecutionPolicy Bypass -Command "iwr -useb https://raw.githubusercontent.com/radiant-ai-hub/rsm-nix/main/install/windows-install-rsm-nix.ps1 | iex"
```

The installer does the full setup:

- installs VS Code and the WSL/Python/Jupyter/Quarto/direnv extensions
- enables WSL2 and installs `Ubuntu-26.04`
- creates a normal Ubuntu user
- installs Determinate Nix inside Ubuntu
- installs and configures `direnv` + `nix-direnv`
- clones the workspace to `~/rsm-msba`
- runs `rsm-setup` and the smoke checks

If Windows asks for a reboot while enabling WSL, reboot and run the same
command again. The script is idempotent and continues from the completed
steps.

## After install

Open VS Code, choose **Connect to WSL**, select `Ubuntu-26.04`, then
open `~/rsm-msba`. Terminals and notebooks pick up the Nix environment
through direnv. For notebooks, choose the **Python (RSM-MSBA)** kernel.

## Manual fallback

In PowerShell (Administrator):

``` powershell
wsl --install -d Ubuntu-26.04
wsl --set-default-version 2
```

Then inside the Ubuntu terminal:

``` bash
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
. /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
nix profile install nixpkgs#direnv nixpkgs#nix-direnv
mkdir -p ~/.config/direnv
echo 'source ~/.nix-profile/share/nix-direnv/direnvrc' >> ~/.config/direnv/direnvrc
echo 'eval "$(direnv hook bash)"' >> ~/.bashrc
git clone https://github.com/radiant-ai-hub/rsm-nix.git ~/rsm-msba
cd ~/rsm-msba
direnv allow
rsm-setup
```

Keep the repo under the Linux filesystem (`~/rsm-msba`), not under
`/mnt/c/...`; WSL file access is much faster there.

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
- **Not sure which environment you’re in?** — run
  `python examples/check_environment.py`. It confirms `python` is the
  RSM/Nix base env and flags a leaked `VIRTUAL_ENV` (e.g. an old
  `/opt/base-uv` that a server auto-activates). See
  `examples/README.md`.
- **Still stuck?** — run the smoke check and share the output:
  `nix develop ~/rsm-msba -c bash ~/rsm-msba/tests/check-default.sh`
