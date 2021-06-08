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
  local source_file="$1"; shift
  local link_name="$1"; shift
  local link_path="$1"; shift
  local link_anchor="$1"; shift

  if [[ ! "${link_anchor}" =~ ^[a-z0-9-]+$ ]]; then
    echo -e "${RED}ERROR${NC}: Anchor ${BLUE}${link_anchor}${NC}" \
      "should be lower-snake-case${NC}"
    problem_count=$((problem_count + 1))
  else
    # Replace - with space
    local anchor_as_heading="${link_anchor//-/ }"

    local effective_link_path
    if [[ -n "${link_path}" ]]; then
      effective_link_path="$( \
        make_path_relative_to_root "${source_file}" "${link_path}" \
      )"
    else
      # no path so local anchor
      effective_link_path="${source_file}"
    fi

    debug_value "anchor_as_heading" "${anchor_as_heading}"
    debug_value "effective_link_path" "${effective_link_path}"
    
    if ! grep -q -i -P "^#+ ${anchor_as_heading}$" "${effective_link_path}"; then
      echo -e "${RED}ERROR${NC}: Anchor ${BLUE}${link_anchor}${NC}" \
        "has no corresponding header in ${effective_link_path}"
      problem_count=$((problem_count + 1))
    fi
  fi
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

make_path_relative_to_root() {
  local source_file="$1"; shift
  local link_path="$1"; shift
  
  # Strip ./ off front if it is there
  local rel_link_path="${link_path#./}"

  local source_dir
  source_dir="$(dirname "${source_file}")"

  local effective_link_path="${source_dir}/${rel_link_path}"
  debug "effective_link_path" "${effective_link_path}"

  # echo to sdtout so we can get the output from the func
  echo "${effective_link_path}"
}

verify_file_exists() {
  local source_file="$1"; shift
  local link_name="$1"; shift
  local link_path="$1"; shift

  if [[ "${link_path}" =~ ^/ ]]; then
    problem_count=$((problem_count + 1))
    echo -e "  ${RED}Found link with absolute path in file" \
      "${BLUE}${source_file}${RED}" \
      "with name ${BLUE}${link_name}${RED} and link path" \
      "${BLUE}${link_path}${NC}"
  else
    # Strip ./ off front
    local rel_link_path="${link_path#./}"

    local source_dir
    source_dir="$(dirname "${source_file}")"

    local effective_link_path
    effective_link_path="$( \
      make_path_relative_to_root "${source_file}" "${link_path}" \
    )"
    debug "effective_link_path" "${effective_link_path}"

    if [[ ! -f "${effective_link_path}" ]]; then
      log_broken_link "${file}" "${link_name}" "${link_path}"
      return 1
    fi
  fi
}

log_broken_link() {
  local source_file="$1"; shift
  local link_name="$1"; shift
  local rel_link_path="$1"; shift

  problem_count=$((problem_count + 1))
  echo -e "  ${RED}Found broken link in file ${BLUE}${source_file}${RED}" \
    "with name ${BLUE}${link_name}${RED} and link path" \
    "${BLUE}${rel_link_path}${NC}"
}

verify_link() {
  local source_file="$1"; shift
  local link_name="$1"; shift
  local link_location="$1"; shift
  
  local link_anchor
  local link_path
  if [[ "${link_location}" =~ ^http ]]; then
    if [[  "${link_location}" == *"www.plantuml.com/plantuml/proxy"* ]]; then
      echo -e "  ${YELLOW}Unable to check plantuml link [${BLUE}${link_name}${YELLOW}]" \
        "with url [${BLUE}${link_location}${YELLOW}]${NC}"
    elif [[  "${link_location}" =~ (localhost|127.0.0.1) ]]; then
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
    link_path=""
    echo -e "  ${GREEN}${GREEN}Checking local anchor link" \
      "[${BLUE}${link_name}${GREEN}] with anchor" \
      "[${BLUE}${link_anchor}${GREEN}]${NC}"

    check_anchor_in_file \
      "${file}" \
      "${link_name}" \
      "${link_path}" \
      "${link_anchor}"
  else
    if [[ "${link_location}" == *#* ]]; then
      # path with anchor
      # Get everything after first #
      link_anchor="${link_location#*#}"
      # Get everything before first #
      link_path="${link_location%%#*}"
      echo -e "  ${GREEN}Checking link [${BLUE}${link_name}${GREEN}] with" \
        "path [${BLUE}${link_path}${GREEN}] and" \
        "anchor [${BLUE}${link_anchor}${GREEN}]${NC}"
      if verify_file_exists "${file}" "${link_name}" "${link_path}"; then

        # Can't check anchor if the link file doesn't exist
        check_anchor_in_file \
          "${file}" \
          "${link_name}" \
          "${link_path}" \
          "${link_anchor}"
      fi
    else
      # path without anchor
      link_path="${link_location}"
      echo -e "  ${GREEN}Checking link [${BLUE}${link_name}${GREEN}] with" \
        "path [${BLUE}${link_path}${GREEN}]${NC}"

      verify_file_exists "${file}" "${link_name}" "${link_path}" \
        || true
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

  local problem_count=0

  for file in ./**/*.md; do
    check_links_in_file "${file}"
  done

  if [[ "${problem_count}" -gt 0 ]]; then
    echo -e "${RED}ERROR${NC}: Found ${BLUE}${problem_count}${NC}" \
      "problems with links and anchors${NC}"
    exit 1
  fi
}

main "$@"
