build:
	stack exec s build

test: build
	firefox _site/index.html

publish: build
	cp -r _site/* _master/
	cd _master/; \
	git add .; \
	git commit; \
 	git push; \
	cd

.PHONY: build test publish
