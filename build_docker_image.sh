#!/usr/bin/env bash

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

main() {
  IS_DEBUG=false
  SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
  DOCKER_IMAGE_TAG="local-SNAPSHOT"
  CURRENT_GIT_COMMIT="$(git rev-parse HEAD)"

  setup_echo_colours

  echo -e "${GREEN}Building stroom-docs docker image" \
    "${BLUE}gchq/stroom-docs:${DOCKER_IMAGE_TAG}${NC} for commit" \
    "${BLUE}${CURRENT_GIT_COMMIT}${NC}"

  docker build \
    --tag gchq/stroom-docs:${DOCKER_IMAGE_TAG} \
    --build-arg GIT_COMMIT="${CURRENT_GIT_COMMIT}" \
    --build-arg GIT_TAG="${DOCKER_IMAGE_TAG}" \
    "${SCRIPT_DIR}/docker"

  echo -e "${GREEN}Done${NC}"
}

main "$@"
