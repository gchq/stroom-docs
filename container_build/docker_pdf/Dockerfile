FROM buildkite/puppeteer:10.0.0 

WORKDIR /builder

# Pass in the uid/gid of the running user so we can use the same user id
# in the container so that any files created can be read outside the 
# container.
ARG USER_ID
ARG GROUP_ID    

RUN apt-get update && apt-get install -y \
    curl \
    wait-for-it \
  && echo "installing npm packages" \
  && npm install html2canvas jspdf \
  && mkdir -p /builder/repo \
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
  && echo "Done"

ENV  PATH="${PATH}:/node_modules/.bin"

COPY --chown=$USER_ID:$GROUP_ID generate-pdf.js /builder/

USER $USER_ID

