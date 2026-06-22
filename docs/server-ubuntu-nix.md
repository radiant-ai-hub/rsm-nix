

<!-- generated from docs/src/server-ubuntu-nix.qmd — edit the .qmd, then run docs/src/render-docs.sh -->

# RSM-MSBA on an Ubuntu 24.04 server (multi-user Nix)

> **Path A — the immediate MVP.** Ubuntu 24.04 LTS with multi-user Nix
> gives you the same flake students run on their laptops, hosted
> centrally. Students connect over SSH (terminal or VS Code Remote-SSH)
> and open their own `~/rsm-msba`. No Docker, no Podman, no Kubernetes.

This is the fastest way to stand up a shared environment with IT’s
“safe” distro. The declarative NixOS blueprint is
**[server-nixos.md](server-nixos.md)** (Path B) for later.

------------------------------------------------------------------------

## 1. Install multi-user Nix

As an admin (sudo) on the Ubuntu 24.04 host:

``` bash
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install --determinate
```

This creates the `/nix` store, the `nix-daemon` systemd service, and the
`nixbld` build users — all shared across every account on the box.
Flakes are enabled by default.

Verify (open a fresh shell first):

``` bash
nix --version
nix run nixpkgs#hello
```

> Official installer alternative (if IT prefers upstream):
> `sh <(curl -L https://nixos.org/nix/install) --daemon`, then add
> `experimental-features = nix-command flakes` to `/etc/nix/nix.conf`
> and `sudo systemctl restart nix-daemon`.

------------------------------------------------------------------------

## 2. Choose a workspace model

**Option A — per-user clone (recommended to start).** Each student gets
a normal Linux account and their own writable `~/rsm-msba`. Simple,
isolated, and identical to the laptop workflow. The Nix store is shared,
so the heavy toolchain is built/downloaded **once** for the whole
machine; each student’s clone only adds their own uv Python env (~1–2
GB) under `~/rsm-msba/.rsm-msba`.

**Option B — shared read-only template + per-user state.** Place a
read-only template at `/srv/rsm-msba` (admin-owned) and have each
student keep only their coursework and `.rsm-msba` state in their home.
Lower duplication, more moving parts. Start with Option A unless disk is
tight.

------------------------------------------------------------------------

## 3. Provision student accounts

A minimal admin loop (adjust to your roster / SSO):

``` bash
# /usr/local/sbin/rsm-provision.sh  (run as root)
REPO=https://github.com/radiant-ai-hub/rsm-nix.git
while read -r user; do
  id "$user" &>/dev/null || adduser --disabled-password --gecos "" "$user"
  install -d -o "$user" -g "$user" "/home/$user"
  sudo -u "$user" -H git clone "$REPO" "/home/$user/rsm-msba" 2>/dev/null || true
done < students.txt
```

Add each student’s SSH public key to
`/home/<user>/.ssh/authorized_keys`.

> **Pre-warm the store** once as admin so the first student doesn’t
> wait: `nix develop /home/<any-user>/rsm-msba -c true` and
> `nix develop /home/<any-user>/rsm-msba#spark-hadoop -c true`.

------------------------------------------------------------------------

## 4. First-run per student

The quickest per-user path is the Linux installer — it installs/uses the
shared Nix, configures **direnv + nix-direnv** for the student’s login
shell (so VS Code Remote-SSH activates the env automatically), clones
the workspace, and runs `rsm-setup`:

``` bash
curl -fsSL https://raw.githubusercontent.com/radiant-ai-hub/rsm-nix/main/install/linux-install-rsm-nix.sh | bash
```

The manual equivalent, after SSH-ing in:

``` bash
cd ~/rsm-msba
nix develop          # or enable direnv (below)
rsm-setup            # builds their uv env, kernel, course folders
```

Enable direnv per account (optional, smoother for VS Code):

``` bash
nix profile install nixpkgs#direnv nixpkgs#nix-direnv
mkdir -p ~/.config/direnv
echo 'source ~/.nix-profile/share/nix-direnv/direnvrc' >> ~/.config/direnv/direnvrc
echo 'eval "$(direnv hook bash)"' >> ~/.bashrc
# then, once:
cd ~/rsm-msba && direnv allow
```

> Avoid server-wide dotfile edits. If you want students dropped into the
> env on login without per-user direnv, add a minimal, opt-in
> `/etc/profile.d/rsm-msba.sh` **only with IT approval** — but per-user
> direnv keeps the host clean and is preferred.

------------------------------------------------------------------------

## 5. VS Code Remote-SSH

Students install the **Remote - SSH** extension on their laptop VS Code,
add the server as an SSH host, connect, and **Open Folder →
`/home/<user>/rsm-msba`**. With the `mkhl.direnv` extension installed on
the remote, terminals and notebook kernels (`Python (RSM-MSBA)`)
activate automatically.

------------------------------------------------------------------------

## 6. PostgreSQL on a shared host

Each student’s PostgreSQL is **workspace-local** (data under
`~/rsm-msba/.rsm-msba/postgres`) and listens on `127.0.0.1:8765`. On a
single shared host the port would collide between simultaneous users.
Options:

- **Per-user port:** set `export PGPORT=<unique>` in the student’s
  `~/rsm-msba/.rsm-msba/zsh/local.zsh` (or shell rc) — the scripts honor
  `PGPORT`.
- **Socket-only:** students connect via the per-user socket directory
  (`rsm-pg-psql` already does), which never collides; only the TCP
  listener does. Skipping `pgweb` (or giving it a unique `--listen`
  port) avoids the clash entirely.

Document one convention for your cohort.

------------------------------------------------------------------------

## 7. Capacity & maintenance

- **Disk:** the shared `/nix/store` plus one uv env per student. Budget
  ~3–4 GB shared + ~1.5 GB/student. Run `nix store gc` periodically.
- **Updates:** `git -C /home/<user>/rsm-msba pull` then
  `rsm-python-sync` (can be scripted across accounts).
- **Binary cache:** the default `cache.nixos.org` covers everything
  here. For a large cohort consider a local cache/substituter to save
  bandwidth.

------------------------------------------------------------------------

## 8. Smoke test the server

As any provisioned user:

``` bash
cd ~/rsm-msba
nix flake check                         # builds/validates all outputs
nix develop -c bash tests/check-default.sh
nix develop -c bash tests/check-postgres.sh   # uses a unique PGPORT if shared
nix run .#check
```
