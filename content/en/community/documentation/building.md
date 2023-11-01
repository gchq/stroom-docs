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
* {{< external-link "Docker" "https://docs.docker.com/get-docker/" >}} 
* {{< external-link "docker-buildx" "https://github.com/docker/buildx#installing" >}}

{{% note %}}
If you cannot or do not want to install Docker and buildx on your local machine see [Developing Stroom-Docs on GitHub Codespaces]({{< relref "#developing-stroom-docs-on-github-codespaces" >}}) below.
{{% /note %}}

Docker or Docker Desktop is required as all the build steps are performed in docker containers to ensure a consistent and known build environment.
It also ensures that the local build environment matches that used in GitHub actions.

`docker-buildx` is a plugin for docker that allows caching of the docker images to speed up the build process.
This may be installed by your package manager when you install `docker` or Docker Desktop, or you may need to install it separately.
You can confirm you have `buildx` by executing the following command which should give you output similar to this:

{{< command-line >}}
docker buildx version
(out)github.com/docker/buildx 0.9.1 ed00243a0ce2a0aee75311b06e32d33b44729689
{{</ command-line >}}

It is possible to build the docs without docker but you would need to install all the other dependencies that are provided in the docker images, e.g. java, plantuml, puppeteer, hugo, npm, html2canvas, jspdf, graphviz etc.

It is assumed that you have a reasonable understanding of how to use Git and Github, specifically:

* Github
  * Forks
  * Pull requests
* Git
  * Branching
  * Pulling from upstream remotes


## Cloning the stroom-docs git repository

The git repository for this site is [stroom-docs (external link)](https://github.com/gchq/stroom-docs).
_stroom-docs_ uses the Docsy theme (`themes/docsy/`) via a Go module so the theme will be pulled in when Hugo is first run.

Unless you are a committer on the `gchq/stroom-docs` repository, you will need to fork this repository into your own Github account.
You can then clone your fork of the repository like so (in this example it is assumed your Github username is `jbloggs`):

{{< command-line >}}
# Clone the repo
git clone https://github.com/jbloggs/stroom-docs.git
(out)Cloning into 'stroom-docs'...
(out)remote: Enumerating objects: 66006, done.
(out)remote: Counting objects: 100% (7916/7916), done.
(out)remote: Compressing objects: 100% (1955/1955), done.
(out)remote: Total 66006 (delta 3984), reused 7417 (delta 3603), pack-reused 58090
(out)Receiving objects: 100% (66006/66006), 286.61 MiB | 7.31 MiB/s, done.
(out)Resolving deltas: 100% (34981/34981), done.
{{</ command-line >}}


### Configuring the fork

You now need to configure the clone of your fork with details of the `gchq/stroom-docs` upstream, which will allow you to pull changes from it.

{{< command-line >}}
git remote add upstream https://github.com/gchq/stroom-docs.git
{{</ command-line >}}


### Checking out the correct branch

There is a version of the documentation for each minor Stroom version (see [Stroom Versions]({{< relref "versions" >}}).

Before you start editing/viewing the documentation you need to be working from the correct branch of the Git repository.
If for example you are adding some content that is applicable to Stroom v7.0 then you need to checkout branch `7.0`.

{{< command-line >}}
git checkout 7.0
{{</ command-line >}}


### Creating a feature branch

If you are making changes to the documentation then the recommended working practice is to always make changes on a _feature branch_.
A feature branch would typically contain all commits/changes relating to a single feature, e.g. the addition of a new section, or updating the documentation for a specific change in Stroom.
Having only these changes on a branch makes it easy to merge them into the release branch (e.g. `7.0`) or to just delete the branch if they are no longer needed.
A feature branch would typically be merged into the appropriate release branch by creating a pull request in GitHub.

Assuming you have checked out the desired release branch that you would like your changes to ultimately be merged into, do something like the following to create a feature branch (where `add-properties-section` is the name of your branch):

{{< command-line >}}
git checkout -b add-properties-section
{{</ command-line >}}

This will create the named branch and check it out in one step.


## Serving the site on a local server

To view the stroom-docs site in a browser you simply need to run:

{{< command-line >}}
./serve_site.sh
{{</ command-line >}}

This will execute the following steps:

* [Convert PlantUML files to SVG]({{< relref "#converting-the-plantuml-files-to-svg" >}})
* [Run a local Hugo Server]({{< relref "#running-a-local-hugo-server" >}})


## Developing Stroom-Docs on GitHub Codespaces

If you cannot or do not want to install docker and buildx on your local machine but need to work on the documentation then you can do it from within {{< external-link "GitHub Codespaces" "https://github.com/features/codespaces" >}}.

{{% note %}}
Codespaces is a paid feature on GitHub, however it comes with 60hrs of free use per month so if you are only using it for stroom-docs development this should be ample.
{{% /note %}}

To develop Stroom-Docs with Codespaces do the following:

1. Visit Stroom-Docs' GitHub site at the desired version branch, e.g. {{< external-link "https://github.com/gchq/stroom-docs/tree/7.2" >}} (or visit {{< external-link "https://github.com/gchq/stroom-docs" >}} and switch branch using the branch/tag drop-down button).
  {{% note %}}
  If you are developing on a fork then replace `gchq` in the URL with your github username.
  {{% /note %}}
1. Click on the green _Code_ drop-down button.
1. On the Codespaces tab click on _Create Codespace on <branch>_
   {{< image "documenting-stroom/github-codespaces.png" "300x" />}}
   On first use of the Codespace it will take some time to do the initial setup of the development container.
   Subsequent uses will load more quickly.
1. It will open Visual Studio Code in the browser with a terminal pane at the bottom.
1. In the terminal pane enter:
   `./serve_site.sh`
   This will run the Hugo development server and Codespaces should detect the open port.
   You should see something like:
   {{< image "documenting-stroom/github-codespaces-open-port.png" "300x" />}}
1. Click _Open in Browser_ and it will open a URL unique to your Codespace in the browser displaying the stroom-docs site.

Within the Codespace you can use all the git commands to pull/push/commit changes.

To stop the code space hit `ctrl+shift+p`, enter `stop` and then select _Codespaces: Stop current Codespace_.


## Additional commands

### Converting the PlantUML files to SVG

_stroom-docs_ makes used of {{< external-link "PlantUML" "https://plantuml.com" >}} for a lot of its diagrams.
These are stored in the repository as `.puml` text files.
In order that they can be rendered in the site they need to be converted into SVGs first.

{{% note %}}
Docsy has the capability to render PlantUML content in fenced code blocks on the fly.
This capability makes use of internet based servers to do the conversion therefore it is not suitable for this site as this site needs to available for deployment in environments with no internet access.
All PlantUML content should authored in `.puml` files and converted at build time.
{{% /note %}}

To convert all `.puml` files into sibling `.puml.svg` files, run this from the repository root:

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


### Running a local Hugo server

The documentation can be built and served locally while developing it.
To build and serve the site, run this from the repository root.

{{< command-line >}}
./container_build/runInHugoDocker.sh server
{{</ command-line >}}

This uses Hugo to build the site in memory and then serve it from a local web server.
When any source files are changed or added Hugo will detect this and rebuild the site as required, including automatically refreshing the browser page to update the rendered view.

Once the server is running the site is available at [localhost:1313](http://localhost:1313).

{{% warning %}}
Sometimes changes made to the site source will not be re-loaded correctly so it may be necessary to stop and re-start the server.
{{% /warning %}}


### Building the site locally

To perform a full build of the static site, run this from the repository root:

{{< command-line >}}
./container_build/runInHugoDocker.sh build
{{</ command-line >}}

This will generate all the static content and place it in `public/`.


### Generating the PDF

Every page has a _Print entire section_ link that will display a printable view of that section and its children.
In addition to this the GitHub Actions we generate a PDF of the `docs` section and all its children, i.e. all of the documentation (but not News/Releases or Community) in one PDF.
This makes the documentation available for offline use.

To test the PDF generation, run this from the repository root:

{{< command-line >}}
./container_build/runInPupeteerDocker.sh PDF
{{</ command-line >}}


## Updating the Docsy theme

The Docsy theme is a dependency of this Hugo site. See {{< external-link "Update the Hugo Docsy Module" "https://www.docsy.dev/docs/updating/updating-hugo-module/" >}} for details on how to update the version of the Docsy theme.

In those instructions when it says to run a `hugo` command you need to do it from within the hugo docker container.

{{< command-line >}}
./container_build/runInHugoDocker.sh bash
{{</ command-line >}}

This will give you a bash prompt inside the container that has the `hugo` binary available.
The container has access to your local stroom-docs repository (from where you ran `runInHugoDocker.sh`) and the initial directory is the root of the repository.
Inside the container the root of the repository is mounted as `/builder/shared`.

To leave the container's shell type `exit`.

Alternatively you can run a single command directly, e.g. to update Docsy to `0.6.0` do:

{{< command-line >}}
./container_build/runInHugoDocker.sh 'hugo mod get -u github.com/google/docsy@v0.6.0'
{{</ command-line >}}
