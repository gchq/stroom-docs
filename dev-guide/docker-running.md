# Running Stroom in  Docker Containers

This is how to run Stroom using _Docker_. You may also [build a Docker image from scratch](./docker-building.md). Running Stroom in _Docker_ is the quickest and easiest way to get Stroom up and running.

## Prerequisites

In order to run Stroom using Docker you will need the following installed on the machine you intend to run Stroom on:

* A Linux-like shell environment with bash
* docker CE
* docker-compose
* git

## Using pre-built _Docker Hub_ images for the latest v5.x release of Stroom.

```bash
git clone https://github.com/gchq/stroom-resources.git

cd stroom-resources/bin

./bounceIt.sh -f env/stroom5.env
```

Open a browser (preferably Chrome) at [http://localhost:8080/stroom](http://localhost:8080/stroom) and login with:

* username: _admin_ 
* password: _admin_

## Using pre-built _Docker Hub_ images for the latest v6.x pre-release of Stroom.

This will install the core stack of peripheral services required to run Stroom.

```bash
git clone https://github.com/gchq/stroom-resources.git

cd stroom-resources/bin

./bounceIt.sh -f env/stroom6-core.env

```

Open a browser (preferably Chrome) at [http://localhost:8080/stroom](http://localhost:8080/stroom) and login with:

* username: _admin_ (NOT an email address)
* password: _admin_

Stroom uses a self-signed certificate so you may need to accept a prompt warning you about visiting an untrusted site.

## Docker Hub links
[The Stroom image](https://hub.docker.com/r/gchq/stroom/)

[The GCHQ organisation](https://hub.docker.com/r/gchq/)
