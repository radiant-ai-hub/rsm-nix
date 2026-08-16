# check-rsm-ssh-readonly.sh
#
# Verifies the read-only / nix-managed guard: rsm-ssh-setup writes the managed
# 'Host sc2' block when ~/.ssh/config is writable, and SKIPS it (no error, no
# clobber) when the config is read-only -- the NixOS / home-manager case. The same
# _managed_ro guard protects rsm-github's `git config --global` writes. Run in the
# dev shell (rsm-ssh-setup on PATH):
#   nix develop -c bash tests/check-rsm-ssh-readonly.sh
set -uo pipefail

fail=0
ok()  { printf '  \033[32mok\033[0m   %s\n' "$1"; }
bad() { printf '  \033[31mFAIL\033[0m %s\n' "$1"; fail=1; }

command -v rsm-ssh-setup >/dev/null 2>&1 || { echo "rsm-ssh-setup not on PATH (run inside the dev shell)"; exit 1; }

echo "== writable config: writes the managed 'Host sc2' block =="
h1="$(mktemp -d)"; mkdir -p "$h1/.ssh"
: > "$h1/.ssh/id_ed25519"; : > "$h1/.ssh/id_ed25519.pub"   # pre-place key so keygen is skipped (offline)
out1="$(HOME="$h1" RSM_SSH_USER=teststu rsm-ssh-setup 2>&1)"
grep -q '^Host sc2' "$h1/.ssh/config" 2>/dev/null && ok "wrote Host sc2 when writable" || bad "did not write Host sc2 (out: $out1)"
grep -q 'User teststu' "$h1/.ssh/config" 2>/dev/null && ok "wrote the derived User" || bad "User line missing"

echo "== read-only config: skips, does not error, does not clobber =="
h2="$(mktemp -d)"; mkdir -p "$h2/.ssh"
: > "$h2/.ssh/id_ed25519"; : > "$h2/.ssh/id_ed25519.pub"
printf 'Host keep-me\n  HostName example.org\n' > "$h2/.ssh/config"
chmod 0444 "$h2/.ssh/config"   # simulate a read-only (nix-managed) config file
if out2="$(HOME="$h2" RSM_SSH_USER=teststu rsm-ssh-setup 2>&1)"; then rc=0; else rc=$?; fi
[ "${rc:-0}" -eq 0 ] && ok "did not error on a read-only config" || bad "errored (rc=$rc): $out2"
printf '%s' "$out2" | grep -qiE 'read-only|managed' && ok "reported the managed config" || bad "no managed-config notice"
{ grep -q 'HostName example.org' "$h2/.ssh/config" && ! grep -q 'Host sc2' "$h2/.ssh/config"; } \
  && ok "left the read-only config untouched" || bad "modified the read-only config"

chmod 0644 "$h2/.ssh/config" 2>/dev/null || true
rm -rf "$h1" "$h2"
[ "$fail" -eq 0 ] && echo "rsm-ssh-readonly check passed." || { echo "rsm-ssh-readonly check FAILED." >&2; exit 1; }
