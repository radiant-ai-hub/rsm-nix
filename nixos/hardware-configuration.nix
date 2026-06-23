# ============================================================================
# PLACEHOLDER — DO NOT DEPLOY THIS FILE.
#
# Replace it with the file generated ON YOUR HOST by:
#   sudo nixos-generate-config
# (it writes /etc/nixos/hardware-configuration.nix). This stub exists only so
# the example flake evaluates with `nix eval` / `nixos-rebuild build`; it will
# NOT boot a real machine.
# ============================================================================
{ lib, modulesPath, ... }:

{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/boot";
    fsType = "vfat";
  };

  swapDevices = [ ];
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
