#!/usr/bin/env bash

#########################################################
#  Generates a sha256 hash of all the docker source.    #
#  This is so we can use it as a cache key for github   #
#  actions caching and the buildx cache.                #
#########################################################

# For testing a specific uid/gid do something like:
# ./container_build/generate_buildx_cache_key.sh 1001 12

set -eo pipefail

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

  local is_mac_os
  if [[ "$( uname -s )" == "Darwin" ]]; then
    is_mac_os=true
  else
    is_mac_os=false
  fi

  id=
  id="$(id -u)"
  user_id="${1:-$id}"

  gid=
  gid="$(id -g)"
  group_id="${2:-$gid}"
  local_repo_root="$(git rev-parse --show-toplevel)"
  
  echo "Creating cache key with" \
    "user_id: ${user_id}, group_id: ${group_id}" > /dev/stderr

  files=(
    "${local_repo_root}/container_build/runInHugoDocker.sh" \
    "${local_repo_root}/container_build/runInPumlDocker.sh" \
    "${local_repo_root}/container_build/runInPupeteerDocker.sh" \
    "${local_repo_root}/container_build/docker_hugo/Dockerfile" \
    "${local_repo_root}/container_build/docker_pdf/Dockerfile" \
    "${local_repo_root}/container_build/docker_pdf/generate-pdf.js" \
    "${local_repo_root}/container_build/docker_puml/Dockerfile" \
    "${local_repo_root}/container_build/docker_puml/docker-entrypoint.sh" \
    "${local_repo_root}/container_build/docker_puml/convert_puml_files.sh" \
  )


  # Concat all the things that affect the docker image,
  # e.g. our local username or the dockerfile
  cache_key_source=
  cache_key_source="$( cat "${files[@]}" )"
  cache_key_source="${user_id}\n${group_id}\n${cache_key_source}"

  # Gen the sha256 for each file so we can spot which files are different
  if [[ "${debug:-false}" = true && "${is_mac_os}" = false ]]; then
    for file in "${files[@]}"; do
      sha256sum "${file}" > /dev/stderr
    done
    echo -e "${cache_key_source}" > "/tmp/hugo_source_$(date -u +"%FT%H%M%S")"
  fi

  # Make a hash of these things and effectively use this as the cache key for
  # buildx so any change makes it ignore a previous cache.
  if [[ "${is_mac_os}" = true ]]; then
    shasum -a 256 <<< "${cache_key_source}" \
      | cut -d" " -f1
  else
    sha256sum <<< "${cache_key_source}" \
      | cut -d" " -f1
  fi
}

main "$@"
