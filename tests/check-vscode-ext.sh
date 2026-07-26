#!/usr/bin/env bash
# check-vscode-ext.sh
#
# Guards bin/rsm-vscode-ext's CLI discovery + install loop -- specifically the
# fix that lets extensions sync on a SERVER from a plain SSH shell (no `code` on
# PATH) via the bundled headless ~/.vscode-server code-server. Requirements:
#   * with no `code` on PATH, picks the NEWEST bundled code-server and installs
#     only the MISSING extensions into it (idempotent on re-run)
#   * $RSM_CODE_BIN overrides discovery
#   * with nothing found, exits non-zero and prints a "connect once" hint
#   * must not abort under `set -e -o pipefail` when the vscode-server globs
#     don't match (the ls|head trap)
# All VS Code CLIs are faked; runs on plain Linux CI. Pure bash:
#   bash tests/check-vscode-ext.sh
set -uo pipefail

HERE="$(cd "$(dirname "$0")/.." && pwd)"
SCRIPT="$HERE/bin/rsm-vscode-ext"

fail=0
ok()  { printf '  \033[32mok\033[0m   %s\n' "$1"; }
bad() { printf '  \033[31mFAIL\033[0m %s\n' "$1"; fail=1; }

tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' EXIT

# A flake with a curated extensions list.
flake="$tmp/flake"; mkdir -p "$flake/vscode"
printf 'ms-python.python\nms-toolsai.jupyter\nquarto.quarto\n' > "$flake/vscode/extensions.txt"

# A fake code-server / code: records install calls; reports ms-python.python as
# already installed so the loop must install the OTHER two (and nothing on re-run
# once RSM_FAKE_ALL=1 makes it report all three present).
make_fake_code() {
  cat > "$1" <<'SH'
#!/bin/sh
printf '%s %s\n' "$(basename "$0")=$0" "$*" >> "$RSM_FAKE_LOG"
case "$1" in
  --list-extensions)
    echo ms-python.python
    if [ -n "${RSM_FAKE_ALL:-}" ]; then echo ms-toolsai.jupyter; echo quarto.quarto; fi
    ;;
  --install-extension)
    echo "INSTALL $2" >> "$RSM_FAKE_LOG"
    ;;
esac
exit 0
SH
  chmod +x "$1"
}

export RSM_FLAKE="$flake"

# Give ONLY the rsm-vscode-ext subprocess a PATH that has the coreutils it needs
# but NO `code`, so CLI discovery falls through to the bundled code-server. (Do
# not touch this harness's own PATH -- on NixOS coreutils live in the store.)
nocodebin="$tmp/nocodebin"; mkdir -p "$nocodebin"
for t in bash ls head tr grep basename cat; do
  p="$(command -v "$t" 2>/dev/null)" && ln -sf "$p" "$nocodebin/$t"
done

run_ext() {  # HOME=<home> [extra env] run_ext ; captures stdout+stderr, sets $out/$rc
  out="$(env -i PATH="$nocodebin" RSM_FLAKE="$flake" "$@" \
         bash -o errexit -o nounset -o pipefail "$SCRIPT" 2>&1)"; rc=$?
}

# ---- server case: newest bundled code-server, install only what's missing ----
echo "== plain server shell: uses newest ~/.vscode-server code-server, installs missing =="
home="$tmp/home"; log="$tmp/calls.log"; : > "$log"
oldcs="$home/.vscode-server/bin/OLDHASH/bin/code-server"
newcs="$home/.vscode-server/cli/servers/Stable-NEWHASH/server/bin/code-server"
mkdir -p "$(dirname "$oldcs")" "$(dirname "$newcs")"
make_fake_code "$oldcs"; make_fake_code "$newcs"
touch -d '2020-01-01T00:00:00' "$oldcs"       # older
touch -d '2024-01-01T00:00:00' "$newcs"       # newer -> must be chosen
run_ext HOME="$home" RSM_FAKE_LOG="$log"
[ "$rc" -eq 0 ] && ok "exited 0 (no abort under set -e/pipefail)" || bad "aborted/failed (rc=$rc): $out"
printf '%s' "$out" | grep -q 'Stable-NEWHASH' && ok "selected the NEWEST code-server" || bad "did not pick newest: $out"
grep -q '^INSTALL ms-toolsai.jupyter$' "$log" && ok "installed the missing jupyter"  || bad "did not install jupyter"
grep -q '^INSTALL quarto.quarto$'      "$log" && ok "installed the missing quarto"   || bad "did not install quarto"
grep -q '^INSTALL ms-python.python$'   "$log" && bad "reinstalled an already-present ext" || ok "skipped the already-present python"
grep -q 'OLDHASH' "$log" && bad "used the OLD code-server" || ok "did not touch the old code-server"

echo "== idempotent: when all are present, installs nothing =="
: > "$log"
run_ext HOME="$home" RSM_FAKE_LOG="$log" RSM_FAKE_ALL=1
[ "$rc" -eq 0 ] && ok "exited 0" || bad "failed on re-run (rc=$rc)"
grep -q '^INSTALL ' "$log" && bad "installed something when all present" || ok "no installs when all present"

# ---- RSM_CODE_BIN override wins ----
echo "== RSM_CODE_BIN overrides discovery =="
: > "$log"
override="$tmp/override-code"; make_fake_code "$override"
run_ext HOME="$home" RSM_FAKE_LOG="$log" RSM_CODE_BIN="$override" RSM_FAKE_ALL=1
printf '%s' "$out" | grep -qF "$override" && ok "used RSM_CODE_BIN" || bad "ignored RSM_CODE_BIN: $out"

# ---- nothing found: exits non-zero with a helpful hint ----
echo "== no code + no ~/.vscode-server: exits non-zero with a connect-once hint =="
empty="$tmp/emptyhome"; mkdir -p "$empty"
run_ext HOME="$empty" RSM_FAKE_LOG="$tmp/unused.log"
[ "$rc" -ne 0 ] && ok "exited non-zero when nothing is available" || bad "should fail when no CLI found"
printf '%s' "$out" | grep -qi 'connect to this machine once' && ok "printed the connect-once hint" || bad "missing hint: $out"

[ "$fail" -eq 0 ] && echo "vscode-ext check passed." || { echo "vscode-ext check FAILED." >&2; exit 1; }
