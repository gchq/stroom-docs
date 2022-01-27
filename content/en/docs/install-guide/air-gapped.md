---
title: "Installing in an Air Gapped Environment"
linkTitle: "Air Gapped Environments"
weight: 30
date: 2022-01-27
tags: 
description: >
  How to install Stroom when there is no internet connection.
---

## Docker images

For those deployments of Stroom that use docker containers, by default docker will try to pull the docker images from DockerHub on the internet.
If you do not have an internet connection then you will need to make these images availbe to the local docker binary in another way.


### Downloading the images

Firstly you need to determine which images and which tags you need.
Look at {{< external-link "stroom-resources/releases" "https://github.com/gchq/stroom-resources/releases" >}} and for each release and variant of the Stroom stacks you will see a manifest of the docker images/tags in that release/variant.
For eaxmple, for `stroom-stacks-v7.0-beta.175` and stack variant `stroom_core` the list of images is:

```text
nginx gchq/stroom-nginx:v7.0-beta.2
stroom gchq/stroom:v7.0-beta.175
stroom-all-dbs mysql:8.0.23
stroom-log-sender gchq/stroom-log-sender:v2.2.0
stroom-proxy-local gchq/stroom-proxy:v7.0-beta.175
```


#### With the _docker_ binary

If you have access to an internet connected computer that has Docker installed on it then you can use Docker to pull the images.
For each of the required images run a command like this:

{{< command-line "user" "localhost" >}}
docker pull gchq/stroom-nginx:v7.0-beta.2
docker save -o stroom-nginx.tar gchq/stroom-nginx:v7.0-beta.2
{{</ command-line >}}


#### Without the _docker_ binary

If you can't install Docker on the internet connected maching then this {{< external-link "shell script" "https://github.com/moby/moby/blob/master/contrib/download-frozen-image-v2.sh" >}} may help you to download and assemble the various layers of an image from DockerHub using only _bash_, _curl_ and _jq_.
This is a third party script so we cannot vouch for it in any way.
As with all scripts you run that you find on the internet, look at and understand what they do before running them.



### Loading the images

Once you have downloaded the image tar files and transferred them over the air gap you will need to load them into your local docker repo.
Either this will be the local repo on the maching where you will deploy Stroom (or one of its component containers) or you will have a central docker repository that many machines can access.
Managing a central air-gapped repository is beyond the scope of this documentation.

To load the images into your local repository use a command similar to this for each of the `.tar` files that you created using `docker save` above:

{{< command-line >}}
docker load --input stroom-nginx.tar
{{</ command-line >}}

You can check the images are avialable using:

{{< command-line >}}
docker image ls
{{</ command-line >}}

