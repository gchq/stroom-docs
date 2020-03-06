# Properties

> This documentation applies to version 7.0 or higher

Properties are the means of configuring the Stroom application and are typically maintained by the Stroom system administrator.

## Sources

Property values can be defined in the following locations.

### System Default

The system defaults are hard-coded into the Stroom application code and can't be changed.

### Global Database Value

The global database value is defined as a record in the `config` table in the database.
The database record will only exist if a database value has explicitly been set.
The database value will apply to all nodes in the cluster, overriding the default value, unless a node also has a value set in its YAML configuration.

Database values can be set from the Stroom user interface using _Tools_ -> _Properties_.
Some properties are marked _Read Only_ which means they cannot have a database value set for them.
These properties can only be altered via the YAML configuration file on each node.

### YAML Configuration file

Each Stroom node has a YAML configuration file which is required to run Stroom.
This is typically `config.yml` and is located in the `config` directory.
This file contains both the DropWizard configuration settings (settings for ports, paths and application logging) and the Stroom properties configuration.
The file is in YAML format and the Stroom properties are located under the `appConfig` key.

The following is an example of the YAML configuration file:

```yaml
server:
  ...
logging:
  ...
appConfig:
  superDevMode: true
  commonDbDetails:
    connection:
      jdbcDriverClassName: ${STROOM_JDBC_DRIVER_CLASS_NAME:-com.mysql.cj.jdbc.Driver}
      jdbcDriverUrl: ${STROOM_JDBC_DRIVER_URL:-jdbc:mysql://localhost:3307/stroom?useUnicode=yes&characterEncoding=UTF-8}
      jdbcDriverUsername: ${STROOM_JDBC_DRIVER_USERNAME:-stroomuser}
      jdbcDriverPassword: ${STROOM_JDBC_DRIVER_PASSWORD:-stroompassword1}
  contentPackImport:
    enabled: true
```

In the Stroom user interface properties are named with a dot notation key, e.g. _stroom.contentPackImport.enabled_.
Each part of the dot notation property name represents a key in the YAML file, e.g. for this example, the location in the YAML would be:

```yaml
appConfig:
  contentPackImport:
    enabled: true
```

The _stroom_ part of the dot notation name is replaced with _appConfig_.

#### Variable Substitution

The configuration file supports Bash style variable substitution in the form of:

`${ENV_VAR_NAME:-value_if_not_set}`

This allows values to be set either directly in the file or via an environment variable, e.g.

```yaml
      jdbcDriverClassName: ${STROOM_JDBC_DRIVER_CLASS_NAME:-com.mysql.cj.jdbc.Driver}
```

In the above example, if the _STROOM_JDBC_DRIVER_CLASS_NAME_ environment variable is not set then the value _com.mysql.cj.jdbc.Driver_ will be used instead.

#### Typed Values

YAML supports typed values rather than just strings, see https://yaml.org/refcard.html.
YAML understands booleans, strings, integers, floating point numbers, as well as sequences/lists and maps.
Some properties will be represented differently in the user interface to the YAML file.
This is due to how values are stored in the database and how the current user interface works.
This will likely be improved in future versions.
For details of how different types are represented in the YAML and the UI, see [Data Types](#data-types).

## Source Precedence

The three sources above are listed in increasing priority, i.e _YAML_ trumps _Database_, which trumps _Default_.
For example, in a two node cluster:

Source    | Node1 | Node2
----------|-------|------
Default   | red   | red
Database  |       |
YAML      |       | blue 
Effective | red   | blue 

Or

Source    | Node1 | Node2
----------|-------|------
Default   | red   | red
Database  | green | green
YAML      |       | blue
Effective | green | blue



## Data Types

### String Conversion




## Restart Required


