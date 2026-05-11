#!/usr/bin/env bash
# build_pagefind.sh — build the Pagefind index over the rendered site.
#
# Must run AFTER `quarto render` (which produces _site/) and BEFORE
# publishing _site/ to the gh-pages branch.
#
# Usage: scripts/build_pagefind.sh

set -euo pipefail

SITE_DIR="${SITE_DIR:-_site}"

if [ ! -d "$SITE_DIR" ]; then
  echo "::error::$SITE_DIR not found. Run 'quarto render' first."
  exit 1
fi

# Pagefind needs to walk the rendered HTML and emit pagefind/* assets
# back into the site dir so they ship with the deploy.
npx --yes pagefind@1 --site "$SITE_DIR" --output-subdir pagefind

ls -la "$SITE_DIR/pagefind" >/dev/null
echo "Pagefind index built at $SITE_DIR/pagefind/"
