SHELL := /bin/bash

.PHONY: hugo-build site-assemble serve-hugo serve-combined preview-combined

hugo-build:
	hugo --source hugo --destination ./.hugo-public-test --minify

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
