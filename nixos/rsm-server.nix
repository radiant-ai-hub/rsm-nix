# Reusable RSM-MSBA server module. Host-agnostic: it wires the rsm-nix
# environment into a multi-user NixOS box reachable via VS Code Remote-SSH.
# configuration.nix supplies host identity; students.nix supplies accounts.
{ config, pkgs, lib, rsm-nix, ... }:

let
  system = pkgs.stdenv.hostPlatform.system; # e.g. "x86_64-linux"
  rsmSetup = rsm-nix.packages.${system}.rsm-setup;
  rsmMsba = rsm-nix.packages.${system}.rsm-msba;
in
{
  # --- VS Code Remote-SSH fix (the important one) ----------------------------
  # The VS Code "server" downloads its own dynamically-linked Node binary, which
  # cannot run on NixOS without a standard dynamic loader. nix-ld provides that
  # loader plus the libraries the server (and most prebuilt wheels' helpers)
  # expect. Without this, Remote-SSH connects then immediately disconnects.
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    stdenv.cc.cc # libstdc++, libgcc_s
    zlib
    glib
    openssl
    curl
    icu
    util-linux # libuuid
  ];

  # --- SSH access (key-only) -------------------------------------------------
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      AllowTcpForwarding = true; # forward pgweb / Postgres back to the laptop
      X11Forwarding = false;
    };
  };

  # Only SSH is exposed. Per-student Postgres/pgweb are reached through SSH
  # port-forwarding, never published on the network.
  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [ 22 ];

  # zsh is the environment's native shell. Enabling it here lets students.nix set
  # it as the login shell. The interactiveShellInit hook loads the full rsm shell
  # (oh-my-zsh + powerlevel10k, installed per-workspace by rsm-setup) the moment
  # you enter ~/rsm-msba — in ANY terminal (kitty SSH as well as VS Code). direnv
  # can't do this (it only moves env vars), so a zsh chpwd hook sources the
  # workspace's rsm .zshrc. It persists for that terminal's session (oh-my-zsh
  # has no clean unload); the per-folder signal that reverts is the (nix-uv) venv
  # segment + active python (direnv).
  programs.zsh = {
    enable = true;
    interactiveShellInit = ''
      _rsm_zsh_load() {
        local zd="$HOME/rsm-msba/.rsm-msba/zsh"
        if [[ -z ''${_RSM_ZSH_LOADED:-} && -f "$zd/.zshrc" && ( $PWD == "$HOME/rsm-msba" || $PWD == "$HOME/rsm-msba"/* ) ]]; then
          export _RSM_ZSH_LOADED=1 ZDOTDIR="$zd"
          source "$zd/.zshrc"
        fi
      }
      autoload -Uz add-zsh-hook
      add-zsh-hook chpwd _rsm_zsh_load
      _rsm_zsh_load
    '';
  };

  # --- Shared group + uv download cache --------------------------------------
  # Students share the `rsm` group (set in students.nix) so they can share one
  # uv download cache instead of duplicating ~1.2 GB each. uv runs in copy
  # link-mode (see rsm-nix/bin/rsm-env.sh), so each venv gets private copies;
  # only the downloads are shared. setgid + a default ACL keep new cache entries
  # group-writable regardless of each user's umask.
  users.groups.rsm = { };

  systemd.tmpfiles.rules = [
    "d /srv/uv-cache 2775 root rsm - -"
    "a+ /srv/uv-cache - - - - d:g:rsm:rwx,g:rsm:rwx"
  ];
  environment.sessionVariables.UV_CACHE_DIR = "/srv/uv-cache";

  # --- Per-user Postgres port ------------------------------------------------
  # Handled in the env header (rsm-nix/bin/rsm-env.sh): PGPORT defaults to
  # 8765 + (uid % 1000), so simultaneous users don't collide on 8765. It lives
  # there (not a profile.d snippet) so it applies in every context — login
  # shells, non-login shells, the dev shell, and the rsm-pg-* wrappers alike.

  # --- Environment tooling on PATH ------------------------------------------
  # System-wide direnv + nix-direnv so ~/rsm-msba (and course subfolders)
  # activate on cd, including inside VS Code terminals — this is the fix for the
  # "direnv: command not found" seen in VS Code on a non-NixOS server.
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  environment.systemPackages = with pkgs; [
    git
    git-lfs
    curl
    vim
    direnv
    rsmSetup # `rsm-setup` available system-wide
    rsmMsba # `rsm-msba` — clone-if-missing + rsm-setup, for full reset
  ];

  # --- Seed each student's flake checkout ------------------------------------
  # Clone rsm-nix to ~/rsm-nix for every member of the `rsm` group that does not
  # have it yet, then let them run `rsm-setup` once to build their personal
  # nix-uv env. The real flake is the single source of truth — no toy template.
  systemd.services.rsm-seed-workspaces = {
    description = "Clone rsm-nix into each rsm-group home (if missing)";
    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    path = [ pkgs.git pkgs.coreutils pkgs.getent ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      Environment = "GIT_SSL_CAINFO=${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";
    };
    script = ''
      set -u
      members="$(getent group rsm | cut -d: -f4 | tr ',' ' ')"
      for u in $members; do
        home="$(getent passwd "$u" | cut -d: -f6)"
        [ -n "$home" ] || continue
        if [ ! -e "$home/rsm-nix/flake.nix" ]; then
          git clone https://github.com/radiant-ai-hub/rsm-nix.git "$home/rsm-nix" || true
          chown -R "$u":rsm "$home/rsm-nix" || true
        fi
      done
    '';
  };
}
