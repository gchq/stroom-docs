#!/usr/bin/env bash

# Checks the markdown content against the mechanically verifiable rules in the
# style guide, see content/en/community/documentation/style-guide/
#
# Usage:
#   ./check_style.sh                       # summary of all findings
#   ./check_style.sh --detail              # list every finding
#   ./check_style.sh --rule title-case     # one rule only
#   ./check_style.sh content/en/docs/**/*.md
#   ./check_style.sh --ratchet             # fail only on findings above the baseline
#   ./check_style.sh --update-baseline     # rewrite style-baseline.tsv
#
# To exempt a region of a page, e.g. a deliberate counter example, wrap it in
#   <!-- style-check: disable -->
#   <!-- style-check: enable -->

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

main() {
  # https://hub.docker.com/_/python
  local python_version="3.13-alpine"

  setup_echo_colours

  local status=0

  docker \
    run \
    --rm \
    -u "$(id -u):$(id -g)" \
    -v "${PWD}:/workdir" \
    -w /workdir \
    "python:${python_version}" \
      python3 \
      check_style.py \
      "$@" \
    || status=$?

  if [[ ${status} -eq 1 ]]; then
    echo
    echo -e "${RED}ERROR${NC}: Style check failed."
    echo -e "Do one or more of the following:"
    echo -e "  * Fix the issues listed above."
    echo -e "  * See the conventions in ${BLUE}content/en/community/documentation/style-guide/${NC}"
    echo -e "  * Run ${BLUE}./check_style.sh --detail${NC} to see every finding."
    echo -e "  * Wrap a deliberate exception in ${BLUE}\`<!-- style-check: disable -->\`${NC} and ${BLUE}\`<!-- style-check: enable -->\`${NC}"
    exit 1
  elif [[ ${status} -ne 0 ]]; then
    echo -e "${RED}ERROR${NC}: Style check could not run (exit ${status})."
    exit "${status}"
  else
    echo -e "${GREEN}Style check passed.${NC}"
  fi
}

main "$@"
