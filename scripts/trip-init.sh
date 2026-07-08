#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONTENT_ROOT="${ROOT_DIR}/hugo/content/reiseblog"

TITLE=""
SLUG=""
DATE=""
SUMMARY=""
FORCE=0

usage() {
  cat <<'EOF'
Usage:
  ./scripts/trip-init.sh --title "Alpen 2026" --slug alpen-2026 --date 2026-07-08 [--summary "..."] [--force]

Creates a new trip page bundle:
- hugo/content/reiseblog/<slug>/index.md
- hugo/content/reiseblog/<slug>/route.geojson
- hugo/content/reiseblog/<slug>/route.gpx
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --title)
      TITLE="$2"
      shift 2
      ;;
    --slug)
      SLUG="$2"
      shift 2
      ;;
    --date)
      DATE="$2"
      shift 2
      ;;
    --summary)
      SUMMARY="$2"
      shift 2
      ;;
    --force)
      FORCE=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage
      exit 1
      ;;
  esac
done

if [[ -z "$TITLE" || -z "$SLUG" || -z "$DATE" ]]; then
  echo "Error: --title, --slug and --date are required." >&2
  usage
  exit 1
fi

if [[ ! "$DATE" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
  echo "Error: --date must be in YYYY-MM-DD format." >&2
  exit 1
fi

DEST_DIR="${CONTENT_ROOT}/${SLUG}"
if [[ -e "$DEST_DIR" ]]; then
  if [[ "$FORCE" -eq 1 ]]; then
    rm -rf "$DEST_DIR"
  else
    echo "Error: destination already exists: $DEST_DIR" >&2
    echo "Use --force to overwrite." >&2
    exit 1
  fi
fi

mkdir -p "$DEST_DIR"

if [[ -z "$SUMMARY" ]]; then
  SUMMARY="Roadtrip"
fi

cat > "${DEST_DIR}/index.md" <<EOF
---
title: "${TITLE}"
date: ${DATE}
slug: "${SLUG}"
summary: "${SUMMARY}"
---

## Überblick

${TITLE} startet am ${DATE}.

{{< tripmap geojson="route.geojson" gpx="route.gpx" lang="de" >}}

## Etappen
EOF

cat > "${DEST_DIR}/route.geojson" <<'EOF'
{
  "type": "FeatureCollection",
  "features": []
}
EOF

cat > "${DEST_DIR}/route.gpx" <<'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<gpx version="1.1" creator="trip-init.sh" xmlns="http://www.topografix.com/GPX/1/1">
  <trk>
    <name>Reiseroute</name>
  </trk>
</gpx>
EOF

echo "Created ${DEST_DIR}/index.md"
echo "Created ${DEST_DIR}/route.geojson"
echo "Created ${DEST_DIR}/route.gpx"
