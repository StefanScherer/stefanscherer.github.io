# Hugo-Migration mit URL-Kompatibilitaet

Dieses Repository enthaelt weiterhin den bestehenden, statischen Ghost/Buster-Output im Root.

Neu hinzugekommen ist ein Hugo-Quellprojekt unter `hugo/`.

## Ziel

- neue Reisebeitraege mit Hugo pflegen
- alte Blog-URLs unveraendert erreichbar halten
- Deployment ueber GitHub Actions automatisieren

## Wie das Deployment funktioniert

Der Workflow in `.github/workflows/pages.yml` baut Hugo und kombiniert anschliessend:

1. den kompletten bisherigen Root-Inhalt (Legacy)
2. den Hugo-Build-Output aus `hugo/`

Danach wird das kombinierte Ergebnis auf GitHub Pages deployed.

Wichtig: Wenn Hugo eine Datei mit gleichem Pfad erzeugt (z. B. `index.html`), dann gewinnt die Hugo-Datei.

## Lokal testen

Voraussetzung: Hugo installiert.

```bash
hugo server --source hugo
```

Dann ist die neue Hugo-Seite lokal erreichbar, waehrend Legacy-Dateien im Repo weiter bestehen.

Hinweis: Der Hugo-Server zeigt nur Hugo-Inhalte. Legacy-Posts aus dem Repo-Root sind dort nicht sichtbar.

Fuer eine kombinierte lokale Vorschau (Legacy + Hugo) nutze:

```bash
make serve-combined
```

Danach sind alte und neue URLs gemeinsam unter `http://localhost:4173/` testbar.

## Neue Reiseposts anlegen

Neue Inhalte unter:

- `hugo/content/reiseblog/`

Empfohlenes Frontmatter:

```yaml
---
title: "Mein Beitrag"
date: 2026-07-07
slug: "mein-beitrag"
summary: "Kurze Vorschau"
---
```

Die URL wird durch `hugo/hugo.toml` als `/reiseblog/:slug/` erzeugt.

## Legacy-URLs erhalten

Alte Pfade bleiben erhalten, solange die Legacy-Dateien im Root nicht geloescht oder verschoben werden.
