---
title: "Stroom Configuration"
linkTitle: "Stroom Configuration"
#weight:
date: 2021-06-23
tags:
description: >
  Describes how the Stroom application is configured.
---

{{% see-also %}}
[Stroom and Stroom-Proxy Common Configuration]({{< relref "common-configuration" >}})  
[Stroom Properties]({{< relref "/docs/user-guide/properties.md" >}})
{{% /see-also %}}


## General configuration

The Stroom application is essentially just an executable {{< external-link "JAR" "https://en.wikipedia.org/wiki/JAR_%28file_format%29" >}} file that can be run when provided with a configuration file, `config.yml`.
This config file is common to all forms of deployment.


### config.yml

Stroom operates on a configuration by exception basis so all configuration properties will have a sensible default value and a property only needs to be explicitly configured if the default value is not appropriate, e.g. for tuning a large scale production deployment or where values are environment specific.
As a result `config.yml` only contains a minimal set of properties.
The full tree of properties can be seen in `./config/config-defaults.yml` and a schema for the configuration tree (along with descriptions for each property) can be found in `./config/config-schema.yml`.
These two files can be used as a reference when configuring stroom.


#### Key Configuration Properties

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

In a clustered deployment each node must be given a node name that is unique within the cluster.
This is used to identify nodes in the Nodes screen.
It could be the hostname of the node or follow some other naming convetion.

```yaml
  node:
    name: "node1a"
```

Each node should have its identity on the network configured so that it uses the appropriate FQDNs.
The `nodeUri` hostname is the FQDN of each node and used by nodes to communicate with each other, therefore it can be private to the cluster of nodes.
The `publicUri` hostname is the public facing FQDN for stroom, i.e. the address of a load balancer or Nginx.
This is the address that users will use in their browser.

```yaml
  nodeUri:
    hostname: "localhost" # e.g. node5.stroomnodes.somedomain
  publicUri:
    hostname: "localhost" # e.g. stroom.somedomain
```


## Deploying without Docker

Stroom running without docker has two files to configure it.
The following locations are relative to the stroom home directory, i.e. the root of the distribution zip.

* `./config/config.yml` - Stroom configuration YAML file
* `./config/scripts.env` - Stroom scripts configuration env file

The distribution also includes these files which are helpful when it comes to configuring stroom.

* `./config/config-defaults.yml` - Full version of the config.yml file containing all branches/leaves with default values set.
                                   Useful as a reference for the structure and the default values.
* `./config/config-schema.yml` - The schema defining the structure of the `config.yml` file.


### scripts.env

This file is used by the various shell scripts like `start.sh`, `stop.sh`, etc.
This file should not need to be unless you want to change the locations where certain log files are written to or need to change the java memory settings.

In a production system it is highly likely that you will need to increase the java heap size as the default is only 2G.
The heap size settings and any other java command line options can be set by changing:

```sh
JAVA_OPTS="-Xms512m -Xmx2048m"
```


## As part of a docker stack

When stroom is run as part of one of our docker stacks, e.g. _stroom_core_ there are some additional layers of configuration to take into account, but the configuration is still primarily done using the `config.yml` file.

Stroom's `config.yml` file is found in the stack in `./volumes/stroom/config/` and this is the primary means of configuring Stroom.

The stack also ships with a default `config.yml` file baked into the docker image.
This minimal fallback file (located in `/stroom/config-fallback/` inside the container) will be used in the absence of one provided in the docker stack configuration (`./volumes/stroom/config/`).

The default `config.yml` file uses [environment variable substitution]({{< relref "./#environment-variables" >}}) so some configuration items will be set by environment variables set into the container by the stack _env_ file and the docker-compose YAML.
This approach is useful for configuration values that need to be used by multiple containers, e.g. the public FQDN of Nginx, so it can be configured in one place.

If you need to further customise the stroom configuration then it is recommended to edit the `./volumes/stroom/config/config.yml` file.
This can either be a simple file with hard coded values or one that uses environment variables for some of its
configuration items.

The configuration works as follows:

```text
env file (stroom<stack name>.env)
                |
                |
                | environment variable substitution
                |
                v
docker compose YAML (01_stroom.yml)
                |
                |
                | environment variable substitution
                |
                v
Stroom configuration file (config.yml)
```


### Ansible

If you are using Ansible to deploy a stack then it is recommended that all of stroom's configuration properties are set directly in the `config.yml` file using a templated version of the file and to NOT use any environment variable substitution.
When using Ansible, the Ansible inventory is the single source of truth for your configuration so not using environment variable substitution for stroom simplifies the configuration and makes it clearer when looking at deployed configuration files.

[Stroom-ansible](https://github.com/gchq/stroom-ansible) has an example inventory for a single node stroom stack deployment.
The [group_vars/all](https://github.com/gchq/stroom-ansible/blob/master/config/single_node_stroom_core_stack/example_inventory/group_vars/all) file shows how values can be set into the _env_ file.

