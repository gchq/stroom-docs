---
title: "Managing Stroom Versions"
linkTitle: "Stroom Versions"
weight: 20
date: 2022-01-25
tags: 
description: >
  How to manage documentation for different versions of Stroom.

---

The _Docsy_ theme supports site versioning so that multiple versions of the site/documentation can exist and link between each other.
For this documentation site, each version of the site is tied to a minor release of Stroom, e.g. `7.0`, `7.1`, `7.2`, `8.0` etc.
Each Stroom version is represented by a git branch with the same name.
There is an additional git branch `legacy` that is for all Stroom versions prior to `7.0` and will be removed once the versions prior to `7.0` are no longer supported.
Documentation changes for an as yet unreleased Stroom version would be performed on the `master` branch.

When the combined site is built, each version will exist within a directory as siblings of each other, i.e.

```bash
/         # Latest version content lives here (i.e. copy of v8.0)
/7.0/
/7.1/
/7.2/
/8.0/     # Latest version is also published here but only used by CI build.
/legacy/
```

The `master` branch is NOT published to GitHub Pages or included in the release artefacts.


## Versioned Site Configuration

To configure each version of the site so that it knows what version it is and what the other versions are you need to edit `config.toml`.
This needs to be done on each branch in a way that is appropriate to each branch.
If a change needs to be applied to all branches then it is best to make it in the oldest branch for which the documentation is published, and then [merge the changes]({{< relref "#merging-changes" >}}) the changes up the chain, e.g. legacy => 7.0 => 7.1 => 7.2 => 8.0 => master.

The following config properties needed to be amended on each branch.
This example is from the _7.1_ branch and is based on there being versions _legacy_, _7.0_ and _7.1_, with _7.1_ being the latest.

{{< cardpane >}}
  {{< card header="7.0" >}}
```toml
[params]
  # Menu title if your navbar has a versions selector
  # to access old versions of your site.
  version_menu = "Stroom Version (7.0)"

  # If true, displays a banner on each page warning that
  # it is an old version. Set this to true on each git branch
  # of stroom-docs that is not the latest release branch
  archived_version = true

  # Used in the banner on each archived page.
  # Must match the value in brackets in "version_menu" above
  version = "7.0"

  # A link to latest version of the docs. Used in the
  # "version-banner" partial to point people to the main
  # doc site. Ignored for the latest version
  url_latest_version = "/../"

  # The version number of the latest version. Used in the
  # "version-banner" partial to tell people what the latest
  # version is. Ignored for the latest version
  latest_version = "7.1"

  # The name of the github branch that this version of the
  # documentation lives on. Used for the github links in the
  # top of the right hand sidebar. Should match the last part
  # of url_latest_version.
  github_branch = "7.0"

  # A set of all the versions that are available.
  [[params.versions]]
    version = "7.1 (Latest)"
    url = "/../"
  [[params.versions]]
    version = "7.0"
    url = "/../7.0"
  [[params.versions]]
    version = "Legacy"
    url = "/../legacy"
```
  {{< /card >}}

  {{< card header="7.1" >}}
```toml
[params]
  # Menu title if your navbar has a versions selector
  # to access old versions of your site.
  version_menu = "Stroom Version (7.1)"

  # If true, displays a banner on each page warning that
  # it is an old version. Set this to true on each git branch
  # of stroom-docs that is not the latest release branch
  archived_version = false

  # Used in the banner on each archived page.
  # Must match the value in brackets in "version_menu" above
  version = "7.1"

  # A link to latest version of the docs. Used in the
  # "version-banner" partial to point people to the main
  # doc site. Ignored for the latest version
  url_latest_version = "/../"

  # The version number of the latest version. Used in the
  # "version-banner" partial to tell people what the latest
  # version is. Ignored for the latest version
  latest_version = "7.1"

  # The name of the github branch that this version of the
  # documentation lives on. Used for the github links in the
  # top of the right hand sidebar. Should match the last part
  # of url_latest_version.
  github_branch = "7.1"

  # A set of all the versions that are available.
  [[params.versions]]
    version = "7.1 (Latest)"
    url = "/"
  [[params.versions]]
    version = "7.0"
    url = "/7.0"
  [[params.versions]]
    version = "Legacy"
    url = "/legacy"
```
  {{< /card >}}
{{< /cardpane >}}


## Automated build process

On every commit Github Actions will build the version of the site that the commit is on to ensure that Hugo can convert the content into a static site.
It will also build all the other versioned branches to check that they work.
On a nightly basis, Github Actions will also run a scheduled build on the _HEAD_ commit of the `master` branch.

In addition to building each version of the site, it will establish if the combined site needs to be published.
It will determine this by comparing the commit hashes of each version branch with the contents of a `commit.sha1` file that is published in each of the version directories on https://gchq.github.io/stroom-docs.
If any one of the hashes is different then the combined site will be assembled and published.

This automated build will look for any branches matching the pattern `(legacy|[0-9]+\.[0-9]+)` and for each one will do the following:

* Checkout that branch
* Build the site for that version using Hugo
  * Add the site files to a combined site
  * Generate the documenation PDF
* Build the site with no other versions configured
  * Create a zip of the single version site

Once each site has been processed it will:

* Copy the latest version of the site to the root of the combined site
* Create a single zip file containing the combined site
* Tag the release with a version number
* Add the following release artefacts:
  * Single version site zips
  * Combined site zip
  * Single version PDFs
* Publish the combined site to GitHub Pages {{< external-link "https://gchq.github.io/stroom-docs" "https://gchq.github.io/stroom-docs" >}}.

Although the build is run on the `master` branch it will use the `HEAD` commit of each of the release branches to build the site(s).

The build and release can be forced by adding the text `[publish]` to the commit message on `master`.
This is useful in testing, or if updated documentation is needed for any reason.

For example you can run this on the `master` branch to for:

{{< command-line >}}
git commit --allow-empty -m "Empty commit to force [publish]" && git push
{{</ command-line >}}


## Merging changes

When you make changes to one of the version branches (`7.0`, `7.1`, etc.), either directly or with a pull request from a feature branch, you will need to merge the changes up through each of the versions until they reach `master`.
Merging up through multiple branches is tedious when done manually so you can use the `merge_up.sh` script in the root of this repo.

You can either run it without any arguments to merge from `legacy` all the way up to `master` with all branches in between.
Alternatively you can supply the name of the branch to start from, e.g. `./merge_up.sh 7.0`, which will save it doing a pointless merge up from older branches that have not changed.

{{< command-line >}}
./merge_up.sh 7.0
(out)Merge_up will merge changes up this chain of branches:
(out)
(out)7.0 -> 7.1 -> master
(out)
(out)It will stop if there are merge conflicts.
(out)Press [y|Y] to continue, or ctrl+c to exit...
{{</ command-line >}}

When you run it, it will tell you the merge path and get you to confirm.
If there are no merge conflicts then it will perform all the merges and return you to your current branch.
If there are conflicts at any stage then it will stop at that point.
You will then need to fix the conflicts and commit the merge.
You can then run `merge_up.sh` again to do the rest of the merges.


## Where to make changes

The nature of a change to the site/documentation will determine which git branch the change is made on.


### Changes specific to a Stroom version

Any changes that are specific to a Stroom version, e.g. documenting a new feature in that version should be made on the oldest branch that contains that feature.
If the change relates to an as yet unreleased version of Stroom then make the change on `master`.


### Changes to the News/Releases

Adding news items or release notes for new versions should be done on the latest release branch.
The News/Releases section is not included in old versions when released.


### Changing the site look

Ideally changes to the look of the site, e.g. upgrading the _Docsy_ theme sub-module to a new commit, adding shortcodes or tweaking the CSS should be done on all branches so when switching between branches the look doesn't change.
This means this sort of change should be done on the oldest published version branch and then merged up the chain to the others, e.g. `legacy` => `7.0` => `7.1` => `master`.

In some cases a change to the look may require significant refactoring of the content, e.g. changes to a shortcode.
In the event of this it may be necessary to only make the change on the latest release branch and for different versions to have a slightly different look.
The decision on how best to tackle these situations will have to be on a case by case basis.


### Changing the GitHub Actions build process

If the change impacts the building of a single version then it needs to be done on the oldest version and merge up.

If the change only impacts the preparation of release artefacts then it can be performed on the `master` branch.


## Building a mock multi-version site

To make it easier to test how the combined site will look with multiple versions the following script can be run to mock up a multi-version site.
It does the following:

1. Copies the content of the local repository.
1. Amends the config file to set appropriate versions.
1. Builds the site for that version.
1. Copies the built site into a sub-directory matching the version in `/tmp/stroom-docs_mock_combined_site/`.

To run this script do:

```bash
create_mock_combined_site.sh
```

The combined site can be served using something like the Python simple HTTP server, e.g. 

```bash
cd /tmp/stroom-docs_mock_combined_site
python -m SimpleHTTPServer 8888
```

Then open a browser at [localhost:8888](localhost:8888).

As each version of the site is a copy of the same thing the content will be all the same but it allows you to test the version drop down and archived banner.
