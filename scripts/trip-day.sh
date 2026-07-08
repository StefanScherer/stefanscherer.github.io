#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONTENT_ROOT="${ROOT_DIR}/hugo/content/reiseblog"

TRIP_DIR=""
SLUG=""
DAY=""
DATE=""
STAGE=""
PHOTO_SRC=""
GPX_DIR=""
TEXT=""
TEXT_FILE=""
START_NAME="Start"
TRACK_NAME="Reiseroute"
MAX_WIDTH="2200"
QUALITY="82"
FORCE=0

usage() {
  cat <<'EOF'
Usage:
  ./scripts/trip-day.sh \
    --slug alpen-2026 \
    --day 2 \
    --date 2026-07-09 \
    --stage "Dolomiten" \
    --photo-src "$HOME/trip/alpen-2026/raw/day-02" \
    --gpx-dir "$HOME/trip/alpen-2026/gpx" \
    [--text "Kurzer Text"] \
    [--text-file ./day-02.md] \
    [--start-name "Start"] \
    [--track-name "Reiseroute"] \
    [--max-width 2200] \
    [--quality 82] \
    [--force]

  ./scripts/trip-day.sh \
    --trip-dir hugo/content/reiseblog/alpen-2026 \
    --day 2 \
    --date 2026-07-09 \
    --stage "Dolomiten" \
    --photo-src "$HOME/trip/alpen-2026/raw/day-02" \
    --gpx-dir "$HOME/trip/alpen-2026/gpx" \
    [--text "Kurzer Text"] \
    [--text-file ./day-02.md] \
    [--start-name "Start"] \
    [--track-name "Reiseroute"] \
    [--max-width 2200] \
    [--quality 82] \
    [--force]

What it does:
1) Resizes day photos into <trip-dir>/day-XX
2) Rebuilds route.geojson + route.gpx from all GPX files
3) Generates gallery markup
4) Appends a ready-to-edit day section to index.md
EOF
}

to_ddmmyyyy() {
  local iso="$1"
  if [[ "$iso" =~ ^([0-9]{4})-([0-9]{2})-([0-9]{2})$ ]]; then
    printf '%s.%s.%s' "${BASH_REMATCH[3]}" "${BASH_REMATCH[2]}" "${BASH_REMATCH[1]}"
    return 0
  fi
  return 1
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --slug)
      SLUG="$2"
      shift 2
      ;;
    --trip-dir)
      TRIP_DIR="$2"
      shift 2
      ;;
    --day)
      DAY="$2"
      shift 2
      ;;
    --date)
      DATE="$2"
      shift 2
      ;;
    --stage)
      STAGE="$2"
      shift 2
      ;;
    --photo-src)
      PHOTO_SRC="$2"
      shift 2
      ;;
    --gpx-dir)
      GPX_DIR="$2"
      shift 2
      ;;
    --text)
      TEXT="$2"
      shift 2
      ;;
    --text-file)
      TEXT_FILE="$2"
      shift 2
      ;;
    --start-name)
      START_NAME="$2"
      shift 2
      ;;
    --track-name)
      TRACK_NAME="$2"
      shift 2
      ;;
    --max-width)
      MAX_WIDTH="$2"
      shift 2
      ;;
    --quality)
      QUALITY="$2"
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

if [[ -z "$DAY" || -z "$DATE" || -z "$STAGE" || -z "$PHOTO_SRC" || -z "$GPX_DIR" ]]; then
  echo "Error: --day, --date, --stage, --photo-src and --gpx-dir are required." >&2
  usage
  exit 1
fi

if [[ -z "$SLUG" && -z "$TRIP_DIR" ]]; then
  echo "Error: provide --slug (preferred) or --trip-dir." >&2
  usage
  exit 1
fi

if [[ -n "$SLUG" && -n "$TRIP_DIR" ]]; then
  echo "Error: use either --slug or --trip-dir, not both." >&2
  usage
  exit 1
fi

if [[ -n "$TEXT" && -n "$TEXT_FILE" ]]; then
  echo "Error: use either --text or --text-file, not both." >&2
  exit 1
fi

if [[ ! "$DAY" =~ ^[0-9]+$ ]]; then
  echo "Error: --day must be a positive number." >&2
  exit 1
fi

if ! DATE_DE="$(to_ddmmyyyy "$DATE")"; then
  echo "Error: --date must be in YYYY-MM-DD format." >&2
  exit 1
fi

if [[ -n "$SLUG" ]]; then
  TRIP_DIR_ABS="${CONTENT_ROOT}/${SLUG}"
else
  TRIP_DIR_ABS="$TRIP_DIR"
  if [[ ! "$TRIP_DIR_ABS" = /* ]]; then
    TRIP_DIR_ABS="${ROOT_DIR}/${TRIP_DIR_ABS}"
  fi
fi

INDEX_FILE="${TRIP_DIR_ABS}/index.md"
if [[ ! -f "$INDEX_FILE" ]]; then
  echo "Error: index.md not found in trip dir: $TRIP_DIR_ABS" >&2
  exit 1
fi

if [[ ! -d "$PHOTO_SRC" ]]; then
  echo "Error: photo source directory not found: $PHOTO_SRC" >&2
  exit 1
fi

if [[ ! -d "$GPX_DIR" ]]; then
  echo "Error: GPX directory not found: $GPX_DIR" >&2
  exit 1
fi

if [[ -n "$TEXT_FILE" && ! -f "$TEXT_FILE" ]]; then
  echo "Error: text file not found: $TEXT_FILE" >&2
  exit 1
fi

if ! grep -q '^## Etappen' "$INDEX_FILE"; then
  echo "Error: '## Etappen' heading not found in $INDEX_FILE" >&2
  exit 1
fi

if [[ "$FORCE" -ne 1 ]] && grep -q "^### Tag ${DAY} - " "$INDEX_FILE"; then
  echo "Error: day section already exists in index.md (Tag ${DAY}). Use --force to append anyway." >&2
  exit 1
fi

DAY_DIR="day-$(printf '%02d' "$DAY")"
PHOTO_DEST="${TRIP_DIR_ABS}/${DAY_DIR}"
GALLERY_ID="$DAY_DIR"

"${ROOT_DIR}/scripts/resize-trip-photos.sh" \
  --src "$PHOTO_SRC" \
  --dest "$PHOTO_DEST" \
  --prefix "$DAY_DIR" \
  --max-width "$MAX_WIDTH" \
  --quality "$QUALITY"

python3 "${ROOT_DIR}/scripts/gpx_tracks_to_map_assets.py" \
  --gpx-dir "$GPX_DIR" \
  --geojson-out "${TRIP_DIR_ABS}/route.geojson" \
  --gpx-out "${TRIP_DIR_ABS}/route.gpx" \
  --start-name "$START_NAME" \
  --track-name "$TRACK_NAME"

TMP_GALLERY="$(mktemp)"
trap 'rm -f "$TMP_GALLERY"' EXIT

"${ROOT_DIR}/scripts/make-gallery-snippet.sh" \
  --dir "$PHOTO_DEST" \
  --gallery-id "$GALLERY_ID" \
  --alt "$STAGE" > "$TMP_GALLERY"

if [[ -n "$TEXT_FILE" ]]; then
  DAY_TEXT="$(cat "$TEXT_FILE")"
elif [[ -n "$TEXT" ]]; then
  DAY_TEXT="$TEXT"
else
  DAY_TEXT="Kurzer Text zum Tag."
fi

{
  echo
  echo "### Tag ${DAY} - ${DATE_DE}"
  echo
  echo "#### Etappe: ${STAGE}"
  echo
  echo "$DAY_TEXT"
  echo
  cat "$TMP_GALLERY"
  echo
} >> "$INDEX_FILE"

echo "Updated: $INDEX_FILE"
echo "Photos:  $PHOTO_DEST"
echo "Map:     ${TRIP_DIR_ABS}/route.geojson"
echo "Track:   ${TRIP_DIR_ABS}/route.gpx"
