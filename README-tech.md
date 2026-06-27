

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

Per-platform guides:

- Full getting-started guide:
  [docs/getting-started.md](docs/getting-started.md)
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
| `rsm-python-sync` | Refresh the base env from `uv.lock` |
| `rsm-new-course NAME...` | Create course/project folder(s) + remember in `courses.txt` |
| `rsm-pg-init` / `-start` / `-stop` / `-status` | Workspace-local PostgreSQL lifecycle |
| `rsm-pg-psql` | `psql` into the `rsm-msba` database |
| `rsm-pgweb` | pgweb UI at <http://127.0.0.1:8282> |

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
