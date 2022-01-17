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

# Returns 0 if $1 is in the array of elements passed as subsequent args
# e.g. 
# arr=( "one" "two" "three" )
# element_in "two" "${arr[@]}" # returns 0
element_in() {
  local element 
  local match="$1"
  shift
  for element; do 
    [[ "${element}" == "${match}" ]] && return 0
  done
  return 1
}

build_version() {
  local branch_name="${1:-SNAPSHOT}"; shift
  local repo_root="$1"; shift
  
  local hugo_base_url
  local site_dir="${repo_root}/public"
  local pdf_filename="${branch_name}.pdf"

  if [[ "${BUILD_BRANCH}" = "master" ]]; then
    hugo_base_url="${BASE_URL_BASE}/"
  else
    hugo_base_url="${BASE_URL_BASE}/${BUILD_BRANCH}"
  fi

  echo -e "${GREEN}-----------------------------------------------------${NC}"
  echo -e "${GREEN}Building" \
    "\nbranch_name: ${BLUE}${branch_name}${GREEN}," \
    "\nrepo_root:   ${BLUE}${repo_root}${GREEN}," \
    "\nbase_url:    ${BLUE}${hugo_base_url}${NC}"
  echo -e "${GREEN}-----------------------------------------------------${NC}"

  pushd "${repo_root}"

  echo -e "${GREEN}Converting .puml files to .puml.svg${NC}"
  ./container_build/runInPumlDocker.sh SVG

  # Build the Hugo site html
  # TODO, remove --buildDrafts arg once we merge to master
  echo -e "${GREEN}Building site HTML with Hugo${NC}"
  ./container_build/runInHugoDocker.sh build "${hugo_base_url}"

  echo -e "${GREEN}Building site PDF with pupeteer${NC}"
  ./container_build/runInPupeteerDocker.sh PDF
  mv stroom-docs.pdf "${RELEASE_ARTEFACTS_REL_DIR}/${pdf_filename}"

  if element_in "${branch_name}" "${RELEASE_BRANCHES[@]}"; then
    local site_branch_dir="${COMBINED_SITE_DIR}/${branch_name}/"
    mkdir -p "${site_branch_dir}"
    echo -e "${GREEN}Copying site HTML (${BLUE}${site_dir}${GREEN}) to combined" \
      "site (${BLUE}${site_branch_dir}${GREEN})${NC}"
    cp -r "${site_dir}"/* "${site_branch_dir}"
  else
    echo -e "${BLUE}${branch_name}${GREEN} is not a release branch so won't" \
      "add it to ${BLUE}${COMBINED_SITE_DIR}${NC}"
  fi
  
  popd
}

main() {
  setup_echo_colours

  # Array of branch names that contain a version of the site,
  # e.g. master, 7.1, 7.0, legacy
  RELEASE_BRANCHES=(
    "hugo-docsy"
  )
  #RELEASE_BRANCHES=(
    #"master"
    #"7.0"
    #"legacy"
  #)

  local PDF_FILENAME="${BUILD_TAG:-SNAPSHOT}.pdf"
  local ZIP_FILENAME="${BUILD_TAG:-SNAPSHOT}.zip"
  local RELEASE_ARTEFACTS_DIR_NAME="release_artefacts"
  local RELEASE_ARTEFACTS_DIR="${BUILD_DIR}/${RELEASE_ARTEFACTS_DIR_NAME}"
  local RELEASE_ARTEFACTS_REL_DIR="./${RELEASE_ARTEFACTS_DIR_NAME}"
  local COMBINED_SITE_DIR="${BUILD_DIR}/combined_site"
  local GIT_WORK_DIR="${BUILD_DIR}/git_work"
  #local SITE_DIR="${BUILD_DIR}/public"
  local GITHUB_PAGES_DIR="${BUILD_DIR}/gh-pages"
  local BASE_URL_BASE="https://gchq.github.io/stroom-docs"
  local GIT_REPO_URL="https://github.com/gchq/stroom-docs.git"

  echo -e "BUILD_BRANCH:          [${GREEN}${BUILD_BRANCH}${NC}]"
  echo -e "BUILD_COMMIT:          [${GREEN}${BUILD_COMMIT}${NC}]"
  echo -e "BUILD_DIR:             [${GREEN}${BUILD_DIR}${NC}]"
  echo -e "BUILD_IS_PULL_REQUEST: [${GREEN}${BUILD_IS_PULL_REQUEST}${NC}]"
  echo -e "BUILD_IS_RELEASE:      [${GREEN}${BUILD_IS_RELEASE}${NC}]"
  echo -e "BUILD_NUMBER:          [${GREEN}${BUILD_NUMBER}${NC}]"
  echo -e "BUILD_TAG:             [${GREEN}${BUILD_TAG}${NC}]"
  echo -e "LOCAL_BUILD:           [${GREEN}${LOCAL_BUILD}${NC}]"
  echo -e "PDF_FILENAME:          [${GREEN}${PDF_FILENAME}${NC}]"
  echo -e "PWD:                   [${GREEN}$(pwd)${NC}]"
  echo -e "RELEASE_BRANCHES:      [${GREEN}${RELEASE_BRANCHES[*]}${NC}]"
  echo -e "ZIP_FILENAME:          [${GREEN}${ZIP_FILENAME}${NC}]"

  mkdir -p "${RELEASE_ARTEFACTS_DIR}"
  mkdir -p "${COMBINED_SITE_DIR}"
  mkdir -p "${GIT_WORK_DIR}"
  mkdir -p "${GITHUB_PAGES_DIR}"

  # TODO Need to check for broken simple markdown links

  # Build the commit/tag/pr that triggered this script to run
  # to ensure the site and PDF build ok.
  build_version "${BUILD_BRANCH}" "${BUILD_DIR}"

  #echo -e "Replacing ${GREEN}VERSION${NC} and ${GREEN}BUILD_DATE${NC}" \
    #"tags in ${BLUE}VERSION.md${NC}"
  #sed -i "s/@@VERSION@@/${BUILD_TAG:-SNAPSHOT}/g" VERSION.md
  #sed -i "s/@@BUILD_DATE@@/$(date -u)/" VERSION.md

  # TODO get this working for hugo content
  #echo -e "${GREEN}Checking all .md files for broken links${NC}"
  #./broken_links.sh

  pushd "${GIT_WORK_DIR}"

  local hugo_base_url
  for branch_name in "${RELEASE_BRANCHES[@]}"; do

    # We may have already built this branch if it had the commit
    # that triggered the build, so ignore it
    if [[ "${branch_name}" != "${BUILD_BRANCH}" ]]; then
      echo -e "${GREEN}Cloning branch ${BLUE}${branch_name}${GREEN} of" \
        "${BLUE}${GIT_REPO_URL}${GREEN} into ${BLUE}./${branch_name}${NC}"

      git \
        clone \
        --depth 1 \
        --branch "${branch_name}" \
        --single-branch \
        --recurse-submodules \
        "${GIT_REPO_URL}" \
        "./${branch_name}"

      # Run the build for this branch in the self named dir
      build_version "${branch_name}" "${branch_name}"

    # TODO: AT # Do we want the docs for unreleased code to be on / or /master?
      if [[ "${BUILD_BRANCH}" = "master" ]]; then
        hugo_base_url="${BASE_URL_BASE}/"
      else
        hugo_base_url="${BASE_URL_BASE}/${BUILD_BRANCH}"
      fi
    else
      echo -e "${GREEN}Skipping build for ${BLUE}${branch_name}${NC}"
    fi
  done

  popd

  #echo -e "${GREEN}Removing unwanted files${NC}"
  #rm -v "${SITE_DIR}"/*.yml
  #rm -v "${SITE_DIR}"/*.sh
  #rm -v -rf "${SITE_DIR}/.github"

  if element_in "${BUILD_BRANCH}" "${RELEASE_BRANCHES[@]}"; then
    echo -e "${GREEN}Making a zip of the combined site html content${NC}"
    pushd "${COMBINED_SITE_DIR}"
    zip -r -9 "${RELEASE_ARTEFACTS_DIR}/${ZIP_FILENAME}" ./*
    popd

    echo -e "${GREEN}Copying from ${BLUE}${COMBINED_SITE_DIR}/${GREEN}" \
      "to ${BLUE}${GITHUB_PAGES_DIR}/${GREEN}${NC}"
    cp -r "${COMBINED_SITE_DIR}"/* "${GITHUB_PAGES_DIR}/"

  else
    echo -e "${GREEN}${BLUE}${BUILD_BRANCH}${GREEN} is not a release branch" \
    "so skip zip creation${NC}"
  fi

  echo -e "${GREEN}Dumping contents of ${RELEASE_ARTEFACTS_DIR}${NC}"
  ls -1 "${RELEASE_ARTEFACTS_DIR}/"

  # TODO do we want to release on each commit or only on tagged commits
  if [[ "${LOCAL_BUILD}" != "true" \
    && -n "$BUILD_TAG" \
    && "${BUILD_IS_PULL_REQUEST}" != "true" ]] ; then

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
