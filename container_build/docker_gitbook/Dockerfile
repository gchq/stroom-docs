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

FROM node:13.14.0-alpine3.11
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

ENV GLIBC_VERSION 2.33-r0
#ENV CALIBRE_VERSION v5.21.0
ENV CALIBRE_VERSION 2.55.0

ENV LD_LIBRARY_PATH $LD_LIBRARY_PATH:/opt/calibre/lib
ENV PATH $PATH:/opt/calibre/bin
ENV CALIBRE_INSTALLER_SOURCE_CODE_URL https://raw.githubusercontent.com/kovidgoyal/calibre/$CALIBRE_VERSION/setup/linux-installer.py
#ENV CALIBRE_INSTALLER_SOURCE_CODE_URL https://raw.githubusercontent.com/kovidgoyal/calibre/$CALIBRE_VERSION/setup/linux-installer.sh


# Set tini as entrypoint
ENTRYPOINT ["/sbin/tini", "--", "/builder/docker-entrypoint.sh"]

CMD id

# We need to run as the same user/group ID in the container as on the host
# so that any files created have the right perms and the container can
# access all the files in the shared bind mount.
# We don't know if the uid/gid on the host are in used in the container
# or not so we need to test for their existence and create a user and/or group
# as needed.
# Lots of echo to help debug in travis
# Installation of glibc taken from https://github.com/jeanblanchard/docker-alpine-glibc/blob/master/Dockerfile
# Installation of calibre taken from https://github.com/ljnelson/docker-calibre-alpine/blob/master/Dockerfile
RUN apk add --no-cache \
      bash \
      su-exec \
      tini \
      ca-certificates \
      gcc \
      mesa-gl \
      python3 \
      qt5-qtbase-x11 \
      wget \
      xdg-utils \
      xz \
      xvfb-run

RUN echo "-------" \
    && echo "USER_ID: [$USER_ID]" \
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
    && mkdir -p /builder/shared \
    && echo "Installing calibre $CALIBRE_VERSION" \
    && (wget -nv -O- https://download.calibre-ebook.com/linux-installer.sh | sh /dev/stdin install_dir=/builder isolated=y) \
    && chown -R "$USER_ID:$GROUP_ID" /builder \
    && ln -s /builder/calibre/ebook-convert /usr/bin/ebook-convert \
    && echo "id: [$(id)]"

    #&& mkdir -p /opt/calibre \
    #&& wget -nv "https://download.calibre-ebook.com/$CALIBRE_VERSION/calibre-$CALIBRE_VERSION-x86_64.txz" \
    #&& tar xf calibre-$CALIBRE_VERSION-x86_64.txz -C /opt/calibre \

#RUN echo \
    #&& ls -l /opt/calibre/bin/ \
    #&& echo \
    #&& ls -l /opt/calibre/bin/calibre_postinstall \
    #&& /opt/calibre/bin/calibre --version \
    #&& /opt/calibre/bin/calibre_postinstall \
    #&& rm -rf calibre-$CALIBRE_VERSION-x86_64.txz \

RUN echo \
    && echo "Installing gitbook-cli" \
    && npm install -g gitbook-cli \
    && echo "Installing svgexport" \
    && npm install -g svgexport --unsafe-perm=true \
    && echo "Done"

    #&& wget -nv -O- https://download.calibre-ebook.com/linux-installer.sh | sh /dev/stdin version=5.0.0 \
    #&& rm -rf /tmp/calibre-installer-cache \

    #&& wget -nv "${CALIBRE_INSTALLER_SOURCE_CODE_URL}" \
    #&& chmod u+x ./linux-installer.py \
    #&& python -c "import sys; main=lambda:sys.stderr.write('Download failed\n'); exec(sys.stdin.read()); main(install_dir='/opt', isolated=True)" < ./linux-installer.py \
    #&& rm -rf linux-installer.py \

    #&& apk del curl



    #&& echo "Calibre version: [$(calibre -v)]" \

    #&& echo "Installing glibc $GLIBC_VERSION" \
    #&& curl -sLo /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub \
    #&& curl -sLo glibc.apk "https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-${GLIBC_VERSION}.apk" \
    #&& curl -sLo glibc-bin.apk "https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-bin-${GLIBC_VERSION}.apk" \
    #&& apk add glibc-bin.apk glibc.apk \
    #&& /usr/glibc-compat/sbin/ldconfig /lib /usr/glibc-compat/lib \
    #&& echo 'hosts: files mdns4_minimal [NOTFOUND=return] dns mdns4' >> /etc/nsswitch.conf \
    #&& rm -rf glibc.apk glibc-bin.apk \

    #&& python -c "import sys; main=lambda:sys.stderr.write('Download failed\n'); exec(sys.stdin.read()); main(install_dir='/opt', isolated=True)" < install.py \
    #&& (wget -O- ${CALIBRE_INSTALLER_SOURCE_CODE_URL} | python -c "import sys; main=lambda:sys.stderr.write('Download failed\n'); exec(sys.stdin.read()); main(install_dir='/opt', isolated=True)") \
    #&& (wget -nv -O- ${CALIBRE_INSTALLER_SOURCE_CODE_URL} | python -c "import sys; main=lambda:sys.stderr.write('Download failed\n'); exec(sys.stdin.read()); main(install_dir='/opt', isolated=True)") \

    #&& curl -sLo linux-installer.py "${CALIBRE_INSTALLER_SOURCE_CODE_URL}" \
    #&& chmod u+x ./linux-installer.py \
    #&& python -c "import sys; main=lambda:sys.stderr.write('Download failed\n'); exec(sys.stdin.read()); main(install_dir='/opt', isolated=True)" < ./linux-installer.py \
    #&& rm -rf linux-installer.py \

COPY --chown=$USER_ID:$GROUP_ID docker-entrypoint.sh /builder/

#In order to make gitbook's pdf generation work on a headless server we need to 
#wrap the ebook-convert binary with our own wrapper script of the same name
COPY ebook-convert /usr/local/bin/
