#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONTENT_ROOT="${ROOT_DIR}/hugo/content/reiseblog"
SERVE=1
OPEN_BROWSER=1
OPEN_EDITOR=1

DAY_ARGS=()
TRIP_DIR=""
SLUG=""

usage() {
  cat <<'EOF'
Usage:
  ./scripts/trip-day-open.sh --slug alpen-2026 [trip-day args...] [--no-serve] [--no-open-browser] [--no-open-editor]

  (Fallback, backwards compatible)
  ./scripts/trip-day-open.sh --trip-dir hugo/content/reiseblog/alpen-2026 [trip-day args...] [--no-serve] [--no-open-browser] [--no-open-editor]

Runs trip-day workflow, then optionally:
- starts Hugo server on 127.0.0.1:1313 (if not already running)
- opens the trip page in browser
- opens index.md in VS Code (if `code` is available)
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --no-serve)
      SERVE=0
      shift
      ;;
    --no-open-browser)
      OPEN_BROWSER=0
      shift
      ;;
    --no-open-editor)
      OPEN_EDITOR=0
      shift
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    --trip-dir)
      TRIP_DIR="$2"
      DAY_ARGS+=("$1" "$2")
      shift 2
      ;;
    --slug)
      SLUG="$2"
      DAY_ARGS+=("$1" "$2")
      shift 2
      ;;
    *)
      DAY_ARGS+=("$1")
      shift
      ;;
  esac
done

if [[ -z "$SLUG" && -z "$TRIP_DIR" ]]; then
  echo "Error: provide --slug (preferred) or --trip-dir." >&2
  exit 1
fi

if [[ -n "$SLUG" && -n "$TRIP_DIR" ]]; then
  echo "Error: use either --slug or --trip-dir, not both." >&2
  exit 1
fi

"${ROOT_DIR}/scripts/trip-day.sh" "${DAY_ARGS[@]}"

if [[ -n "$SLUG" ]]; then
  TRIP_DIR_ABS="${CONTENT_ROOT}/${SLUG}"
else
  TRIP_DIR_ABS="$TRIP_DIR"
  if [[ ! "$TRIP_DIR_ABS" = /* ]]; then
    TRIP_DIR_ABS="${ROOT_DIR}/${TRIP_DIR_ABS}"
  fi
  SLUG="$(basename "$TRIP_DIR_ABS")"
fi

INDEX_FILE="${TRIP_DIR_ABS}/index.md"
URL="http://127.0.0.1:1313/reiseblog/${SLUG}/"

if [[ "$SERVE" -eq 1 ]]; then
  if lsof -iTCP:1313 -sTCP:LISTEN -n -P >/dev/null 2>&1; then
    echo "Hugo server already running on :1313"
  else
    (
      cd "$ROOT_DIR"
      nohup hugo server --source hugo --bind 127.0.0.1 --port 1313 > /tmp/reiseblog-hugo-server.log 2>&1 &
    )
    echo "Started Hugo server on :1313 (log: /tmp/reiseblog-hugo-server.log)"
  fi
fi

if [[ "$OPEN_EDITOR" -eq 1 ]]; then
  if command -v code >/dev/null 2>&1; then
    code "$INDEX_FILE" >/dev/null 2>&1 || true
    echo "Opened in editor: $INDEX_FILE"
  else
    echo "Editor open skipped (code CLI not found)."
  fi
fi

if [[ "$OPEN_BROWSER" -eq 1 ]]; then
  if command -v open >/dev/null 2>&1; then
    open "$URL" >/dev/null 2>&1 || true
    echo "Opened in browser: $URL"
  else
    echo "Browser open skipped (open command not found)."
  fi
fi

echo "Done."
