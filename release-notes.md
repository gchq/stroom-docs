# New Features and Changes

## 7.1

### User Preferences
The UI can now be customised with different themes (dark + light) to suit the needs of a user.

The font and font size can be customised to suit different users and different display sizes.

Spacing between visual elements such as table rows can be adjusted to increase reading comfort or make the layout more compact.

Date and time formatting can now be customised along with the timezone.

### Visualisation Selection
It is now possible to create visualisations that have selection behaviour that affects other aspects of a dashboard, e.g. you can have a visualisation that shows events over a time range and selecting a portion of that visualisation can filter results displayed in a dashboard table.

### Elastic Search Integration
Stroom now integrates with elastic search as a data source provider for indexing and searching.

### XSLT 3.0 Support
The XSLT library has been updated to allow the use of XSLT 3.0.

### Stroom Proxy
Improved Stroom Proxy configuration.

Stroom proxy can now forward to multiple destinations.

The aggregation process has been changed to be more performant and produce aggregates that meet the configured constraints.

## v7.0

### Integrated Authentication

The previously standalone (in v6) _stroom-auth-service_ and _stroom-auth-ui_ services have been integrated into the core _stroom_ application.
This simplifies the installation and configuration of stroom.

Support has been added for multiple OpenID Connect identity providers including Amazon AWS and Google.

### Annotations

Search results in dashboards can be annotated to provide status and notes relating to the result item, e.g. an event. These annotations can later be searched to see which events have annotations associated with them.

### Conditional Formatting

Dashboard tables have added support for conditional formatting allowing rows to have custom background and text color when user defined conditions are matched.

### New Dashboard Functions

* Functions to select data from nested child rows, `any()`, `first()`, `last()`, `nth()`, `top()` and `bottom()`.
* `joining()` function to concatenate supplied fields in child rows.
* `modulus()` function along with alias `mod()` and modulus operator `%`.
* `annotation()` link creation function, `currentUser()` alias for `param('currentUser()')` and additional link creation functions for `data()` and `stepping()`.
* Dashboard link option to link to a dashboard using the `DASHBOARD` target name, e.g. `link(${UserId}, concat('type=Dashboard&uuid=<TARGET_DASHBOARD_UUID>', ${UserId}), '', 'DASHBOARD')`.
* Dashboard link option to link to a dashboard from within a vis, e.g. `stroomLink(d.name, 'type=Dashboard&uuid=<TARGET_DASHBOARD_UUID>&params=userId%3D' + d.name, 'DASHBOARD')`.
* Dashboard visualisations now link with similar functions available to dashboard tables, e.g. `link()`, `dashboard()`, `annotation()`, `stepping()`, `data()`.
* Mechanism to inject dashboard parameters into expressions using the `param` and `params` functions so that dashboard parameters can be echoed by expressions to create dashboard links.
* `encodeUrl()`, `decodeUrl()` and `dashboard()` functions to dashboard tables to make dashboard linking easier. The `link()` function now automatically encodes/decodes each param so that parameters do not break the link format, e.g. `[Click Here](http://www.somehost.com/somepath){dialog|Dialog Title}`.  
* `typeOf(...)` function to dashboard.
* Cast functions `toBoolean`, `toDouble`, `toInteger`, `toLong` and `toString`.
* `include` and `exclude` functions.
* `if` and `not` functions.
* Value functions `true()`, `false()`, `null()` and `err()`.
* `match` boolean function.
* `variance` and `stDev` functions.
* `hash` function.
* `formatDate`, `parseDate` functions.
*  Made `substring` and `decode` functions capable of accepting functional parameters.
* `substringBefore`, `substringAfter`, `indexOf` and `lastIndexOf` functions.
* `countUnique` function.

### New XSLT Functions

Added XSLT functions (`source`, `sourceId`, `partNo`, `recordNo`, `lineFrom`, `colFrom`, `lineTo`, `colTo`) to determine the current source location so it can be embedded in a cooked event. Events containing raw source location info can be made into links in dashboard tables or the text pane so that a user can see raw source data or jump directly to stepping the raw record.

### Configuration Properties Improvements

#### Configuration is now provided by YAML files on boot

Previously _stroom_ used a flat `.conf` file to manage the application configuration.
Application logging was configured either via a `.yml` file (in v6) or in an `.xml` file (in v5).
Now _stroom_ uses a single `.yml` file to configure the application and logging.
This file is different to the `.yml` files(s) used in the docker compose configuration.
The YAML file provides a more logical hierarchical structure and support for typed values (longs, doubles, maps, lists, etc.).

The YAML configuration is intended for configuration items that are either needed to bootstrap _stroom_ or have values that are specific to a node.
Cluster wide configuration properties are still stored in the database and managed via the UI.

There has been a change to the precedence of the configuration properties held in different locations (YAML, database, default) and this is described in [Properties](user-guide/properties.md).

#### Stroom Home and relative paths

The concept of _Stroom Home_ has been introduced.
Stroom Home allows for one path to be configured and for all other configurable paths to default to being a child of this path.
This keeps all configured directories in one place by default.
Each configured directory can be set to an absolute path if a location outside Stroom Home is required.
If a relative path is used it will be relative to Stroom Home.
Stroom Home can be configured with the property `stroom.path.home`.

#### Improved _Properties_ UI screens that tell you the values over the cluster

Previously the _Properties_ UI screens could only tell you the values held within the database and not the value that a node was actually using.
The Properties screens have been improved to tell you the source of a property value and where multiple values exist across the cluster, which nodes have what values.
See [Properties](user-guide/properties.md).

#### Validation of Configuration Property Values

Validation of configuration property values is now possible.
The validation rules are defined in the application code and allow for things like:

* Ensuring that a regex pattern is a valid pattern
* Setting maximum or minimum values to numeric properties.
* Ensuring a property has a value.

Validation will be enforced on application boot or when a value is edited via the UI.

#### Hot Loading of Node Configuration

Now that node specific configuration is managed via the YAML configuration file _stroom_ will detect changes to this file and update the configuration properties accordingly.
Some properties however do not support being changed at runtime so will still require either the whole system or the UI nodes to be restarted.

### Data Retention Policies
Data retention is now controlled via a user defined policy that allows the specification of multiple filters.

#### Data retention impact summary

The _Data_Retention_ screen now provides an _Impact Summary_ tab that will show you a summary of what will be deleted by the current active rules.
The summary is based on the rules as they currently are in the UI, so it allows you to see the impact before saving rule changes.
The summary is a count of the number of streams that will be deleted by each rule, broken down by feed and stream type.
In very large systems with a lot of data or where complex rules are in place the summary may take a some time (minutes) to produce.

See [Data Retention](user-guide/data-retention.md) for more details.

### Fuzzy Finding in Quick Filters and Suggestion Text Fields

A richer fuzzy find algorithm has been added to the Quick filter search fields.
It has also been added to some text input fields with suggestion fields, e.g. _Feed Name_ input fields.
This makes finding values or rows in a table faster and more precise.

See [Finding Things](user-guide/finding-things/finding-things.md) for more details.

### New (off-heap) memory efficient reference data

The reference data feature in previous versions of _stroom_ loaded the reference data on demand and held it in Java's heap memory.
In large systems or where a pipeline doing reference data lookups across a wide time range this can lead to very large heap sizes.

In v7 _stroom_ now uses an off-heap, disk backed store ([LMDB](http://www.lmdb.tech/doc/)) for the reference data.
This removes all (with the exception of context lookups) from the Java heap, so the `-Xmx` value can be reduced.
In large systems this can mean keeping your `-Xmx` value below the 32Gb threshold to further reduce the memory usage.
Because the store is disk backed frequently used reference data can be kept in the store to reduce the loading overhead.
As the reference data is held off-heap it _stroom_ can make use of all available free RAM for the reference data.

See [Reference Data](user-guide/pipelines/reference-data.md)

#### Reference Data API

A RESTful API has been added for the reference data store.
This primarily allows reference lookups to be performed by external systems.

See [Reference Data API](user-guide/pipelines/reference-data.md#reference-data-api)

### Text editor improvements

The Ace text editor is used widely in Stroom for such things as editing XSLTs, editing dashboard column expressions, viewing stream data and stepping.
There have been a number of improvements to this editor.

See [Editing and Viewing Text Data](user-guide/editing-and-viewing.md)

#### Editor context menu

Additional options have been added to the context menu in the text editor:

* Toggle soft line wrapping of long lines.
* Toggle viewing hidden characters, e.g. tabs, spaces, line breaks.
* Toggle Vim key bindings. The Ace editor does not implement all Vim functionality but supports the core key bindings.
* Toggle auto-completion. Completion is triggered using `ctrl-space`.
* Toggle live auto-completion. Completion is triggered as you type.
* Toggle the inclusion of snippets in the auto-complete suggestions.

#### Auto-completion and snippets

Most editor screens now support basic auto-completion of existing words found in the text.
Some editor screens, such as XSLT, dashboard column expressions and Javascript scripts also support keyword and snippet completion.

### Data viewing improvements

The way data is viewed in Stroom has changed to improve the viewing of large files or files with no line breaks.
Previously a set number of lines of data would be fetched for display on the page in the Data Viewer.
This did not work for data that has no line breaks as Stroom would then try to fetch all data.

In v7 Stroom works at the character level so can fetch a reasonable number of characters for display whether they are all one line or spread over multiple lines.

The viewing of data has been separated into two mechanisms, _Data Preview_ and _Source View_.

See [Editing and Viewing Text Data](user-guide/editing-and-viewing.md)

#### Data Preview

This is the default view of the data.
It displays the first n characters (configurable) of the data.
It will attempt the format the data, e.g. showing pretty-printed XML.
You cannot navigate around the data.

#### Source View

This view is intended for seeing the actual data in its raw un-formatted form and for navigating around it.
This view provides navigation controls to define the range of data being display, e.g. from a character offset, line number or line and column.


### You can now query data, server tasks and processing tasks on dashboards

> TODO


### New Dashboard Data Sources
Dashboards can now be created to show data from the following internal sources:
* Annotations
* Stream meta data store
* Reference data
* Processor tasks
* System wide processes


### Index volume groups for easier index volume assignment

> TODO

### Kafka Integration

#### New Kafka Configuration Entity

Integration with Apache Kafka was introduced in v6 however the way the connection to Kafka cluster(s) is configured has been improved.
We have introduced a new entity type called _Kafka Configuration_ that can be created/managed via the explorer tree.
This means _stroom_ can integrate with many Kafka clusters or connect to a cluster using different sets of Kafka Configuration properties.
The Kafka Configuration entity provides an editor for setting all the Kafka specific configuration properties.
Pipeline elements that use Kafka now provide a means to select the Kafka Configuration to use.

> TODO Add user guide section on Kafka configuration

#### An Improved Pipeline Element for Sending Data to Kafka

The previous Kafka pipeline elements in v6 have been replaced with a single _StandardKafkaProducer_ element.
The new element allows for the dynamic construction of a Kafka Producer message via an XML document conforming to the _kafka-records_ XmlSchema.
With this new element events can be translated into kafka records which will be then given to the Kafka Producer to send to the Kafka Cluster.
This allows for complete control of things like timestamps, topics, keys, values, etc.

> TODO Add user guide section on Kafka Standard Producer


### No limitations on data reprocessing

> TODO

### Improved REST API

#### A rich REST API for all UI accessible functions

The architecture of the _stroom_ UI has been changed such that all communication between the UI and the back end is via REST calls.
This means all of these REST calls are available as an API for users of _stroom_ to take advantage of.
It opens up the possibility for interacting with _stoom_ via scripts or from other applications.

#### Swagger UI to document REST API methods

The Swagger UI and specification file have been improved to include all of the API methods available in stroom.

### Improved architecture with separate modules with individual DB access to spread load.

The architecture of the core stroom application has been fundamentally changed in v7 to internally break up the application into its functional areas.
This separation makes for a more logical code base and allows for the possibility of each functional area having its own database instance, if required.

### Java 12 

_stroom_ v7 now runs on the Java 12 JVM.

### MySQL 8 support.

_stroom_ v7 has been changed to support MySQL v8, opening up the possibility of using features like group replication.

### Search Result Storage
Search results are stored on disk rather than in memory during creation to reduce the memory overhead incurred by search.


---


## v6.1

> TODO


---


## v6.0

### OAuth 2.0/OpenID Connect authentication

Authentication for Stroom provided by an external service rather than a service internal to Stroom.
This change allows support for broader corporate authentication schemes and is a key requirement for enabling the future microservice architecture for Stroom.

### API keys for third party clients

Anyone wishing to make use of the data exposed by Stroom's services can request an API key.
This key acts as a password for their own applications.
It allows administrators to secure and manage access to Stroom's data.

### HBase backed statistics store

This new implementation of statistics (Stroom-Stats) provides a vastly more scalable time series DB for large scale collection of Stroom's data aggregated to various time buckets.
Stroom-Stats uses Kafka for ingesting the source data.

### Data receipt filtering

Data arriving in Stroom has meta data that can be matched against a policy so that certain actions can be taken.
This could be to receive, drop or reject the data.

Filtering of data also applies to Stroom proxy where each proxy can get a filtering policy from an upstream proxy or a Stroom instance.

### Data retention policies

The length of time that data will be retained in Strooms stream store can be defined by creating data retention rules.
These rules match streams based on their meta data and will automatically delete data once the retention period associated with the rule is exceeded.

### Dashboard linking

Links can be created in dashboards to jump to other dashboards or other external sites that provide additional contextual information.

### Search API

The search system used by Dashboards can be used via a restful API.
This provides access to data stored in search indices (including the ability to extract data) and statistics stores.
The data fetched via the search API can be received and processed via an external system.

### Kafka appender and filter

New pipeline elements for writing XML or text data to a Kafka topic.
This provides more options for using Stroom's data in other systems.

---

## v5.0

### Initial open source release

### Fine grained permissions for explorer items

Users can be added to user groups and individual users and groups can have various permissions (e.g.
Use, Read, Update, Delete) on individual items available in the explorer tree.

### Raw streaming

Data can be streamed in it's raw form from the stream store to multiple destinations without any transformation taking place.

### HDFS appender

Pipeline XML/text data can be writen out to a HDFS (Hadoop Distributed File System) cluster.
This increases the options for using Stroom's data for other purposes.

### Dashboard enhancements

Date and time operators can be used to specify times in search expressions.
These include constants such as `now()`, `second()`, `minute()`, `hour()`, `day()`, `week()`, `month()` and `year()`.
You can also perform simple date time artithmetic in expressions such as `day() - 2d` or `hour() - 30m`.

Dashboards can be configured to automatically run/query when they are opened and can also refresh on a configurable time interval.

Dashboards can use replacement variables in query expressions.
The value to use for any variable can be set for the whole dashboard in a text area at the top of the dashboard.
