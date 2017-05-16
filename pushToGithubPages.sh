#!/bin/sh

#The pushing of code to the gh-pages branch will be handled by travis-ci but this is here for reference



#Create a new empty gh-pages branch
git checkout --orphan gh-pages
git reset
git commit --allow-empty -m 'Initial commit'
git checkout --force master

#ensure 'build' is in .gitignore

#create directory build that is backed by the gh-pages branch
git worktree add build gh-pages

#build the gitbook and copy it into the build dir
gitbook install && gitbook build
gitbook pdf ./ ./stroom-docs.pdf
rsync -avr --delete --exclude '.git' ./_book/ ./build/
