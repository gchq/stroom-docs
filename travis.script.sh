#!/bin/bash

set -e

#Shell Colour constants for use in 'echo -e'
#e.g.  echo -e "My message ${GREEN}with just this text in green${NC}"
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
NC='\033[0m' # No Colour 

BUILD_NAME=stroom-docs-v$TRAVIS_BUILD_NUMBER
PDF_FILENAME=$BUILD_NAME.pdf
ZIP_FILENAME=$BUILD_NAME.zip

#Dump all the travis env vars to the console for debugging
echo -e "TRAVIS_BUILD_NUMBER: [${GREEN}${TRAVIS_BUILD_NUMBER}${NC}]"
echo -e "TRAVIS_COMMIT:       [${GREEN}${TRAVIS_COMMIT}${NC}]"
echo -e "TRAVIS_BRANCH:       [${GREEN}${TRAVIS_BRANCH}${NC}]"
echo -e "TRAVIS_TAG:          [${GREEN}${TRAVIS_TAG}${NC}]"
echo -e "TRAVIS_PULL_REQUEST: [${GREEN}${TRAVIS_PULL_REQUEST}${NC}]"
echo -e "TRAVIS_EVENT_TYPE:   [${GREEN}${TRAVIS_EVENT_TYPE}${NC}]"
echo -e "BUILD_NAME:          [${GREEN}${BUILD_NAME}${NC}]"
echo -e "PDF_FILENAME:        [${GREEN}${PDF_FILENAME}${NC}]"
echo -e "ZIP_FILENAME:        [${GREEN}${ZIP_FILENAME}${NC}]"

#In order to make gitbook's pdf generation work on a headless server we need to 
#wrap the ebook-convert binary with our own wrapper script of the same name
sudo mv ebook-convert /usr/local/bin/

#Replace the @@VERSION@@ tag in the VERSION.md file
echo -e "${GREEN}Replacing VERSION tag in ${BLUE}VERSION.md${NC}"
sed -i "s/@@VERSION@@/${BUILD_NAME}/" VERSION.md

#build the gitbook
echo -e "${GREEN}Installing and building gitbook${NC}"
gitbook install
gitbook build

echo -e "${GREEN}Highlighting un-converted markdown files as they could be missing from the ${BLUE}SUMMARY.md${NC}"
find ./_book/ -name "*.md"

#generate a pdf of the gitbook
gitbook pdf ./ ./${PDF_FILENAME}

echo -e "${GREEN}Removing unwanted files${NC}"
rm -v _book/.travis.yml
rm -v _book/*.yml
rm -v _book/*.md
rm -v _book/*.sh

echo -e "${GREEN}Making a zip of the html content${NC}"
pushd _book
zip -r -9 ../${ZIP_FILENAME} ./*
popd

if [[ "$TRAVIS_BRANCH" == "master" ]]; then
    git config --global user.email "builds@travis-ci.com"
    git config --global user.name "Travis CI"
    export GIT_TAG=${BUILD_NAME}

    echo -e "Creating tag ${GREEN}${GIT_TAG}${NC}"
    git tag $GIT_TAG -a -m "Automated build $TRAVIS_BUILD_NUMBER" 2>/dev/null;
    git push -q https://$TAGPERM@github.com/gchq/stroom-docs --tags >/dev/null 2>&1;
else
    echo -e "${GREEN}Branch is not master so won't tag the repository${NC}"
fi
