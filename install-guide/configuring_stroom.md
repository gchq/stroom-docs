> * Version Information: Created with Stroom v7.0  
* Last Updated: 2021-06-04

# Configuring Stroom

Stroom can be deployed in may ways (single node docker stack, non-docker cluster, kubernetes, etc).
This document will cover two types of deployment:

* Single node stroom_core docker stack.
* A mixed deployment with nginx in docker and stroom, stroom-proxy and the database not in docker.

This document will explain how each application/service is configured and where its configuration files live.

## General configuration of docker stacks

The docker stacks have a single env file `<stack name>.env` that acts as a single point to configure 


## Stroom Configuration


### Without Docker

Stroom running without docker has two files to configure it.
The following locations are relative to the stroom home directory, i.e. the root of the distribution zip.

* ./config/config.yml - Stroom configuration YAML file
* ./config/scripts.env - Stroom scripts configuration env file


#### config.yml

This file, sometimes known as the DropWizard configuration file (as DropWizard is the java framework on which Stroom runs) is the primary means of configuring stroom.
As a minimum this file should be used to configure anything that needs to be set before stroom can start up, e.g. database connection details or is specific to a node in a stroom cluster.
If you are using some form of scripted deployment, e.g. ansible then it can be used to set all stroom properties for the environment that stroom runs in.
If you are not using scripted deployments then you can maintain stroom's node agnostic configuration properties via the user interface.

For more details on the structure of the file and property precedence see [Properties](../user-guide/properties.md).

Stroom's operates on a configuration by exception basis so all configuration properties will have a sensible default value and a property only needs to be explicitly configured if the default value is not appropriate, e.g. for tuning a large scale production deployment.
As a result `config.yml` only contains a minimal set of properties.
The full tree of properties can be seen in `./config/config-defaults.yml` and a schema for the configuration tree (along with descriptions for each property) can be found in `./config/config-schema.yml`.
These two files can be used as a reference when configuring stroom.


##### Key Configuration Properties

The following are key properties that would typically be changed for a production deployment.
All configuration branches are relative to the `appConfig` root.

The database name(s), hostname(s), port(s), usernames(s) and password(s) should be configured using these properties.
Typically stroom is configured to keep it statistics data in a separate database to the main stroom database, as is configured below.

```yaml
  commonDbDetails:
    connection:
      jdbcDriverUrl: "jdbc:mysql://localhost:3307/stroom?useUnicode=yes&characterEncoding=UTF-8"
      jdbcDriverUsername: "stroomuser"
      jdbcDriverPassword: "stroompassword1"
  statistics:
    sql:
      db:
        connection:
          jdbcDriverUrl: "jdbc:mysql://localhost:3307/stats?useUnicode=yes&characterEncoding=UTF-8"
          jdbcDriverUsername: "statsuser"
          jdbcDriverPassword: "stroompassword1"
```

In a clustered deployment each node should be given a node name that is unique within the cluster.

```yaml
  node:
    name: "node1a"
```

Each node should have its identity on the network configured so that it uses the appropriate FQDNs.
The nodeUri hostname is the FQDN of each node and used by nodes to communicate with each other, therefore it can be private to the cluster of nodes.
The publicUri hostname is the public facing FQDN for stroom, i.e. the address of a load balancer or Nginx.

```yaml
  nodeUri:
    hostname: "localhost"
  publicUri:
    hostname: "localhost"
```

#### scripts.env

This file is used by the various shell scripts like `start.sh`, `stop.sh`, etc.
This file should not need to be unless you want to change the locations where certain log files are written to or need to change the java memory settings.

In a production system it is highly likely that you will need to increase the java heap size as the default is only 2G.
The heap size settings and any other java command line options can be set by changing:

```sh
JAVA_OPTS="-Xms512m -Xmx2048m"
```


### As part of a docker stack

When stroom is run as part of one of our docker stacks, e.g. _stroom_core_ there are some additional layers of configuration to take into account.

## Stroom-proxy

### Without Docker

### As part of a docker stack

## MySQL

### Without Docker

### As part of a docker stack

## Nginx

## Stroom-log-sender













