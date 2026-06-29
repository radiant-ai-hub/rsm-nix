

<!-- generated from docs/src/readme-tech.qmd — edit the .qmd, then run docs/src/render-docs.sh -->

# rsm-nix — technical reference

> Student-facing quickstart is in [README.md](README.md). This page is
> the technical reference for the flake (interfaces, commands, layout,
> tests).

A single Nix flake that reproduces the RSM-MSBA computing environment
(Python/uv, Quarto, PostgreSQL, optional Spark/Hadoop) **natively** on
macOS, Linux, NixOS, and Windows (WSL2) — **no Docker, no Podman**.
Students clone one workspace at `~/rsm-msba`; direnv cascades the
environment into every course subfolder. R is intentionally excluded.

## Install / quickstart

### macOS (Apple Silicon)

``` bash
curl -fsSL https://raw.githubusercontent.com/radiant-ai-hub/rsm-nix/main/install/macos-arm-install-rsm-nix.sh | bash
```

The installer sets up VS Code (+ the curated extensions), the MesloLGS
Nerd Font, Determinate Nix, `direnv` + `nix-direnv`, Tailscale, clones
the workspace to `~/rsm-msba`, runs `rsm-setup`, and runs the smoke
checks.

### Windows 11 (WSL2 + Ubuntu 26.04)

Run PowerShell **as Administrator** for the first WSL install:

``` powershell
powershell -NoProfile -ExecutionPolicy Bypass -Command "iwr -useb https://raw.githubusercontent.com/radiant-ai-hub/rsm-nix/main/install/windows-install-rsm-nix.ps1 | iex"
```

The installer sets up VS Code on Windows (+ extensions and the MesloLGS
Nerd Font), Ubuntu 26.04 on WSL2 with zsh, Determinate Nix inside
Ubuntu, `direnv` + `nix-direnv`, Tailscale, and the `~/rsm-msba`
workspace.

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

Per-platform guides:

- macOS Apple Silicon: [docs/student-macos.md](docs/student-macos.md)
- Windows 11 (WSL2 + Ubuntu 26.04):
  [docs/student-wsl2.md](docs/student-wsl2.md)
- **Connect to the shared server with VS Code** (students/TAs):
  [docs/connect-server.md](docs/connect-server.md)
- Ubuntu 24.04 server (multi-user Nix):
  [docs/server-ubuntu-nix.md](docs/server-ubuntu-nix.md)
- NixOS server (declarative):
  [docs/server-nixos.md](docs/server-nixos.md)

## Layout

``` text
~/rsm-nix/      the flake (a git repo) — update with: cd ~/rsm-nix && git pull
~/rsm-msba/     your workspace (NOT a git repo)
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

## Commands

| Command | What it does |
|----|----|
| `rsm-setup` | Bootstrap: uv base env, Jupyter kernel, course folders |
| `rsm-update` | Same as `rsm-setup` + bump Claude Code to latest (the “update” name) |
| `rsm-msba` | Bootstrap/reset: clone the flake if missing, then `rsm-setup` |
| `rsm-version` | Print the environment version (the flake’s git commit) + platform |
| `rsm-python-sync` | Refresh the base env from `uv.lock` |
| `rsm-new-course NAME...` | Create course/project folder(s) + remember in `courses.txt` |
| `rsm-vscode-ext` | Install the curated VS Code extensions into the connected (WSL/SSH) window |
| `rsm-pg-init` / `-start` / `-stop` / `-status` | Workspace-local PostgreSQL lifecycle |
| `rsm-pg-psql` | `psql` into the `rsm-msba` database |
| `rsm-pgweb` | pgweb UI at <http://127.0.0.1:8282> |
| `github` | One-time setup of your Git identity + a GitHub SSH key |

## Flake interfaces

- `devShells.<system>.default` — Python/uv, Quarto 1.9.13, PostgreSQL
  16, pgweb, git/git-lfs, gh, notebook support, the `rsm-*` commands.
- `devShells.<system>.spark-hadoop` — adds Java + Spark 3.5 + Hadoop +
  PySpark.
- `packages.<system>.{rsm-setup,rsm-python-sync,rsm-pg-*,rsm-pgweb,rsm-new-course,quarto-bin,spark-hadoop-env,spark-hadoop-proof}`
- `apps.<system>.{check,check-spark-hadoop,rsm-setup}`

Supported systems: `aarch64-darwin`, `x86_64-darwin`, `aarch64-linux`,
`x86_64-linux`. Windows is via WSL2 Linux.

## Testing

``` bash
nix flake check
nix develop -c bash tests/check-default.sh        # toolchain + 35 course-core imports
nix develop -c bash tests/check-postgres.sh       # PostgreSQL lifecycle
nix develop -c bash tests/check-folders.sh        # workspace layout
nix develop -c bash tests/check-no-host-mutation.sh
nix develop .#spark-hadoop -c bash tests/check-spark-hadoop.sh
nix run .#check                                   # bundled smoke check
```

## Reaching the MSBA server (Tailscale and the UCSD‑Protected “100.x” issue)

Students need to reach the MSBA server (e.g. `sc2` / `rsm-compute-02`)
from their laptops for both SSH and the course web apps. The campus VPN
is the “official” path but is unreliable, so Tailscale is the preferred
fallback. There is one campus‑networking gotcha worth recording.

### What was happening

The server’s services live on the **campus data‑net** (public
`132.249.x` addresses) — for example the Django app
`https://rsm-django-02.ucsd.edu` (`132.249.225.82`, reverse‑proxied by
Caddy) and SSH on `rsm-compute-02.ucsd.edu` (`132.249.225.85`). Students
on the **UCSD‑Protected** Wi‑Fi could not load those pages.

The cause is campus segmentation: **UCSD‑Protected is a CGNAT network**
that hands clients addresses in `100.64.0.0/10` and does **not** route
to the research / data‑net, so a direct hit to `132.249.x` is dropped.
(Hence the “it’s something about `100` IPs” memory — the `100.x` is
UCSD‑Protected’s client range, not the server’s.)

### Why Tailscale doesn’t “just work” there — and the fix

The server is also published over Tailscale (its tailnet IP serves
`:443` too), so Tailscale would normally bypass the segmentation. **But
Tailscale also uses `100.64.0.0/10`** for tailnet IPs. On UCSD‑Protected
the laptop already holds a `100.x` address and route, so it **collides**
with Tailscale’s range and traffic to the server’s `100.x` can be sent
to the local Wi‑Fi interface instead of `tailscale0`. This is
Tailscale’s documented **CGNAT conflict**.

It is fixable, so **student‑level Tailscale is viable**. In order of
preference:

1.  **Restrict the tailnet to a non‑overlapping IP pool.** In the
    tailnet policy file, pin nodes (including the server) to a `/16`
    inside `100.64.0.0/10` that UCSD‑Protected does *not* use, e.g.:

    ``` json
    { "nodeAttrs": [ { "target": ["*"], "ipPool": ["100.81.0.0/16"] } ] }
    ```

    The server’s tailnet IP then no longer falls in the client’s local
    `100.x` subnet, so the more‑specific local route stops shadowing it
    and routing to the server works. (IP pool is in beta;
    `100.100.0.0/24`, `100.100.100.0/24`, and `100.115.92.0/23` are
    reserved and can’t be used.)

2.  **Address the server by MagicDNS name**, not the raw `100.x` IP
    (e.g. `sc2.<tailnet>.ts.net`), so Tailscale resolves and routes it
    in userspace rather than relying on the conflicting IPv4 route. This
    is also why `~/.ssh/config` uses short MagicDNS names with a
    campus‑DNS fallback alias.

3.  **Last resort — IPv6‑only.** The `disable-ipv4` node attribute
    removes the v4 conflict entirely, at the cost of any IPv4‑only
    resources.

The server side needs nothing special for this —
`services.tailscale.enable = true` is enough; the fix lives in the
**tailnet policy** (IP pool), so it applies to every node at once.

### What students can and can’t reach (isolation)

Two layers that are easy to conflate:

- **Tailscale is a private network path to a machine — not file
  access.** It lets a laptop *reach* the server; it does not log anyone
  in or open any files. On the server every student is a separate
  account with a private home directory (same as today), so reaching the
  server over Tailscale never lets one student read another’s files —
  the server’s OS enforces that, independent of Tailscale.
- **Student-to-student network isolation** is a separate control: either
  an ACL (single-tailnet model) or simply keeping students in separate
  tailnets (node-sharing model). Students never need to be on the
  instructor’s *personal* tailnet either way.

### Onboarding students — node sharing (reusable link) vs. dedicated tailnet

- **Node sharing with a reusable link (recommended — simple and it
  scales).** “Sharing” a node gives someone access to *only* the server;
  they stay in **their own** tailnet (never join yours, never see your
  other machines, and can’t see each other). A single **reusable share
  link can be accepted by up to 1,000 people**, so one link covers the
  whole class — no per-person step. Recipients are external guests: they
  do **not** consume your tailnet’s user seats (sharing actually
  *raises* your device allowance), and it works on the **free** plan.
  The link expires after 30 days if unused, so regenerate it each term.
  Optionally restrict shared users to just SSH/HTTPS with an ACL for
  `autogroup:shared` (below).
- **Dedicated MSBA tailnet + SSO + ACLs (for central management).**
  Create a *separate* tailnet for the course (not your personal one);
  students sign in with UCSD identity and an ACL limits them to the
  server’s ports and blocks student-to-student traffic. More control
  (central SSO, audit), but heavier setup and the free tier is limited
  on **users**, so a cohort needs a paid plan. Node sharing avoids both.

Either way the instructor’s personal machines are never exposed, and
home directories are always protected by the server, not by Tailscale.

### Step by step: node sharing with a reusable link

**Instructor — once for the whole group (Tailscale admin console):**

1.  Make sure the server is in your tailnet and powered on
    (e.g. `sc1-nixos`).
2.  Open <https://login.tailscale.com/admin/machines>.
3.  Find the server’s row, click its `...` menu, choose **Share**.
4.  Pick a **reusable** link (good for up to 1,000 people) and copy it.
    Send that one link to all your TAs/students (course LMS or email).
    Treat it as semi-private — anyone with it can reach only this one
    server, and they still need valid SSH credentials to log in.

**TA / student — once:**

1.  Install Tailscale (Windows or macOS app from
    <https://tailscale.com/download>).
2.  Sign in with **their own** account (this creates their own free
    tailnet).
3.  Open the share link and **Accept** — the server now appears in their
    Tailscale machine list. Confirm Tailscale shows **Connected**.

**Connecting to the server (the two paths Windows students use):**

- **VS Code on Windows, Remote-SSH — simplest.** With the Tailscale
  Windows app running, the server is reachable. In VS Code: *Remote-SSH
  -\> Connect to Host* using `<their-username>@<server>`, where
  `<server>` is the address shown for it in their Tailscale app (its
  `100.x` IP always works; the MagicDNS name works once the share is
  accepted). No WSL is needed for server access.

- **From inside WSL (e.g. `ssh <server>` in a WSL terminal).** WSL2 does
  not see the Windows Tailscale interface by default. Turn on **mirrored
  networking** so WSL shares the Windows network (including Tailscale):
  create/edit `C:\Users\<you>\.wslconfig` with

  ``` ini
  [wsl2]
  networkingMode=mirrored
  ```

  then run `wsl --shutdown` and reopen. After that, `ssh <server>` from
  WSL works. (Alternative: install Tailscale *inside* WSL as its own
  node — more setup, and it reintroduces the CGNAT issue above, so
  prefer mirrored networking.)

macOS students install the Tailscale app, sign in, accept the share,
then use VS Code Remote-SSH the same way.

### Restrict shared users to SSH only (recommended hardening)

By default a shared user can reach **every** port on the machine shared
to them — the default `"src": ["*"]` allow-all rule applies to shared
users too. To limit them to **SSH only** (which still covers VS Code
Remote-SSH), edit the tailnet policy so your own devices keep full
access while shared users get **only TCP 22**:

``` json
{
  "acls": [
    { "action": "accept", "src": ["autogroup:members"], "dst": ["*:*"] },
    { "action": "accept", "src": ["autogroup:shared"],  "dst": ["*:22"] }
  ]
}
```

Why this is correct and reusable for every server:

- The first rule replaces the default `"src": ["*"]` with
  `autogroup:members`, so the blanket allow applies to **you and your
  own devices only**, not to shared users. (If you also have *tagged*
  devices that initiate connections, add rules for them.)
- The second rule is then the *only* thing matching shared users, so
  they get **port 22 and nothing else**.
- `dst` is `*:22` on purpose — not a hostname or tag. **Sharing already
  limits a recipient to the one machine you shared with them**, and
  **tags/hostnames are stripped from shared nodes**, so the rule keys on
  the *port*. That means it covers **sc1 today and sc2 the moment you
  share it** — no per-server edit.

To apply: Tailscale admin console -\> **Access controls** -\> merge in
the two rules -\> **Save**. Shared TAs/students can then SSH (and use VS
Code Remote-SSH) to the server, but can’t reach any other port or
machine.

### Before rollout — confirm on UCSD‑Protected

1.  Note a laptop’s address on UCSD‑Protected (`ip addr` / `ipconfig`)
    to learn the exact `100.x` subnet campus hands out.
2.  Pick an `ipPool` `/16` clearly outside that subnet and set it in the
    policy file.
3.  Test end‑to‑end from UCSD‑Protected: `tailscale status`, SSH to the
    server’s MagicDNS name, and load a course web app over Tailscale.

References: Tailscale [CGNAT
conflicts](https://tailscale.com/docs/reference/troubleshooting/network-configuration/cgnat-conflicts),
[IP pool](https://tailscale.com/kb/1304/ip-pool), [Tailscale IP
addresses](https://tailscale.com/docs/concepts/tailscale-ip-addresses).
