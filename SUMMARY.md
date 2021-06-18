# Summary

### 1. Introduction

* [Introduction](README.md)
* [Release Notes](release-notes.md)
* [Screenshots](screenshots.md)
* [Quick-start guide](quick-start-guide/quick-start.md)
  * [Running](quick-start-guide/running/running.md)
  * [Getting data in](quick-start-guide/feed/feed.md)
  * [Processing the data](quick-start-guide/process/process.md)
  * [Indexing the data](quick-start-guide/index/index.md)
  * [Visualising the data](quick-start-guide/dashboard/dashboard.md)

### 2. Installation

* [Architecture & Deployment](install-guide/stroom-6-architecture.md)
* [Installing Stroom](install-guide/stroom-app-install.md)
* [Installing Stroom Proxy v7](install-guide/Stroom-7-Proxy-Installation.md)
* [Configuration](install-guide/configuration/configuration.md)
  * [Stroom](install-guide/configuration/configuring-stroom.md)
  * [Stroom-proxy](install-guide/configuration/configuring-stroom-proxy.md)
  * [MySQL](install-guide/configuration/configuring-mysql.md)
  * [Nginx](install-guide/configuration/configuring-nginx.md)
  * [Stroom-log-sender](install-guide/configuration/configuring-stroom-log-sender.md)
* Setup
  * [Apache forwarding](install-guide/setup/apache-forwarding.md)
  * [Java key store setup](install-guide/setup/java-key-store-setup.md)
  * [MySQL server setup](install-guide/setup/mysql-server-setup.md)
  * [Processing user setup](install-guide/setup/processing-user-setup.md)
  * [Securing Stroom](install-guide/setup/securing-stroom.md)
* [Upgrading and patching](install-guide/upgrade-patch.md)
  * [v6 to v7 Upgrade](install-guide/upgrades/6_to_7_upgrade.md)
* [Stroom 6 installation guide (DRAFT)](install-guide/stroom-6-installation.md)

### 3. User Guide

* [Concepts](user-guide/concepts/README.md)
  * [Streams](user-guide/concepts/streams.md)
* [Properties](user-guide/properties.md)
* [Nodes](user-guide/nodes.md)
* [Volumes](user-guide/volumes.md)
* [Jobs](user-guide/jobs.md)
* [Feeds](user-guide/feeds.md)
* [Finding Things](user-guide/finding-things/finding-things.md)
* [Editing and Viewing Text Data](user-guide/editing-and-viewing.md)
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
  * [Reference Data](user-guide/pipelines/reference-data.md)
* [Dashboards](user-guide/dashboards/README.md)
  * [Queries](user-guide/dashboards/queries.md)
  * [Dictionaries](user-guide/dashboards/dictionaries.md)
  * [Direct URLs](user-guide/dashboards/direct-urls.md)
  * [Expressions](user-guide/dashboards/expressions/README.md)
    * [Aggregate Functions](user-guide/dashboards/expressions/aggregate.md)
    * [Cast Functions](user-guide/dashboards/expressions/cast.md)
    * [Date Functions](user-guide/dashboards/expressions/date.md)
    * [Link Functions](user-guide/dashboards/expressions/link.md)
    * [Logic Functions](user-guide/dashboards/expressions/logic.md)
    * [Mathematics Functions](user-guide/dashboards/expressions/mathematics.md)
    * [Rounding Functions](user-guide/dashboards/expressions/rounding.md)
    * [Selection Functions](user-guide/dashboards/expressions/selection.md)
    * [String Functions](user-guide/dashboards/expressions/string.md)
    * [Type Checking Functions](user-guide/dashboards/expressions/type-checking.md)
    * [URI Functions](user-guide/dashboards/expressions/uri.md)
    * [Value Functions](user-guide/dashboards/expressions/value.md)
* [Data Retention](user-guide/data-retention.md)
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
* [Application Programming Interfaces (API)](user-guide/api/README.md)
  * [Query API](user-guide/api/query-api.md)
* [Tools](user-guide/tools/README.md)
  * [Command Line Tools](user-guide/tools/command-line.md)
  * [Stream Dump Tool](user-guide/tools/stream-dump-tool.md)

### 4. HOWTOs

* [Introduction](HOWTOs/StroomHowTos.md)
* General
  * [Feed Management](HOWTOs/General/FeedManagementHowTo.md)
  * [Tasks](HOWTOs/General/TasksHowTo.md)
  * [Raw Source Tracking](HOWTOs/General/RawSourceTracking.md)
* Authentication
  * [User Logout](HOWTOs/Authentication/UserLogoutHowTo.md)
  * [User Login](HOWTOs/Authentication/UserLoginHowTo.md)
  * [Create User](HOWTOs/Authentication/CreateUserHowTo.md)
* Install
  * [Nodes](HOWTOs/Install/InstallNodesHowTo.md)
  * [Database](HOWTOs/Install/InstallDatabaseHowTo.md)
  * [Install](HOWTOs/Install/InstallHowTo.md)
  * [Processing User Setup](HOWTOs/Install/InstallProcessingUserSetupHowTo.md)
  * [NFS](HOWTOs/Install/InstallNFSHowTo.md)
  * [Testing](HOWTOs/Install/InstallTestingHowTo.md)
  * [Proxy](HOWTOs/Install/InstallProxyHowTo.md)
  * [Volumes](HOWTOs/Install/InstallVolumesHowTo.md)
  * [Httpd](HOWTOs/Install/InstallHttpdHowTo.md)
  * [Certificates](HOWTOs/Install/InstallCertificatesHowTo.md)
  * [Application](HOWTOs/Install/InstallApplicationHowTo.md)
* Event Feeds
  * [Event Processing](HOWTOs/EventFeeds/ProcessingHowTo.md)
  * [Apache HTTPD Event Feed](HOWTOs/EventFeeds/CreateApacheHTTPDEventFeed.md)
* Reference Feeds
  * [Create Reference Feed](HOWTOs/ReferenceFeeds/CreateSimpleReferenceFeed.md)
* Administration
  * [System Properties](HOWTOs/Administration/SystemProperties.md)
* Indexing and Search
  * [Search API using bash](HOWTOs/Search/SearchFromBash.md)
  * [Elasticsearch integration](HOWTOs/Search/Elasticsearch.md)
  * [Solr integration](HOWTOs/Search/Solr.md)


### 5. Stroom Proxy

* [Installing Stroom proxy](proxy/install.md)
* [Docker](proxy/docker.md)
* [Apache forwarding](proxy/apache-forwarding.md)

### 6. Developer Guide

* [Developer guide](dev-guide/README.md)
  * [Contributing](CONTRIBUTING.md)
  * [Releasing](dev-guide/releasing.md)
  * [Running Stroom from IntelliJ](dev-guide/stroom-in-an-ide.md)
  * [Running Stroom using Docker](dev-guide/docker-running.md)
  * [Components](dev-guide/components.md)
  * [Building GitBook documentation](dev-guide/gitbook.md)

### 7. About Stroom-docs

* [Change log](CHANGELOG.md)
* [Version information](VERSION.md)
* [Building stroom-docs](gitbook.md)
