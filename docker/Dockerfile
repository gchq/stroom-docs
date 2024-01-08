# Copyright 2017 Crown Copyright
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

FROM nginxinc/nginx-unprivileged:1.25-alpine3.18

ARG UID=101

# run entrypoint script inside tini for better unix process handling, 
# see https://github.com/krallin/tini/issues/8
ENTRYPOINT ["/sbin/tini", "--", "/docker-entrypoint.sh"]

CMD ["nginx",  "-g", "daemon off;"]

# root so we can install tini
USER root

# bash for the entrypoint script
# tini required for process control in the entrypoint
# remove the default nginx html path to avoid confusion
RUN \
    apk add --no-cache \
        tini

# Copy the stroom-docs content for nginx to serve
COPY html/ /usr/share/nginx/html/

# Label the image so we can see what commit/tag it came from
ARG GIT_COMMIT=unspecified
ARG GIT_TAG=unspecified
LABEL \
    git_commit="$GIT_COMMIT" \
    git_tag="$GIT_TAG"
# Pass the GIT_TAG through to the running container
# This should not be set at container run time
ENV GIT_TAG=$GIT_TAG

# Switch back to the non-root nginx user
USER $UID
