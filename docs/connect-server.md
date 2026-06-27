

<!-- generated from docs/src/connect-server.qmd — edit the .qmd, then run docs/src/render-docs.sh -->

# Connecting to the RSM server with VS Code

This guide is for students/TAs who use the shared **RSM compute server**
instead of installing the environment on their own laptop. You connect
from VS Code on your laptop over **Remote-SSH**, and everything (Python,
Quarto, PostgreSQL, the `nix-uv` environment) runs on the server.

> **Server address (MSBA alpha):** `rsm-compute-01.ucsd.edu` Use the
> address your instructor gives you; this guide uses the one above.

## What you need

- A **UCSD AD account** — your campus username (e.g. `msaad`) and
  password. You log in with the *same* credentials you use for campus
  services.
- **VS Code** on your laptop: <https://code.visualstudio.com>
- To be **on the campus network** — either physically on campus, or
  connected to the **UCSD VPN** (the server is not reachable from the
  open internet).

## 1. Install the VS Code extensions

In VS Code, open the Extensions panel (`Cmd/Ctrl+Shift+X`) and install:

- **Remote - SSH** (`ms-vscode-remote.remote-ssh`) — connects to the
  server.

The others (Python, Jupyter, Quarto, **direnv**) you install *after* you
connect, **on the server side** — see step 3.

## 2. Connect to the server

1.  Press `F1` (or `Cmd/Ctrl+Shift+P`) and run **Remote-SSH: Connect to
    Host…**

2.  Choose **+ Add New SSH Host…** and enter:

        ssh <your-ad-username>@rsm-compute-01.ucsd.edu

    (e.g. `ssh msaad@rsm-compute-01.ucsd.edu`)

3.  Pick the SSH config file when prompted, then **Connect**.

4.  When asked, enter your **campus AD password**. (First connect also
    asks to trust the host fingerprint — accept it.)

A new VS Code window opens, connected to the server (bottom-left shows
`SSH: rsm-compute-01.ucsd.edu`).

## 3. Install the server-side extensions

In the connected window, open Extensions again and click **Install in
SSH: rsm-compute-01…** for:

- **Python** (`ms-python.python`)
- **Jupyter** (`ms-toolsai.jupyter`)
- **Quarto** (`quarto.quarto`)
- **direnv** (`mkhl.direnv`) — **important:** this is what
  auto-activates the `nix-uv` environment in terminals and notebooks.

## 4. First-time setup (once)

Open a terminal in VS Code (**Terminal → New Terminal**) and run:

``` bash
rsm-setup
```

This builds your personal `nix-uv` Python environment, the **Python
(nix-uv)** notebook kernel, and your workspace at `~/rsm-msba` (with
course folders). The first run takes a few minutes; later runs are fast.

> The shared download cache means later students build much faster than
> the first.

## 5. Open your workspace

**File → Open Folder…** and choose **`~/rsm-msba`** (this is where you
work — see the layout below).

- The first time, the direnv extension shows a prompt to **allow** the
  environment — click **Allow** (or run `direnv allow` in the terminal).
  You only do this once per folder. After that, every terminal in
  `~/rsm-msba` is automatically in the `nix-uv` environment.
- For notebooks, pick the **Python (nix-uv)** kernel (top-right of the
  notebook).

That’s it — you’re ready. Try the examples in `~/rsm-msba/examples`
(e.g. open `check_environment.py` and run it; it should print **ALL
GOOD**).

## Notes & troubleshooting

- **You’ll see a direnv message in `~/rsm-nix`** (`".envrc is blocked"`)
  — that folder is just the environment’s source code; **ignore it** and
  work in `~/rsm-msba`. Do *not* run `direnv allow` there.
- **`import numpy` fails with a `libstdc++.so.6` error** → the
  environment isn’t active. Make sure the **direnv** extension is
  installed *on the server*, that you ran `direnv allow` in
  `~/rsm-msba`, and that the terminal/kernel was opened from inside
  `~/rsm-msba`.
- **Want passwordless login?** After your first connect, add your
  laptop’s SSH public key to `~/.ssh/authorized_keys` on the server.
- **Can’t connect at all?** Confirm you’re on campus or the UCSD VPN,
  and that your campus username/password work elsewhere.

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
