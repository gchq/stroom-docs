#!/usr/bin/env bash

# This script is used to run commands inside a docker container that
# has been set up as a gitbook/calibre build environment. It will bind mount
# the root of the git repo you are currently in into the container, so
# your pwd must be somewhere inside the desired repo.

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

HUGO_PORT="1313"
PRINT_PAGE_PATH="/docs/_print/"

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

clean_up() {
  echo -e "${GREEN}Stopping stroom-hugo-build-env* containers${NC}"
  # MacOS doesn't support xargs --no-run-if-empty/-r <sigh>, so need a hacky
  # work around to deal with the case then the ls returns nothing
  docker container \
    ls \
    -q \
    --filter "name=stroom-hugo-build-env*" \
    | xargs -I XxX bash -c '[[ -n "XxX" ]] && docker container stop XxX'

  # Seconds
  sleep 1

  echo -e "${GREEN}Deleting stroom-hugo-build-env* containers${NC}"
  # MacOS doesn't support xargs --no-run-if-empty/-r <sigh>, so need a hacky
  # work around to deal with the case then the ls returns nothing
  docker container \
    ls -a \
    -q \
    --filter "name=stroom-hugo-build-env*" \
    | xargs -I XxX bash -c '[[ -n "XxX" ]] && docker container rm XxX'

  remove_network
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

run_hugo_server() {
  local container_count
  container_count="$( \
    docker container ls -q --filter "name=stroom-hugo-build-env*" | wc -l)"

  if [[ "${container_count}" -lt 1 ]]; then
    echo -e "${GREEN}Run Hugo server in the background on port" \
      "${BLUE}${HUGO_PORT}${NC}"

    "${local_repo_root}/container_build/runInHugoDocker.sh" server detach 
  fi

  create_network
}

wait_for_200_response() {
  if [[ $# -eq 0 ]]; then
    echo -e "${RED}Invalid arguments to wait_for_200_response()," \
      "expecting a URL to wait for${NC}"
    exit 1
  fi

  local url=$1; shift
  local maxWaitSecs=30

  local n=0
  local were_dots_shown=false
  # Keep retrying for maxWaitSecs
  until [ "$n" -ge "${maxWaitSecs}" ]
  do
    # OR with true to prevent the non-zero exit code from curl from stopping our script
    responseCode=$(curl -sL -w "%{http_code}\\n" "${url}" -o /dev/null || true)
    #echo "Response code: ${responseCode}"
    if [[ "${responseCode}" = "200" ]]; then
      break
    fi

    # Only display the wait msg if the service isn't already up
    if [ "$n" -eq 0 ]; then
      echo
      echo -e "${GREEN}Waiting for Hugo server to start" \
        "(${BLUE}${url}${GREEN})${NC}"
    fi

    # print a simple unbounded progress bar, increasing every 2s
    mod=$(( n  % 2 ))
    if [[ ${mod} -eq 0 ]]; then
      printf '.'
      were_dots_shown=true
    fi

    n=$(( n + 1 ))
    # Seconds
    sleep 0.3
  done

  if [ "${were_dots_shown}" = true ]; then
    printf "\n"
  fi

  if [[ $n -ge ${maxWaitSecs} ]]; then
    echo -e "${RED}Gave up wating for hugo server to start up, quitting!${NC}"
    # Dump the docker info so we can see what containers are up
    docker ps -a
    exit 1
  fi
}

main() {
  if [ "$#" -ne 1 ]; then
    echo -e "${RED}ERROR: Invalid arguments.${NC}"
    echo -e "Usage: $0 bash_command"
    echo -e "e.g:   $0 ./path/to/script.sh arg1 arg2"
    echo -e "or:    $0 bash  # for a bash prompt"
    echo -e "or:    $0 PDF  # to generate the all content PDF"
    echo -e "Commands are relative to the repo root."
    echo -e "Commands/scripts with args must be quoted as a whole."
    exit 1
  fi

  bash_cmd="$1"

  if [ "${bash_cmd}" = "bash" ]; then
    run_cmd=( "bash" )

  elif [[ "${bash_cmd}" = "PDF" || "${bash_cmd}" = "pdf" ]]; then
    # Hugo is running in another container so use the service name 
    # 'stroom-hugo-build-env' the host
    run_cmd=( \
      "node" \
      "../generate-pdf.js" \
      "http://stroom-hugo-build-env:${HUGO_PORT}${PRINT_PAGE_PATH}" )
  else
    run_cmd=( \
      "bash" \
      "-c" \
      "${bash_cmd[*]}" )
  fi

  user_id=
  user_id="$(id -u)"

  group_id=
  group_id="$(id -g)"

  image_tag="stroom-pupeteer-pdf-builder"

  # This path may be on the host or in the container depending
  # on where this script is called from
  local_repo_root="$(git rev-parse --show-toplevel)"

  dest_dir="/builder/shared"

  echo -e "${GREEN}HOME ${BLUE}${HOME}${NC}"
  echo -e "${GREEN}User ID ${BLUE}${user_id}${NC}"
  echo -e "${GREEN}Group ID ${BLUE}${group_id}${NC}"
  echo -e "${GREEN}Local repo root dir ${BLUE}${local_repo_root}${NC}"

  if ! docker version >/dev/null 2>&1; then
    echo -e "${RED}ERROR: Docker is not installed. Please install Docker or Docker Desktop.${NC}"
    exit 1
  fi

  if ! docker buildx version >/dev/null 2>&1; then
    echo -e "${RED}ERROR: Docker buildx is not installed. Please install it.${NC}"
    exit 1
  fi

  # So we are not rate limited, login before doing the build as this
  # will pull images
  docker_login

  if ! docker buildx inspect stroom-puppeteer-builder >/dev/null 2>&1; then
    docker buildx \
      create \
      --name stroom-puppeteer-builder
  fi
  docker buildx \
    use \
    stroom-puppeteer-builder

  # Make a hash of these things and effectively use this as the cache key for
  # buildx so any change makes it ignore a previous cache.
  cache_key=
  cache_key="$( \
    "${local_repo_root}/container_build/generate_buildx_cache_key.sh"
    )"

  cache_dir_base="/tmp/stroom_puppeteer_buildx_caches"
  cache_dir_from="${cache_dir_base}/from_${cache_key}"
  #cache_dir_to="${cache_dir_base}/to_${cache_key}"

  echo -e "${GREEN}Using cache_key: ${YELLOW}${cache_key}${NC}"

  # TODO consider pushing the built image to dockerhub so we can
  # reuse it for better performance.  See here
  # https://github.com/i3/i3/blob/42f5a6ce479968a8f95dd5a827524865094d6a5c/.travis.yml
  # https://github.com/i3/i3/blob/42f5a6ce479968a8f95dd5a827524865094d6a5c/travis/ha.sh
  # for an example of how to hash the build context so we can pull or push
  # depending on whether there is already an image for the hash.

  mkdir -p "${cache_dir_base}"

  # Delete old caches, except latest
  # shellcheck disable=SC2012
  if compgen -G  "${cache_dir_base}/from_*" > /dev/null; then
    echo -e "${GREEN}Removing old cache directories${NC}"
    #ls -1trd "${cache_dir_base}/from_"*

    # List all matching dirs
    # Remove the last item
    # Delete each item
    ls -1trd "${cache_dir_base}/from_"* \
      | sed '$d' \
      | xargs rm -rf --
    echo -e "${GREEN}Remaining cache directories${NC}"
    ls -1trd "${cache_dir_base}/from_"*
  fi

  # Pass in the location of the repo root on the docker host
  # which may have been passed down to us or we have determined
  echo -e "${GREEN}Building image ${BLUE}${image_tag}${GREEN}" \
    "(this may take a while on first run)${NC}"
  docker buildx build \
    --progress=plain \
    --tag "${image_tag}" \
    --build-arg "USER_ID=${user_id}" \
    --build-arg "GROUP_ID=${group_id}" \
    --build-arg "HOST_REPO_DIR=${local_repo_root}" \
    "--cache-from=type=local,src=${cache_dir_from}" \
    "--cache-to=type=local,dest=${cache_dir_from},mode=max" \
    --load \
    "${local_repo_root}/container_build/docker_pdf"

  run_hugo_server

  if [ -t 1 ]; then 
    # In a terminal
    tty_args=( "--tty" "--interactive" )
  else
    tty_args=()
  fi

  # We are outside the containers here so use localhost instead of site
  wait_for_200_response "http://localhost:${HUGO_PORT}${PRINT_PAGE_PATH}" 

  # Mount the whole repo into the container so we can run the build
  # The mount src is on the host file system
  # "${tty_args[@]+"${tty_args[@]}"}" The + thing is so it does complain
  # of being unbound when set -u is on
  # Need to pass in docker creds in case the container needs to do authenticated
  # pulls/pushes with dockerhub
  # shellcheck disable=SC2145
  echo -e "${GREEN}Running image ${BLUE}${image_tag}${GREEN} with" \
    "tty args [${BLUE}${tty_args[@]}${GREEN}] and command" \
    "${BLUE}${run_cmd[@]}${NC}"

  docker run \
    "${tty_args[@]+"${tty_args[@]}"}" \
    --rm \
    --tmpfs /tmp \
    --mount "type=bind,src=${local_repo_root},dst=${dest_dir}" \
    --workdir "${dest_dir}" \
    --name "stroom_puppeteer-build-env" \
    --network "hugo-stroom" \
    --init \
    --env "BUILD_VERSION=${BUILD_VERSION:-SNAPSHOT}" \
    --env "DOCKER_USERNAME=${DOCKER_USERNAME}" \
    --env "DOCKER_PASSWORD=${DOCKER_PASSWORD}" \
    "${image_tag}" \
    "${run_cmd[@]}"

  clean_up

  # Would be nice to use "${bash_cmd,,}" = "pdf" for case insense compare
  # but that is bash4, and well, you know, macOS :-(
  if [[ "${bash_cmd}" = "PDF" || "${bash_cmd}" = "pdf" ]]; then
    pdf_file="${local_repo_root}/stroom-docs.pdf" 
    if [[ ! -f "${pdf_file}" ]]; then
      echo -e "${RED}ERROR${NC} Can't find PDF file ${pdf_file}." \
        "Has the Puppeteer PDF generation failed?"
      exit 1
    fi
  fi

  echo -e "${GREEN}Done${NC}"
}

main "$@"
