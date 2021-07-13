## Getting and Running Stroom

For this quick start you want a simple single-node Stroom. 
You will want to follow [these instructions](../../dev-guide/docker-running.md). 
They do require Docker and Docker Compose, so make sure you've installed those first.

At the risk of sowing confusion you should know that there are different ways of running Stroom. Here are the full options:

* [Run using Docker Hub images (recommended)](../../dev-guide/docker-running.md)
* [Install a stroom v5.x release](../../installation/version-5/stroom-app-install.md)
* [Install a stroom v6.x release](../../installation/version-6/stroom-6-installation.md)
* From source you can:
  * [Build and run from IntelliJ](../../dev-guide/stroom-in-an-ide.md)

## Basic configuration

### Enable processing of data streams

Automatic processing isn't enabled by default: you might first want to check other settings (for example  nodes, properties, and volumes). So we need to enable Stream Processing. 
This is in Tools -> Jobs menu::
![Opening the jobs ment](images/go-jobs.png)

Next we need to enable Stream Processor jobs:

![Enabling stream processing](images/configure-jobs.png)

Below the list of jobs is the properties pane. The Stream Processor's properties show the list of nodes. You should have one. You'll need to enable it by scrolling right:

![Enabling the nodes for the stream processor](images/configure-jobs-stream.png)

So now we've done that lets [get data into stroom](../feed/feed.md).
