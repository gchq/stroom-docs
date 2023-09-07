#!/usr/bin/env bash

set -ex

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
  IS_DEBUG=${IS_DEBUG:=false}
  SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
  CONTENT_DIR="${SCRIPT_DIR}/content"

  setup_echo_colours

  # find non-hugo links
  # rg -t md --pcre2 '\[.*\]\([^{].*\)' ./content

  # Array allows us to easily comment bits out for testing
  local extra_args=()

  # Add new line between sentences
  #extra_args+=('-e' 's/(?<=\.)(?<!(?:[Ee]\.[Gg]|[Ii]\.[Ee])\.) +([A-Z])/\n\1/g')

  # Ensure two blank lines before heading
  # shellcheck disable=SC2016
  extra_args+=('-e' 's/(^[^#\n]*$)\n+(^#+ .*$)/$1\n\n\n$2/gm;')

  # Ensure one blank line between consequtive headings
  # Must be run after the ensure two lines one above
  #extra_args+=('-e' 's/(^#+ .*$)\n*(^#+ .*$)/\1\n\n\2/g')
  # shellcheck disable=SC2016
  extra_args+=('-e' 's/(^#+ .*$)\n*(?=^(#+ .*)$)/$1\n\n$2/gm;')

  # Ensure one blank line after heading
  # Ensure all fenced blocks have a language
  # Ensure space between fence and language

  debug_value "CONTENT_DIR" "${CONTENT_DIR}"

  # The order of sed -e args is important as some may undo the work of others
  # if run out of order.
  find "${CONTENT_DIR}" \
    -type f \
    -name "*.md" \
    -print0 \
      | xargs -0 \
      perl \
        -0777 \
        -pi \
        "${extra_args[@]}"
}

main "$@"
