#!/usr/bin/env bash
# install-nix.sh — install Nix for the RSM-MSBA computing environment.
#
# Uses the Determinate Systems installer (flakes enabled by default). Works on
# macOS (Apple Silicon / Intel) and Linux. Run it once:
#
#     bash ~/install-nix.sh
#
# It will prompt for your SUDO PASSWORD — multi-user Nix needs root to create
# the /nix store and the background daemon. Nothing else here needs sudo.
set -euo pipefail

profile_script=/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh

# Already fully installed and on PATH?
if command -v nix >/dev/null 2>&1; then
  echo "Nix is already installed: $(nix --version)"
  exit 0
fi

# Installed previously but not yet loaded into this shell?
if [ -e /nix/var/nix/profiles/default/bin/nix ]; then
  echo "Nix is installed but not active in this shell."
  echo "Open a NEW terminal, or run:"
  echo "  . $profile_script"
  exit 0
fi

echo "==> Installing Nix via the Determinate Systems installer"
echo "    (you will be prompted for your sudo password)"
echo

curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix \
  | sh -s -- install --no-confirm

# Load Nix into THIS shell so we can verify right away.
if [ -e "$profile_script" ]; then
  # shellcheck disable=SC1090
  . "$profile_script"
fi

echo
if command -v nix >/dev/null 2>&1; then
  echo "==> Nix installed: $(nix --version)"
else
  echo "==> Nix installed."
fi
echo "Open a NEW terminal (so 'nix' is on your PATH) before the next steps."
echo "Then tell Claude it's done, and the build + tests will run over SSH."
