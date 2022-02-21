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

do_copy() {
  local source_dir="$1"; shift
  local dest_dir="$1"; shift

  if [ ! -d "${source_dir}" ]; then
    echo -e "${RED}ERROR${NC}: Can't find source directory ${BLUE}${source_dir}${NC}"
    exit 1
  fi
  
  echo -e "Copying SVG files from" \
    "${BLUE}${source_dir}${NC} to ${BLUE}${dest_dir}${NC}"
  echo

  mkdir -p "${dest_dir}"

  rsync \
    --verbose \
    --recursive \
    --delete \
    --include='*/' \
    --include='*.svg' \
    --include='*.png' \
    --exclude='*' \
    "${source_dir}"/ \
    "${dest_dir}/"
  echo
}

main() {
  IS_DEBUG=false

  setup_echo_colours

  if [ "$#" -ne 1 ]; then
    echo -e "${RED}ERROR${NC}: Invalid arguments"
    echo -e "Usage: ${BLUE}$0 stroom_repo_root${NC}"
    exit 1
  fi

  local stroom_repo_root="$1"
  local images_base_dir="${stroom_repo_root}/stroom-app/src/main/resources/ui/images"
  local dashboard_images_base_dir="${stroom_repo_root}/stroom-dashboard/stroom-dashboard-client/src/main/resources/stroom/dashboard/client/table"
  local dest="./assets/images/stroom-ui"

  if [ ! -d "${stroom_repo_root}" ]; then
    echo -e "${RED}ERROR${NC}: Can't find stroom repo root ${BLUE}${stroom_repo_root}${NC}"
    exit 1
  fi

  if [ ! -d "${dest}" ]; then
    echo -e "${RED}ERROR${NC}: Can't find destination directory ${BLUE}${dest}/${NC}"
    exit 1
  fi

  do_copy "${images_base_dir}" "${dest}"
  do_copy "${images_base_dir}/document" "${dest}/document"
  do_copy "${images_base_dir}/pipeline" "${dest}/pipeline"
  do_copy "${dashboard_images_base_dir}" "${dest}/dashboard"
  
  echo -e "${GREEN}Done${NC}"
}

main "$@"
