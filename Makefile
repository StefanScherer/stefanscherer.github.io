SHELL := /bin/bash
ROOT := $(CURDIR)

.PHONY: hugo-build site-assemble serve-hugo serve-combined preview-combined import-trip list-trips

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
