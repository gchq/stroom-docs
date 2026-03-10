---
title: "Stroom Proxy Installation"
linkTitle: "Stroom Proxy Installation"
weight: 10
date: 2021-08-20
tags: 
  - TODO
  - proxy
description: >
  How to install Stroom-Proxy.
---

Stroom-Proxy can be installed in 4 main ways:

* App - There is an _app_ version that runs Stroom-Proxy as a Java {{< glossary "JAR" >}} file locally on the server and has settings contained in a configuration file that controls access to the stroom server and database.

* Docker Stack - Stroom-Proxy, Nginx and Stroom-Log-Sender run in Docker containers, orchestrated using Docker Compose and some shell scripts.
  The stroom-proxy image is essentially a minimal Alpine Linux container with the appropriate Java version installed and the Stroom-Proxy JAR contained within it.

* Docker Images - Manually run containers based on the Stroom-Proxy docker image.

* Kubernetes - Deploy Stroom-Proxy into a Kubernetes cluster.

The document will cover the installation and configuration of the Stroom-Proxy software for both the 'app' and Docker stack deployments.

{{% note %}}
Older versions of Stroom-Proxy 'sent' data to Stroom by being co-located with Stroom and using a shared repository location.
Stroom-Proxy would write to the repository and Stroom would retrieve data from there.

This method is no longer used.
Current versions of Stroom-Proxy forward data to Stroom over HTTP so do not need to be co-located with Stroom.
{{% /note %}}


## Typical Deployments

Stroom-Proxy is typically deployed in front of Stroom to act as a proxy for data receipt into Stroom.
This abstracts Stroom from the clients sending the data and ensures that received data is aggregated into sensibly sized streams.

For a production Stroom cluster, it is likely that you will want multiple Stroom-Proxy instances behind a load balancer for resiliency and load management.

{{% note %}}
Stroom-Proxy instances are independent and cannot form a coherent cluster.
If you have a 'cluster' of Stroom-Proxy instances for resilience, each Stroom-Proxy instance can only work with the data it has received and loss of an instance means the loss of any data it was in the process of aggregating.

Also if you have a large 'cluster' of Stroom-Proxy instances, this can have an impact on aggregation as data for the same aggregation key (Feed and Stream Type) will be spread over multiple instances and thus aggregates.
For low volume Feeds, this can mean smaller aggregates than is preferred.

To mitigate against this, you can use sticky sessions when load balancing or ideally use a load balancer that allows selection of the upstream instance using HTTP headers, i.e. `Feed`.
{{% /note %}}


## Assumptions

The following assumptions are used in this document.

* The user has reasonable RHEL/CentOS/Rocky System administration skills.
* Installation is on a fully patched minimal RHEL/CentOS/Rocky instance.
* The application user `stroomuser` has been created in the OS.
* The user has set up the Stroom processing user as described [here]({{< relref "../HOWTOs/Install/InstallProcessingUserSetupHowTo.md" >}}).
* The prerequisite software has been installed.


## Firewall Configuration

For both methods of deployment, the ports used are as follows:
Some may need to be opened to allow access to the ports from outside the host.

* `80` - Nginx listens on port `80` but redirects onto `443`.
* `443`  - Nginx listens on port `443`.
* `8090` - Stroom-Proxy listens on port `8090` for its main public APIs (`/datafeed`, REST endpoints, etc).
* `8091` - Stroom-Proxy listens on port `8091` for its administration APIs.
  Access to this port should probably be carefully controlled.

It is therefore likely that you will only want to expose `443` and maybe `80` to other hosts.

For example on a RHEL/CentOS server using `firewalld` the commands would be as `root` user:

{{< command-line "root" "localhost" >}}
firewall-cmd --zone=public --permanent --add-port=80/tcp
firewall-cmd --zone=public --permanent --add-port=443/tcp
firewall-cmd --reload
{{</ command-line >}}


## Stroom Proxy (docker version)

The build of a stroom proxy where the Stroom-Proxy Java application (and associated services) are running in docker containers.

Because everything is running in Docker containers, the only requirement for the host is for the following:

* Docker Engine
* Docker Compose Plugin
* `bash` v4 or greater - Used by the stack scripts.
* GNU `coreutils` - Used by the stack scripts.
* `jq` - Used by the stack scripts.


### Download and install docker

To install Docker Engine and the Docker Composer Plugin see:

* {{< external-link "Docker Engine" "https://docs.docker.com/engine/install" >}}
* {{< external-link "Docker Compose Plugin" "https://docs.docker.com/compose/install" >}}

All the Stroom-Proxy logs and data will be stored in Docker managed volumes that will, by default, reside in `/var/lib/docker`.
It is typical that this directory will be on small mount point for the OS.
It is therefore recommended to relocate this directory to a mount with more space and sufficient resilience, i.e. RAID mirroring.

To do this you need to follow these steps:

1. Stop the Docker engine.
1. Move the directory to its new location.
1. Edit the file `/etc/docker/daemon.json` and ensure this field is present with the new location as the value.
   ```json
   {
     "data-root": "/path/to/new/location"
   }
   ```
1. Start the Docker engine.


### Download and Install Docker Stack

The _stroom_proxy_ Docker stack is available from {{< external-link "stroom-resources releases" "https://github.com/gchq/stroom-resources/releases" >}} on GitHub.
The stack distribution is simply a collection of shell scripts and Docker Compose configuration files.
The Docker images will get pulled down from DockerHub when the stack is started.

The installation example below is for stroom version 7.10.20 - but is applicable to other stroom v7 versions.
As a suitable stroom user e.g. `stroomuser` - download and unpack the stroom software.

{{< command-line "stroomuser" "localhost" >}}
mkdir -p ~/stroom-proxy
cd ~/stroom-proxy
wget https://github.com/gchq/stroom-resources/releases/download/stroom-stacks-v7.10.20/stroom_proxy-v7.10.20.tar.gz
tar -zxf stroom_proxy-v7.10.20.tar.gz
cd stroom_proxy-v7.10.20
{{</ command-line >}}

For a stroom proxy, the configuration file `stroom_proxy/stroom_proxy-v7.10.20/stroom_proxy.env` needs to be edited, with the connection details of the stroom server that data files will be sent to.
The default network port for connection to the stroom server is 8080.

The values that need to be set are:

```text
STROOM_PROXY_REMOTE_FEED_STATUS_API_KEY  
STROOM_PROXY_REMOTE_FEED_STATUS_URL  
STROOM_PROXY_REMOTE_FORWARD_URL  
```

The 'API key' is generated on the stroom server and is related to a specific user e.g. proxyServiceUser.
The 2 URL values also refer to the stroom server and can be a fully qualified domain name (fqdn) or the IP Address.

e.g. if the stroom server was - stroom-serve.somewhere.co.uk - the URL lines would be:

```bash
export STROOM_PROXY_REMOTE_FEED_STATUS_URL="http://stroom-serve.somewhere.co.uk:8080/api/feedStatus/v1"
export STROOM_PROXY_REMOTE_FORWARD_URL="http://stroom-serve.somewhere.co.uk:8080/stroom/datafeed"
```


### To Start Stroom Proxy

As the stroom user, run the 'start.sh' script found in the stroom install:

{{< command-line "stroomuser" "localhost" >}}
cd ~/stroom_proxy/stroom_proxy-v7.10.20/
./start.sh
{{</ command-line >}}


The first time the script is run it will download the docker images from DockerHub:

* stroom-proxy-remote
* stroom-log-sender
* stroom-nginx

Once the script has completed the Stroom-Proxy server should be running.

The stack directory contains the following scripts for managing the Stroom-Proxy stack.

* `health.sh` - Tests and displays the health of the stack.
* `info.sh*` - Displays info about the stack.
* `pull_images.sh` - Pulls all the docker images used in the stack.
* `logs.sh` - Tails the logs from all services in the stack.
* `remove.sh` - Removes all services and volumes in the stack.
  **Warning**: this will delete any data held in Stroom-Proxy.
* `restart.sh` - Restarts all or named services it the stack.
* `send_data.sh` - Script to aid POSTing data into Stroom-Proxy.
* `set_log_levels.sh` - Sets log levels for classes/packages on the running Stroom-Proxy.
* `set_services.sh` - Used for disabling services in the stack.
* `show_config.sh` - Displays the effective docker compose config taking the env file into account.
* `start.sh` - Starts all or named services it the stack.
* `status.sh` - Shows the status of the services in the stack.
* `stop.sh` - Stops all or named services it the stack.


## Stroom Proxy (app version)

This is the bare bones installation method that requires installing everything manually.
If you are able to use Docker we recommend doing this as there are less things to install and configure, e.g. nginx, send_to_stroom.sh, cron, etc.

Stroom-Proxy is distributed as a ({{< glossary "JAR" >}}) file so this method will run this JAR using the `java` executable.

The pre-requisites for this deployment are:

* RHEL/CentOS/Rocky
* Java 25+ JDK (JDK is preferred over JRE as it provides additional tools (e.g. `jmap`) for capturing heap histogram statistics).
* `bash` v4 or greater - Used by the helper scripts.
* GNU `coreutils` - Used by the helper scripts.

For details about which Java distribution and version to use, and how to install it, see [Java]({{< relref "docs/install-guide/java" >}}).

{{% note %}}
Disable _selinux_ to avoid issues with access and file permissions. 
{{% /note %}}


### Download and install Stroom v7 (app version)

Stroom-Proxy releases are available from {{< external-link "github.com/gchq/stroom/releases" "https://github.com/gchq/stroom/releases" >}}.
Each release has a number of artefacts, the Stroom-Proxy application is `stroom-proxy-app-v*.zip`.

The installation example below is for stroom version v7.10.20, but is applicable to other stroom v7 versions.
As a suitable stroom user e.g. stroomuser - download and unpack the stroom software.

{{< command-line "stroomuser" "localhost" >}}
wget https://github.com/gchq/stroom/releases/download/v7.10.20/stroom-proxy-app-v7.10.20.zip
unzip stroom-proxy-app-v7.10.20.zip
{{</ command-line >}}

The configuration file – `stroom-proxy/config/config.yml` – is the principal file that controls the configuration of Stroom-Proxy.
See [Stroom Proxy Configuration]({{< relref "docs/install-guide/configuration/stroom-and-proxy/configuring-stroom-proxy" >}}).

