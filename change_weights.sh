#!/usr/bin/env bash

# Script to alter the Hugo front matter weights for _index.md
# files. Builds a list of the pages/sections in the provided dir
# then opens the default editor with that list. The user can then
# user their editor to re-order the items and the script will then
# apply the changes to the front matter in the files.
# If the order changes then it will rebuild the weights starting from 10
# and going up by 10 for each page.
#
# This is using bash/sed/etc. to edit yaml so it may not work in all cases

set -e

temp_file=

cleanup() {
  if [[ -n "${temp_file}" && -f "${temp_file}" ]]; then
    rm -f "${temp_file}"
  fi
}

trap cleanup EXIT SIGTERM

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

open_file_in_editor() {
  local file_to_open="$1"; shift
  
  local editor
  editor="${VISUAL:-${EDITOR:-vi}}"

  #echo -e "${GREEN}Opening editor" \
    #"(${BLUE}${editor}${GREEN})${NC}"

  echo
  read -e -n 1 -s -r -p "Press any key to modify the order in your editor (ctrl-c to cancel)"
  echo

  "${editor}" "${file_to_open}"
}

build_weights_array() {
  if [[ $# -eq 0 ]]; then
    echo "Error: No directory supplied" >&2
    exit 1
  fi

  local dir="$1"; shift
  # Remove trailing slash
  dir="${dir%/}"
  
  arr=()
  
  #if ! compgen -G "${dir}/*" > /dev/null; then
    #echo "Error: No matching files!" >&2
    #exit 1
  #fi

  for path in "${dir}/"*; do
    debug_value "file" "${file}"

    local file
    if [[ "${path}" =~ _index.md$ ]]; then
      # This file has the weight for the parent level so ignore it
      continue
    elif [[ -f "${path}" ]]; then
      file="${path}"
    elif [[ -d "${path}" && -f "${path}/_index.md" ]]; then
      file="${path}/_index.md"
    fi

    local yaml_block
    yaml_block="$( sed -n '/---/,/---/p' "${file}" )"

    local weight
    weight="$( \
      echo -e "${yaml_block}" \
      | grep -P -o '(?<=^weight: )[0-9]+' || true)"

    #if [[ ! -n "${weight}" ]]; then
      #echo -e "${GREEN}Error: Can't read weight from ${BLUE}${file}${NC}" >&2
      #exit 1
    #fi
    weight="${weight:--1}"

    local title
    title="$( echo -e "${yaml_block}" | grep -P -o '(?<=^title: )"?[^"]+"?' || true)"
    title="${title//\"/}"
    title="${title:-NO TITLE}"

    local line="${weight}|${title}|${file}"

    arr+=( "${line}" )

    debug "${line}"
  done
}

main() {
  IS_DEBUG=false
  #SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

  setup_echo_colours

  local dir="${1:-./}"; shift

  local arr=()
  build_weights_array "${dir}"

  if [[ ${#arr[@]} -eq 0 ]]; then
    echo "Error: No matching files!" >&2
    exit 1
  fi

  local sorted_arr=()
  readarray -t sorted_arr \
    < <(printf '%s\0' "${arr[@]}" | sort -z -k1 -n -t '|' | xargs -0n1)

  temp_file="$( mktemp --suffix "_weights" )"

  {
    echo "# Revise the document order by moving whole lines up/down."
    echo "# Do not change the numbers or the content of the lines."
    echo "# These comment lines will be ignored."
  } > "${temp_file}"

  printf '%s\n' "${sorted_arr[@]}" | column -t -s '|' >> "${temp_file}"

  echo -e "${GREEN}Current document order:${NC}"
  grep -E -v "^#.*" "${temp_file}" || true

  local sha1
  sha1="$(sha1sum "${temp_file}")"

  open_file_in_editor "${temp_file}"

  if echo "${sha1}" | sha1sum -c --quiet --status; then
    echo -e "${GREEN}Order has not changed. Quitting.${NC}"
    exit 0
  else
    echo -e "${GREEN}Updating files with new order${NC}"

    # Convert the tablular form back into pipe delim
    local re_sorted_arr
    readarray -t re_sorted_arr \
      < <(grep -E -v "^#.*" "${temp_file}" | sed -r 's/[ ]{2,}/|/g')

    local has_changed=false
    local counter=0
    for line in "${re_sorted_arr[@]}"; do
      counter=$(( counter + 10 ))
      local new_weight="${counter}"
      local old_weight="${line%%|*}"
      local file="${line##*|}"

      debug "file: ${file}, old_weight: ${old_weight}, new_weight: ${new_weight}"

      if [[ "${new_weight}" -ne "${old_weight}" ]]; then
        has_changed=true

        if  sed -n '/---/,/---/p' "${file}" | grep -E -q "weight:"; then
          # 'weight:' is present in the front matter so replace it
          echo -e "${YELLOW}Changing weight of file ${BLUE}${file}${YELLOW}" \
            "from ${BLUE}${old_weight}${YELLOW} to ${BLUE}${new_weight}${NC}"

          # Needs to cope with:
          #   weight: 99
          #   #  weight:
          #   #weight:
          # GNU sed only. Work within range 0 => /.../, i.e. drop out on first
          # match
          sed \
            -r \
            -i'' \
            "0,/^(#\s*)?weight:.*/{s/^(#\s*)?weight:.*/weight: ${new_weight}/}" \
            "${file}"
        else
          # 'weight:' not in the front matter so add it
          echo -e "${YELLOW}Adding weight ${BLUE}${new_weight}${YELLOW} to file" \
            "${BLUE}${file}${NC}"

          # Hugo's sorting is weight|date|linkTitle|filePath so in theory we
          # only need to set weight on those docs that differ from that default
          # order but that is getting way too complicated for this script.
          # If you only want to weight a sub set then just do it manually.
          sed \
            -i'' \
            "0,/^---$/{s/^---$/---\nweight: ${new_weight}/}" \
            "${file}"
        fi
      else
        echo -e "${GREEN}File ${BLUE}${file}${GREEN} is unchanged${NC}"
      fi

    done

    if [[ "${has_changed}" = "true" ]]; then
      echo
      echo -e "${GREEN}New document order:${NC}"
      build_weights_array "${dir}"

      readarray -t sorted_arr \
        < <(printf '%s\0' "${arr[@]}" | sort -z -k1 -n -t '|' | xargs -0n1)

      printf '%s\n' "${sorted_arr[@]}" | column -t -s '|'
    fi
    
    echo
    echo "Done"
  fi

  rm "${temp_file}"
}

main "$@"
