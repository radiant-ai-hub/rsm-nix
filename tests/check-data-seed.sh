#!/usr/bin/env bash
# check-data-seed.sh
#
# Tests rsm_seed_dir (defined in bin/rsm-env.sh), which rsm-setup uses to drop
# the flake's data/ folder into the workspace: it must ADD missing files but
# NEVER overwrite files the student already has. Pure bash + coreutils, so it
# runs anywhere (no nix dev shell needed):
#   bash tests/check-data-seed.sh
set -euo pipefail

HERE="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck disable=SC1091
source "$HERE/bin/rsm-env.sh"    # provides rsm_seed_dir

fail=0
ok()  { printf '  \033[32mok\033[0m   %s\n' "$1"; }
bad() { printf '  \033[31mFAIL\033[0m %s\n' "$1"; fail=1; }
eq()  { [ "$(cat "$1" 2>/dev/null)" = "$2" ]; }

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
src="$tmp/flake-data"
dst="$tmp/ws-data"
mkdir -p "$src/sub"
printf 'flake-sales\n'  > "$src/sales.csv"
printf 'flake-readme\n' > "$src/README.md"
printf 'nested\n'       > "$src/sub/extra.csv"

echo "== 1) fresh seed copies everything (incl. nested) =="
rsm_seed_dir "$src" "$dst"
eq "$dst/sales.csv" "flake-sales"   && ok "sales.csv seeded"     || bad "sales.csv not seeded"
eq "$dst/sub/extra.csv" "nested"    && ok "nested file seeded"   || bad "nested file not seeded"

echo "== 2) re-run NEVER clobbers the student's files =="
printf 'MY-OWN-EDIT\n' > "$dst/sales.csv"    # student edited a seeded file
printf 'my-notes\n'    > "$dst/mydata.csv"   # student added their own file
rsm_seed_dir "$src" "$dst"
eq "$dst/sales.csv" "MY-OWN-EDIT"   && ok "student edit to sales.csv preserved" || bad "student edit CLOBBERED"
eq "$dst/mydata.csv" "my-notes"     && ok "student's own file preserved"        || bad "student file lost"

echo "== 3) a newly-shipped flake file appears on re-run =="
printf 'brand-new\n' > "$src/newset.csv"
rsm_seed_dir "$src" "$dst"
eq "$dst/newset.csv" "brand-new"    && ok "new flake file added"        || bad "new flake file not added"
eq "$dst/sales.csv" "MY-OWN-EDIT"   && ok "student edit STILL preserved" || bad "student edit clobbered on re-run"

echo "== 4) a missing source folder is a harmless no-op =="
if rsm_seed_dir "$tmp/does-not-exist" "$dst"; then ok "missing source returns success"; else bad "missing source errored"; fi

[ "$fail" -eq 0 ] && echo "data-seed check passed." || { echo "data-seed check FAILED." >&2; exit 1; }
