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

```text
/7.0/
/7.1/
/7.2/
/8.0/
/legacy/
```

The `master` branch is NOT published to GitHub Pages or included in the release artefacts.


## Versioned Site Configuration

To configure each version of the site so that it knows what version it is and what the other versions are you need to edit `config.toml`.
This needs to be done on each branch in a way that is appropriate to each branch.
If a change needs to be applied to all branches then it is best to make it in the oldest branch for which the documentation is published and then merged the changes up the chain, e.g. legacy => 7.0 => 7.1 => 7.2 => 8.0 => master.

The following config properties needed to be amended on each branch.
This example is from the _7.1_ branch and is based on there being versions _legacy_, _7.0_ and _7.1_, with _7.1_ being the latest.

{{< cardpane >}}
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
  # doc site.
  url_latest_version = "/../7.1"

  # The name of the github branch that this version of the
  # documentation lives on. Used for the github links in the
  # top of the right hand sidebar. Should match the last part
  # of url_latest_version.
  github_branch = "7.1"

  # A set of all the versions that are available.
  [[params.versions]]
    version = "7.1"
    url = "/../7.1"
  [[params.versions]]
    version = "7.0"
    url = "/../7.0"
  [[params.versions]]
    version = "Legacy"
    url = "/../legacy"
```
  {{< /card >}}
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
  # doc site.
  url_latest_version = "/../7.1"

  # The name of the github branch that this version of the
  # documentation lives on. Used for the github links in the
  # top of the right hand sidebar. Should match the last part
  # of url_latest_version.
  github_branch = "7.0"

  # A set of all the versions that are available.
  [[params.versions]]
    version = "7.1"
    url = "/../7.1"
  [[params.versions]]
    version = "7.0"
    url = "/../7.0"
  [[params.versions]]
    version = "Legacy"
    url = "/../legacy"
```
  {{< /card >}}
{{< /cardpane >}}



In the same example scenario as above, the `config.toml` file for the _7.0_ branch (which is not the latest version in this case) would be:



## Automated build process

The site is built by Gihub Actions on a nightly basis.
This schedule is controlled by {{< external-link "build_and_release.yml" "https://github.com/gchq/stroom-docs/blob/master/.github/workflows/build_and_release.yml" >}} on the `master` branch.

This automated build will look for any branches matching the pattern `(legacy|[0-9]+\.[0-9]+)` and for each one will do the following:

* Checkout that branch
* Build the site for that version using Hugo
  * Add the site files to a combined site
  * Generate the documenation PDF
* Build the site with no other versions configured
  * Create a zip of the single version site

Once each site has been processed it will:

* Create a single zip file containing the combined site
* Tag the release with a version number
* Add the following release artefacts:
  * Single version site zips
  * Combined site zip
  * Single version PDFs
* Create a root `index.hml` file that will redirect to the latest version sub-directory.
* Publish the combined site to GitHub Pages {{< external-link "https://gchq.github.io/stroom-docs" "https://gchq.github.io/stroom-docs" >}}.

Although the build is run on the `master` branch it will use the `HEAD` commit of each of the release branches to build the site(s).

The build and release can be forced by adding the text `[publish]` to the commit message on `master`.
This is useful in testing, or if updated documentation is needed for any reason.


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
