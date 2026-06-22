# check-no-host-mutation.sh
#
# Verifies the flake never writes RSM config into host home dotfiles. Run it
# before and after rsm-setup / a dev-shell session; the dotfile baseline is
# stored under $RSMBASE/logs and compared on subsequent runs.
#   nix develop -c bash tests/check-no-host-mutation.sh

set -euo pipefail

: "${RSM_WORKSPACE:=$PWD}"
: "${RSMBASE:=$RSM_WORKSPACE/.rsm-msba}"

fail=0
ok()  { printf '  \033[32mok\033[0m   %s\n' "$1"; }
bad() { printf '  \033[31mFAIL\033[0m %s\n' "$1"; fail=1; }

echo "== rsm-podman paths must be absent =="
for p in "$HOME/.config/rsm-podman" "$HOME/.local/state/rsm-podman"; do
  if [ -e "$p" ]; then bad "exists: $p"; else ok "absent: $p"; fi
done

echo "== state dir is workspace-local =="
case "$RSMBASE" in
  "$RSM_WORKSPACE"/*) ok "RSMBASE=$RSMBASE";;
  *) bad "RSMBASE not under workspace: $RSMBASE";;
esac

echo "== host dotfiles unchanged across runs =="
mkdir -p "$RSMBASE/logs"
baseline="$RSMBASE/logs/dotfile-baseline.txt"
hash_cmd() { if command -v sha256sum >/dev/null 2>&1; then sha256sum "$@"; else shasum -a 256 "$@"; fi; }
current="$(mktemp)"
for f in "$HOME/.zshrc" "$HOME/.bashrc" "$HOME/.profile" "$HOME/.zprofile"; do
  if [ -f "$f" ]; then hash_cmd "$f"; else echo "absent  $f"; fi
done > "$current"

if [ -f "$baseline" ]; then
  if diff -u "$baseline" "$current" >/dev/null; then
    ok "no changes since baseline"
  else
    bad "host dotfiles changed since baseline:"
    diff -u "$baseline" "$current" || true
  fi
else
  cp "$current" "$baseline"
  ok "recorded baseline ($baseline) — re-run after rsm-setup to verify"
fi
rm -f "$current"

[ "$fail" -eq 0 ] && echo "No host mutation detected." || { echo "Host mutation check FAILED." >&2; exit 1; }
