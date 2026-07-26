#!/usr/bin/env bash
# RSM-MSBA Nix development environment installer for macOS Apple Silicon.

set -euo pipefail

REPO_URL="https://github.com/radiant-ai-hub/rsm-nix.git"
FLAKE_PATH="$HOME/rsm-nix"        # the flake repo (git pull to update)
WORKSPACE_PATH="$HOME/rsm-msba"   # your coursework + state (not a git repo)
SKIP_VSCODE=0
SKIP_WORKSPACE_SETUP=0
DRY_RUN=0
SIMULATE_BROKEN_NIX_VOLUME=0   # test hook: pretend a half-created Nix volume exists

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
TAILSCALE_PKG_URL="https://pkgs.tailscale.com/stable/Tailscale-latest-macos.pkg"

usage() {
  cat <<'EOF'
Usage: macos-arm-install-rsm-nix.sh [options]

Options:
  --repo-url URL             Git repository to clone.
  --workspace PATH           Workspace path. Default: ~/rsm-msba.
  --skip-vscode              Do not install VS Code or extensions.
  --skip-workspace-setup     Do not clone/build the RSM workspace.
  --dry-run                  Check requirements without changing the host.
  --simulate-broken-nix-volume  (testing) Exercise the half-created Nix-volume
                             recovery path without touching real APFS volumes.
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
    --simulate-broken-nix-volume)
      # Test/demo only: force the "a previous run left an unmounted Nix Store
      # volume" branch so the recovery UX can be exercised without real APFS.
      SIMULATE_BROKEN_NIX_VOLUME=1
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

  # NODE_NO_WARNINGS silences the Node deprecation noise (e.g. url.parse /
  # DEP0169) that the VS Code 'code' CLI prints on every --install-extension.
  while IFS= read -r extension; do
    [ -n "$extension" ] || continue
    log_detail "Installing VS Code extension $extension..."
    NODE_NO_WARNINGS=1 "$code_command" --install-extension "$extension" --force \
      || log_detail "  could not install $extension; continuing."
  done < <(desired_vscode_extensions)
}

install_nerd_font() {
  # powerlevel10k draws its prompt with a Nerd Font. Install MesloLGS NF (p10k's
  # recommended font) for the current user - no admin needed. VS Code's terminal
  # is already pointed at it (.vscode/settings.json); for Terminal.app / iTerm2
  # the student selects "MesloLGS NF" as the profile font. Non-fatal.
  log_section "Checking MesloLGS Nerd Font"

  local base fonts_dir
  base="https://github.com/romkatv/powerlevel10k-media/raw/master"
  fonts_dir="$HOME/Library/Fonts"
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
  log_detail "MesloLGS NF ready. In Terminal.app/iTerm2, set the profile font to 'MesloLGS NF'."
}

install_tailscale() {
  # Tailscale lets students reach the MSBA server from any network (incl.
  # UCSD-Protected) without the campus VPN. We install the app; signing in
  # (their own account) and accepting the instructor's share link are
  # interactive and done by the student.
  log_section "Checking Tailscale"

  if [ -d "/Applications/Tailscale.app" ]; then
    log_detail "Tailscale already installed."
    return
  fi

  if [ "$DRY_RUN" -eq 1 ]; then
    log_detail "[dry-run] Would install Tailscale from $TAILSCALE_PKG_URL"
    return
  fi

  local pkg
  pkg="$(mktemp -d)/Tailscale.pkg"
  if curl -fL -o "$pkg" "$TAILSCALE_PKG_URL"; then
    sudo installer -pkg "$pkg" -target / \
      || log_detail "Tailscale install failed — install it from https://tailscale.com/download/mac"
  else
    log_detail "Could not download Tailscale — install it from https://tailscale.com/download/mac"
  fi
  rm -f "$pkg"

  log_detail "Tailscale, once: open it, approve the system extension, sign in with your"
  log_detail "OWN account, then accept the instructor's share link to reach the server."
}

# --- Determinate Nix install + half-created-volume recovery ----------------
# On some Macs (seen on brand-new machines that have effectively never rebooted)
# the Determinate installer creates the encrypted "Nix Store" APFS volume but
# cannot mount it at /nix ("Volume on disk3sX failed to mount"), then aborts.
# It leaves the volume plus /etc/synthetic.conf and /etc/fstab entries behind,
# so every re-run fails identically. The functions below detect that state,
# offer to clean it up (never without confirmation), and tell the student to
# restart and re-run -- a restart activates the /nix mount point.

is_yes() {
  case "$1" in
    [Yy]|[Yy][Ee][Ss]) return 0 ;;
    *) return 1 ;;
  esac
}

prompt_yes_no() {
  # Ask a y/N question on the controlling terminal. stdin is the `curl | bash`
  # pipe, so read from /dev/tty. RSM_ASSUME_ANSWER overrides for tests/CI. With
  # no answer and no tty we return "no" -- destructive steps never run silently.
  local prompt="$1" ans=""
  if [ -n "${RSM_ASSUME_ANSWER:-}" ]; then
    ans="$RSM_ASSUME_ANSWER"
  elif [ -r /dev/tty ]; then
    printf '%s ' "$prompt" > /dev/tty
    IFS= read -r ans < /dev/tty || ans=""
  else
    return 1
  fi
  is_yes "$ans"
}

nix_install_state() {
  # Pure decision helper. Args: nix_present volume_exists nix_mounted (each 1/0).
  #   skip    -- nix already works, do nothing
  #   cleanup -- a half-created volume exists but isn't mounted; recover first
  #   install -- clean slate, install normally
  local nix_present="$1" vol_exists="$2" mounted="$3"
  if [ "$nix_present" = "1" ]; then echo skip; return; fi
  if [ "$vol_exists" = "1" ] && [ "$mounted" != "1" ]; then echo cleanup; return; fi
  echo install
}

nix_store_volume_id() {
  # Device identifier (diskXsY) of the 'Nix Store' APFS volume, or empty.
  # When the volume doesn't exist `diskutil info` exits non-zero; capture it in
  # its own substitution (no pipe) so `set -e -o pipefail` doesn't abort here --
  # a missing volume is the normal case, not an error.
  if [ "${SIMULATE_BROKEN_NIX_VOLUME:-0}" = "1" ]; then
    printf 'disk9s9\n'
    return 0
  fi
  local info
  info="$(diskutil info "Nix Store" 2>/dev/null)" || return 0
  printf '%s\n' "$info" \
    | awk -F: '/Device Identifier/ { gsub(/[[:space:]]/, "", $2); print $2; exit }'
}

nix_is_mounted() {
  if [ "${SIMULATE_BROKEN_NIX_VOLUME:-0}" = "1" ]; then return 1; fi
  mount 2>/dev/null | grep -q ' /nix '
}

strip_lines_privileged() {
  # Remove lines matching extended-regex $1 from file $2 (needs root in prod;
  # tests shim `sudo`). Portable rewrite-via-temp so it works with GNU and BSD
  # sed alike. Missing file is a no-op.
  local pattern="$1" file="$2" tmp
  [ -e "$file" ] || return 0
  tmp="$(mktemp)"
  grep -vE "$pattern" "$file" > "$tmp" 2>/dev/null || true
  sudo cp "$tmp" "$file"
  rm -f "$tmp"
}

remove_stale_nix_volume() {
  # Undo a half-created Determinate install. Prefer Determinate's own uninstaller
  # when it's reachable (it usually isn't -- it lives under the /nix that never
  # mounted), then delete the leftover volume and clear ONLY the /nix mount
  # config so a fresh install can recreate everything.
  local vol_id="$1"
  if [ -x /nix/nix-installer ]; then
    log_detail "Removing the partial install with the Determinate uninstaller..."
    sudo /nix/nix-installer uninstall --no-confirm \
      || log_detail "  uninstaller reported an error; continuing with manual cleanup."
  fi
  if [ -n "$vol_id" ]; then
    log_detail "Deleting APFS volume $vol_id ('Nix Store')..."
    sudo diskutil apfs deleteVolume "$vol_id" \
      || log_detail "  could not delete $vol_id automatically; remove it in Disk Utility."
  fi
  log_detail "Clearing the leftover /nix mount configuration..."
  # synthetic.conf: the firmlink line is exactly 'nix' (optionally 'nix<TAB>...').
  # Anchored so paths like /data/nixcache or 'nixpkgs' are left untouched.
  strip_lines_privileged '^nix([[:space:]].*)?$' "${RSM_SYNTHETIC_CONF:-/etc/synthetic.conf}"
  # fstab: only the '/nix apfs ...' entry, not other apfs volumes or /opt/nix*.
  strip_lines_privileged '(^|[[:space:]])/nix[[:space:]]+apfs' "${RSM_FSTAB:-/etc/fstab}"
  sudo security delete-generic-password -s "Nix Store" \
    /Library/Keychains/System.keychain >/dev/null 2>&1 || true
}

print_restart_instructions() {
  cat <<'EOF'

    Next step: restart your Mac yourself, then run the same install command
    again. The restart activates the /nix mount point, after which Nix installs
    cleanly:

      curl -fsSL https://raw.githubusercontent.com/radiant-ai-hub/rsm-nix/main/install/macos-arm-install-rsm-nix.sh | bash
EOF
}

print_manual_cleanup_instructions() {
  local vol_id="$1"
  cat <<EOF

    Leaving it in place. To finish Nix setup later, remove the volume, restart
    your Mac, and run the install command again:

      sudo diskutil apfs deleteVolume $vol_id
      # then restart your Mac and re-run the installer
EOF
}

handle_stale_nix_volume() {
  local vol_id="$1"
  log_detail "A previous Nix install left an unmounted 'Nix Store' volume ($vol_id)."
  log_detail "This is why the install failed and why re-running keeps failing. It is"
  log_detail "safe to remove -- Nix recreates it on the next run."

  if [ "$DRY_RUN" -eq 1 ]; then
    log_detail "[dry-run] Would ask to remove volume $vol_id and clear its"
    log_detail "[dry-run] /etc/synthetic.conf and /etc/fstab entries."
    print_restart_instructions
    return
  fi

  if ! prompt_yes_no "Remove the leftover 'Nix Store' volume $vol_id now? [y/N]"; then
    print_manual_cleanup_instructions "$vol_id"
    exit 1
  fi

  remove_stale_nix_volume "$vol_id"
  print_restart_instructions
  # A restart is required before Nix can be reinstalled, so stop here.
  exit 1
}

install_determinate_nix() {
  # Single point that runs the upstream installer; kept in its own function so
  # `if ! install_determinate_nix` can capture failure (set -e is suppressed for
  # a function used as a condition).
  curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix \
    | sh -s -- install --no-confirm
}

install_nix() {
  log_section "Checking Determinate Nix"

  source_nix_profile

  if [ "${SIMULATE_BROKEN_NIX_VOLUME:-0}" = "1" ]; then
    handle_stale_nix_volume "$(nix_store_volume_id)"
    return
  fi

  local nix_present=0 vol_exists=0 mounted=0 vol_id state
  command_exists nix && nix_present=1
  vol_id="$(nix_store_volume_id)"
  [ -n "$vol_id" ] && vol_exists=1
  nix_is_mounted && mounted=1
  state="$(nix_install_state "$nix_present" "$vol_exists" "$mounted")"

  case "$state" in
    skip)
      log_detail "Nix already installed: $(nix --version)"
      return
      ;;
    cleanup)
      handle_stale_nix_volume "$vol_id"
      return
      ;;
  esac

  if [ "$DRY_RUN" -eq 1 ]; then
    log_detail "[dry-run] Would install Determinate Nix."
    return
  fi

  if ! install_determinate_nix; then
    # The common first-run failure IS the mount failure above: the volume got
    # created but couldn't mount. Re-detect and route into the same recovery.
    vol_id="$(nix_store_volume_id)"
    if [ -n "$vol_id" ] && ! nix_is_mounted; then
      handle_stale_nix_volume "$vol_id"
      return
    fi
    echo "Determinate Nix installation failed." >&2
    exit 1
  fi

  source_nix_profile
  if ! command_exists nix; then
    echo "Nix was installed, but the nix command is not active in this shell." >&2
    exit 1
  fi
}

configure_direnv() {
  log_section "Checking direnv and nix-direnv"

  source_nix_profile

  # 'nix profile install' was renamed to 'add'; prefer 'add' when the Nix in use
  # supports it, so it doesn't print "'install' is a deprecated alias for 'add'".
  # Falls back to 'install' on older Nix.
  local nix_add="install"
  if nix profile add --help >/dev/null 2>&1; then
    nix_add="add"
  fi

  if [ "$DRY_RUN" -eq 1 ]; then
    log_detail "[dry-run] Would run: nix profile $nix_add nixpkgs#direnv nixpkgs#nix-direnv"
    log_detail "[dry-run] Would configure ~/.config/direnv/direnvrc and the managed ~/.zshrc block"
    return
  fi

  if ! command_exists direnv; then
    nix profile "$nix_add" nixpkgs#direnv
  fi

  if [ ! -e "$HOME/.nix-profile/share/nix-direnv/direnvrc" ]; then
    nix profile "$nix_add" nixpkgs#nix-direnv
  fi

  mkdir -p "$HOME/.config/direnv"
  touch "$HOME/.config/direnv/direnvrc"
  if ! grep -Fqx 'source ~/.nix-profile/share/nix-direnv/direnvrc' "$HOME/.config/direnv/direnvrc"; then
    printf '%s\n' 'source ~/.nix-profile/share/nix-direnv/direnvrc' >>"$HOME/.config/direnv/direnvrc"
  fi

  # Managed ~/.zshrc block so EVERY terminal (Terminal.app, iTerm2, VS Code)
  # loads direnv and auto-loads the full oh-my-zsh/powerlevel10k shell on
  # entering ~/rsm-msba. The Nix-on-PATH line is a safety net for terminals
  # (e.g. iTerm2) that don't pick up the system Nix shell snippet, which is the
  # usual reason "nothing happens" there. Mirrors the Windows/WSL installer;
  # idempotent via the marker.
  touch "$HOME/.zshrc"
  if ! grep -Fq '# >>> rsm-msba (managed) >>>' "$HOME/.zshrc"; then
    cat >>"$HOME/.zshrc" <<'ZRC'

# >>> rsm-msba (managed) >>>
# Nix on PATH (safety net; harmless if the system zsh config already does this).
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
  # Create the personal SSH key if absent (idempotent). `github` later adds the
  # server to ~/.ssh/config with your username.
  RSM_WORKSPACE="$workspace" nix develop "$flake" -c rsm-ssh-setup || true
  RSM_WORKSPACE="$workspace" nix develop "$flake" -c bash "$flake/tests/check-default.sh"
  RSM_WORKSPACE="$workspace" nix develop "$flake" -c bash "$flake/tests/check-folders.sh"
}

# RSM_INSTALLER_NOEXEC=1 lets tests source this file (defining the functions
# above) without running the installer -- safe for `curl | bash`, which never
# sets it.
if [ "${RSM_INSTALLER_NOEXEC:-0}" != "1" ]; then
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
  install_nerd_font
  install_tailscale
  install_nix
  configure_direnv
  setup_workspace

  printf '\n%s\n' "Installation complete."
  printf '%s\n' "Open VS Code and use File > Open Folder for $(expand_workspace_path)."
fi
