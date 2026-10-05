# See this link for details of how this is put together
# https://github.com/puppeteer/puppeteer/blob/main/docs/troubleshooting.md
# https://pptr.dev/guides/docker 
FROM node:26.8-bookworm-slim@sha256:367679cf9792759492a486e4aa4b421764d71a9546a6dae8aab81a99eb797b3e

# Remove the node user that the base img unhelpfully creates
# Install chrome here so that it pulls in all the many deps that it needs, so when puppeteer installs
# chrome it will work
RUN userdel -r node \
  && mkdir -p /etc/apt/keyrings \
  && apt-get update \
  && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    dbus \
    dbus-x11 \
    gnupg \
    locales \
    unzip \
    wait-for-it \
    wget \
  && curl -fsSL https://dl-ssl.google.com/linux/linux_signing_key.pub \
    | gpg --dearmor -o /etc/apt/keyrings/google-chrome.gpg \
  && echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/google-chrome.gpg] http://dl.google.com/linux/chrome/deb/ stable main" \
    | tee /etc/apt/sources.list.d/google-chrome.list \
  && apt-get update \
  && apt-get install -y google-chrome-stable \
  && rm -rf /var/lib/apt/lists/* \
  && sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen \
  && locale-gen

# Configure default locale (important for chrome-headless-shell).
ENV LANG=en_US.UTF-8  
ENV LANGUAGE=en_US:en  
ENV LC_ALL=en_US.UTF-8 
# Attempts to start a new DBUS session if none is present
ENV DBUS_SESSION_BUS_ADDRESS=autolaunch:

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
  && if [ -z "${user_name}" ]; then adduser --uid "$USER_ID" --home "/home/builder" --disabled-password --ingroup  "${group_name}" builder; fi \
  && adduser builder audio \
  && adduser builder video \
  && if [ ! -n "${user_name}" ]; then user_name="builder"; fi \
  && echo "user_name: [$user_name]" \
  && mkdir -p "/home/${user_name}/Downloads" \
  && chown -R "${USER_ID}:${GROUP_ID}" "/home/${user_name}" \
  && mkdir -p "/home/${user_name}/.npm" \
  && chown -R "${USER_ID}:${GROUP_ID}"  "/home/${user_name}/.npm" \
  && mkdir -p "/builder" \
  && chown -R "${USER_ID}:${GROUP_ID}"  "/builder" \
  && echo "Done setting up users/groups"

# Drop down to a non-root user
USER $USER_ID

WORKDIR /builder

# Install puppeteer and packages as non-root user.
# Puppeteer's installer automatically places the Chrome binary in $HOME/.cache/puppeteer
# but seems to mess it up, so have to clear and re-install chrome
RUN npm init -y \
  && npm install puppeteer@25.10.0 \
  && npm install html2canvas \
  && npm install jspdf \
  && rm -rf "$HOME/.cache/puppeteer" \
  && npx puppeteer browsers install chrome \
  && mkdir -p /builder/repo

# This is the script that will gen the pdf
COPY --chown=$USER_ID:$GROUP_ID generate-pdf.js /builder/
