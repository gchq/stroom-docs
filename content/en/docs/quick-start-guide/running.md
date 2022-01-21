---
title: "Running Stroom"
linkTitle: "Running Stroom"
weight: 10
date: 2021-07-09
tags: 
description: >
  
---

## Getting and Running Stroom

For this quick start you want a simple single-node Stroom. 
You will want to follow [these instructions]({{< relref "community/dev-guide/docker-running.md" >}}). 
They do require Docker and Docker Compose, so make sure you've installed those first.

At the risk of sowing confusion you should know that there are different ways of running Stroom. Here are the full options:

* [Run using Docker Hub images (recommended)]({{< relref "community/dev-guide/docker-running.md" >}})
* [Install a stroom v5.x release]({{< relref "../install-guide/stroom-app-install.md" >}})
* [Install a stroom v6.x release]({{< relref "../install-guide/stroom-6-installation.md" >}})
* From source you can:
  * [Build and run from IntelliJ]({{< relref "community/dev-guide/stroom-in-an-ide.md" >}})

## Basic configuration

### Enable processing of data streams

Automatic processing isn't enabled by default: you might first want to check other settings (for example  nodes, properties, and volumes). So we need to enable Stream Processing. 
This is in Tools -> Jobs menu::
{{< image "quick-start-guide/running/go-jobs.png" >}}Opening the jobs menu{{< /image >}}

Next we need to enable Stream Processor jobs:

{{< image "quick-start-guide/running/configure-jobs.png" >}}Enabling stream processing{{< /image >}}

Below the list of jobs is the properties pane. The Stream Processor's properties show the list of nodes. You should have one. You'll need to enable it by scrolling right:

{{< image "quick-start-guide/running/configure-jobs-stream.png" >}}Enabling the nodes for the stream processor{{< /image >}}

So now we've done that lets [get data into stroom](../feed).
