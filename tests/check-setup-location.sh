#!/usr/bin/env bash
set -euo pipefail

: "${RSM_FLAKE:?Run inside the RSM dev shell}"
log="$(mktemp)"
trap 'rm -f -- "$log"' EXIT
if RSM_WORKSPACE="$RSM_FLAKE" RSM_SKIP_FLAKE_UPDATE=1 rsm-setup > "$log" 2>&1; then
  echo 'rsm-setup accepted a workspace inside its source flake' >&2
  exit 1
fi
if ! grep -q 'RSM_WORKSPACE must be outside RSM_FLAKE' "$log"; then
  cat "$log" >&2
  exit 1
fi
test -f "$RSM_FLAKE/examples/README.md"
echo 'rsm-setup rejects a workspace inside its source flake.'
