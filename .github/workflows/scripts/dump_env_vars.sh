#!/usr/bin/env bash

set -eo pipefail

if [[ ! -n "${ACTIONS_SCRIPTS_DIR}" ]]; then
  echo "ACTIONS_SCRIPTS_DIR not set"
  exit 1
fi

"${ACTIONS_SCRIPTS_DIR}/echo_variables.sh" \
  "docker version" "$(docker --version)" \
  "docker-compose version" "$(docker-compose --version)" \
  "git version" "$(git --version)" \
  "GITHUB_EVENT_NAME" "$GITHUB_EVENT_NAME" \
  "GITHUB_REF" "$GITHUB_REF" \
  "GITHUB_SHA" "$GITHUB_SHA" \
  "GITHUB_WORKSPACE" "$GITHUB_WORKSPACE" \
  "BUILD_BRANCH" "$BUILD_BRANCH" \
  "BUILD_COMMIT" "$BUILD_COMMIT" \
  "BUILD_DIR" "$BUILD_DIR" \
  "BUILD_NUMBER" "$BUILD_NUMBER" \
  "BUILD_TAG" "$BUILD_TAG" \
  "BUILD_IS_FORCED_RELEASE" "$BUILD_IS_FORCED_RELEASE" \
  "BUILD_IS_RELEASE" "$BUILD_IS_RELEASE" \
  "BUILD_IS_PULL_REQUEST" "$BUILD_IS_PULL_REQUEST" \
  "ACTIONS_SCRIPTS_DIR" "$ACTIONS_SCRIPTS_DIR" \
  "PWD" "$PWD" \
  "HOME" "$HOME"

