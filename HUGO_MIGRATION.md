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
make serve-hugo
```

Dann ist die neue Hugo-Seite lokal erreichbar, waehrend Legacy-Dateien im Repo weiter bestehen.

Hinweis: Der Hugo-Server zeigt nur Hugo-Inhalte. Legacy-Posts aus dem Repo-Root sind dort nicht sichtbar.

Fuer eine kombinierte lokale Vorschau (Legacy + Hugo) nutze:

```bash
make serve-combined
```

Danach sind alte und neue URLs gemeinsam unter `http://localhost:4173/` testbar.

Nur neu bauen (ohne Serverstart):

```bash
make site-assemble
```

Das Ergebnis liegt dann unter `.site-test/`.

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
	DATE=2025-09-20 \
	SLUG=cabriotour-immer-der-sonne-nach \
	SUMMARY="Roadtrip vom 20.09.2025 bis 27.09.2025"
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
- automatisch erzeugte Galerie pro Etappe
- Lightbox auf derselben Seite (kein neuer Tab)

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
	SLUG=cabriotour-immer-der-sonne-nach \
	SUMMARY="Roadtrip vom 20.09.2025 bis 27.09.2025"

# Oder exakt ueber den Trip-Ordner:
make import-trip \
	SOURCE=/pfad/zum/export-root \
	TRIP_DIR=/pfad/zum/export-root/cabriotour-immer-der-sonne-nach_24486935 \
	TITLE="Cabriotour immer der Sonne nach" \
	DATE=2025-09-20 \
	SLUG=cabriotour-immer-der-sonne-nach \
	SUMMARY="Roadtrip vom 20.09.2025 bis 27.09.2025"

# Vorhandenen Beitrag mit gleichem Slug ueberschreiben:
make import-trip \
	SOURCE=/pfad/zum/export-root \
	TRIP_MATCH=cabriotour \
	TITLE="Cabriotour immer der Sonne nach" \
	DATE=2025-09-20 \
	SLUG=cabriotour-immer-der-sonne-nach \
	SUMMARY="Roadtrip vom 20.09.2025 bis 27.09.2025" \
	FORCE=1
```

Beispiel fuer eine andere Reise:

```bash
make import-trip \
	SOURCE=user_data/trip \
	TRIP_DIR=user_data/trip/grand-tour_25988711 \
	TITLE="Grand Tour" \
	DATE=2026-05-23 \
	SLUG=grand-tour \
	SUMMARY="Roadtrip vom 23.05.2026 bis 31.05.2026" \
	FORCE=1
```

## Bekannte Limitierung Polarsteps-Reihenfolge

Die aktuelle Exportstruktur in diesem Repo liefert pro Step in `trip.json` keine vollstaendige Medienliste (`media_items`) und keine nutzbaren `main_media_item_path`-Werte.

Die Importlogik versucht daher zuerst, Reihenfolgereferenzen direkt aus den Step-Objekten in `trip.json` zu erkennen. Wenn dort keine Referenzen vorhanden sind, verwendet sie eine deterministische Dateinamen-Fallback-Sortierung.

Konsequenz: Die exakte Polarsteps-UI-Reihenfolge kann bei manchen Schritten nicht zu 100% rekonstruiert werden.

## Legacy-URLs erhalten

Alte Pfade bleiben erhalten, solange die Legacy-Dateien im Root nicht geloescht oder verschoben werden.
