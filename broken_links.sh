#!/usr/bin/env bash

# Requires bash >=4.3

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
    echo -e "${DGREY}DEBUG ${name}: [${value}]${NC}"
  fi
}

debug() {
  if [ "${IS_DEBUG}" = true ]; then
    echo -e "${DGREY}DEBUG $* ${NC}"
  fi
}

check_anchor_in_file() {
  #local file="$1"; shift
  #local anchor="$1"; shift
  return 0
  

}

verify_http_link() {
  local source_file="$1"; shift
  local link_name="$1"; shift
  local link_location="$1"; shift

  local response_code
  response_code="$( \
    curl \
      --silent \
      --location \
      --output /dev/null \
      --write-out "%{http_code}" \
      "${link_location}" \
    || echo "" \
  )"

  if [[ ! "${response_code}" =~ ^2 ]]; then
    log_broken_link "${source_file}" "${link_name}" "${link_location}"
  fi
}

verify_file_exists() {
  local source_file="$1"; shift
  local link_name="$1"; shift
  # Strip ./ off front
  local rel_link_path="${1#./}"; shift

  local source_dir
  source_dir="$(dirname "${source_file}")"

  local effective_link_path="${source_dir}/${rel_link_path}"
  debug "effective_link_path" "${effective_link_path}"

  if [[ -f "${effective_link_path}" ]]; then
    return 0
  else
    return 1
  fi
}

log_broken_link() {
  local source_file="$1"; shift
  local link_name="$1"; shift
  local rel_link_path="${1}"; shift

  broken_links_found=$((broken_links_found + 1))
  echo -e "  ${RED}Found broken link in file ${BLUE}${source_file}${RED}" \
    "with name ${BLUE}${link_name}${RED} and link path" \
    "${BLUE}${rel_link_path}${NC}"
}

verify_link() {
  local source_file="$1"; shift
  local link_name="$1"; shift
  local link_location="$1"; shift
  
  local link_anchor
  if [[ "${link_location}" =~ ^http ]]; then
    if [[  "${link_location}" == *"www.plantuml.com/plantuml/proxy"* ]]; then
      echo -e "  ${YELLOW}Unable to check plantuml link [${BLUE}${link_name}${YELLOW}]" \
        "with url [${BLUE}${link_location}${YELLOW}]${NC}"
    elif [[  "${link_location}" == *"localhost"* ]]; then
      echo -e "  ${YELLOW}Unable to check localhost link [${BLUE}${link_name}${YELLOW}]" \
        "with url [${BLUE}${link_location}${YELLOW}]${NC}"
    else
      # HTTP link
      # We can't verify the plant uml links as the file in the link may not exist
      # on github yet
      echo -e "  ${GREEN}Checking http link [${BLUE}${link_name}${GREEN}]" \
        "with url [${BLUE}${link_location}${GREEN}]${NC}"
      verify_http_link "${file}" "${link_name}" "${link_location}"
    fi
  elif [[ "${link_location}" =~ ^# ]]; then
    # local anchor link
    link_anchor="${link_location#*#}"
    echo -e "  ${GREEN}${GREEN}Checking local anchor link" \
      "[${BLUE}${link_name}${GREEN}] with anchor" \
      "[${BLUE}${link_anchor}${GREEN}]${NC}"
    check_anchor_in_file "${file}" "${link_anchor}${NC}"
  else
    local link_path
    if [[ "${link_location}" == *#* ]]; then
      # path with anchor
      # Get everything after first #
      link_anchor="${link_location#*#}"
      # Get everything before first #
      link_path="${link_location%%#*}"
      echo -e "  ${GREEN}Checking link [${BLUE}${link_name}${GREEN}] with" \
        "path [${BLUE}${link_path}${GREEN}] and" \
        "anchor [${BLUE}${link_anchor}${GREEN}]${NC}"
      if ! verify_file_exists "${file}" "${link_name}" "${link_path}"; then
        
        log_broken_link "${file}" "${link_name}" "${link_location}"
      fi
    else
      # path without anchor
      link_path="${link_location}"
      echo -e "  ${GREEN}Checking link [${BLUE}${link_name}${GREEN}] with" \
        "path [${BLUE}${link_path}${GREEN}]${NC}"

      if ! verify_file_exists "${file}" "${link_name}" "${link_path}"; then
        log_broken_link "${file}" "${link_name}" "${link_location}"
      fi
    fi
  fi
}

parse_link() {
  local link="$1"; shift
  
  local link_name
  # [xxx](yyy "zzz") => [xxx
  link_name="${link%%\]\(*}"
  # [xxx => xxx
  link_name="${link_name#*\[}";

  local link_location
  # [xxx](yyy "zzz") => yyy "zzz")
  link_location="${link#*\]\(}"
  # yyy "zzz") => yyy "zzz"
  link_location="${link_location%%\)}";
  # yyy "zzz" => yyy
  link_location="${link_location% \"*\"}";

  debug_value "link" "${link}"
  debug_value "link_name" "${link_name}"
  debug_value "link_location" "${link_location}"

  verify_link "${file}" "${link_name}" "${link_location}"
}

check_links_in_file() {
  local file="$1"; shift
  echo -e "${GREEN}Checking file ${BLUE}${file}${NC}"
  
  #local links
  #links="$( \
    #grep \
      #--perl-regexp \
      #--only-matching \
      #"\[[^\]]*?\]\([^)]+?\)" \
      #"${file}" \
      #|| echo ""
    #)"
  #echo -e "links:\n${links}"

  # Not using herestring as it seemt to mess up syntax hlighting in vim
  while read -r link; do
    if [[ -n "${link}" ]]; then
      parse_link "${link}"
    fi
  done < <(grep \
      --perl-regexp \
      --only-matching \
      "\[[^\]]*?\]\([^)]+?\)" \
      "${file}" \
      || echo "")

}

main() {
  IS_DEBUG="${IS_DEBUG:-false}"
  #SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

  setup_echo_colours

  local repo_root
  repo_root="$(git rev-parse --show-toplevel)"


  pushd "${repo_root}" > /dev/null

  local broken_links_found=0

  for file in ./**/*.md; do
    check_links_in_file "${file}"
  done

  if [[ "${broken_links_found}" -gt 0 ]]; then
    echo -e "${RED}ERROR${NC}: Found ${BLUE}${broken_links_found}${NC}" \
      "broken links${NC}"
    exit 1
  fi
}

main "$@"
