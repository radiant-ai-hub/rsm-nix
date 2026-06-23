# Reusable RSM-MSBA server module. Host-agnostic: it wires the rsm-nix
# environment into a multi-user NixOS box reachable via VS Code Remote-SSH.
# configuration.nix supplies host identity; students.nix supplies accounts.
{ config, pkgs, lib, rsm-nix, ... }:

let
  system = pkgs.stdenv.hostPlatform.system; # e.g. "x86_64-linux"
  rsmSetup = rsm-nix.packages.${system}.rsm-setup;
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

  # zsh is the environment's native shell (banner, aliases, oh-my-zsh prompt).
  # Enabling it here lets students.nix set it as the login shell.
  programs.zsh.enable = true;

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

  # --- Per-user Postgres port (avoid collisions on a shared host) ------------
  # rsm-pg-* honor $PGPORT (default 8765). One host means simultaneous users
  # would collide on 8765, so give each UID its own port. (The unix-socket path
  # used by rsm-pg-psql is already per-user and never collides; this covers the
  # TCP listener and pgweb.)
  environment.etc."profile.d/rsm-pgport.sh".text = ''
    export PGPORT="$(( 8765 + $(id -u) % 50 ))"
  '';

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
    path = [ pkgs.git pkgs.coreutils ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
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
