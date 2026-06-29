#!/usr/bin/env bash
# render-docs.sh — render the Quarto doc sources to GitHub-flavored markdown.
#
# Sources live here in docs/src/ (*.qmd + _includes/); the committed, student-
# facing .md are generated artifacts that land in docs/ (and README.md at the
# repo root). Run inside the dev shell from anywhere:
#
#     nix develop -c bash docs/src/render-docs.sh
#
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"   # docs/src
cd "$here"

guides=(
  readme.qmd
  readme-tech.qmd
  student-macos.qmd
  student-wsl2.qmd
  student-linux.qmd
  connect-server.qmd
  server-ubuntu-nix.qmd
  server-nixos.qmd
)

for g in "${guides[@]}"; do
  echo "rendering $g"
  quarto render "$g" --to gfm >/dev/null
done

# Place outputs: guides -> ../ (docs/), readme -> ../../README.md (repo root).
for g in student-macos student-wsl2 student-linux connect-server server-ubuntu-nix server-nixos; do
  mv -f "$g.md" "../$g.md"
done
mv -f readme.md ../../README.md
mv -f readme-tech.md ../../README-tech.md

echo "rendered: ${guides[*]}"
echo "  -> docs/*.md, README.md, README-tech.md"
