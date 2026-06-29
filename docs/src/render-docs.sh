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

# Normalize the generated markdown with prettier so the committed files match
# what the prettier VS Code extension produces on save (consistent code fences,
# list markers, thematic breaks, no leading blank lines). Prettier's default
# config preserves prose wrapping, so the Quarto line-wrapping is left intact.
# Only the rendered .md are formatted — never the .qmd sources (prettier would
# mangle Quarto shortcodes like {{< include >}}).
if command -v prettier >/dev/null 2>&1; then
  prettier --log-level warn --write \
    ../../README.md ../../README-tech.md ../*.md >/dev/null
  echo "prettier: normalized README.md, README-tech.md, docs/*.md"
else
  echo "prettier not found; skipping markdown normalization" >&2
fi

echo "rendered: ${guides[*]}"
echo "  -> docs/*.md, README.md, README-tech.md"
