#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONTENT_ROOT="${ROOT_DIR}/hugo/content/reiseblog"

SOURCE=""
TITLE=""
DATE=""
SLUG=""
SUMMARY=""
TEXT_FILE=""
TRIP_DIR=""
TRIP_MATCH=""
LIST_TRIPS=0
FORCE=0

usage() {
  cat <<'EOF'
Usage:
  ./scripts/import-trip.sh \
    --source /path/to/export-or-trip-folder \
    --title "Cabriotour" \
    --date 2026-07-07 \
    --slug cabriotour-immer-der-sonne-nach \
    [--summary "Kurztext"] \
    [--text-file /path/to/text.md] \
    [--trip-dir "/path/to/specific/trip-folder"] \
    [--trip-match "cabriotour"] \
    [--force]

  ./scripts/import-trip.sh --source /path/to/export-root --list-trips

Expected trip folder content:
- Optional notes file: notes.md
- Optional images in root or subfolders (jpg, jpeg, png, webp, gif)
EOF
}

sanitize_filename() {
  local s="$1"
  s="${s//\//__}"
  s="${s// /_}"
  s="${s//:/-}"
  printf '%s' "$s"
}

escape_yaml() {
  local s="$1"
  s="${s//\\/\\\\}"
  s="${s//\"/\\\"}"
  printf '%s' "$s"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --source)
      SOURCE="$2"
      shift 2
      ;;
    --title)
      TITLE="$2"
      shift 2
      ;;
    --date)
      DATE="$2"
      shift 2
      ;;
    --slug)
      SLUG="$2"
      shift 2
      ;;
    --summary)
      SUMMARY="$2"
      shift 2
      ;;
    --text-file)
      TEXT_FILE="$2"
      shift 2
      ;;
    --trip-dir)
      TRIP_DIR="$2"
      shift 2
      ;;
    --trip-match)
      TRIP_MATCH="$2"
      shift 2
      ;;
    --list-trips)
      LIST_TRIPS=1
      shift
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

if [[ -z "$SOURCE" ]]; then
  echo "Error: --source is required." >&2
  usage
  exit 1
fi

if [[ ! -d "$SOURCE" ]]; then
  echo "Error: source folder does not exist: $SOURCE" >&2
  exit 1
fi

trip_candidates() {
  find "$SOURCE" -mindepth 1 -maxdepth 3 -type d \( \
    -iname '*trip*' -o -iname '*reise*' -o -iname '*travel*' -o -iname '*journey*' -o -iname '*cabriotour*' \
  \)
}

if [[ "$LIST_TRIPS" -eq 1 ]]; then
  echo "Trip candidates in: $SOURCE"
  candidates="$(trip_candidates || true)"
  if [[ -n "$candidates" ]]; then
    printf '%s\n' "$candidates"
  else
    echo "No named trip folders found. Showing first-level folders instead:"
    find "$SOURCE" -mindepth 1 -maxdepth 1 -type d
  fi
  exit 0
fi

if [[ -z "$TITLE" || -z "$DATE" || -z "$SLUG" ]]; then
  echo "Error: --title, --date and --slug are required for import." >&2
  usage
  exit 1
fi

if [[ -n "$TRIP_DIR" && -n "$TRIP_MATCH" ]]; then
  echo "Error: use only one of --trip-dir or --trip-match." >&2
  exit 1
fi

SOURCE_TRIP="$SOURCE"

if [[ -n "$TRIP_DIR" ]]; then
  if [[ ! -d "$TRIP_DIR" ]]; then
    echo "Error: trip folder does not exist: $TRIP_DIR" >&2
    exit 1
  fi
  SOURCE_TRIP="$TRIP_DIR"
elif [[ -n "$TRIP_MATCH" ]]; then
  matches="$(find "$SOURCE" -type d -iname "*${TRIP_MATCH}*" 2>/dev/null || true)"
  if [[ -z "$matches" ]]; then
    echo "Error: no trip folder matches '$TRIP_MATCH' under $SOURCE" >&2
    exit 1
  fi
  match_count="$(printf '%s\n' "$matches" | sed '/^$/d' | wc -l | tr -d ' ')"
  if [[ "$match_count" -gt 1 ]]; then
    echo "Error: trip match '$TRIP_MATCH' is ambiguous. Candidates:" >&2
    printf '%s\n' "$matches" >&2
    exit 1
  fi
  SOURCE_TRIP="$matches"
fi

# If source looks like an export root with many folders and no direct images,
# force explicit trip selection to avoid importing all trips accidentally.
root_images="$(find "$SOURCE_TRIP" -maxdepth 1 -type f \( \
  -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' -o -iname '*.gif' \
\) | head -n 1)"

first_level_dirs_count="$(find "$SOURCE_TRIP" -mindepth 1 -maxdepth 1 -type d | wc -l | tr -d ' ')"
if [[ -z "$root_images" && "$first_level_dirs_count" -gt 1 && -z "$TRIP_DIR" && -z "$TRIP_MATCH" ]]; then
  echo "Error: source appears to be an export root with multiple trips." >&2
  echo "Use --trip-match or --trip-dir, or run --list-trips first." >&2
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

COPIED_IMAGES_FILE="$(mktemp)"
trap 'rm -f "$COPIED_IMAGES_FILE"' EXIT

# Copy typical image formats recursively into the page bundle.
while IFS= read -r -d '' img; do
  rel="${img#$SOURCE_TRIP/}"
  safe_rel="$(sanitize_filename "$rel")"
  cp "$img" "${DEST_DIR}/${safe_rel}"
  echo "$safe_rel" >> "$COPIED_IMAGES_FILE"
done < <(find "$SOURCE_TRIP" -type f \( \
  -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' -o -iname '*.gif' \
\) -print0)

TEXT_SOURCE=""
if [[ -n "$TEXT_FILE" && -f "$TEXT_FILE" ]]; then
  TEXT_SOURCE="$TEXT_FILE"
elif [[ -f "${SOURCE_TRIP}/notes.md" ]]; then
  TEXT_SOURCE="${SOURCE_TRIP}/notes.md"
fi

TITLE_ESC="$(escape_yaml "$TITLE")"
SUMMARY_ESC="$(escape_yaml "$SUMMARY")"

INDEX_FILE="${DEST_DIR}/index.md"
{
  echo "---"
  echo "title: \"${TITLE_ESC}\""
  echo "date: ${DATE}"
  echo "slug: \"${SLUG}\""
  if [[ -n "$SUMMARY_ESC" ]]; then
    echo "summary: \"${SUMMARY_ESC}\""
  else
    echo "summary: \"Importierte Reise\""
  fi
  echo "---"
  echo

  GENERATED_FROM_TRIP_JSON=0

  if [[ -n "$TEXT_SOURCE" ]]; then
    cat "$TEXT_SOURCE"
    echo
  elif [[ -f "${SOURCE_TRIP}/trip.json" ]]; then
    GENERATED_FROM_TRIP_JSON=1
    python3 - "$SOURCE_TRIP/trip.json" "$DEST_DIR" <<'PY'
import datetime
import json
import os
import re
import sys

trip_path = sys.argv[1]
dest_dir = sys.argv[2]
with open(trip_path, 'r', encoding='utf-8') as f:
  trip = json.load(f)

name = trip.get('name') or 'Reise'
summary = trip.get('summary') or ''
start_ts = trip.get('start_date')
end_ts = trip.get('end_date')

def fmt_date(ts):
  if not ts:
    return ''
  try:
    return datetime.datetime.fromtimestamp(float(ts)).strftime('%d.%m.%Y')
  except Exception:
    return ''

start_date = fmt_date(start_ts)
end_date = fmt_date(end_ts)

def is_image(filename):
  lower = filename.lower()
  return lower.endswith('.jpg') or lower.endswith('.jpeg') or lower.endswith('.png') or lower.endswith('.webp') or lower.endswith('.gif')

all_images = [f for f in os.listdir(dest_dir) if os.path.isfile(os.path.join(dest_dir, f)) and is_image(f)]
all_images.sort()

image_meta = {}
for img in all_images:
  # Polarsteps export filenames often look like:
  # <uuid_a>_<uuid_b>.jpg
  # We observed that ordering by uuid_b descending matches UI order better
  # than destination-file mtimes (which reflect copy order).
  source_name = img.split('__photos__', 1)[1] if '__photos__' in img else img
  base = source_name.rsplit('.', 1)[0]
  parts = base.split('_', 1)
  uuid_b = parts[1] if len(parts) == 2 else ''

  image_meta[img] = {
    'uuid_b': uuid_b,
    'source_name': source_name,
  }

UUID = r'[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}'
PAIR_RE = re.compile(rf'({UUID}_{UUID})')

def media_pair_from_text(value):
  if not isinstance(value, str):
    return None
  text = value.strip()
  if not text:
    return None
  m = PAIR_RE.search(text)
  if m:
    return m.group(1).lower()
  tail = text.rsplit('/', 1)[-1].split('?', 1)[0]
  base = tail.rsplit('.', 1)[0]
  m = PAIR_RE.search(base)
  if m:
    return m.group(1).lower()
  return None

def collect_step_pairs(node, out):
  if isinstance(node, dict):
    for _, val in node.items():
      collect_step_pairs(val, out)
  elif isinstance(node, list):
    for item in node:
      collect_step_pairs(item, out)
  else:
    pair = media_pair_from_text(node)
    if pair:
      out.append(pair)

def step_images_from_json(step, step_images):
  if not step_images:
    return []

  token_to_images = {}
  for img in step_images:
    source_name = image_meta.get(img, {}).get('source_name', img)
    base = source_name.rsplit('.', 1)[0].lower()
    token_to_images.setdefault(base, []).append(img)

  ordered_pairs = []
  collect_step_pairs(step, ordered_pairs)
  if not ordered_pairs:
    return []

  out = []
  seen = set()
  for pair in ordered_pairs:
    for img in token_to_images.get(pair, []):
      if img not in seen:
        out.append(img)
        seen.add(img)

  return out

images_by_prefix = {}
for img in all_images:
  if '__photos__' in img:
    prefix = img.split('__photos__', 1)[0]
  else:
    prefix = ''
  images_by_prefix.setdefault(prefix, []).append(img)

print('## Überblick')
print('')
if start_date and end_date:
  print(f'{name} vom {start_date} bis {end_date}.')
elif start_date:
  print(f'{name} ab {start_date}.')
else:
  print(f'Importierte Reise: {name}.')
if summary:
  print('')
  print(summary)
print('')
print('## Etappen')
print('')

steps = trip.get('all_steps', []) or []
steps = sorted(steps, key=lambda s: float(s.get('start_time') or 0.0))

day_index = 0
current_day = ''

for step in steps:
  step_day = fmt_date(step.get('start_time'))
  if step_day != current_day:
    day_index += 1
    current_day = step_day
    if step_day:
      print(f'### Tag {day_index} - {step_day}')
    else:
      print(f'### Tag {day_index}')
    print('')

  step_name = step.get('display_name') or step.get('name') or 'Etappe'
  print(f'#### Etappe: {step_name}')
  print('')
  desc = (step.get('description') or '').strip()
  if desc:
    print(desc)
  else:
    print('Notizen folgen.')
  print('')

  step_slug = (step.get('display_slug') or step.get('slug') or '').strip()
  step_id = step.get('id')
  candidates = []
  if step_slug and step_id:
    candidates.append(f'{step_slug}_{step_id}')

  step_images = []
  for c in candidates:
    step_images.extend(images_by_prefix.get(c, []))

  json_order = step_images_from_json(step, step_images)
  if json_order:
    ordered_set = set(json_order)
    remaining = [img for img in step_images if img not in ordered_set]
    step_images = json_order + sorted(remaining, key=lambda n: (image_meta.get(n, {}).get('uuid_b', ''), n), reverse=True)
  else:
    step_images = sorted(step_images, key=lambda n: (image_meta.get(n, {}).get('uuid_b', ''), n), reverse=True)

  if step_images:
    group_id = f'step-{step_id}' if step_id else f'step-{step_slug or "unknown"}'
    print('<div class="step-gallery">')
    for idx, img in enumerate(step_images, start=1):
      safe_name = step_name.replace('"', '&quot;')
      print(f'  <a href="{img}" class="step-thumb-link" data-gallery="{group_id}" data-index="{idx}">')
      print(f'    <img src="{img}" alt="{safe_name}" loading="lazy" class="step-thumb">')
      print('  </a>')
    print('</div>')
    print('')
PY
  else
    cat <<'EOF'
## Überblick

Diese Reise wurde aus einem externen Export importiert.

## Etappen

Ergaenze hier die Etappen und Notizen.
EOF
    echo
  fi

  if [[ "$GENERATED_FROM_TRIP_JSON" -eq 0 ]]; then
    images_list="$(LC_ALL=C sort "$COPIED_IMAGES_FILE" | sed '/^$/d')"

    if [[ -n "$images_list" ]]; then
      echo "## Galerie"
      echo
      while IFS= read -r img; do
        echo "![${TITLE_ESC} - ${img}](${img})"
        echo
      done <<< "$images_list"
    fi
  fi
} > "$INDEX_FILE"

echo "Created: ${INDEX_FILE}"
if compgen -G "${DEST_DIR}/*" > /dev/null; then
  echo "Bundle folder: ${DEST_DIR}"
fi
echo "Imported from: ${SOURCE_TRIP}"
