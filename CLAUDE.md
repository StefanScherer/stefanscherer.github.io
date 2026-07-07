# Context: Hugo migration for stefanscherer.github.io

## Goal

Migrate from historical Ghost/Buster static output to Hugo for new content, while keeping all existing legacy URLs reachable.

## Current architecture

- Legacy static site remains in repo root (historical Ghost/Buster output).
- New Hugo source lives in `hugo/`.
- GitHub Pages deploy uses workflow `.github/workflows/pages.yml`.
- Deployment merges legacy root files with Hugo build output.
- If paths overlap, Hugo output wins (copied last).

## UI requirements

- All new or changed UI/CSS must be compatible with both light and dark mode.
- Color/theme switching should happen automatically via system preference (`prefers-color-scheme`).
- No manual dark/light toggle is required.
- Validate readability/contrast for header, cards, callout boxes, and link text in both modes.

## Local development

- Hugo only preview (new content):
  - `make serve-hugo`
  - URL: http://localhost:1313/
  - Note: legacy posts are not served here.

- Combined preview (legacy + Hugo):
  - `make serve-combined`
  - URL: http://localhost:4173/
  - Use this to verify old and new URLs together.

- Rebuild combined output without starting a server:
  - `make site-assemble`
  - Output folder: `.site-test/`

## Polarsteps import workflow

- Import helper: `scripts/import-trip.sh` (invoked via `make import-trip`).
- Typical import from export root with trip selection:
  - `make import-trip SOURCE=user_data/trip TRIP_MATCH=<match> TITLE="..." DATE=YYYY-MM-DD SLUG=<slug> SUMMARY="..." FORCE=1`
- Exact trip folder import:
  - `make import-trip SOURCE=user_data/trip TRIP_DIR=user_data/trip/<trip_slug_id> TITLE="..." DATE=YYYY-MM-DD SLUG=<slug> SUMMARY="..." FORCE=1`
- List possible trips:
  - `make list-trips SOURCE=user_data/trip`

### Current importer behavior

- Creates a Hugo page bundle under `hugo/content/reiseblog/<slug>/`.
- Generates `index.md` from `trip.json` when available.
- Groups content by day and step.
- Renders per-step image galleries with in-page lightbox support.
- Tries to infer per-step image order from references found inside each step object in `trip.json`.
- If no image references exist in step JSON, uses deterministic filename fallback.

### Important limitation (verified)

- In the current Polarsteps export format in this repo, `trip.json` step objects do not contain `media_items` or usable `main_media_item_path` values.
- Exported JPG files also do not provide usable EXIF timestamps for ordering.
- Result: exact Polarsteps UI order cannot always be reconstructed automatically from available data.

## Important files

- Hugo config: `hugo/hugo.toml`
- Hugo content root: `hugo/content/`
- New travel posts: `hugo/content/reiseblog/`
- Workflow: `.github/workflows/pages.yml`
- Local helper script: `scripts/preview-combined.sh`
- Trip import script: `scripts/import-trip.sh`
- Lightbox script: `hugo/static/js/lightbox.js`
- Migration notes: `HUGO_MIGRATION.md`

## Git ignore

Root `.gitignore` ignores only local test outputs:

- `.hugo-public-test/`
- `.site-test/`
- `user_data/`
- `.DS_Store`

## Status checklist

- [x] Hugo scaffolding added
- [x] GitHub Actions workflow added for merge deploy
- [x] Combined local preview workflow added
- [x] Legacy URL compatibility validated locally
- [x] Polarsteps import helper with day/step grouping
- [x] In-page lightbox for step galleries
- [x] Import fallback ordering implemented for missing metadata
- [ ] Push changes and verify first Pages deploy
- [ ] Optionally pin Hugo version in workflow (instead of `latest`)

## Next recommended steps

1. Commit and push current changes.
2. Ensure GitHub Pages source is set to GitHub Actions.
3. Trigger workflow and validate:
   - legacy URL (example): `/how-to-use-secrets-in-azure-pipelines/`
   - new URL (example): `/reiseblog/neustart-reiseblog-mit-hugo/`
   - imported travel URL (example): `/reiseblog/cabriotour-immer-der-sonne-nach/`
4. Decide whether to pin a fixed Hugo version in workflow.
