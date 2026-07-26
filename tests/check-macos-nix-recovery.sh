#!/usr/bin/env bash
# check-macos-nix-recovery.sh
#
# Guards the half-created "Nix Store" APFS volume recovery in the macOS
# installer (install/macos-arm-install-rsm-nix.sh). The Determinate installer
# sometimes creates the encrypted Nix Store volume but can't mount it at /nix,
# aborts, and leaves the volume + /etc/synthetic.conf + /etc/fstab entries
# behind so every re-run fails identically. The installer must:
#   * decide skip / cleanup / install correctly (nix_install_state),
#   * NEVER delete a volume without an explicit yes (prompt_yes_no),
#   * when confirmed, delete ONLY the Nix Store volume and strip ONLY the /nix
#     lines from synthetic.conf/fstab (leave unrelated 'nix' paths alone),
#   * then tell the student to restart and re-run (no auto-reboot).
#
# All of macOS's tools (diskutil/security/sudo/mount) are shimmed on PATH, so
# this runs on plain Linux CI -- no APFS, no root. Pure bash:
#   bash tests/check-macos-nix-recovery.sh
set -uo pipefail

HERE="$(cd "$(dirname "$0")/.." && pwd)"
SCRIPT="$HERE/install/macos-arm-install-rsm-nix.sh"

fail=0
ok()  { printf '  \033[32mok\033[0m   %s\n' "$1"; }
bad() { printf '  \033[31mFAIL\033[0m %s\n' "$1"; fail=1; }

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

# --- fake macOS tools on PATH ----------------------------------------------
# Every call is appended to $RSM_FAKE_LOG so we can assert exactly what ran.
export RSM_FAKE_LOG="$tmp/calls.log"
: > "$RSM_FAKE_LOG"
bindir="$tmp/bin"
mkdir -p "$bindir"

cat > "$bindir/diskutil" <<'SH'
#!/bin/sh
printf 'diskutil %s\n' "$*" >> "$RSM_FAKE_LOG"
if [ "$1" = "info" ]; then
  printf '   Device Identifier:         %s\n' "${RSM_FAKE_VOL:-disk9s9}"
  exit 0
fi
if [ "$1" = "apfs" ] && [ "$2" = "deleteVolume" ]; then
  printf 'DELETEVOLUME %s\n' "$3" >> "$RSM_FAKE_LOG"
  exit 0
fi
exit 0
SH

cat > "$bindir/security" <<'SH'
#!/bin/sh
printf 'security %s\n' "$*" >> "$RSM_FAKE_LOG"
exit 0
SH

# Transparent sudo: record it, then run the rest (so `sudo cp`, `sudo diskutil`
# etc. actually execute against our fixtures / fakes).
cat > "$bindir/sudo" <<'SH'
#!/bin/sh
printf 'sudo %s\n' "$*" >> "$RSM_FAKE_LOG"
exec "$@"
SH

chmod +x "$bindir/diskutil" "$bindir/security" "$bindir/sudo"
export PATH="$bindir:$PATH"

# Source the installer's functions without running it.
export RSM_INSTALLER_NOEXEC=1
# shellcheck disable=SC1090
source "$SCRIPT"
set +e   # source turned on `set -e`; assertions below manage their own status

# ---------------------------------------------------------------------------
echo "== nix_install_state decides skip / cleanup / install =="
[ "$(nix_install_state 1 0 0)" = "skip" ]    && ok "nix present => skip"            || bad "nix present should skip"
[ "$(nix_install_state 1 1 0)" = "skip" ]    && ok "nix present wins over volume"   || bad "nix present should still skip"
[ "$(nix_install_state 0 1 0)" = "cleanup" ] && ok "volume + not mounted => cleanup" || bad "half-created should be cleanup"
[ "$(nix_install_state 0 1 1)" = "install" ] && ok "volume mounted => install"       || bad "mounted volume is not stale"
[ "$(nix_install_state 0 0 0)" = "install" ] && ok "clean slate => install"          || bad "clean slate should install"

echo "== is_yes matches only y / yes (case-insensitive) =="
for a in y Y yes YES Yes; do is_yes "$a" && ok "'$a' is yes" || bad "'$a' should be yes"; done
for a in n N no "" maybe yep; do is_yes "$a" && bad "'$a' should NOT be yes" || ok "'$a' is not yes"; done

echo "== strip_lines_privileged removes ONLY the /nix lines =="
syn="$tmp/synthetic.conf"
printf 'nix\napp\t/opt/myapp\ncache\t/data/nixcache\nnixpkgs\n' > "$syn"
strip_lines_privileged '^nix([[:space:]].*)?$' "$syn"
grep -q '^nix$'         "$syn" && bad "did not remove the 'nix' firmlink line"    || ok "removed the 'nix' firmlink line"
grep -q '/data/nixcache' "$syn" && ok "kept /data/nixcache (unrelated)"            || bad "wrongly removed /data/nixcache"
grep -q '^nixpkgs$'      "$syn" && ok "kept 'nixpkgs' (not the firmlink)"          || bad "wrongly removed 'nixpkgs'"
grep -q '/opt/myapp'     "$syn" && ok "kept unrelated app line"                    || bad "wrongly removed the app line"

fst="$tmp/fstab"
printf 'LABEL=Nix\\040Store /nix apfs rw,nobrowse\nUUID=1 /data apfs rw\nLABEL=X /opt/nixthing hfs rw\n' > "$fst"
strip_lines_privileged '(^|[[:space:]])/nix[[:space:]]+apfs' "$fst"
grep -q ' /nix apfs'   "$fst" && bad "did not remove the /nix apfs fstab entry"    || ok "removed the /nix apfs fstab entry"
grep -q ' /data apfs'  "$fst" && ok "kept the /data apfs entry"                    || bad "wrongly removed /data apfs"
grep -q '/opt/nixthing' "$fst" && ok "kept /opt/nixthing (not the /nix mount)"     || bad "wrongly removed /opt/nixthing"

echo "== remove_stale_nix_volume deletes the volume + clears config + keychain =="
# The fixtures MUST contain unrelated 'nix'-ish lines so that a too-broad
# pattern (the naive '/nix/d') is caught here, exercising the REAL patterns
# baked into remove_stale_nix_volume (not a pattern the test supplies).
: > "$RSM_FAKE_LOG"
export RSM_SYNTHETIC_CONF="$tmp/rm-synthetic.conf" RSM_FSTAB="$tmp/rm-fstab"
printf 'nix\napp\t/opt/myapp\ncache\t/data/nixcache\nnixpkgs\n' > "$RSM_SYNTHETIC_CONF"
printf 'LABEL=Nix\\040Store /nix apfs rw,nobrowse\nUUID=1 /data apfs rw\nLABEL=X /opt/nixthing hfs rw\n' > "$RSM_FSTAB"
remove_stale_nix_volume "disk3s7" >/dev/null 2>&1
grep -q '^DELETEVOLUME disk3s7$'                "$RSM_FAKE_LOG" && ok "deleted volume disk3s7"        || bad "did not delete disk3s7"
grep -q 'security delete-generic-password.*Nix Store' "$RSM_FAKE_LOG" && ok "cleared the keychain item" || bad "did not clear keychain"
grep -q '^nix$'          "$RSM_SYNTHETIC_CONF" && bad "synthetic.conf still has the nix firmlink" || ok "cleared the synthetic.conf nix line"
grep -q '/data/nixcache' "$RSM_SYNTHETIC_CONF" && ok "kept /data/nixcache in synthetic.conf"      || bad "wrongly removed /data/nixcache"
grep -q '^nixpkgs$'      "$RSM_SYNTHETIC_CONF" && ok "kept nixpkgs in synthetic.conf"              || bad "wrongly removed nixpkgs"
grep -q ' /nix apfs'    "$RSM_FSTAB" && bad "fstab still has the /nix apfs entry"                  || ok "cleared the fstab /nix apfs entry"
grep -q ' /data apfs'   "$RSM_FSTAB" && ok "kept the /data apfs entry in fstab"                    || bad "wrongly removed /data apfs"
grep -q '/opt/nixthing' "$RSM_FSTAB" && ok "kept /opt/nixthing in fstab"                           || bad "wrongly removed /opt/nixthing"

# ---------------------------------------------------------------------------
# handle_stale_nix_volume exits 1 (a restart is required), so run it in a
# subshell to capture output + exit code without ending this test.
echo "== declined (answer=n) => NO deleteVolume, restart guidance, exit 1 =="
: > "$RSM_FAKE_LOG"
out="$( RSM_ASSUME_ANSWER=n handle_stale_nix_volume "disk4s2" 2>&1 )"; rc=$?
[ "$rc" -ne 0 ]                                  && ok "exited non-zero"            || bad "should exit non-zero when declined"
grep -q 'DELETEVOLUME' "$RSM_FAKE_LOG"           && bad "deleted WITHOUT confirmation!" || ok "no volume deleted without a yes"
printf '%s' "$out" | grep -q 'deleteVolume disk4s2' && ok "showed manual removal command" || bad "no manual guidance shown"

echo "== confirmed (answer=y) => deletes, then restart guidance, exit 1 =="
: > "$RSM_FAKE_LOG"
out="$( RSM_ASSUME_ANSWER=y handle_stale_nix_volume "disk4s2" 2>&1 )"; rc=$?
[ "$rc" -ne 0 ]                                  && ok "exited non-zero (restart needed)" || bad "should exit non-zero after cleanup"
grep -q '^DELETEVOLUME disk4s2$' "$RSM_FAKE_LOG" && ok "deleted the volume after yes"     || bad "did not delete after yes"
printf '%s' "$out" | grep -qi 'restart your Mac' && ok "told the student to restart"       || bad "missing restart instructions"
printf '%s' "$out" | grep -qi 'Restart-Computer\|reboot now\|shutdown' && bad "looks like an auto-reboot" || ok "does not auto-reboot"

# ---------------------------------------------------------------------------
echo "== install_nix survives 'diskutil info' failing under set -e -o pipefail =="
# When there is no Nix Store volume, real diskutil exits non-zero. Under the
# script's `set -e -o pipefail` a piped substitution would abort the whole
# installer (regression seen on the macOS runner). Reproduce it here: a fake
# diskutil that fails for `info`, install_nix driven with errexit+pipefail on.
nvbin="$tmp/novol_bin"; mkdir -p "$nvbin"
cat > "$nvbin/diskutil" <<'SH'
#!/bin/sh
[ "$1" = "info" ] && exit 1   # no 'Nix Store' volume
exit 0
SH
chmod +x "$nvbin/diskutil"
(
  set -euo pipefail
  export PATH="$nvbin:$PATH"
  DRY_RUN=1; SIMULATE_BROKEN_NIX_VOLUME=0
  install_nix
) > "$tmp/novol.out" 2>&1
rc=$?
[ "$rc" -eq 0 ] && ok "install_nix completed (no abort on diskutil failure)" \
               || bad "install_nix aborted under set -e/pipefail (rc=$rc): $(cat "$tmp/novol.out")"

# The full-script end-to-end (arg parse -> main -> install_nix) can't run on
# Linux CI because ensure_supported_system gates on macOS; the macOS CI job
# runs it. Here we drive install_nix directly in simulate + dry-run mode, which
# is the same code path the flag reaches.
echo "== simulate + dry-run proposes cleanup + restart, deletes nothing =="
: > "$RSM_FAKE_LOG"
DRY_RUN=1; SIMULATE_BROKEN_NIX_VOLUME=1
out="$( install_nix 2>&1 )"; rc=$?
DRY_RUN=0; SIMULATE_BROKEN_NIX_VOLUME=0
[ "$rc" -eq 0 ]                                  && ok "dry-run completed (exit 0)"    || bad "dry-run should not fail"
printf '%s' "$out" | grep -q 'Nix Store'         && ok "mentions the Nix Store volume" || bad "did not mention the stale volume"
printf '%s' "$out" | grep -qi 'restart your Mac' && ok "dry-run shows restart guidance" || bad "dry-run missing restart guidance"
grep -q 'DELETEVOLUME' "$RSM_FAKE_LOG"           && bad "dry-run actually deleted!"     || ok "dry-run changed nothing"

[ "$fail" -eq 0 ] && echo "macos-nix-recovery check passed." || { echo "macos-nix-recovery check FAILED." >&2; exit 1; }
