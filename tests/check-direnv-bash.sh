# check-direnv-bash.sh
#
# Verifies the macOS fix for nix-direnv's "minimum required bash version is 4.4"
# warning. On macOS the nix `direnv` normally uses its baked nix bash, but if that
# store path is garbage-collected it falls back to /bin/bash 3.2. The macOS installer
# installs a GC-safe nix bash and points DIRENV_BASH at it; direnv honors DIRENV_BASH,
# so `use flake` always gets a modern bash. Run in the dev shell:
#   nix develop -c bash tests/check-direnv-bash.sh
set -uo pipefail

fail=0
ok()  { printf '  \033[32mok\033[0m   %s\n' "$1"; }
bad() { printf '  \033[31mFAIL\033[0m %s\n' "$1"; fail=1; }

INST="${RSM_FLAKE:-$HOME/rsm-nix}/install/macos-arm-install-rsm-nix.sh"
[ -f "$INST" ] || INST="install/macos-arm-install-rsm-nix.sh"

echo "== installer wires the DIRENV_BASH fix (all platforms) =="
grep -Fq 'export DIRENV_BASH="$HOME/.nix-profile/bin/bash"' "$INST" \
  && ok "installer sets DIRENV_BASH to the nix bash" || bad "installer missing the DIRENV_BASH export"
grep -Eq 'nix profile .*nixpkgs#bash' "$INST" \
  && ok "installer installs nixpkgs#bash (GC-safe)" || bad "installer does not install nixpkgs#bash"

if [ "$(uname -s)" != "Darwin" ]; then
  echo "== direnv/DIRENV_BASH integration: skipped (not macOS) =="
  [ "$fail" -eq 0 ] && { echo "direnv-bash check passed (static only)."; exit 0; }
  echo "direnv-bash check FAILED." >&2; exit 1
fi

echo "== macOS: direnv honors DIRENV_BASH (the fix) =="
nix profile install nixpkgs#direnv nixpkgs#bash >/dev/null 2>&1 \
  || nix profile add nixpkgs#direnv nixpkgs#bash >/dev/null 2>&1 || true
D="$HOME/.nix-profile/bin/direnv"; NB="$HOME/.nix-profile/bin/bash"
if [ ! -x "$D" ] || [ ! -x "$NB" ]; then
  echo "  (could not provision nix direnv/bash; skipping the integration assertions)"
  [ "$fail" -eq 0 ] && { echo "direnv-bash check passed (static only; provision skipped)."; exit 0; }
  echo "direnv-bash check FAILED." >&2; exit 1
fi

# canonical temp dir so direnv's allow (/var/...) and exec (/private/var/...) agree
d="$(cd "$(mktemp -d)" && pwd -P)"
printf 'printf "%%s" "${BASH_VERSION:-NObash}" > "%s/bv"\n' "$d" > "$d/.envrc"
"$D" allow "$d/.envrc" >/dev/null 2>&1
probe() { rm -f "$d/bv"; "$D" exec "$d" true >/dev/null 2>&1 || true; cat "$d/bv" 2>/dev/null || true; }
major() { printf '%s' "${1%%.*}"; }

f="$(DIRENV_BASH="$NB" probe)"
if [ -n "$f" ] && [ "$(major "$f")" -ge 4 ] 2>/dev/null; then
  ok "DIRENV_BASH=nix bash -> direnv uses bash $f (>= 4.4, no warning)"
else
  bad "DIRENV_BASH=nix bash did not give bash >= 4.4 (got [$f])"
fi
# mutation sanity: forcing the old bash proves DIRENV_BASH is what controls it
o="$(DIRENV_BASH=/bin/bash probe)"
if [ -n "$o" ] && [ "$(major "$o")" -lt 4 ] 2>/dev/null; then
  ok "DIRENV_BASH=/bin/bash -> bash $o (confirms DIRENV_BASH controls direnv's bash)"
else
  bad "DIRENV_BASH override not effective (got [$o])"
fi

rm -rf "$d"
[ "$fail" -eq 0 ] && echo "direnv-bash check passed." || { echo "direnv-bash check FAILED." >&2; exit 1; }
