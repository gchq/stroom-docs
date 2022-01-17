#**********************************************************************
# Copyright 2022 Crown Copyright
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#**********************************************************************

FROM klakegg/hugo:ext-alpine

# Run separately so docker can cache the layer to speed up image creation
RUN apk add --no-cache \
        bash \
        git

# Work from the shared git repo dir
WORKDIR /builder/shared

# Remove the parent entrypoint so we can shell onto the container
ENTRYPOINT []

# Set the user ID into an env var so the entrypoint can see it
ENV CONTAINER_USER_ID=$USER_ID

# Pass in the uid/gid of the running user so we can use the same user id
# in the container so that any files created can be read outside the 
# container.
ARG USER_ID
ARG GROUP_ID    

# Docker can't cache this layer as it has variables in it.
RUN echo "USER_ID: [$USER_ID]" \
    && echo "GROUP_ID: [$GROUP_ID]" \
    && echo \
    && echo "Ensuring group exists for group id [${GROUP_ID}]" \
    && group_name="$(cat /etc/group | grep ":${GROUP_ID}:" | awk -F ":" '{ print $1 }')" \
    && echo "group_name from /etc/group: [$group_name"] \
    && if [ -n "${group_name}" ]; then echo "Found group [${group_name}] with id ${GROUP_ID}"; fi \
    && if [ ! -n "${group_name}" ]; then echo "Creating group [builder] with id ${GROUP_ID}"; fi \
    && if [ ! -n "${group_name}" ]; then addgroup -g "$GROUP_ID" -S builder; fi \
    && if [ ! -n "${group_name}" ]; then group_name="builder"; fi \
    && echo "group_name: [$group_name"] \
    && echo \
    && echo "Ensuring user exists for user id [${USER_ID}]" \
    && user_name="$(getent passwd "$USER_ID" | cut -d: -f1)" \
    && echo "user_name from passwd with id ${USER_ID}: [$user_name]" \
    && if [ -n "${user_name}" ]; then echo "Found user [${user_name}] with id ${USER_ID}"; fi \
    && if [ ! -n "${user_name}" ]; then echo "Creating user [builder] with id ${USER_ID}"; fi \
    && if [ ! -n "${user_name}" ]; then adduser -u "$USER_ID" -S -s /bin/false -D -G "${group_name}" builder; fi \
    && if [ ! -n "${user_name}" ]; then user_name="builder"; fi \
    && echo "user_name: [$user_name]" \
    && echo \
    && mkdir -p /builder/shared

USER $USER_ID

# vim: set tabstop=4 shiftwidth=4 expandtab:
