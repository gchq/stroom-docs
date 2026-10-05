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

main() {
  IS_DEBUG=false
  #SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

  setup_echo_colours

  if [[ $# -ne 3 ]]; then
    echo "Invalid arguments" >&2
    echo "Usage:" >&2
    echo "./get_stroom_changelog_content.sh stroom_repo_path old_branch new_branch" >&2
    echo "e.g.:" >&2
    echo "./get_stroom_changelog_content.sh ../stroom_7.13 7.12 7.13" >&2
    exit 1
  fi

  local path="$1"; shift
  local old_branch="$1"; shift
  local new_branch="$1"; shift

  local types=(
    "Feature"
    "Bug"
    "Dependency"
    "Refactor"
    "Build"
    "Issue"
  )

  declare -A type_headings
  type_headings["Feature"]="New Features and Changes"
  type_headings["Bug"]="Bug Fixes"
  type_headings["Dependency"]="Dependency Changes"
  type_headings["Refactor"]="Code Refactor"
  type_headings["Build"]="Build Changes"
  type_headings["Issue"]="Uncategorised Issues"

  if [[ ! -d "${path}" ]]; then
    echo "Directory '${path}' doesn't exist" >&2
    exit 1
  fi

  local diff_script="${path}/diff_changelog.sh"

  if [[ ! -f "${diff_script}" ]]; then
    echo "Can't find script '${diff_script}'" >&2
    exit 1
  fi

  pushd "${path}" > /dev/null
  local old_tag
  old_tag=$( git tag --merged "${old_branch}" --sort=-version:refname | head -n 1 )
  old_tag="${old_tag:-$old_branch}"
  local new_tag
  new_tag=$( git tag --merged "${new_branch}" --sort=-version:refname | head -n 1 )
  new_tag="${new_tag:-$new_branch}"
  popd > /dev/null

  local have_output=false

  echo "<!-- Changes between '${old_tag}' and '${new_tag}' taken on $( date ) -->"
  echo

  for type in "${types[@]}"; do

    if [[ -v type_headings["$type"] ]]; then
      heading="## ${type_headings["$type"]}"
    else
      echo "No heading found for type '${type}'"
    fi

    local output
    output=$( \
      "${diff_script}" "${old_branch}" "${new_branch}" \
        | grep -E "^\* ${type} " \
        | sed -E \
          -e 's/^/\n/' \
            -e 's@(Issue|Bug|Feature|Build|Dependency|Refactor) \*\*#([0-9]+)\*\*@\1 **{{< external-link "#\2" "https://github.com/gchq/stroom/issues/\2" >}}**@g' \
    )

    if [[ -n "${output}" ]]; then
      if [[ "${have_output}" = "true" ]]; then
        echo
        echo
      fi
      echo "${heading}"
      echo "${output}"

      have_output=true
    fi
  done
}

main "$@"
