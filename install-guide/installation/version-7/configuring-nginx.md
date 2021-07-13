# Nginx Configuration

> **Version Information:** Created with Stroom v7.0  
> **Last Updated:** 2021-06-07  
> **See Also:** [Nginx documentation (external link)](https://nginx.org/en/docs/).

Nginx is the standard web server used by stroom.
Its primary role is SSL termination and reverse proxying for stroom and stroom-proxy that sit behind it.
It can also load balance incoming requests and ensure traffic from the same source is always route to the same upstream instance.
Other web servers can be used if required but their installation/configuration is out of the scope of this documentation.


## Without Docker

The standard way of deploying Nginx with stroom running without docker involves running Nginx as part of the _services_ stack.
See below for details of how to configure it.
If you want to deploy Nginx without docker then you can but that is outside the scope of the this documentation.


## As part of a docker stack

Nginx is included in all the stroom docker stacks.
Nginx is configured using multiple configuration files to aid clarity and allow reuse of sections of configuration.
The main file for configuring Nginx is `nginx.conf.template` and this makes use of other files via `include` statements.

The purpose of the various files is as follows:

* `nginx.conf.template` - Top level configuration file that orchestrate the other files.
* `logging.conf.template` - Configures the logging output, its content and format.
* `server.conf.template` - Configures things like SSL settings, timeouts, ports, buffering, etc.
* Upstream configuration
  * `upstreams.stroom.ui.conf.template` - Defines the upstream host(s) for stroom node(s) that are dedicated to serving the user interface.
  * `upstreams.stroom.processing.conf.template` - Defines the upstream host(s) for stroom node(s) that are dedicated to stream processing and direct data receipt.
  * `upstreams.proxy.conf.template` - Defines the upstream host(s) for local stroom-proxy node(s).
* Location configuration
  * `locations_defaults.conf.template` - Defines some default directives (e.g. headers) for configuring stroom paths.
  * `proxy_location_defaults.conf.template` - Defines some default directives (e.g. headers) for configuring stroom-proxy paths. 
  * `locations.proxy.conf.template` - Defines the various paths (e.g/ `/datafeed`) that will be reverse proxied to stroom-proxy hosts.
  * `locations.stroom.conf.template` - Defines the various paths (e.g/ `/datafeeddirect`) that will be reverse proxied to stroom hosts. 


### Templating

The nginx container has been configured to support using environment variables passed into it to set values in the Nginx configuration files.
It should be noted that recent versions of Nginx have templating support built in.
The templating mechanism used in stroom's Nginx container was set up before this existed but achieves the same result.

All non-default configuration files for Nginx should be placed in `volumes/nginx/conf/` and named with the suffix `.template` (even if no templating is needed).
When the container starts any variables in these templates will be substituted and the resulting files will be copied into `/etc/nginx`.
The result of the template substitution is logged to help with debugging.

The files can contain templating of the form:

```
ssl_certificate             /stroom-nginx/certs/<<<NGINX_SSL_CERTIFICATE>>>;
```

In this example `<<<NGINX_SSL_CERTIFICATE>>>` will be replaced with the value of environment variable `NGINX_SSL_CERTIFICATE` when the container starts.


### Upstreams

When configuring a multi node cluster you will need to configure the upstream hosts.
Nginx acts as a reverse proxy for the applications behind it so the lists of hosts for each application need to be configured.

For example if you have a 10 node cluster and 2 of those nodes are dedicated for user interface use then the configuration would look like:

**upstreams.stroom.ui.conf.template**
```conf
server node1.stroomhosts:<<<STROOM_PORT>>>
server node2.stroomhosts:<<<STROOM_PORT>>>
```

**upstreams.stroom.processing.conf.template**
```conf
server node3.stroomhosts:<<<STROOM_PORT>>>
server node4.stroomhosts:<<<STROOM_PORT>>>
server node5.stroomhosts:<<<STROOM_PORT>>>
server node6.stroomhosts:<<<STROOM_PORT>>>
server node7.stroomhosts:<<<STROOM_PORT>>>
server node8.stroomhosts:<<<STROOM_PORT>>>
server node9.stroomhosts:<<<STROOM_PORT>>>
server node10.stroomhosts:<<<STROOM_PORT>>>
```

**upstreams.proxy.conf.template**
```conf
server node3.stroomhosts:<<<STROOM_PORT>>>
server node4.stroomhosts:<<<STROOM_PORT>>>
server node5.stroomhosts:<<<STROOM_PORT>>>
server node6.stroomhosts:<<<STROOM_PORT>>>
server node7.stroomhosts:<<<STROOM_PORT>>>
server node8.stroomhosts:<<<STROOM_PORT>>>
server node9.stroomhosts:<<<STROOM_PORT>>>
server node10.stroomhosts:<<<STROOM_PORT>>>
```

In the above example the port is set using templating as it is the same for all nodes.
Nodes 1 and 2 will receive all UI and REST API traffic.
Nodes 8-10 will serve all datafeed(direct) requests.


### Certificates

The stack comes with a default server certificate/key and CA certificate for demo/test purposes.
The files are located in `volumes/nginx/certs/`.
For a production deployment these will need to be changed, see [Certificates](configuration.md#certificates)


### Log rotation

The Nginx container makes use of logrotate to rotate Nginx's log files after a period of time so that rotated logs can be sent to stroom.
Logrotate is configured using the file `volumes/stroom-log-sender/logrotate.conf.template`.
This file is templated in the same way as the Nginx configuration files, see [above](#templating).
The number of rotated files that should be kept before deleting them can be controlled using the line.

```
rotate 100
```

This should be set in conjunction with the frequency that logrotate is called, which is controlled by `volumes/stroom-log-sender/crontab.txt`.
This crontab file drives the lograte process and by default is set to run every minute.

