#!/usr/bin/env bash
set -euo pipefail

DIR=""
GALLERY_ID=""
ALT="Foto"

usage() {
  cat <<'EOF'
Usage:
  ./scripts/make-gallery-snippet.sh --dir <trip-bundle-dir> --gallery-id <id> [--alt "Text"]

Prints a step-gallery HTML snippet to stdout based on JPG/PNG/WebP files in the given folder.
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dir)
      DIR="$2"
      shift 2
      ;;
    --gallery-id)
      GALLERY_ID="$2"
      shift 2
      ;;
    --alt)
      ALT="$2"
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

if [[ -z "$DIR" || -z "$GALLERY_ID" ]]; then
  echo "Error: --dir and --gallery-id are required" >&2
  usage
  exit 1
fi

if [[ ! -d "$DIR" ]]; then
  echo "Error: directory does not exist: $DIR" >&2
  exit 1
fi

mapfile -d '' files < <(find "$DIR" -maxdepth 1 -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \) -print0 | sort -z)

if [[ ${#files[@]} -eq 0 ]]; then
  echo "No images found in $DIR" >&2
  exit 1
fi

echo '<div class="step-gallery">'
i=1
for f in "${files[@]}"; do
  name="$(basename "$f")"
  echo "  <a href=\"$name\" class=\"step-thumb-link\" data-gallery=\"$GALLERY_ID\" data-index=\"$i\">"
  echo "    <img src=\"$name\" alt=\"$ALT\" loading=\"lazy\" class=\"step-thumb\">"
  echo '  </a>'
  i=$((i + 1))
done
echo '</div>'
