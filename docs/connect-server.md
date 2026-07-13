<!-- generated from docs/src/connect-server.qmd — edit the .qmd, then run docs/src/render-docs.sh -->

# Connecting to the Rady server with VS Code

This guide is for students/TAs who use a **shared Rady compute server**
instead of installing the environment on their own laptop. Everything
(Python, Quarto, PostgreSQL, the `nix-uv` environment) runs **on the
server**; you just use VS Code on your laptop as a window into it. This
works the same on macOS and Windows, and on any laptop — including older
Intel Macs.

## Which server?

Use the one your instructor gives you. There are two:

| Server  | Campus / VPN address      | Tailscale hostname (recommended) | Tailscale IP     |
| ------- | ------------------------- | -------------------------------- | ---------------- |
| **sc1** | `rsm-compute-01.ucsd.edu` | `sc1-nixos.tail37260b.ts.net`    | `100.120.22.116` |
| **sc2** | `rsm-compute-02.ucsd.edu` | `sc2-ubuntu.tail37260b.ts.net`   | `100.120.8.242`  |

Use the **full Tailscale hostname** (the `….ts.net` name) — it works
from any network once Tailscale is connected, and doesn’t depend on your
laptop’s DNS settings the way the short name (`sc2-ubuntu`) does. The
Tailscale IP is a last-resort fallback.

Wherever this guide shows `<server>`, replace it with your assigned
server’s address (e.g. `sc2-ubuntu.tail37260b.ts.net` over Tailscale, or
`rsm-compute-02.ucsd.edu` on the campus VPN).

## What you need

- A **UCSD AD account** — your campus username (e.g. `msaad`) and
  password, the same ones you use for other campus services.
- **VS Code** on your laptop. If you don’t have it, get it from
  <https://code.visualstudio.com> and install it (just click through the
  installer).
- A **network path to the server**. The server is not on the open
  internet, so you reach it one of two ways:
  - **Tailscale (recommended)** — works from any network, including home
    Wi-Fi and **UCSD-Protected**. Set up once (Step 1).
  - **Campus network or UCSD VPN** — if you’re physically on campus or
    connected to the UCSD VPN, you can use the `rsm-compute-0X.ucsd.edu`
    address directly and skip Step 1.

> If a course web page or the server won’t load on the
> **UCSD-Protected** Wi-Fi, that network conflicts with the campus VPN’s
> addressing — **Tailscale is the reliable fix**, so we recommend
> setting it up regardless.

## Step 1 — Set up Tailscale (once)

Tailscale is a small app that gives your laptop a private, secure path
to the server. It does **not** give anyone access to your files — it’s
just the network “road” to the server; you still log in with your own
account.

1.  **Install Tailscale.** If you ran the macOS or Windows all-in-one
    installer, it’s already installed. Otherwise download it from
    <https://tailscale.com/download> and install it.
2.  **Sign in with your OWN account.** Open Tailscale, and sign in (a
    free personal account — Google/Microsoft/GitHub login all work).
    This creates your own private network; you are **not** joining
    anyone else’s.
3.  **Accept the instructor’s invite.** Open the invite link your
    instructor posts at <https://rsm-django-02.ucsd.edu/ict/> and click
    **Accept**. The server now appears in your Tailscale app. Make sure
    Tailscale shows **Connected**.

That’s the whole setup. You can now reach the server from any network.
(You only see this one server — not other students, and not the
instructor’s other machines.)

> **Windows + WSL note (only if you also want to `ssh` from inside
> WSL):** the Windows Tailscale app is enough for VS Code Remote-SSH
> below. If you specifically want `ssh <server>` to work from a WSL
> terminal, create `C:\Users\<you>\.wslconfig` containing `[wsl2]` then
> `networkingMode=mirrored`, and run `wsl --shutdown`. For normal use
> you can ignore this.

## Step 2 — Install the Remote-SSH extension (once)

In VS Code, open the **Extensions** panel (click the squares icon on the
left, or press **Cmd/Ctrl + Shift + X**), search for **Remote - SSH**
(`ms-vscode-remote.remote-ssh`), and click **Install**. This is what
lets VS Code connect to the server.

## Step 3 — Connect to the server

1.  Press **F1** (or **Cmd/Ctrl + Shift + P**) and type **Remote-SSH:
    Connect to Host…**, then press Enter.

2.  Click **+ Add New SSH Host…** and type:

        ssh <your-ad-username>@<server>

    For example, over Tailscale:
    `ssh msaad@sc2-ubuntu.tail37260b.ts.net` (or on the campus VPN:
    `ssh msaad@rsm-compute-02.ucsd.edu`).

3.  When asked which SSH config file to use, accept the first one. Then
    choose **Connect** (you can also reconnect any time via
    **Remote-SSH: Connect to Host…**, where the server is now listed).

4.  Enter your **campus AD password** when prompted. The first time, VS
    Code asks to trust the server’s fingerprint — accept it.

A new VS Code window opens, connected to the server. The bottom-left
corner shows **SSH: `<server>`**.

## Step 4 — First-time setup on the server (once)

Open a terminal in the connected window (**Terminal → New Terminal**)
and run:

```bash
rsm-setup
```

This builds your personal `nix-uv` Python environment, the **Python
(nix-uv)** notebook kernel, and your workspace at `~/rsm-msba` (with
course folders). The first run takes a few minutes; later runs are fast
(a shared cache means you benefit from what classmates already built).
When it finishes it prints your `rsm-version` — a short code identifying
your setup.

Then install the course’s VS Code extensions **on the server** with one
command:

```bash
rsm-vscode-ext
```

(That installs the full curated set into this connected window.
Alternatively you can install them by hand from the Extensions panel —
at minimum **Python**, **Jupyter**, **Quarto**, and **direnv**
(`mkhl.direnv`), clicking **“Install in SSH: `<server>`”** for each.)

## Step 5 — Open your workspace folder

Now tell VS Code which folder to work in. _Opening a folder_ sets the
project VS Code shows on the left and where its terminal starts — it is
**not** the same as typing in the terminal.

1.  **File → Open Folder…**
2.  In the path box, type **`~/rsm-msba`** (or
    `/home/<your-username>/rsm-msba`) and click **OK**.

- The first time, the **direnv** extension shows a prompt to **allow**
  the environment — click **Allow** (or run `direnv allow` in the
  terminal). You only do this once per folder. After that, every
  terminal in `~/rsm-msba` is automatically in the `nix-uv` environment.
- For notebooks, click the **kernel picker** (top-right of the notebook)
  and choose **Python (nix-uv)**.

That’s it — you’re ready. Try `examples/check_environment.py` (open it
and run, or in a terminal `python examples/check_environment.py`); it
should print **ALL GOOD**.

## Notes & troubleshooting

- **You’ll see a direnv message in `~/rsm-nix`** (`".envrc is blocked"`)
  — that folder is just the environment’s source code; **ignore it** and
  work in `~/rsm-msba`. Do _not_ run `direnv allow` there.
- **`import numpy` fails with a `libstdc++.so.6` error** → the
  environment isn’t active. Make sure the **direnv** extension is
  installed _on the server_, that you ran `direnv allow` in
  `~/rsm-msba`, and that the terminal/kernel was opened from inside
  `~/rsm-msba`.
- **Can’t connect at all?** Confirm Tailscale shows **Connected** (or
  that you’re on campus / the UCSD VPN), and that your campus
  username/password work elsewhere.
- **Out of sync with a classmate?** Run `rsm-version` on both and
  compare; if they differ, run `rsm-update`.
- **Want passwordless login?** After your first connect, add your
  laptop’s SSH public key to `~/.ssh/authorized_keys` on the server.

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
rsm-new-course mgta455 mgta495
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
