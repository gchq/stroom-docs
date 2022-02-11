---
title: "Properties"
linkTitle: "Properties"
#weight:
date: 2021-07-27
tags:
  - property
  - configuration
description: >
  Configuration of Stroom's application properties.
---

> This documentation applies to Stroom 7.0 or higher

Properties are the means of configuring the Stroom application and are typically maintained by the Stroom system administrator.
The value of some properties are required in order for Stroom to function, e.g. database connection details, and thus need to be set prior to running Stroom.
Some properties can be changed at runtime to alter the behaviour of Stroom.

## Sources

Property values can be defined in the following locations.

### System Default

The system defaults are hard-coded into the Stroom application code by the developers and can't be changed.
These represent reasonable defaults, where applicable, but may need to be changed, e.g. to reflect the scale of the Stroom system or the specific environment.

The default property values can either be viewed in the Stroom user interface (_Tools_ -> _Properties_) or in the file `config/config-defaults.yml` in the Stroom distribution.

### Global Database Value

Global database values are property values stored in the database that are global across the whole cluster.

The global database value is defined as a record in the `config` table in the database.
The database record will only exist if a database value has explicitly been set.
The database value will apply to all nodes in the cluster, overriding the default value, unless a node also has a value set in its YAML configuration.

Database values can be set from the Stroom user interface using _Tools_ -> _Properties_.
Some properties are marked _Read Only_ which means they cannot have a database value set for them.
These properties can only be altered via the YAML configuration file on each node.
Such properties are typically used to configure values required for Stroom to be able to boot, so it does not make sense for them to be configurable from the User Interface.

### YAML Configuration file

Stroom is built on top of a framework called Drop Wizard.
Drop Wizard uses a YAML configuration file on each node to configure the application.
This is typically `config.yml` and is located in the `config` directory.

This file contains both the Drop Wizard configuration settings (settings for ports, paths and application logging) and the Stroom specific properties configuration.
The file is in YAML format and the Stroom properties are located under the `appConfig` key.
For details of the Drop Wizard configuration structure, see {{< external-link "here" "https://www.dropwizard.io/en/latest/manual/configuration.html" >}}.

The file is split into three sections using these keys:

* `server` - Configuration of the web server, e.g. ports, paths, request logging.
* `logging` - Configuration of application logging
* `appConfig` - The stroom configuration properties

The following is an example of the YAML configuration file:

```yaml
# Drop Wizard configuration section
server:
  # e.g. ports and paths
logging:
  # e.g. logging levels/appenders

# Stroom properties configuration section
appConfig:
  commonDbDetails:
    connection:
      jdbcDriverClassName: ${STROOM_JDBC_DRIVER_CLASS_NAME:-com.mysql.cj.jdbc.Driver}
      jdbcDriverUrl: ${STROOM_JDBC_DRIVER_URL:-jdbc:mysql://localhost:3307/stroom?useUnicode=yes&characterEncoding=UTF-8}
      jdbcDriverUsername: ${STROOM_JDBC_DRIVER_USERNAME:-stroomuser}
      jdbcDriverPassword: ${STROOM_JDBC_DRIVER_PASSWORD:-stroompassword1}
  contentPackImport:
    enabled: true
  ...
```

In the Stroom user interface properties are named with a dot notation key, e.g. _stroom.contentPackImport.enabled_.
Each part of the dot notation property name represents a key in the YAML file, e.g. for this example, the location in the YAML would be:

```yaml
appConfig:
  contentPackImport:
    enabled: true   # stroom.contentPackImport.enabled
```

The _stroom_ part of the dot notation name is replaced with _appConfig_.

#### Variable Substitution

The YAML configuration file supports Bash style variable substitution in the form of:

```bash
${ENV_VAR_NAME:-value_if_not_set}
```

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

The three sources (_Default_, _Database_ & _YAML_) are listed in increasing priority, i.e _YAML_ trumps _Database_, which trumps _Default_.

For example, in a two node cluster, this table shows the effective value of a property on each node.
A `-` indicates the value has not been set in that source.
`NULL` indicates that the value has been explicitly set to NULL.

Source    | Node1     | Node2
----------|-----------|------
Default   | red       | red
Database  | -         | -
YAML      | -         | blue 
Effective | **red**   | **blue** 

Or where a Database value is set.

Source    | Node1     | Node2
----------|-----------|------
Default   | red       | red
Database  | green     | green
YAML      | -         | blue
Effective | **green** | **blue**

Or where a YAML value is explicitly set to `NULL`.

Source    | Node1     | Node2
----------|-----------|------
Default   | red       | red
Database  | green     | green
YAML      | -         | NULL
Effective | **green** | **NULL**

## Data Types

Stroom property values can be set using a number of different data types.
Database property values are currently set in the user interface using the string form of the value.
For each of the data types defined below, there will be an example of how the data type is recorded in its string form.

Data Type       | Example UI String Forms                                               | Example YAML form
----------      | ----------------------                                                | ------------------
Boolean         | `true` `false`                                                        | `true` `false`
String          | `This is a string`                                                    | `"This is a string"`
Integer/Long    | `123`                                                                 | `123`
Float           | `1.23`                                                                | `1.23`
Stroom Duration | `P30D` `P1DT12H` `PT30S` `30d` `30s` `30000`                          | `"P30D"` `"P1DT12H"` `"PT30S"` `"30d"` `"30s"` `"30000"` See [Stroom Duration Data Type](#stroom-duration-data-type).
List            | `#red#Green#Blue` `,1,2,3`                                            | See [List Data Type](#list-data-type)
Map             | `,=red=FF0000,Green=00FF00,Blue=0000FF`                               | See [Map Data Type](#map-data-type)
DocRef          | `,docRef(MyType,a56ff805-b214-4674-a7a7-a8fac288be60,My DocRef name)` | See [DocRef Data Type](#docref-data-type)
Enum            | `HIGH` `LOW`                                                          | `"HIGH"` `"LOW"`
Path            | `/some/path/to/a/file`                                                | `"/some/path/to/a/file"`
ByteSize        | `32`, `512Kib`                                                        | `32`, `512Kib` See [Byte Size Data Type](#byte-size-data-type)

### Stroom Duration Data Type

The _Stroom Duration_ data type is used to specify time durations, for example the time to live of a cache or the time to keep data before it is purged.
_Stroom Duration_ uses a number of string forms to support legacy property values.

#### ISO 8601 Durations

_Stroom Duration_ can be expressed using {{< external-link "ISO 8601" "https://en.wikipedia.org/wiki/ISO_8601" >}} duration strings.
It does NOT support the full _ISO 8601_ format, only `D`, `H`, `M` and `S`.
For details of how the string is parsed to a Stroom Duration, see {{< external-link "Duration" "https://docs.oracle.com/en/java/javase/12/docs/api/java.base/java/time/Duration.html#parse(java.lang.CharSequence)" >}}

The following are examples of _ISO 8601_ duration strings:

* `P30D` - 30 days
* `P1DT12H` - 1 day 12 hours (36 hours)
* `PT30S` - 30 seconds
* `PT0.5S` - 500 milliseconds

#### Legacy Stroom Durations

This format was used in versions of Stroom older than v7 and is included to support legacy property values.

The following are examples of legacy duration strings:

* `30d` - 30 days
* `12h` - 12 hours
* `10m` - 10 minutes
* `30s` - 30 seconds
* `500` - 500 milliseconds

Combinations such as `1m30s` are not supported.

### List Data Type

This type supports ordered lists of items, where an item can be of any supported data type, e.g. a list of strings or list of integers.

The following is an example of how a property (`statusValues`) that is is List of strings is represented in the YAML:

```yaml
  annotation:
    statusValues:
    - "New"
    - "Assigned"
    - "Closed"
```

This would be represented as a string in the User Interface as:

`|New|Assigned|Closed`.

See [Delimiters in String Conversion](#delimiters-in-string-conversion) for details of how the items are delimited in the string.

The following is an example of how a property (`cpu`) that is is List of DocRefs is represented in the YAML:

```yaml
  statistics:
    internal:
      cpu:
      - type: "StatisticStore"
        uuid: "af08c4a7-ee7c-44e4-8f5e-e9c6be280434"
        name: "CPU"
      - type: "StroomStatsStore"
        uuid: "1edfd582-5e60-413a-b91c-151bd544da47"
        name: "CPU"
```

This would be represented as a string in the User Interface as: 

`|,docRef(StatisticStore,af08c4a7-ee7c-44e4-8f5e-e9c6be280434,CPU)|,docRef(StroomStatsStore,1edfd582-5e60-413a-b91c-151bd544da47,CPU)`

See [Delimiters in String Conversion](#delimiters-in-string-conversion) for details of how the items are delimited in the string.

### Map Data Type

This type supports a collection of key/value pairs where the key is unique within the collection.
The type of the key must be string, but the type of the value can be any supported type.

The following is an example of how a property (`mapProperty`) that is a map of string => string would be represented in the YAML:

```yaml
mapProperty:
  red: "FF0000"
  green: "00FF00"
  blue: "0000FF"
```

This would be represented as a string in the User Interface as: 

`,=red=FF0000,Green=00FF00,Blue=0000FF`

The delimiter between pairs is defined first, then the delimiter for the key and value.

See [Delimiters in String Conversion](#delimiters-in-string-conversion) for details of how the items are delimited in the string.

### DocRef Data Type

A DocRef (or Document Reference) is a type specific to Stroom that defines a reference to an instance of a Document within Stroom, e.g. an XLST, Pipeline, Dictionary, etc.
A DocRef consists of three parts, the type, the {{< external-link "UUID" "https://en.wikipedia.org/wiki/Universally_unique_identifier" >}} and the name of the Document.

The following is an example of how a property (`aDocRefProperty`) that is a DocRef would be represented in the YAML:

```yaml
aDocRefProperty:
  type: "MyType"
  uuid: "a56ff805-b214-4674-a7a7-a8fac288be60"
  name: "My DocRef name"
```

This would be represented as a string in the User Interface as: 

`,docRef(MyType,a56ff805-b214-4674-a7a7-a8fac288be60,My DocRef name)` 

See [Delimiters in String Conversion](#delimiters-in-string-conversion) for details of how the items are delimited in the string.

### Byte Size Data Type

The Byte Size data type is used to represent a quantity of bytes using the {{< external-link "IEC" "https://en.wikipedia.org/wiki/Binary_prefix" >}} standard.
Quantities are represented as powers of 1024, i.e. a Kib (Kibibyte) means 1024 bytes.

Examples of Byte Size values in string form are (a YAML value would optionally be surrounded with double quotes):

* `32`, `32b`, `32B`, `32bytes` - 32 bytes
* `32K`, `32KB`, `32KiB` - 32 kibibytes
* `32M`, `32MB`, `32MiB` - 32 mebibytes
* `32G`, `32GB`, `32GiB` - 32 gibibytes
* `32T`, `32TB`, `32TiB` - 32 tebibytes
* `32P`, `32PB`, `32PiB` - 32 pebibytes

The `*iB` form is preferred as it is more explicit and avoids confusion with SI units.

### Delimiters in String Conversion

The string conversion used for collection types like _List_, _Map_ etc. relies on the string form defining the delimiter(s) to use for the collection.
The delimiter(s) are added as the first n characters of the string form, e.g. `|red|green|blue` or `|=red=FF0000|Green=00FF00|Blue=0000FF`.
It is possible to use a number of different delimiters to allow for delimiter characters appearing in the actual value, e.g. `#some text#some text with a | in it`
The following are the delimiter characters that can be used.

`|`, `:`, `;`, `,`, `!`, `/`, `\`, `#`, `@`, `~`, `-`, `_`, `=`, `+`, `?`

When Stroom records a property value to the database it may use a delimiter of its own choosing, ensuring that it picks a delimiter that is not used in the property value.

## Restart Required

Some properties are marked as requiring a restart.
There are two scopes for this:

### Requires UI Refresh

If a property is marked in UI as requiring a UI refresh then this means that a change to the property requires that the Stroom nodes serving the UI are restarted for the new value to take effect.

### Requires Restart

If a property is marked in UI as requiring a restart then this means that a change to the property requires that all Stroom nodes are restarted for the new value to take effect.
