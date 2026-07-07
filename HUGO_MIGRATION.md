# Hugo-Migration mit URL-Kompatibilitaet

Dieses Repository enthaelt weiterhin den bestehenden, statischen Ghost/Buster-Output im Root.

Neu hinzugekommen ist ein Hugo-Quellprojekt unter `hugo/`.

## Ziel

- neue Reisebeiträge mit Hugo pflegen
- alte Blog-URLs unveraendert erreichbar halten
- Deployment über GitHub Actions automatisieren

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

## Reise-Import aus externen Tools (z. B. Polarsteps)

Fuer einen schrittweisen Import pro Reise ist ein Helfer-Skript vorhanden:

```bash
make import-trip \
	SOURCE=/pfad/zum/export-ordner \
	TITLE="Cabriotour immer der Sonne nach" \
	DATE=2026-07-07 \
	SLUG=cabriotour-immer-der-sonne-nach \
	SUMMARY="Importierte Reise"
```

Optional kann ein eigener Markdown-Text uebergeben werden:

```bash
make import-trip \
	SOURCE=/pfad/zum/export-ordner \
	TITLE="Cabriotour immer der Sonne nach" \
	DATE=2026-07-07 \
	SLUG=cabriotour-immer-der-sonne-nach \
	TEXT=/pfad/zur/reise-notiz.md
```

Ergebnis:

- neues Page-Bundle unter `hugo/content/reiseblog/<slug>/`
- `index.md` mit Frontmatter und Basistext
- alle Bilder aus dem Exportordner im selben Bundle
- automatisch erzeugte Galerie im Beitrag

Wenn dein Export mehrere Reisen enthaelt, liste zuerst passende Reiseordner:

```bash
make list-trips SOURCE=/pfad/zum/export-root
```

Danach importierst du gezielt eine Reise ueber `TRIP_MATCH` oder `TRIP_DIR`:

```bash
make import-trip \
	SOURCE=/pfad/zum/export-root \
	TRIP_MATCH=cabriotour \
	TITLE="Cabriotour immer der Sonne nach" \
	DATE=2025-09-20 \
	SLUG=cabriotour-immer-der-sonne-nach

# Vorhandenen Beitrag mit gleichem Slug ueberschreiben:
make import-trip \
	SOURCE=/pfad/zum/export-root \
	TRIP_MATCH=cabriotour \
	TITLE="Cabriotour immer der Sonne nach" \
	DATE=2025-09-20 \
	SLUG=cabriotour-immer-der-sonne-nach \
	FORCE=1
```

## Legacy-URLs erhalten

Alte Pfade bleiben erhalten, solange die Legacy-Dateien im Root nicht geloescht oder verschoben werden.
