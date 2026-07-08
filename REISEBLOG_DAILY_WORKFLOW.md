# Reiseblog: Tagesaktuelle Updates ohne Polarsteps

Diese Anleitung ist auf dein aktuelles Hugo-Setup abgestimmt.

Ziel:
- Täglich mit wenig Aufwand schreiben
- GPS-Track als Karte anzeigen
- Kamera-Fotos webfreundlich verkleinern
- Schnell lokal prüfen und veröffentlichen

## 1) Einmal pro Reise: neuen Beitrag anlegen

Am schnellsten mit dem neuen Init-Befehl:

```bash
make trip-init TITLE="Alpen 2026" SLUG="alpen-2026" DATE=2026-07-08 SUMMARY="Roadtrip durch die Alpen"
```

Dadurch werden automatisch erstellt:

- `hugo/content/reiseblog/alpen-2026/index.md`
- `hugo/content/reiseblog/alpen-2026/route.geojson`
- `hugo/content/reiseblog/alpen-2026/route.gpx`

Beispiel-Struktur für eine neue Reise:

- `hugo/content/reiseblog/alpen-2026/index.md`
- `hugo/content/reiseblog/alpen-2026/route.geojson`
- `hugo/content/reiseblog/alpen-2026/route.gpx` (optional, wird automatisch erzeugt)
- `hugo/content/reiseblog/alpen-2026/day-01/` (Fotos)
- `hugo/content/reiseblog/alpen-2026/day-02/` (Fotos)

Minimaler Start für `index.md`:

```md
---
title: "Alpen 2026"
date: 2026-07-08
slug: "alpen-2026"
summary: "Roadtrip durch die Alpen"
---

## Überblick

{{< tripmap geojson="route.geojson" gpx="route.gpx" lang="de" >}}

## Etappen
```

Hinweis:
- `geojson` steuert die Etappen-Punkte und deren Reihenfolge.
- `gpx` zeigt die echte Track-Linie auf der Karte.

## 2) Täglicher Ablauf unterwegs (empfohlen)

### Turbo-Variante: alles mit einem Kommando

```bash
make trip-day SLUG="alpen-2026" DAY=2 DATE=2026-07-09 STAGE="Dolomiten" PHOTO_SRC="$HOME/trip/alpen-2026/raw/day-02" GPX_DIR="$HOME/trip/alpen-2026/gpx" TEXT="Kurzer Tagesbericht"
```

Komfort-Variante mit Auto-Preview + Datei oeffnen:

```bash
make trip-day-open SLUG="alpen-2026" DAY=2 DATE=2026-07-09 STAGE="Dolomiten" PHOTO_SRC="$HOME/trip/alpen-2026/raw/day-02" GPX_DIR="$HOME/trip/alpen-2026/gpx" TEXT="Kurzer Tagesbericht"
```

Was zusaetzlich passiert:
- startet bei Bedarf `hugo server` auf Port 1313
- oeffnet die Reise-Seite im Browser
- oeffnet die Reise-`index.md` in VS Code (wenn `code` CLI verfuegbar)

Was `trip-day` macht:
- skaliert Fotos nach `hugo/content/reiseblog/alpen-2026/day-02/`
- erzeugt/aktualisiert `route.geojson` und `route.gpx`
- erstellt Galerie-HTML
- hängt einen fertigen Tagesabschnitt an `index.md` an

Optional:
- statt `TEXT="..."` mit `TEXT_FILE=./day-02.md` arbeiten
- bei bereits vorhandenem Tag mit `FORCE=1` trotzdem anhängen

### Schritt A: GPX-Datei des Tages ablegen

Lege die Tagesdatei in einen Sammelordner, z. B.:

- `~/trip/alpen-2026/gpx/2026-07-08-brenner.gpx`
- `~/trip/alpen-2026/gpx/2026-07-09-dolomiten.gpx`

Wichtig:
- Dateinamen in chronologischer Reihenfolge halten (Datum vorne).

### Schritt B: Karten-Dateien aktualisieren

Aus dem Repo-Root:

```bash
make trip-map-assets GPX_DIR="$HOME/trip/alpen-2026/gpx" GEOJSON_OUT="hugo/content/reiseblog/alpen-2026/route.geojson" GPX_OUT="hugo/content/reiseblog/alpen-2026/route.gpx" START_NAME="Start"
```

Ergebnis:
- `route.geojson` wird neu erzeugt (Etappenpunkte)
- `route.gpx` wird zusammengeführt (eine Route aus allen Tagen)

### Schritt C: Fotos des Tages verkleinern

Beispiel: Rohbilder von SD-Karte oder Import-Ordner für Tag 2

```bash
make trip-photos SRC="$HOME/trip/alpen-2026/raw/day-02" DEST="hugo/content/reiseblog/alpen-2026/day-02" PREFIX="day-02" MAX_WIDTH=2200 QUALITY=82
```

Ergebnis:
- Weboptimierte JPGs in deinem Tagesordner im Beitrag
- Einheitliche Dateinamen für leichte Weiterverarbeitung

### Schritt D: Galerie-Snippet erzeugen

```bash
make trip-gallery DIR="hugo/content/reiseblog/alpen-2026/day-02" GALLERY="day-02" ALT="Dolomiten"
```

Das Kommando gibt HTML aus. Diesen Block in `index.md` unter den passenden Abschnitt kopieren.

### Schritt E: Tagesabschnitt in index.md ergänzen

Beispiel:

```md
### Tag 2 - 09.07.2026

#### Etappe: Dolomiten

Kurzer Text zum Tag.

<div class="step-gallery">
  ... aus trip-gallery ...
</div>
```

Wichtig für schöne Map-Popups:
- Name in `#### Etappe: ...` sollte zum Etappen-Namen aus den GPX-Dateinamen passen.

## 3) Lokal prüfen

Nur Hugo:

```bash
make serve-hugo
```

Kombiniert (legacy + Hugo):

```bash
make serve-combined
```

## 4) Veröffentlichen

Minimaler täglicher Git-Flow:

```bash
git add hugo/content/reiseblog/alpen-2026

git commit -m "Reiseblog: Tag 2 ergänzt"

git push
```

## 5) Praktische Tipps für unterwegs

- Bilder pro Tag in separaten Ordnern halten (`day-01`, `day-02`, ...).
- GPX-Dateien nie überschreiben, sondern täglich neue Datei erzeugen.
- Wenn Netz schwach ist: lokal mehrere Tage sammeln, dann gesammelt pushen.
- Lieber pro Tag 8-20 gute Bilder statt alles hochladen.
- Vor dem Push einmal lokal öffnen und auf Tippfehler/Map prüfen.

## 6) Was die neuen Skripte genau tun

- `scripts/gpx_tracks_to_map_assets.py`
  - Liest alle `.gpx` im Ordner (sortiert nach Dateiname)
  - Baut `route.geojson` mit Startpunkt + Tages-Endpunkten
  - Kann optional ein kombiniertes `route.gpx` schreiben

- `scripts/resize-trip-photos.sh`
  - Verkleinert Bilder auf sinnvolle Breite
  - Konvertiert in JPG mit einstellbarer Qualität
  - Benennt Dateien konsistent für den Blog

- `scripts/make-gallery-snippet.sh`
  - Erzeugt fertigen HTML-Block für die vorhandene Lightbox-Galerie

## 7) Ein-Kommando-Helfer

- `scripts/trip-init.sh`
  - Erstellt ein neues Reise-Bundle inkl. Startdateien

- `scripts/trip-day.sh`
  - Orchestriert Resize, Map-Assets und Galerie
  - Schreibt den Tagesblock direkt in die Reise-`index.md`
  - Stoppt bei Duplikat-Tag, außer mit `--force`

- `scripts/trip-day-open.sh`
  - Wie `trip-day`, plus Vorschau/Browsersprung/Editor-Open

## 8) So läuft der erste Tag ab

1. Reise einmalig anlegen:

```bash
make trip-init TITLE="Alpen 2026" SLUG="alpen-2026" DATE=2026-07-08 SUMMARY="Roadtrip durch die Alpen"
```

2. Erste GPX-Datei ablegen, z. B. `~/trip/alpen-2026/gpx/2026-07-08-brenner.gpx`.

3. Erste Fotos in einen Rohordner legen, z. B. `~/trip/alpen-2026/raw/day-01/`.

4. Tag 1 mit einem Befehl verarbeiten:

```bash
make trip-day-open SLUG="alpen-2026" DAY=1 DATE=2026-07-08 STAGE="Brenner" PHOTO_SRC="$HOME/trip/alpen-2026/raw/day-01" GPX_DIR="$HOME/trip/alpen-2026/gpx" TEXT="Start in den Urlaub, erste Etappe bis ..."
```

5. Kurz den eingefuegten Tagesblock in `index.md` nachbearbeiten und dann commit/push.
