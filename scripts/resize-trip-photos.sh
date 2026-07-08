#!/usr/bin/env bash
set -euo pipefail

# Resize camera images for web usage with macOS sips.
# Converts all supported input files to JPEG in destination folder.

SRC=""
DEST=""
MAX_WIDTH="2200"
QUALITY="82"
PREFIX=""

usage() {
  cat <<'EOF'
Usage:
  ./scripts/resize-trip-photos.sh --src <input-dir> --dest <output-dir> [--max-width 2200] [--quality 82] [--prefix day1]

Notes:
- Requires macOS tool: sips
- Supported input: jpg, jpeg, png, heic, tif, tiff, webp
- Output files are JPEG, sorted by filename.
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --src)
      SRC="$2"
      shift 2
      ;;
    --dest)
      DEST="$2"
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
    --prefix)
      PREFIX="$2"
      shift 2
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

if [[ -z "$SRC" || -z "$DEST" ]]; then
  echo "Error: --src and --dest are required" >&2
  usage
  exit 1
fi

if [[ ! -d "$SRC" ]]; then
  echo "Error: input dir does not exist: $SRC" >&2
  exit 1
fi

if ! command -v sips >/dev/null 2>&1; then
  echo "Error: sips not found (macOS only)." >&2
  exit 1
fi

mkdir -p "$DEST"

sanitize() {
  local s="$1"
  s="${s,,}"
  s="${s// /-}"
  s="${s//_/\-}"
  s="${s//[^a-z0-9\-]/}"
  s="${s#-}"
  s="${s%-}"
  printf '%s' "$s"
}

mapfile -d '' files < <(find "$SRC" -type f \( \
  -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.heic' -o -iname '*.tif' -o -iname '*.tiff' -o -iname '*.webp' \
\) -print0 | sort -z)

if [[ ${#files[@]} -eq 0 ]]; then
  echo "No supported image files found in $SRC" >&2
  exit 1
fi

i=1
for f in "${files[@]}"; do
  base="$(basename "$f")"
  stem="${base%.*}"
  clean="$(sanitize "$stem")"
  if [[ -z "$clean" ]]; then
    clean="foto"
  fi

  if [[ -n "$PREFIX" ]]; then
    out_name="${PREFIX}-$(printf '%03d' "$i")-${clean}.jpg"
  else
    out_name="$(printf '%03d' "$i")-${clean}.jpg"
  fi

  out_path="$DEST/$out_name"

  sips --resampleWidth "$MAX_WIDTH" -s format jpeg "$f" --out "$out_path" >/dev/null
  sips -s formatOptions "$QUALITY" "$out_path" >/dev/null

  echo "Wrote $out_path"
  i=$((i + 1))
done
