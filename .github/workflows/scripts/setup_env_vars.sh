#!/usr/bin/env bash

# Set variables in github's special env file which are then automatically 
# read into env vars in each subsequent step

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
    # strip off the 'ref/heads/' bit
    build_branch="${GITHUB_REF#refs/heads/}"
    echo "BUILD_BRANCH=${build_branch}"
  fi

  # Every commit to master is a new release, at least at the moment
  # This means any changes on a relase branch need to get merged up
  # to master before a release will happen
  if [[ ${build_branch} = "master" ]]; then
    echo "BUILD_IS_RELEASE=true"
    echo "BUILD_TAG=stroom-docs-v${build_number}"
  else
    echo "BUILD_IS_RELEASE=false"
  fi

  if [[ ${GITHUB_REF} =~ ^refs/pulls/ ]]; then
    echo "BUILD_IS_PULL_REQUEST=true"
  else
    echo "BUILD_IS_PULL_REQUEST=false"
  fi
} >> "${GITHUB_ENV}"
