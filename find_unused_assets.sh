#!/usr/bin/env bash

set -e
shopt -s globstar nullglob dotglob

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
  local assets_dir="${SCRIPT_DIR}/assets"
  local images_dir="${assets_dir}/images"
  local files_dir="${assets_dir}/files"

  setup_echo_colours

  if ! command -v rg; then
    echo -e "ERROR: You need to install ripgrep"
  fi

  echo "Searching for unused images in ${images_dir}"
  for asset_file in "${images_dir}"/**/*; do
    if [[ "${asset_file}" =~ \.(puml\.svg|svg|png)$ ]] \
      && [[ ! "${asset_file}" =~ /assets/images/stroom-ui/ ]]; then
      local asset_filename
      asset_filename="$(basename "${asset_file}")"
      #echo "  Testing file ${asset_file}"
      if ! rg \
        --quiet \
        --fixed-strings \
        --type md \
        "${asset_filename}" \
        content/en/; then
        echo "  ${asset_file}"
      fi
    fi
  done
}

main "$@"
