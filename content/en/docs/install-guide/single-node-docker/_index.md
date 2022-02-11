---
title: "Single Node Docker Installation"
linkTitle: "Single Node (Docker)"
weight: 10
date: 2022-01-25
tags: 
  - TODO
  - docker
description: >
  How to install a Single node instance of Stroom using Docker containers.

---

Running Stroom in _Docker_ is the quickest and easiest way to get Stroom up and running.
Using Docker means you don't need to install the right versions of dependencies like Java or MySQL or get them configured corectly for Stroom.


## Stroom Docker stacks

Stroom has a number of predefined _stacks_ that combine multiple docker containers into a fully functioning Stroom.
The docker stacks are aimed primarily at single node instances or for evaluation/test.
If you want to deploy a Stroom cluster using containers then you should use Kubernetes.

{{% todo %}}
Add Kubernetes install link.
{{% /todo %}}

At the moment the usable stacks are:

{{< cardpane >}}
  {{< card header="`stroom_core`" >}}
A production single node stroom.

**Services:**  
stroom  
stroom-proxy-local  
stroom-log-sender  
nginx  
mysql
  {{< /card >}}
  {{< card header="`stroom_core_test`" >}}
A single node stroom for test/evalutaion, pre-loaded with content.
Also includes a _remote_ proxy for demonstration purposes.

**Services:**  
stroom  
stroom-proxy-local  
stroom-proxy-remote  
stroom-log-sender  
nginx  
mysql
  {{< /card >}}
  {{< card header="`stroom_proxy`" >}}
A remote proxy stack for aggregating and forwarding logs to stroom(-proxy).

**Services:**  
stroom-proxy-remote  
stroom-log-sender  
nginx  
  {{< /card >}}
  {{< card header="`stroom_services`" >}}
An Nginx instance for running stroom without Docker.

**Services:**  
stroom-log-sender  
nginx  
  {{< /card >}}
{{< /cardpane >}}


## Prerequisites

In order to run Stroom using Docker you will need the following installed on the machine you intend to run Stroom on:

* An internet connection. If you don't have one see [Air Gapped Environments]({{< relref "air-gapped#docker-images" >}}).
* A Linux-like shell environment.
* Docker CE (v17.12.0+) - e.g {{< external-link "docs.docker.com/install/linux/docker-ce/centos/" "https://docs.docker.com/install/linux/docker-ce/centos/" >}} for Centos
* docker-compose (v1.21.0+) - {{< external-link "docs.docker.com/compose/install/" "https://docs.docker.com/compose/install/" >}} 
* bash (v4+)
* jq - {{< external-link "stedolan.github.io/jq/" "https://stedolan.github.io/jq/" >}} e.g. `sudo yum install jq`
* curl
* A non-root user to perform the install as, e.g. `stroomuser`

{{% note %}}
`jq` is not a hard requirement but improves the functionality of the health checks.
{{% /note %}}


## Install steps

This will install the core stack (Stroom and the peripheral services required to run Stroom).

Visit {{< external-link "stroom-resources/releases" "https://github.com/gchq/stroom-resources/releases" >}} to find the latest stack release.
The Stroom stack comes in a number of different variants:

* **stroom_core_test** - If you are just evaluating Stroom or just want to see it running then download the `stroom_core_test*.tar.gz` stack which includes some pre-loaded content.
* **stroom_core** - If it is for an actual deployment of Stroom then download `stroom_core*.tar.gz`, which has no content and requires some configuration.

Using `stroom_core_test-v7.0-beta.175.tar.gz` as an example:

{{< command-line "stroomuser" "localhost" >}}
# Define the version to download
VERSION="v7.0-beta.175"; STACK="stroom_core_test"
(out)
# Download and extract the Stroom stack
curl -sL "https://github.com/gchq/stroom-resources/releases/download/stroom-stacks-${VERSION}/${STACK}-${VERSION}.tar.gz" | tar xz
(out)
# Navigate into the new stack directory, where xxxx is the directory that has just been created
cd "${STACK}-${VERSION}"
(out)
# Start the stack
./start.sh
{{</ command-line >}}

Alternatively if you understand the risks of redirecting web sourced content direct to bash, you can get the latest `stroom_core_test` release using:

{{< command-line "stroomuser" "localhost" >}}
# Download and extract the laStroom stack
bash <(curl -s https://gchq.github.io/stroom-resources/v7.0/get_stroom.sh)
(out)
# Navigate into the new stack directory
cd stroom_core_test/stroom_core_test*
(out)
# Start the stack
./start.sh
{{</ command-line >}}

On first run stroom will build the database schemas so this can take a minute or two. 
The `start.sh` script will provide details of the various URLs that are available.

Open a browser (preferably Chrome) at [https://localhost](https://localhost) and login with:

* username: _admin_
* password: _admin_

The stroom stack comes supplied with self-signed certificates so you may need to accept a prompt warning you about visiting an untrusted site.


## Configuration

To configure your new instance see [Configuration]({{< relref "docs/install-guide/configuration" >}}).


## Docker Hub links

* {{< external-link "The Stroom image" "https://hub.docker.com/r/gchq/stroom/" >}} 
* {{< external-link "The GCHQ organisation" "https://hub.docker.com/r/gchq/" >}} 

