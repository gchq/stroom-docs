---
title: "Single Node Docker Installation"
linkTitle: "Single Node (Docker)"
weight: 10
date: 2022-01-25
tags: 
  - docker
description: >
  How to install a Single node instance of Stroom using Docker containers.

---

Running Stroom in _Docker_ is the quickest and easiest way to get Stroom up and running.

## Prerequisites

In order to run Stroom using Docker you will need the following installed on the machine you intend to run Stroom on:

* An internet connection. If you don't have one see [Air Gapped Environments]({{< relref "air-gapped#docker-images" >}}).
* A Linux-like shell environment.
* Docker CE (v17.12.0+) - e.g [docs.docker.com/install/linux/docker-ce/centos/ (external link)](https://docs.docker.com/install/linux/docker-ce/centos/) for Centos
* docker-compose (v1.21.0+) - [docs.docker.com/compose/install/ (external link)](https://docs.docker.com/compose/install/) 
* bash (v4+)
* jq - [stedolan.github.io/jq/ (external link)](https://stedolan.github.io/jq/) e.g. `sudo yum install jq`
* curl

{{% note %}}
`jq` is not a hard requirement but improves the functionality of the health checks.
{{% /note %}}


## Install steps

This will install the core stack (Stroom and the peripheral services required to run Stroom).

Visit [stroom-resources/releases (external link)](https://github.com/gchq/stroom-resources/releases) to find the latest stack release.
If you are just evaluating Stroom or just want to see it running then download the `stroom_core_test*.tar.gz` stack which includes some pre-loaded content.
If it is for an actual deployment of Stroom then download `stroom_core*.tar.gz`, which has no content and requires some configuration.

Using `stroom_core_test-v7.0-beta.175.tar.gz` as an example:

```bash

# Define the version to download
VERSION="v7.0-beta.175"; STACK="stroom_core_test"

# Download and extract the Stroom stack
curl -sL "https://github.com/gchq/stroom-resources/releases/download/stroom-stacks-${VERSION}/${STACK}-${VERSION}.tar.gz" | tar xz

# Navigate into the new stack directory, where xxxx is the directory that has just been created
cd "${STACK}-${VERSION}"

# Start the stack
./start.sh
```

Alternatively if you understand the risks of redirecting web sourced content direct to bash, you can get the latest `stroom_core_test` release using:

``` bash
# Download and extract the laStroom stack
bash <(curl -s https://gchq.github.io/stroom-resources/v7.0/get_stroom.sh)

# Navigate into the new stack directory
cd stroom_core_test/stroom_core_test*

# Start the stack
./start.sh
```

On first run stroom will build the database schemas so this can take a minute or two. 
The `start.sh` script will provide details of the various URLs that are available.

Open a browser (preferably Chrome) at [https://localhost](https://localhost) and login with:

* username: _admin_
* password: _admin_

The stroom stack comes supplied with self-signed certificates so you may need to accept a prompt warning you about visiting an untrusted site.


## Configuration

To configure your new instance see [Configuration]({{< relref "docs/install-guide/configuration" >}}).


## Docker Hub links
[The Stroom image (external link)](https://hub.docker.com/r/gchq/stroom/)

[The GCHQ organisation (external link)](https://hub.docker.com/r/gchq/)

