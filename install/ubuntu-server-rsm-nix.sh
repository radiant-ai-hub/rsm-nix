#!/usr/bin/env bash
# RSM-MSBA multi-user SERVER setup for Ubuntu/Debian — the imperative analog of
# nixos/rsm-server.nix. Makes `rsm-setup` + the rsm-nix dev environment
# available to every user on a shared host that already runs multi-user
# (daemon) Nix. Used on rsm-compute-02 while it is on Ubuntu 24.04.
#
# This is for a SERVER (all users), not a laptop — for a personal machine use
# install/linux-install-rsm-nix.sh instead.
#
# What it sets up (every step idempotent; re-running only fills in what's
# missing):
#   1. rsm-setup/rsm-msba/rsm-update + direnv + nix-direnv in a dedicated SYSTEM
#      Nix profile (/nix/var/nix/profiles/rsm), then symlinked into
#      /usr/local/bin so the commands are on PATH for EVERY shell -- login and
#      non-login alike (VS Code terminals, `su`, ...) -- with no shell-config
#      juggling.
#   2. /etc/direnv/direnvrc -> nix-direnv `use flake` for all users.
#   3. (ENABLE_UV_CACHE=1) shared uv download cache at /srv/uv-cache, group
#      $RSM_GROUP, setgid + default ACL — saves ~1.2 GB per student.
#   4. (ENABLE_ZSH_HOOK=1) a chpwd hook in /etc/zsh/zshrc so the full
#      oh-my-zsh/powerlevel10k shell loads in plain SSH terminals too (VS Code
#      gets it via the workspace ZDOTDIR).
#
# Prereqs: multi-user Nix already installed (nix-daemon running) with flakes
# enabled, plus sudo. Determinate Nix is the supported installer:
#   curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
#
# Then a user does: log in fresh -> `rsm-setup` (once) -> `cd ~/rsm-msba`.
#
# Reverse everything:
#   sudo rm -f /etc/profile.d/rsm.sh /etc/direnv/direnvrc
#   sudo rm -f /usr/local/bin/rsm-setup /usr/local/bin/rsm-msba \
#              /usr/local/bin/rsm-update /usr/local/bin/direnv
#   sudo rm /nix/var/nix/profiles/rsm /nix/var/nix/profiles/rsm-*   # profile + generations
#   # and delete the "rsm-msba (managed)" block from /etc/zsh/zshrc
#   # (the /srv/uv-cache directory can stay or be removed)

set -euo pipefail

PROFILE=/nix/var/nix/profiles/rsm
FLAKE_REF="${FLAKE_REF:-github:radiant-ai-hub/rsm-nix}"
RSM_GROUP="${RSM_GROUP:-rds_managed}"      # group every student already shares
UV_CACHE="${UV_CACHE:-/srv/uv-cache}"
ENABLE_UV_CACHE="${ENABLE_UV_CACHE:-1}"
ENABLE_ZSH_HOOK="${ENABLE_ZSH_HOOK:-1}"

log() { printf '\n==> %s\n' "$1"; }
detail() { printf '    %s\n' "$1"; }

# --- prereqs ---------------------------------------------------------------
NIX="$(command -v nix || true)"
[ -n "$NIX" ] || NIX=/nix/var/nix/profiles/default/bin/nix
if [ ! -x "$NIX" ]; then
  echo "Nix not found. Install multi-user Nix first (see the header)." >&2
  exit 1
fi
if ! systemctl is-active --quiet nix-daemon 2>/dev/null; then
  echo "Warning: nix-daemon is not active — this script expects a MULTI-USER Nix install." >&2
fi
NIXFLAGS=(--extra-experimental-features 'nix-command flakes')

# --- 1. system profile: rsm tools + direnv/nix-direnv ----------------------
log "rsm system profile ($PROFILE)"
if [ -e "$PROFILE" ]; then
  detail "already present — leaving as-is"
  detail "update later with: sudo $NIX profile upgrade --profile $PROFILE --all"
else
  detail "installing rsm-setup/rsm-msba/rsm-update + direnv + nix-direnv"
  sudo "$NIX" "${NIXFLAGS[@]}" profile install --profile "$PROFILE" \
    "${FLAKE_REF}#rsm-setup" "${FLAKE_REF}#rsm-msba" "${FLAKE_REF}#rsm-update" \
    'nixpkgs#direnv' 'nixpkgs#nix-direnv'
fi

# --- 1b. Commands on PATH for EVERY shell, the simple way ------------------
# /usr/local/bin is on the default PATH for login AND non-login shells (VS Code
# terminals, `su`, subshells), so a symlink here beats juggling profile.d vs
# /etc/zsh/zshrc. Points at the gc-rooted profile, so it survives upgrades.
log "symlinks in /usr/local/bin"
for t in rsm-setup rsm-msba rsm-update direnv; do
  sudo ln -sfn "$PROFILE/bin/$t" "/usr/local/bin/$t"
done

# --- 2. direnv hook (+ shared cache) for login shells ----------------------
log "/etc/profile.d/rsm.sh (direnv hook + uv cache)"
sudo tee /etc/profile.d/rsm.sh >/dev/null <<'EOF'
# RSM-MSBA environment (Ubuntu analog of sc1's NixOS rsm-server.nix).
# The rsm-* commands + direnv are on PATH via /usr/local/bin symlinks (step 1b);
# this only adds the direnv hook so `cd ~/rsm-msba` auto-loads the flake env.
if command -v direnv >/dev/null 2>&1; then
  if   [ -n "${ZSH_VERSION:-}" ];  then eval "$(direnv hook zsh)"
  elif [ -n "${BASH_VERSION:-}" ]; then eval "$(direnv hook bash)"
  fi
fi
EOF
if [ "$ENABLE_UV_CACHE" = "1" ]; then
  # Appended after the truncating rewrite above, so it stays a single line on re-run.
  echo "export UV_CACHE_DIR=\"$UV_CACHE\"" | sudo tee -a /etc/profile.d/rsm.sh >/dev/null
fi

# --- 3. nix-direnv `use flake` for everyone --------------------------------
log "/etc/direnv/direnvrc (nix-direnv use flake)"
sudo install -d -m 0755 /etc/direnv
sudo tee /etc/direnv/direnvrc >/dev/null <<'EOF'
# Enable nix-direnv's `use flake` for all users (rsm-msba workspaces use it).
source /nix/var/nix/profiles/rsm/share/nix-direnv/direnvrc
EOF

# --- 4. shared uv download cache (optional) --------------------------------
if [ "$ENABLE_UV_CACHE" = "1" ]; then
  log "shared uv cache $UV_CACHE (group $RSM_GROUP)"
  sudo install -d -m 2775 -g "$RSM_GROUP" "$UV_CACHE"
  if command -v setfacl >/dev/null 2>&1; then
    sudo setfacl -d -m "g:${RSM_GROUP}:rwx" "$UV_CACHE"
    sudo setfacl    -m "g:${RSM_GROUP}:rwx" "$UV_CACHE"
    detail "setgid + default ACL set (new entries stay group-writable)"
  else
    detail "setfacl not found — install 'acl' for inherited group-write ACLs"
  fi
fi

# --- 5. interactive-shell coverage -----------------------------------------
# Commands are already on PATH via /usr/local/bin; this adds the direnv hook +
# ~/rsm-msba loader for NON-login interactive zsh (VS Code terminals, `su`),
# which never source /etc/profile.d. Every interactive zsh sources
# /etc/zsh/zshrc. Strip any prior managed block first so re-runs update in
# place. Mirrors nixos/rsm-server.nix.
if [ "$ENABLE_ZSH_HOOK" = "1" ] && [ -f /etc/zsh/zshrc ]; then
  log "/etc/zsh/zshrc (direnv hook + rsm-msba loader)"
  sudo su -c "sed -i '/# >>> rsm-msba (managed) >>>/,/# <<< rsm-msba (managed) <<</d' /etc/zsh/zshrc"
  sudo tee -a /etc/zsh/zshrc >/dev/null <<'EOF'

# >>> rsm-msba (managed) >>>
# Non-login interactive zsh (VS Code terminals, `su`) doesn't source
# /etc/profile.d, so set the shared cache + direnv hook here too. (The rsm-*
# commands + direnv are already on PATH via /usr/local/bin symlinks.)
[ -d /srv/uv-cache ] && export UV_CACHE_DIR="${UV_CACHE_DIR:-/srv/uv-cache}"
command -v direnv >/dev/null 2>&1 && eval "$(direnv hook zsh)"
# Load the full oh-my-zsh + powerlevel10k shell on entering ~/rsm-msba (kitty/SSH;
# VS Code gets it via the workspace ZDOTDIR).
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
# The host /etc/zsh/zshrc installs `_uv_auto_activate`, a chpwd hook that
# activates a local ./.venv or else falls back to /opt/base-uv/.venv. The
# rsm-msba nix-uv env lives in .rsm-msba/envs (not ./.venv), so that hook never
# finds it and re-sources base-uv on EVERY chpwd -- including cd'ing *within*
# ~/rsm-msba (e.g. into examples/), where direnv is already loaded and so does
# NOT re-assert. That silently clobbers nix-uv back to base-uv (wrong numpy,
# missing sqlalchemy/duckdb, ...). Fix: make that hook defer to direnv whenever
# direnv manages the current dir (DIRENV_DIR set), keeping its original behavior
# everywhere else. Wrap (don't rewrite) the host function so SDSC updates to it
# are preserved.
if (( ${+functions[_uv_auto_activate]} )); then
  functions[_rsm_uv_auto_activate_orig]=$functions[_uv_auto_activate]
  _uv_auto_activate() {
    [[ -n ${DIRENV_DIR:-} ]] && return   # direnv owns the venv in this tree
    _rsm_uv_auto_activate_orig
  }
fi
# Belt-and-suspenders: also make direnv the LAST chpwd hook so it wins on the
# first entry into ~/rsm-msba, before DIRENV_DIR is set.
if (( ${+functions[_direnv_hook]} )); then
  add-zsh-hook -d chpwd _direnv_hook
  add-zsh-hook chpwd _direnv_hook
fi
# <<< rsm-msba (managed) <<<
EOF
fi

log "done"
detail "Users: log in fresh, run 'rsm-setup' once, then 'cd ~/rsm-msba'."
detail "Verify: zsh -lic 'command -v rsm-setup; echo \$UV_CACHE_DIR'"
