#!/usr/bin/env bash

# Script to alter the Hugo front matter weights for _index.md
# files.


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

open_file_in_editor() {
  local file_to_open="$1"; shift
  
  local editor
  editor="${VISUAL:-${EDITOR:-vi}}"

  #echo -e "${GREEN}Opening editor" \
    #"(${BLUE}${editor}${GREEN})${NC}"

  echo
  read -n 1 -s -r -p "Press any key to modify the order in your editor (ctrl-c to cancel)"
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

  local temp_file
  temp_file="$( mktemp --suffix "_weights.sh" )"
  printf '%s\n' "${sorted_arr[@]}" | column -t -s '|' > "${temp_file}"

  echo -e "${GREEN}Current document order:${NC}"
  cat "${temp_file}"

  local sha1
  sha1="$(sha1sum "${temp_file}")"

  open_file_in_editor "${temp_file}"

  # TODO open file in vim

  # TODO check sha1

  if echo "${sha1}" | sha1sum -c --quiet --status; then
    echo -e "${GREEN}Order has not changed. Quitting.${NC}"
    exit 0
  else
    echo -e "${GREEN}Updating files with new order${NC}"

    # Convert the tablular form back into pipe delim
    local re_sorted_arr
    readarray -t re_sorted_arr \
      < <(sed -r 's/[ ]{2,}/|/g' "${temp_file}")

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
        
        echo -e "${GREEN}Changing weight of file ${BLUE}${file}${GREEN}" \
          "from ${BLUE}${old_weight}${GREEN} to ${BLUE}${new_weight}${NC}"

        # Support replacing commented out
        sed -r -i'' "s/^(#\s*)?(weight: )[0-9]+/\2${new_weight}/" "${file}"
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
