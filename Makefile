build:
	stack exec s build

clean:
	stack exec s clean

test: build
	firefox _site/index.html

ct: clean test

publish: build
	cp -r _site/* _master/
	cd _master/; \
	git add .; \
	git commit; \
	git push; \
	cd

.PHONY: build clean test publish
