---
title: "Building the Documentation"
linkTitle: "Building the Documentation"
weight: 10
date: 2022-01-12
tags: 
  - TODO
description: >
  How to develop and build the documentation.
---


## Prerequisites

In order to build and contribute to the documentation you will need the following installed:

* bash
* {{< external-link "Docker" "https://docs.docker.com/get-docker/" >}} 

Docker is required as all the build steps are performed in docker containers to ensure a consistent and known build environment.
It also ensures that the local build environment matches that used in GitHub actions.

It is possible to build the docs without docker but you would need to install all the other dependencies that are provided in the docker images, e.g. java, plantuml, puppeteer, hugo, npm, html2canvas, jspdf, graphviz etc.


## Cloning the stroom-docs git repository

The git repository for this site is {{< external-link "stroom-docs" "https://github.com/gchq/stroom-docs" >}}.
_stroom-docs_ uses the Docsy theme (`themes/docsy/`) via a git sub-module, which in turn uses two nested sub-modules for Bootstrap (`themes/docsy/assets/vendor/bootstrap/`) and Font-Awesome (`themes/docsy/assets/vendor/Font-Awesome/`).
Therefore to clone stroom-docs you need to do

{{< command-line >}}
# Clone the repo
git clone https://github.com/gchq/stroom-docs.git
(out)Cloning into 'stroom-docs'...
(out)remote: Enumerating objects: 66006, done.
(out)remote: Counting objects: 100% (7916/7916), done.
(out)remote: Compressing objects: 100% (1955/1955), done.
(out)remote: Total 66006 (delta 3984), reused 7417 (delta 3603), pack-reused 58090
(out)Receiving objects: 100% (66006/66006), 286.61 MiB | 7.31 MiB/s, done.
(out)Resolving deltas: 100% (34981/34981), done.
cd stroom-docs
(out)
# Download all sub modules
git submodule update --init --recursive
(out)Submodule 'themes/docsy' (https://github.com/google/docsy.git) registered for path 'themes/docsy'
(out)Cloning into '/tmp/stroom-docs/themes/docsy'...
(out)...
(out)Submodule 'assets/vendor/Font-Awesome' (https://github.com/FortAwesome/Font-Awesome.git) registered for path 'themes/docsy/assets/vendor/Font-Awesome'
(out)Submodule 'assets/vendor/bootstrap' (https://github.com/twbs/bootstrap.git) registered for path 'themes/docsy/assets/vendor/bootstrap'
(out)Cloning into '/tmp/stroom-docs/themes/docsy/assets/vendor/Font-Awesome'...
(out)Cloning into '/tmp/stroom-docs/themes/docsy/assets/vendor/bootstrap'...
(out)...
{{</ command-line >}}


## Converting the PlantUML files to SVG

_stroom-docs_ makes used of {{< external-link "PlantUML" "https://plantuml.com" >}} for a lot of its diagrams.
These are stored in the repository as `.puml` text files.
In order that they can be rendered in the site they need to be converted into SVGs first.

{{% note %}}
Docsy has the capability to render PlantUML content in fenced code blocks on the fly.
This capability makes use of internet based servers to do the conversion therefore it is not suitable for this site as this site needs to available for deployment in environments with no internet access.
All PlantUML content should authored in `.puml` files and converted at build time.
{{% /note %}}

To convert all `.puml` files into sibling `.puml.svg` files do the following:

{{< command-line >}}
./container_build/runInPumlDocker.sh SVG
{{</ command-line >}}

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

{{< command-line >}}
./container_build/runInHugoDocker.sh server
{{</ command-line >}}

This uses Hugo to build the site in memory and then serve it from a local web server.
When any source files are changed or added Hugo will detect this and rebuild the site as required, including automatically refreshing the browser page to update the rendered view.

Once the server is running the site is available at [localhost:1313/stroom-docs](http://localhost:1313/stroom-docs).

{{% warning %}}
Sometimes changes made to the site source will not be re-loaded correctly so it may be necessary to stop and re-start the server.
{{% /warning %}}


## Building the site locally

To perform a full build of the static site run:

{{< command-line >}}
./container_build/runInHugoDocker.sh build
{{</ command-line >}}

This will generate all the static content and place it in `public/`.


## Generating the PDF

Every page has a _Print entire section_ link that will display a printable view of that section and its children.
In addition to this the GitHub Actions we generate a PDF of the `docs` section and all its children, i.e. all of the documentation (but not News/Releases or Community) in one PDF.
This makes the documentation available for offline use.

To test the PDF generation do:

{{< command-line >}}
./container_build/runInPupeteerDocker.sh PDF
{{</ command-line >}}


## Updating the Docsy theme

This repository uses a git submodule for the Docsy theme.

{{% todo %}}
Complete this section.
Docsy is undergoing changes to make use of shallow sub modules for Bootstrap/Font-Awesome and to change to being a Hugo module so maybe wait until that is complete.
Cover how to update the submodule to the latest (or a specific) Docsy commit.
Warn of implications of breaking the site when updating with incompatible upstream changes.
{{% /todo %}}
