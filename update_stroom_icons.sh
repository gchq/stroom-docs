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

copy_dir() {
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

  # We don't want any of the dark theme icons
  rsync \
    --verbose \
    --recursive \
    --delete \
    --exclude='*/'\
    --exclude='*-dark.*' \
    --include='*.svg' \
    --include='*.png' \
    --exclude='*' \
    "${source_dir}"/ \
    "${dest_dir}/"
  echo
}

copy_file() {
  local source_file="$1"; shift
  local dest_dir="$1"; shift

  if [ ! -f "${source_file}" ]; then
    echo -e "${RED}ERROR${NC}: Can't find source file ${BLUE}${source_file}${NC}"
    exit 1
  fi
  
  echo -e "Copying file" \
    "${BLUE}${source_file}${NC} to ${BLUE}${dest_dir}${NC}"
  echo

  mkdir -p "${dest_dir}"

  rsync \
    --verbose \
    "${source_file}" \
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
  local stroom_app_resources_ui_dir="${stroom_repo_root}/stroom-app/src/main/resources/ui"
  local images_base_dir="${stroom_app_resources_ui_dir}/images"
  local css_base_dir="${stroom_app_resources_ui_dir}/css"
  local images_dest_dir="./assets/images/stroom-ui"
  # Have to go in ./assets/ so they can be minified by hugo
  local css_dest_dir="./assets/css/stroom-ui"

  if [ ! -d "${stroom_repo_root}" ]; then
    echo -e "${RED}ERROR${NC}: Can't find stroom repo root ${BLUE}${stroom_repo_root}${NC}"
    exit 1
  fi

  if [ ! -d "${images_dest_dir}" ]; then
    echo -e "${RED}ERROR${NC}: Can't find destination directory ${BLUE}${images_dest_dir}/${NC}"
    exit 1
  fi

  copy_dir "${images_base_dir}" "${images_dest_dir}/"
  copy_dir "${images_base_dir}/document" "${images_dest_dir}/document"
  copy_dir "${images_base_dir}/pipeline" "${images_dest_dir}/pipeline"
  copy_dir "${images_base_dir}/fields" "${images_dest_dir}/fields"

  # Any files copied here also need a link adding in layouts/partials/head.html
  # These are needed for the styling of stroom ui elements, e.g. icons
  copy_file "${css_base_dir}/material_design_colors.css" "${css_dest_dir}/"
  copy_file "${css_base_dir}/icon-colours.css" "${css_dest_dir}/"
  copy_file "${css_base_dir}/theme-root.css" "${css_dest_dir}/"
  copy_file "${css_base_dir}/theme-dark.css" "${css_dest_dir}/"

  # Hack to make dark theme the default without having to alter the <body> tag
  #sed -i 's/\.stroom-theme-dark /:root /'  "${css_dest_dir}/theme-dark.css"
  
  echo -e "${GREEN}Done${NC}"
}

main "$@"
