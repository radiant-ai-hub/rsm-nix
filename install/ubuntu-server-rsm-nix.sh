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
#   3. uv download cache: PER-USER by default (each student's ~/.cache/uv). Opt
#      into a shared cache (saves re-downloading wheels) with ENABLE_UV_CACHE=1
#      + RSM_GROUP=<a dedicated group>; students are never added to a privileged
#      group, and the shell only uses the shared cache when it is writable.
#   4. (ENABLE_ZSH_HOOK=1) a chpwd hook in /etc/zsh/zshrc so the full
#      oh-my-zsh/powerlevel10k shell loads in plain SSH terminals too (VS Code
#      gets it via the workspace ZDOTDIR).
#
# Prereqs: multi-user Nix already installed (nix-daemon running) with flakes
# enabled, plus sudo. Determinate Nix is the supported installer:
#   curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
#
# Run this server setup (one-liner; idempotent — safe to re-run to update the
# shell config / pick up changes). Run as a sudo-capable user:
#   curl -fsSL https://raw.githubusercontent.com/radiant-ai-hub/rsm-nix/main/install/ubuntu-server-rsm-nix.sh | bash
# To also refresh the rsm-* commands to the latest release afterward:
#   sudo /nix/var/nix/profiles/default/bin/nix profile upgrade --profile /nix/var/nix/profiles/rsm --all
#
# Then EACH student does: log in fresh -> `rsm-setup` (once) -> `cd ~/rsm-msba`.
# (`rsm-update` later re-runs setup + bumps their tools.)
#
# Reverse everything:
#   sudo rm -f /etc/profile.d/rsm.sh /etc/direnv/direnvrc
#   sudo rm -f /usr/local/bin/rsm-setup /usr/local/bin/rsm-msba \
#              /usr/local/bin/rsm-update /usr/local/bin/rsm-mkdir \
#              /usr/local/bin/rsm-clone /usr/local/bin/rsm-project-check \
#              /usr/local/bin/direnv
#   sudo rm /nix/var/nix/profiles/rsm /nix/var/nix/profiles/rsm-*   # profile + generations
#   # and delete the "rsm-msba (managed)" block from /etc/zsh/zshrc
#   # (the /srv/uv-cache directory can stay or be removed)

set -euo pipefail

PROFILE=/nix/var/nix/profiles/rsm
FLAKE_REF="${FLAKE_REF:-github:radiant-ai-hub/rsm-nix}"
UV_CACHE="${UV_CACHE:-/srv/uv-cache}"
# Per-user uv caches by DEFAULT: each student's uv writes its own ~/.cache/uv.
# No shared writable directory, and no student needs to be in any privileged
# group. Opt into a SHARED cache only by setting ENABLE_UV_CACHE=1 together with
# RSM_GROUP=<a-dedicated-group>. NEVER point RSM_GROUP at a group students must
# not be able to write to (e.g. an admin/management group) — uv opens its cache
# read-write, so every user of a shared cache can write it.
ENABLE_UV_CACHE="${ENABLE_UV_CACHE:-0}"
RSM_GROUP="${RSM_GROUP:-}"                  # required (and dedicated) iff ENABLE_UV_CACHE=1
ENABLE_ZSH_HOOK="${ENABLE_ZSH_HOOK:-1}"

if [ "$ENABLE_UV_CACHE" = "1" ] && [ -z "$RSM_GROUP" ]; then
  echo "ENABLE_UV_CACHE=1 requires RSM_GROUP=<dedicated group> (a group made for" >&2
  echo "the cache, NOT one students shouldn't be able to write). Aborting." >&2
  exit 1
fi

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
# The commands the server profile provides (rsm-clone/rsm-mkdir are the folder
# commands students actually use; rsm-new-project was merged into rsm-mkdir).
RSM_CMDS=(rsm-setup rsm-msba rsm-update rsm-mkdir rsm-clone rsm-project-check)

if [ -e "$PROFILE" ]; then
  # Present already -> UPGRADE it to the latest so re-running this one-liner
  # actually updates the server (rsm-setup/rsm-update etc. re-resolve their
  # `github:radiant-ai-hub/rsm-nix` ref to the newest main). The /usr/local/bin
  # symlinks point at $PROFILE/bin, so they follow the upgrade automatically.
  detail "already present — upgrading to the latest $FLAKE_REF"
  # rsm-new-project was merged into rsm-mkdir. Drop the now-removed element FIRST,
  # else `profile upgrade --all` fails re-resolving an output the flake no longer
  # has. Removing a name that isn't installed is a harmless no-op.
  sudo "$NIX" "${NIXFLAGS[@]}" profile remove --profile "$PROFILE" rsm-new-project >/dev/null 2>&1 || true
  sudo "$NIX" "${NIXFLAGS[@]}" profile upgrade --profile "$PROFILE" --all
  # Add any commands an older install predates (e.g. rsm-mkdir/rsm-clone). Only
  # install the ones not already in the profile, so this stays idempotent.
  for _cmd in "${RSM_CMDS[@]}"; do
    if ! sudo "$NIX" "${NIXFLAGS[@]}" profile list --profile "$PROFILE" 2>/dev/null | grep -q -- "$_cmd"; then
      detail "adding missing command: $_cmd"
      sudo "$NIX" "${NIXFLAGS[@]}" profile install --profile "$PROFILE" "${FLAKE_REF}#${_cmd}"
    fi
  done
else
  detail "installing ${RSM_CMDS[*]} + direnv + nix-direnv"
  _refs=()
  for _cmd in "${RSM_CMDS[@]}"; do _refs+=("${FLAKE_REF}#${_cmd}"); done
  sudo "$NIX" "${NIXFLAGS[@]}" profile install --profile "$PROFILE" \
    "${_refs[@]}" 'nixpkgs#direnv' 'nixpkgs#nix-direnv'
fi

# --- 1b. Commands on PATH for EVERY shell, the simple way ------------------
# /usr/local/bin is on the default PATH for login AND non-login shells (VS Code
# terminals, `su`, subshells), so a symlink here beats juggling profile.d vs
# /etc/zsh/zshrc. Points at the gc-rooted profile, so it survives upgrades.
log "symlinks in /usr/local/bin"
for t in "${RSM_CMDS[@]}" direnv; do
  sudo ln -sfn "$PROFILE/bin/$t" "/usr/local/bin/$t"
done
# Drop a stale rsm-new-project symlink from an older install (now merged into rsm-mkdir).
sudo rm -f /usr/local/bin/rsm-new-project

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
# uv cache: per-user by default. Use the shared cache ONLY when it exists AND
# this user can actually write it — so `uv` (uv run/sync/pip) and rsm-setup never
# error out for students who aren't in the cache's group. Appended after the
# truncating rewrite above (step 5 sets the same for non-login zsh).
sudo tee -a /etc/profile.d/rsm.sh >/dev/null <<EOF

if [ -w "$UV_CACHE" ]; then
  export UV_CACHE_DIR="$UV_CACHE"
else
  export UV_CACHE_DIR="\$HOME/.cache/uv"
fi
EOF

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
if [ -w /srv/uv-cache ]; then export UV_CACHE_DIR="${UV_CACHE_DIR:-/srv/uv-cache}"; else export UV_CACHE_DIR="${UV_CACHE_DIR:-$HOME/.cache/uv}"; fi
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
# Self-check: confirm the profile's rsm-setup is a RECENT one (has the data-seed
# + self-update features), so re-running this really did update the server.
if grep -q 'rsm_seed_dir' "$PROFILE/bin/rsm-setup" 2>/dev/null; then
  detail "server profile is current: rsm-setup seeds data/ and self-updates in one run"
else
  detail "WARNING: profile rsm-setup still looks old — the upgrade may not have fetched the latest ($FLAKE_REF)"
fi
detail "Users: log in fresh, run 'rsm-setup' once, then 'cd ~/rsm-msba'."
detail "Verify: zsh -lic 'command -v rsm-setup; echo \$UV_CACHE_DIR'"
