#!/bin/bash

set -eo pipefail
#IFS=$'\n\t'

setup_echo_colours() {
  # Exit the script on any error
  set -e

  # shellcheck disable=SC2034
  if [ "${MONOCHROME}" = true ]; then
    RED=''
    GREEN=''
    YELLOW=''
    BLUE=''
    BLUE2=''
    DGREY=''
    NC='' # No Colour
  else 
    RED='\033[1;31m'
    GREEN='\033[1;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[1;34m'
    BLUE2='\033[1;34m'
    DGREY='\e[90m'
    NC='\033[0m' # No Colour
  fi
}

setup_ssh_agent() {
  # See if there is already a socket for ssh-agent
  if [[ -S "${SSH_AUTH_SOCK}" ]]; then
    echo -e "${GREEN}ssh-agent already bound to ${BLUE}SSH_AUTH_SOCK${NC}"
  else
    # Start ssh-agent and add our private ssh deploy key to it
    echo -e "${GREEN}Starting ssh-agent${NC}"
    ssh-agent -a "${SSH_AUTH_SOCK}" > /dev/null
  fi

  # SSH_DEPLOY_KEY is the private ssh key that corresponds to the public key
  # that is held in the 'deploy keys' section of the stroom repo on github
  # https://github.com/gchq/stroom/settings/keys
  echo -e "${GREEN}Adding ssh key${NC}"
  ssh-add - <<< "${SSH_DEPLOY_KEY}"
}

# Returns 0 if $1 is in the array of elements passed as subsequent args
# e.g. 
# arr=( "one" "two" "three" )
# element_in "two" "${arr[@]}" # returns 0
element_in() {
  local element 
  local match="$1"
  shift
  for element; do 
    [[ "${element}" == "${match}" ]] && return 0
  done
  return 1
}

build_version_from_source() {
  local branch_name="${1:-SNAPSHOT}"; shift
  local repo_root="$1"; shift

  pushd "${repo_root}"
  
  #local hugo_base_url
  local generated_site_dir="${repo_root}/public"
  local pdf_filename="${BUILD_TAG:-SNAPSHOT}_stroom-${branch_name}.pdf"

  local branch_head_commit_sha
  branch_head_commit_sha="$(git rev-parse HEAD)"

  local branch_gh_pages_dir="${NEW_GH_PAGES_DIR}/${branch_name}"
  mkdir -p "${branch_gh_pages_dir}"

  # Write the commit sha to gh-pages so in future builds we can query it
  echo "${branch_head_commit_sha}" \
    > "${branch_gh_pages_dir}/${COMMIT_SHA_FILENAME}"

  echo -e "${GREEN}-----------------------------------------------------${NC}"
  echo -e "${GREEN}Building" \
    "\n  branch_name:            ${BLUE}${branch_name}${GREEN}" \
    "\n  branch_head_commit_sha: ${BLUE}${branch_head_commit_sha}${GREEN}" \
    "\n  repo_root:              ${BLUE}${repo_root}${GREEN}" \
    "\n  latest_version:         ${BLUE}${latest_version}${GREEN}"
    #"\n  base_url:        ${BLUE}${hugo_base_url}${NC}"
  echo -e "${GREEN}-----------------------------------------------------${NC}"

  if [[ -n "${BUILD_TAG}" ]]; then
    local config_file="${repo_root}/${CONFIG_FILENAME}"
    echo -e "${GREEN}Updating config file ${BLUE}${config_file}${GREEN}" \
      "(build_version=${BUILD_TAG:-SNAPSHOT})${NC}"

    sed \
      --in-place'' \
      --regexp-extended \
      --expression "s/^  build_version *=.*/  build_version = \"${BUILD_TAG:-SNAPSHOT}\"/" \
      "${config_file}"
  fi

  # Don't want sections like news|community in the old versions
  if element_in "${branch_name}" "${release_branches[@]}" \
    && [[ "${branch_name}" != "${latest_version}" ]]; then
      remove_unwanted_sections "${repo_root}"
  fi

  echo "::group::PUML conversion"
  echo -e "${GREEN}Converting all .puml files to .puml.svg${NC}"
  ./container_build/runInPumlDocker.sh SVG
  echo "::endgroup::"

  # Build the Hugo site html (into ./public/)
  # TODO, remove --buildDrafts arg once we merge to master
  echo "::group::Hugo build"
  echo -e "${GREEN}Building combined site HTML with Hugo${NC}"
  ./container_build/runInHugoDocker.sh build
  echo "::endgroup::"

  echo "::group::PDF generation"
  echo -e "${GREEN}Building whole site docs PDF for this branch${NC}"
  ./container_build/runInPupeteerDocker.sh PDF
  echo "::endgroup::"

  # Don't want to release anything for master
  if [[ "${branch_name}" != "master" ]]; then

    # Rename/move the gennerated PDF and also copy to gh-pages so we
    # can easily get it in a future build
    mv stroom-docs.pdf "${RELEASE_ARTEFACTS_DIR}/${pdf_filename}"
    #cp \
      #"${RELEASE_ARTEFACTS_DIR}/${pdf_filename}" \
      #"${branch_gh_pages_dir}/"

    # Might be some random feature branch
    if element_in "${branch_name}" "${release_branches[@]}"; then

      mkdir -p "${branch_gh_pages_dir}"
      echo -e "${GREEN}Copying site HTML (${BLUE}${generated_site_dir}${GREEN})" \
        "to combined gh-pages dir (${BLUE}${branch_gh_pages_dir}${GREEN})${NC}"
      cp -r "${generated_site_dir}"/* "${branch_gh_pages_dir}"

      # Now make a site that only knows about one version for inclusion with
      # stack/zip deployments. Must do this after the copy above as it will
      # modify the Hugo config
      make_single_version_site "${branch_name}" "${repo_root}"
    else
      echo -e "${BLUE}${branch_name}${GREEN} is not a release branch so won't" \
        "add it to ${BLUE}${NEW_GH_PAGES_DIR}${NC}"
    fi
  fi
  
  popd
}

copy_version_from_current() {
  local branch_name="${1:-SNAPSHOT}"; shift

  # If there have been no commits on this branch then we can just copy
  # the site from the current gh-pages clone.
  echo -e "${GREEN}Copying current gh-pages site${NC}"
  cp -r "${CURRENT_GH_PAGES_DIR}/${branch_name}" "${NEW_GH_PAGES_DIR}/"

  # Now need to get the single site zip and pdf from github releases
  # to save us having to rebuild them

  echo -e "${GREEN}Latest GitHub release: ${NC}"
  curl \
    --silent \
    --header "authorization: Bearer ${GITHUB_TOKEN}" \
    "${GIT_API_URL}/releases/latest" \
    | jq -r '.tag_name'

  echo -e "${GREEN}Dumping asset names for latest release${NC}"
  curl \
    --silent \
    --header "authorization: Bearer ${GITHUB_TOKEN}" \
    "${GIT_API_URL}/releases/latest" \
    | jq -r '.assets[] | .name'

  # Double escape \. to \\\\., once for bash, once for jq
  local existing_zip_url=
  existing_zip_url="$( \
    curl \
      --silent \
      --header "authorization: Bearer ${GITHUB_TOKEN}" \
      "${GIT_API_URL}/releases/latest" \
      | jq -r ".assets[] | select(.name | test(\"^stroom-docs-.*_stroom-${branch_name}\\\\.zip$\")) .browser_download_url")"

  echo -e "${GREEN}Downloading: ${BLUE}${existing_zip_url}${GREEN}" \
    "to ${BLUE}${RELEASE_ARTEFACTS_DIR}${NC}"

  wget \
    --quiet \
    --directory-prefix "${RELEASE_ARTEFACTS_DIR}" \
    "${existing_zip_url}"

  # Double escape \. to \\\\., once for bash, once for jq
  local existing_pdf_url=
  existing_pdf_url="$( \
    curl \
      --silent \
      --header "authorization: Bearer ${GITHUB_TOKEN}" \
      "${GIT_API_URL}/releases/latest" \
      | jq -r ".assets[] | select(.name | test(\"^stroom-docs-.*_stroom-${branch_name}\\\\.pdf$\")) .browser_download_url")"

  echo -e "${GREEN}Downloading: ${BLUE}${existing_pdf_url}${GREEN}" \
    "to ${BLUE}${RELEASE_ARTEFACTS_DIR}${NC}"

  wget \
    --quiet \
    --directory-prefix "${RELEASE_ARTEFACTS_DIR}" \
    "${existing_pdf_url}"
}

assemble_version() {
  local branch_name="${1:-SNAPSHOT}"; shift

  # See if there have been any commits on this branch since the last
  # release.
  if has_release_branch_changed "${branch_name}"; then
    # Has new commits, so build the site and pdf from source for this version

    echo -e "${GREEN}Branch ${BLUE}${branch_name}${GREEN} has new commits" \
      "since last release${NC}"

    local branch_clone_dir="${GIT_WORK_DIR}/${branch_name}"


    echo "::group::Cloning branch ${branch_name}"
    echo -e "${GREEN}Cloning branch ${BLUE}${branch_name}${GREEN} of" \
      "${BLUE}${GIT_REPO_URL}${GREEN} into ${BLUE}${branch_clone_dir}${NC}"

    # Clone the required branch into a dir with the name of the branch
    git \
      clone \
      --depth 1 \
      --branch "${branch_name}" \
      --single-branch \
      --recurse-submodules \
      "${GIT_REPO_URL}" \
      "${branch_clone_dir}"
    echo "::endgroup::"

    build_version_from_source "${branch_name}" "${branch_clone_dir}"
  else
    # No new commits so copy the existing site from gh-pages and the
    # pdf from gh releases
    echo -e "${GREEN}Branch ${BLUE}${branch_name}${GREEN} has not changed" \
      "since last release${NC}"
    copy_version_from_current "${branch_name}"
  fi
}

# We want a site for a single version that doesn't know about any of the
# others.
make_single_version_site() {
  local branch_name="${1:-SNAPSHOT}"; shift
  local repo_root="$1"; shift

  echo -e "${GREEN}Creating single version site for ${BLUE}${branch_name}" \
    "${repo_root}${NC}"

  local generated_site_dir="${repo_root}/public"
  local single_ver_zip_filename="${BUILD_TAG:-SNAPSHOT}_stroom-${branch_name}.zip"

  local config_file="${repo_root}/${CONFIG_FILENAME}"
  local temp_config_backup_file
  temp_config_backup_file="$(mktemp)"
  cp "${config_file}" "${temp_config_backup_file}"

  # No point having the warning banner for it being an old version if it is
  # the only one
  echo -e "${GREEN}Updating config file ${BLUE}${config_file}${GREEN}" \
    "(archived_version=false)${NC}"
  sed \
    --in-place'' \
    --regexp-extended \
    --expression "s/^  archived_version = .*/  archived_version = false/" \
    "${config_file}"

  # This is a single version site so remove all the version blocks i.e.
  # everything inside these tags, including the tags
  #   <<<VERSIONS_BLOCK_START>>>
  #   ...
  #   <<<VERSIONS_BLOCK_END>>>
  # TODO This is a bit hacky so am open to ideas
  echo -e "${GREEN}Updating config file ${BLUE}${config_file}${GREEN}" \
    "(remove versions)${NC}"
  sed \
    --in-place'' \
    '/<<<VERSIONS_BLOCK_START>>>/,/<<<VERSIONS_BLOCK_END>>>/d' \
    "${config_file}"

  echo "::group::Diffing config changes"
  echo -e "${GREEN}Diffing config changes${NC}"
  echo -e "${GREEN}---------------------------------${NC}"
  diff "${temp_config_backup_file}" "${config_file}" \
    || true
  echo -e "${GREEN}---------------------------------${NC}"
  echo "::endgroup::"

  # Clear out the generated site dir from the last run
  rm -rf "${generated_site_dir:?}"/*

  # Don't want sections like news|community in the old versions
  if element_in "${branch_name}" "${release_branches[@]}" \
    && [[ "${branch_name}" != "${latest_version}" ]]; then
      remove_unwanted_sections "${repo_root}"
  fi

  # Now re-build the site with the modified config
  echo "::group::Hugo build"
  echo -e "${GREEN}Building single site HTML with Hugo${NC}"
  ./container_build/runInHugoDocker.sh build
  echo "::endgroup::"

  # go into the dir so all paths in the zip are relative to generated_site_dir
  pushd "${generated_site_dir}"

  echo -e "${GREEN}Creating single site zip" \
    "${BLUE}${single_ver_zip_filename}${NC}"
  zip \
    --recurse-paths \
    --quiet \
    -9 \
    "${RELEASE_ARTEFACTS_DIR}/${single_ver_zip_filename}" \
    ./*

  # Also copy the zip into gh-pages so it is easier for us to get on future
  # builds
  #cp \
    #"${RELEASE_ARTEFACTS_DIR}/${single_ver_zip_filename}" \
    #"${NEW_GH_PAGES_DIR}/${branch_name}/"

  popd
}

remove_unwanted_sections() {
  local site_root_dir="$1"; shift

  for section_name in "${UNWANTED_SECTIONS[@]}"; do
    local section_dir="${site_root_dir}/content/en/${section_name}"
    if [[ -d "${section_dir}" ]]; then
      echo -e "${GREEN}Removing section ${BLUE}${section_dir}${NC}"
      rm -rf "${section_dir:?}"
    else
      echo -e "${GREEN}Section ${BLUE}${section_dir}${GREEN} doesn't exist${NC}"
    fi
  done
}

# Copies the site map from the latest branch down to the root
# and changes all the <loc> tags in the sitemap to point sub-paths of
# the latest branch dir
create_root_sitemap() {
  echo -e "${GREEN}Creating root sitemap file for latest version" \
    "[${BLUE}${latest_version}${GREEN}]${NC}"
  pushd "${NEW_GH_PAGES_DIR}"

  echo "Copying sitemap.xml file to root"
  cp "./${latest_version}/sitemap.xml" ./

  echo "Changing <loc> tags in sitemap.xml to point to /${latest_version}/"
  sed \
    -i \
    "s#<loc>/#<loc>${GH_PAGES_BASE_URL}/latest/#" \
    ./sitemap.xml

  echo "Creating robots.txt file in root"
  cp "./${latest_version}/robots.txt" ./
  echo "Adding sitemap location to robots.txt"
  {
    echo "User-agent: *" 
    echo "Sitemap: ${GH_PAGES_BASE_URL}/sitemap.xml" 
  } > ./robots.txt

  popd
}

create_root_redirect_page() {
  echo -e "${GREEN}Creating root redirect page with latest version" \
    "[${BLUE}${latest_version}${GREEN}]${NC}"

  # Create a symlink so we have something like
  # /
  #   /7.0/
  #   /7.1/
  #   /7.2/
  #   /latest/ -> /7.2/
  pushd "${NEW_GH_PAGES_DIR}"
  ln -s "./${latest_version}/" "latest" 
  popd

  # Now make a redirect to the symlink so we open the latest
  # version by default
  sed \
    --regexp-extended \
    --expression "s/<<<LATEST_VERSION>>>/latest/g" \
    "${BUILD_DIR}/index.html.template" \
    > "${NEW_GH_PAGES_DIR}/index.html"

  # This is to stop gh-pages treating the content as Jekyll content
  # in which case dirs prefixed with '_' are ignored breaking the print 
  # functionality
  touch "${NEW_GH_PAGES_DIR}/.nojekyll"

  # Make sure the google site verification file is in gh-pages
  # so google can index the site
  cp \
    "${BUILD_DIR}/${GOOGLE_VERIFICATION_FILENAME}" \
    "${NEW_GH_PAGES_DIR}/"
}

create_release_tag() {
  setup_ssh_agent

  git config user.name "${GITHUB_ACTOR}"
  git config user.email "${GITHUB_ACTOR}@bots.github.com"

  pushd "${BUILD_DIR}"

  # Tag the commit so we can create a release against it in github
  echo -e "Creating git tag ${GREEN}${BUILD_TAG}${NC}"
  git tag \
    "${BUILD_TAG}" \
    -a \
    -m "Automated build ${BUILD_NUMBER}"

  echo -e "Pushing tag ${GREEN}${BUILD_TAG}${NC}"
  git push \
    -q \
    origin \
    "${BUILD_TAG}"
}

#have_release_branches_changed() {
  #echo TODO
#}

# Return: 0 if changed, 1 if not
has_release_branch_changed() {
  local branch_name="$1"; shift
  local repo_root="$1"; shift

  # Get the latest commit sha on this branch
  # DO NOT echo the token
  local latest_commit_sha=
  latest_commit_sha="$( \
    curl \
      --silent \
      --header "authorization: Bearer ${GITHUB_TOKEN}" \
      "${GIT_API_URL}/commits/${branch_name}" \
    | jq -r '.sha')"

  local gh_pages_commit_sha_file="${CURRENT_GH_PAGES_DIR}/${branch_name}/${COMMIT_SHA_FILENAME}"

  echo -e "${GREEN}gh_pages_commit_sha_file: ${BLUE}${gh_pages_commit_sha_file}${NC}"
  echo -e "${GREEN}branch_name: ${BLUE}${branch_name}${NC}"
  echo -e "${GREEN}latest_commit_sha: ${BLUE}${latest_commit_sha}${NC}"
  
  # When we build gh-pages from source we write the commit sha to a file
  # so we know which commit it came from
  if [[ -f "${gh_pages_commit_sha_file}" ]]; then
    local gh_pages_commit_sha
    gh_pages_commit_sha=$(<"${gh_pages_commit_sha_file}")
    echo -e "${GREEN}gh_pages_commit_sha: ${BLUE}${gh_pages_commit_sha}${NC}"

    if [[ "${gh_pages_commit_sha}" = "${latest_commit_sha}" ]]; then
      return 1
    else
      have_any_release_branches_changed=true
      return 0
    fi
  else
    # No commit sha file so treat as changed
    echo -e "${GREEN}Commit file ${BLUE}${gh_pages_commit_sha_file}${GREEN}" \
      "not found, treat as changed.${NC}"
    have_any_release_branches_changed=true
    return 0
  fi
}

clone_current_gh_pages_branch() {
  echo -e "${GREEN}Cloning gh-pages branch into" \
    "${BLUE}${CURRENT_GH_PAGES_DIR}${NC}"
  git \
    clone \
    --depth 1 \
    --branch "gh-pages" \
    --single-branch \
    "${GIT_REPO_URL}" \
    "${CURRENT_GH_PAGES_DIR}"
}

prepare_for_release() {
  #echo -e "${GREEN}Copying from ${BLUE}${COMBINED_SITE_DIR}/${GREEN}" \
    #"to ${BLUE}${NEW_GH_PAGES_DIR}/${NC}"
  #cp -r "${COMBINED_SITE_DIR}"/* "${NEW_GH_PAGES_DIR}/"

  # Make sure master dir is not in the zipped site. It is ok to have it
  # in the gh-pages one so we can see docs for an as yet un-released
  # stroom, though master should not appear in the versions dropdown.
  rm -rf "${NEW_GH_PAGES_DIR}/master"

  echo -e "${GREEN}Dumping contents of ${BLUE}${NEW_GH_PAGES_DIR}${NC}"
  ls -1 "${NEW_GH_PAGES_DIR}/"

  echo -e "${GREEN}Making a zip of the combined site html content${NC}"

  # pushd so all paths in the zip are relative to this dir
  pushd "${NEW_GH_PAGES_DIR}"
  # Exclude the individual version zip/pdfs from the combined zip
  # Exclude arg needs to go after zip filename and target(s)
  # We have the 'latest' symlink so add that to the zip as a link
  # rather than dereferencing
  zip \
    --recurse-paths \
    --symlinks \
    --quiet \
    -9 \
    "${RELEASE_ARTEFACTS_DIR}/${ZIP_FILENAME}" \
    ./* \
    --exclude '*/stroom-docs-v*.zip' \
    --exclude '*/stroom-docs-v*.pdf'
  popd

  echo -e "${GREEN}Dumping contents of ${BLUE}${RELEASE_ARTEFACTS_DIR}${NC}"
  ls -1 "${RELEASE_ARTEFACTS_DIR}/"

  if [[ "${LOCAL_BUILD}" != "true" \
    && -n "$BUILD_TAG" \
    && "${BUILD_IS_PULL_REQUEST}" != "true" ]] ; then

    create_release_tag
  else
    echo -e "${GREEN}Not a release so won't tag the repository${NC}"
  fi
}

populate_release_brances_arr() {
  echo -e "${GREEN}Getting list of release branches${NC}"

  # Read all the matching release branches into the arr
  readarray -t release_branches \
    < <(curl \
      --silent \
      --header "authorization: Bearer ${GITHUB_TOKEN}" \
      "${GIT_API_URL}/branches" \
      | jq -r '.[] | select(.name | test("(^legacy|[0-9]+\\.[0-9]+$)")) | .name')

  echo -e "release_branches:      [${GREEN}${release_branches[*]}${NC}]"

  if [[ "${#release_branches[@]}" -eq 0 ]]; then
    echo "Error no release branches found. Dumping branches:"
    echo "---------"
    curl \
      --silent \
      --header "authorization: Bearer ${GITHUB_TOKEN}" \
      "${GIT_API_URL}/branches" \
      | jq -r '.[] | select(.name | test("(^legacy|[0-9]+\\.[0-9]+$)")) | .name'
    echo "---------"
    exit 1
  fi

  # print array, null delimited
  # Get just the 123.456 ones
  # Sort them by major then minor part
  # Get the biggest one
  latest_version="$( \
    printf '%s\n' "${release_branches[@]}" \
    | grep -E "^[0-9]+\.[0-9]+$" \
    | sort -t . -k 1,1n -k 2,2n \
    | tail -n1)"

  echo -e "latest_version:        [${GREEN}${latest_version}${NC}]"
}

main() {
  setup_echo_colours

  # Array of branch names that contain a version of the site,
  # e.g. 7.1, 7.0, legacy
  # A site will be built for each one to create one big combined site
  # that will be rsync'd into gh-pages and zipped up.
  # A PDF will be generated for each one.

  # gh-pages will look roughly like:
  #   / # Will contain copy of the site of the latest version
  #   /legacy/
  #   /7.0/
  #   /7.1/
  #   ...
  # Master should not be published to ghpages or released.
  #release_branches=(
    #"hugo-docsy"
  #)

  #release_branches=(
    #"7.0"
    #"legacy"
  #)

  local PDF_FILENAME_BASE="${BUILD_TAG:-SNAPSHOT}"
  local ZIP_FILENAME="${BUILD_TAG:-SNAPSHOT}.zip"
  local RELEASE_ARTEFACTS_DIR_NAME="release_artefacts"
  local RELEASE_ARTEFACTS_DIR="${BUILD_DIR}/${RELEASE_ARTEFACTS_DIR_NAME}"
  #local RELEASE_ARTEFACTS_REL_DIR="./${RELEASE_ARTEFACTS_DIR_NAME}"
  #local COMBINED_SITE_DIR="${BUILD_DIR}/_combined_site"
  local SINGLE_SITE_DIR="${BUILD_DIR}/_single_site"
  local GIT_WORK_DIR="${BUILD_DIR}/_git_work"
  #local SITE_DIR="${BUILD_DIR}/public"
  local NEW_GH_PAGES_DIR="${BUILD_DIR}/gh-pages"
  local CURRENT_GH_PAGES_DIR="${BUILD_DIR}/gh-pages_current"
  #local BASE_URL_BASE="/stroom-docs"
  local GIT_REPO_URL="https://github.com/gchq/stroom-docs.git"
  local GIT_API_URL="https://api.github.com/repos/gchq/stroom-docs"
  local GH_PAGES_BASE_URL="https://gchq.github.io/stroom-docs"
  local CONFIG_FILENAME="config.toml"
  local COMMIT_SHA_FILENAME="commit.sha1"
  local GOOGLE_VERIFICATION_FILENAME="googlebc2798bfa34e6596.html"
  local have_any_release_branches_changed=false
  # These are the sections we don't want in old/single versions of the site
  # Can't remove community at the mo as some pages in docs link to it
  local UNWANTED_SECTIONS=(
    #"community"
    "news"
  )

  echo -e "BUILD_BRANCH:          [${GREEN}${BUILD_BRANCH}${NC}]"
  echo -e "BUILD_COMMIT:          [${GREEN}${BUILD_COMMIT}${NC}]"
  echo -e "BUILD_DIR:             [${GREEN}${BUILD_DIR}${NC}]"
  echo -e "BUILD_IS_PULL_REQUEST: [${GREEN}${BUILD_IS_PULL_REQUEST}${NC}]"
  echo -e "BUILD_IS_RELEASE:      [${GREEN}${BUILD_IS_RELEASE}${NC}]"
  echo -e "BUILD_NUMBER:          [${GREEN}${BUILD_NUMBER}${NC}]"
  echo -e "BUILD_TAG:             [${GREEN}${BUILD_TAG}${NC}]"
  echo -e "GITHUB_EVENT_NAME:     [${GREEN}${GITHUB_EVENT_NAME}${NC}]"
  echo -e "LOCAL_BUILD:           [${GREEN}${LOCAL_BUILD}${NC}]"
  echo -e "PDF_FILENAME_BASE:     [${GREEN}${PDF_FILENAME_BASE}${NC}]"
  echo -e "PWD:                   [${GREEN}$(pwd)${NC}]"
  echo -e "ZIP_FILENAME:          [${GREEN}${ZIP_FILENAME}${NC}]"
  echo -e "UNWANTED_SECTIONS:     [${GREEN}${UNWANTED_SECTIONS[*]}${NC}]"

  mkdir -p "${RELEASE_ARTEFACTS_DIR}"
  mkdir -p "${GIT_WORK_DIR}"
  mkdir -p "${NEW_GH_PAGES_DIR}"
  mkdir -p "${SINGLE_SITE_DIR}"

  local release_branches=()
  # Set by populate_release_brances_arr()
  local latest_version=

  populate_release_brances_arr

  # TODO Need to check for broken simple markdown links

  # Get a local copy of the gh-pages branch as it stands
  clone_current_gh_pages_branch

  # If this is a scheduled build there is point in building the master branch
  # as it will have been built before and is not part of the release.
  if [[ ! "${GITHUB_EVENT_NAME}" = "schedule" ]]; then
    # Build the commit/tag/pr that triggered this script to run
    # to ensure the site and PDF build ok. E.g. this might be some feature
    # branch
    build_version_from_source "${BUILD_BRANCH}" "${BUILD_DIR}"
  fi

  # TODO get this working for hugo content
  #echo -e "${GREEN}Checking all .md files for broken links${NC}"
  #./broken_links.sh

  pushd "${GIT_WORK_DIR}"

  # Now build each of the release branches (if they have changed)
  for branch_name in "${release_branches[@]}"; do

    if ! git ls-remote --exit-code --heads origin "refs/heads/${branch_name}"; then
      echo -e "${RED}ERROR: Branch ${BLUE}${branch_name}${RED}" \
        "does not exist. Check contents of release_branches array.${NC}"
      exit 1
    fi

    # Don't build the branch that we built above
    if [[ "${branch_name}" != "${BUILD_BRANCH}" ]]; then

      # Run the build for this branch in the self named dir
      assemble_version "${branch_name}" "${branch_clone_dir}"
    else
      echo -e "${GREEN}Skipping build for ${BLUE}${branch_name}${NC}"
    fi
  done

  popd

  create_root_sitemap

  # In the absence of url rewriting on github pages create a symlink
  # that does a redirect to the latest version e.g. / => /7.1
  create_root_redirect_page

  echo -e "${GREEN}have_any_release_branches_changed:" \
    "${BLUE}${have_any_release_branches_changed}${NC}"

  #if element_in "${BUILD_BRANCH}" "${release_branches[@]}"; then
  if [[ "${BUILD_IS_RELEASE}" = "true" ]]; then
    if [[ "${have_any_release_branches_changed}" = "true" ]]; then

      prepare_for_release

      echo "CONTENT_HAS_CHANGED=true" >> "${GITHUB_ENV}"

    else
    echo -e "${GREEN}Nothing has changed since last release so skipping" \
      "release preparation${NC}"

    # Clear out any artefacts to be on the safe side
    rm -rf "${RELEASE_ARTEFACTS_DIR:?}/*"
    rm -rf "${NEW_GH_PAGES_DIR:?}/*"

    echo "CONTENT_HAS_CHANGED=false" >> "${GITHUB_ENV}"
    fi
  else
    echo -e "${GREEN}Not a release so skipping releaase preparation${NC}"

    # Clear out any artefacts to be on the safe side
    rm -rf "${RELEASE_ARTEFACTS_DIR:?}/*"
    rm -rf "${NEW_GH_PAGES_DIR:?}/*"

    echo "CONTENT_HAS_CHANGED=false" >> "${GITHUB_ENV}"
  fi
}

main "$@"
