#!/bin/bash

set -eo pipefail
IFS=$'\n\t'

setup_echo_colours() {
  # Exit the script on any error
  set -e

  # shellcheck disable=SC2034
  if [ "${MONOCHROME}" = true ]; then
    RED=''
    GREEN=''
    YELLOW=''
    BLUE=''
    BLUE2=''
    DGREY=''
    NC='' # No Colour
  else 
    RED='\033[1;31m'
    GREEN='\033[1;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[1;34m'
    BLUE2='\033[1;34m'
    DGREY='\e[90m'
    NC='\033[0m' # No Colour
  fi
}

setup_ssh_agent() {
  # See if there is already a socket for ssh-agent
  if [[ -S "${SSH_AUTH_SOCK}" ]]; then
    echo -e "${GREEN}ssh-agent already bound to ${BLUE}SSH_AUTH_SOCK${NC}"
  else
    # Start ssh-agent and add our private ssh deploy key to it
    echo -e "${GREEN}Starting ssh-agent${NC}"
    ssh-agent -a "${SSH_AUTH_SOCK}" > /dev/null
  fi

  # SSH_DEPLOY_KEY is the private ssh key that corresponds to the public key
  # that is held in the 'deploy keys' section of the stroom repo on github
  # https://github.com/gchq/stroom/settings/keys
  echo -e "${GREEN}Adding ssh key${NC}"
  ssh-add - <<< "${SSH_DEPLOY_KEY}"
}

main() {
  setup_echo_colours

  PDF_FILENAME="${BUILD_TAG:-SNAPSHOT}.pdf"
  ZIP_FILENAME="${BUILD_TAG:-SNAPSHOT}.zip"
  RELEASE_ARTEFACTS_DIR_NAME="release_artefacts"
  RELEASE_ARTEFACTS_DIR="${BUILD_DIR}/${RELEASE_ARTEFACTS_DIR_NAME}"
  RELEASE_ARTEFACTS_REL_DIR="./${RELEASE_ARTEFACTS_DIR_NAME}"
  GITBOOK_DIR="${BUILD_DIR}/_book"
  GITHUB_PAGES_DIR="${BUILD_DIR}/gh-pages"

  echo -e "BUILD_NUMBER:          [${GREEN}${BUILD_NUMBER}${NC}]"
  echo -e "BUILD_COMMIT:          [${GREEN}${BUILD_COMMIT}${NC}]"
  echo -e "BUILD_BRANCH:          [${GREEN}${BUILD_BRANCH}${NC}]"
  echo -e "BUILD_TAG:             [${GREEN}${BUILD_TAG}${NC}]"
  echo -e "BUILD_IS_RELEASE:      [${GREEN}${BUILD_IS_RELEASE}${NC}]"
  echo -e "BUILD_IS_PULL_REQUEST: [${GREEN}${BUILD_IS_PULL_REQUEST}${NC}]"
  echo -e "PDF_FILENAME:          [${GREEN}${PDF_FILENAME}${NC}]"
  echo -e "ZIP_FILENAME:          [${GREEN}${ZIP_FILENAME}${NC}]"

  # In order to make gitbook's pdf generation work on a headless server we need to 
  # wrap the ebook-convert binary with our own wrapper script of the same name
  # sudo mv ebook-convert /usr/local/bin/

  echo -e "Replacing ${GREEN}VERSION${NC} and ${GREEN}BUILD_DATE${NC}" \
    "tags in ${BLUE}VERSION.md${NC}"
  sed -i "s/@@VERSION@@/${BUILD_TAG:-SNAPSHOT}/g" VERSION.md
  sed -i "s/@@BUILD_DATE@@/$(date -u)/" VERSION.md

  echo -e "${GREEN}Checking all .md files for broken links${NC}"
  ./broken_links.sh

  # build the gitbook
  echo -e "${GREEN}Installing and building gitbook${NC}"
  ./container_build/runInNodeDocker.sh "gitbook install; gitbook build"

  # For a markdown file to be included in the gitbook conversion to html/pdf
  # it must be linked to in SUMMARY.md
  missingFileCount=$(find "${GITBOOK_DIR}/" -name "*.md" | wc -l)
  if [ "${missingFileCount}" -gt 0 ]; then
    echo -e "${missingFileCount} markdown file(s) have not been converted," \
      "ensure they are linked to in ${BLUE}SUMMARY.md${NC}"
    # shellcheck disable=SC2044
    for file in $(find "${GITBOOK_DIR}/" -name "*.md"); do
        echo -e "  ${RED}${file}${NC}"
    done
    echo "Failing the build"
    exit 1
  fi

  mkdir -p "${RELEASE_ARTEFACTS_DIR}"

  # generate a pdf of the gitbook
  ./container_build/runInNodeDocker.sh \
    "gitbook pdf ./ \"${RELEASE_ARTEFACTS_REL_DIR}/${PDF_FILENAME}\""

  echo -e "${GREEN}Removing unwanted files${NC}"
  rm -v "${GITBOOK_DIR}"/*.yml
  rm -v "${GITBOOK_DIR}"/*.sh
  rm -v -rf "${GITBOOK_DIR}/.github"

  echo -e "${GREEN}Making a zip of the html content${NC}"
  pushd "${GITBOOK_DIR}"
  zip -r -9 "${RELEASE_ARTEFACTS_DIR}/${ZIP_FILENAME}" ./*
  popd

  echo -e "${GREEN}Dumping contents of ${RELEASE_ARTEFACTS_DIR}${NC}"
  ls -1 "${RELEASE_ARTEFACTS_DIR}/"

  # We release on every commit to master
  if [[ -n "$BUILD_TAG" && "${BUILD_IS_PULL_REQUEST}" != "true" ]]; then

    mkdir -p "${GITHUB_PAGES_DIR}"

    echo -e "${GREEN}Copying from ${GITBOOK_DIR}/ to ${GITHUB_PAGES_DIR}/${NC}"
    cp -r "${GITBOOK_DIR}"/* "${GITHUB_PAGES_DIR}/"

    setup_ssh_agent

    git config user.name "${GITHUB_ACTOR}"
    git config user.email "${GITHUB_ACTOR}@bots.github.com"

    # Tag the commit so we can create a release against it in github
    echo -e "Creating tag ${GREEN}${BUILD_TAG}${NC}"
    git tag \
      "${BUILD_TAG}" \
      -a \
      -m "Automated build ${BUILD_NUMBER}"

    echo -e "Pushing tag ${GREEN}${BUILD_TAG}${NC}"
    git push \
      -q \
      origin \
      "${BUILD_TAG}"
  else
    echo -e "${GREEN}Not a release so won't tag the repository${NC}"
  fi
}

main "$@"
