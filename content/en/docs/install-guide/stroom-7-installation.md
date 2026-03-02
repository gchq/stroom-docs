---
title: "Stroom Installation"
linkTitle: "Stroom Installation"
#weight:
date: 2026-02-27
tags: 
description: >
  Details how to install Stroom and its assocatied services.
---

{{% todo %}}
This section is not yet complete.
{{% /todo %}}

## Typical Deployments

Stroom can be deployed in a number of ways:

* Single node - For environments with low data volumes, test environments or where resilience is not critical.
  For a single node deployment, the simplest way to deploy is with a [Single Node Docker Stack]({{< relref "./single-node-docker" >}}) as this includes everything needed for Stroom to run.

* Non-Docker Cluster - A Stroom cluster where the Stroom Java application is running direction on the physical/virtual host and Stroom's peripheral services (e.g. Nginx, MySQL, Stroom-Proxy) have been installed adjacent to the Stroom Cluster.

* Kubernetes - For deploying a containerised Stroom cluster, Kubernetes (k8s) is the recommended approach.
  See [Kubernetes Cluster]({{< relref "./kubernetes" >}}).

This document will only be concerned with the installation of a non-Docker Stroom cluster.

For a more detailed description of the deployment architecture, see [Architecture]({{< relref "docs/architecture" >}}).

For details of how to install Stroom-Proxy see [Stroom-Proxy Installation]({{< relref "docs/proxy/stroom-7-proxy-installation" >}}).


## Assumptions

The following assumptions are used in this document.

* The user has reasonable RHEL/CentOS/Rocky System administration skills.
* Installation is on a fully patched minimal RHEL/CentOS/Rocky instance.
* The application user `stroomuser` has been created in the OS.
* The user has set up the Stroom processing user as described [here]({{< relref "../HOWTOs/Install/InstallProcessingUserSetupHowTo.md" >}}).
* The prerequisite software has been installed.


## Firewall Configuration

The following are the ports used in a typical Stroom deployment.
Some may need to be opened to allow access to the ports from outside the host.

* `80` - Nginx listens on port `80` but redirects onto `443`.
* `443`  - Nginx listens on port `443`.
* `3306` - MySQL listens on port `3306` by default.
* `8080` - Stroom listens on port `8080` for its main public APIs (`/datafeed`, REST endpoints, etc).
* `8081` - Stroom listens on port `8081` for its administration APIs.
  Access to this port should probably be carefully controlled.
* `8090` - Stroom-Proxy listens on port `8090` for its main public APIs (`/datafeed`, REST endpoints, etc).
* `8091` - Stroom-Proxy listens on port `8091` for its administration APIs.
  Access to this port should probably be carefully controlled.

{{% note %}}
A lot of the default Stroom configuration assumes MySQL is listening on `3307`.
This is for historic reasons.
You can either change the Stroom configuration to use `3306` or change MySQL to listen on `3307`.
{{% /note %}}

Which ports you open on a host will depend on what service is running on that host.
Typically Stroom will be running on different hosts to Nginx, MySQL and Stroom-Proxy, so Stroom's `8080` port will need to be opened for traffic from Stroom-Proxy and Nginx.

For example on a RHEL/CentOS server using `firewalld` the commands would be as `root` user:

{{< command-line "root" "localhost" >}}
firewall-cmd --zone=public --permanent --add-port=80/tcp
firewall-cmd --zone=public --permanent --add-port=443/tcp
firewall-cmd --reload
{{</ command-line >}}


## Prerequisites

* RHEL/CentOS/Rocky
* Java JDK (JDK is preferred over JRE as it provides additional tools (e.g. `jmap`) for capturing heap histogram statistics).
  For details about which Java distribution and version to use, and how to install it, see [Java]({{< relref "docs/install-guide/java" >}}).
* `bash` v4 or greater - Used by the helper scripts.
* GNU `coreutils` - Used by the helper scripts.
* `jq` - Used by the stack scripts.

Create a shell script that will define the Java variable OR add the statements to `.bash_profile`.


## Install Components

### Install Nginx

To deploy Nginx, it can either be installed manually (see {{< external-link "Installing Nginx" "https://nginx.org/en/docs/install.html" >}}) or using the `stroom_services` [Docker Stack]({{< relref "docs/install-guide/single-node-docker#stroom-docker-stacks" >}}).


### Install Stroom-Proxy

For details of how to install Stroom-Proxy see [Stroom-Proxy Installation]({{< relref "docs/proxy/stroom-7-proxy-installation" >}}).


### Install MySQL

For details of how to install MySQL see [MySQL Setup]({{< relref "docs/install-guide/setup/mysql-server-setup" >}}).


### Install Stroom

Stroom releases are available from {{< external-link "github.com/gchq/stroom/releases" "https://github.com/gchq/stroom/releases" >}}.
Each release has a number of artefacts, the Stroom application is `stroom-app-v*.zip`.

The installation example below is for stroom version 7.10.20, but is applicable to other stroom v7 versions.
As a suitable stroom user e.g. stroomuser - download and unpack the stroom software.

{{< command-line "stroomuser" "localhost" >}}
wget https://github.com/gchq/stroom/releases/download/v7.10.20/stroom-app-v7.10.20.zip
unzip stroom-app-v7.10.20.zip
{{</ command-line >}}

The configuration file – `stroom/config/config.yml` – is the principal file that controls the configuration of Stroom, although once Stroom is running, the configuration can be managed via [System Properties]({{< relref "docs/user-guide/properties" >}}).
See [Stroom Configuration]({{< relref "docs/install-guide/configuration/stroom-and-proxy/configuring-stroom" >}}).

