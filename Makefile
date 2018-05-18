build:
	stack exec s build

copy:
	cp -r _site/* _master/

publish:
	cd _master/
	git add .
	git commit
	git push
	cd
