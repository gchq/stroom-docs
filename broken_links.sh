#!/usr/bin/env bash

# NOTE: This script was written before the content moved to Hugo/Docsy
# so don't run it. Keeping it for now as some of it may be useful
# for content validation in a Hugo/Docsy world.

# Requires bash >=4.3
# Requires realpath

# Script to check the markdown in a repo to ensure that all links to
# other files are not broken and that link anchors are valid.
# Also will hit each url link to see if it gets a 2** response.
# Also spots duplicate anchors in files.
# In hindsight this should probably have been written python as it is
# not the quickest, probably due to the large number of possible anchors
# it must check against. Was too far down the road to change languages.

set -eo pipefail
shopt -s globstar

file_blacklist=(
  ./VERSION.md
)

indent="    "

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

setup_debuging() {
  if [ ! "${IS_DEBUG}" = true ]; then
    # redefine the debug funcs as no ops, saves having a test in each call to
    # the debug func
    eval "
    debug() { 
      true 
    }
    debug_value() { 
      true 
    }"
  fi
}

# Requires setup_debuging to be run once
debug_value() {
  if [ ${#} -ne 2 ]; then
    echo -e "${RED}Error${NC}: Invalid arguments${NC}"
    echo -e "Usage: $0 debug_name debug_value"
    exit 1
  fi
  
  local debug_name="$1"; shift
  local debug_value="$1"; shift
  
  # echo to stderr so we don't polute stdout which causes issues
  # for funcs that return via stdout
  echo -e "${DGREY}DEBUG ${debug_name}: [${debug_value}]${NC}" >&2
}

# Requires setup_debuging to be run once
debug() {
  # echo to stderr so we don't polute stdout which causes issues
  # for funcs that return via stdout
  # shellcheck disable=SC2317
  echo -e "${DGREY}DEBUG $* ${NC}" >&2
}

verify_http_link() {
  local source_file="$1"; shift
  local link_name="$1"; shift
  local link_location="$1"; shift

  # 'http://domain.com/path "title"' => 'http://domain.com/path'  
  local link_url="${link_location%% \"*}"

  if [[ ! ${checked_links_map[${link_url}]} ]]; then

    echo -e "${indent}${NC}Checking URL ${NC}${link_url}${NC}"

    local response_code
    response_code="$( \
      curl \
        --silent \
        --head \
        --location \
        --output /dev/null \
        --write-out "%{http_code}" \
        "${link_url}" \
      || echo "" \
    )"

    if [[ "${response_code}" =~ ^2 ]]; then
      # Link is good so add to our set/map so we don't have to hit it again
      checked_links_map["${link_url}"]=1
    else
      # Some sites don't seem to like the --head option so try it again
      # but getting the full page.
      response_code="$( \
        curl \
          --silent \
          --location \
          --output /dev/null \
          --write-out "%{http_code}" \
          "${link_url}" \
        || echo "" \
    )"
      if [[ "${response_code}" =~ ^2 ]]; then
        # Link is good so add to our set/map so we don't have to hit it again
        checked_links_map["${link_url}"]=1
      else
        log_broken_http_link "${source_file}" "${link_name}" "${link_url}"
      fi
    fi
  else
    echo -e "${indent}${NC}Already Checked URL ${NC}${link_url}${NC}"
  fi
}

#make_path_relative_to_root() {
  #local source_file="$1"; shift
  #local link_path="$1"; shift
  
  ## Strip ./ off front if it is there
  #local rel_link_path="${link_path#./}"

  #local source_dir
  #source_dir="$(dirname "${source_file}")"

  #local effective_link_path="${source_dir}/${rel_link_path}"
  ## turn ./a/aa/../../b/bb into ./b/bb
  #effective_link_path="./$( \
    #realpath \
      #--relative-to="${repo_root}" \
      #"${effective_link_path}" \
  #)"
  #debug "effective_link_path" "${effective_link_path}"

  ## echo to sdtout so we can get the output from the func
  #echo "${effective_link_path}"
#}

#verify_file_exists() {
  #local source_file="$1"; shift
  #local line_no="$1"; shift
  #local link_name="$1"; shift
  #local link_path="$1"; shift

  #if [[ "${link_path}" =~ ^/ ]]; then
    #problem_count=$((problem_count + 1))
    #echo -e "${indent}${RED}ERROR${NC}: Found link with absolute path in file" \
      #"${BLUE}${source_file}:${line_no}${NC}" \
      #"with name ${BLUE}${link_name}${NC} and link path" \
      #"${BLUE}${link_path}${NC}"
  #else
    ## Strip ./ off front
    #local rel_link_path="${link_path#./}"

    #local source_dir
    #source_dir="$(dirname "${source_file}")"

    #local effective_link_path
    #effective_link_path="$( \
      #make_path_relative_to_root "${source_file}" "${link_path}" \
    #)"
    #debug "effective_link_path" "${effective_link_path}"

    #if [[ ! -f "${effective_link_path}" ]]; then
      #log_broken_link \
        #"${file}" \
        #"${line_no}" \
        #"${link_name}" \
        #"${link_path}" \
        #"${effective_link_path}"
      #return 1
    #fi
  #fi
#}

# shellcheck disable=SC2317
log_broken_link() {
  local source_file="$1"; shift
  local line_no="$1"; shift
  local link_name="$1"; shift
  local rel_link_path="$1"; shift
  local effective_link_path="$1"; shift

  problem_count=$((problem_count + 1))
  echo -e "${indent}${RED}Error${NC}: Found broken link in file" \
    "${BLUE}${source_file}:${line_no}${NC}" \
    "with name ${BLUE}${link_name}${NC}, link path" \
    "${BLUE}${rel_link_path}${NC} and effective link path" \
    "${BLUE}${effective_link_path}${NC}"
}

log_broken_http_link() {
  local source_file="$1"; shift
  local link_name="$1"; shift
  local url="$1"; shift

  problem_count=$((problem_count + 1))
  echo -e "${indent}${RED}Error${NC}: Found broken link in file" \
    "${BLUE}${source_file}${NC}" \
    "with name ${BLUE}${link_name}${NC} and link URL" \
    "${BLUE}${url}${NC}"
}

verify_link() {
  local source_file="$1"; shift
  local line_no="$1"; shift
  local link_name="$1"; shift
  local link_location="$1"; shift
  
  if [[ "${link_location}" =~ ^http ]]; then
    if [[  "${link_location}" == *"www.plantuml.com/plantuml/proxy"* ]]; then
      echo -e "${indent}${YELLOW}Unable to check plantuml link" \
        "[${BLUE}${link_name}${YELLOW}]" \
        "with url [${BLUE}${link_location}${YELLOW}]${NC}"
    elif [[  "${link_location}" =~ (localhost|127.0.0.1) ]]; then
      echo -e "${indent}${YELLOW}Unable to check localhost link" \
        "[${BLUE}${link_name}${YELLOW}]" \
        "with url [${BLUE}${link_location}${YELLOW}]${NC}"
    elif [[  "${link_location}" =~ www\.somehost\.com ]]; then
      : # noop
      #echo -e "${indent}${YELLOW}Ignoring dummy link" \
        #"[${BLUE}${link_name}${YELLOW}]" \
        #"with url [${BLUE}${link_location}${YELLOW}]${NC}"
    elif [[  "${link_location}" =~ @@VERSION@@ ]]; then
      echo -e "${indent}${YELLOW}Unable to check versioned link" \
        "[${BLUE}${link_name}${YELLOW}]" \
        "with url [${BLUE}${link_location}${YELLOW}]${NC}"
    else
      # HTTP link
      # We can't verify the plant uml links as the file in the link may not exist
      # on github yet
      #echo -e "${indent}${GREEN}Checking http link [${BLUE}${link_name}${GREEN}]" \
        #"with url [${BLUE}${link_location}${GREEN}]${NC}"
      verify_http_link "${file}" "${link_name}" "${link_location}"
    fi
  fi
}

parse_link() {
  local line_no="$1"; shift
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
  debug_value "line_no" "${line_no}"

  verify_link "${file}" "${line_no}" "${link_name}" "${link_location}"
}
check_links_in_file() {
  local file="$1"; shift
  echo -e "${GREEN}Checking file ${BLUE}${file}${NC}"
  check_basic_links_in_file "${file}"
  check_external_links_in_file "${file}"
}

check_basic_links_in_file() {
  local file="$1"; shift
  
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
  # Find all the markdown links e.g. 
  # [Name](./path/file.md#heading-anchor "Title")
  # Also ignore ones like [...](?...) as these appear in link.md fence
  # blocks.  Bit of a hack, but ignoring text inside fences would be
  # a bit of an adventure in bash.
  while read -r grep_line; do
    debug_value "grep_line" "${grep_line}"

    if [[ -n "${grep_line}" ]]; then
      # grep line looks like:
      # 6:[Properties](../../user-guide/properties.md)
      # So parse out the line no and link
      local line_no="${grep_line%%:*}"
      local link="${grep_line#*:}"
      debug_value "line_no" "${line_no}"
      debug_value "link" "${link}"

      parse_link "${line_no}" "${link}"
      link_count=$((link_count + 1))
    fi
  done < <(grep \
      --line-number \
      --perl-regexp \
      --only-matching \
      "\[[^\]]*?\]\([^?)][^)]*?\)" \
      "${file}" \
      || echo "")
}

check_external_links_in_file() {
  local file="$1"; shift
  
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
  # Find all the markdown links e.g. 
  # [Name](./path/file.md#heading-anchor "Title")
  # Also ignore ones like [...](?...) as these appear in link.md fence
  # blocks.  Bit of a hack, but ignoring text inside fences would be
  # a bit of an adventure in bash.
  local bash_regex='\{\{< ?external-link "(.*)" "(.*)" ?>\}\}'
  while read -r grep_line; do
    debug_value "grep_line" "${grep_line}"

    if [[ -n "${grep_line}" ]]; then
      # grep line looks like:
      # 6:{{< external-link "My Title" "https://www.elastic....." >}}
      # So parse out the line no and link
      local line_no="${grep_line%%:*}"
      local link="${grep_line#*:}"
      debug_value "line_no" "${line_no}"
      debug_value "link" "${link}"
      if [[ "${link}" =~ ${bash_regex} ]]; then
        link_name="${BASH_REMATCH[1]}"
        link_location="${BASH_REMATCH[2]}"
        debug_value "link_name" "${link_name}"
        debug_value "link_location" "${link_location}"
        verify_link "${file}" "${line_no}" "${link_name}" "${link_location}"
      else
        echo -e "${indent}${RED}Error${NC}: Found external link in file" \
          "${BLUE}${source_file}${NC} at line ${BLUE}${line_no}${NC} that" \
          "couldn't be parsed: '${BLUE}${grep_line}${NC}'"
      fi

      parse_link "${line_no}" "${link}"
      link_count=$((link_count + 1))
    fi
  done < <(grep \
      --line-number \
      --perl-regexp \
      --only-matching \
      '\{\{< ?external-link ".*?" ".*?" ?>\}\}' \
      "${file}" \
      || echo "")
}

#find_headings() {
  #local file="$1"; shift
  
  ## turn all headings into their anchor form then add them to
  ## the assoc. array concatted with the filename so we can look
  ## them up later
  ## A heading in anchor form keeps only a-zA-Z0-9 and - with 
  ## all spaces replaced with a '-'.
  ## It is non trivial to see if an anchor exists as a heading in a file
  ## so instead we convert ALL headings to anchor form and hold them in an
  ## assoc array to lookup against.
  ## Some headings look like:
  ##  ## <a name="sec-3-1-1"></a>References to &lt;split&gt; Match Groups
  ## so need to strip the <a...> tags and other bits of html
  #while read -r heading_line; do
    #if [[ -n "${heading_line}" ]]; then
      #local heading_as_anchor
      ## '###  Eats, Shoots & Leaves' => 'Eats-Shoots--Leaves'
      #heading_as_anchor="$( \
        #echo "${heading_line}" \
        #| sed \
          #-r \
          #-e 's/^#+\s+//' \
          #-e 's/<a\s+name="[^"]+"\s*(><\/a>|\/>)//g' \
          #-e 's/(&lt;|&gt;|[^a-z0-9A-Z -])//g' \
          #-e 's/\s/-/g' \
      #)"
      ## Make it lower case, obvs
      #heading_as_anchor="${heading_as_anchor,,}"

      #debug_value "heading_line" "${heading_line}"
      #debug_value "heading_as_anchor" "${heading_as_anchor}"

      #if [[ ${single_file_anchors_map[$heading_as_anchor]+_} ]]; then
        #echo -e "${indent}${RED}ERROR${NC}: Anchor" \
          #"${BLUE}${heading_as_anchor}${NC}" \
          #"already exists in file ${BLUE}${file}${NC}"
        #problem_count=$((problem_count + 1))
      #fi

      ## e.g. ./some/path/file.md#eats-shoots--leaves
      #local key="${file}#${heading_as_anchor}"
      #debug_value "key" "${key}"

      ## Don't care about value so just put an empty string
      #file_and_anchor_map["${key}"]=""
    #fi
  #done < <(grep \
      #--perl-regexp \
      #--only-matching \
      #"^#+\s+.*" \
      #"${file}" \
      #|| echo "")
#}

#find_anchors() {
  #local file="$1"; shift
  
  ## Fine the names of all 
  ## <a name="my-anchor">
  ## tags and add them to our list of anchors
  #while read -r anchor_name; do
    #if [[ -n "${anchor_name}" ]]; then
      #if [[ ${single_file_anchors_map[$anchor_name]+_} ]]; then
        #echo -e "${indent}${RED}ERROR${NC}: Anchor ${BLUE}${anchor_name}${NC}" \
          #"already exists in file ${BLUE}${file}${NC}"
        #problem_count=$((problem_count + 1))
      #fi

      #local key="${file}#${anchor_name}"
      #debug_value "key" "${key}"

      ## Don't care about value so just put an empty string
      #file_and_anchor_map["${key}"]=""
    #fi
  #done < <(grep \
      #--perl-regexp \
      #--only-matching \
      #'(?<=<a name=")[^"]+(?=")' \
      #"${file}" \
      #|| echo "")
#}

#is_anchor_in_file() {
  #local file="$1"; shift
  #local anchor_name="$1"; shift

  #local key="${file}#${anchor_name}"
  #debug_value "key" "${key}"

  #if [[ ${file_and_anchor_map[$key]+_} ]]; then
    ### Found key in associative array
    #return 0
  #else
    ### Didn't find key in associative array
    #return 1
  #fi

  ## This way uses grep, but seems to be slower so will stick with
  ## assoc. array lookups
  ## Change field separator to \n in a sub shell so we can grep over the
  ## array items
  ##if ( IFS=$'\n'; echo "${!file_and_anchor_map[*]}" ) \
    ##| grep \
      ##--quiet \
      ##--fixed-strings \
      ##--line-regexp \
      ##"${key}"; then

    ### Found key in associative array
    ##return 0
  ##else
    ### Didn't find key in associative array
    ##return 1
  ##fi
#}

main() {
  if [[ $# -gt 0 ]]; then
    local named_file="${1}"; shift
  fi

  IS_DEBUG="${IS_DEBUG:-false}"
  SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
  CONTENT_DIR="${SCRIPT_DIR}/content"

  setup_echo_colours
  setup_debuging

  local repo_root
  repo_root="$(git rev-parse --show-toplevel)"

  pushd "${repo_root}" > /dev/null

  debug_value "PWD" "${PWD}"

  local problem_count=0
  #declare -A file_and_anchor_map

  local file_count=0
  local link_count=0
  local -A checked_links_map

  local -A file_blacklist_map
  for file in "${file_blacklist[@]}"; do 
    file_blacklist_map[${file}]=1
  done

  #echo -e "${GREEN}Scanning all .md files to find headings${NC}"
  ## Loop over all files and build a map of all file heading combos
  #for file in ./**/*.md; do
    ## shellcheck disable=SC1001
    #if [[ ! "${file}" =~ \/node_modules\/ ]] \
      #&& [[ ! ${file_blacklist_map["${file}"]+_} ]]; then
      #debug_value "file" "${file}"
      ## An associative array to hold all anchors for this file
      ## so we can check for dups
      #declare -A single_file_anchors_map
      #find_headings "${file}"
      #find_anchors "${file}"
      #file_count=$((file_count + 1))
    #else
      #debug "Skipping file ${file}"
    #fi
  #done

  if [[ -n "${named_file}" ]]; then
    if [[ ! -f "${named_file}" ]]; then
      echo -e "${indent}${RED}ERROR${NC}: File ${BLUE}${named_file}${NC}" \
        "doesn't exist${NC}"
      exit 1
    fi
    if [[ ! ${file_blacklist_map["${named_file}"]+_} ]]; then
      check_links_in_file "${named_file}"
    else
      echo -e "${indent}${YELLOW}Ignoring blacklisted file" \
        "[${BLUE}${named_file}${YELLOW}]${NC}"
    fi
  else
    # Now loop over all files again and verify the links in the files
    echo -e "${GREEN}Scanning all .md files to check links${NC}"
    for file in "${CONTENT_DIR}"/**/*.md; do
      # shellcheck disable=SC1001
      if [[ ! "${file}" =~ \/node_modules\/ ]] \
        && [[ ! ${file_blacklist_map["${file}"]+_} ]]; then

        check_links_in_file "${file}"
      fi
    done
  fi

  echo -e "${GREEN}File count: ${BLUE}${file_count}${NC}"
  echo -e "${GREEN}Link count: ${BLUE}${link_count}${NC}"
  #echo -e "${GREEN}Heading count: ${BLUE}${#file_and_anchor_map[@]}${NC}"

  if [[ "${problem_count}" -gt 0 ]]; then
    echo -e "${indent}${RED}ERROR${NC}: Found ${BLUE}${problem_count}${NC}" \
      "problems with links and anchors. See output above.${NC}"
    exit 1
  else
    echo -e "${GREEN}All checks completed with no problems found${NC}"
    exit 0
  fi
}

main "$@"
