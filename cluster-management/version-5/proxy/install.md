# Stroom Proxy Install

## Prerequisites

- Linux Server's with at least 4GB RAM
- Install files stroom-proxy-X-Y-Z-distribution.zip, stroom-deploy-X-Y-Z-distribution.zip
- Temporarily allow port 9080 if not relying on Apache Forwarding (see below)

## Processing User Setup

See [Processing User Setup](../processing-user-setup.md).

## Installing Stroom Proxy

As the processing user unpack the stroom-proxy-X-Y-Z-distribution.zip installation files
in the processing users home directory.

```bash
unzip stroom-proxy-X-Y-Z-distribution.zip
```
 
Stroom Proxy can be setup as follows:

- forward - as an aggregation point to store and forwarding onto another Stroom or Stroom / Proxy
- store - to front Stroom for data ingest
 

### Stroom Proxy - forward

In forward mode you need to know the server address that data is being sent onto.
Run the setup script to capture the basic settings required to run Stroom Proxy in forward mode.

- @@ NODE @@ - Each Stroom instance in the cluster needs a unique name, if this is a reinstall ensure you use the previous deployment.
**This name needs match the name used in your worker.properties (e.g. 'node1' in the case 'node1.my.org')** 
- @@ PORT PREFIX @@ - By default Stroom Proxy will run on port 9080

```bash
[stroomuser@node1 ~]$ ./stroom-proxy/bin/setup.sh forward

[stroomuser@dev1 ~]$ ./stroom-proxy/bin/setup.sh forward





...

Parameters
==========

@@NODE@@           : Unique node name for install [node1                                                     ] : node1
@@PORT_PREFIX@@    : HTTP prefix to use           [90                                                        ] : 90
@@REPO_DIR@@       : Stroom Proxy Repository Dir     [/stroomdata/stroom-proxy                                        ] : /home/stroomuser/stroom-proxy-repo
@@FORWARD_SERVER@@ : Server to forward data on to [hostname                                                  ] : audit.my.org
@@JAVA_OPTS@@      : Optional tomcat JVM settings ["-Xms512m -Xmx1g"                                         ] :

...
```   
    
### Stroom Proxy - store

In store mode you need to know the mysql details to validate incoming data with.

```bash
[stroomuser@node1 ~]$ ./stroom-proxy-app/bin/setup.sh store

...

@@NODE@@           : Unique node name for install            [node                                                      ] :
@@PORT_PREFIX@@    : HTTP prefix to use                      [90                                                        ] : 72
@@REPO_DIR@@       : Stroom Proxy Repository Dir                [/stroomdata/stroom-proxy                                        ] : /home/stroomuser/stroom-proxy-repo-2
@@JDBC_CLASSNAME@@ : JDBC class name                         [com.mysql.jdbc.Driver                                     ] :
@@JDBC_URL@@       : JDBC URL (jdbc:mysql://[HOST]/[DBNAME]) [jdbc:mysql://localhost/stroom                                ] :
@@DB_USERNAME@@    : Database username                       [                                                          ] : stroomuser
@@DB_PASSWORD@@    : Database password                       [                                                          ] :
@@JAVA_OPTS@@      : Optional tomcat JVM settings            ["-Xms512m -Xmx1g"                                         ] :
```

### Install Check

Start the installed instance:

```bash
./stroom-deploy/start.sh
```

Inspect the logs: 

```bash
tail -f stroom-proxy-app/instance/logs/stroom.log
```

### Stroom Proxy Properties
The following properties can be configured in the stroom.properties file.

TODO - Could do with a column indicating which proxy mode these properties apply to, e.g. store/forward

Property Name               | Description
-------------               | -----------
repoDir                     | Optional Repository DIR. If set any incoming request will be written to the file system.
logRequest                  | Optional log line with header attributes output as defined by this property
bufferSize                  | Override default (8192) JDK buffer size to use
forwardUrl                  | Optional The URL's to forward onto This is pass-through mode if repoDir is not set
forwardThreadCount          | Number of threads to forward with
forwardTimeoutMs            | Time out when forwarding
forwardChunkSize            | Chunk size to use over http(s) if not set requires buffer to be fully loaded into memory
rollCron                    | Interval to roll any writing repositories.
readCron                    | Cron style interval (e.g. every hour '0 * *', every half hour '0,30 * *') to read any ready repositories (if not defined we read all the time).
maxAggregation              | Aggregate size to break at when building an aggregate.
zipFilenameDelimiter        | The delimiter used to separate the id ihe zip filename from the templated part
zipFilenameTemplate         | A template for naming the zip files in the repository where files will be named nnn!zipFilenameTemplate.zip where nnn is the id prefix, ! is the configurable delimiter and zipFilenameTemplate will be something like '${feed}!${headerMapKey1}!${headerMapKey2}'. The naem of each variable must exactly match a key in the meta data else it will resolve to ''.
requestDelayMs              | Sleep time used to aid with testing
forwardDelayMs              | Debug setting to add a delay
dbRequestValidatorContext   | Database Feed Validator - Data base JDBC context
dbRequestValidatorJndiName  | Database Feed Validator - Data base JDBC JNDI name
dbRequestValidatorFeedQuery | Database Feed Validator - SQL to check feed status
dbRequestValidatorAuthQuery | Database Feed Validator - SQL to check authorisation required
remotingUrl                 | Url to use for remoting services
remotingReadTimeoutMs       | Change from the default JVM settings.
remotingConnectTimeoutMs    | Change from the default JVM settings.
maxStreamSize               | Stream size to break at when building an aggregate.
maxFileScan                 | Max number of files to scan over during forwarding.  Once this limit is it it will wait until next read interval
cacheTimeToIdleSeconds      | Time to idle settings to used for validating feed information
cacheTimeToLiveSeconds      | Time to live settings to used for validating feed information


## Apache Forwarding

See [Apache Forwarding](../apache-forwarding.md).

## Java Key Store Setup

If you require that Stroom Proxy communicates over 2-way https you will need to set up Java Key Stores.

See [Java Key Store Setup](../java-key-store-setup.md).

## Securing Stroom

See [Securing Stroom](../securing-stroom.md).


   
