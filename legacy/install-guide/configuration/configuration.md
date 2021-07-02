# Configuration

> **Version Information:** Created with Stroom v7.0  
> **Last Updated:** 2021-06-23

Stroom and its associated services can be deployed in may ways (single node docker stack, non-docker cluster, kubernetes, etc).
This document will cover two types of deployment:

* Single node stroom_core docker stack.
* A mixed deployment with nginx in docker and stroom, stroom-proxy and the database not in docker.

This document will explain how each application/service is configured and where its configuration files live.


## Application Configuration

The following sections provide links to how to configure each application.

* [Stroom Configuration](./configuring-stroom.md)

* [Stroom Proxy Configuration](./configuring-stroom-proxy.md)

* [MySQL Configuration](./configuring-mysql.md)

* [Nginx Configuration](./configuring-nginx.md)

* [Stroom log sender Configuration](./configuring-stroom-log-sender.md)


## General configuration of docker stacks


### Environment variables

The stroom docker stacks have a single env file `<stack name>.env` that acts as a single point to configure some aspects of the stack.
Setting values in the env file can be useful when the value is shared between multiple containers.
This env file sets environment variables that are then used for variable substitution in the docker compose YAML files, e.g.

```yaml
    environment:
      - MYSQL_ROOT_PASSWORD=${STROOM_DB_ROOT_PASSWORD:-my-secret-pw}
```

In this example the environment variable `STROOM_DB_ROOT_PASSWORD` is read and used to set the environment variable `MYSQL_ROOT_PASSWORD` in the docker container.
If `STROOM_DB_ROOT_PASSWORD` is not set then the value `my-secret-pw` is used instead.

The environment variables set in the env file are _NOT_ automatically visible _inside_ the containers.
Only those environment variables defined in the `environment` section of the docker-compose YAML files are visible.
These `environment` entries can either be hard coded values or use environment variables from _outside_ the container.
In some case the names in the env file and the names of the environment variables set in the containers are the same, in some they are different.

The environment variables set in the containers can then be used by the application running in each container to set its configuration.
For example, stroom's `config.yml` file also uses variable substitution, e.g.

```yaml
appConfig:
  commonDbDetails:
    connection:
    jdbcDriverClassName: "${STROOM_JDBC_DRIVER_CLASS_NAME:-com.mysql.cj.jdbc.Driver}"
```

In this example `jdbcDriverUrl` will be set to the value of environment variable `STROOM_JDBC_DRIVER_CLASS_NAME` or `com.mysql.cj.jdbc.Driver` if that is not set.

The following example shows how setting `MY_ENV_VAR=123` means `myProperty` will ultimately get a value of `123` and not its default of `789`.

```
env file (stroom<stack name>.env) - MY_ENV_VAR=123
                |
                |
                | environment variable substitution
                |
                v
docker compose YAML (01_stroom.yml) - STROOM_ENV_VAR=${MY_ENV_VAR:-456}
                |
                |
                | environment variable substitution
                |
                v
Stroom configuration file (config.yml) - myProperty: "${STROOM_ENV_VAR:-789}"
```

Note that environment variables are only set into the container on start.
Any changes to the env file will not take effect until the container is (re)started.


### Configuration files

The following shows the basic structure of a stack with respect to the location of the configuration files:

```
── stroom_core_test-vX.Y.Z
   ├── config                [stack env file and docker compose YAML files]
   └── volumes
       └── <service>
           └── conf/config   [service specifc configuration files]
```

Some aspects of configuration do not lend themselves to environment variable substitution, e.g. deeply nested parts of stroom's `config.yml`.
In these instances it may be necessary to have static configuration files that have no connection to the env file or only use environment variables for some values.


### Bind mounts

Everything in the stack `volumes` directory is bind-mounted into the named docker container but is mounted read-only to the container.
This allows configuration files to be read by the container but not modified.

Typically the bind mounts mount a directory into the container, though in the case of the `stroom-all-dbs.cnf` file, the file is mounted.
The mounts are done using the inode of the file/directory rather than the name, so docker will mount whatever the inode points to even if the name changes.
If for instance the `stroom-all-dbs.cnf` file is renamed to `stroom-all-dbs.cnf.old` then copied to `stroom-all-dbs.cnf` and then the new version modified, the container would still see the old file.


### Docker managed volumes

When stroom is running various forms of data are persisted, e.g. stroom's stream store, stroom-all-dbs database files, etc.
All this data is stored in docker managed volumes.
By default these will be located in `/var/lib/docker/volumes/<volume name>/_data` and root/sudo access will be needed to access these directories.


#### Docker data root

> **IMPORTANT**

By default Docker stores all its images, container layers and managed volumes in its default data root directory which defaults to `/var/lib/docker`.
It is typical in server deployments for the root file system to be kept fairly small and this is likely to result in the root file system running out of space due to the growth in docker images/layers/volumes in `/var/lib/docker`.
It is therefore strongly recommended to move the docker data root to another location with more space.

There are various options for achieving this.
In all cases the docker daemon should be stopped prior to making the changes, e.g. `service docker stop`, then started afterwards.

* **Symlink** - One option is to move the `var/lib/docker` directory to a new location then create a symlink to it.
    For example: 
    ```sh
    ln -s /large_mount/docker_data_root /var/lib/docker
    ```
    This has the advantage that anyone unaware that the data root has moved will be able to easily find it if they look in the default location.

* **Configuration** - The location can be changed by adding this key to the file `/etc/docker/daemon.json` (or creating this file if it doesn't exist.
    ```json
    {
      "data-root": "/mnt/docker"
    }
    
    ```
* **Mount** - If your intention is to use a whole storage device for the docker data root then you can mount that device to `/var/lib/docker`.
    You will need to make a copy of the `/var/lib/docker` directory prior to doing this then copy it mount once created.
    The process for setting up this mount will be OS dependent and is outside the scope of this document.


### Active services

Each stroom docker stack comes pre-built with a number of different services, e.g. the _stroom_core_ stack contains the following:

* stroom
* stroom-proxy-local
* stroom-all-dbs
* nginx
* stroom-log-sender

While you can pass a set of service names to the commands like `start.sh` and `stop.sh`, it may sometimes be required to configure the stack instance to only have a set of services active.
You can set the active services like so:

```bash
./set_services.sh stroom stroom-all-dbs nginx
```

In the above example and subsequent use of commands like `start.sh` and `stop.sh` with no named services would only act upon the active services set by `set_services.sh`.
This list of active services is held in `ACTIVE_SERVICES.txt` and the full list of available services is held in `ALL_SERVICES.txt`.


### Certificates

A number of the services in the docker stacks will make use of SSL certificates/keys in various forms.
The certificate/key files are typically found in the directories `volumes/<service>/certs/`.

The stacks come with a set of client/server certificates that can be used for demo/test purposes.
For production deployments these should be replaced with the actual certificates/keys for your environment.

In general the best approach to configuring the certificates/keys is to replace the existing files with symlinks to the actual files.
For example in the case of the server certificates for nginx (found in `volumes/nginx/certs/`) the directory would look like:

```
ca.pem.crt -> /some/path/to/certificate_authority.pem.crt
server.pem.crt -> /some/path/to/host123.pem.crt
server.unencrypted.key -> /some/path/to/host123.key
```

This approach avoids the need to change any configuration files to reference differently named certificate/key files and avoids having to copy your real certificates/keys into multiple places.

For examples of how to create certificates, keys and keystores see [creatCerts.sh (external link)](https://github.com/gchq/stroom-resources/blob/master/dev-resources/certs/createCerts.sh)
