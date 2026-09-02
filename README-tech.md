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

```bash
curl -fsSL https://raw.githubusercontent.com/radiant-ai-hub/rsm-nix/main/install/macos-arm-install-rsm-nix.sh | bash
```

The installer sets up VS Code (+ the curated extensions), the MesloLGS
Nerd Font, Determinate Nix, `direnv` + `nix-direnv`, Tailscale, clones
the workspace to `~/rsm-msba`, runs `rsm-setup`, and runs the smoke
checks.

### Windows 11 (WSL2 + Ubuntu 26.04)

Run PowerShell **as Administrator** for the first WSL install:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -Command "iwr -useb https://raw.githubusercontent.com/radiant-ai-hub/rsm-nix/main/install/windows-install-rsm-nix.ps1 | iex"
```

The installer sets up VS Code on Windows (+ extensions and the MesloLGS
Nerd Font), Ubuntu 26.04 on WSL2 with zsh, Determinate Nix inside
Ubuntu, `direnv` + `nix-direnv`, Tailscale, and the `~/rsm-msba`
workspace.

### Linux laptop (Ubuntu/Debian or NixOS)

```bash
curl -fsSL https://raw.githubusercontent.com/radiant-ai-hub/rsm-nix/main/install/linux-install-rsm-nix.sh | bash
```

One-command laptop setup: VS Code (+ the curated extensions), the
MesloLGS Nerd Font, `direnv` + `nix-direnv`, Tailscale, and the
`~/rsm-msba` workspace. On Ubuntu/Debian it also installs Determinate
Nix; on NixOS Nix is already present and Tailscale is enabled
declaratively (the installer prints the line). Other distros work for
the Nix/workspace parts; install VS Code/Tailscale yourself.

### Bare server (Remote-SSH, no VS Code)

Run the same script with `--skip-vscode` on a headless server, then
connect from your laptop with the **Remote - SSH** + **mkhl.direnv**
extensions.

### Manual path (any platform)

```bash
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
- Linux laptop (Ubuntu/Debian or NixOS):
  [docs/student-linux.md](docs/student-linux.md)
- **Connect to the shared server with VS Code** (students/TAs):
  [docs/connect-server.md](docs/connect-server.md)
- Ubuntu 24.04 server (multi-user Nix):
  [docs/server-ubuntu-nix.md](docs/server-ubuntu-nix.md)
- NixOS server (declarative):
  [docs/server-nixos.md](docs/server-nixos.md)

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

## Commands

| Command                                        | What it does                                                                                                                                                                                                                     |
| ---------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `rsm-setup`                                    | Bootstrap: uv base env, Jupyter kernel, course folders                                                                                                                                                                           |
| `rsm-update`                                   | Same as `rsm-setup` + bump Claude Code to latest (the “update” name)                                                                                                                                                             |
| `rsm-msba`                                     | Bootstrap/reset: clone the flake if missing, then `rsm-setup`                                                                                                                                                                    |
| `rsm-version`                                  | Print the environment version (the flake’s git commit) + platform                                                                                                                                                                |
| `rsm-python-sync`                              | Refresh the base env from `uv.lock`                                                                                                                                                                                              |
| `rsm-mkdir [--venv] PATH...`                   | Make folder(s) first-class RSM projects to open directly in VS Code — nested or standalone, sharing the one nix-uv env (CWD-relative like `mkdir`); `--venv` gives a folder its **own** reproducible env (the conda alternative) |
| `rsm-clone URL [DIR]`                          | `git clone` a repo AND set it up (direnv + nix-uv) so it opens directly in VS Code                                                                                                                                               |
| `rsm-gpu-init [--cpu] PATH`                    | `rsm-mkdir --venv` plus PyTorch matched to this machine — CUDA build where a driver is present, CPU build otherwise (`--cpu` forces the smaller CPU build)                                                                       |
| `rsm-gpu-proof`                                | Report the NVIDIA driver, CUDA reachability, and (if installed) what PyTorch actually sees. Also `nix run .#check-gpu`                                                                                                           |
| `rsm-threads`                                  | Browse past Claude Code conversations across every folder (fzf menu by title + folder + date); Enter resumes the chosen thread in its own folder                                                                                 |
| `rsm-project-check`                            | In a `--venv` folder, import each declared package and flag anything that fails to load                                                                                                                                          |
| `rsm-vscode-ext`                               | Install the curated VS Code extensions into the connected (WSL/SSH) window                                                                                                                                                       |
| `rsm-pg-init` / `-start` / `-stop` / `-status` | Workspace-local PostgreSQL lifecycle                                                                                                                                                                                             |
| `rsm-pg-psql`                                  | `psql` into the `rsm-msba` database                                                                                                                                                                                              |
| `rsm-pgweb`                                    | Browser-based database viewer (opens the exact per-user URL it prints)                                                                                                                                                           |
| `rsm-github` (alias `github`)                  | One-time setup of your Git identity + a GitHub SSH key                                                                                                                                                                           |

`rsm-threads` is handy when you work across many folders (for example
lots of student repos): it reads your local Claude history in
`~/.claude/projects/` and, on Enter, `cd`s to the selected thread’s
folder and runs `claude --resume`, so you reconnect in the right place.
The preview pane shows your prompts in that thread, and
`rsm-threads --list` gives a plain, non-interactive listing.

## Flake interfaces

- `devShells.<system>.default` — Python/uv, Quarto 1.9.13, PostgreSQL
  16, pgweb, git/git-lfs, gh, notebook support, the `rsm-*` commands.
- `devShells.<system>.spark-hadoop` — adds Java + Spark 3.5 + Hadoop +
  PySpark.
- `packages.<system>.{rsm-setup,rsm-python-sync,rsm-pg-*,rsm-pgweb,quarto-bin,spark-hadoop-env,spark-hadoop-proof}`
- `apps.<system>.{check,check-spark-hadoop,rsm-setup}`

Supported systems: `aarch64-darwin`, `x86_64-darwin`, `aarch64-linux`,
`x86_64-linux`. Windows is via WSL2 Linux.

## GPUs: how it works, and limiting server resources

### Why there is no Docker here

A CUDA workload needs exactly **one** thing from the host:
`libcuda.so.1`, the userspace half of the kernel driver. It must match
the running kernel module and cannot be pip-installed. Everything above
it — the CUDA runtime, cuBLAS, cuDNN — ships _inside_ the PyTorch wheel.

On a normal distro `libcuda.so.1` sits in `/usr/lib` and the loader
finds it. On NixOS it lives in `/run/opengl-driver/lib`, which is
deliberately **not** on the default loader path —
`ldconfig -p | grep libcuda` returns nothing on a perfectly working GPU
machine. That single omission is the whole problem. Measured on
`rsm-compute-01`:

| environment                                | `torch.cuda.is_available()` | devices |
| ------------------------------------------ | --------------------------- | ------- |
| plain `uv` venv                            | `False`                     | 0       |
| `+ LD_LIBRARY_PATH=/run/opengl-driver/lib` | `True`                      | 4       |

`nvidia-container-toolkit` solves this by bind-mounting the host driver
into a container. Running natively there is no container to inject into,
so pointing the loader at the driver is sufficient — and simpler.

`gpu/default.nix` does that, guarded on the library **existing** rather
than on the OS, so the same commit works on a Mac laptop, a CPU-only
Linux box, and the GPU servers. The hook lives in the **default**
devShell (it is a no-op without a driver, setting only `RSM_GPU=0`),
which is why a student on the server gets a working `torch.cuda` without
knowing a special shell exists.

```bash
nix run .#check-gpu     # driver -> ctypes cuInit -> torch, reported separately
rsm-gpu-init FOLDER     # project folder + the matching torch wheel
```

`rsm-gpu-init` picks the wheel from the driver, not the hostname. That
is the reason it exists: a CPU wheel on a GPU box does **not** error. It
reports `is_available() False` and trains roughly 50× slower while the
student concludes the GPU is broken.

### Limiting memory

Per-user caps are set in the server config (`limits.nix`) via the
systemd user slice. **Two keys are required, and this is the part that
catches people:**

```nix
systemd.slices."user-".sliceConfig = {
  MemoryAccounting = true;
  MemoryHigh    = "48G";   # soft: reclaim pressure, user slows down
  MemoryMax     = "64G";   # hard ceiling
  MemorySwapMax = "16G";   # WITHOUT THIS the two above are advisory
};
```

`MemoryMax` alone is not a cap. Measured: a process under a 512 M
`MemoryMax` was held at exactly 512 MiB RSS (`memory.peak` confirmed it,
and the cgroup hit its limit 8 979 times) and **still ran to
completion**, `oom_kill 0`, because the overflow went to swap. Add
`MemorySwapMax` and the identical test dies by SIGKILL (scope exit
`137`) with the OOM events in `dmesg`.

This matters more than it sounds on `rsm-compute-01`, whose swap is
**188 GiB of zram** — swap that lives in RAM. Spilling a runaway job
into zram does not protect the machine’s memory; it stores the same
pages compressed, still in RAM.

Two operational notes:

- Values are **policy**, not physics. They are sized per host (sc0: 125
  GiB RAM → 32 G per user; sc1: 376 GiB → 64 G), aiming to leave room
  for several concurrent users plus system services.
- Changing the config does **not** retroactively change a logged-in
  user’s slice. New logins pick it up; to apply immediately use
  `systemctl set-property user-<uid>.slice MemoryMax=…`.

Verify enforcement on any host:

```bash
sudo systemd-run --scope -p MemoryMax=512M -p MemorySwapMax=0 -p MemoryAccounting=yes \
  python3 -c 'b=[]
for i in range(16):
    x=bytearray(128*1024**2); x[::4096]=b"x"*(len(x)//4096); b.append(x)'
# expect: exit 137
```

Note the loop **touches** every page. A plain `bytearray(n)` is served
by `mmap`, glibc skips the memset, the pages are never faulted in, and
no physical memory is used — a test written that way appears to prove
the limit is broken when it is fine.

### Limiting GPUs

| mechanism                            | actually enforces? | notes                               |
| ------------------------------------ | ------------------ | ----------------------------------- |
| `CUDA_VISIBLE_DEVICES`               | **no**             | advisory; the user can `unset` it   |
| cgroup `DeviceAllow` (root)          | **yes**            | kernel-level; survives `unset`      |
| `systemd-run --user` + `DeviceAllow` | **no**             | _silently ignored_, exits 0         |
| compute mode `EXCLUSIVE_PROCESS`     | yes                | root-only to set; 1 process per GPU |
| MIG partitioning                     | n/a                | A2 and RTX 2080 do not support it   |

Measured on `rsm-compute-01` (4 GPUs), with the student running
`unset CUDA_VISIBLE_DEVICES` in every case:

    no restriction                          4 devices
    CUDA_VISIBLE_DEVICES=0, then unset      4 devices   <- escaped
    root scope + DeviceAllow /dev/nvidia0   1 device    <- enforced
    user scope + DeviceAllow /dev/nvidia0   4 devices   <- SILENTLY ignored

Two conclusions worth acting on:

1.  **`CUDA_VISIBLE_DEVICES` is a convention, not a control.** Use it to
    steer cooperative users; never rely on it to enforce a share.
2.  **GPU limits must be imposed by the admin.** The user-scope form
    accepts `DeviceAllow`, exits 0, prints no warning, and does nothing
    — so it is entirely possible to believe a restriction is in place
    when it is not. Always verify by counting devices, not by checking
    that the command succeeded.

To pin a user to specific GPUs, add a drop-in on their slice:

```nix
systemd.slices."user-1234".sliceConfig = {
  DevicePolicy = "closed";
  DeviceAllow = [ "/dev/nvidiactl rw" "/dev/nvidia-uvm rw" "/dev/nvidia0 rw" ];
};
```

Static per-user assignment does not scale to a whole class against 4
GPUs. For a class the more practical lever is compute mode:

```bash
sudo nvidia-smi -c EXCLUSIVE_PROCESS     # one CUDA process per GPU
```

which caps concurrency at the number of GPUs and gives a clear
`CUDA_ERROR_DEVICE_UNAVAILABLE` to the next person instead of silent
thrashing. It requires root to change, so students cannot undo it —
verified: a non-root `nvidia-smi -c` fails with
`Insufficient Permissions`.

## Claude Code harness (agentic engineering)

The flake deploys a course-agnostic Claude Code teaching harness that
encourages good habits + critical thinking (verify AI output,
tests-as-interface, git-as-safety-net). Source assets live in `claude/`
and `skills/`. There are three deploy scopes, on purpose:

**1. User-level: skills + slash commands (`~/.claude/`).** Installed by
`rsm-setup` (steps 6b and 6b2), which copies every `skills/<name>/` and
every `claude/commands/*.md` from the flake into `~/.claude/skills/` and
`~/.claude/commands/`. Being user-level, these are available in
**every** folder and subfolder. That matters because project-scoped
commands do not reach up from a subfolder to the workspace root, so
otherwise each folder would need its own copy.

Skills (guidance-only, so harmless everywhere):

- `rsm-project`: set up/manage project folders (direnv + uv + venv).
- `git-workflow`: recover from push/pull/merge trouble from real repo
  state (runs a read-only `git_state.sh` first).
- `verify-ai-code`: a structured read-and-verify pass on AI-written code
  (read the diff, explain it, run + manually exercise, check the agent’s
  claims).

Slash commands: `/review`, `/explain`, `/run-tests`, `/add-function`.
Adding a skill or command is just a new file under `skills/` or
`claude/commands/`, no code change.

**2. One workspace `justfile` (`~/rsm-msba/justfile`).** Deployed by
`rsm-setup`. `just` searches UP the directory tree, so this single file
is found from any subfolder below (no per-folder copy), and every recipe
runs in the folder you invoked `just` from (via
`invocation_directory()`), so `just test` targets your current project.
It is refreshed while it carries the `_rsmManaged` marker; delete the
marker to keep your own edits. Recipes: `just test`, `just check`,
`just review`, `just save "msg"`, `just verify`, plus the hook and
status-line toggles below.

**3. Per-folder harness (`<dir>/.claude/` + `CLAUDE.md`).** Written by
`rsm-claude-settings <dir>`, which `rsm-setup` calls on the `~/rsm-msba`
workspace root and `rsm-mkdir`/`rsm-clone` call on every folder,
mirroring `rsm-vscode-settings`. Settings and hooks are
**git-root-scoped** by Claude Code (they do not span repos), so they are
deployed per repo/folder. Curated source is read from the **live** flake
checkout (`$RSM_FLAKE/claude/`), so a `git pull` of the flake updates
it, no rebuild.

- `.claude/settings.json`: a **uv-only permission policy** (`deny`
  pip/`uv pip`; `ask` before `rm`/`ssh`/destructive git; safe reads +
  `uv`/`just`/git pre-allowed; `defaultMode: default` so students see
  each prompt) plus the hook wiring. Carries an `_rsmManaged` marker: a
  folder’s own `settings.json` **without** that marker is kept, never
  clobbered (same for a folder’s own `CLAUDE.md`, which is only created
  when absent).

- `.claude/hooks/`: bash hooks:

  | Hook                               | Event                         | What it does                                                      |
  | ---------------------------------- | ----------------------------- | ----------------------------------------------------------------- |
  | `secret-scan`                      | PreToolUse (git commit)       | Flags API keys / `.env` files in staged content; forces an `ask`. |
  | `usage-log` / `auto-stage-log`     | UserPromptSubmit / PreToolUse | Instructor telemetry, **course-org repos only** (see below).      |
  | `ruff-format`                      | PostToolUse (Write/Edit)      | `ruff format` on any `.py` Claude writes.                         |
  | `check-stale-tests` / `ruff-check` | Stop                          | Non-blocking nudges to run pytest / fix lint.                     |
  | `save-test-time`                   | PostToolUse (pytest)          | Records the last test run for the stale-test nudge.               |

**Telemetry is scoped to the course org.** `usage-log.sh` +
`auto-stage-log.sh` no-op unless the enclosing repo’s `origin` matches
`RSM_COURSE_ORG_PATTERN` (default `rsm-msba-`). So logs are written and
pushed **only** with course repos — never a student’s personal work, and
never from the `~/rsm-msba` root (not a git repo). Logs record prompts +
tool-call summaries, never file contents or output;
`.claude/usage-log/README.md` is the student-facing disclosure. Override
the org pattern by exporting `RSM_COURSE_ORG_PATTERN` before launching
Claude.

**Toggling hooks / status line (teaching).** The workspace justfile
ships `just hooks-off` / `just hooks-on` (flip the built-in
`disableAllHooks` in `.claude/settings.local.json`, to demo what the
hooks catch) and `just status-line` / `just status-line-off` (install
`claude/statusline.sh` into `~/.claude/settings.json` — shows
`host | folder (branch*) | direnv | model | ctx N% left | 5h/7d N% left + reset countdown`;
the rate-limit fields are Claude Pro/Max only). The script resolves `jq`
by absolute path and derives host/folder/branch/time with bash builtins,
because Claude Code runs status-line/hook commands with a **minimal
PATH** — on NixOS `jq` (and everything) lives only in the Nix profile,
never `/usr/bin`. A `*` after the branch means uncommitted changes; `direnv!` rather than `direnv` means an `.envrc` governs the folder but has not been allowed, so none of it is in effect — run `direnv allow`.

**Customizing / opting out.** To take ownership of a folder’s managed
`settings.json` (and stop it being refreshed), delete the `_rsmManaged`
marker. To disable a single hook, remove its block from `settings.json`.
Course-specific enforcement (deliverable CI, stack rules, always-on
telemetry) belongs in the course repo’s own `.claude/`, not the base
environment.

Verified by `tests/check-claude-harness.sh` (in `nix-ci.yml`):
per-folder deploy (no per-folder commands/justfile), user-level
commands, the workspace justfile (upward-search +
`invocation_directory`), secret-scan, the telemetry scope guard
(personal / no-origin repos are never logged), stale-tests, ruff-format,
and the keep-foreign guards.

## Testing

```bash
nix flake check
nix develop -c bash tests/check-default.sh        # toolchain + 35 course-core imports
nix develop -c bash tests/check-postgres.sh       # PostgreSQL lifecycle
nix develop -c bash tests/check-folders.sh        # workspace layout
nix develop -c bash tests/check-mkdir.sh          # rsm-mkdir folder setup
nix develop -c bash tests/check-claude-harness.sh # Claude Code harness + telemetry scope
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
    inside `100.64.0.0/10` that UCSD‑Protected does _not_ use, e.g.:

    ```json
    { "nodeAttrs": [{ "target": ["*"], "ipPool": ["100.81.0.0/16"] }] }
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
  access.** It lets a laptop _reach_ the server; it does not log anyone
  in or open any files. On the server every student is a separate
  account with a private home directory (same as today), so reaching the
  server over Tailscale never lets one student read another’s files —
  the server’s OS enforces that, independent of Tailscale.
- **Student-to-student network isolation** is a separate control: either
  an ACL (single-tailnet model) or simply keeping students in separate
  tailnets (node-sharing model). Students never need to be on the
  instructor’s _personal_ tailnet either way.

### Onboarding students — node sharing (reusable link) vs. dedicated tailnet

- **Node sharing with a reusable link (recommended — simple and it
  scales).** “Sharing” a node gives someone access to _only_ the server;
  they stay in **their own** tailnet (never join yours, never see your
  other machines, and can’t see each other). A single **reusable share
  link can be accepted by up to 1,000 people**, so one link covers the
  whole class — no per-person step. Recipients are external guests: they
  do **not** consume your tailnet’s user seats (sharing actually
  _raises_ your device allowance), and it works on the **free** plan.
  The link expires after 30 days if unused, so regenerate it each term.
  Optionally restrict shared users to just SSH/HTTPS with an ACL for
  `autogroup:shared` (below).
- **Dedicated MSBA tailnet + SSO + ACLs (for central management).**
  Create a _separate_ tailnet for the course (not your personal one);
  students sign in with UCSD identity and an ACL limits them to the
  server’s ports and blocks student-to-student traffic. More control
  (central SSO, audit), but heavier setup and the free tier is limited
  on **users**, so a cohort needs a paid plan. Node sharing avoids both.

Either way the instructor’s personal machines are never exposed, and
home directories are always protected by the server, not by Tailscale.

### Step by step: node sharing with a reusable link

**Instructor — once for the whole group (Tailscale admin console):**

1.  Make sure the server is in your tailnet and powered on
    (e.g. `sc2-ubuntu`).
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
  Windows app running, the server is reachable. In VS Code: _Remote-SSH
  -\> Connect to Host_ using `<their-username>@<server>`, where
  `<server>` is the address shown for it in their Tailscale app (its
  `100.x` IP always works; the MagicDNS name works once the share is
  accepted). No WSL is needed for server access.

- **From inside WSL (e.g. `ssh <server>` in a WSL terminal).** WSL2 does
  not see the Windows Tailscale interface by default. Turn on **mirrored
  networking** so WSL shares the Windows network (including Tailscale):
  create/edit `C:\Users\<you>\.wslconfig` with

  ```ini
  [wsl2]
  networkingMode=mirrored
  ```

  then run `wsl --shutdown` and reopen. After that, `ssh <server>` from
  WSL works. (Alternative: install Tailscale _inside_ WSL as its own
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

```json
{
  "acls": [
    { "action": "accept", "src": ["autogroup:members"], "dst": ["*:*"] },
    { "action": "accept", "src": ["autogroup:shared"], "dst": ["*:22"] }
  ]
}
```

Why this is correct and reusable for every server:

- The first rule replaces the default `"src": ["*"]` with
  `autogroup:members`, so the blanket allow applies to **you and your
  own devices only**, not to shared users. (If you also have _tagged_
  devices that initiate connections, add rules for them.)
- The second rule is then the _only_ thing matching shared users, so
  they get **port 22 and nothing else**.
- `dst` is `*:22` on purpose — not a hostname or tag. **Sharing already
  limits a recipient to the one machine you shared with them**, and
  **tags/hostnames are stripped from shared nodes**, so the rule keys on
  the _port_. That means it covers **sc1 today and sc2 the moment you
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
