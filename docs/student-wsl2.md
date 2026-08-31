<!-- generated from docs/src/student-wsl2.qmd — edit the .qmd, then run docs/src/render-docs.sh -->

# Installing the RSM-MSBA computing environment on Windows 11

This guide is for **Windows 11**. It assumes you have **not** used a
terminal, VS Code, or Linux before. Follow the steps in order.

On Windows, the RSM-MSBA tools run inside **WSL2** — a real Ubuntu Linux
that Windows runs for you in the background, with **Ubuntu 26.04**.
You’ll still use the normal Windows VS Code window; it simply connects
into Ubuntu. You don’t need to learn Linux — the installer sets
everything up.

> This is the **Nix flake** version of the RSM-MSBA environment. Instead
> of Docker Desktop and a multi-gigabyte container image, you install
> native Nix and get the exact same Python, Quarto, PostgreSQL, and
> Spark toolchain built reproducibly on your own machine. There is **no
> Docker**, no container to start, and nothing littered across your
> system — everything lives in the Nix store and one workspace folder
> (`~/rsm-msba`) that you can delete to fully reset.

## Step 1 — Open PowerShell as Administrator

**PowerShell** is Windows’ command window. The installer needs
Administrator rights the first time (to turn on WSL).

1.  Click the **Start** button.
2.  Type **PowerShell**.
3.  Under “Windows PowerShell”, click **Run as Administrator** (or
    right-click it → **Run as administrator**).
4.  Click **Yes** when Windows asks for permission.

A blue window opens.

## Step 2 — Run the installer

Copy the line below, paste it into the PowerShell window
(**right-click** pastes, or **Ctrl + V**), and press **Enter**:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -Command "iwr -useb https://raw.githubusercontent.com/radiant-ai-hub/rsm-nix/main/install/windows-install-rsm-nix.ps1 | iex"
```

This one command does **everything** — you do **not** need to install VS
Code, Ubuntu, or anything else separately. It installs:

- **VS Code** on Windows, plus the extensions the course uses.
- The **MesloLGS Nerd Font** (so the terminal prompt shows its icons).
- **WSL2** with **Ubuntu 26.04** (a Linux system inside Windows), with
  **zsh** as the shell.
- **Determinate Nix** + **direnv** inside Ubuntu — the environment
  machinery.
- **Tailscale** — used later to reach the Rady server from any network
  (you sign in and accept the invite separately; see
  [connect-server.md](connect-server.md)).
- Your **workspace** at `~/rsm-msba` (inside Ubuntu), then `rsm-setup` +
  a check.

What to expect while it runs:

- **If Windows says it needs to restart** to finish turning on WSL:
  **restart**, then open PowerShell as Administrator again and **re-run
  the same command**. The installer remembers where it left off — this
  is normal and may happen once.
- Ubuntu may ask you to **create a username and password** for the Linux
  system. Pick something simple you’ll remember (this is separate from
  your Windows login).
- The **first** run downloads a few GB and can take **15–30 minutes**.
  Leave it until it finishes.

## Step 3 — Open VS Code, connect to Ubuntu, then open your folder

After it finishes, open **VS Code** (Start → type **Visual Studio Code**
→ Enter).

Because your files live inside Ubuntu (not in regular Windows), you
first tell VS Code to **connect into Ubuntu (WSL)**, and _then_ open the
folder:

1.  Press **F1** (or **Ctrl + Shift + P**) to open the command box at
    the top.
2.  Type **WSL: Connect to WSL** and press **Enter**. A new VS Code
    window opens; the bottom-left corner shows a green badge like **WSL:
    Ubuntu-26.04**.
3.  Now open your folder: **File → Open Folder…**. In the path box at
    the top of the dialog, type **`/home/`**, open your username’s
    folder, then select **`rsm-msba`** and click **OK**.

> **“Open Folder” vs. the Terminal — what’s the difference?** _Open
> Folder_ sets the project VS Code shows on the left and where its
> built-in terminal starts. The _Terminal_ (Step 4) is a command line
> **inside** VS Code. You open a folder once per project; you use the
> terminal whenever you need a command. (On Windows there’s an extra
> first step — _Connect to WSL_ — so the folder you open is the one
> inside Ubuntu.)

The first time, a popup may ask to **allow direnv** for this folder —
click **Allow**. That’s what turns the tools on automatically. You only
do this once.

> **Keep your files inside Ubuntu** (`~/rsm-msba`), **not** under `C:\`
> or `/mnt/c/...`. Working in the Linux home folder is much faster and
> avoids odd errors.

## Step 4 — Run something

- **A notebook:** open `examples/notebook_intro.ipynb`, click the
  **kernel picker** (top-right), choose **Python (nix-uv)**, then **Run
  All**.

- **A terminal:** open one with **Terminal → New Terminal**. You’ll see
  `(nix-uv)` in the prompt. Try:

  ```bash
  python examples/check_environment.py     # should print: ALL GOOD
  ```

That’s it — put your coursework in the matching course folder
(e.g. `mgta403`).

## Keeping it up to date (and checking your version)

From a terminal in `~/rsm-msba`:

```bash
rsm-update      # pull the latest environment + rebuild (safe to run any time)
rsm-version     # print your version, e.g. "rsm-nix version: 7ff499b0c (2026-06-28)"
```

`rsm-version` prints a short code identifying your exact setup. If
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
rsm-pgweb                          # browse (prints a password-protected URL)
rsm-pg-status                      # is it running?
rsm-pg-stop                        # stop it
```

Run **`pg`** any time for a quick status (running? which port?) plus a
reminder of these commands.

Connection details: host = the private Unix socket under
`.rsm-msba/postgres/socket` (the `$PGHOST` variable), port =
**`$PGPORT`** (run `echo $PGPORT`), databases = `rsm-msba` and your
username. There is **no TCP** and no password: the server listens only
on that socket, protected by peer authentication — on a shared server
this is what keeps one student out of another student’s database. From
Python, connect over the socket (`host=$PGHOST`), not `127.0.0.1` (see
`examples/postgres_python.py`). The port is derived per-user on a shared
server, so always read it from `$PGPORT` rather than hard-coding `8765`.

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
for troubleshooting. In PowerShell (Administrator):

```powershell
wsl --install -d Ubuntu-26.04
wsl --set-default-version 2
```

Then, inside the **Ubuntu** terminal:

```bash
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
. /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
nix profile add nixpkgs#direnv nixpkgs#nix-direnv
mkdir -p ~/.config/direnv
echo 'source ~/.nix-profile/share/nix-direnv/direnvrc' >> ~/.config/direnv/direnvrc
echo 'eval "$(direnv hook bash)"' >> ~/.bashrc
git clone https://github.com/radiant-ai-hub/rsm-nix.git ~/rsm-nix
nix develop ~/rsm-nix -c rsm-setup   # creates ~/rsm-msba + .envrc + nix-uv env + folders
direnv allow ~/rsm-msba
```
