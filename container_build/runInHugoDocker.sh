#!/usr/bin/env bash

# This script is used to run commands inside a docker container that
# has been set up as a Hugo build environment. It will bind mount
# the root of the git repo you are currently in into the container, so
# your pwd must be somewhere inside the desired repo.
# It comes with some pre-baked commands such as ERD and GRADLE_BUILD

# Script 
set -eo pipefail
IFS=$'\n\t'

# Shell Colour constants for use in 'echo -e'
# e.g.  echo -e "My message ${GREEN}with just this text in green${NC}"
# shellcheck disable=SC2034
{
  RED='\033[1;31m'
  GREEN='\033[1;32m'
  YELLOW='\033[1;33m'
  BLUE='\033[1;34m'
  NC='\033[0m' # No Colour
}

docker_login() {
  # The username and password are configured in the travis gui
  if [[ -n "${DOCKER_USERNAME}" ]] && [[ -n "${DOCKER_PASSWORD}" ]]; then
    # Docker login stores the creds in a file so check it to
    # see if we are already logged in
    #local dockerConfigFile="${HOME}/.docker/config.json"
    #if [[ -f "${dockerConfigFile}" ]] \
      #&& grep -q "index.docker.io" "${dockerConfigFile}"; then

      #echo -e "Already logged into docker"
    #else
      echo -e "Logging in to Docker (if this fails, have you provided the" \
        "correct docker creds)"
      # Login is idempotent
      echo "${DOCKER_PASSWORD}" \
        | docker login \
          -u "${DOCKER_USERNAME}" \
          --password-stdin \
          >/dev/null 2>&1
      echo -e "Successfully logged in to docker"
    #fi
  else
    echo -e "${YELLOW}DOCKER_USERNAME and/or DOCKER_PASSWORD not set so" \
      "skipping docker login. Pulls/builds will be un-authenticated and rate" \
      "limited, pushes will fail.${NC}"
  fi
}

create_network() {
  local network_count
  network_count="$( \
    docker network ls -q --filter "name=hugo-stroom*" | wc -l )"

  if [[ "${network_count}" -lt 1 ]]; then
    echo -e "${GREEN}Create docker network hugo-stroom${NC}"
    docker \
      network \
      create \
      "hugo-stroom"
  fi
}

remove_network() {
  local network_count
  network_count="$( \
    docker network ls -q --filter "name=hugo-stroom*" | wc -l )"

  if [[ "${network_count}" -gt 0 ]]; then
    echo -e "${GREEN}Delete docker network hugo-stroom${NC}"
    docker \
      network \
      rm \
      "hugo-stroom"
  fi
}

main() {

  run_cmd=()
  extra_docker_args=()

  if [[ $# -lt 1 ]]; then
    echo -e "${RED}ERROR: Invalid arguments.${NC}"
    echo -e "Usage: $0 bash_command"
    echo -e "e.g:   $0 \"./some_path/a_script.sh arg1 arg2\""
    echo -e "or:    $0 bash  # for a bash prompt in the container"
    echo -e "or:    $0 SVG  # To convert all .puml files to .puml.svg"
    echo -e "Commands are relative to the repo root."
    echo -e "Commands/scripts with args must be quoted as a whole."
    exit 1
  else
    if [[ $# -eq 1 ]] && [[ "$1" = "bash" ]]; then

      run_cmd=( "bash" )
    elif [[ $# -ge 1 ]] && [[ "$1" = "server" ]]; then
      # Run the site in memory and serve on localhost:1313
      run_cmd=( \
        "bash" \
        "-c"  \
        "hugo server" \
      )
        #"hugo server --baseURL 'localhost:1313/stroom-docs'" \
      if [[ $# -eq 2 ]] && [[ "${2}" = "detach" ]]; then
        extra_docker_args=( "--detach" )
      fi
    elif [[ $# -eq 1 ]] && [[ "$1" = "build" ]]; then
      run_cmd=( \
        # Build the site and output to ./public
        "bash" \
        "-c"  \
        "hugo --buildDrafts" \
      )
        #"hugo --buildDrafts --baseURL '/stroom-docs'" \
    elif [[ $# -ge 1 ]] && [[ "$1" = "build" ]]; then
      echo "Using baseUrl: $2"

      run_cmd=( \
        # Build the site and output to ./public
        "bash" \
        "-c"  \
        "hugo --buildDrafts --baseUrl \"$2\"" \
      )
    else
      run_cmd=( \
        "bash" \
        "-c" \
        "$1" \
      )
    fi
  fi

  user_id=
  user_id="$(id -u)"

  group_id=
  group_id="$(id -g)"

  image_tag="hugo-build-env"

  # This path may be on the host or in the container depending
  # on where this script is called from
  local_repo_root="$(git rev-parse --show-toplevel)"

  # This script may be running inside a container so first check if
  # the env var has been set in the container
  host_abs_repo_dir="${HOST_REPO_DIR:-$local_repo_root}"

  dest_dir="/builder/shared"

  docker_group_id="$(stat -c '%g' /var/run/docker.sock)"

  echo -e "${GREEN}HOME ${BLUE}${HOME}${NC}"
  echo -e "${GREEN}User ID ${BLUE}${user_id}${NC}"
  echo -e "${GREEN}Group ID ${BLUE}${group_id}${NC}"
  echo -e "${GREEN}Host repo root dir ${BLUE}${host_abs_repo_dir}${NC}"
  echo -e "${GREEN}Docker group id ${BLUE}${docker_group_id}${NC}"

  # Create a persistent vol for the home dir, idempotent
  docker volume create builder-home-dir-vol

  # So we are not rate limited, login before doing the build as this
  # will pull images
  docker_login

  # TODO consider pushing the built image to dockerhub so we can
  # reuse it for better performance.  See here
  # https://github.com/i3/i3/blob/42f5a6ce479968a8f95dd5a827524865094d6a5c/.travis.yml
  # https://github.com/i3/i3/blob/42f5a6ce479968a8f95dd5a827524865094d6a5c/travis/ha.sh
  # for an example of how to hash the build context so we can pull or push
  # depending on whether there is already an image for the hash.

  echo -e "${GREEN}Building image ${BLUE}${image_tag}${NC}"
  docker build \
    --tag "${image_tag}" \
    --build-arg "USER_ID=${user_id}" \
    --build-arg "GROUP_ID=${group_id}" \
    --build-arg "HOST_REPO_DIR=${host_abs_repo_dir}" \
    "${local_repo_root}/container_build/docker_hugo"

    #--workdir "${dest_dir}" \

  if [ -t 1 ]; then 
    # In a terminal
    tty_args=( "--tty" "--interactive" )
  else
    tty_args=()
  fi

  create_network

  # Mount the whole repo into the container so we can run the build
  # The mount src is on the host file system
  # group-add gives the permission to interact with the docker cli
  # docker.sock allows use to interact with the docker cli
  # Need :exec on /tmp else LMDB complains with link errors
  # Need to pass in docker creds in case the container needs to do authenticated
  # pulls/pushes with dockerhub
  # shellcheck disable=SC2145
  echo -e "${GREEN}Running image ${BLUE}${image_tag}${NC} with command" \
    "${BLUE}${run_cmd[@]}${NC}"

  docker run \
    "${tty_args[@]+"${tty_args[@]}"}" \
    --rm \
    --publish 1313:1313 \
    --tmpfs /tmp:exec \
    --mount "type=bind,src=${host_abs_repo_dir},dst=${dest_dir}" \
    --read-only \
    --name "hugo-build-env" \
    --network "hugo-stroom" \
    --env "BUILD_VERSION=${BUILD_VERSION:-SNAPSHOT}" \
    --env "DOCKER_USERNAME=${DOCKER_USERNAME}" \
    --env "DOCKER_PASSWORD=${DOCKER_PASSWORD}" \
    "${extra_docker_args[@]}" \
    "${image_tag}" \
    "${run_cmd[@]}"

  #remove_network
}

main "$@"
