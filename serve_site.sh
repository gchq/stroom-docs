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

check_prerequisites() {
  if ! docker version >/dev/null 2>&1; then
    echo -e "${RED}ERROR: Docker is not installed. Please install Docker or Docker Desktop.${NC}"
    exit 1
  fi

  if ! docker buildx version >/dev/null 2>&1; then
    echo -e "${RED}ERROR: Docker buildx is not installed. Please install it.${NC}"
    exit 1
  fi
}

main() {
  IS_DEBUG=false
  local repo_root
  repo_root="$(git rev-parse --show-toplevel)"
  pushd "${repo_root}" > /dev/null

  setup_echo_colours
  check_prerequisites

  local puml_svg_count
  puml_svg_count="$(find "${repo_root}" -name "*.puml.svg" | wc -l )"

  if [[ "${puml_svg_count}" -eq 0 ]]; then
    echo -e "${GREEN}No PlantUML SVG files found (*.puml.svg) so running SVG generation process.${NC}"

    ./container_build/runInPumlDocker.sh SVG
  fi

  echo -e "${GREEN}Running the Hugo server on localhost:1313${NC}"

  ./container_build/runInHugoDocker.sh server
}

main "$@"
