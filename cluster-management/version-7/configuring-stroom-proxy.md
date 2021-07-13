# Stroom Proxy Application Configuration

> **Version Information:** Created with Stroom v7.0  
> **Last Updated:** 2021-06-23  
> **See Also:** [Stroom Application Configuration](configuring-stroom.md)  
> **See Also:** [Properties](../../user-guide/properties.md).  
> **TODO:** This needs updating for v7.1  

The configuration of Stroom-proxy is very much the same as for Stroom with the only difference being the structure of the `config.yml` file.
Stroom-proxy has a `proxyConfig` key in the YAML while Stroom has `appConfig`.
It is recommended to first read [Stroom Application Configuration](configuring-stroom.md) to understand the general mechanics of the stroom configuration as this will largely apply to stroom-proxy.


## General configuration

The Stroom-proxy application is essentially just an executable [JAR (external link)](https://en.wikipedia.org/wiki/JAR_%28file_format%29) file that can be run when provided with a configuration file, `config.yml`.
This configuration file is common to all forms of deployment.


### config.yml

Stroom-proxy does not have a user interface so the `config.yml` file is the only way of configuring stroom-proxy.
As with stroom, the `config.yml` file is split into three sections using these keys:

* `server` - Configuration of the web server, e.g. ports, paths, request logging.
* `logging` - Configuration of application logging
* `proxyConfig` - Configuration of stroom-proxy

See also [Properties](../../user-guide/properties.md) for more details on structure of the config.yml file and supported data types.

Stroom-proxy operates on a configuration by exception basis so all configuration properties will have a sensible default value and a property only needs to be explicitly configured if the default value is not appropriate, e.g. for tuning a large scale production deployment or where values are environment specific.
As a result `config.yml` only contains a minimal set of properties.
The full tree of properties can be seen in `./config/config-defaults.yml` and a schema for the configuration tree (along with descriptions for each property) can be found in `./config/config-schema.yml`.
These two files can be used as a reference when configuring stroom.


#### Key Configuration Properties

Stroom-proxy has two main functions, storing and forwarding.
It can be configured to do either or both of these functions.
These functions are enabled/disabled using:

```yaml
proxyConfig:

  forwardStreamConfig:
    forwardingEnabled: true

  proxyRepositoryConfig:
    storingEnabled: true
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
  forwardStreamConfig:
    forwardDestinations:
      - forwardUrl: "https://nginx/stroom/datafeed"
```

`forwardUrl` specifies the URL of the _datafeed_ endpoint on the destination host.
Each forward location can use a different key/trust store pair.
See also [Forwarding certificate configuration](#forwarding-certificate-configuration).

If the proxy is configured to store then it is the location of the proxy repository may need to be configured if it needs to be in a different location to the proxy home directory, e.g. on another mount point.


## Deploying without Docker

Apart from the structure of the `config.yml` file, the configuration in a non-docker environment is the same as for [stroom](./configuring-stroom-proxy.md#deploying-without-docker)


## As part of a docker stack

The way stroom-proxy is configured is essentially the same as for [stroom](./configuring-stroom-proxy.md#as-part-of-a-docker-stack) with the only real difference being the structure of the `config.yml` file as note [above](#configyml) .
As with stroom the docker stack comes with a `./volumes/stroom-proxy-*/config/config.yml` file that will be used in the absence of a provided one.
Also as with stroom, the `config.yml` file supports environment variable substitution so can make use of environment variables set in the stack env file and passed down via the docker-compose YAML files. 


### Certificates

Stroom-proxy makes use of client certificates for two purposes:

* Communicating with a downstream stroom/stroom-proxy in order to establish the receipt status for the feeds it has received data for.
* When forwarding data to a downstream stroom/stroom-proxy

The stack comes with the following files that can be used for demo/test purposes.

```
volumes/stroom-proxy-*/certs/ca.jks
volumes/stroom-proxy-*/certs/client.jks
```

For a production deployment these will need to be changed, see [Certificates](configuration.md#certificates)


#### Feed status certificate configuration

The configuration of the client certificates for feed status checks is done using: 

```yaml
proxyConfig:

  jerseyClient:
    timeout: "10s"
    connectionTimeout: "10s"
    timeToLive: "1h"
    cookiesEnabled: false
    maxConnections: 1024
    maxConnectionsPerRoute: "1024"
    keepAlive: "0ms"
    retries: 0
    tls:
      verifyHostname: true
      keyStorePath: "/stroom-proxy/certs/client.jks"
      keyStorePassword: "password"
      keyStoreType: "JKS"
      trustStorePath: "/stroom-proxy/certs/ca.jks"
      trustStorePassword: "password"
      trustStoreType: "JKS"
      trustSelfSignedCertificates: false
```

This configuration is also used for making any other REST API calls.


#### Forwarding certificate configuration

Stroom-proxy can forward to multiple locations.
The configuration of the certificate(s) for the forwarding locations is as follows:

```yaml
proxyConfig:

  forwardStreamConfig:
    forwardingEnabled: true
    forwardDestinations:
      # If you want multiple forward destinations then you will need to edit this file directly
      # instead of using env var substitution
      - forwardUrl: "https://nginx/stroom/datafeed"
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

