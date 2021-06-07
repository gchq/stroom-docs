> * Version Information: Created with Stroom v7.0  
* Last Updated: 2021-06-07

> TODO: This needs updating for v7.1

# Stroom Proxy Application Configuration

The configuration of Stroom-proxy is very much the same as for Stroom with the only difference being the structure of the `config.yml` file.
Stroom-proxy has a `proxyConfig` key in the YAML while Stroom has `appConfig`.
It is recomended to read [Stroom Application Configuration](./configuring-stroom.md) to understand the general mechanics of the stroom configuration as this will largely apply to stroom-proxy.

## Without Docker

As with stroom, stroom-proxy is configured using two files:

* `./config/config.yml` - Stroom configuration YAML file
* `./config/scripts.env` - Stroom scripts configuration env file

### config.yml

Stroom-proxy does not have a user interface so the `config.yml` file is the only way of configuring stroom-proxy.
As with stroom, the `config.yml` file is split into three sections:

* `server` - Configuration of the web server, e.g. ports, paths, request logging.
* `logging` - Configuration of application logging
* `proxyConfig` - Configuration of stroom-proxy

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
    apiKey: "http://stroom:8080/api/feedStatus/v1"
```

If the proxy is configured to forward data then the forward destination(s) should be set.
This is the `datafeed` endpoint of the downstream stroom-proxy or stroom instance that data will be forwarded to.
This may also be te address of a load balancer or similar that is fronting a cluster of stroom-proxy or stroom instances.

```yaml
  forwardStreamConfig:
    forwardDestinations:
      - forwardUrl: "https://nginx/stroom/datafeed"
```

If the proxy is configured to store then it is the location of the proxy repository may need to be configured if it needs to be in a different localtion to the proxy home directory, e.g. on another mount point.



## As part of a docker stack

As with stroom the docker image comes with a baked in fallback `config.yml` file that will be used in the absence of a provided one.
Also as with stroom, the file supports environment variable substitution so can make use of environment variables set in the stack env file and passed down via the docker-compose yaml files. 
