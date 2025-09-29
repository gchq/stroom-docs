# See this link for details of how this is put together
# https://github.com/puppeteer/puppeteer/blob/main/docs/troubleshooting.md
# https://pptr.dev/guides/docker 
FROM node:22-bullseye-slim

# Configure default locale (important for chrome-headless-shell).
ENV LANG=en_US.UTF-8  
ENV LANGUAGE=en_US:en  
ENV LC_ALL=en_US.UTF-8 

# Attempts to start a new DBUS session if none is present
ENV DBUS_SESSION_BUS_ADDRESS=autolaunch:

WORKDIR /builder

# Install latest chrome dev package and fonts to support major charsets (Chinese, Japanese, Arabic, Hebrew, Thai and a few others)
# Note: this installs the necessary libs to make the bundled version of Chrome that Puppeteer
# installs, work.
# Remove the node user that the base img unhelpfully creates
RUN userdel -r node \
  && apt-get update \
  && apt-get install -y \
     wget \
    gnupg \
  && wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
  && sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list' \
  && apt-get update \
  && apt-get install -y --no-install-recommends \
    google-chrome-stable \
    fonts-ipafont-gothic \
    fonts-wqy-zenhei \
    fonts-thai-tlwg \
    fonts-kacst \
    fonts-freefont-ttf \
    libxss1 \
    dbus \
    dbus-x11 \
    wait-for-it \
    curl \
    locales \
  && rm -rf /var/lib/apt/lists/*

RUN npm init -y \
    && echo "installing npm packages" \
    && npm install \
      puppeteer@24.22.3 \
      puppeteer-core@24.22.3 \
      @puppeteer/browsers \
      html2canvas \
      jspdf \
    && mkdir -p /builder/repo

# Pass in the uid/gid of the running user so we can use the same user id
# in the container so that any files created can be read outside the 
# container.
ARG USER_ID
ARG GROUP_ID    

RUN echo "USER_ID: [$USER_ID]" \
  && echo "GROUP_ID: [$GROUP_ID]" \
  && echo \
  && echo "Ensuring group exists for group id [${GROUP_ID}]" \
  && group_name="$(cat /etc/group | grep ":${GROUP_ID}:" | awk -F ":" '{ print $1 }')" \
  && echo "group_name from /etc/group: [$group_name"] \
  && if [ -n "${group_name}" ]; then echo "Found group [${group_name}] with id ${GROUP_ID}"; fi \
  && if [ -z "${group_name}" ]; then echo "Creating group [builder] with id ${GROUP_ID}"; fi \
  && if [ -z "${group_name}" ]; then addgroup --gid "$GROUP_ID" --system builder; fi \
  && if [ -z "${group_name}" ]; then group_name="builder"; fi \
  && echo "group_name: [$group_name"] \
  && echo \
  && echo "Ensuring user exists for user id [${USER_ID}]" \
  && user_name="$(getent passwd "$USER_ID" | cut -d: -f1)" \
  && echo "user_name from passwd with id ${USER_ID}: [$user_name]" \
  && if [ -n "${user_name}" ]; then echo "Found user [${user_name}] with id ${USER_ID}"; fi \
  && if [ -z "${user_name}" ]; then echo "Creating user [builder] with id ${USER_ID}"; fi \
  && if [ -z "${user_name}" ]; then adduser --uid "$USER_ID" --system --shell /bin/false --disabled-password --ingroup  "${group_name}" builder; fi \
  && adduser builder audio \
  && adduser builder video \
  && if [ ! -n "${user_name}" ]; then user_name="builder"; fi \
  && echo "user_name: [$user_name]" \
  && mkdir -p "/home/${user_name}/Downloads" \
  && chown -R "${USER_ID}:${GROUP_ID}" "/home/${user_name}" \
  && chown -R "${USER_ID}:${GROUP_ID}" ./node_modules \
  && chown -R "${USER_ID}:${GROUP_ID}" ./package.json \
  && chown -R "${USER_ID}:${GROUP_ID}" ./package-lock.json \
  && echo "Done setting up users/groups"

USER $USER_ID

WORKDIR /builder

ENV PATH="${PATH}:/builder/node_modules/.bin"

COPY --chown=$USER_ID:$GROUP_ID generate-pdf.js /builder/

# This needs to be run after we switch to user $USER_ID so it can see the locally
# installed chromium.
RUN \
    cd /builder/node_modules/puppeteer \
    && pwd \
    && ls -l \
    && npm install \
    && cd /builder
