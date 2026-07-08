SHELL := /bin/bash
ROOT := $(CURDIR)

.PHONY: hugo-build site-assemble serve-hugo serve-combined preview-combined import-trip list-trips trip-map-assets trip-photos trip-gallery trip-day trip-day-open trip-init

hugo-build:
	hugo --source "$(ROOT)/hugo" --destination "$(ROOT)/.hugo-public-test" --minify

site-assemble: hugo-build
	rm -rf ./.site-test
	mkdir -p ./.site-test
	rsync -a ./ ./.site-test/ \
		--exclude .git/ \
		--exclude .github/ \
		--exclude hugo/ \
		--exclude .site-test/ \
		--exclude .hugo-public-test/
	mkdir -p ./.site-test/legacy
	@test -f ./index.html && cp ./index.html ./.site-test/legacy/index.html || true
	@test -f ./.site-test/legacy/index.html && perl -0777 -i -pe 's|<head>|<head>\n    <base href="/">| unless /<base href=/' ./.site-test/legacy/index.html || true
	@test -f ./index.xml && cp ./index.xml ./.site-test/legacy/index.xml || true
	rsync -a ./.hugo-public-test/ ./.site-test/

serve-hugo:
	hugo server --source hugo --bind 127.0.0.1 --port 1313

serve-combined: site-assemble
	cd ./.site-test && python3 -m http.server 4173

preview-combined:
	./scripts/preview-combined.sh 4173

import-trip:
	@test -n "$(SOURCE)" || (echo "SOURCE is required" && exit 1)
	@test -n "$(TITLE)" || (echo "TITLE is required" && exit 1)
	@test -n "$(DATE)" || (echo "DATE is required" && exit 1)
	@test -n "$(SLUG)" || (echo "SLUG is required" && exit 1)
	./scripts/import-trip.sh --source "$(SOURCE)" --title "$(TITLE)" --date "$(DATE)" --slug "$(SLUG)" --summary "$(SUMMARY)" $(if $(TEXT),--text-file "$(TEXT)",) $(if $(TRIP_DIR),--trip-dir "$(TRIP_DIR)",) $(if $(TRIP_MATCH),--trip-match "$(TRIP_MATCH)",) $(if $(FORCE),--force,)

list-trips:
	@test -n "$(SOURCE)" || (echo "SOURCE is required" && exit 1)
	./scripts/import-trip.sh --source "$(SOURCE)" --list-trips

trip-map-assets:
	@test -n "$(GPX_DIR)" || (echo "GPX_DIR is required" && exit 1)
	@test -n "$(GEOJSON_OUT)" || (echo "GEOJSON_OUT is required" && exit 1)
	python3 ./scripts/gpx_tracks_to_map_assets.py --gpx-dir "$(GPX_DIR)" --geojson-out "$(GEOJSON_OUT)" $(if $(GPX_OUT),--gpx-out "$(GPX_OUT)",) $(if $(START_NAME),--start-name "$(START_NAME)",) $(if $(TRACK_NAME),--track-name "$(TRACK_NAME)",)

trip-photos:
	@test -n "$(SRC)" || (echo "SRC is required" && exit 1)
	@test -n "$(DEST)" || (echo "DEST is required" && exit 1)
	./scripts/resize-trip-photos.sh --src "$(SRC)" --dest "$(DEST)" $(if $(MAX_WIDTH),--max-width "$(MAX_WIDTH)",) $(if $(QUALITY),--quality "$(QUALITY)",) $(if $(PREFIX),--prefix "$(PREFIX)",)

trip-gallery:
	@test -n "$(DIR)" || (echo "DIR is required" && exit 1)
	@test -n "$(GALLERY)" || (echo "GALLERY is required" && exit 1)
	./scripts/make-gallery-snippet.sh --dir "$(DIR)" --gallery-id "$(GALLERY)" $(if $(ALT),--alt "$(ALT)",)

trip-init:
	@test -n "$(TITLE)" || (echo "TITLE is required" && exit 1)
	@test -n "$(SLUG)" || (echo "SLUG is required" && exit 1)
	@test -n "$(DATE)" || (echo "DATE is required" && exit 1)
	./scripts/trip-init.sh --title "$(TITLE)" --slug "$(SLUG)" --date "$(DATE)" $(if $(SUMMARY),--summary "$(SUMMARY)",) $(if $(FORCE),--force,)

trip-day:
	@test -n "$(SLUG)$(TRIP_DIR)" || (echo "SLUG or TRIP_DIR is required" && exit 1)
	@test -n "$(DAY)" || (echo "DAY is required" && exit 1)
	@test -n "$(DATE)" || (echo "DATE is required" && exit 1)
	@test -n "$(STAGE)" || (echo "STAGE is required" && exit 1)
	@test -n "$(PHOTO_SRC)" || (echo "PHOTO_SRC is required" && exit 1)
	@test -n "$(GPX_DIR)" || (echo "GPX_DIR is required" && exit 1)
	./scripts/trip-day.sh $(if $(SLUG),--slug "$(SLUG)",) $(if $(TRIP_DIR),--trip-dir "$(TRIP_DIR)",) --day "$(DAY)" --date "$(DATE)" --stage "$(STAGE)" --photo-src "$(PHOTO_SRC)" --gpx-dir "$(GPX_DIR)" $(if $(TEXT),--text "$(TEXT)",) $(if $(TEXT_FILE),--text-file "$(TEXT_FILE)",) $(if $(START_NAME),--start-name "$(START_NAME)",) $(if $(TRACK_NAME),--track-name "$(TRACK_NAME)",) $(if $(MAX_WIDTH),--max-width "$(MAX_WIDTH)",) $(if $(QUALITY),--quality "$(QUALITY)",) $(if $(FORCE),--force,)

trip-day-open:
	@test -n "$(SLUG)$(TRIP_DIR)" || (echo "SLUG or TRIP_DIR is required" && exit 1)
	@test -n "$(DAY)" || (echo "DAY is required" && exit 1)
	@test -n "$(DATE)" || (echo "DATE is required" && exit 1)
	@test -n "$(STAGE)" || (echo "STAGE is required" && exit 1)
	@test -n "$(PHOTO_SRC)" || (echo "PHOTO_SRC is required" && exit 1)
	@test -n "$(GPX_DIR)" || (echo "GPX_DIR is required" && exit 1)
	./scripts/trip-day-open.sh $(if $(SLUG),--slug "$(SLUG)",) $(if $(TRIP_DIR),--trip-dir "$(TRIP_DIR)",) --day "$(DAY)" --date "$(DATE)" --stage "$(STAGE)" --photo-src "$(PHOTO_SRC)" --gpx-dir "$(GPX_DIR)" $(if $(TEXT),--text "$(TEXT)",) $(if $(TEXT_FILE),--text-file "$(TEXT_FILE)",) $(if $(START_NAME),--start-name "$(START_NAME)",) $(if $(TRACK_NAME),--track-name "$(TRACK_NAME)",) $(if $(MAX_WIDTH),--max-width "$(MAX_WIDTH)",) $(if $(QUALITY),--quality "$(QUALITY)",) $(if $(FORCE),--force,) $(if $(NO_SERVE),--no-serve,) $(if $(NO_OPEN_BROWSER),--no-open-browser,) $(if $(NO_OPEN_EDITOR),--no-open-editor,)
