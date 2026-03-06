---
title: "Stroom Proxy Configuration"
linkTitle: "Stroom Proxy Configuration"
#weight:
date: 2021-06-23
tags: 
  - proxy
description: >
  Describes how the Stroom-Proxy application is configured.
---

{{% see-also %}}
[Stroom and Stroom-Proxy Common Configuration]({{< relref "common-configuration" >}})  
[Stroom Properties]({{< relref "/docs/user-guide/properties.md" >}})
{{% /see-also %}}


The configuration of Stroom-proxy is very much the same as for Stroom with the only difference being the structure of the application specific part of the `config.yml` file.
Stroom-proxy has a `proxyConfig` key in the YAML while Stroom has `appConfig`.


## YAML Configuration File

The Stroom-proxy application is essentially just an executable {{< external-link "JAR" "https://en.wikipedia.org/wiki/JAR_%28file_format%29" >}} file that can be run when provided with a configuration file, `config.yml`.
This configuration file is common to all forms of deployment.

As Stroom-proxy does not have a user interface, the `config.yml` file is the only way of configuring Stroom-Proxy.
As with stroom, the `config.yml` file is split into three sections using these keys:

* `server` - Configuration of the web server, e.g. ports, paths, request logging.
  See [Server Configuration]({{< relref "common-configuration#server-configuration" >}})

* `logging` - Configuration of application logging.
  See [Logging Configuration]({{< relref "common-configuration#logging-configuration" >}})

* `proxyConfig` - Stroom-Proxy specific configuration

See also [Properties]({{< relref "/docs/user-guide/properties.md" >}}) for more details on structure of the config.yml file and supported data types.

Stroom-Proxy operates on a configuration by exception basis so as far as is possible, all configuration properties will have a sensible default value and a property only needs to be explicitly configured if the default value is not appropriate (e.g. for tuning a large scale production deployment) or where values are environment specific (e.g. the hostname of a forward destination).

As a result the `config.yml` shipped with Stroom Proxy only contains a minimal set of properties.
The full tree of properties can be seen in `./config/config-defaults.yml` and a schema for the configuration tree (along with descriptions for each property) can be found in `./config/config-schema.yml`.
These two files can be used as a reference when configuring stroom.

In the snippets of YAML configuration below, the defaultsections 


### Basic Structure

Stroom-proxy has a number of [key functions]({{< relref "docs/proxy/proxy-functions" >}}) which are all configured via its YAML configuration file.

Each branch of the this YAML is explained in more detail below.

```yaml
proxyConfig:

  # This should be set to a value that is unique within your Stroom/Stroom-Proxy estate.
  # It is used in the unique ReceiptId that is set in the meta of received data so
  # provides provenence of where data was received at each stage.
  proxyId: null

  # If true, Stroom-Proxy will halt on start up if any errors are found in the YAML
  # configuration file. If false, the errors will simply be logged. Setting this to
  # false is not advised
  haltBootOnConfigValidationFailure: true

  # Configuration of the base and temp paths used by Stroom-Proxy.
  # See Path Configuration below
  path:

  # This is the downstream (in flow of stream data terms) Stroom/Stroom-Proxy instance/cluster
  # used for feed status checks, supplying data receipt rules and verifying API keys.
  downstreamHost:

  # This controls the aggregation of received data into larger chunks prior to forwarding.
  # This is typically required to prevent Stroom receiving lots of small streams.
  aggregator:

  # If receive.receiptCheckMode is FEED_STATUS, this controls the feed status
  # checking. See Feed Status Configuration below.
  feedStatus:

  # Zero to many HTTP POST based destinations.
  # E.g. for forwarding to Stroom or another Stroom-Proxy
  forwardHttpDestinations:

  # Zero to many file system based destinations. See Forward Configuration below.
  forwardFileDestinations:

  # This controls the meta entries that will be included in the send and receive logs.
  logStream:

  # If receive.receiptCheckMode is RECEIPT_POLICY, this controls the fetching
  # of the policy rules.
  receiptPolicy:

  # This section is common to both Stroom and Stroom-Proxy
  # See Receive Configuration below.
  receive:

  # Configuration for authentication. See Security Configuration below.
  security:
```

Stroom-proxy should be configured to check the receipt status of feeds on receipt of data.
This is done by configuring the end point of a downstream stroom-proxy or stroom.

```yaml
  feedStatus:
    url: "http://stroom:8080/api/feedStatus/v1"
    apiKey: ""
```

The `url` should be the url for the feed status API on the downstream stroom(-proxy).
If this is on the same host then you can use the http endpoint, however if it is on a remote host then you should use https and the host of its nginx, e.g. `https://downstream-instance/api/feedStatus/v1`.

In order to use the API, the proxy must have a configured `apiKey`.
The API key must be created in the downstream stroom instance and then copied into this configuration.

If the proxy is configured to forward data then the forward destination(s) should be set.
This is the `datafeed` endpoint of the downstream stroom-proxy or stroom instance that data will be forwarded to.
This may also be the address of a load balancer or similar that is fronting a cluster of stroom-proxy or stroom instances.
See also [Feed status certificate configuration](#feed-status-certificate-configuration).

```yaml
  forwardHttpDestinations:
    - enabled: true
      name: "downstream"
      forwardUrl: "https://some-host/stroom/datafeed"
```

`forwardUrl` specifies the URL of the _datafeed_ endpoint on the destination host.
Each forward location can use a different key/trust store pair.
See also [Forwarding certificate configuration](#forwarding-certificate-configuration).

If the proxy is configured to store then the location of the proxy repository may need to be configured if it needs to be in a different location to the proxy home directory, e.g. on another mount point.


### Aggregator Configuration

```yaml
proxyConfig:
  aggregator:
    enabled: true
    # Whether to split received ZIPs if they are too large.
    splitSources: true
    # Maximum number of items to include in an aggregate
    maxItemsPerAggregate: 1000
    # Maximum size of the aggregate in uncompressed bytes.
    # Aggregates may be larger than this is splitSources is false or single very
    # large streams are received.
    maxUncompressedByteSize: "1G"
    #The the length of time that data is added to an aggregate for before the aggregate is closed.
    aggregationFrequency: "PT10M"
```

{{% note %}}
The `aggregator` settings apply to **all** forwarders.
It is not possible for forwarders to to use different aggregation settings.

If you need to forward to a HTTP destination but also want to forward to a file destination using different aggregator settings, e.g. to keep a local archive of the data, you would need to employ a second Stroom-Proxy.
Stroom-Proxy A would forward to the HTTP downstream and forward to Stroom-Proxy B over HTTP.
Stroom-Proxy B would forward to a file destination, using much larger aggregator thresholds.
{{% /note %}}


### Directory Scanner Configuration

This configuration controls the directories that Stroom-Proxy scans to look for ZIP files to ingest.
It is primarily used as a means of manually re-processing files that have failed to forward, either as a result of too many retries or due to an unrecoverable error.

```yaml
proxyConfig:
  dirScanner:
    # One or more directories to scan.
    # If the path is relative it is treated as relative to the proxyConfig.path.home property.
    dirs:
    - "zip_file_ingest"
    # Whether directory scanning is enabled or not
    enabled: true
    # The directory to move any failed files to.
    # If the path is relative it is treated as relative to the proxyConfig.path.home property.
    failureDir: "zip_file_ingest_failed"
    # How frequently each directory is scanned for files.
    scanFrequency: "PT1M"
```


### Downstream Host Configuration

This is the default downstream (in flow of stream data terms) Stroom/Stroom-Proxy instance/cluster used for feed status checks, supplying data receipt rules and verifying API keys.


By default it will be used as the default

```yaml
proxyConfig:
  downstreamHost:
    # http or https
    scheme: "https"
    # If not set, will default to 80/443 depending on scheme
    port: 443
    hostname: "...STROOM-PROXY OR STROOM FQDN..."
    # If not using OpenID authentication you will need to provide an API key.
    apiKey: "sak_6a011e3e5d_oKimmDxfNwj......<truncated>.....HYQxHaR2"
```


### Event Store Configuration

The Event Store is used to store and aggregate individual events received via the `/api/event` {{< glossary "API" >}} or the SQS Connectors.
Events are appended to files specific to the Feed and Stream Type of the event.
Once a threshold is reached, the file will be rolled and processed by Stroom-Proxy.

Each event is stored as a JSON line in the file.

```yaml
proxyConfig:
  eventStore:
    # The size of an internal queue used to buffer aggregates that are ready to process.
    forwardQueueSize: 1000
    # The maximum age of the file before it is rolled.
    maxAge: "PT1M"
    # The maximum size of the file before it is rolled.
    maxByteCount: 9223372036854775807
    # The maximum number of events in the file before it is rolled.
    maxEventCount: 9223372036854775807
    # Configuration of the cache used for the event store.
    openFilesCache:
    # The frequency at which files are checked to see if they need to be rolled or not.
    rollFrequency: "PT10S"
```


### Feed Status Configuration

The configuration for performing feed status checks.
This section is only relevant if `proxyConfig.receive.receiptCheckMode` is set to `FEED_STATUS`.

```yaml
proxyConfig:
  feedStatus:
    # Standard cache configuration block for configuring the cache of feed status check outcomes
    feedStatusCache:
    # The full URL to use for feed status checking.
    # ONLY set this if using a non-standard URL, otherwise
    # it will be derived from the downstreamHost.
    url: null
```

The configuration of the client certificates for feed status checks is done using the `DOWNSTREAM` jersey client configuration.
See [Stroom and Stroom-Proxy Common Configuration]({{< relref "common-configuration#jersey-http-client-configuration" >}}).


### Forward Configuration

Stroom-Proxy has two configuration branches for controlling forwarding as each has a different structure.

```yaml
proxyConfig:
  # Zero to many HTTP POST based destinations.
  forwardHttpDestinations:
  # Zero to many file system based destinations.
  forwardFileDestinations:
```

Both types of forwarder have an `enabled` property.
If a forwarder's `enabled` state is set to `false` it is as if the forwarder configuration does not exist, i.e no data will be queued for that forwarder until its state is changed to `true`.


#### File Forward Destinations Configuration

```yaml
proxyConfig:
  # Zero to many file system based destinations.
  forwardFileDestinations:
    # Stroom-Proxy will attempt to move files onto the forward destination using an atomic move.
    # This ensures that the move does not happen more than once. If an atomic move is not possible,
    # e.g. the destination is a remote file system that does not support an atomic move, then it will
    # fall back to a non-atomic move with the risk of it happening more than once. If you see warnings
    # in the logs or know the file system will not support atomic moves then set this to false
  - atomicMoveEnabled: true
    # Whether this destination is enabled or not.
    enabled: true
    # If Instant Forwarding is to be used.
    instant: false
    # The type of liveness check to perform:
    # READ - will attempt to read the file/dir specified in livenessCheckPath. 
    # WRITE - will attempt to touch the file specified in livenessCheckPath.
    livenessCheckMode: "READ"
    # The path to use for regular liveness checking of this forward destination.
    # If null, empty or if the 'queue' property is not configured, then no liveness check
    # will be performed and the destination will be
    # assumed to be healthy. If livenessCheckMode is READ, livenessCheckPath can be a
    # directory or a file and stroom-proxy will attempt to check it can read the
    # file/directory. If livenessCheckMode is WRITE, then livenessCheckPath must be a
    # file and stroom-proxy will attempt to touch that file. It is
    # only recommended to set this property for a remote file system where
    # connection issues may be likely. If it is a relative path, it will be assumed
    # to be relative to 'path'
    livenessCheckPath: null
    # The unique name of the destination (across all file/http forward destinations.
    # The name is used in the directories on the file system, so do not change the name
    # once proxy has processed data. Must be provided.
    name: "...PROVIDE FORWARDER NAME..."
    # The base path of a directory to forward to.
    path: "...PROVIDE PATH..."
    # See Queue Configuration section below
    queue:
    # The templated relative sub-path of path.
    # The default path template is '${year}${month}${day}/${feed}'
    # Cannot be an absolute path and must resolve to a descendant of path.
    # Fore details of this configuration branch, see Path Templating Configuration below.
    subPathTemplate: null
```


#### HTTP Forward Destinations Configuration

```yaml
proxyConfig:
  # Zero to many HTTP POST based destinations.
  forwardHttpDestinations:
    # If true, add Open ID authentication headers to the request. Only works if the identityProviderType
    # is EXTERNAL_IDP and the destination is in the same Open ID Connect realm as the OIDC client that this
    # proxy instance is using.
  - addOpenIdAccessToken: false
    # The API key to use when forwarding data if Stroom is configured to require an API key.
    # Does NOT use the API Key from downstreamHost config.
    apiKey: null
    # Whether this destination is enabled or not.
    enabled: true
    forwardHeadersAdditionalAllowSet: []
    # The full URL to forward to if different from <downstreamHost>/datafeed
    forwardUrl: null
    # Configuration of the HTTP client, see below.
    httpClient:
    # If Instant Forwarding is to be used.
    instant: false
    # Whether liveness checking of the HTTP destination will take place. The queue property
    # must also be configured for liveness checking to happen
    livenessCheckEnabled: true
    # The URL/path to check for liveness of the forward destination. The URL should return a 200 response
    # to a GET request for the destination to be considered live.
    # If the response from the liveness check is not a 200, forwarding
    # will be paused at least until the next liveness check is performed.
    # If this property is not set, the downstreamHost configuration will be combined with the default API
    # path (/status).
    # If this property is just a path, it will be combined with the downstreamHost configuration.
    # Only set this property if you wish to use a non-default path.
    # or you want to use a different host/port/scheme to that defined in downstreamHost
    livenessCheckUrl: null
    # The unique name of the destination (across all file/http forward destinations.
    # The name is used in the directories on the file system, so do not change the name
    # once proxy has processed data. Must be provided.
    name: "...PROVIDE FORWARDER NAME..."
    # See Queue Configuration section below
    queue:
```

#### Queue Configuration

Each forward destination (whether file or HTTP) has a `queue` configuration property that controls various aspects of forwarding, e.g. failure handling, delays, concurrency, etc.

```yaml
  forwardHttpDestinations / forwardFileDestinations:
    queue:
      # The sub-path template to use for data that could not be retried
      # or has reached a retry limit.
      errorSubPathTemplate:
        enabled: true
        pathTemplate: "${year}${month}${day}/${feed}"
        templatingMode: "REPLACE_UNKNOWN_PARAMS"
      # A delay to add before forwarding. Primarily for testing.
      forwardDelay: "PT0S"
      # Number of threads to process retries
      forwardRetryThreadCount: 1
      # Number of threads to handle forwarding
      forwardThreadCount: 5
      # Duration between liveness checks
      livenessCheckInterval: "PT1M"
      # The maximum time from the first failed forward attempt to continue retrying.
      # After this the data will be move to the failure directory permenantly.
      maxRetryAge: "P7D"
      # The maximum time between retries. Must be greater than or equal to retryDelay.
      maxRetryDelay: "P1D"
      # If false forwards will be attempted imediately and any failure will restult in the
      # data being moved to the failure directory.
      queueAndRetryEnabled: false
      # The time between retries. If retryDelayGrowthFactor is >1, this value will grow
      # after each retry.
      retryDelay: "PT10M"
      # The factor to apply to retryDelay after each failed retry.
      retryDelayGrowthFactor: 1.0
```


#### Path Templating Configuration

The following properties all share the same structure:

* `proxyConfig.forwardFileDestinations.[n].subPathTemplate`
* `proxyConfig.forwardFileDestinations.[n].queue.errorSubPathTemplate`
* `proxyConfig.forwardHttpDestinations.[n].queue.errorSubPathTemplate`

```yaml
  xxxxxxTemplate:
    # Whether templating is enabled or not. If not enabled
    # no sub-path will be used.
    enabled: true
    # The template to use for the sub-path
    pathTemplate: "${year}${month}${day}/${feed}"
    # Controls how unknown parameters are dealt with. One of:
    # IGNORE_UNKNOWN_PARAMS - e.g. 'cat/${unknownparam}/dog' => 'cat/${unknownparam}/dog'
    # REMOVE_UNKNOWN_PARAMS - e.g. 'cat/${unknownparam}/dog' => 'cat/dog'
    # REPLACE_UNKNOWN_PARAMS - Replace unknown with 'XXX', e.g. 'cat/${unknownparam}/dog' => 'cat/XXX/dog'
    templatingMode: "REPLACE_UNKNOWN_PARAMS"
```

The following template parameters are supported:

* `${feed}` - The Feed name.
* `${type}` - The Stream Type.
* `${year}` - The 4 digit year of the current date/time.
* `${month}` - The 2 digit month of the current date/time.
* `${day}` - The 2 digit day of the current date/time.
* `${hour}` - The 2 digit hour of the current date/time.
* `${minute}` - The 2 digit minute of the current date/time.
* `${second}` - The 2 digit second of the current date/time.
* `${millis}` - The 3 digit milliseconds of the current date/time.
* `${ms}` - The current date/time as milliseconds since the Unix Epoch.


#### Liveness Checking

Each of the configured forward destinations has a liveness check that can be configured.
This allows Stroom Proxy to periodically check that the destination is _live_.
If the liveness check fails for a destination, all forwarding for that destination will be paused until a subsequent liveness check reports it as _live_ again.

The liveness checks take the following forms:

* HTTP Destination - Performs a `GET` request to the URL configured using `forwardHttpDestinations.[n].livenessCheckUrl`.
  If not configured it will use `/status` on the downstream host.
  The destination is considered live if it gets a `200` response.
  You can use a URL that allows the destination to control its liveness, i.e. to take itself off line during an upgrade.

* File Destination - Reads or writes (`touch`) to a file defined by `forwardFileDestinations.[n].livenessCheckPath`.
  Liveness checking for a file destination may be useful if the destination is on a network file share.
  `livenessCheckMode` controls whether a read or write to the file is performed.


#### HTTP Client Configuration

```yaml
proxyConfig:
  forwardHttpDestinations:
    httpClient:
      connectionRequestTimeout: "PT3M"
      connectionTimeout: "PT3M"
      cookiesEnabled: false
      keepAlive: "PT0S"
      maxConnections: 1024
      maxConnectionsPerRoute: 1024
      proxy: null
      retries: 0
      timeToLive: "PT1H"
      timeout: "PT3M"
      # Transport Layer Security, see below.
      tls: null
      userAgent: null
      validateAfterInactivityPeriod: "PT0S"
```

The `tls` branch of the configuration is for configuring Transport Layer Security (the successor to Secure Sockets Layer (SSL)).
It is `null` by default, i.e. no additional TLS configuration is used.
Its structure is:

```yaml
proxyConfig:
  forwardHttpDestinations:
    httpClient:
      tls:
        protocol: "TLSv1.2"
        # The name of the JCE provider to use on client side for cryptographic support 
        # (for example, SunJCE, Conscrypt, BC, etc). See Oracle documentation for more information.
        provider:
        # The path of the key store file
        keyStorePath: null
        # The password of the key store file
        keyStorePassword: null
        # The type of key store (usually JKS, PKCS12, JCEKS, Windows-MY, or Windows-ROOT).
        keyStoreType: "JKS"
        keyStoreProvider: null
        # The path of the trust store file
        trustStorePath: null
        # The password of the trust store file
        trustStorePassword: null
        # The type of trust store (usually JKS, PKCS12, JCEKS, Windows-MY, or Windows-ROOT).
        trustStoreType: "JKS"
        trustStoreProvider: null
        trustSelfSignedCertificates: false
        verifyHostname: false
        # Zero to protocols (e.g., SSLv3, TLSv1) which are supported.
        # All other protocols will be refused.
        supportedProtocols: null
        # A list of cipher suites (e.g., TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA256) which are supported.
        # All other cipher suites will be refused.
        supportedCiphers: null
        certAlias: null
```


### Log Stream Configuration

This controls the meta entries that will be included in the send and receive logs.

```yaml
proxyConfig:
  logStream:
    # The headers attributes that will be output in the send/receive log lines.
    # They will be output in the order that they appear in this list.
    # Duplicates will be ignored, case does not matter.
    metaKeys:
      - "guid"
      - "receiptid"
      - "feed"
      - "system"
      - "environment"
      - "remotehost"
      - "remoteaddress"
      - "remotedn"
      - "remotecertexpiry"
```


### Path Configuration

```yaml
proxyConfig:
  path:
    # By default all files read or written to by stroom-proxy will be in directories relative to
    # the home location. Ideally this should differ from the location of the Stroom Proxy
    # installed software as it has a different lifecycle.
    # If not set the location of the Stroom-Proxy application JAR file will be used and if that
    # can't be determined, <user's home>/.stroom will be used.
    home: "...SET TO AN ABSOLUTE PATH..."
    # The location for Stroom-Proxy's persisted data
    data: "data"
    # The location for any temporary files/directories.
    # If not set, will use a sub-directory called 'stroom-proxy' in the system temp dir,
    # i.e. as defined by 'java.io.tmpdir'.
    temp: null
```

All paths in the configuration file can be either relative or absolute.
If relative then they will be treated as being relative to the `home` path.


### Receipt Policy Configuration

This section of configuration is only applicable if `proxyConfig.receive.receiptCheckMode` is `RECEIPT_POLICY`.
It controls the fetching of the receipt policy rules from a downstream Stroom or Stroom-Proxy.

```yaml
proxyConfig:
  receiptPolicy:
    # Only set if using a non-standard URL, else this is derived based on downstreamHost
    # config.
    receiveDataRulesUrl: null
    # The duration between calls to fetch the latest policy rules.
    syncFrequency: "PT1M"
```

The configuration of the client certificates for receipt policy checks is done using the `DOWNSTREAM` jersey client configuration.
See [Stroom and Stroom-Proxy Common Configuration]({{< relref "common-configuration#jersey-http-client-configuration" >}}).


### Receive Configuration

The `receive` configuration is common to both Stroom and Stroom-Proxy, see [Receive Configuration]({{< relref "common-configuration#receive-configuration" >}})


### Security Configuration

```yaml
proxyConfig:
  security:
    authentication:
      # This property is currently not used
      authenticationRequired: true
      # Open ID Connect configuration
      openId:
```

The `openId` branch of the config is common to both Stroom and Stroom-Proxy, see [Open ID Configuration]({{< relref "common-configuration#open-id-configuration" >}}) for details.


### Amazon Simple Queue Service Configuration

Stroom-Proxy is able to consume messages from multiple AWS SQS queues.
Each message received from a queue will be added to the Event Store for aggregation by Feed and Stream Type.

```yaml
proxyConfig:
  # Zero to many connectors
  sqsConnectors:
    # This property is not currently used
  - awsProfileName: null
    # The name of the AWS region the SQS queue exists in.
    awsRegionName: "...AWS REGION..."
    # The maximum time to wait when polling the queue for messages
    pollFrequency: "PT10S"
    # This property is not currently used
    queueName: null
    # The URL of the Amazon SQS queue from which messages are received.
    queueUrl: "...SQS QUEUE URL..."
```


### Thread Configuration

Stroom-Proxy is able to run certain operations in parallel.
This configuration allows you to increase the number of threads used for each operation.

```yaml
proxyConfig:
  threads:
    # Number of threads to consume from the aggregate input queue.
    aggregateInputQueueThreadCount: 1
    # Number of threads to consume from the forwarding input queue. 
    forwardingInputQueueThreadCount: 1
    # Number of threads to consume from the pre-aggregate input queue.
    preAggregateInputQueueThreadCount: 1
    # Number of threads to consume from the zip splitting input queue.
    zipSplittingInputQueueThreadCount: 1
```


## Deploying without Docker

Apart from the structure of the `config.yml` file, the configuration in a non-docker environment is the same as for [stroom]({{< relref "./configuring-stroom.md#deploying-without-docker" >}}).


## As part of a docker stack

The way Stroom-Proxy is configured is essentially the same as for [stroom]({{< relref "./configuring-stroom.md#as-part-of-a-docker-stack" >}}) with the only real difference being the structure of the `config.yml` file as note [above](#config-file-structure) .
As with stroom the docker stack comes with a `./volumes/stroom-proxy-*/config/config.yml` file that will be used in the absence of a provided one.
Also as with stroom, the `config.yml` file supports environment variable substitution so can make use of environment variables set in the stack `.env` file and passed down via the docker-compose YAML files. 


### Certificates

Stroom-proxy makes use of client certificates for two purposes:

* Communicating with a downstream stroom/stroom-proxy in order to establish the receipt status for the feeds it has received data for.
* When forwarding data to a downstream stroom/stroom-proxy

The stack comes with the following files that can be used for demo/test purposes.

```text
volumes/stroom-proxy-*/certs/ca.jks
volumes/stroom-proxy-*/certs/client.jks
```

For a production deployment these will need to be replaced with the certificates that are appropriate for your environment.


## Typical Configuration

The following are a guide to typical configurations for operating a Stroom-Proxy with different use cases.


### Store and Forward

This is a typical case where you want to aggregate received data then forward it to a downstream Stroom or Stroom-Proxy, but also retain a store of the aggregates.

```yaml
server:
  applicationContextPath: /
  adminContextPath: /proxyAdmin
  applicationConnectors:
    - type: http
      port: "8090"
      useForwardedHeaders: true
  adminConnectors:
    - type: http
      port: "8091"
      useForwardedHeaders: true
  detailedJsonProcessingExceptionMapper: true
  requestLog:
    appenders:
      # Log appender for the web server request logging
    - type: file
      currentLogFilename: logs/access/access.log
      discardingThreshold: 0
      # Rolled and gzipped every minute
      archivedLogFilenamePattern: logs/access/access-%d{yyyy-MM-dd'T'HH:mm}.log.gz
      # One week using minute files
      archivedFileCount: 10080
      logFormat: '%h %l "%u" [%t] "%r" %s %b "%i{Referer}" "%i{User-Agent}" %D'

logging:
  level: WARN
  loggers:
    # Logs useful information about stroom proxy. Only set DEBUG on specific 'stroom' classes or packages
    # due to the large volume of logs that would be produced for all of 'stroom' in DEBUG.
    stroom: INFO
    # Logs useful information about dropwizard when booting stroom
    io.dropwizard: INFO
    # Logs useful information about the jetty server when booting stroom
    # Set this to INFO if you want to log all REST request/responses with headers/payloads.
    org.glassfish.jersey.logging.LoggingFeature: OFF

    # Logger and appender for proxy receipt audit logs
    "receive":
      level: INFO
      additive: false
      appenders:
      - type: file
        currentLogFilename: logs/receive/receive.log
        discardingThreshold: 0
        # Rolled and gzipped every minute
        archivedLogFilenamePattern: logs/receive/receive-%d{yyyy-MM-dd'T'HH:mm}.log.gz
        # One week using minute files
        archivedFileCount: 10080
        logFormat: "%-6level [%d{yyyy-MM-dd'T'HH:mm:ss.SSS'Z'}] [%t] %logger - %X{code} %msg %n"

    # Logger and appender for proxy send audit logs
    "send":
      level: INFO
      additive: false
      appenders:
      - type: file
        currentLogFilename: logs/send/send.log
        discardingThreshold: 0
        # Rolled and gzipped every minute
        archivedLogFilenamePattern: logs/send/send-%d{yyyy-MM-dd'T'HH:mm}.log.gz
        # One week using minute files
        archivedFileCount: 10080
        logFormat: "%-6level [%d{yyyy-MM-dd'T'HH:mm:ss.SSS'Z'}] [%t] %logger - %X{code} %msg %n"

  appenders:

    # Log to stdout, use this if running in Docker
  - type: console
    # Multi-coloured log format for console output
    logFormat: "%highlight(%-6level) [%d{\"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'\",UTC}] [%green(%t)] %cyan(%logger) - %X{code} %msg %n"
    timeZone: UTC

    # Minute rolled files for stroom/datafeed, will be curl'd/deleted by stroom-log-sender
  - type: file
    currentLogFilename: logs/app/app.log
    discardingThreshold: 0
    archivedLogFilenamePattern: logs/app/app-%d{yyyy-MM-dd'T'HH:mm}.log.gz
    # One week using minute files
    archivedFileCount: 10080
    logFormat: "%-6level [%d{\"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'\",UTC}] [%t] %logger - %X{code} %msg %n"

# This section contains the Stroom Proxy configuration properties
# For more information see:
# https://gchq.github.io/stroom-docs/user-guide/properties.html
# jerseyClients are used for making feed status and content sync REST calls
jerseyClients:
  default:
    tls:
      keyStorePath: "certs/client.jks"
      keyStorePassword: "password"
      trustStorePath: "certs/ca.jks"
      trustStorePassword: "password"

proxyConfig:
  path:
    # By default all files read or written to by stroom-proxy will be in directories relative to
    # the home location. This must be set to an absolute path and also to one that differs
    # the installed software as it has a different lifecycle.
    home: "/stroomdata/stroom-proxy/home"
  # This is the downstream (in datafeed flow terms) stroom/stroom-proxy used for
  # feed status checks, supplying data receipt rules and verifying API keys.
  downstreamHost:
    scheme: "https"
    port: "443"
    hostname: "stroom.some.domain"
    apiKey: "...API KEY..."

  aggregator:
    maxItemsPerAggregate: 1000
    maxUncompressedByteSize: "1G"
    aggregationFrequency: 10m

  forwardFileDestinations:
  - name: "archive-repo"
    path: "/stroomdata/stroom-proxy/archive-repo"
    subPathTemplate:
      pathTemplate: "${year}/${year}-${month}/${year}-${month}-${day}/${year}-${month}-${day}-${feed}/"

  forwardHttpDestinations:
  - name: "downstream-stroom"
    httpClient:
      tls:
        keyStorePath: "certs/client.jks"
        keyStorePassword: "password"
        trustStorePath: "certs/ca.jks"
        trustStorePassword: "password"

  receive:
    receiptCheckMode: "RECEIPT_POLICY"
```


### Air-Gapped Store Only

This is an example of a Stroom-Proxy instance that is hosted in an environment where is has no direct link to a downstream Stroom/Stroom-Proxy.
All data is aggregated and forwarded to the local file system for transport downstream using other means outside of the scope of this documentation.

```yaml
server:
  # ... Same as configuration above

logging:
  # ... Same as configuration above

jerseyClients:
  # ... Same as configuration above

proxyConfig:
  path:
    # By default all files read or written to by stroom-proxy will be in directories relative to
    # the home location. This must be set to an absolute path and also to one that differs
    # the installed software as it has a different lifecycle.
    home: "/stroomdata/stroom-proxy/home"

  # No downstreamHost due to air-gap
  downstreamHost:
    enabled: false

  aggregator:
    maxItemsPerAggregate: 1000
    maxUncompressedByteSize: "1G"
    aggregationFrequency: 10m

  forwardFileDestinations:

  # Repo for a local archive
  - name: "archive-repo"
    path: "/stroomdata/stroom-proxy/archive-repo"
    subPathTemplate:
      pathTemplate: "${year}/${year}-${month}/${year}-${month}-${day}/${year}-${month}-${day}-${feed}/"

  # Repo to be transported downstream around air-gap
  - name: "downstream-repo"
    path: "/stroomdata/stroom-proxy/downstream-repo"
    subPathTemplate:
      pathTemplate: "${year}/${year}-${month}/${year}-${month}-${day}/${year}-${month}-${day}-${feed}/"

  forwardHttpDestinations: []

  receive:
    # No receipt checking due to air-gap. All data accepted.
    receiptCheckMode: "RECEIVE_ALL"
```

