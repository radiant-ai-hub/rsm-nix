# NixOS server example for RSM-MSBA

A minimal, multi-user NixOS configuration that hosts the RSM-MSBA computing
environment for students connecting over **VS Code Remote-SSH**. It **consumes**
the `rsm-nix` flake (it does not redefine the environment), so the toolchain is
identical to what students run on their laptops, maintained in one place.

This is the deployable companion to [`docs/server-nixos.md`](../docs/server-nixos.md),
which explains the design. Sized for a small **alpha** (a handful of accounts);
see the "deferred" notes in the doc for scaling further.

## Files

| File | Purpose |
|------|---------|
| `flake.nix` | System flake: pins `nixpkgs` + the `rsm-nix` input → `nixosConfigurations.<host>`. |
| `configuration.nix` | Host glue: hostname, boot loader, Nix daemon, locale, `stateVersion`. |
| `rsm-server.nix` | The reusable RSM module: nix-ld (VS Code fix), SSH, firewall, direnv, shared uv cache, per-user Postgres port, workspace seeding. |
| `students.nix.example` | Account registry template. **Copy to `students.nix`** and add real keys. |
| `hardware-configuration.nix` | **Placeholder** — replace with your host's generated file. |

## Use it

```bash
# On the target host, as admin:
cd /etc/nixos
# 1. Bring in these files (configuration.nix, rsm-server.nix, flake.nix).
# 2. Generate real hardware config (overwrites the placeholder):
sudo nixos-generate-config            # writes hardware-configuration.nix
# 3. Create the account registry with real SSH public keys:
cp students.nix.example students.nix  # then edit: usernames + keys
# 4. Set networking.hostName + nixosConfigurations.<name> to match, and
#    system.stateVersion to this machine's install release.
# 5. Build & switch:
sudo nixos-rebuild switch --flake /etc/nixos#<host>
```

## Important

- **No `wheel` for students.** They must not have sudo on a shared box. Keep a
  *separate* admin account with `wheel` (see `vnijs` in the example) or you will
  lock yourself out of `nixos-rebuild`.
- **`students.nix` is gitignored** so real keys never land in the public repo.
- After switch, each student runs `rsm-setup` once (builds their personal
  nix-uv env), then opens `~/rsm-msba` in VS Code.
- Atomic rollback if anything breaks: `sudo nixos-rebuild switch --rollback`
  (or pick a previous generation at boot).
