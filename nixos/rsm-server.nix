# Reusable RSM-MSBA server module. Host-agnostic: it wires the rsm-nix
# environment into a multi-user NixOS box reachable via VS Code Remote-SSH.
# configuration.nix supplies host identity; students.nix supplies accounts.
{ config, pkgs, lib, rsm-nix, ... }:

let
  system = pkgs.stdenv.hostPlatform.system; # e.g. "x86_64-linux"
  rsmSetup = rsm-nix.packages.${system}.rsm-setup;
  rsmMsba = rsm-nix.packages.${system}.rsm-msba;
  rsmMkdir = rsm-nix.packages.${system}.rsm-mkdir;
  rsmClone = rsm-nix.packages.${system}.rsm-clone;
  rsmProjectCheck = rsm-nix.packages.${system}.rsm-project-check;
  rsmClaude = rsm-nix.packages.${system}.rsm-claude;
  rsmClaudeBoundaryCheck = rsm-nix.packages.${system}.rsm-claude-boundary-check;
  rsmServerEnv = rsm-nix.packages.${system}.rsm-server-env;
  rsmServerEnvHook = rsm-nix.packages.${system}.rsm-server-env-hook;
  rsmFlakePath = "/opt/rsm-nix";
  managedStudentUsers =
    lib.filterAttrs
      (_: user:
        (lib.elem "rsm" (user.extraGroups or [ ]) || (user.group or null) == "rsm")
        && !(lib.elem "rds_managed" (user.extraGroups or [ ]) || (user.group or null) == "rds_managed")
        && (user.uid or null) != null)
      config.users.users;
  managedStudentUids = map (user: toString user.uid) (lib.attrValues managedStudentUsers);
  managedStudentUidWords = lib.concatStringsSep " " managedStudentUids;
  hasManagedStudents = managedStudentUids != [ ];
  managedClaudeSettings = {
    allowManagedPermissionRulesOnly = true;
    allowManagedMcpServersOnly = true;
    allowedMcpServers = [ ];
    disableClaudeAiConnectors = true;
    disableSideloadFlags = true;
    strictPluginOnlyCustomization = [ "mcp" ];
    permissions = {
      disableAutoMode = "disable";
      disableBypassPermissionsMode = "disable";
      deny = [
        "Read(//home/**)"
        "Read(//root/**)"
        "Read(//srv/**)"
        "Read(//mnt/**)"
        "Read(//etc/nixos/**)"
      ];
    };
    sandbox = {
      enabled = true;
      failIfUnavailable = true;
      allowUnsandboxedCommands = false;
      bwrapPath = "${pkgs.bubblewrap}/bin/bwrap";
      socatPath = "${pkgs.socat}/bin/socat";
      filesystem = {
        denyRead = [
          "~/"
          "/home"
          "/root"
          "/srv"
          "/mnt"
          "/etc/nixos"
        ];
        allowRead = [ "~/rsm-msba" ];
        allowManagedReadPathsOnly = true;
        denyWrite = [
          "~/"
          "/home"
          "/root"
          "/srv"
          "/mnt"
          "/etc"
        ];
        allowWrite = [ "~/rsm-msba" ];
      };
      network = {
        allowManagedDomainsOnly = true;
        strictAllowlist = true;
        allowedDomains = [
          "api.anthropic.com:443"
          "claude.ai:443"
          "console.anthropic.com:443"
          "github.com:443"
          "*.github.com:443"
          "*.githubusercontent.com:443"
          "pypi.org:443"
          "files.pythonhosted.org:443"
          "*.pythonhosted.org:443"
        ];
      };
    };
  };
  codexRequirements = ''
    allowed_approval_policies = ["on-request"]
    allowed_sandbox_modes = ["workspace-write"]
    allowed_web_search_modes = []
    default_permissions = "rsm-workspace"
    allow_login_shell = false
    allow_managed_hooks_only = true
    allow_remote_control = false
    check_for_update_on_startup = false

    [allowed_permission_profiles]
    "rsm-workspace" = true
    ":read-only" = false
    ":workspace" = false
    ":danger-full-access" = false

    [features]
    apps = false
    browser_use = false
    browser_use_external = false
    browser_use_full_cdp_access = false
    computer_use = false
    fast_mode = false
    in_app_browser = false
    in_app_updates = false
    memories = false
    multi_agent = false
    plugin_sharing = false
    plugins = false
    remote_plugin = false
    workspace_dependencies = false

    [feedback]
    enabled = false

    [marketplaces]
    restrict_to_allowed_sources = true

    [mcp_servers]

    [permissions.filesystem]
    deny_read = [
      "/etc/nixos/**",
      "/home/*/.ssh/**",
      "/home/*/.aws/**",
      "/home/*/.config/**",
      "/home/*/.claude/**",
      "/home/*/.codex/**",
      "/home/vnijs/**",
      "/mnt/**",
      "/root/**",
      "/srv/**",
    ]

    [permissions.rsm-workspace.workspace_roots]
    "~/rsm-msba" = true

    [permissions.rsm-workspace.filesystem]
    ":minimal" = "read"
    "~/.ssh" = "deny"
    "~/.aws" = "deny"
    "~/.config" = "deny"
    "~/.claude" = "deny"
    "~/.codex" = "deny"
    "~/rsm-nix" = "deny"
    "/etc/nixos" = "deny"
    "/home/vnijs" = "deny"
    "/mnt" = "deny"
    "/root" = "deny"
    "/srv" = "deny"

    [permissions.rsm-workspace.filesystem.":workspace_roots"]
    "." = "write"
    "**/.env" = "deny"
    "**/.env.*" = "deny"
    "**/secrets/**" = "deny"

    [permissions.rsm-workspace.network]
    enabled = true

    [permissions.rsm-workspace.network.domains]
    "api.openai.com" = "allow"
    "chatgpt.com" = "allow"
    "github.com" = "allow"
    "**.github.com" = "allow"
    "**.githubusercontent.com" = "allow"
    "pypi.org" = "allow"
    "files.pythonhosted.org" = "allow"
    "**.pythonhosted.org" = "allow"

    [experimental_network]
    enabled = true
    managed_allowed_domains_only = true
    allow_local_binding = false
    allow_upstream_proxy = false
    dangerously_allow_all_unix_sockets = false
    dangerously_allow_non_loopback_proxy = false

    [experimental_network.domains]
    "api.openai.com" = "allow"
    "chatgpt.com" = "allow"
    "github.com" = "allow"
    "**.github.com" = "allow"
    "**.githubusercontent.com" = "allow"
    "pypi.org" = "allow"
    "files.pythonhosted.org" = "allow"
    "**.pythonhosted.org" = "allow"
  '';
  codexManagedConfig = ''
    approval_policy = "on-request"
    sandbox_mode = "workspace-write"
    default_permissions = "rsm-workspace"

    [sandbox_workspace_write]
    network_access = false
  '';
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
    enable = lib.mkDefault true;
    settings = {
      PasswordAuthentication = lib.mkDefault false;
      KbdInteractiveAuthentication = lib.mkDefault false;
      AllowTcpForwarding = lib.mkDefault true; # forward pgweb / Postgres back to the laptop
      X11Forwarding = lib.mkDefault false;
    };
  };

  # Only SSH is exposed. Per-student Postgres/pgweb are reached through SSH
  # port-forwarding, never published on the network.
  networking.firewall.enable = lib.mkDefault true;
  networking.firewall.allowedTCPPorts = lib.mkDefault [ 22 ];

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
  users.groups.rds_managed = lib.mkDefault { };

  # Students use the root-built /run/current-system/sw RSM environment. They do
  # not need the daemon for coursework, so keep Nix evaluation and installation
  # to root and the managed administrator group.
  nix.settings.allowed-users = lib.mkForce [ "root" "@rds_managed" ];
  nix.settings.trusted-users = lib.mkForce [ "root" "@rds_managed" ];
  systemd.sockets.nix-daemon.socketConfig = {
    SocketMode = lib.mkForce "0660";
    SocketUser = lib.mkForce "root";
    SocketGroup = lib.mkForce "rds_managed";
  };

  # Use the shared cache only when this user can actually write it (i.e. is in
  # the `rsm` group); otherwise a per-user cache, so `uv` never errors out for a
  # user who isn't in the group. Set via shell init (not sessionVariables) so the
  # per-user fallback can be evaluated per login.
  environment.interactiveShellInit = ''
    if [ -w /srv/uv-cache ]; then
      export UV_CACHE_DIR=/srv/uv-cache
    else
      export UV_CACHE_DIR="$HOME/.cache/uv"
    fi
    if id -nG 2>/dev/null | tr ' ' '\n' | grep -qx rsm; then
      export RSM_SERVER_MANAGED_CLAUDE=1
      export RSM_FLAKE=${rsmFlakePath}
    fi
  '';

  environment.etc."claude-code/managed-settings.json" = {
    text = builtins.toJSON managedClaudeSettings;
    mode = "0444";
  };

  environment.etc."claude-code/managed-mcp.json" = {
    text = builtins.toJSON { mcpServers = { }; };
    mode = "0444";
  };

  environment.etc."codex/requirements.toml" = {
    text = codexRequirements;
    mode = "0444";
  };

  environment.etc."codex/managed_config.toml" = {
    text = codexManagedConfig;
    mode = "0444";
  };

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
    rsmMkdir # `rsm-mkdir` — set up a folder (nested or standalone) as a project
    rsmClone # `rsm-clone` — git clone + set the clone up as a project
    rsmProjectCheck # `rsm-project-check` — verify a project's imports
    rsmClaude # managed `claude` wrapper for shared servers
    rsmClaudeBoundaryCheck # smoke-test the outer filesystem boundary
    rsmServerEnv # root-built server shell closure for no-Nix student direnv
    rsmServerEnvHook # /run/current-system/sw/share/rsm-msba/server-env-hook.sh
    bubblewrap
    socat
  ];
  environment.pathsToLink = [ "/share/rsm-msba" ];

  # --- Root-owned flake checkout ---------------------------------------------
  # Shared servers use one immutable, root-owned flake source. Students can read
  # it, but they cannot change the environment definition or shadow it with a
  # writable per-user checkout.
  systemd.tmpfiles.rules = [
    "d /srv/uv-cache 2775 root rsm - -"
    "a+ /srv/uv-cache - - - - d:g:rsm:rwx,g:rsm:rwx"
    "L+ ${rsmFlakePath} - - - - ${rsm-nix}"
  ];

  # Managed student accounts keep loopback, DNS, and HTTPS. Other outbound
  # traffic is blocked at the OS layer, independent of Claude/Codex settings.
  networking.firewall.extraCommands = lib.mkIf hasManagedStudents ''
    rsm_student_allow4() {
      iptables -C OUTPUT "$@" 2>/dev/null || iptables -A OUTPUT "$@"
    }
    rsm_student_allow6() {
      ip6tables -C OUTPUT "$@" 2>/dev/null || ip6tables -A OUTPUT "$@"
    }
    for uid in ${managedStudentUidWords}; do
      rsm_student_allow4 -m owner --uid-owner "$uid" -o lo -j ACCEPT
      rsm_student_allow4 -m owner --uid-owner "$uid" -p udp --dport 53 -j ACCEPT
      rsm_student_allow4 -m owner --uid-owner "$uid" -p tcp --dport 53 -j ACCEPT
      rsm_student_allow4 -m owner --uid-owner "$uid" -p tcp --dport 443 -j ACCEPT
      rsm_student_allow4 -m owner --uid-owner "$uid" -j REJECT

      rsm_student_allow6 -m owner --uid-owner "$uid" -o lo -j ACCEPT
      rsm_student_allow6 -m owner --uid-owner "$uid" -p udp --dport 53 -j ACCEPT
      rsm_student_allow6 -m owner --uid-owner "$uid" -p tcp --dport 53 -j ACCEPT
      rsm_student_allow6 -m owner --uid-owner "$uid" -p tcp --dport 443 -j ACCEPT
      rsm_student_allow6 -m owner --uid-owner "$uid" -j REJECT
    done
  '';

  networking.firewall.extraStopCommands = lib.mkIf hasManagedStudents ''
    rsm_student_delete4() {
      while iptables -D OUTPUT "$@" 2>/dev/null; do :; done
    }
    rsm_student_delete6() {
      while ip6tables -D OUTPUT "$@" 2>/dev/null; do :; done
    }
    for uid in ${managedStudentUidWords}; do
      rsm_student_delete4 -m owner --uid-owner "$uid" -o lo -j ACCEPT
      rsm_student_delete4 -m owner --uid-owner "$uid" -p udp --dport 53 -j ACCEPT
      rsm_student_delete4 -m owner --uid-owner "$uid" -p tcp --dport 53 -j ACCEPT
      rsm_student_delete4 -m owner --uid-owner "$uid" -p tcp --dport 443 -j ACCEPT
      rsm_student_delete4 -m owner --uid-owner "$uid" -j REJECT

      rsm_student_delete6 -m owner --uid-owner "$uid" -o lo -j ACCEPT
      rsm_student_delete6 -m owner --uid-owner "$uid" -p udp --dport 53 -j ACCEPT
      rsm_student_delete6 -m owner --uid-owner "$uid" -p tcp --dport 53 -j ACCEPT
      rsm_student_delete6 -m owner --uid-owner "$uid" -p tcp --dport 443 -j ACCEPT
      rsm_student_delete6 -m owner --uid-owner "$uid" -j REJECT
    done
  '';

  systemd.services.rsm-seed-workspaces = {
    description = "Prepare RSM-MSBA workspace directories for rsm-group users";
    wantedBy = [ "multi-user.target" ];
    path = [ pkgs.coreutils pkgs.getent ];
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
        install -d -m 0700 -o "$u" -g "$u" "$home" "$home/rsm-msba" "$home/rsm-msba/.rsm-msba"
      done
    '';
  };
}
