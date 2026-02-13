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


## General configuration

The Stroom-proxy application is essentially just an executable {{< external-link "JAR" "https://en.wikipedia.org/wiki/JAR_%28file_format%29" >}} file that can be run when provided with a configuration file, `config.yml`.
This configuration file is common to all forms of deployment.


### config.yml

Stroom-proxy does not have a user interface so the `config.yml` file is the only way of configuring stroom-proxy.
As with stroom, the `config.yml` file is split into three sections using these keys:

* `server` - Configuration of the web server, e.g. ports, paths, request logging.
* `logging` - Configuration of application logging
* `proxyConfig` - Stroom-Proxy specific configuration

See also [Properties]({{< relref "/docs/user-guide/properties.md" >}}) for more details on structure of the config.yml file and supported data types.

Stroom-Proxy operates on a configuration by exception basis so all configuration properties will have a sensible default value and a property only needs to be explicitly configured if the default value is not appropriate (e.g. for tuning a large scale production deployment) or where values are environment specific (e.g. the hostname of a forward destination).

As a result the `config.yml` shipped with Stroom Proxy only contains a minimal set of properties.
The full tree of properties can be seen in `./config/config-defaults.yml` and a schema for the configuration tree (along with descriptions for each property) can be found in `./config/config-schema.yml`.
These two files can be used as a reference when configuring stroom.


#### Key Configuration Properties

Stroom-proxy has two main functions, storing and forwarding.
It can be configured to do either or both of these functions.
These functions are enabled/disabled using:

```yaml
proxyConfig:

  # This should be set to a value that is unique within your Stroom/Stroom-Proxy estate.
  # It is used in the unique ReceiptId that is set in the meta of received data so
  # provides provenence of where data was received at each stage.
  proxyId: null

  path:
    # By default all files read or written to by stroom-proxy will be in directories relative to
    # the home location. Ideally this should differ from the location of the Stroom Proxy
    # installed software as it has a different lifecycle.
    home: "/stroom-proxy"

  # This is the downstream (in flow of stream data terms) Stroom/Stroom-Proxy instance/cluster
  # used for feed status checks, supplying data receipt rules and verifying API keys.
  downstreamHost:
    scheme: "https"
    # If not set, will default to 80/443 depending on scheme
    port: 443
    hostname: stroom.some-domain
    # If not using OpenID authentication you will need to provide an API key.
    apiKey: "sak_6a011e3e5d_oKimmDxfNwj......<truncated>.....HYQxHaR2"

  # This controls the aggregation of received data into larger chunks prior to forwarding.
  # This is typically required to prevent Stroom receiving lots of small streams.
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

  # Zero to many HTTP POST based destinations.
  # E.g. for forwarding to Stroom or another Stroom-Proxy
  forwardHttpDestinations:
  - enabled: true
    # The name of the destination (must be unique across all destinations)
    name: "stroom"
    # If true received data is streamed directly to the destination with no aggregation.
    # Using 'instant' means you can have only one destination.
    instant: false
    # See Queue Configuration section below
    queue:
    # The HTTP client configuration to use for this destination.
    httpClient:
      tls:
        keyStorePath: "certs/client.jks"
        keyStorePassword: "password"
        trustStorePath: "certs/ca.jks"
        trustStorePassword: "password"
        verifyHostname: ${FORWARDING_HOST_VERIFICATION_ENABLED:-true}

  # Zero to many file system based destinations.
  forwardFileDestinations:
  - enabled: true
    # The name of the destination (must be unique across all destinations)
    name: "local-store"
      # If true received data is streamed directly to the destination with no aggregation.
      # Using 'instant' means you can have only one destination.
      instant: false
    # The base path to write to.
    path: "/some/path/"
    # A templated sub-path of 'path'. If not set '${year}${month}${day}/${feed}' is used.
    subPathTemplate: null
    # See Queue Configuration section below
    queue:

  # This controls the meta entries that will be included in the send and receive logs.
  logStream:
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

  # If receive.receiptCheckMode is RECEIPT_POLICY, this controls the fetching
  # of the policy rules.
  receiptPolicy:
    # Only set if using a non-standard URL, else this is derived based on downstreamHost
    # config.
    receiveDataRulesUrl: null
    # The duration between calls to fetch the latest policy rules.
    syncFrequency: "PT1M"

  # This section is common to both Stroom and Stroom-Proxy
  # See Receive Configuration below.
  receive:

  feedStatus:
    # Only set this to the FULL url of the feed status endpoint if it differs
    # from where the downstreamHost config points to. Under normal circumstances
    # the url is derived using downstreamHost.
    url: "${FEED_STATUS_URL:-}"
  # (FEED_STATUS|RECEIPT_POLICY|RECEIVE_ALL|DROP_ALL|REJECT_ALL)

  receive:
    receiptCheckMode: "${RECEIPT_CHECK_MODE:-FEED_STATUS}"
    fallbackReceiveAction: "${FALLBACK_RECEIVE_ACTION:-}"
    # Whether authentication is required for requests sent to /datafeed
    authenticationRequired: ${RECEIVE_AUTH_REQUIRED:-true}
  security:
    authentication:
      openId:
        # (NO_IDP|EXTERNAL_IDP|TEST_CREDENTIALS), Only use TEST for test/demo installs
        # NO_IDP - No IDP is used. API keys are set in config for feed status checks.
        # EXTERNAL_IDP - An external IDP such as KeyCloak/Cognito.
        # TEST_CREDENTIALS - Use hard-coded authentication credentials for test/demo only.
        identityProviderType: "${IDENTITY_PROVIDER_TYPE:-NO_IDP}"
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
This may also be te address of a load balancer or similar that is fronting a cluster of stroom-proxy or stroom instances.
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

If the proxy is configured to store then it is the location of the proxy repository may need to be configured if it needs to be in a different location to the proxy home directory, e.g. on another mount point.


## Receive Configuration

The `receive` configuration section is common to both Stroom and Stroom Proxy, see [Receive Configuration]({{< relref "common-configuration#common-appconfigproxyconfig-configuration" >}}).


## Forward Configuration

### Queue Configuration

Each forward destination has a `queue` configuration property that controls various aspects of forwarding, e.g. failure handling, delays, concurrency, etc.

```yaml
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


### Path Templating Configuration

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


### Liveness Checking

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


## Deploying without Docker

Apart from the structure of the `config.yml` file, the configuration in a non-docker environment is the same as for [stroom]({{< relref "./configuring-stroom-proxy.md#deploying-without-docker" >}})


## As part of a docker stack

The way stroom-proxy is configured is essentially the same as for [stroom]({{< relref "./configuring-stroom-proxy.md#as-part-of-a-docker-stack" >}}) with the only real difference being the structure of the `config.yml` file as note [above](#configyml) .
As with stroom the docker stack comes with a `./volumes/stroom-proxy-*/config/config.yml` file that will be used in the absence of a provided one.
Also as with stroom, the `config.yml` file supports environment variable substitution so can make use of environment variables set in the stack env file and passed down via the docker-compose YAML files. 


### Certificates

Stroom-proxy makes use of client certificates for two purposes:

* Communicating with a downstream stroom/stroom-proxy in order to establish the receipt status for the feeds it has received data for.
* When forwarding data to a downstream stroom/stroom-proxy

The stack comes with the following files that can be used for demo/test purposes.

```text
volumes/stroom-proxy-*/certs/ca.jks
volumes/stroom-proxy-*/certs/client.jks
```

For a production deployment these will need to be changed, see [Certificates]({{< relref "./#certificates" >}})


#### Feed status certificate configuration

The configuration of the client certificates for feed status checks is done using the `FEED_STATUS` jersey client configuration.
See [Stroom and Stroom-Proxy Common Configuration]({{< relref "common-configuration#jersey-http-client-configuration" >}}).


#### Forwarding Configuration

Stroom-proxy can forward to multiple locations.
The configuration of the certificate(s) for the forwarding locations is as follows:

```yaml
proxyConfig:

  forwardHttpDestinations:
    - enabled: true
      name: "downstream"
      forwardUrl: "https://some-host/stroom/datafeed"
      sslConfig:
        keyStorePath: "/stroom-proxy/certs/client.jks"
        keyStorePassword: "password"
        keyStoreType: "JKS"
        trustStorePath: "/stroom-proxy/certs/ca.jks"
        trustStorePassword: "password"
        trustStoreType: "JKS"
        hostnameVerificationEnabled: true
```

`forwardUrl` specifies the URL of the _datafeed_ endpoint on the destination host.
Each forward location can use a different key/trust store pair.


