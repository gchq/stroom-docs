#!/usr/bin/env bash
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

create_release() {
  echo -e "${GREEN}Found release asssets${NC}"
  local asset_files=()
  for asset_file in "${RELEASE_ARTEFACTS_DIR}/"*; do
    echo -e "${GREEN}Found asset file: ${BLUE}${asset_file}${NC}"
    asset_files+=("${asset_file}")
  done

  local args=()
  if [[ ${GITHUB_REF} =~ .*(beta|alpha).* ]]; then
    echo -e "${GREEN}Release is a pre-release${NC}"
    args+=("--prerelease")
  fi

  git tag \
    --list "${BUILD_TAG}" \
    --format='%(subject)%0a%0a%(contents:body)'

  local message
  message="$( \
    git tag \
      --list "${BUILD_TAG}" \
      --format='%(subject)%0a%0a%(contents:body)')"

  echo -e "${GREEN}Creating release for tag ${BLUE}${BUILD_TAG}${GREEN} with message:${NC}"
  echo -e "${DGREY}------------------------------------------------------------------------${NC}"
  echo -e "${DGREY}${message}${NC}"
  echo -e "${DGREY}------------------------------------------------------------------------${NC}"


  # Create the release on GitHub using the annotated tag that triggered
  # this build
  # See https://cli.github.com/manual/gh_release_create
  gh release create \
    --title "${BUILD_TAG}" \
    --notes "${message}" \
    --verify-tag \
    "${args[@]}" \
    "${BUILD_TAG}" \
    "${asset_files[@]}"

  #hub release create "${args[@]}" "$BUILD_TAG"
  echo -e "${GREEN}Release created for tag ${BLUE}${BUILD_TAG}${NC}"
}

main() {
  IS_DEBUG=false
  #SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

  setup_echo_colours

  local RELEASE_ARTEFACTS_DIR="${BUILD_DIR}/release_artefacts"

  # Use Github's hub CLI to create our release
  # See https://github.com/github/hub
  echo -e "${GREEN}Finding asset files for release${NC}"

  if compgen -G "${RELEASE_ARTEFACTS_DIR}/*" > /dev/null; then
    # The dir is non-empty so go ahead with the release
    create_release
  else
    echo -e "${GREEN}Directory ${BLUE}${RELEASE_ARTEFACTS_DIR}${GREEN}" \
      "is empty, nothing to release. Quitting.${NC}"
    exit 0
  fi
}

main "$@"

# vim: set tabstop=2 shiftwidth=2 expandtab:
