#!/usr/bin/env bash
# RSM-MSBA Nix development environment installer for macOS Apple Silicon.

set -euo pipefail

REPO_URL="https://github.com/radiant-ai-hub/rsm-nix.git"
FLAKE_PATH="$HOME/rsm-nix"        # the flake repo (git pull to update)
WORKSPACE_PATH="$HOME/rsm-msba"   # your coursework + state (not a git repo)
SKIP_VSCODE=0
SKIP_WORKSPACE_SETUP=0
DRY_RUN=0

# Fallback extension list, used only if vscode/extensions.txt can't be fetched.
# The curated list lives in vscode/extensions.txt in the repo.
VSCODE_EXTENSIONS=(
  "ms-python.python"
  "ms-toolsai.jupyter"
  "quarto.quarto"
  "mkhl.direnv"
  "pinage404.nix-extension-pack"
)
EXTENSIONS_URL_DEFAULT="https://raw.githubusercontent.com/radiant-ai-hub/rsm-nix/main/vscode/extensions.txt"

usage() {
  cat <<'EOF'
Usage: macos-arm-install-rsm-nix.sh [options]

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
    --repo-url)
      REPO_URL="${2:?--repo-url requires a value}"
      shift 2
      ;;
    --workspace)
      WORKSPACE_PATH="${2:?--workspace requires a value}"
      shift 2
      ;;
    --skip-vscode)
      SKIP_VSCODE=1
      shift
      ;;
    --skip-workspace-setup)
      SKIP_WORKSPACE_SETUP=1
      shift
      ;;
    --dry-run)
      DRY_RUN=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

log_section() {
  printf '\n==> %s\n' "$1"
}

log_detail() {
  printf '    %s\n' "$1"
}

run_or_dry() {
  if [ "$DRY_RUN" -eq 1 ]; then
    log_detail "[dry-run] Would run: $*"
  else
    "$@"
  fi
}

command_exists() {
  command -v "$1" >/dev/null 2>&1
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
  # Raw URL of vscode/extensions.txt in the repo being installed from.
  case "$REPO_URL" in
    https://github.com/*)
      local path="${REPO_URL#https://github.com/}"
      path="${path%.git}"
      printf 'https://raw.githubusercontent.com/%s/main/vscode/extensions.txt\n' "$path"
      ;;
    *)
      printf '%s\n' "$EXTENSIONS_URL_DEFAULT"
      ;;
  esac
}

desired_vscode_extensions() {
  # One extension id per line: the curated vscode/extensions.txt, or the
  # built-in fallback if it can't be fetched. Strips comments and blank lines.
  local text
  if text="$(curl -fsSL "$(extensions_url)" 2>/dev/null)" && [ -n "$text" ]; then
    printf '%s\n' "$text" | sed 's/#.*//;s/[[:space:]]//g' | grep -v '^$'
  else
    printf '%s\n' "${VSCODE_EXTENSIONS[@]}"
  fi
}

ensure_supported_system() {
  log_section "Checking system compatibility"

  if [ "$(uname -s)" != "Darwin" ]; then
    echo "This installer is intended for macOS." >&2
    exit 1
  fi

  if [ "$(uname -m)" != "arm64" ]; then
    echo "This installer supports Apple Silicon Macs only." >&2
    exit 1
  fi

  log_detail "macOS $(sw_vers -productVersion)"
  log_detail "Architecture: $(uname -m)"
}

ensure_xcode_command_line_tools() {
  log_section "Checking Xcode Command Line Tools"

  if xcode-select -p >/dev/null 2>&1; then
    log_detail "Xcode Command Line Tools already installed."
    return
  fi

  if [ "$DRY_RUN" -eq 1 ]; then
    log_detail "[dry-run] Xcode Command Line Tools are missing; would run xcode-select --install."
    return
  fi

  if [ "${CI:-false}" = "true" ]; then
    echo "Xcode Command Line Tools are missing on a CI runner." >&2
    exit 1
  fi

  xcode-select --install
  echo "Finish the Xcode Command Line Tools prompt, then rerun this installer." >&2
  exit 1
}

find_code_command() {
  local candidates=(
    "$(command -v code 2>/dev/null || true)"
    "/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code"
    "$HOME/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code"
    "/usr/local/bin/code"
  )
  local candidate

  for candidate in "${candidates[@]}"; do
    if [ -n "$candidate" ] && [ -x "$candidate" ]; then
      printf '%s\n' "$candidate"
      return 0
    fi
  done

  return 1
}

copy_app_to_applications() {
  local app_path="$1"

  if cp -R "$app_path" /Applications/ 2>/dev/null; then
    return
  fi

  sudo cp -R "$app_path" /Applications/
}

install_symlink() {
  local source_path="$1"
  local target_path="$2"
  local target_dir

  target_dir="$(dirname "$target_path")"
  if [ ! -d "$target_dir" ]; then
    mkdir -p "$target_dir" 2>/dev/null || sudo mkdir -p "$target_dir"
  fi

  if ln -sf "$source_path" "$target_path" 2>/dev/null; then
    return
  fi

  sudo ln -sf "$source_path" "$target_path"
}

install_vscode() {
  if [ "$SKIP_VSCODE" -eq 1 ]; then
    log_detail "Skipping VS Code setup."
    return
  fi

  log_section "Checking Visual Studio Code"

  local vscode_url code_command temp_dir dmg_path mount_output volume_path app_path
  vscode_url="https://code.visualstudio.com/sha/download?build=stable&os=darwin-arm64-dmg"

  if [ "$DRY_RUN" -eq 1 ]; then
    log_detail "[dry-run] Verifying VS Code ARM64 download URL."
    test "$(curl -I -L -s -o /dev/null -w '%{http_code}' "$vscode_url")" = "200"
    local count
    count="$(desired_vscode_extensions | wc -l | tr -d ' ')"
    log_detail "[dry-run] Would install $count VS Code extensions from extensions.txt."
    return
  fi

  if [ -d "/Applications/Visual Studio Code.app" ] || find_code_command >/dev/null 2>&1; then
    log_detail "VS Code already installed."
  else
    temp_dir="$(mktemp -d)"
    trap 'rm -rf "$temp_dir"' RETURN
    dmg_path="$temp_dir/VSCode.dmg"
    curl -L -o "$dmg_path" "$vscode_url"
    mount_output="$(hdiutil attach "$dmg_path" -nobrowse)"
    volume_path="$(printf '%s\n' "$mount_output" | awk -F'\t' '/\/Volumes\// {print $3; exit}')"
    app_path="$volume_path/Visual Studio Code.app"

    if [ ! -d "$app_path" ]; then
      echo "Could not find Visual Studio Code.app in the mounted image." >&2
      exit 1
    fi

    rm -rf "/Applications/Visual Studio Code.app" 2>/dev/null || sudo rm -rf "/Applications/Visual Studio Code.app"
    copy_app_to_applications "$app_path"
    hdiutil detach "$volume_path" -quiet
  fi

  code_command="$(command -v code 2>/dev/null || true)"
  if [ -z "$code_command" ] && [ -x "/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code" ]; then
    install_symlink "/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code" "/usr/local/bin/code"
  fi

  code_command="$(find_code_command || true)"
  if [ -z "$code_command" ]; then
    echo "VS Code is installed, but the code CLI was not found." >&2
    exit 1
  fi

  while IFS= read -r extension; do
    [ -n "$extension" ] || continue
    log_detail "Installing VS Code extension $extension..."
    "$code_command" --install-extension "$extension" --force \
      || log_detail "  could not install $extension; continuing."
  done < <(desired_vscode_extensions)
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
    exit 1
  fi
}

configure_direnv() {
  log_section "Checking direnv and nix-direnv"

  source_nix_profile
  if [ "$DRY_RUN" -eq 1 ]; then
    log_detail "[dry-run] Would run: nix profile install nixpkgs#direnv nixpkgs#nix-direnv"
    log_detail "[dry-run] Would configure ~/.config/direnv/direnvrc and ~/.zshrc"
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

  touch "$HOME/.zshrc"
  # shellcheck disable=SC2016
  if ! grep -Fqx 'eval "$(direnv hook zsh)"' "$HOME/.zshrc"; then
    # shellcheck disable=SC2016
    printf '\n%s\n' 'eval "$(direnv hook zsh)"' >>"$HOME/.zshrc"
  fi
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

  # Bootstrap the workspace: creates $workspace + .envrc + nix-uv env + folders.
  RSM_WORKSPACE="$workspace" nix develop "$flake" -c rsm-setup
  direnv allow "$workspace" || true
  RSM_WORKSPACE="$workspace" nix develop "$flake" -c bash "$flake/tests/check-default.sh"
  RSM_WORKSPACE="$workspace" nix develop "$flake" -c bash "$flake/tests/check-folders.sh"
}

printf '%s\n' "Rady School of Management @ UCSD"
printf '%s\n' "RSM-MSBA Nix Installer for macOS Apple Silicon"
printf '%s\n' "=============================================="

if [ "$DRY_RUN" -eq 1 ]; then
  log_detail "Mode: dry-run (no host mutations)"
fi
log_detail "Workspace: $(expand_workspace_path)"

ensure_supported_system
ensure_xcode_command_line_tools
install_vscode
install_nix
configure_direnv
setup_workspace

printf '\n%s\n' "Installation complete."
printf '%s\n' "Open VS Code and use File > Open Folder for $(expand_workspace_path)."
