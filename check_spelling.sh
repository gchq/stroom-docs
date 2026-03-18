#!/usr/bin/env bash

set -e -o pipefail

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
  C_SPELL_VERSION="9.7.0"
  #SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

  setup_echo_colours

  local status=0

  docker \
    run \
    -v "${PWD}:/workdir" \
    "ghcr.io/streetsidesoftware/cspell:${C_SPELL_VERSION}" \
    --config \
    cspell.yaml \
    --no-progress \
    --show-context \
    --show-suggestions \
    --color \
    "$@" \
    || status=$?

  if [[ $status -ne 0 ]]; then
    echo -e "${RED}ERROR${NC}: Spell check failed."
    echo -e "Do one or more of the following:"
    echo -e "  * Fix the spelling mistakes."
    echo -e "  * Add the word to the list of allowed words (${YELLOW}words${NC}) in ${BLUE}cspell.yaml${NC}"
    echo -e "  * Surround the text with backticks if appropriate, e.g. '${BLUE}Enter the value: \`foobar\`'${NC}"
    echo -e "  * Add a new regex pattern to (${YELLOW}ignoreRegExpList${NC}) in ${BLUE}cspell.yaml${NC} to ignore sections of text"
    echo -e "  * Surround the bad text with ${BLUE}\`<!-- cSpell:enable -->\`${NC} and ${BLUE}\`<!-- cSpell:disable -->\`${NC}"
    exit 1
  else
    echo -e "${GREEN}Spelling check passed.${NC}"
  fi
}

main "$@"
