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

  setup_echo_colours

  user_id=
  user_id="$(id -u)"

  group_id=
  group_id="$(id -g)"
  local_repo_root="$(git rev-parse --show-toplevel)"
  # This script may be running inside a container so first check if
  # the env var has been set in the container
  host_abs_repo_dir="${HOST_REPO_DIR:-$local_repo_root}"

  # Concat all the things that affect the docker image,
  # e.g. our local username or the dockerfile
  cache_key_source=
  cache_key_source="$( \
    cat \
      "${local_repo_root}/container_build/runInHugoDocker.sh" \
      "${local_repo_root}/container_build/runInPupeteerDocker.sh" \
      "${local_repo_root}/container_build/docker_hugo/Dockerfile" \
      "${local_repo_root}/container_build/docker_pdf/Dockerfile" \
      "${local_repo_root}/container_build/docker_pdf/generate-pdf.js"
    )"
  cache_key_source="${host_abs_repo_dir}\n${user_id}\n${group_id}\n${cache_key_source}"

  #echo -e "${cache_key_source}" > "/tmp/hugo_source_$(date -u +"%FT%H%M%S")"

  # Make a hash of these things and effectively use this as the cache key for
  # buildx so any change makes it ignore a previous cache.
  sha256sum <<< "${cache_key_source}" \
    | cut -d" " -f1
}

main "$@"
