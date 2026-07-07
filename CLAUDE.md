# Context: Hugo migration for stefanscherer.github.io

## Goal

Migrate from historical Ghost/Buster static output to Hugo for new content, while keeping all existing legacy URLs reachable.

## Current architecture

- Legacy static site remains in repo root (historical Ghost/Buster output).
- New Hugo source lives in `hugo/`.
- GitHub Pages deploy uses workflow `.github/workflows/pages.yml`.
- Deployment merges legacy root files with Hugo build output.
- If paths overlap, Hugo output wins (copied last).

## Local development

- Hugo only preview (new content):
  - `make serve-hugo`
  - URL: http://localhost:1313/
  - Note: legacy posts are not served here.

- Combined preview (legacy + Hugo):
  - `make serve-combined`
  - URL: http://localhost:4173/
  - Use this to verify old and new URLs together.

## Important files

- Hugo config: `hugo/hugo.toml`
- Hugo content root: `hugo/content/`
- New travel posts: `hugo/content/reiseblog/`
- Workflow: `.github/workflows/pages.yml`
- Local helper script: `scripts/preview-combined.sh`
- Migration notes: `HUGO_MIGRATION.md`

## Git ignore

Root `.gitignore` ignores only local test outputs:

- `.hugo-public-test/`
- `.site-test/`
- `.DS_Store`

## Status checklist

- [x] Hugo scaffolding added
- [x] GitHub Actions workflow added for merge deploy
- [x] Combined local preview workflow added
- [x] Legacy URL compatibility validated locally
- [ ] Push changes and verify first Pages deploy
- [ ] Optionally pin Hugo version in workflow (instead of `latest`)

## Next recommended steps

1. Commit and push current changes.
2. Ensure GitHub Pages source is set to GitHub Actions.
3. Trigger workflow and validate:
   - legacy URL (example): `/how-to-use-secrets-in-azure-pipelines/`
   - new URL (example): `/reiseblog/neustart-reiseblog-mit-hugo/`
4. Decide whether to pin a fixed Hugo version in workflow.
