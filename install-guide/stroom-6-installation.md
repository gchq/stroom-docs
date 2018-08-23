# Stroom 6 Installation Guide [DRAFT]

## Quick-install
If you'd like to run a test or demo of Stroom then you probably need something easy and quick. This means using Docker images for everything, and using the `bounceIt.sh` script to start the containers. 

If you don't want to use containers at all then please feel free to submit a PR indicating how you plan to do this.

### Getting the Docker images
If your host for Stroom has access to hub.docker.com then you can go to the next step; `bounceIt.sh` uses `docker-compose`, which will pull down the images automatically.

If you don't have direct access to the internet then you've got some work to do. If you have a Docker image repository on your intranet then you might already have an automatic mechanism for getting the images onto your network. If you don't have a Docker image repository then you need to do the following:

1. Download the images (TODO: link to images) on a machine which does have access to the internet. The easiest way to do this is by running `bounceIt.sh`. Instructions are below (TODO: link).
2. (Export)[https://docs.docker.com/engine/reference/commandline/export/] each image to a file. Something like this: `docker export gchq/stroom:v6.0-beta.2 > gchq_stroom_v6.0-beta.2.tar`
3. Get these images onto your network and onto your host machine, however you do that.
4. (Import)[https://docs.docker.com/engine/reference/commandline/import/] the images to your host's local repository. Something like this: `docker import /path/to/gchq_stroom_v6.0-beta.2.tgz`.

### Getting bounceIt.sh
Clone the git repository. `stroom-resources` contains scripts and configuration that is used to build and run stroom.

`git clone git@github.com:gchq/stroom-resources.git`

### Running Stroom
TODO: customise the tags? Run a canned version? What about the repo?
`cd strom-resources/bin`
`./bounceIt.sh`

## Post-install hardening

### Before first run

#### Change database passwords

If you don't do this before the first run of Stroom then the passwords will already be set and you'll have to change them on the database manually, and then change the `.env`.

This change should be made in the `.env` configuration file. If the values are not there then this service is not included in your Stroom stack and there is nothing to change.

* `STROOM_DB_PASSWORD`
* `STROOM_DB_ROOT_PASSWORD`

* `STROOM_STATS_DB_ROOT_PASSWORD`
* `STROOM_STATS_DB_PASSWORD`

* `STROOM_AUTH_DB_PASSWORD`
* `STROOM_AUTH_DB_ROOT_PASSWORD`

* `STROOM_ANNOTATIONS_DB_PASSWORD`
* `STROOM_ANNOTATIONS_DB_ROOT_PASSWORD`

### On first run

#### Change the admin password

Change the admin password using Stroom, under `User` -> `Change password`. In a future release you will be required to change the admin password on first run.

#### Delete un-used users and API keys

* If you're not using stats you can delete or disable the following:
  * the user `statsServiceUser`
  * the API key for `statsServiceUser`

#### Change the API keys

First generate new API keys. You can generate a new API key using Stroom, under `Tools` -> `API Keys`. The following need to be changed:

* `STROOM_SECURITY_API_TOKEN`

  * This is the API token for user `stroomServiceUser`.

Then stop Stroom and update the API key in the `.env` configuration file with the new value.
