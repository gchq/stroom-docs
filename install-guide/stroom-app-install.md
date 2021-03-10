> *NOTE* This document was written for stroom v4/5. It is not applicable for v6+.

# Stroom Install

## Prerequisites

* Install file 'stroom-app-distribution-X-Y-Z-bin.zip'. All the pre-built binaries are [available on GitHub](https://github.com/gchq/stroom/releases)
* MySQL Server 5.5
* JDK8
* Temporarily allow port 8080, if not relying on Apache Forwarding. 

## Installing Stroom

Unpack the distribution `stroom-app-distribution-X-Y-Z-bin.zip`:

```bash
unzip stroom-app-distribution-X-Y-Z-bin.zip
```

In `bin` are scripts for configuring and starting and stopping Stroom. 

### Configuring 

The `setup.sh` script will ask a series of questions to help you configure Stroom.

```bash
./bin/setup.sh
```

This script asks a series of questions about configuration parameters. These parameters are:

* **TEMP_DIR** - This is where Stroom will write some temporary files, e.g. imports/exports. Only change this if you do not want to use '/tmp'.
* **NODE** - Each Stroom instance in the cluster needs a unique name, if this is a reinstall ensure you use the previous deployment.
  **This name needs match the name used in your worker.properties (e.g. 'node1' in the case 'node1.my.org')** 
* **RACK** - Used to group nodes together (so for example nodes near each other process near data)
* **PORT_PREFIX** - By default Stroom will run on port 8080
* **JDBC_CLASSNAME**, **JDBC URL**, **DB USERNAME**, **DB PASSWORD** - MySQL connection details for the **stroom** database
* **JPA DIALECT** - Leave blank to use MySQL
* **JAVA OPTS** - By default this is '-Xms1g -Xmx8g'. Stroom performs better if you use most of the servers memory so change the maximum memory setting (Xmx) accordingly, e.g. -Xmx40g will use 40 GB.
* **STROOM_STATISTICS_SQL_JDBC_CLASSNAME**, **STROOM_STATISTICS_SQL_JDBC URL**, **STROOM_STATISTICS_SQL_DB USERNAME**, **STROOM_STATISTICS_SQL_DB PASSWORD** - MySQL connection details for the **statistics** database

### Running 

Start the configured instance:

```bash
./bin/start.sh
```

Inspect the logs:

```bash
tail -f instance/logs/stroom.log
```

### Other things to configure:

You might want to configure some of the following:

* [Processing User Setup](setup/processing-user-setup.md)
* [MySQL Server Setup](setup/mysql-server-setup.md)
* [Java Key Store Setup](setup/java-key-store-setup.md)
* [Apache Forwarding](setup/apache-forwarding.md)
* [Securing Stroom](setup/securing-stroom.md)
