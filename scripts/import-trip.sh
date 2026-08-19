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
FFMPEG_AVAILABLE=0

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

is_video_file() {
  local lower
  lower="$(printf '%s' "$1" | tr '[:upper:]' '[:lower:]')"
  [[ "$lower" == *.mp4 || "$lower" == *.mov || "$lower" == *.m4v || "$lower" == *.webm ]]
}

file_cache_buster() {
  local path="$1"
  if [[ ! -f "$path" ]]; then
    return 1
  fi

  if command -v stat >/dev/null 2>&1; then
    if stat -f "%m" "$path" >/dev/null 2>&1; then
      stat -f "%m" "$path"
      return 0
    fi
    if stat -c "%Y" "$path" >/dev/null 2>&1; then
      stat -c "%Y" "$path"
      return 0
    fi
  fi

  date +%s
}

make_video_thumbnail() {
  local video_path="$1"
  local thumb_path="$2"
  local duration=""
  local -a tries
  local best_time=""
  local best_yavg="-1"
  local yavg=""
  local is_better="0"
  local t

  if [[ "$FFMPEG_AVAILABLE" -ne 1 ]]; then
    return 1
  fi

  # Probe duration and sample multiple moments to avoid black intros.
  if command -v ffprobe >/dev/null 2>&1; then
    duration="$(ffprobe -v error -show_entries format=duration -of default=nk=1:nw=1 "$video_path" 2>/dev/null | head -n 1 | tr -d '\r')"
  fi

  tries=("1" "3" "5" "8" "12")

  if [[ -n "$duration" ]]; then
    mid1="$(awk -v d="$duration" 'BEGIN{printf "%.3f", (d * 0.35)}')"
    mid2="$(awk -v d="$duration" 'BEGIN{printf "%.3f", (d * 0.55)}')"
    mid3="$(awk -v d="$duration" 'BEGIN{printf "%.3f", (d * 0.75)}')"
    tries+=("$mid1" "$mid2" "$mid3")
  fi

  # Pick the brightest candidate frame first to reduce black thumbnails.
  for t in "${tries[@]}"; do
    yavg="$(ffmpeg -v error -ss "$t" -i "$video_path" -vf "signalstats,metadata=print:file=-" -frames:v 1 -f null - 2>&1 | sed -n 's/^lavfi.signalstats.YAVG=//p' | head -n 1)"
    if [[ -z "$yavg" ]]; then
      continue
    fi

    is_better="$(awk -v a="$yavg" -v b="$best_yavg" 'BEGIN{if (a > b) print 1; else print 0}')"
    if [[ "$is_better" == "1" ]]; then
      best_yavg="$yavg"
      best_time="$t"
    fi
  done

  if [[ -n "$best_time" ]]; then
    if ffmpeg -loglevel error -y -ss "$best_time" -i "$video_path" -frames:v 1 -vf "scale='min(960,iw)':-2" "$thumb_path" >/dev/null 2>&1; then
      if [[ -s "$thumb_path" ]]; then
        return 0
      fi
    fi
  fi

  for t in "${tries[@]}"; do
    if ffmpeg -loglevel error -y -ss "$t" -i "$video_path" -frames:v 1 -vf "scale='min(960,iw)':-2" "$thumb_path" >/dev/null 2>&1; then
      if [[ -s "$thumb_path" ]]; then
        return 0
      fi
    fi
  done

  # Final fallback: let ffmpeg choose a representative frame from the stream.
  ffmpeg -loglevel error -y -i "$video_path" -vf "thumbnail=120,scale='min(960,iw)':-2" -frames:v 1 "$thumb_path" >/dev/null 2>&1
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

if command -v ffmpeg >/dev/null 2>&1; then
  FFMPEG_AVAILABLE=1
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

# Copy supported media formats recursively into the page bundle.
# Sort source paths to keep import deterministic across filesystems.
while IFS= read -r -d '' media; do
  rel="${media#$SOURCE_TRIP/}"
  safe_rel="$(sanitize_filename "$rel")"
  cp "$media" "${DEST_DIR}/${safe_rel}"
  echo "$safe_rel" >> "$COPIED_IMAGES_FILE"
done < <(
  find "$SOURCE_TRIP" -type f \( \
    -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' -o -iname '*.gif' \
    -o -iname '*.mp4' -o -iname '*.mov' -o -iname '*.m4v' -o -iname '*.webm' \
  \) -print0 | LC_ALL=C sort -z
)

if [[ "$FFMPEG_AVAILABLE" -eq 1 ]]; then
  while IFS= read -r media_name; do
    if ! is_video_file "$media_name"; then
      continue
    fi

    video_path="${DEST_DIR}/${media_name}"
    thumb_name="${media_name%.*}__thumb.jpg"
    thumb_path="${DEST_DIR}/${thumb_name}"
    if [[ -f "$thumb_path" ]]; then
      continue
    fi

    make_video_thumbnail "$video_path" "$thumb_path" || true
  done < "$COPIED_IMAGES_FILE"
else
  echo "Warning: ffmpeg not found; video thumbnails were not generated." >&2
fi

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

def short_note(text, max_len=180):
  if not text:
    return ''
  cleaned = ' '.join(str(text).strip().split())
  if len(cleaned) <= max_len:
    return cleaned
  return cleaned[:max_len - 3].rstrip() + '...'

start_date = fmt_date(start_ts)
end_date = fmt_date(end_ts)

def is_image(filename):
  lower = filename.lower()
  return lower.endswith('.jpg') or lower.endswith('.jpeg') or lower.endswith('.png') or lower.endswith('.webp') or lower.endswith('.gif')

def is_video(filename):
  lower = filename.lower()
  return lower.endswith('.mp4') or lower.endswith('.mov') or lower.endswith('.m4v') or lower.endswith('.webm')

def cache_busted_url(filename):
  path = os.path.join(dest_dir, filename)
  if not os.path.isfile(path):
    return filename
  try:
    ts = int(os.path.getmtime(path))
  except Exception:
    return filename
  return f'{filename}?v={ts}'

UUID = r'[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}'
PAIR_RE = re.compile(rf'({UUID}_{UUID})')
VIDEO_RE = re.compile(rf'({UUID}_video)', re.IGNORECASE)

all_media = [f for f in os.listdir(dest_dir) if os.path.isfile(os.path.join(dest_dir, f)) and (is_image(f) or is_video(f))]
all_media.sort()

media_meta = {}
for media_name in all_media:
  # Polarsteps export filenames often look like:
  # <uuid_a>_<uuid_b>.jpg
  # or for videos:
  # <uuid>_video.mp4
  # We observed that ordering by uuid_b descending matches UI order better
  # than destination-file mtimes (which reflect copy order).
  source_name = media_name
  if '__photos__' in source_name:
    source_name = source_name.split('__photos__', 1)[1]
  elif '__videos__' in source_name:
    source_name = source_name.split('__videos__', 1)[1]

  base = source_name.rsplit('.', 1)[0]
  parts = base.split('_', 1)
  uuid_b = parts[1] if len(parts) == 2 else ''
  pair_token = ''
  pair_match = PAIR_RE.search(base)
  if pair_match:
    pair_token = pair_match.group(1).lower()
  video_token = ''
  video_match = VIDEO_RE.search(base)
  if video_match:
    video_token = video_match.group(1).lower()
  kind = 'video' if is_video(media_name) else 'image'

  media_meta[media_name] = {
    'uuid_b': uuid_b,
    'source_name': source_name,
    'pair_token': pair_token,
    'video_token': video_token,
    'kind': kind,
  }

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

def collect_step_tokens(node, out):
  if isinstance(node, dict):
    for _, val in node.items():
      collect_step_tokens(val, out)
  elif isinstance(node, list):
    for item in node:
      collect_step_tokens(item, out)
  else:
    if not isinstance(node, str):
      return
    pair = media_pair_from_text(node)
    if pair:
      out.append(pair)
    m = VIDEO_RE.search(node)
    if m:
      out.append(m.group(1).lower())

def step_media_from_json(step, step_media):
  if not step_media:
    return []

  token_to_media = {}
  for media_name in step_media:
    source_name = media_meta.get(media_name, {}).get('source_name', media_name)
    base = source_name.rsplit('.', 1)[0].lower()
    token_to_media.setdefault(base, []).append(media_name)

    pair_token = media_meta.get(media_name, {}).get('pair_token')
    if pair_token:
      token_to_media.setdefault(pair_token, []).append(media_name)

    video_token = media_meta.get(media_name, {}).get('video_token')
    if video_token:
      token_to_media.setdefault(video_token, []).append(media_name)

  ordered_tokens = []
  collect_step_tokens(step, ordered_tokens)
  if not ordered_tokens:
    return []

  out = []
  seen = set()
  for token in ordered_tokens:
    for media_name in token_to_media.get(token, []):
      if media_name not in seen:
        out.append(media_name)
        seen.add(media_name)

  return out

def sort_fallback_media(step_media):
  imgs = [n for n in step_media if media_meta.get(n, {}).get('kind') == 'image']
  vids = [n for n in step_media if media_meta.get(n, {}).get('kind') == 'video']

  imgs = sorted(imgs, key=lambda n: (media_meta.get(n, {}).get('uuid_b', ''), n), reverse=True)
  vids = sorted(vids, key=lambda n: (media_meta.get(n, {}).get('uuid_b', ''), n), reverse=True)
  return imgs + vids

media_by_prefix = {}
for media_name in all_media:
  if '__photos__' in media_name:
    prefix = media_name.split('__photos__', 1)[0]
  elif '__videos__' in media_name:
    prefix = media_name.split('__videos__', 1)[0]
  else:
    prefix = ''
  media_by_prefix.setdefault(prefix, []).append(media_name)

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

route_features = []
for i, step in enumerate(steps, start=1):
  loc = step.get('location') or {}
  lat = loc.get('lat')
  lon = loc.get('lon')
  if lat is None or lon is None:
    continue
  try:
    lat = float(lat)
    lon = float(lon)
  except Exception:
    continue
  route_features.append({
    'type': 'Feature',
    'geometry': {'type': 'Point', 'coordinates': [lon, lat]},
    'properties': {
      'order': i,
      'name': step.get('display_name') or step.get('name') or 'Etappe',
      'date': fmt_date(step.get('start_time')),
      'note': short_note(step.get('description') or ''),
      'step_id': step.get('id'),
    },
  })

if route_features:
  route_geojson_path = os.path.join(dest_dir, 'route.geojson')
  with open(route_geojson_path, 'w', encoding='utf-8') as f:
    json.dump({'type': 'FeatureCollection', 'features': route_features}, f, ensure_ascii=False, indent=2)
    f.write('\n')

  print('{{< tripmap geojson="route.geojson" >}}')
  print('')

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

  step_media = []
  for c in candidates:
    step_media.extend(media_by_prefix.get(c, []))

  json_order = step_media_from_json(step, step_media)
  if json_order:
    ordered_set = set(json_order)
    remaining = [m for m in step_media if m not in ordered_set]
    step_media = json_order + sort_fallback_media(remaining)
  else:
    step_media = sort_fallback_media(step_media)

  if step_media:
    group_id = f'step-{step_id}' if step_id else f'step-{step_slug or "unknown"}'
    print('<div class="step-gallery">')
    for idx, media_name in enumerate(step_media, start=1):
      safe_name = step_name.replace('"', '&quot;')
      kind = media_meta.get(media_name, {}).get('kind', 'image')
      if kind == 'video':
        thumb_name_jpg = media_name.rsplit('.', 1)[0] + '__thumb.jpg'
        thumb_name_png = media_name.rsplit('.', 1)[0] + '__thumb.png'
        thumb_name = ''
        if os.path.isfile(os.path.join(dest_dir, thumb_name_jpg)):
          thumb_name = thumb_name_jpg
        elif os.path.isfile(os.path.join(dest_dir, thumb_name_png)):
          thumb_name = thumb_name_png

        has_thumb = bool(thumb_name)
        thumb_url = cache_busted_url(thumb_name) if has_thumb else ''
        poster_attr = f' data-video-poster="{thumb_url}"' if has_thumb else ''
        print(f'  <a href="{media_name}" class="step-thumb-link step-video-link" data-gallery="{group_id}" data-index="{idx}" data-media-kind="video"{poster_attr}>')
        if has_thumb:
          print(f'    <img src="{thumb_url}" alt="{safe_name} (Video)" loading="lazy" class="step-thumb step-thumb-video">')
        else:
          print(f'    <video class="step-thumb step-thumb-video" preload="metadata" muted playsinline>')
          print(f'      <source src="{media_name}" type="video/mp4">')
          print('    </video>')
        print('    <span class="step-video-badge">Video</span>')
        print('  </a>')
      else:
        print(f'  <a href="{media_name}" class="step-thumb-link" data-gallery="{group_id}" data-index="{idx}" data-media-kind="image">')
        print(f'    <img src="{media_name}" alt="{safe_name}" loading="lazy" class="step-thumb">')
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
      while IFS= read -r media_name; do
        lower_name="$(printf '%s' "$media_name" | tr '[:upper:]' '[:lower:]')"
        if [[ "$lower_name" == *.mp4 || "$lower_name" == *.mov || "$lower_name" == *.m4v || "$lower_name" == *.webm ]]; then
          thumb_name_jpg="${media_name%.*}__thumb.jpg"
          thumb_name_png="${media_name%.*}__thumb.png"
          thumb_name=""
          if [[ -f "${DEST_DIR}/${thumb_name_jpg}" ]]; then
            thumb_name="$thumb_name_jpg"
          elif [[ -f "${DEST_DIR}/${thumb_name_png}" ]]; then
            thumb_name="$thumb_name_png"
          fi

          if [[ -n "$thumb_name" ]]; then
            thumb_bust="$(file_cache_buster "${DEST_DIR}/${thumb_name}" || true)"
            thumb_url="$thumb_name"
            if [[ -n "$thumb_bust" ]]; then
              thumb_url="${thumb_name}?v=${thumb_bust}"
            fi
            echo "<a href=\"${media_name}\" class=\"step-thumb-link step-video-link\" data-media-kind=\"video\" data-video-poster=\"${thumb_url}\">"
            echo "  <img src=\"${thumb_url}\" alt=\"${TITLE_ESC} - Video\" loading=\"lazy\" class=\"step-thumb step-thumb-video\">"
            echo "  <span class=\"step-video-badge\">Video</span>"
            echo "</a>"
          else
            echo "<video controls preload=\"metadata\" class=\"step-thumb-video\">"
            echo "  <source src=\"${media_name}\" type=\"video/mp4\">"
            echo "  Dein Browser unterstuetzt das Video-Element nicht."
            echo "</video>"
          fi
        else
          echo "![${TITLE_ESC} - ${media_name}](${media_name})"
        fi
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
