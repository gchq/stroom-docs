## Getting and Running Stroom

There are several options to get Stroom running and by far the quickest and easiest is to use Docker. If you're new to [Docker](https://www.docker.com/what-docker) then you might want to follow their [getting started guide](https://www.docker.com/products/docker) first. Otherwise you can follow our [quick guide](/dev-guide/docker-running.md).

If you're really interested here are your full options for running Stroom:

* [Run using a Docker Hub image (recommended)](/dev-guide/docker-running.md#using-a-pre-built-docker-hub-image)
* [Run using a release](/install-guide/stroom-app-install.md)
* From source you can:
  * [Build and run from IntelliJ](/dev-guide/stroom-in-an-ide.md)
  * [Build and run using Docker](/dev-guide/docker-building.md)

## Basic configuration

### Enable processing of data streams

Automatic processing isn't enabled by default: you might first want to check other settings (for example  nodes, properties, and volumes). So we need to enable Stream Processing. This is in Tools -> Jobs menu::
![Opening the jobs ment](images/go-jobs.png)

Next we need to enable Stream Processor jobs:

![Enabling stream processing](images/configure-jobs.png)

Below the list of jobs is the properties pane. The Stream Processor's properties show the list of nodes. You should have one. You'll need to enable it by scrolling right:

![Enabling the nodes for the stream processor](images/configure-jobs-stream.png)

So now we've done that lets [get data into stroom](../feed/feed.md).
