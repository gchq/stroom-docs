#!/bin/bash

set -e

#Shell Colour constants for use in 'echo -e'
#e.g.  echo -e "My message ${GREEN}with just this text in green${NC}"
# shellcheck disable=SC2034
{
  RED='\033[1;31m'
  GREEN='\033[1;32m'
  YELLOW='\033[1;33m'
  BLUE='\033[1;34m'
  NC='\033[0m' # No Colour 
}

BUILD_TAG=stroom-docs-v$_BUILD_NUMBER
PDF_FILENAME=$BUILD_TAG.pdf
ZIP_FILENAME=$BUILD_TAG.zip
RELEASE_ARTEFACTS_DIR_NAME="release_artefacts"
RELEASE_ARTEFACTS_DIR="${BUILD_DIR}/${RELEASE_ARTEFACTS_DIR_NAME}"
RELEASE_ARTEFACTS_REL_DIR="./${RELEASE_ARTEFACTS_DIR_NAME}"

echo -e "BUILD_NUMBER:          [${GREEN}${BUILD_NUMBER}${NC}]"
echo -e "BUILD_COMMIT:          [${GREEN}${BUILD_COMMIT}${NC}]"
echo -e "BUILD_BRANCH:          [${GREEN}${BUILD_BRANCH}${NC}]"
echo -e "BUILD_TAG:             [${GREEN}${BUILD_TAG}${NC}]"
echo -e "BUILD_IS_RELEASE:      [${GREEN}${BUILD_IS_RELEASE}${NC}]"
echo -e "BUILD_IS_PULL_REQUEST: [${GREEN}${BUILD_IS_PULL_REQUEST}${NC}]"
echo -e "PDF_FILENAME:          [${GREEN}${PDF_FILENAME}${NC}]"
echo -e "ZIP_FILENAME:          [${GREEN}${ZIP_FILENAME}${NC}]"

#In order to make gitbook's pdf generation work on a headless server we need to 
#wrap the ebook-convert binary with our own wrapper script of the same name
#sudo mv ebook-convert /usr/local/bin/

echo -e "Replacing ${GREEN}VERSION${NC} and ${GREEN}BUILD_DATE${NC} tags in ${BLUE}VERSION.md${NC}"
sed -i "s/@@VERSION@@/${BUILD_TAG}/g" VERSION.md
sed -i "s/@@BUILD_DATE@@/$(date -u)/" VERSION.md

#build the gitbook
echo -e "${GREEN}Installing and building gitbook${NC}"
./container_build/runInNodeDocker.sh "gitbook install; gitbook build"

#For a markdown file to be included in the gitbook conversion to html/pdf it must be linked to in SUMMARY.md
missingFileCount=$(find ./_book/ -name "*.md" | wc -l)
if [ "${missingFileCount}" -gt 0 ]; then
  echo -e "${missingFileCount} markdown file(s) have not been converted, ensure they are linked to in ${BLUE}SUMMARY.md${NC}"
  # shellcheck disable=SC2044
  for file in $(find ./_book/ -name "*.md"); do
      echo -e "  ${RED}${file}${NC}"
  done
  echo "Failing the build"
  exit 1
fi

mkdir -p "${RELEASE_ARTEFACTS_DIR}"

#generate a pdf of the gitbook
./container_build/runInNodeDocker.sh \
  "gitbook pdf ./ \"${RELEASE_ARTEFACTS_REL_DIR}/${PDF_FILENAME}\""


echo -e "${GREEN}Removing unwanted files${NC}"
rm -v _book/*.yml
rm -v _book/*.sh

echo -e "${GREEN}Making a zip of the html content${NC}"
pushd _book
zip -r -9 "../${RELEASE_ARTEFACTS_DIR_NAME}/${ZIP_FILENAME}" ./*
popd

echo -e "${GREEN}Dumping contents of ${RELEASE_ARTEFACTS_DIR}${NC}"
ls -l "${RELEASE_ARTEFACTS_DIR}"

#We release on every commit to master
if [[ -n "$BUILD_TAG" && "${BUILD_IS_PULL_REQUEST}" != "true" ]]; then

  # Start ssh-agent and add our private ssh deploy key to it
  echo -e "${GREEN}Starting ssh-agent${NC}"
  ssh-agent -a "${SSH_AUTH_SOCK}" > /dev/null

  # SSH_DEPLOY_KEY is the private ssh key that corresponds to the public key
  # that is held in the 'deploy keys' section of the stroom repo on github
  # https://github.com/gchq/stroom-docs/settings/keys
  ssh-add - <<< "${SSH_DEPLOY_KEY}"

  git config user.name "${GITHUB_ACTOR}"
  git config user.email "${GITHUB_ACTOR}@bots.github.com"

  echo -e "Creating tag ${GREEN}${BUILD_TAG}${NC}"
  git tag \
    "${BUILD_TAG}" \
    -a \
    -m "Automated build ${BUILD_NUMBER}"

  echo -e "Pushing tag ${GREEN}${BUILD_TAG}${NC}"
  git push -q origin "${BUILD_TAG}"
else
  echo -e "${GREEN}Not a release so won't tag the repository${NC}"
fi

exit 0
