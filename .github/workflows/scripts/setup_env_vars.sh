#!/usr/bin/env bash

# Set variables in github's special env file which are then automatically 
# read into env vars in each subsequent step

GIT_API_URL="https://api.github.com/repos/gchq/stroom-docs"

if [[ ${GITHUB_REF} =~ ^refs/heads/ ]]; then
  # strip off the 'ref/heads/' bit
  local build_branch="${GITHUB_REF#refs/heads/}"
fi

# If releases are only done nighly this allows us to force one for testing
# So just include '[publish]' in the commit msg
is_forced_release=false
if [[ ${build_branch} = "master" ]] \
  && git --no-pager log -1 --pretty=format:"%s" \
    | head -n1 \
    | grep -q -i "\[publish\]"; then

  # Seen '[publish]' in the latest commit msg on master
  is_forced_release=true;
fi
echo -e "${GREEN}is_forced_release: ${BLUE}${is_forced_release}${NC}"

# Get the tag name of the latest release. As we only release off master
# it should be safe to rely on the most recent release.
# DO NOT echo the token
latest_release_tag_name=
latest_release_tag_name="$( \
  curl \
    --silent \
    --header "authorization: Bearer ${GITHUB_TOKEN}" \
    "${GIT_API_URL}/releases/latest" \
  | jq -r '.tag_name')"

# Get the commit sha for the tag.
# DO NOT echo the token
latest_release_tag_sha=
latest_release_tag_sha="$( \
  curl \
    --silent \
    --header "authorization: Bearer ${GITHUB_TOKEN}" \
    "${GIT_API_URL}/git/ref/tags/${latest_release_tag_name}" \
  | jq -r '.object.sha')"

# Echoing for debug, not to set it in env vars
echo -e "${GREEN}latest_release_tag_name: ${BLUE}${latest_release_tag_name}${NC}"
echo -e "${GREEN}latest_release_tag_sha: ${BLUE}${latest_release_tag_sha}${NC}"
echo -e "${GREEN}GITHUB_SHA: ${BLUE}${GITHUB_SHA}${NC}"

if [[ "${GITHUB_SHA}" = "${latest_release_tag_sha}" ]]; then
  is_same_commit_as_last_release=true
else
  is_same_commit_as_last_release=false
fi
echo -e "${GREEN}is_same_commit_as_last_release:" \
  "${BLUE}${is_same_commit_as_last_release}${NC}"

# Determine if we need to perform a release or not
if [[ "${is_same_commit_as_last_release}" = "false" \
  && ( ${GITHUB_EVENT_NAME} = "schedule" || "${is_forced_release}" = "true" ) \
  ]]; then
  is_release=true
else
  is_release=fase
fi
echo -e "${GREEN}is_release: ${BLUE}${is_release}${NC}"


# Brace block means all echo stdout get appended to GITHUB_ENV
{
  # Map the GITHUB env vars to our own
  echo "BUILD_DIR=${GITHUB_WORKSPACE}"
  echo "BUILD_COMMIT=${GITHUB_SHA}"

  # Travis got to a build number of 354 so add that
  build_number="$((GITHUB_RUN_NUMBER + 354))"
  echo "BUILD_NUMBER=${build_number}"

  echo "ACTIONS_SCRIPTS_DIR=${GITHUB_WORKSPACE}/.github/workflows/scripts"

  # If we switch to explicitly tagging releases then we will need this
  # if [[ ${GITHUB_REF} =~ ^refs/tags/ ]]; then
  #   # strip off the 'refs/tags/' bit
  #   tag="${GITHUB_REF#refs/tags/}"
  #   echo "BUILD_TAG=${tag}"
  # fi

  if [[ ${GITHUB_REF} =~ ^refs/heads/ ]]; then
    echo "BUILD_BRANCH=${build_branch}"
  fi

  # Only do a release based on our schedule, e.g. nightly
  # Skip release if we have same commit as last time
  if [[ "${is_release}" = "true" ]]; then
    echo "BUILD_IS_RELEASE=true"
    echo "BUILD_TAG=stroom-docs-v${build_number}"
  else
    echo "BUILD_IS_RELEASE=false"
  fi

  # TODO Not sure BUILD_IS_FORCED_RELEASE is used anywhere
  if [[ "${is_forced_release}" = "true" ]]; then
    echo "BUILD_IS_FORCED_RELEASE=true"
  else
    echo "BUILD_IS_FORCED_RELEASE=false"
  fi

  if [[ ${GITHUB_REF} =~ ^refs/pulls/ ]]; then
    echo "BUILD_IS_PULL_REQUEST=true"
  else
    echo "BUILD_IS_PULL_REQUEST=false"
  fi

} >> "${GITHUB_ENV}"
