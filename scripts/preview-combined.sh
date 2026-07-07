#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
HUGO_OUT="${ROOT_DIR}/.hugo-public-test"
SITE_OUT="${ROOT_DIR}/.site-test"
PORT="${1:-4173}"

cd "${ROOT_DIR}"

echo "[1/3] Hugo build -> ${HUGO_OUT}"
hugo --source hugo --destination "${HUGO_OUT}" --minify

echo "[2/3] Merge legacy + hugo -> ${SITE_OUT}"
rm -rf "${SITE_OUT}"
mkdir -p "${SITE_OUT}"
rsync -a ./ "${SITE_OUT}/" \
  --exclude .git/ \
  --exclude .github/ \
  --exclude hugo/ \
  --exclude .site-test/ \
  --exclude .hugo-public-test/
rsync -a "${HUGO_OUT}/" "${SITE_OUT}/"

echo "[3/3] Serve ${SITE_OUT} on http://localhost:${PORT}/"
cd "${SITE_OUT}"
python3 -m http.server "${PORT}"
