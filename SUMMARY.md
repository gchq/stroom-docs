# Summary

### 1. Introduction

* [Introduction](README.md)
* [Screenshots](screenshots.md)
* [Quick-start guide](quick-start-guide/quick-start.md)

### 2. Installation

* [Installing Stroom](install-guide/stroom-app-install.md)
* Setup
  * [Apache forwarding](install-guide/setup/apache-forwarding.md)
  * [Java key store setup](install-guide/setup/java-key-store-setup.md)
  * [MySQL server setup](install-guide/setup/mysql-server-setup.md)
  * [Processing user setup](install-guide/setup/processing-user-setup.md)
  * [Securing Stroom](install-guide/setup/securing-stroom.md)
* [Upgrading and patching](install-guide/upgrade-patch.md)

### 4. User Guide

  * [Nodes](user-guide/nodes.md)
  * [Volumes](user-guide/volumes.md)
  * [Tasks](user-guide/tasks.md)
  * [Feeds](user-guide/feeds.md)
  * [Roles and permissions](user-guide/roles.md)
  * [Sending data to Stroom](user-guide/sending-data/README.md)
    * [Header Arguments](user-guide/sending-data/header-arguments.md)
    * [Payloads](user-guide/sending-data/payloads.md)
    * [Response codes](user-guide/sending-data/response-codes.md)
    * [Example clients](user-guide/sending-data/example-clients.md)
    * [SSL Java keystores](user-guide/sending-data/java-keystores.md)
    * [SSL configuration](user-guide/sending-data/ssl.md)
  * [Pipelines](user-guide/pipelines/README.md) 
    * [Parser](user-guide/pipelines/parser/README.md)
      * [XML fragments](user-guide/pipelines/parser/xml-fragments.md)
      * [Context data](user-guide/pipelines/parser/context-data.md)
    * [XSLT](user-guide/pipelines/xslt/README.md)
      * [XSLT includes](user-guide/pipelines/xslt/xslt-includes.md)
      * [XSLT functions](user-guide/pipelines/xslt/xslt-functions.md)
    * [File output](user-guide/pipelines/file-output.md)
  * [Dashboards](user-guide/dashboards/README.md)
    * [Queries](user-guide/dashboards/queries.md)
    * [Dictionaries](user-guide/dashboards/dictionaries.md)
  * [Security](user-guide/security.md)
  * Data splitter
    * [Introduction](datasplitter/1-0-introduction.md)
      * [Simple CSV example](datasplitter/1-1-simple-csv-example.md)
      * [Simple CSV example with heading](datasplitter/1-2-simple-csv-example-with-heading.md)
      * [Complex example with regex and user defined names](datasplitter/1-3-complex-example.md)
      * [Multi-line example](datasplitter/1-4-multi-line-example.md)
    * [Element reference](datasplitter/2-0-element-reference.md)
      * [Content providers](datasplitter/2-1-content-providers.md)
      * [Expressions](datasplitter/2-2-expressions.md)
      * [Variables](datasplitter/2-3-variables.md)
      * [Output](datasplitter/2-4-output.md)
    * [Match references, variables and fixed strings](datasplitter/3-0-match-references.md)
      * [Expression match references](datasplitter/3-1-expression-match-references.md)
      * [Variable reference](datasplitter/3-2-variable-reference.md)
      * [Use of fixed strings](datasplitter/3-3-use-of-fixed-strings.md)
      * [Concatenation of references](datasplitter/3-4-concatenation-of-references.md)

### 6. Stroom Proxy

* [Installing Stroom proxy](proxy/install.md)
* [Docker](proxy/docker.md)
* [Apache forwarding](proxy/apache-forwarding.md)

### 7. Developer Guide

* [Developer guide](dev-guide/README.md)
  * [Releasing](dev-guide/releasing.md)
  * [Running Stroom from IntelliJ](dev-guide/stroom-in-an-ide.md)
  * [Running Stroom using Docker](dev-guide/docker-running.md)
  * [Building a Stroom Docker image](dev-guide/docker-building.md)
  * [Building GitBook documentation](dev-guide/gitbook.md)
