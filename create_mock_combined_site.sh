#!/usr/bin/env bash

#############################################################
#  A script to create a mock up of a multi versioned site
#  using multiple copies of the current site code.
#  For each version it copies the source, edits the config
#  so that the version details are correct then builds the
#  site for that version. All versions are then combined
#  in one directory. The site can be run with the python simple
#  http server or similar, e.g.
#  ./create_mock_combined_site.sh && cd /tmp/stroom-docs_mock_combined_site && python -m SimpleHTTPServer 8888
############################################################

set -e

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

debug_value() {
  local name="$1"; shift
  local value="$1"; shift
  
  if [ "${IS_DEBUG}" = true ]; then
    echo -e "${DGREY}DEBUG ${name}: ${value}${NC}"
  fi
}

debug() {
  local str="$1"; shift
  
  if [ "${IS_DEBUG}" = true ]; then
    echo -e "${DGREY}DEBUG ${str}${NC}"
  fi
}

build_branch() {
  echo -e "${GREEN}----------------------------------------${NC}"
  echo -e "${GREEN}Branch ${branch_name}${NC}"
  echo -e "${GREEN}----------------------------------------${NC}"

  rm -rf "${TEMP_BUILD_DIR}"
  mkdir -p "${TEMP_BUILD_DIR}"

  echo -e "${GREEN}Copying repo to ${BLUE}${TEMP_BUILD_DIR}${NC}"
  rsync \
    --human-readable \
    --archive \
    --delete \
    "${SCRIPT_DIR}/" "${TEMP_BUILD_DIR}/"

    #--exclude='.git/' \

  local version_name
  if [[ "${branch_name}" = "master" ]]; then
    version_name="Unreleased"
  elif [[ "${branch_name}" = "legacy" ]]; then
    version_name="Legacy"
  else
    version_name="${branch_name}"
  fi

  local config_file="${TEMP_BUILD_DIR}/config.toml"
  echo -e "${GREEN}Updating config file ${config_file}${NC}"
  sed \
    --in-place'' \
    --regexp-extended \
    --expression "s/^  version_menu = .*/  version_menu = \"Stroom Version (${version_name})\"/" \
    --expression "s/^  version = .*/  version = \"${version_name}\"/" \
    "${config_file}"

  if [[ "${branch_name}" != "${LATEST_VERSION}" ]]; then
    echo -e "${GREEN}Updating config file ${config_file} (archived_version setting)${NC}"
    sed \
      --in-place'' \
      --regexp-extended \
      --expression "s/^  archived_version = .*/  archived_version = true/" \
      "${config_file}"
  fi

  echo -e "${GREEN}Diffing config.toml${NC}"
  diff "${SCRIPT_DIR}/config.toml" "${config_file}" || true

  pushd "${TEMP_BUILD_DIR}"

  echo -e "${GREEN}Running the Hugo build for ${branch_name}${NC}"
  #./container_build/runInHugoDocker.sh \
    #build \
    #"${BASE_URL}/${branch_name}"

  ./container_build/runInHugoDocker.sh \
    build

  echo -e "${GREEN}Copying site${NC}"
  dest_dir="${COMBINED_SITE_DIR}/${branch_name}"
  mkdir -p "${dest_dir}"
  cp -r "${TEMP_BUILD_DIR}/public/"* "${dest_dir}/"

  popd
}

main() {
  IS_DEBUG=false
  local SCRIPT_DIR
  SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
  # TODO could scrape this from config.yaml maybe
  local LATEST_VERSION="7.1"
  #local BASE_URL="/stroom-docs"
  local BASE_URL=""

  #local SITE_SOURCE="${SCRIPT_DIR}/public"
  local TEMP_BUILD_DIR="/tmp/stroom-docs_build_dir"
  local COMBINED_SITE_DIR="/tmp/stroom-docs_mock_combined_site${BASE_URL}"

  setup_echo_colours

  pushd "${SCRIPT_DIR}" > /dev/null

  # Controls the versions of the site that will be created.
  # One copy of the site for each of these.
  local RELEASE_BRANCHES=(
    "master"
    "7.1"
    "7.0"
    "legacy"
  )

  #local RELEASE_BRANCHES=(
    #"master"
  #)

  echo -e "${GREEN}Clearing dirs${NC}"
  #rm -rf "${SITE_SOURCE}"
  rm -rf "${COMBINED_SITE_DIR}"
  mkdir -p "${COMBINED_SITE_DIR}"

  local dest_dir
  for branch_name in "${RELEASE_BRANCHES[@]}"; do
    build_branch
  done

  echo -e "${GREEN}Creating root redirect page${NC}"
  cp "${SCRIPT_DIR}/index.html" "${COMBINED_SITE_DIR}/"
  sed \
    --in-place'' \
    --regexp-extended \
    --expression "s/<<<LATEST_VERSION>>>/${LATEST_VERSION}/g" \
    "${COMBINED_SITE_DIR}/index.html"

  echo -e "${GREEN}Done. Site is available in ${BLUE}${COMBINED_SITE_DIR}${NC}"
}

main "$@"
