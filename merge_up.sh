#!/usr/bin/env bash

set -e

setup_echo_colours() {
  # Exit the script on any error

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

error() {
    echo -e "${RED}ERROR${NC} $*${NC}" >&2
}

populate_branches_arr() {

  # Ensure we have an accurate picture of branches available
  # on the default remote
  # --prune to delete any local branches tracking the remote where the remote
  # branch no longer exists.
  git fetch --prune

  # Add the branches that come before the release branches
  branches+=( "${TAIL_BRANCHES[@]}" )

  local release_branches
  release_branches="$( \
    git branch \
    | sed 's/..//' \
    | grep -E "^[0-9]+\.[0-9]+$" )"

  for branch in ${release_branches}; do
    branches+=( "${branch}" )
  done

  # Add the branches that come after the release branches
  branches+=( "${HEAD_BRANCHES[@]}" )

  for branch in "${branches[@]}"; do
    check_branch_exists "${branch}"
  done
}

validate_inside_git_repo() {
  if ! git rev-parse --is-inside-work-tree > /dev/null; then
    error "Not inside a git repository"
    exit 1
  fi
}

check_branch_exists() {
  local branch_name="$1"; shift
  
  if ! git show-ref --quiet "refs/heads/${branch_name}"; then
    error "Branch ${branch_name} does not exist"
    exit 1
  fi

  if ! git show-branch "remotes/${REMOTE_NAME}/${branch_name}" > /dev/null; then
    error "Branch ${branch_name} does not exist on remote ${REMOTE_NAME}"
    exit 1
  fi
}

validate_for_uncommitted_work() {
  debug "validate_for_uncommitted_work() called"
  if [ "$(git status --porcelain 2>/dev/null | wc -l)" -ne 0 ]; then
    error "There are uncommitted changes or untracked files."
    exit 1
  fi
}

merge_branch_up() {
  local source_branch="$1"; shift
  local dest_branch="$1"; shift

  echo -e "${GREEN}Merging up from ${BLUE}${source_branch}${GREEN}" \
    "to ${BLUE}${dest_branch}${NC}"

  git checkout 
  
}
  


main() {
  #SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

  setup_echo_colours

  local REMOTE_NAME
  local TAIL_BRANCHES=( \
    "legacy" )
  local HEAD_BRANCHES=( \
    "master" )

  local branches=()

  validate_inside_git_repo
  validate_for_uncommitted_work
  populate_branches_arr

  debug_value "branches" "${branches[*]}"

  local prev_branch
  local curr_branch

  for branch in "${branches[@]}"; do
    curr_branch="${branch}"

    echo -e "${GREEN}Checking out ${BLUE}${curr_branch}${NC}"
    git checkout "${curr_branch}"

    echo -e "${GREEN}Pushing branch ${BLUE}${curr_branch}${NC}"
    git push "${curr_branch}"

    if [[ -n "${prev_branch}" ]]; then
      merge_branch_up "${prev_branch}" "${source_branch}"
    else
      debug "No prev_branch, curr_branch: ${curr_branch}"
    fi

    prev_branch="${curr_branch}"
  done
}

main "$@"
