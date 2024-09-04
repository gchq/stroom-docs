#!/usr/bin/env bash

# This script is used to run commands inside a docker container that
# has been set up as a java build environment. It will bind mount
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

run_cmd=()

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
  elif [[ $# -eq 1 ]] && [[ "$1" = "SVG" ]]; then
    # convert all .puml files to .puml.svg
    run_cmd=( \
      "bash" \
      "-c"  \
      "/builder/convert_puml_files.sh /builder/shared/content /builder/shared/assets" \
    )
  elif [[ $# -gt 1 ]] && [[ "$1" = "SVG" ]]; then
    # convert all .puml files to .puml.svg
    shift
    run_cmd=( \
      "bash" \
      "-c"  \
      "/builder/convert_puml_files.sh $*" \
    )
  else
    run_cmd=( \
      "bash" \
      "-c" \
      "$1" \
    )
  fi
fi

if [[ "$( uname -s )" == "Darwin" ]]; then
  is_mac_os=true
else
  is_mac_os=false
fi

user_id=
user_id="$(id -u)"

group_id=
group_id="$(id -g)"

image_tag="puml-build-env"

# This path may be on the host or in the container depending
# on where this script is called from
local_repo_root="$(git rev-parse --show-toplevel)"

dest_dir="/builder/shared"

if [[ "${is_mac_os}" = true ]]; then
  # No GNU binutils on macos
  docker_group_id="$(stat -f '%g' /var/run/docker.sock)"
else
  docker_group_id="$(stat -c '%g' /var/run/docker.sock)"
fi

echo -e "${GREEN}HOME ${BLUE}${HOME}${NC}"
echo -e "${GREEN}User ID ${BLUE}${user_id}${NC}"
echo -e "${GREEN}Group ID ${BLUE}${group_id}${NC}"
echo -e "${GREEN}Local repo root dir ${BLUE}${local_repo_root}${NC}"
echo -e "${GREEN}Docker group id ${BLUE}${docker_group_id}${NC}"

# So we are not rate limited, login before doing the build as this
# will pull images
docker_login

if ! docker buildx inspect stroom-puml-builder >/dev/null 2>&1; then
  docker buildx \
    create \
    --name stroom-puml-builder
fi

docker buildx \
  use \
  stroom-puml-builder

# Make a hash of these things and effectively use this as the cache key for
# buildx so any change makes it ignore a previous cache.
cache_key=
cache_key="$( \
  "${local_repo_root}/container_build/generate_buildx_cache_key.sh"
  )"

cache_dir_base="/tmp/stroom_puml_buildx_caches"
cache_dir_name="from_${cache_key}"
cache_dir_from="${cache_dir_base}/${cache_dir_name}"

echo -e "${GREEN}Using cache_key: ${YELLOW}${cache_key}${NC}"

# TODO consider pushing the built image to dockerhub so we can
# reuse it for better performance.  See here
# https://github.com/i3/i3/blob/42f5a6ce479968a8f95dd5a827524865094d6a5c/.travis.yml
# https://github.com/i3/i3/blob/42f5a6ce479968a8f95dd5a827524865094d6a5c/travis/ha.sh
# for an example of how to hash the build context so we can pull or push
# depending on whether there is already an image for the hash.

mkdir -p "${cache_dir_base}"
echo -e "${GREEN}Current cache directories${NC}"
find "${cache_dir_base:?"Variable cache_dir_base not set"}/" \
  -maxdepth 1 \
  -type d \
  -name "from_*"

# Delete old caches
# shellcheck disable=SC2012
if compgen -G  "${cache_dir_base}/from_*" > /dev/null; then
  echo -e "${GREEN}Removing redundant cache directories${NC}"
  # VERY bad if cache_dir_base is not set, i.e. rm -rf /
  find "${cache_dir_base:?"Variable cache_dir_base not set"}/" \
    -maxdepth 1 \
    -type d \
    -name "from_*" \
    ! -name "${cache_dir_name}" \
    -exec rm -rf {} \; 
  echo -e "${GREEN}Remaining cache directories${NC}"
  find "${cache_dir_base:?"Variable cache_dir_base not set"}/" \
    -maxdepth 1 \
    -type d \
    -name "from_*"
fi

echo -e "${GREEN}Building docker image ${BLUE}${image_tag}${NC}"
time docker buildx build \
  --tag "${image_tag}" \
  --build-arg "USER_ID=${user_id}" \
  --build-arg "GROUP_ID=${group_id}" \
  "--cache-from=type=local,src=${cache_dir_from}" \
  "--cache-to=type=local,dest=${cache_dir_from},mode=max" \
  --load \
  "${local_repo_root}/container_build/docker_puml"

echo -e "${GREEN}Current cache directories${NC}"
find "${cache_dir_base:?"Variable cache_dir_base not set"}/" \
  -maxdepth 1 \
  -type d \
  -name "from_*"

  #--workdir "${dest_dir}" \

if [ -t 1 ]; then 
  # In a terminal
  tty_args=( "--tty" "--interactive" )
else
  tty_args=()
fi

# Mount the whole repo into the container so we can run the build
# The mount src is on the host file system
# group-add gives the permission to interact with the docker cli
# docker.sock allows use to interact with the docker cli
# Need :exec on /tmp else LMDB complains with link errors
# Need to pass in docker creds in case the container needs to do authenticated
# pulls/pushes with dockerhub
# shellcheck disable=SC2145
echo -e "${GREEN}Running docker image ${BLUE}${image_tag}${NC} with command" \
  "${BLUE}${run_cmd[@]}${NC}"

time docker run \
  "${tty_args[@]+"${tty_args[@]}"}" \
  --rm \
  --tmpfs /tmp:exec \
  --mount "type=bind,src=${local_repo_root},dst=${dest_dir}" \
  --read-only \
  --name "puml-build-env" \
  --env "BUILD_VERSION=${BUILD_VERSION:-SNAPSHOT}" \
  --env "DOCKER_USERNAME=${DOCKER_USERNAME}" \
  --env "DOCKER_PASSWORD=${DOCKER_PASSWORD}" \
  "${image_tag}" \
  "${run_cmd[@]}"

