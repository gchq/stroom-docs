> * Version Information: Created with Stroom v7.0  
* Last Updated: 2021-06-07

# Configuring Stroom

Stroom and its associated services can be deployed in may ways (single node docker stack, non-docker cluster, kubernetes, etc).
This document will cover two types of deployment:

* Single node stroom_core docker stack.
* A mixed deployment with nginx in docker and stroom, stroom-proxy and the database not in docker.

This document will explain how each application/service is configured and where its configuration files live.


## General configuration of docker stacks

### Environment variables

The stroom docker stacks have a single env file `<stack name>.env` that acts as a single point to configure some aspects of the stack.
This env file sets environment variables that are then used for variable substitution in the docker compose yaml files, e.g.

```yaml
    environment:
      - MYSQL_ROOT_PASSWORD=${STROOM_DB_ROOT_PASSWORD:-my-secret-pw}
```

In this example the environment variable `STROOM_DB_ROOT_PASSWORD` is read and used to set the environment variable `MYSQL_ROOT_PASSWORD` in the docker container, or `my-secret-pw` is used if `STROOM_DB_ROOT_PASSWORD` is not set.
The environment variables set in the env file are NOT visible in the containers.
Only those environment variable defined in the `environment` section of the docker-compose yaml files are visible.
In some case the names in the env file and the names of the environment variables set in the containers are the same, in some they are different.

The environment variables set in the containers can then be used by each each container to set its configuration.
For exmple stroom's `config.yml` file also uses variable substitution, e.g.

```yaml
appConfig:
  commonDbDetails:
    connection:
    jdbcDriverClassName: "${STROOM_JDBC_DRIVER_CLASS_NAME:-com.mysql.cj.jdbc.Driver}"
```

In this example `jdbcDriverUrl` will be set to the value of environment variable `STROOM_JDBC_DRIVER_CLASS_NAME` or `com.mysql.cj.jdbc.Driver` if that is not set.

### Configuration files

The following shows the basic structure of a stack with respect to the location of the configuration files:

```
├── stroom_core_test-vX.Y.Z
│   └── config - stack env file and docker compose yaml files
└── volumes
    └── <service>
        └── conf/config - service specifc configuration files
```

Some aspects of configuration do not lend themselves to environment variable substitution, e.g. deeply nested parts of stroom's `config.yml`.
In these instances it may be necessary to have static configuration files that have no connection to the env file or only use environment variables for some values.


## Stroom Configuration

[Stroom Configuration](./configuring-stroom.md)



## Stroom-proxy

### Without Docker

### As part of a docker stack

## MySQL

### Without Docker

### As part of a docker stack

## Nginx

## Stroom-log-sender







