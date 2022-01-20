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
  
  #local hugo_base_url
  local site_dir="${repo_root}/public"
  local pdf_filename="${BUILD_TAG:-SNAPSHOT}_stroom-${branch_name}.pdf"

  #if [[ "${BUILD_BRANCH}" = "master" ]]; then
    #hugo_base_url="${BASE_URL_BASE}/"
  #else
    #hugo_base_url="${BASE_URL_BASE}/${BUILD_BRANCH}"
  #fi
  #hugo_base_url="${BASE_URL_BASE}/${BUILD_BRANCH}"

  # Scrape the Hugo config to find out what the latest version is
  local latest_version
  latest_version="$( \
    grep  -e "^\s*url_latest_version" "${BUILD_DIR}/config.toml" \
    | sed -r 's|[^"]*".*/([^"]+)"|\1|' \
  )"

  echo -e "${GREEN}-----------------------------------------------------${NC}"
  echo -e "${GREEN}Building" \
    "\n  branch_name:     ${BLUE}${branch_name}${GREEN}," \
    "\n  repo_root:       ${BLUE}${repo_root}${GREEN}," \
    "\n  latest_version:  ${BLUE}${latest_version}${GREEN},"
    #"\n  base_url:        ${BLUE}${hugo_base_url}${NC}"
  echo -e "${GREEN}-----------------------------------------------------${NC}"

  pushd "${repo_root}"

  echo -e "${GREEN}Converting all .puml files to .puml.svg${NC}"
  ./container_build/runInPumlDocker.sh SVG

  # Build the Hugo site html
  # TODO, remove --buildDrafts arg once we merge to master
  echo -e "${GREEN}Building site HTML with Hugo${NC}"
  #./container_build/runInHugoDocker.sh build "${hugo_base_url}"
  ./container_build/runInHugoDocker.sh build

  echo -e "${GREEN}Building whole site PDF for this branch${NC}"
  ./container_build/runInPupeteerDocker.sh PDF

  # Don't want to release anything for master
  if [[ "${branch_name}" != "master" ]]; then
    # Renamed the gennerated PDF
    mv stroom-docs.pdf "${RELEASE_ARTEFACTS_REL_DIR}/${pdf_filename}"

    make_single_version_zip

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
  fi
  
  popd
}

# We want a site for a single version that doesn't know about any of the
# others.
make_single_version_zip() {
  local single_site_version_dir="${SINGLE_SITE_DIR}/${branch_name}"
  local single_ver_zip_filename="${BUILD_TAG:-SNAPSHOT}_stroom-${branch_name}.pdf"
  mkdir -p "${single_site_version_dir}"
  cp -r "${site_dir}"/* "${single_site_version_dir}/"

  pushd "${single_site_version_dir}"

  # No point having the warning banner for it being an old version if it is
  # the only one
  echo -e "${GREEN}Updating config file ${CONFIG_FILENAME} (archived_version=false)${NC}"
  sed \
    --in-place'' \
    --regexp-extended \
    --expression "s/^  archived_version = .*/  archived_version = false/" \
    "${CONFIG_FILENAME}"

  # This is a single version site so remove all the version blocks i.e.
  # everything inside these tags, including the tags
  #   <<<VERSION_BLOCK_START>>>
  #   ...
  #   <<<VERSION_BLOCK_END>>>
  # TODO This is a bit hacky so am open to ideas
  echo -e "${GREEN}Updating config file ${BLUE}${CONFIG_FILENAME}${GREEN}" \
    "(remove versions)${NC}"
  sed \
    --in-place'' \
    '/<<<VERSION_BLOCK_START>>>/,/<<<VERSION_BLOCK_END>>>/d' \
    "${CONFIG_FILENAME}"

  zip \
    --recurse-paths \
    --quiet \
    -9 \
    "${RELEASE_ARTEFACTS_DIR}/${single_ver_zip_filename}" \
    ./*

  popd
}

create_redirect_page() {
  echo -e "${GREEN}Creating root redirect page with latest version" \
    "${BLUE}${latest_version}${NC}"
  sed \
    --regexp-extended \
    --expression "s/<<<LATEST_VERSION>>>/${latest_version}/g" \
    "${BUILD_DIR}/index.html.template" \
    > "${COMBINED_SITE_DIR}/index.html"
}

create_release_tag() {
  setup_ssh_agent

  git config user.name "${GITHUB_ACTOR}"
  git config user.email "${GITHUB_ACTOR}@bots.github.com"

  pushd "${BUILD_DIR}"

  # Tag the commit so we can create a release against it in github
  echo -e "Creating git tag ${GREEN}${BUILD_TAG}${NC}"
  git tag \
    "${BUILD_TAG}" \
    -a \
    -m "Automated build ${BUILD_NUMBER}"

  echo -e "Pushing tag ${GREEN}${BUILD_TAG}${NC}"
  git push \
    -q \
    origin \
    "${BUILD_TAG}"
}

main() {
  setup_echo_colours

  # Array of branch names that contain a version of the site,
  # e.g. 7.1, 7.0, legacy
  # A site will be built for each one to create one big combined site
  # that will be rsync'd into gh-pages and zipped up.
  # A PDF will be generated for each one.

  # gh-pages will look roughly like:
  #   / # Will contain copy of the site of the latest version
  #   /legacy/
  #   /7.0/
  #   /7.1/
  #   ...
  # Master should not be published to ghpages or released.
  RELEASE_BRANCHES=(
    "hugo-docsy"
  )
  #RELEASE_BRANCHES=(
    #"master"
    #"7.0"
    #"legacy"
  #)

  local PDF_FILENAME_BASE="${BUILD_TAG:-SNAPSHOT}"
  local ZIP_FILENAME="${BUILD_TAG:-SNAPSHOT}.zip"
  local RELEASE_ARTEFACTS_DIR_NAME="release_artefacts"
  local RELEASE_ARTEFACTS_DIR="${BUILD_DIR}/${RELEASE_ARTEFACTS_DIR_NAME}"
  local RELEASE_ARTEFACTS_REL_DIR="./${RELEASE_ARTEFACTS_DIR_NAME}"
  local COMBINED_SITE_DIR="${BUILD_DIR}/_combined_site"
  local SINGLE_SITE_DIR="${BUILD_DIR}/_single_site"
  local GIT_WORK_DIR="${BUILD_DIR}/_git_work"
  #local SITE_DIR="${BUILD_DIR}/public"
  local GITHUB_PAGES_DIR="${BUILD_DIR}/_gh-pages"
  #local BASE_URL_BASE="/stroom-docs"
  local GIT_REPO_URL="https://github.com/gchq/stroom-docs.git"
  local CONFIG_FILENAME="config.toml"

  echo -e "BUILD_BRANCH:          [${GREEN}${BUILD_BRANCH}${NC}]"
  echo -e "BUILD_COMMIT:          [${GREEN}${BUILD_COMMIT}${NC}]"
  echo -e "BUILD_DIR:             [${GREEN}${BUILD_DIR}${NC}]"
  echo -e "BUILD_IS_PULL_REQUEST: [${GREEN}${BUILD_IS_PULL_REQUEST}${NC}]"
  echo -e "BUILD_IS_RELEASE:      [${GREEN}${BUILD_IS_RELEASE}${NC}]"
  echo -e "BUILD_NUMBER:          [${GREEN}${BUILD_NUMBER}${NC}]"
  echo -e "BUILD_TAG:             [${GREEN}${BUILD_TAG}${NC}]"
  echo -e "LOCAL_BUILD:           [${GREEN}${LOCAL_BUILD}${NC}]"
  echo -e "PDF_FILENAME_BASE:     [${GREEN}${PDF_FILENAME_BASE}${NC}]"
  echo -e "PWD:                   [${GREEN}$(pwd)${NC}]"
  echo -e "RELEASE_BRANCHES:      [${GREEN}${RELEASE_BRANCHES[*]}${NC}]"
  echo -e "ZIP_FILENAME:          [${GREEN}${ZIP_FILENAME}${NC}]"

  mkdir -p "${RELEASE_ARTEFACTS_DIR}"
  mkdir -p "${COMBINED_SITE_DIR}"
  mkdir -p "${GIT_WORK_DIR}"
  mkdir -p "${GITHUB_PAGES_DIR}"
  mkdir -p "${SINGLE_SITE_DIR}"

  # TODO Need to check for broken simple markdown links

  # Build the commit/tag/pr that triggered this script to run
  # to ensure the site and PDF build ok.
  build_version "${BUILD_BRANCH}" "${BUILD_DIR}"

  # TODO get this working for hugo content
  #echo -e "${GREEN}Checking all .md files for broken links${NC}"
  #./broken_links.sh

  pushd "${GIT_WORK_DIR}"

  #local hugo_base_url
  for branch_name in "${RELEASE_BRANCHES[@]}"; do

    if ! git show-ref --quiet --verify "refs/heads/${branch_name}"; then
      echo -e "${RED}ERROR: Branch ${BLUE}${branch_name}${RED}" \
        "does not exist. Check contents of RELEASE_BRANCHES array.${NC}"
      exit 1
    fi

    # We may have already built this branch if it had the commit
    # that triggered the build, so ignore it
    if [[ "${branch_name}" != "${BUILD_BRANCH}" ]]; then

      echo -e "${GREEN}Cloning branch ${BLUE}${branch_name}${GREEN} of" \
        "${BLUE}${GIT_REPO_URL}${GREEN} into ${BLUE}./${branch_name}${NC}"

      # Clone the required branch into a dir with the name of the branch
      git \
        clone \
        --depth 1 \
        --branch "${branch_name}" \
        --single-branch \
        --recurse-submodules \
        "${GIT_REPO_URL}" \
        "./${branch_name}"

      # Run the build for this branch in the self named dir
      build_version "${branch_name}" "${GIT_WORK_DIR}/${branch_name}"

      #hugo_base_url="${BASE_URL_BASE}/${BUILD_BRANCH}"
    else
      echo -e "${GREEN}Skipping build for ${BLUE}${branch_name}${NC}"
    fi
  done

  popd

  #echo -e "${GREEN}Removing unwanted files${NC}"
  #rm -v "${SITE_DIR}"/*.yml
  #rm -v "${SITE_DIR}"/*.sh
  #rm -v -rf "${SITE_DIR}/.github"

  # In the absence of url rewriting on github pages, copy the latest
  # branch into the root
  #if [[ -d "${COMBINED_SITE_DIR}/${latest_version}" ]]; then
    #echo -e "${GREEN}Copying contents of " \
      #"${BLUE}${COMBINED_SITE_DIR}/${latest_version}/${GREEN} to" \
      #"${BLUE}${GITHUB_PAGES_DIR}/${NC}"
    #cp \
      #-r \
      #"${COMBINED_SITE_DIR}/${latest_version}/"*
      #"${GITHUB_PAGES_DIR}/"
  #fi

  # In the absence of url rewriting on github pages create an index.html
  # that does a redirect to the latest version e.g. / => /7.1
  create_redirect_page

  #if element_in "${BUILD_BRANCH}" "${RELEASE_BRANCHES[@]}"; then
  if [[ "${BUILD_IS_RELEASE}" = "true" ]]; then

    echo -e "${GREEN}Copying from ${BLUE}${COMBINED_SITE_DIR}/${GREEN}" \
      "to ${BLUE}${GITHUB_PAGES_DIR}/${NC}"
    cp -r "${COMBINED_SITE_DIR}"/* "${GITHUB_PAGES_DIR}/"

    echo -e "${GREEN}Making a zip of the combined site html content${NC}"
    # Make sure master dir is not in the zipped site. It is ok to have it
    # in the gh-pages one so we can see docs for an as yet un-released
    # stroom, though master should not appear in the versions dropdown.
    rm -rf "${COMBINED_SITE_DIR}/master"

    pushd "${COMBINED_SITE_DIR}"
    zip \
      --recurse-paths \
      --quiet \
      -9 \
      "${RELEASE_ARTEFACTS_DIR}/${ZIP_FILENAME}" \
      ./*
    popd
  else
    echo -e "${GREEN}Not a release so skipping zip creation${NC}"
  fi

  echo -e "${GREEN}Dumping contents of ${RELEASE_ARTEFACTS_DIR}${NC}"
  ls -1 "${RELEASE_ARTEFACTS_DIR}/"

  if [[ "${LOCAL_BUILD}" != "true" \
    && -n "$BUILD_TAG" \
    && "${BUILD_IS_PULL_REQUEST}" != "true" ]] ; then

    create_release_tag
  else
    echo -e "${GREEN}Not a release so won't tag the repository${NC}"
  fi
}

main "$@"
