# Stroom Application Configuration

> **Version Information:** Created with Stroom v7.0  
> **Last Updated:** 2021-06-07  
> **See Also:** [Properties](../../user-guide/properties.md).  

## General configuration

The Stroom application is essentially just an executable [JAR (external link)](https://en.wikipedia.org/wiki/JAR_%28file_format%29) file that can be run when provided with a configuration file, `config.yml`.
This config file is common to all forms of deployment.

### config.yml

This file, sometimes known as the DropWizard configuration file (as DropWizard is the java framework on which Stroom runs) is the primary means of configuring stroom.
As a minimum this file should be used to configure anything that needs to be set before stroom can start up, e.g. database connection details or is specific to a node in a stroom cluster.
If you are using some form of scripted deployment, e.g. ansible then it can be used to set all stroom properties for the environment that stroom runs in.
If you are not using scripted deployments then you can maintain stroom's node agnostic configuration properties via the user interface.

For more details on the structure of the file, data types and property precedence see [Properties](../../user-guide/properties.md).

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

In a clustered deployment each node should be given a node name that is unique within the cluster.

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
The stack ships with a default `config.yml` file baked into the docker image.
This fallback file (located in `/stroom/config-fallback` inside the container) will be used in the absence of one provided in the docker stack configuration (`./volumes/stroom/config`).
This fallback config file contains environment variable substitution so some configuration items will be set by environment variables set into the container by the stack env file and the docker-compose YAML.

For basic configuration it is possible to configure stroom via the env file only.
The env file contains the configuration items that need to be set for stroom to run or typically need to be changed in a production environment.
It does not contain all possible configuration items.

If you need to further customise the stroom configuration then it is recommended to create a `./volumes/stroom/config/config.yml` file.
This can either be a simple file with hard coded values or one that uses environment variables for some of its
configuration items.

The configuration works as follows:

```
env file (stroom<stack name>.env)
              |
              | environment variable substitution
              v
docker compose YAML (01_stroom.yml)
              |
              | environment variable substitution
              v
Stroom configuration file (config.yml)
```

### Ansible

If you are deploying a stack with Ansible then to make life easier we have provided `./stroom_<stack name>-X.Y-Z/config/ansible/stroom_<stack name>.env.j2` which is a jinja2 templated version of the env file.
This file is for use with stroom-ansible and means you can simply set variables in your inventory and this template will be used to create an env file.

