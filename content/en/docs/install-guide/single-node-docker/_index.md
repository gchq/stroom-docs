---
title: "Single Node Docker Installation"
linkTitle: "Single Node (Docker)"
weight: 10
date: 2022-10-18
tags: 
  - TODO
  - docker
description: >
  How to install a Single node instance of Stroom using Docker containers.

---

Running Stroom in _Docker_ is the quickest and easiest way to get Stroom up and running.
Using Docker means you don't need to install the right versions of dependencies like Java or MySQL or get them configured correctly for Stroom.


## Stroom Docker stacks

Stroom has a number of predefined _stacks_ that combine multiple docker containers into a fully functioning Stroom environment.
The Docker stacks are aimed primarily at single node instances or for evaluation/test.
The stack makes use of various shell scripts combined with Docker Compose to integrate the various Docker containers and make them easy to run.

If you want to deploy a Stroom cluster using containers then you should use [Kubernetes Cluster]({{< relref "../kubernetes/introduction" >}}).

At the moment the usable stacks are:

* `stroom_core` - A single node stroom stack geared towards production use.

* `stroom_core_test` - A single node stroom for test/evalutaion, pre-loaded with content.
   Also includes a _remote_ proxy for demonstration purposes.
   If you just want to try out Stroom, this is the one to use.

* `stroom_proxy` - A remote proxy stack for aggregating and forwarding logs to stroom(-proxy).
  Intended for use as a remote proxy that will forward received/aggregated data into a downstream stroom/stroom-proxy.

* `stroom_services` - An Nginx instance for running stroom without Docker.

Each stack contains the following docker compose services.

{{< cardpane >}}
  {{< card header="`stroom_core`" >}}
stroom  
stroom-proxy-local  
stroom-log-sender  
nginx  
mysql
  {{< /card >}}

  {{< card header="`stroom_core_test`" >}}
stroom  
stroom-proxy-local  
stroom-proxy-remote  
stroom-log-sender  
nginx  
mysql
  {{< /card >}}

  {{< card header="`stroom_proxy`" >}}
stroom-proxy-remote  
stroom-log-sender  
nginx  
  {{< /card >}}

  {{< card header="`stroom_services`" >}}
stroom-log-sender  
nginx  
  {{< /card >}}
{{< /cardpane >}}

The services are as follows:

* `stroom` - A Stroom instance.
* `stroom-proxy-local` - A Stroom-Proxy instance that is typically local to Stroom and acts as its front door for data reception.
* `stroom-proxy-remote` - A Stroom-Proxy instance that is remote from Stroom (e.g. owned by another team) and is intended to pass data to a downstream Stroom-Proxy.
* `nginx` - An instance of _nginx_ that is configured to reverse proxy to Stroom and Stroom-Proxy as appropriate.
  It can also be configured to act as a load balancer to multiple Stroom instances if Stroom is being installed without using Docker.
* `mysql` - An instance of _MySQL_ that is configured to create the database and users required by Stroom.
* `stroom-log-sender` - A simple container that is configured to gather all the log files produced by Stroom, Stroom-Proxy and nginx, to then forward them to Stroom so Stroom can process its own logs.


## Prerequisites

In order to run Stroom using Docker you will need the following installed on the machine you intend to run Stroom on:

* An internet connection.
  If you don't have one see [Air Gapped Environments]({{< relref "air-gapped#docker-images" >}}).
* A Linux-like shell environment.
* Docker CE (v17.12.0+) - e.g {{< external-link "docs.docker.com/install/linux/docker-ce/centos/" "https://docs.docker.com/install/linux/docker-ce/centos/" >}} for Centos
* docker-compose (v1.21.0+) - {{< external-link "docs.docker.com/compose/install/" "https://docs.docker.com/compose/install/" >}} 
* bash (v4+)
* jq - {{< external-link "stedolan.github.io/jq/" "https://stedolan.github.io/jq/" >}} e.g. `sudo yum install jq`
* curl
* A non-root user to perform the install as, e.g. `stroomuser`

{{% note %}}
`jq` is not a hard requirement but improves the functionality of the health checks and is a useful thing to have, e.g. for using Stroom's REST API.
{{% /note %}}


## Install steps

This will install the core stack (Stroom and the peripheral services required to run Stroom).

Visit {{< external-link "stroom-resources/releases" "https://github.com/gchq/stroom-resources/releases" >}} to find the latest stack release.
The Stroom stack comes in a number of different variants:

* **stroom_core_test** - If you are just evaluating Stroom or just want to see it running then download the `stroom_core_test*.tar.gz` stack which includes some pre-loaded content.
* **stroom_core** - If it is for an actual deployment of Stroom then download `stroom_core*.tar.gz`, which has no content and requires some configuration.

Using `stroom_core_test-v7.10.11.tar.gz` as an example:

{{< command-line "stroomuser" "localhost" >}}
# Define the version to download
VERSION="v7.10.11"; STACK="stroom_core_test"
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
# Download and extract the latest Stroom stack
bash <(curl -s https://gchq.github.io/stroom-resources/v7.1/get_stroom.sh)
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

{{% note %}}
If you have installed the `stroom_core` stack no user accounts are created by default.
You will need to manually create and administrator account.

{{% /note %}}


The stroom stack comes supplied with self-signed certificates so you may need to accept a prompt warning you about visiting an untrusted site.


## Configuration

To configure your new instance see [Configuration]({{< relref "docs/install-guide/configuration" >}}).


## Docker Hub links

* {{< external-link "The Stroom image" "https://hub.docker.com/r/gchq/stroom/" >}} 
* {{< external-link "The GCHQ organisation" "https://hub.docker.com/r/gchq/" >}} 

