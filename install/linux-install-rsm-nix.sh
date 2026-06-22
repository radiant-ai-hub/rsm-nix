#!/usr/bin/env bash
# RSM-MSBA Nix development environment installer for Linux (bare Ubuntu/Debian
# servers, WSL2 Ubuntu, and other Linux hosts).
#
# Per-user setup: installs Determinate Nix (if missing), configures direnv +
# nix-direnv for your login shell (zsh or bash), clones the workspace, and runs
# rsm-setup + smoke checks. It does NOT install VS Code — on a server you connect
# from your laptop with the VS Code "Remote - SSH" extension; install the
# "mkhl.direnv" extension there so terminals/kernels activate automatically.
#
# Run:
#   curl -fsSL https://raw.githubusercontent.com/radiant-ai-hub/rsm-nix/main/install/linux-install-rsm-nix.sh | bash

set -euo pipefail

REPO_URL="https://github.com/radiant-ai-hub/rsm-nix.git"
WORKSPACE_PATH="$HOME/rsm-msba"
SKIP_WORKSPACE_SETUP=0
DRY_RUN=0

usage() {
  cat <<'EOF'
Usage: linux-install-rsm-nix.sh [options]

Options:
  --repo-url URL             Git repository to clone.
  --workspace PATH           Workspace path. Default: ~/rsm-msba.
  --skip-workspace-setup     Do not clone/build the RSM workspace.
  --dry-run                  Check requirements without changing the host.
  -h, --help                 Show this help.
EOF
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --repo-url) REPO_URL="${2:?--repo-url requires a value}"; shift 2 ;;
    --workspace) WORKSPACE_PATH="${2:?--workspace requires a value}"; shift 2 ;;
    --skip-workspace-setup) SKIP_WORKSPACE_SETUP=1; shift ;;
    --dry-run) DRY_RUN=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown option: $1" >&2; usage >&2; exit 1 ;;
  esac
done

log_section() { printf '\n==> %s\n' "$1"; }
log_detail()  { printf '    %s\n' "$1"; }
command_exists() { command -v "$1" >/dev/null 2>&1; }

source_nix_profile() {
  if [ -e /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]; then
    # shellcheck disable=SC1091
    . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
  fi
}

expand_workspace_path() {
  case "$WORKSPACE_PATH" in
    \~) printf '%s\n' "$HOME" ;;
    \~/*) printf '%s/%s\n' "$HOME" "${WORKSPACE_PATH#\~/}" ;;
    *) printf '%s\n' "$WORKSPACE_PATH" ;;
  esac
}

ensure_supported_system() {
  log_section "Checking system compatibility"
  if [ "$(uname -s)" != "Linux" ]; then
    echo "This installer is intended for Linux (use the macOS installer on a Mac)." >&2
    exit 1
  fi
  log_detail "$(uname -s) $(uname -m)"
  if grep -qi microsoft /proc/version 2>/dev/null; then
    log_detail "Detected WSL2."
  fi
}

install_nix() {
  log_section "Checking Determinate Nix"
  source_nix_profile
  if command_exists nix; then
    log_detail "Nix already installed: $(nix --version)"
    return
  fi
  if [ "$DRY_RUN" -eq 1 ]; then
    log_detail "[dry-run] Would install Determinate Nix."
    return
  fi
  curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix \
    | sh -s -- install --no-confirm
  source_nix_profile
  if ! command_exists nix; then
    echo "Nix was installed, but the nix command is not active in this shell." >&2
    echo "Open a new shell (or 'source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh') and rerun." >&2
    exit 1
  fi
}

# Configure direnv + nix-direnv so the VS Code direnv extension and interactive
# shells pick up the environment. Adds the hook to the user's LOGIN shell rc.
configure_direnv() {
  log_section "Checking direnv and nix-direnv"
  source_nix_profile

  local login_shell rc hook
  login_shell="$(basename "${SHELL:-/bin/bash}")"
  # The hook strings are written verbatim to the rc file (not expanded here).
  # shellcheck disable=SC2016
  case "$login_shell" in
    zsh) rc="$HOME/.zshrc";  hook='eval "$(direnv hook zsh)"' ;;
    *)   rc="$HOME/.bashrc"; hook='eval "$(direnv hook bash)"' ;;
  esac

  if [ "$DRY_RUN" -eq 1 ]; then
    log_detail "[dry-run] Would run: nix profile install nixpkgs#direnv nixpkgs#nix-direnv"
    log_detail "[dry-run] Would configure ~/.config/direnv/direnvrc and $rc ($login_shell)"
    return
  fi

  if ! command_exists direnv; then
    nix profile install nixpkgs#direnv
  fi
  if [ ! -e "$HOME/.nix-profile/share/nix-direnv/direnvrc" ]; then
    nix profile install nixpkgs#nix-direnv
  fi

  mkdir -p "$HOME/.config/direnv"
  touch "$HOME/.config/direnv/direnvrc"
  if ! grep -Fqx 'source ~/.nix-profile/share/nix-direnv/direnvrc' "$HOME/.config/direnv/direnvrc"; then
    printf '%s\n' 'source ~/.nix-profile/share/nix-direnv/direnvrc' >>"$HOME/.config/direnv/direnvrc"
  fi

  touch "$rc"
  # shellcheck disable=SC2016
  if ! grep -Fqx "$hook" "$rc"; then
    printf '\n%s\n' "$hook" >>"$rc"
  fi
  log_detail "direnv configured for $login_shell ($rc)."
}

setup_workspace() {
  if [ "$SKIP_WORKSPACE_SETUP" -eq 1 ]; then
    log_detail "Skipping RSM workspace setup."
    return
  fi
  log_section "Setting up RSM workspace"
  local workspace
  workspace="$(expand_workspace_path)"

  if [ "$DRY_RUN" -eq 1 ]; then
    log_detail "[dry-run] Would clone or reuse $REPO_URL at $workspace"
    log_detail "[dry-run] Would run rsm-setup and smoke checks through nix develop."
    return
  fi

  if [ -e "$workspace" ] && [ ! -d "$workspace/.git" ]; then
    echo "Workspace path exists but is not a git checkout: $workspace" >&2
    exit 1
  fi
  if [ ! -d "$workspace/.git" ]; then
    mkdir -p "$(dirname "$workspace")"
    git clone "$REPO_URL" "$workspace"
  else
    log_detail "Reusing existing workspace: $workspace"
  fi

  cd "$workspace"
  source_nix_profile
  direnv allow || true
  nix develop -c bash tests/check-no-host-mutation.sh
  nix develop -c rsm-setup
  nix develop -c bash tests/check-default.sh
  nix develop -c bash tests/check-folders.sh
}

printf '%s\n' "Rady School of Management @ UCSD"
printf '%s\n' "RSM-MSBA Nix Installer for Linux"
printf '%s\n' "================================"
if [ "$DRY_RUN" -eq 1 ]; then
  log_detail "Mode: dry-run (no host mutations)"
fi
log_detail "Workspace: $(expand_workspace_path)"

ensure_supported_system
install_nix
configure_direnv
setup_workspace

printf '\n%s\n' "Installation complete."
printf '%s\n' "Open a new shell (so direnv is active), or reload your VS Code window."
printf '%s\n' "Connect from VS Code with the 'Remote - SSH' + 'mkhl.direnv' extensions,"
printf '%s\n' "then File > Open Folder for $(expand_workspace_path)."
