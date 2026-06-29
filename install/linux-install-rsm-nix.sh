#!/usr/bin/env bash
# RSM-MSBA Nix development environment installer for Linux laptops.
#
# Targets Ubuntu/Debian (apt) and NixOS. One command sets up: VS Code (+ the
# curated extensions), the MesloLGS Nerd Font, Tailscale, Determinate Nix,
# direnv + nix-direnv, and the ~/rsm-msba workspace (then rsm-setup + smoke
# checks).
#
# Notes:
#   - On NixOS, Nix is already present (the Determinate install is skipped), VS
#     Code is installed with `nix profile`, and Tailscale is enabled
#     declaratively (the script prints the one line to add) rather than
#     imperatively.
#   - Other Linux distributions are supported for the Nix/workspace parts; VS
#     Code / Tailscale fall back to a "install it yourself" note.
#
# Run:
#   curl -fsSL https://raw.githubusercontent.com/radiant-ai-hub/rsm-nix/main/install/linux-install-rsm-nix.sh | bash

set -euo pipefail

REPO_URL="https://github.com/radiant-ai-hub/rsm-nix.git"
FLAKE_PATH="$HOME/rsm-nix"        # the flake repo (git pull to update)
WORKSPACE_PATH="$HOME/rsm-msba"   # your coursework + state (not a git repo)
SKIP_VSCODE=0
SKIP_WORKSPACE_SETUP=0
DRY_RUN=0

# Fallback extension list, used only if vscode/extensions.txt can't be fetched.
VSCODE_EXTENSIONS=(
  "ms-python.python"
  "ms-toolsai.jupyter"
  "quarto.quarto"
  "mkhl.direnv"
)
EXTENSIONS_URL_DEFAULT="https://raw.githubusercontent.com/radiant-ai-hub/rsm-nix/main/vscode/extensions.txt"

usage() {
  cat <<'EOF'
Usage: linux-install-rsm-nix.sh [options]

Options:
  --repo-url URL             Git repository to clone.
  --workspace PATH           Workspace path. Default: ~/rsm-msba.
  --skip-vscode              Do not install VS Code or extensions.
  --skip-workspace-setup     Do not clone/build the RSM workspace.
  --dry-run                  Check requirements without changing the host.
  -h, --help                 Show this help.
EOF
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --repo-url) REPO_URL="${2:?--repo-url requires a value}"; shift 2 ;;
    --workspace) WORKSPACE_PATH="${2:?--workspace requires a value}"; shift 2 ;;
    --skip-vscode) SKIP_VSCODE=1; shift ;;
    --skip-workspace-setup) SKIP_WORKSPACE_SETUP=1; shift ;;
    --dry-run) DRY_RUN=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown option: $1" >&2; usage >&2; exit 1 ;;
  esac
done

log_section() { printf '\n==> %s\n' "$1"; }
log_detail()  { printf '    %s\n' "$1"; }
command_exists() { command -v "$1" >/dev/null 2>&1; }

run_or_dry() {
  if [ "$DRY_RUN" -eq 1 ]; then log_detail "[dry-run] Would run: $*"; else "$@"; fi
}

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

extensions_url() {
  case "$REPO_URL" in
    https://github.com/*)
      local path="${REPO_URL#https://github.com/}"
      path="${path%.git}"
      printf 'https://raw.githubusercontent.com/%s/main/vscode/extensions.txt\n' "$path"
      ;;
    *) printf '%s\n' "$EXTENSIONS_URL_DEFAULT" ;;
  esac
}

desired_vscode_extensions() {
  local text
  if text="$(curl -fsSL "$(extensions_url)" 2>/dev/null)" && [ -n "$text" ]; then
    printf '%s\n' "$text" | sed 's/#.*//;s/[[:space:]]//g' | grep -v '^$'
  else
    printf '%s\n' "${VSCODE_EXTENSIONS[@]}"
  fi
}

# --- distro detection -------------------------------------------------------
IS_NIXOS=0
HAS_APT=0
detect_distro() {
  if [ -e /etc/NIXOS ] || command_exists nixos-version; then IS_NIXOS=1; fi
  command_exists apt-get && HAS_APT=1 || true
}

# 'nix profile install' was renamed to 'add'; prefer 'add' when available.
nix_profile_add() {
  if nix profile add --help >/dev/null 2>&1; then
    nix profile add "$@"
  else
    nix profile install "$@"
  fi
}

ensure_supported_system() {
  log_section "Checking system compatibility"
  if [ "$(uname -s)" != "Linux" ]; then
    echo "This installer is for Linux (use the macOS installer on a Mac)." >&2
    exit 1
  fi
  detect_distro
  log_detail "$(uname -s) $(uname -m)"
  if [ "$IS_NIXOS" -eq 1 ]; then
    log_detail "Detected NixOS."
  elif [ "$HAS_APT" -eq 1 ]; then
    log_detail "Detected Debian/Ubuntu (apt)."
  else
    log_detail "Non-apt, non-NixOS Linux: VS Code / Tailscale need manual install."
  fi
  if grep -qi microsoft /proc/version 2>/dev/null; then
    log_detail "Running under WSL2 (the Windows installer is the supported path there)."
  fi
}

install_nix() {
  log_section "Checking Determinate Nix"
  if [ "$IS_NIXOS" -eq 1 ]; then
    log_detail "NixOS already provides Nix; skipping the Determinate installer."
    return
  fi
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
    echo "Nix was installed, but 'nix' is not active in this shell." >&2
    echo "Open a new shell (or source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh) and rerun." >&2
    exit 1
  fi
}

install_vscode() {
  if [ "$SKIP_VSCODE" -eq 1 ]; then
    log_detail "Skipping VS Code setup."
    return
  fi
  log_section "Checking Visual Studio Code"
  source_nix_profile

  if [ "$DRY_RUN" -eq 1 ]; then
    local count
    count="$(desired_vscode_extensions | wc -l | tr -d ' ')"
    if [ "$IS_NIXOS" -eq 1 ]; then
      log_detail "[dry-run] Would install VS Code via: nix profile add nixpkgs#vscode-fhs"
    elif [ "$HAS_APT" -eq 1 ]; then
      log_detail "[dry-run] Would install VS Code via the Microsoft apt repository."
    else
      log_detail "[dry-run] Would ask you to install VS Code manually."
    fi
    log_detail "[dry-run] Would install $count VS Code extensions from extensions.txt."
    return
  fi

  if command_exists code; then
    log_detail "VS Code already installed: $(code --version 2>/dev/null | head -1)"
  elif [ "$IS_NIXOS" -eq 1 ]; then
    # vscode-fhs runs in an FHS env, so extensions that ship binaries (Python,
    # Jupyter, ...) work. On NixOS you could instead add it declaratively:
    #   environment.systemPackages = [ pkgs.vscode-fhs ];
    log_detail "Installing VS Code (nix profile: vscode-fhs)..."
    nix_profile_add nixpkgs#vscode-fhs \
      || log_detail "Could not install vscode-fhs; install VS Code yourself from https://code.visualstudio.com"
  elif [ "$HAS_APT" -eq 1 ]; then
    log_detail "Installing VS Code via the Microsoft apt repository..."
    sudo apt-get update -y
    sudo apt-get install -y wget gpg apt-transport-https
    local key="/usr/share/keyrings/packages.microsoft.gpg"
    wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | sudo tee "$key" >/dev/null
    echo "deb [arch=amd64,arm64,armhf signed-by=$key] https://packages.microsoft.com/repos/code stable main" \
      | sudo tee /etc/apt/sources.list.d/vscode.list >/dev/null
    sudo apt-get update -y
    sudo apt-get install -y code
  else
    log_detail "Please install VS Code from https://code.visualstudio.com, then rerun (or use --skip-vscode)."
    return
  fi

  if ! command_exists code; then
    log_detail "VS Code is installed but 'code' is not on PATH yet; open a new shell to install extensions."
    return
  fi

  # NODE_NO_WARNINGS silences the Node deprecation noise (url.parse/DEP0169) the
  # 'code' CLI prints on every --install-extension.
  while IFS= read -r extension; do
    [ -n "$extension" ] || continue
    log_detail "Installing VS Code extension $extension..."
    NODE_NO_WARNINGS=1 code --install-extension "$extension" --force \
      || log_detail "  could not install $extension; continuing."
  done < <(desired_vscode_extensions)
}

install_nerd_font() {
  # powerlevel10k draws its prompt with a Nerd Font. Install MesloLGS NF into the
  # user font dir and refresh the font cache. Works on Ubuntu and NixOS.
  log_section "Checking MesloLGS Nerd Font"
  local base fonts_dir
  base="https://github.com/romkatv/powerlevel10k-media/raw/master"
  fonts_dir="$HOME/.local/share/fonts"
  local files=(
    "MesloLGS NF Regular.ttf"
    "MesloLGS NF Bold.ttf"
    "MesloLGS NF Italic.ttf"
    "MesloLGS NF Bold Italic.ttf"
  )
  if [ "$DRY_RUN" -eq 1 ]; then
    log_detail "[dry-run] Would install MesloLGS NF (4 styles) into $fonts_dir"
    return
  fi
  mkdir -p "$fonts_dir"
  local f dest url
  for f in "${files[@]}"; do
    dest="$fonts_dir/$f"
    if [ -f "$dest" ]; then
      log_detail "Font already present: $f"
      continue
    fi
    url="$base/$(printf '%s' "$f" | sed 's/ /%20/g')"
    if curl -fsSL -o "$dest" "$url"; then
      log_detail "Installed $f"
    else
      log_detail "Could not download $f; continuing."
      rm -f "$dest"
    fi
  done
  if command_exists fc-cache; then
    fc-cache -f "$fonts_dir" >/dev/null 2>&1 || true
  fi
  log_detail "MesloLGS NF ready. Set your terminal/VS Code font to 'MesloLGS NF'."
}

install_tailscale() {
  # Tailscale lets students reach the MSBA server from any network. Signing in
  # and accepting the instructor's share link are interactive (done by you).
  log_section "Checking Tailscale"
  if command_exists tailscale; then
    log_detail "Tailscale already installed."
    return
  fi
  if [ "$IS_NIXOS" -eq 1 ]; then
    log_detail "On NixOS, enable Tailscale declaratively. Add to configuration.nix:"
    log_detail "    services.tailscale.enable = true;"
    log_detail "then 'sudo nixos-rebuild switch' and 'sudo tailscale up'."
    return
  fi
  if [ "$DRY_RUN" -eq 1 ]; then
    log_detail "[dry-run] Would install Tailscale via https://tailscale.com/install.sh"
    return
  fi
  if [ "$HAS_APT" -eq 1 ] || command_exists dnf; then
    curl -fsSL https://tailscale.com/install.sh | sh \
      || log_detail "Tailscale install failed — install it from https://tailscale.com/download/linux"
  else
    log_detail "Install Tailscale from https://tailscale.com/download/linux"
  fi
  log_detail "Then: 'sudo tailscale up', sign in with your OWN account, and accept the"
  log_detail "instructor's share link to reach the server."
}

# Configure direnv + nix-direnv for the user's LOGIN shell. For zsh we also add
# the managed block that auto-loads the full oh-my-zsh/powerlevel10k shell on
# entering ~/rsm-msba (mirrors macOS); bash gets the direnv hook only.
configure_direnv() {
  log_section "Checking direnv and nix-direnv"
  source_nix_profile

  local login_shell rc
  login_shell="$(basename "${SHELL:-/bin/bash}")"
  case "$login_shell" in
    zsh) rc="$HOME/.zshrc" ;;
    *)   rc="$HOME/.bashrc" ;;
  esac

  if [ "$DRY_RUN" -eq 1 ]; then
    log_detail "[dry-run] Would run: nix profile add nixpkgs#direnv nixpkgs#nix-direnv"
    log_detail "[dry-run] Would configure ~/.config/direnv/direnvrc and $rc ($login_shell)"
    return
  fi

  if ! command_exists direnv; then
    nix_profile_add nixpkgs#direnv
  fi
  if [ ! -e "$HOME/.nix-profile/share/nix-direnv/direnvrc" ]; then
    nix_profile_add nixpkgs#nix-direnv
  fi

  mkdir -p "$HOME/.config/direnv"
  touch "$HOME/.config/direnv/direnvrc"
  if ! grep -Fqx 'source ~/.nix-profile/share/nix-direnv/direnvrc' "$HOME/.config/direnv/direnvrc"; then
    printf '%s\n' 'source ~/.nix-profile/share/nix-direnv/direnvrc' >>"$HOME/.config/direnv/direnvrc"
  fi

  touch "$rc"
  if [ "$login_shell" = "zsh" ]; then
    if ! grep -Fq '# >>> rsm-msba (managed) >>>' "$rc"; then
      cat >>"$rc" <<'ZRC'

# >>> rsm-msba (managed) >>>
# Nix on PATH (safety net; harmless if the system shell config already does this).
[ -e /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ] && \
  . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
# direnv: load the per-folder rsm-msba Python environment automatically.
command -v direnv >/dev/null 2>&1 && eval "$(direnv hook zsh)"
# Load the full oh-my-zsh + powerlevel10k shell when you enter ~/rsm-msba.
# (In VS Code the ZDOTDIR workspace setting loads it at startup instead.)
_rsm_zsh_load() {
  local zd="$HOME/rsm-msba/.rsm-msba/zsh"
  if [[ -z ${_RSM_ZSH_LOADED:-} && -f "$zd/.zshrc" && ( $PWD == "$HOME/rsm-msba" || $PWD == "$HOME/rsm-msba"/* ) ]]; then
    export _RSM_ZSH_LOADED=1 ZDOTDIR="$zd"
    source "$zd/.zshrc"
  fi
}
autoload -Uz add-zsh-hook
add-zsh-hook chpwd _rsm_zsh_load
_rsm_zsh_load
# <<< rsm-msba (managed) <<<
ZRC
    fi
  else
    # shellcheck disable=SC2016
    if ! grep -Fqx 'eval "$(direnv hook bash)"' "$rc"; then
      # shellcheck disable=SC2016
      printf '\n%s\n' 'eval "$(direnv hook bash)"' >>"$rc"
    fi
  fi
  log_detail "direnv configured for $login_shell ($rc)."
}

setup_workspace() {
  if [ "$SKIP_WORKSPACE_SETUP" -eq 1 ]; then
    log_detail "Skipping RSM workspace setup."
    return
  fi
  log_section "Setting up the RSM environment"
  local flake workspace
  flake="$FLAKE_PATH"
  workspace="$(expand_workspace_path)"

  if [ "$DRY_RUN" -eq 1 ]; then
    log_detail "[dry-run] Would clone the flake $REPO_URL to $flake"
    log_detail "[dry-run] Would bootstrap the workspace $workspace via rsm-setup."
    return
  fi

  if [ -e "$flake" ] && [ ! -d "$flake/.git" ]; then
    echo "Flake path exists but is not a git checkout: $flake" >&2
    exit 1
  fi
  if [ ! -d "$flake/.git" ]; then
    mkdir -p "$(dirname "$flake")"
    git clone "$REPO_URL" "$flake"
  else
    log_detail "Reusing existing flake checkout: $flake"
    git -C "$flake" pull --ff-only || true
  fi

  source_nix_profile
  RSM_WORKSPACE="$workspace" nix develop "$flake" -c rsm-setup
  direnv allow "$workspace" || true
  RSM_WORKSPACE="$workspace" nix develop "$flake" -c bash "$flake/tests/check-default.sh"
  RSM_WORKSPACE="$workspace" nix develop "$flake" -c bash "$flake/tests/check-folders.sh"
}

printf '%s\n' "Rady School of Management @ UCSD"
printf '%s\n' "RSM-MSBA Nix Installer for Linux (Ubuntu/Debian + NixOS)"
printf '%s\n' "========================================================"
if [ "$DRY_RUN" -eq 1 ]; then
  log_detail "Mode: dry-run (no host mutations)"
fi
log_detail "Workspace: $(expand_workspace_path)"

ensure_supported_system
install_nix
install_vscode
install_nerd_font
install_tailscale
configure_direnv
setup_workspace

printf '\n%s\n' "Installation complete."
printf '%s\n' "Open a new shell (so direnv is active), then open VS Code and use"
printf '%s\n' "File > Open Folder for $(expand_workspace_path)."
