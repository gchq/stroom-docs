# Running Stroom in Docker Containers

This is how to run Stroom and its peripheral services using _Docker_. 
Running Stroom in _Docker_ is the quickest and easiest way to get Stroom up and running. 

> _NOTE_: The published docker images are intended for small scale testing or evaluation purposes and are currently un-tested in a production environment.

## Stroom v6.x release

### Prerequisites

In order to run Stroom v6.x using Docker you will need the following installed on the machine you intend to run Stroom on:

* A Linux-like shell environment.
* docker CE (v17.12.0+) - e.g https://docs.docker.com/install/linux/docker-ce/centos/ for Centos
* docker-compose (v1.21.0+) - https://docs.docker.com/compose/install/ 
* bash (v4+)
* jq - https://stedolan.github.io/jq/, e.g. `sudo yum install jq`
* curl

### Install steps

This will install the core stack (Stroom and the peripheral services required to run Stroom).

Visit [stroom-resources/releases (external link)](https://github.com/gchq/stroom-resources/releases) and find the latest stroom_core release and copy the link to the associated `stroom_core*.tar.gz` archive file.

Using `stroom_core-v6.0.19` as an example:

``` bash
# Set the release version to download
export STROOM_STACK_VER="stroom_core-v6.0.19"

# Make the stack directory
mkdir ${STROOM_STACK_VER}

# Download and extract the Stroom stack into the directory stroom_core-vX.Y.Z
curl -sL https://github.com/gchq/stroom-resources/releases/download/${STROOM_STACK_VER}/${STROOM_STACK_VER}.tar.gz | tar xz -C ${STROOM_STACK_VER}

# Navigate into the new stack directory, where xxxx is the directory that has just been created
cd ${STROOM_STACK_VER}

# Start the stack
./start.sh
```

Alternatively if you understand the risks of redirecting web sourced content direct to bash, you can get the latest release using:

``` bash
# Download and extract the Stroom stack
bash <(curl -s https://gchq.github.io/stroom-resources/get_stroom.sh)

# Navigate into the new stack directory
cd stroom_core_test/stroom_core_test*

# Start the stack
./start.sh
```

On first run stroom will build the database schemas so this can take a minute or two. 
The `start.sh` script will provide details of the various URLs that are available.

Open a browser (preferably Chrome) at [https://localhost/stroom](https://localhost/stroom) and login with:

* username: _admin_ (NOT an email address)
* password: _admin_

The stroom stack comes supplied with self-signed certificates so you may need to accept a prompt warning you about visiting an untrusted site.


## Stroom v5.x release

### Prerequisites

In order to run Stroom v5.x using Docker you will need the following installed on the machine you intend to run Stroom on:

* A Linux-like shell environment with bash and GNU sed/grep
* docker CE (v17.12.0+)
* docker-compose (v1.21.0+)
* git

### Install steps

```bash
# Clone the stroom-resources git repository
git clone https://github.com/gchq/stroom-resources.git

# Navigate to the bin directory in the repository
cd stroom-resources/bin

# Start the stroom v5.x stack using docker/docker-compose
./bounceIt.sh -f env/stroom5.env
```

Open a browser (preferably Chrome) at [http://localhost:8080/stroom](http://localhost:8080/stroom) and login with:

* username: _admin_ 
* password: _admin_


## Docker Hub links (external)
[The Stroom image](https://hub.docker.com/r/gchq/stroom/)

[The Stroom Authentication image](https://hub.docker.com/r/gchq/stroom-auth/)

[The GCHQ organisation](https://hub.docker.com/r/gchq/)
