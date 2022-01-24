---
title: "Building the Documentation"
linkTitle: "Building the Documentation"
weight: 10
date: 2022-01-12
tags: 
description: >
  How to develop and build the documentation.
---


## Prerequisites

In order to build and contribute to the documentation you will need the following installed:

* bash
* [Docker (external link)](https://docs.docker.com/get-docker/)

Docker is required as all the build steps are performed in docker containers to ensure a consistent and known build environment.
It also ensures that the local build environment matches that used in GitHub actions.

It is possible to build the docs without docker but you would need to install all the other dependencies that are provided in the docker images, e.g. java, plantuml, puppeteer, hugo, npm, html2canvas, jspdf, graphviz etc.


## Cloning the stroom-docs git repository

The git repository for this site is [stroom-docs (external link)](https://github.com/gchq/stroom-docs).
_stroom-docs_ uses the Docsy theme (`themes/docsy/`) via a git sub-module, which in turn uses two nested sub-modules for Bootstrap (`themes/docsy/assets/vendor/bootstrap/`) and Font-Awesome (`themes/docsy/assets/vendor/Font-Awesome/`).
Therefore to clone stroom-docs you need to do

```bash
# Clone the repo
git clone https://github.com/gchq/stroom-docs.git

cd stroom-docs

# Download all sub modules
git submodule update --init --recursive
```


## Converting the PlantUML files to SVG

_stroom-docs_ makes used of [PlantUML (external link)](https://plantuml.com) for a lot of its diagrams.
These are stored in the repository as `.puml` text files.
In order that they can be rendered in the site they need to be converted into SVGs first.

{{% note %}}
Docsy has the capability to render PlantUML content in fenced code blocks on the fly.
This capability makes use of internet based servers to do the conversion therefore it is not suitable for this site as this site needs to available for deployment in environments with no internet access.
All PlantUML content should authored in `.puml` files and converted at build time.
{{% /note %}}

To convert all `.puml` files into sibling `.puml.svg` files do the following:

```bash
./container_build/runInPumlDocker.sh SVG
```

This command will find all `.puml` files (in `content/` and `assets/`) and convert each one to SVG.
It only needs to be run on first clone of the repo or when `.puml` files are added/changed.
The generated `.puml.svg` files are ignored by git.
This command will be run as part of the GitHub Actions automated build.

{{% warning %}}
If `runInPumlDocker.sh SVG` is not run having added links to PlantUML images in the documentation, then when you build or serve the site you will see errors like this:

```text
Error: Error building site: "/builder/shared/content/en/docs/user-guide/concepts/streams.md:57:1":
failed to render shortcode "image":
failed to process shortcode: "/builder/shared/layouts/shortcodes/image.html:54:21":
execute of template failed: template: shortcodes/image.html:54:21:
executing "shortcodes/image.html" at <$image.Name>: nil pointer evaluating resource.Resource.Name
```
{{% /warning %}}


{{% note %}}
In the build docker containers your local _stroom-docs_ repository is mounted into the container as `/builder/shared/`, so if you see this path mentioned in the logs this is referring to your local repository.
{{% /note %}}


## Running a local server

The documentation can be built and served locally while developing it.
To build and serve the site run

```bash
./container_build/runInHugoDocker.sh server
```

This uses Hugo to build the site in memory and then serve it from a local web server.
When any source files are changed or added Hugo will detect this and rebuild the site as required, including refreshing the browser page.

Once the server is running the site is available at [localhost:1313/stroom-docs](http://localhost:1313/stroom-docs).

{{% warning %}}
Sometimes changes made to the site source will not be re-loaded correctly so it may be necessary to stop and re-start the server.
{{% /warning %}}


## Building the site locally

To perform a full build of the static site run:

```bash
./container_build/runInHugoDocker.sh build
```

This will generate all the static content and place it in `public/`.


## Generating the PDF

Every page has a _Print entire section_ link that will display a printable view of that section and its children.
In addition to this the GitHub Actions we generate a PDF of the `docs` section and all its children, i.e. all of the documentation (but not News/Releases or Community) in one PDF.
This makes the documentation available for offline use.

To test the PDF generation do:

```bash
./container_build/runInPupeteerDocker.sh PDF
```

## Site versioning

The _Docsy_ theme supports site versioning so that multiple versions of the site can link between each other.
For this documentation, each version of the site is tied to a minor release of Stroom, e.g. `7.0`, `7.1`, `7.2`, `8.0` etc.
Each Stroom version is represented by a git branch of the same name.
Documentation changes for an as yet unreleased Stroom version would be performed on the `master` branch.

When the combined site is built, each version will exist within a directory as siblings of each other, i.e.

```text
/7.0/
/7.1/
/7.2/
/8.0/
/legacy/
```

### Versioned Site Configuration

To configure each version of the site so that it knows what version it is and what the other versions are you need to edit `config.toml`.
This needs to be done on each branch in a way that is appropriate to each branch.
If a change needs to be applied to all branches then it is best to make it in the oldest branch for which the documentation is published and then merged the changes up the chain, e.g. legacy => 7.0 => 7.1 => 7.2 => 8.0 => master.

The following config properties needed to be amended on each branch.
This example is based on there being version legacy, 7.0 and 7.1, with 7.1 being the latest.

```toml
[params]
  # Menu title if your navbar has a versions selector to access old versions of your site.
  version_menu = "Stroom Version (7.1)"

  # If true, displays a banner on each page warning that it is an old version.
  # Set this to true on each git branch of stroom-docs that is not the latest release branch
  archived_version = false

  # Used in the banner on each archived page.
  # Must match the value in brackets in "version_menu" above
  version = "7.1"

  # A link to latest version of the docs. Used in the "version-banner" partial to
  # point people to the main doc site.
  url_latest_version = "/../7.1"

  # The name of the github branch that this version of the documentation lives on.
  # Used for the github links in the top of the right hand sidebar.
  # Should match the last part of url_latest_version.
  github_branch= "7.1"

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


### Building a mock multi-version site

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

### Changing the site look

Ideally changes to the look of the site, e.g. upgrading the _Docsy_ theme sub-module to a new commit, should be done on all branches so when switching between branches the look doesn't change.
This means changes to the site framework should be done on the oldest published version branch and then merged up the chain to the others.

In some cases a change to the look may require significant refactoring of the content, e.g. changes to a shortcode.
In the event of this it may be necessary to only make the change on the latest release branch and for different versions to have a slightly different look.
The decision on how best to tackle these situations will have to be on a case by case basis.




