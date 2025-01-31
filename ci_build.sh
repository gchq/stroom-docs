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

# Replace everything inside 
# <<<VERSIONS_BLOCK_START>>>
# ...
# <<<VERSIONS_BLOCK_END>>>
# with one of these blocks per branch
#
#  [[params.versions]]
#    version = "7.3"
#    url = "/../7.3" 
replace_versions_block() {
  local config_file="$1"; shift

  local new_content=""

  # BUILD_BRANCH is the git branch we are building
  # branch_name is the version that we are trying to add to our
  # versions block in the config
  # Each git branch will contain a config file that defines all the versions
  # but the url to get from one version to another 
  # NOTE hugo converts "/" into the root of the versioned site,
  # NOT the root of the whole combined site.
  local ver
  local url
  for branch_name in "${release_branches[@]}"; do
    # Uppercase legacy if present
    ver="${branch_name/legacy/Legacy}"
    url="/../${branch_name}"

    if [[ "${branch_name}" = "${BUILD_BRANCH}" ]]; then
      # This is the version we are building so it is located at the
      # versioned site root regardless of where that is.
      url="/"
    else
      # Different version to the branch being built
      if [[ "${BUILD_BRANCH}" = "${latest_version}" ]]; then
        # We are building the latest version branch, so our versioned site
        # is at the combined site root.
        if [[ "${branch_name}" = "${latest_version}" ]]; then
          url="/"
        else
          url="/${branch_name}"
        fi
      else
        # Building a branch different to branch_name
        if [[ "${branch_name}" = "${latest_version}" ]]; then
          # Up one to the combined site root
          url="/../"
        else
          # Up one then back down to a sibling
          url="/../${branch_name}"
        fi
      fi
    fi

    if [[ "${branch_name}" = "${latest_version}" ]]; then
      ver="${ver} (Latest)"
    fi

    new_content="${new_content}\n\n  [[params.versions]]"
    new_content="${new_content}\n    version = \"${ver}\""
    new_content="${new_content}\n    url = \"${url}\""
  done

  new_content="${new_content}\n"
  echo -e "new_content:\n${new_content}"

  # Export it to an env var so perl can readit from there to avoid
  # a load of escaping and control character issues by being
  # able to use a single quoted perl command.
  # shellcheck disable=SC2155
  export new_content="$(echo -e "${new_content}")"

  # Replace everything inside the two tags with new_content
  perl \
    -0777 \
    -i \
    -pe \
    's/^([\t ]*#[\t ]*<<<VERSIONS_BLOCK_START>>>[^\n]*\n).*(\n[^\n]*<<<VERSIONS_BLOCK_END>>>[^\n]*)$/$1$ENV{new_content}$2/gsm' \
    "${config_file}"

  echo -e "${GREEN}Dumping versions section:"
  awk '/^.*<<<VERSIONS_BLOCK_START>>>.*$/,/^.*<<<VERSIONS_BLOCK_END>>>.*$/' \
    "${config_file}"
}

build_version_from_source() {
  local branch_name="${1:-SNAPSHOT}"; shift
  local repo_root="$1"; shift

  pushd "${repo_root}"
  
  local version_name="${branch_name}"
  if [[ "${version_name}" = "legacy" ]]; then
    version_name="Legacy"
  fi
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
    "\n  version_name:           ${BLUE}${version_name}${GREEN}" \
    "\n  branch_head_commit_sha: ${BLUE}${branch_head_commit_sha}${GREEN}" \
    "\n  repo_root:              ${BLUE}${repo_root}${GREEN}" \
    "\n  latest_version:         ${BLUE}${latest_version}${GREEN}"
    #"\n  base_url:        ${BLUE}${hugo_base_url}${NC}"
  echo -e "${GREEN}-----------------------------------------------------${NC}"

  if [[ -n "${BUILD_TAG}" ]]; then
    echo "::group::Config modification"
    local config_file="${repo_root}/${CONFIG_FILENAME}"
    echo -e "${GREEN}Updating config file ${BLUE}${config_file}${GREEN}" \
      "(build_version=${BUILD_TAG:-SNAPSHOT})${NC}"

    local is_archived_version="true"
    if [[ "${branch_name}" = "${latest_version}" ]]; then
      is_archived_version="false"
    fi

    config_file_backup="${config_file}.bak"
    cp "${config_file}" "${config_file_backup}"
    # Set all the version related config props based on the branch we are
    # building and whether it is the latest version or not
    sed \
      --regexp-extended \
      --expression "s|^\s*build_version\s*=.*|  build_version = \"${BUILD_TAG:-SNAPSHOT}\"|" \
      --expression "s|^\s*archived_version\s*=.*|  archived_version = ${is_archived_version}|" \
      --expression "s|^\s*version_menu\s*=.*|  version_menu = \"Stroom Version (${version_name})\"|" \
      --expression "s|^\s*version\s*=.*|  version = \"${branch_name}\"|" \
      --expression "s|^\s*latest_version\s*=.*|  latest_version = \"${latest_version}\"|" \
      --expression "s|^\s*github_branch\s*=.*|  github_branch = \"${branch_name}\"|" \
      "${config_file_backup}" \
      > "${config_file}"

    replace_versions_block "${config_file}"

    #echo -e "${GREEN}Diffing config file changes" \
      #"${BLUE}${config_file_backup}${GREEN} => ${BLUE}${config_file}${NC}"
    #diff --color "${config_file_backup}" "${config_file}" || true
    echo "::endgroup::"
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

remove_remote_calls() {
  # This is here to remove any imports from external cdns which
  # won't work in an air-gapped env. Obviously this risks breaking
  # the docs site if they are needed, in which case we will need
  # to serve them as part of the docs site like we have done for the
  # google open sans font.
  # An example of a cdn link we need to remove is:
  # https://cdn.jsdelivr.net/gh/rastikerdar/vazir-font@v27.0.1/dist/font-face.css
  # which is an arabic font that we don't need at the moment.
  echo -e "${GREEN}Remvoing cdn imports${NC}"
  local regex='@import "https:\/\/cdn[^"]+";'
  grep \
    --perl-regexp \
    --only-matching \
    --recursive \
    "${regex}"

  find . -type f -print0 \
    | xargs -0 \
    sed -i'' -E "s|${regex}||g"

  if grep \
    --perl-regexp \
    --only-matching \
    --recursive \
    --quiet \
    "${regex}"; then
    
    echo -e "${RED}ERROR${NC}: Found cdn imports in the built site"

    grep \
      --perl-regexp \
      --only-matching \
      --recursive \
      "${regex}"
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

  # We are creating a zip for offline use so remove any remote import calls
  remove_remote_calls

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

set_meta_robots_for_all_version_branches() {
  echo "::group::Set meta robots"
  echo -e "${GREEN}Setting meta robots for all versioned brances in" \
    "${BLUE}${NEW_GH_PAGES_DIR}${NC}"

  for branch_name in "${release_branches[@]}"; do
    local site_html_root_dir="${NEW_GH_PAGES_DIR}/${branch_name}"
    echo "site_html_root_dir: ${site_html_root_dir}"

    if [[ -d "${site_html_root_dir}" ]]; then
      # Replace "index, follow" with "noindex, nofollow" so our version branches
      # that are not the latest one don't get indexed. We only want the 'latest'
      # content to be indexed by google.
      set_meta_robots "${site_html_root_dir}" "no"
    else
      echo -e "${RED}Error${NC} Can't find dir ${site_html_root_dir}"
      exit 1
    fi
  done
  echo "::endgroup::"
}

set_meta_robots() {
  echo "args: ${*}"
  local site_html_root_dir="$1"; shift
  local prefix="$1"; shift
  echo "prefix: ${prefix}"

  local old="<meta name=\"robots\" content=\"(no)?index, (no)?follow\">"
  local new="<meta name=\"robots\" content=\"${prefix}index, ${prefix}follow\">"
  echo "old: ${old}"
  echo "new: ${new}"

  echo -e "${GREEN}Setting meta robots to ${prefix}index/${prefix}follow" \
    "in ${BLUE}${site_html_root_dir}${NC}"
  
  find \
      "${site_html_root_dir}" \
      -name "*.html" \
      -print0 \
    | xargs \
      -0 \
      sed \
      -i \
      -E \
      "s#${old}#${new}#"
}

# Copies the site map from the latest branch down to the root
# and changes all the <loc> tags in the sitemap to point sub-paths of
# the latest branch dir
update_root_sitemap() {
  echo "::group::Update sitemap"
  echo "Changing <loc> tags in root sitemap.xml to point to ${GH_PAGES_BASE_URL}/"
  sed \
    -i \
    "s#<loc>/#<loc>${GH_PAGES_BASE_URL}/#" \
    "${NEW_GH_PAGES_DIR}/sitemap.xml"

  echo "Creating robots.txt file pointing to sitemap"
  {
    echo "User-agent: *" 
    echo "Sitemap: ${GH_PAGES_BASE_URL}/sitemap.xml" 
  } > "${NEW_GH_PAGES_DIR}/robots.txt"
  echo "::endgroup::"
}

copy_latest_to_root() {
  echo "::group::Copy lastest to root"

  # Copy the latest version content down to the root dir
  # That way we can make all other dirs noindex/nofollow to stop
  # google finding them.
  # Don't just rename it, so that we keep a numbered version on
  # gh-pages that we can check the commit for, (see has_release_branch_changed)
  #
  # /    <--copy-of-- /7.2/
  #   /7.0/
  #   /7.1/
  #   /7.2/

  local src="${NEW_GH_PAGES_DIR}/${latest_version}"
  local latest_temp_dir="${NEW_GH_PAGES_DIR}/latest_temp"

  # Copy into temp so when we call set_meta_robots it doesn't descend
  # into the other version dirs
  echo -e "${GREEN}Coping dir ${BLUE}${src}${GREEN} to ${BLUE}${latest_temp_dir}${NC}"
  cp -r "${src}" "${latest_temp_dir}/" 

  # Ensure we have index and follow for the latest site content
  set_meta_robots "${latest_temp_dir}" ""

  # Now move the latest content down to root
  echo -e "${GREEN}Moving contents of ${BLUE}${latest_temp_dir}/${GREEN} to" \
    "${BLUE}${NEW_GH_PAGES_DIR}/${NC}"
  mv "${latest_temp_dir}"/* "${NEW_GH_PAGES_DIR}/"

  # This is to stop gh-pages treating the content as Jekyll content
  # in which case dirs prefixed with '_' are ignored breaking the print 
  # functionality
  local no_jekyll_file="${NEW_GH_PAGES_DIR}/.nojekyll"
  echo -e "${GREEN}Ensuring presence of ${BLUE}${no_jekyll_file}/${NC}"
  touch "${no_jekyll_file}"

  # Make sure the google site verification file is in gh-pages
  # so google can index the site
  echo -e "${GREEN}Copy google verification file${NC}"
  cp \
    "${BUILD_DIR}/${GOOGLE_VERIFICATION_FILENAME}" \
    "${NEW_GH_PAGES_DIR}/"
  echo "::endgroup::"
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
  echo "::group::Prepare for release"
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

  # We are creating a zip for offline use so remove any remote import calls
  remove_remote_calls

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
  echo "::endgroup::"
}

populate_release_brances_arr() {
  echo -e "${GREEN}Getting list of release branches${NC}"

  # Read all the matching release branches into the arr
  readarray -t release_branches \
    < <(curl \
      --silent \
      --header "authorization: Bearer ${GITHUB_TOKEN}" \
      "${GIT_API_URL}/branches" \
      | jq -r '.[] | select(.name | test("^(legacy$|[0-9]+\\.[0-9]+$)")) | .name')


  if [[ "${#release_branches[@]}" -eq 0 ]]; then
    echo "Error no release branches found. Dumping branches:"
    echo "---------"
    curl \
      --silent \
      --header "authorization: Bearer ${GITHUB_TOKEN}" \
      "${GIT_API_URL}/branches" \
      | jq -r '.[] | select(.name | test("^(legacy$|[0-9]+\\.[0-9]+$)")) | .name'
    echo "---------"
    exit 1
  fi

  local found_legacy=false
  if element_in "legacy" "${release_branches[@]}"; then
    found_legacy=true
  fi

  # print array, \n delimited
  # Get just the 123.456 ones
  # Numerically (n) reverse (r) sort them by major then minor part
  local line_delim_numeric_branches
  line_delim_numeric_branches="$( \
    printf '%s\n' "${release_branches[@]}" \
    | grep -E "^[0-9]+\.[0-9]+$" \
    | sort --reverse --field-separator . --key 1,1nr --key 2,2nr \
  )"

  # Clear it out and re-populate it in order, newest first
  release_branches=()
  for branch in ${line_delim_numeric_branches}; do
    release_branches+=( "${branch}" )
  done

  # Add the legacy branch back in if there
  if [[ "${found_legacy}" = "true" ]]; then
    # Add legacy at the end as it is the oldest
    release_branches+=( "legacy" )
  fi

  # First one in arr is the latest version
  latest_version="${release_branches[0]}"

  echo -e "release_branches:      [${GREEN}${release_branches[*]}${NC}]"
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

  echo "::group::Checking for broken links"
  echo -e "${GREEN}Checking all .md files for broken links${NC}"
  ./broken_links.sh
  echo "::endgroup::"

  pushd "${GIT_WORK_DIR}"

  # Only master branch builds all the branches
  if [[ "${BUILD_BRANCH}" = "master" ]]; then
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

    copy_latest_to_root
    update_root_sitemap
    set_meta_robots_for_all_version_branches

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
  fi
}

main "$@"
