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

# Had issues getting this to work in alpine (which needs glibc adding to it)
# so had to settle for the not so slim debian instead
FROM node:13.14.0-buster-slim
WORKDIR /builder

# Pass in the uid/gid of the running user so we can use the same user id
# in the container so that any files created can be read outside the 
# container.
ARG USER_ID
ARG GROUP_ID    

# Pass in the abs path to the repo root on the docker host
ARG HOST_REPO_DIR    

# Set the user ID into an env var so the entrypoint can see it
ENV CONTAINER_USER_ID=$USER_ID

# Hacky fix for getting svgexport to work, see https://github.com/bazelbuild/rules_closure/issues/351
ENV OPENSSL_CONF /dev/null

CMD id

# We need to run as the same user/group ID in the container as on the host
# so that any files created have the right perms and the container can
# access all the files in the shared bind mount.
# We don't know if the uid/gid on the host are in used in the container
# or not so we need to test for their existence and create a user and/or group
# as needed.
# Lots of echo to help debug 
# All the packages are to get the pdf generation with calibre working
RUN apt-get update && apt-get install -y \
      bash \
      ca-certificates \
      calibre \
      fonts-liberation \
      gconf-service \
      libappindicator1 \
      libasound2 \
      libatk-bridge2.0-0 \
      libatk1.0-0 \
      libc6 \
      libcairo2 \
      libcups2 \
      libdbus-1-3 \
      libexpat1 \
      libfontconfig \
      libfontconfig1 \
      libgcc1 \
      libgconf-2-4 \
      libgdk-pixbuf2.0-0 \
      libglib2.0-0 \
      libgtk-3-0 \
      libnspr4 \
      libnss3 \
      libpango-1.0-0 \
      libpangocairo-1.0-0 \
      libstdc++6 \
      libx11-6 \
      libx11-xcb1 \
      libxcb1 \
      libxcomposite1 \
      libxcursor1 \
      libxdamage1 \
      libxext6 \
      libxfixes3 \
      libxi6 \
      libxrandr2 \
      libxrender1 \
      libxss1 \
      libxtst6 \
      lsb-release \
      python3 \
      wget \
      xdg-utils \
      xvfb \
    && echo "USER_ID: [$USER_ID]" \
    && echo "GROUP_ID: [$GROUP_ID]" \
    && echo \
    && echo "Ensuring group exists for group id [${GROUP_ID}]" \
    && group_name="$(cat /etc/group | grep ":${GROUP_ID}:" | awk -F ":" '{ print $1 }')" \
    && echo "group_name from /etc/group: [$group_name"] \
    && if [ -n "${group_name}" ]; then echo "Found group [${group_name}] with id ${GROUP_ID}"; fi \
    && if [ ! -n "${group_name}" ]; then echo "Creating group [builder] with id ${GROUP_ID}"; fi \
    && if [ ! -n "${group_name}" ]; then addgroup --gid "$GROUP_ID" --system builder; fi \
    && if [ ! -n "${group_name}" ]; then group_name="builder"; fi \
    && echo "group_name: [$group_name"] \
    && echo \
    && echo "Ensuring user exists for user id [${USER_ID}]" \
    && user_name="$(getent passwd "$USER_ID" | cut -d: -f1)" \
    && echo "user_name from passwd with id ${USER_ID}: [$user_name]" \
    && if [ -n "${user_name}" ]; then echo "Found user [${user_name}] with id ${USER_ID}"; fi \
    && if [ ! -n "${user_name}" ]; then echo "Creating user [builder] with id ${USER_ID}"; fi \
    && if [ ! -n "${user_name}" ]; then adduser --uid "$USER_ID" --system --shell /bin/false --disabled-password --ingroup  "${group_name}" builder; fi \
    && if [ ! -n "${user_name}" ]; then user_name="builder"; fi \
    && echo "user_name: [$user_name]" \
    && mkdir -p /builder/shared \
    && echo "Installing gitbook-cli" \
    && npm install -g gitbook-cli \
    && echo "Installing svgexport" \
    && npm install -g svgexport --unsafe-perm=true \
    && echo "Done"

#In order to make gitbook's pdf generation work on a headless server we need to 
#wrap the ebook-convert binary with our own wrapper script of the same name
COPY ebook-convert /usr/local/bin/

USER $USER_ID
