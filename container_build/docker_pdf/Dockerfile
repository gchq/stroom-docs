# See this link for details of how this is put together
# https://github.com/puppeteer/puppeteer/blob/main/docs/troubleshooting.md
# https://pptr.dev/guides/docker 
FROM node:26.8-bookworm-slim@sha256:367679cf9792759492a486e4aa4b421764d71a9546a6dae8aab81a99eb797b3e

# Set HOME to a writable directory for non-root users


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
  && apt-get update \
  && apt-get install -y --no-install-recommends \
    fonts-ipafont-gothic \
    fonts-wqy-zenhei \
    fonts-thai-tlwg \
    fonts-kacst \
    fonts-freefont-ttf \
    libxss1 \
    libglib2.0-0 \
    libnss3 \
    libatk1.0-0 \
    libatk-bridge2.0-0 \
    libcups2 \
    libdrm2 \
    libxkbcommon0 \
    libxcomposite1 \
    libxdamage1 \
    libxfixes3 \
    libxrandr2 \
    libgbm1 \
    libasound2 \
    dbus \
    dbus-x11 \
    wait-for-it \
    curl \
    locales \
    unzip

RUN apt-get install -y --no-install-recommends libcairo2


RUN apt-get install -y --no-install-recommends gconf-service libasound2 libatk1.0-0 libatk-bridge2.0-0 libc6 libcairo2 libcups2 libdbus-1-3 libexpat1 libfontconfig1 libgcc1 libgconf-2-4 libgdk-pixbuf2.0-0 libglib2.0-0 libgtk-3-0 libnspr4 libpango-1.0-0 libpangocairo-1.0-0 libstdc++6 libx11-6 libx11-xcb1 libxcb1 libxcomposite1 libxcursor1 libxdamage1 libxext6 libxfixes3 libxi6 libxrandr2 libxrender1 libxss1 libxtst6 ca-certificates fonts-liberation libappindicator1 libnss3 lsb-release xdg-utils wget

RUN rm -rf /var/lib/apt/lists/*

#RUN locale-gen en_US.UTF-8
#RUN update-locale LC_ALL=en_US.UTF-8

# 1. Uncomment en_US.UTF-8 in /etc/locale.gen and compile it
RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && locale-gen

# Configure default locale (important for chrome-headless-shell).
ENV LANG=en_US.UTF-8  
ENV LANGUAGE=en_US:en  
ENV LC_ALL=en_US.UTF-8 
# Attempts to start a new DBUS session if none is present
ENV DBUS_SESSION_BUS_ADDRESS=autolaunch:

  #&& wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
  #&& sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list' \
    #google-chrome-stable \

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

  #&& if [ -z "${user_name}" ]; then adduser --uid "$USER_ID" --system --shell /bin/false --home "/home/$user_name" --disabled-password --ingroup  "${group_name}" builder; fi \

  #&& chown -R "${USER_ID}:${GROUP_ID}" ./node_modules \
  #&& chown -R "${USER_ID}:${GROUP_ID}" ./package.json \
  #&& chown -R "${USER_ID}:${GROUP_ID}" ./package-lock.json \
USER $USER_ID

WORKDIR /builder

#ENV PATH="${PATH}:/builder/node_modules/.bin"
#ENV HOME=/builder
#ENV PUPPETEER_CACHE_DIR=/tmp/puppeteer-cache

#Install puppeteer and packages as non-root user.
#Puppeteer's installer automatically places the Chrome binary in $HOME/.cache/puppeteer
RUN npm init -y

RUN npm install puppeteer@25.10.0
RUN npm install html2canvas
RUN npm install jspdf

RUN rm -rf "$HOME/.cache/puppeteer"

RUN npx puppeteer browsers clear

RUN npx puppeteer browsers install chrome \
  && mkdir -p /builder/repo

COPY --chown=$USER_ID:$GROUP_ID generate-pdf.js /builder/
