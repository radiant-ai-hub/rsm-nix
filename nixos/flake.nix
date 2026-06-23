{
  description = "RSM-MSBA NixOS server (example) — consumes the rsm-nix dev environment flake";

  # This is a *system* flake for a NixOS host. It does not redefine the student
  # environment; it imports the rsm-nix flake as an input and puts `rsm-setup`
  # on PATH. The environment is maintained in exactly one place (rsm-nix); the
  # server only adds host concerns (users, SSH, storage).

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # The student/dev environment, consumed unchanged.
    rsm-nix.url = "github:radiant-ai-hub/rsm-nix";

    # NOTE: we deliberately do NOT add `rsm-nix.inputs.nixpkgs.follows =
    # "nixpkgs"`. Letting rsm-nix use its own pinned nixpkgs keeps the env
    # byte-for-byte identical to what students run on laptops. The cost is a
    # second (cached) nixpkgs eval — worth it for reproducibility.
  };

  outputs = { self, nixpkgs, rsm-nix, ... }: {
    # Rename "rsm-server" to your host. It must match `networking.hostName`
    # below and the `#name` you pass to `nixos-rebuild ... --flake .#name`.
    nixosConfigurations.rsm-server = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux"; # most servers; use "aarch64-linux" on ARM
      specialArgs = { inherit rsm-nix; };
      modules = [
        ./configuration.nix
        ./rsm-server.nix
        ./students.nix
      ];
    };
  };
}
