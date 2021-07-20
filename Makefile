# -*- coding: utf-8-unix -*-

VERSION = `date +%Y%m%d%H%M`

clean:
	rm -rf dist

deploy:
	$(MAKE) dist
	$(if $(shell git status --porcelain),\
	  $(error "Uncommited changes!"))
	@echo "Uploading HTML files..."
	aws s3 sync dist/ s3://otsaloma.io/catapult/ \
	--exclude "*" \
	--include "*.html" \
	--acl public-read \
	--cache-control "public, max-age=3600"
	@echo "Uploading everything else..."
	aws s3 sync dist/ s3://otsaloma.io/catapult/ \
	--exclude "*.html" \
	--acl public-read \
	--cache-control "public, max-age=86400"

dist:
	$(MAKE) clean
	mkdir dist
	cp *.css *.html *.ico *.jpg *.png *.svg dist
	sed -ri "s|\?v=dev\"|?v=$(VERSION)\"|g" dist/*.html
	! grep "?v=dev" dist/*.html
	./bundle-assets.py dist/*.html

.PHONY: clean deploy dist
