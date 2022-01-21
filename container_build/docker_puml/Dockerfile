#**********************************************************************
# Copyright 2018 Crown Copyright
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

FROM adoptopenjdk/openjdk15:jdk-15.0.2_7-alpine

# Work from the shared git repo dir
WORKDIR /builder/shared

# graphviz, ttf-* for plantuml
RUN apk add --no-cache \
      bash \
      curl \
      graphviz \
      su-exec \
      tini \
      ttf-droid \
      ttf-droid-nonlatin \
    && curl \
      -Ls \
      https://sourceforge.net/projects/plantuml/files/plantuml.1.2021.5.jar/download \
      -o /builder/plantuml.jar \
    && apk del curl

# Set the user ID into an env var so the entrypoint can see it
ENV CONTAINER_USER_ID=$USER_ID \
    LANG=en_GB.UTF-8

# Set tini as entrypoint
ENTRYPOINT ["/sbin/tini", "--", "/builder/docker-entrypoint.sh"]

CMD id

# Pass in the uid/gid of the running user so we can use the same user id
# in the container so that any files created can be read outside the 
# container.
ARG USER_ID
ARG GROUP_ID    

# graphviz, ttf-* for plantuml
# As this container will be trying to use the docker cli to run/interact with other
# containers we need to add our non-root user to the docker group i.e. the same gid as
# on the host, but may have a different name or that gid in the container or none at all.
# If we have the gid then find its name and add the user to it, if not create a group
# with that gid then add the user.
# We need this membership to have access to docker.sock.
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

COPY --chown=$USER_ID:$GROUP_ID *.sh /builder/

USER $USER_ID
