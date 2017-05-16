#!/bin/sh

#The pushing of code to the gh-pages branch will be handled by travis-ci but this is here for reference

#created local and remote gh-pages branch using
#git subtree split --prefix war -b gh-pages
#git push -f origin gh-pages:gh-pages

git subtree push --prefix war origin gh-pages
