{ config, pkgs, lib, ... }:

{
  imports = [
    # Replace this placeholder with the real file generated on your host by
    #   sudo nixos-generate-config
    # The committed placeholder only exists so the example evaluates.
    ./hardware-configuration.nix
  ];

  # --- Host identity ---------------------------------------------------------
  # Must match nixosConfigurations.<name> in flake.nix and the `#name` passed to
  # nixos-rebuild.
  networking.hostName = "rsm-server";

  # Boot loader — adjust to your hardware. UEFI default shown; the placeholder
  # hardware-configuration.nix does not set a loader so this one applies.
  boot.loader.systemd-boot.enable = lib.mkDefault true;
  boot.loader.efi.canTouchEfiVariables = lib.mkDefault true;

  # --- Nix daemon ------------------------------------------------------------
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true; # dedupe identical store paths
  };
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  # --- Locale / time (adjust) ------------------------------------------------
  time.timeZone = lib.mkDefault "America/Los_Angeles";
  i18n.defaultLocale = lib.mkDefault "en_US.UTF-8";

  # IMPORTANT: set this to the NixOS release the machine was FIRST installed
  # with, then never change it on upgrades. Replace before deploying.
  system.stateVersion = "24.11";
}
