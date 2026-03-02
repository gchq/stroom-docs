---
title: "Common Configuration"
linkTitle: "Common Configuration"
#weight:
date: 2023-07-11
tags: 
  - configuration
description: >
  Configuration common to Stroom and Stroom-Proxy.
  
---

This YAML file, sometimes known as the Dropwizard configuration file (as it conforms to a structure defined by Dropwizard) is the primary means of configuring Stroom/Stroom-Proxy.
As a minimum this file should be used to configure anything that needs to be set before stroom can start up, e.g. web server, logging, database connection details, etc.
It is also used to configure anything that is specific to a node in a stroom cluster.

If you are using some form of scripted deployment, e.g. ansible then it can be used to set all stroom properties for the environment that stroom runs in.
If you are not using scripted deployments then you can maintain stroom's node agnostic configuration properties via the user interface.


## Config File Structure

This file contains both the Dropwizard configuration settings (settings for ports, paths and application logging) and the Stroom/Stroom-Proxy application specific properties configuration.
The file is in YAML format and the application properties are located under the `appConfig` key.
For details of the Dropwizard configuration structure, see {{< external-link "here" "https://www.dropwizard.io/en/latest/manual/configuration.html" >}}.

The file is split into sections using these keys:

* `server` - Configuration of the web server, e.g. ports, paths, request logging.
* `logging` - Configuration of application logging
* `jerseyClients` - Configuration of the various Jersey HTTP clients in use.
  See [Jersey HTTP Client Configuration]({{< relref "#jersey-http-client-configuration" >}}).
* Application specific configuration:
    * `appConfig` - The Stroom configuration properties.
      These properties can be viewed/modified in the user interface.
    * `proxyConfig` - The Stroom-Proxy configuration properties.
      These properties can be viewed/modified in the user interface.

The following is an example of the YAML configuration file for Stroom:

```yaml
# Dropwizard configuration section
server:
  # e.g. ports and paths
logging:
  # e.g. logging levels/appenders

jerseyClients:
  DEFAULT:
    # Configuration of the named client

# Stroom properties configuration section
appConfig:
  commonDbDetails:
    connection:
      jdbcDriverClassName: ${STROOM_JDBC_DRIVER_CLASS_NAME:-com.mysql.cj.jdbc.Driver}
      jdbcDriverUrl: ${STROOM_JDBC_DRIVER_URL:-jdbc:mysql://localhost:3307/stroom?useUnicode=yes&characterEncoding=UTF-8}
      jdbcDriverUsername: ${STROOM_JDBC_DRIVER_USERNAME:-stroomuser}
      jdbcDriverPassword: ${STROOM_JDBC_DRIVER_PASSWORD:-stroompassword1}
  contentPackImport:
    enabled: true
  ...
```

The following is an example of the YAML configuration file for Stroom-Proxy:
```yaml
# Dropwizard configuration section
server:
  # e.g. ports and paths
logging:
  # e.g. logging levels/appenders

jerseyClients:
  DEFAULT:
    # Configuration of the named client

# Stroom properties configuration section
proxyConfig:
  path:
    home: /some/path
  ...
```


### `appConfig` Section

The `appConfig` section is special as it maps to the Properties seen in the Stroom user interface so values can be managed in the file or via the Properties screen in the Stroom UI.
The other sections of the file can only be managed via the YAML file.
In the Stroom user interface, properties are named with a dot notation key, e.g. _stroom.contentPackImport.enabled_.
Each part of the dot notation property name represents a key in the YAML file, e.g. for this example, the location in the YAML would be:

```yaml
appConfig:
  contentPackImport:
    enabled: true   # stroom.contentPackImport.enabled
```

The _stroom_ part of the dot notation name is replaced with _appConfig_.

For more details on the link between this YAML file and Stroom Properties, see [Properties]({{< relref "/docs/user-guide/properties" >}})


### Variable Substitution

The YAML configuration file supports Bash style variable substitution in the form of:

```bash
${ENV_VAR_NAME:-value_if_not_set}
```

This allows values to be set either directly in the file or via an environment variable, e.g.

```yaml
      jdbcDriverClassName: ${STROOM_JDBC_DRIVER_CLASS_NAME:-com.mysql.cj.jdbc.Driver}
```

In the above example, if the _STROOM_JDBC_DRIVER_CLASS_NAME_ environment variable is not set then the value _com.mysql.cj.jdbc.Driver_ will be used instead.


### Typed Values

YAML supports typed values rather than just strings, see https://yaml.org/refcard.html.
YAML understands booleans, strings, integers, floating point numbers, as well as sequences/lists and maps.
Some properties will be represented differently in the user interface to the YAML file.
This is due to how values are stored in the database and how the current user interface works.
This will likely be improved in future versions.
For details of how different types are represented in the YAML and the UI, see [Data Types](/docs/user-guide/properties#data-types).


## Server configuration

The `server` section controls the configuration of the Jetty web server.

For full details of how to configure the `server` section see:

* {{< external-link "Server" "https://www.dropwizard.io/en/latest/manual/configuration.html#servers" >}}
* {{< external-link "Connectors" "https://www.dropwizard.io/en/latest/manual/configuration.html#connectors" >}}

The following is an example of the configuration for an application listening on HTTP.

```yaml
server:
  # The base path for the main application and its API
  applicationContextPath: "/"
  # The base path for the admininstration pages/API
  # For Stroom-Proxy the default is /proxyAdmin
  adminContextPath: "/stroomAdmin"

  # The scheme/port for the main application and its API
  applicationConnectors:
    - type: http
      # For Stroom-Proxy the default is 8090
      port: 8080
      # Uses X-Forwarded-*** headers in request log instead of proxy server details.
      useForwardedHeaders: true

  # The scheme/port for the admininstration pages/API
  adminConnectors:
    - type: http
      # For Stroom-Proxy the default is 8091
      port: 8081
      useForwardedHeaders: true
```


## Common Application Configuration

This section details configuration that is common in both the Stroom `appConfig` and Stroom-Proxy `proxyConfig` sections.


### Receive Configuration

Configuration for controlling the receipt of data into Stroom and Stroom-Proxy through the `/datafeed` API.

```yaml
appConfig / proxyConfig:
  receive:
    # An allow-list containing IP addresses or fully qualified host names to verify that the direct sender
    # of a request (e.g. a load balancer or reverse proxy) is trusted to supply certificate/DN headers
    # as configured with 'x509CertificateHeader' and 'x509CertificateDnHeader'.
    # If this list is null/empty then no check will be made on the client's address.
    allowedCertificateProviders: []
    # Standard cache configuration block for the cache of authenticated Datafeed Keys.
    # This cache is used to avoid having to re-verify every data feed key.
    authenticatedDataFeedKeyCache:
    # If true, the sender will be authenticated using a certificate or token depending on the
    # state of tokenAuthenticationEnabled and certificateAuthenticationEnabled. If the sender
    # can't be authenticated an error will be returned to the client
    # If false, then authentication will be performed if a token/key/certificate
    # is present, otherwise data will be accepted without a sender identity
    authenticationRequired: true
    # The meta key that is used to identify the owner of a Data Feed Key. This
    # may be an AccountId or similar. It must be provided as a header when sending data
    # using the associated Data Feed Key, and its value will be checked against the value
    # held with the hashed Data Feed Key by Stroom. Default value is 'AccountId'.
    # Case does not matter
    dataFeedKeyOwnerMetaKey: "AccountId"
    # The directory where Stroom will look for datafeed key files.
    # Only used if datafeedKeyAuthenticationEnabled is true
    # If the value is a relative path then it will be treated as being
    # relative to stroom.path.home. Data feed key files must have the extension .json.
    # Files in sub-directory will be ignored.
    dataFeedKeysDir: "data_feed_keys"
    # The types of authentication that are enabled for data receipt.
    enabledAuthenticationTypes:
    - "TOKEN"
    - "CERTIFICATE"
    # If receiptCheckMode is RECEIPT_POLICY or FEED_STATUS and stroom/proxy is
    # unable to perform the receipt check, then this action will be used as a fallback
    # until the receipt check can be successfully performed
    fallbackReceiveAction: "RECEIVE"
    # If true the client is not required to set the 'Feed' header. If Feed is not present
    # a feed name will be generated based on the template specified by the
    # 'feedNameTemplate' property. If false (the default), a populated 'Feed'
    # header will be required
    feedNameGenerationEnabled: false
    # The set of header keys are mandatory if feedNameGenerationEnabled is set to true.
    # Should be set to complement the header keys used in 'feedNameTemplate', but may be a
    # sub-set of those in the template to allow for optional headers
    feedNameGenerationMandatoryHeaders:
    - "AccountId"
    - "Component"
    - "Format"
    - "Schema"
    # A template for generating a feed name from a set of headers. The value of
    # each header referenced in the template will have any unsuitable characters
    # replaced with '_'.
    # If this property is set in the YAML file, use single quotes to prevent the
    # variables being expanded when the config file is loaded
    feedNameTemplate: "${accountid}-${component}-${format}-${schema}"
    # If defined then states the maximum size of a request (uncompressed for gzip requests).
    # Will return a 413 Content Too Long response code for any requests exceeding this
    # value. If undefined then there is no limit to the size of the request.
    maxRequestSize: null
    # Set of supported meta type names. This set must contain all of the names
    # in the default value for this property but can contain additional names.
    metaTypes:
    - "Context"
    - "Detections"
    - "Error"
    - "Events"
    - "Meta Data"
    - "Raw Events"
    - "Raw Reference"
    - "Records"
    - "Reference"
    - "Test Events"
    - "Test Reference"
    # Controls how or whether data is checked on receipt. Valid values
    # (FEED_STATUS|RECEIPT_POLICY|RECEIVE_ALL|REJECT_ALL|DROP_ALL)
    receiptCheckMode: "FEED_STATUS"
    # The format of the Distinguished Name used in the certificate. Valid values are
    # LDAP and OPEN_SSL, where LDAP is the default
    x509CertificateDnFormat: "LDAP"
    # The HTTP header key used to extract the distinguished name (DN) as obtained from an X509 certificate.
    # This is used when a load balancer does the SSL/mTLS termination and passes the client DN though
    # in a header. Only used for
    # authentication if a value is set and 'enabledAuthenticationTypes' includes CERTIFICATE
    x509CertificateDnHeader: "X-SSL-CLIENT-S-DN"
    # The HTTP header key used to extract an X509 certificate. This is used when a load balancer does the
    # SSL/mTLS termination and passes the client certificate though in a header. Only used for
    # authentication if a value is set and 'enabledAuthenticationTypes' includes CERTIFICATE
    x509CertificateHeader: "X-SSL-CERT"
```


### Cache Configuration

Multiple configuration branches in both Stroom and Stroom-Proxy have one or more properties for configuring a cache.
Each of these share the same structure and will typically be named `xxxCache`, e.g. `feedStatusCache` or `metaTypeCache`.

{{% warning %}}
The default values for each property within the cache config will be specific to the cache.
Care needs to be taken when changing the cache properties to avoid changing the behaviour of the cache, e.g. changing from having a `expireAfterWrite` value to having a `expireAfterAccess` value may prevent items from aging off as expected.
{{% /warning %}}


```yaml
      xxxCache:
        # Specifies that each entry should be automatically removed from the cache once
        # this duration has elapsed after the entry's creation, the most recent replacement of
        # its value, or its last read. In ISO-8601 duration format, e.g. 'PT10M'. If no value is set then
        #  entries will not be aged out based these criteria
        expireAfterAccess: 
        # Specifies that each entry should be automatically removed from the cache once
        # a fixed duration has elapsed after the entry's creation, or the most recent replacement of its value.
        # In ISO-8601 duration format, e.g. 'PT5M'. If no value is set then entries will not be aged out based on
        # these criteria.
        expireAfterWrite:
        # Specifies the maximum number of entries the cache may contain. Note that the cache
        # may evict an entry before this limit is exceeded or temporarily exceed the threshold while evicting.
        # As the cache size grows close to the maximum, the cache evicts entries that are less likely to be used
        # again. For example, the cache may evict an entry because it hasn't been used recently or very often.
        # When size is zero, elements will be evicted immediately after being loaded into the cache. This can
        # be useful in testing, or to disable caching temporarily without a code change. If no value is set then
        # no size limit will be applied
        maximumSize:
        # Specifies that each entry should be automatically refreshed in the cache after
        # a fixed duration has elapsed after the entry's creation, or the most recent replacement of its value.
        # In ISO-8601 duration format, e.g. 'PT5M'. Refreshing is performed asynchronously and the current value
        # provided until the refresh has occurred. This mechanism allows the cache to update values without any
        # impact on performance
        refreshAfterWrite:
        # Determines whether/how statistics are captured on cache usage
        # (e.g. hits, misses, entries, etc.). Values are (NONE, INTERNAL, DROPWIZARD_METRICS).
        # NONE means capture no stats, offering a very slight performance gain, but the Caches screen in Stroom
        # won't be able to show any stats for this cache.
        # INTERNAL means the stats are captured but are only accessible via the Stroom Caches screen, thus not
        # suitable for Stroom-Proxy.
        # DROPWIZARD_METRICS means the stats are captured and are accessible via the Stroom Caches screen AND via
        # the metrics servlet on the admin port for integration with tools like Graphite/Collectd
        # The default for Stroom is INTERNAL, the default for Stroom-Proxy is DROPWIZARD_METRICS
        statisticsMode:
```


### Open ID Configuration

Both Stroom and Stroom-Proxy share the same configuration structure for configuring Open ID Connect authentication.
This section of config is only applicable if `appConfig/proxyConfig.security.authentication.identityProviderType` is set to `EXTERNAL_IDP`.

```yaml
appConfig / proxyConfig:
  security:
    authentication:
      openId:
        # A set of audience claim values, one of which must appear in the audience
        # claim in the token.
        # If empty, no validation will be performed on the audience claim
        # If audienceClaimRequired is false and there is no audience claim in the token,
        # then allowedAudiences will be ignored
        allowedAudiences: []
        # If true the token will fail validation if the audience claim is not present
        # and allowedAudiences is not empty
        audienceClaimRequired: false
        # The authentication endpoint used in OpenId authentication
        # Should only be set if not using a configuration endpoint
        authEndpoint: null
        # If custom scopes are required for client_credentials requests then this should be
        # set to replace the default of 'openid'. E.g. for Azure AD you will likely need to set
        # this to 'openid' and '<your-app-id-uri>/.default>'
        clientCredentialsScopes:
        - "openid"
        # The client ID used in OpenId authentication.
        clientId: null
        # The client secret used in OpenId authentication.
        clientSecret: null
        # If using an AWS load balancer to handle the authentication, set this to the Amazon
        # Resource Names (ARN) of the load balancer(s) fronting stroom, which will be something
        # like 'arn:aws:elasticloadbalancing:region-code:account-id:loadbalance
        # /app/load-balancer-name/load-balancer-id'.
        # This config value will be used to verify the 'signer' in the JWT header.
        # Each value is the first N characters of the ARN and as a minimum must include up to
        # the colon after the account-id, i.e.
        # 'arn:aws:elasticloadbalancing:region-code:account-id:'
        # See https://docs.aws.amazon.com/elasticloadbalancing/latest/application/listener-authenticate-users.html#user-claims-encodin
        expectedSignerPrefixes: []
        # Some OpenId providers, e.g. AWS Cognito, require a form to be used for token requests.
        formTokenRequest: true
        # A template to build the user's full name using claim values as variables in the
        # template. E.g '${firstName} ${lastName}' or '${name}'.
        # If this property is set in the YAML file, use single quotes to prevent the
        # variables being expanded when the config file is loaded. Note: claim names are
        # case sensitive
        fullNameClaimTemplate: "${name}"
        # The type of Open ID Connect identity provider that stroom/prox
        # will use for authentication. Valid values are:
        # INTERNAL_IDP - Stroom's internal IDP. Not valid for Stroom-Proxy.
        # EXTERNAL_IDP - An external IDP such as KeyCloak/Cognito,
        # TEST_CREDENTIALS - Use hard-coded authentication credentials for test/demo only and
        # NO_IDP - No IDP is used. API keys are set in config for feed status checks. Only for use by Stroom-Proxy
        # Changing this property will require a restart of the application
        identityProviderType: "NO_IDP"
        # The issuer used in OpenId authentication.
        # Should only be set if not using a configuration endpoint
        issuer: null
        # The URI to obtain the JSON Web Key Set from in OpenId authentication
        # Should only be set if not using a configuration endpoint
        jwksUri: null
        # The logout endpoint for the identity provider
        # This is not typically provided by the configuration endpoint
        logoutEndpoint: null
        # The name of the URI parameter to use when passing the logout redirect URI to the IDP.
        # This is here as the spec seems to have changed from 'redirect_uri' to
        # 'post_logout_redirect_uri'
        logoutRedirectParamName: "post_logout_redirect_uri"
        # You can set an openid-configuration URL to automatically configure much of the openid
        # settings. Without this the other endpoints etc must be set manually
        openIdConfigurationEndpoint: null
        # If the token is signed by AWS then use this pattern to form the URI to obtain the
        # public key from. The pattern supports the variables '${awsRegion}' and '${keyId}'.
        # Multiple instances of a variable are also supported.
        # If this property is set in the YAML file, use single quotes to prevent the
        # variables being expanded when the config file is loaded.
        publicKeyUriPattern: "https://public-keys.auth.elb.${awsRegion}.amazonaws.com/${keyId}"
        # If custom auth flow request scopes are required then this should be set to replace
        # the defaults of 'openid' and 'email'.
        requestScopes:
        - "openid"
        - "email"
        # The token endpoint used in OpenId authentication
        # Should only be set if not using a configuration endpoint
        tokenEndpoint: null
        # The Open ID Connect claim used to link an identity on the IDP to a stroom user.
        # Must uniquely identify the user on the IDP and not be subject to change. Uses 'sub' by
        # default
        uniqueIdentityClaim: "sub"
        # The Open ID Connect claim used to provide a more human friendly username for a user
        # than that provided by uniqueIdentityClaim. It is not guaranteed to be unique and may
        # change
        userDisplayNameClaim: "preferred_username"
        # A set of issuers (in addition to the 'issuer' property that is provided by the IDP
        # that are deemed valid when seen in a token. If no additional valid issuers are
        # required then set this to an empty set. Also this is used to validate the 'issuer'
        # returned by the IDP when it is not a sub path of 'openIdConfigurationEndpoint'. If
        # this set is empty then Stroom will verify that the
        validIssuers: []
```


## Jersey HTTP Client Configuration

Stroom and Stroom Proxy use the {{< external-link "Jersey" "https://eclipse-ee4j.github.io/jersey/" >}} client for making HTTP connections with other nodes or other systems (e.g. Open ID Connect identity providers).
In the YAML file, the `jerseyClients` key controls the configuration of the various clients in use.

To allow complete control of the client configuration, Stroom uses the concept of named client configurations.
Each named client will be unique to a destination (where a destination is typically a server or a cluster of functionally identical servers).
Thus the configuration of the connections to each of those destinations can be configured independently.

The client names are as follows:

* `DEFAULT` - The default client configuration used if a named configuration is not present.
* `AWS_PUBLIC_KEYS` - Connections to fetch AWS public keys used in Open ID Connect authentication.
* `DOWNSTREAM` - Connections to downstream proxy/stroom instances to check feed status. (**Stroom Proxy only**).
* `OPEN_ID` - Connections to an Open ID Connect identity provider, e.g. Cognito, Azure AD, KeyCloak, etc.
* `STROOM` - Inter-node communications within the Stroom cluster (**Stroom only**).

{{% note %}}
If a named configuration does not exist then the configuration for `DEFAULT` will be used.
If `DEFAULT` is not defined in the configuration then the Dropwizard defaults will be used.
{{% /note %}}

The following is an example of how the clients are configured in the YAML file:

```yaml
jerseyClients:
  DEFAULT:
    # Default client configuration, e.g.
    timeout: 500ms
  STROOM:
    # Configuration items for stroom inter-node communications
    timeout: 30s
  # etc.
```

The configuration keys (along with their default values and descriptions) for each client can be found here:

* {{< external-link "Jersey Client" "https://www.dropwizard.io/en/latest/manual/configuration.html#jerseyclient" >}}
* {{< external-link "Base HTTP Client" "https://www.dropwizard.io/en/latest/manual/configuration.html#httpclient" >}}
* {{< external-link "Proxy server settings" "https://www.dropwizard.io/en/latest/manual/configuration.html#proxy" >}}
* {{< external-link "TLS settings" "https://www.dropwizard.io/en/latest/manual/configuration.html#tls" >}}

The following is another example including most keys:

```yaml
jerseyClients:
  DEFAULT:
    minThreads: 1
    maxThreads: 128
    workQueueSize: 8
    gzipEnabled: true
    gzipEnabledForRequests: true
    chunkedEncodingEnabled: true
    timeout: 500ms
    connectionTimeout: 500ms
    timeToLive: 1h
    cookiesEnabled: false
    maxConnections: 1024
    maxConnectionsPerRoute: 1024
    keepAlive: 0ms
    retries: 0
    userAgent: <application name> (<client name>)
    proxy:
      host: 192.168.52.11
      port: 8080
      scheme : http
      auth:
        username: secret
        password: stuff
        authScheme: NTLM
        realm: realm
        hostname: host
        domain: WINDOWSDOMAIN
        credentialType: NT
      nonProxyHosts:
        - localhost
        - '192.168.52.*'
        - '*.example.com'
    tls:
      protocol: TLSv1.2
      provider: SunJSSE
      verifyHostname: true
      keyStorePath: /path/to/file
      keyStorePassword: changeit
      keyStoreType: JKS
      trustStorePath: /path/to/file
      trustStorePassword: changeit
      trustStoreType: JKS
      trustSelfSignedCertificates: false
      supportedProtocols: TLSv1.1,TLSv1.2
      supportedCipherSuites: TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA256
      certAlias: alias-of-specific-cert
```


{{% note %}}
Duration values in the Jersey client configuration blocks are different to [Stroom Durations]({{< relref "#stroom-duration-data-type" >}}) defined in Stroom properties.
They are defined as a numeric value and a unit suffix.
Typical suffixes are (in ascending order): `ns`, `us`, `ms`, `s`, `m`, `h`, `d`.
ISO 8601 duration strings are NOT supported, nor are values without a suffix.
{{< external-link "Full list of duration suffixes and their aliases" "https://github.com/dropwizard/dropwizard/blob/master/dropwizard-util/src/main/java/io/dropwizard/util/Duration.java" >}}
{{% /note %}}

{{% note %}}
The paths used for the key and trust stores will be treated in the same way as Stroom property paths, i.e relative to `stroom.home` if relative and supporting variable substitution.
{{% /note %}}


## Logging Configuration

The Dropwizard configuration file controls all the logging by the application.
In addition to the main application log, there are additional logs such as stroom user events (for audit), Stroom-Proxy send and receive logs and database migration logs.

For full details of the logging configuration, see {{< external-link "Dropwizard Logging Configuration" "https://www.dropwizard.io/en/latest/manual/configuration.html#logging" >}}


### Request Log

The request log is slightly different to the other logs.
It logs all requests to the web server.
It is configured in the `server` section.

The property `archivedLogFilenamePattern` controls rolling of the active log file.
The date pattern in the filename controls the frequency that the log files are rolled.
In this example, files will be rolled every 1 minute.

```yaml
server:
  requestLog:
    appenders:
    - type: file
      currentLogFilename: logs/access/access.log
      discardingThreshold: 0
      # Rolled and gzipped every minute
      archivedLogFilenamePattern: logs/access/access-%d{yyyy-MM-dd'T'HH:mm}.log.gz
      archivedFileCount: 10080
      logFormat: '%h %l "%u" [%t] "%r" %s %b "%i{Referer}" "%i{User-Agent}" %D'
```


### Logback Logs

Dropwizard uses {{< external-link "Logback" "https://logback.qos.ch" >}} for application level logging.
All logs in Stroom and Stroom-Proxy apart from the request log are Logback based logs.

Logback uses the concept of _Loggers_ and _Appenders_.
A _Logger_ is a named thing that that produces log messages.
An _Appender is an output that a _Logger_ can append its log messages to.
Typical _Appenders_ are:
* File - appends messages to a file that may or may not be rolled.
* Console - appends messages to `stdout`.
* Syslog - appends messages to `syslog`.


#### Loggers

A _Logger_ can append to more than one _Appender_ if required.
For example, the default configuration file for Stroom has two appenders for the application logs.
The rolled files from one appender are POSTed to Stroom to index its own logs, then deleted and the other is intended to
remain on the server until archived off to allow viewing by an administrator.

A _Logger_ can be configured with a severity, valid severities are (`TRACE`, `DEBUG`, `WARN`, `ERROR`).
The severity set on a logger means that only messages with that severity or higher will be logged, with the rest not logged.

_Logger_ names are typically the name of the Java class that is producing the log message.
You don't need to understand too much about Java classes as you are only likely to change logger severities when requested by one of the developers.
Some loggers, such as `event-logger` do not have a Java class name.

As an example this is a portion of a Stroom config.yml file to illustrate the different loggers/appenders:

```yaml
logging:
  # This is root logging severity level for all loggers. Only messages >= to WARN will be logged unless overridden
  # for a specific logger
  level: WARN

  # All the named loggers
  loggers:
    # Logs useful information about stroom. Only set DEBUG on specific 'stroom' classes or packages
    # due to the large volume of logs that would be produced for all of 'stroom' in DEBUG.
    stroom: INFO
    # Logs useful information about dropwizard when booting stroom
    io.dropwizard: INFO
    # Logs useful information about the jetty server when booting stroom
    org.eclipse.jetty: INFO
    # Logs REST request/responses with headers/payloads. Set this to OFF to turn disable that logging.
    org.glassfish.jersey.logging.LoggingFeature: INFO
    # Logs summary information about FlyWay database migrations
    org.flywaydb: INFO
    # Logger and custom appender for audit logs
    event-logger:
      level: INFO
      # Prevents messages from this logger from being sent to other appenders
      additive: false
      appenders:
        - type: file
          currentLogFilename: logs/user/user.log
          discardingThreshold: 0
          # Rolled every minute
          archivedLogFilenamePattern: logs/user/user-%d{yyyy-MM-dd'T'HH:mm}.log
          # Minute rolled logs older than a week will be deleted. Note rolled logs are deleted
          # based on the age of the window they contain, not the number of them. This value should be greater
          # than the maximum time stroom is not producing events for.
          archivedFileCount: 10080
          logFormat: "%msg%n"
    # Logger and custom appender for the flyway DB migration SQL output
    org.flywaydb.core.internal.sqlscript:
      level: DEBUG
      additive: false
      appenders:
        - type: file
          currentLogFilename: logs/migration/migration.log
          discardingThreshold: 0
          # Rolled every day
          archivedLogFilenamePattern: logs/migration/migration-%d{yyyy-MM-dd}.log
          archivedFileCount: 10
          logFormat: "%-6level [%d{\"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'\",UTC}] [%t] %logger - %X{code} %msg %n"
```


#### Appenders

The following is an example of the default appenders that will be used for all loggers unless they have their own custom appender configured.

```yaml
logging:
  # Appenders for all loggers except for where a logger has a custom appender configured
  appenders:

    # stdout
  - type: console
    # Multi-coloured log format for console output
    logFormat: "%highlight(%-6level) [%d{\"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'\",UTC}] [%green(%t)] %cyan(%logger) - %X{code} %msg %n"
    timeZone: UTC
#
    # Minute rolled files for stroom/datafeed, will be curl'd/deleted by stroom-log-sender
  - type: file
    currentLogFilename: logs/app/app.log
    discardingThreshold: 0
    # Rolled and gzipped every minute
    archivedLogFilenamePattern: logs/app/app-%d{yyyy-MM-dd'T'HH:mm}.log.gz
    # One week using minute files
    archivedFileCount: 10080
    logFormat: "%-6level [%d{\"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'\",UTC}] [%t] %logger - %X{code} %msg %n"
```


#### Log Rolling

Rolling of log files can be done based on size of file or time.
The `archivedLogFilenamePattern` property controls the rolling behaviour.
The rolling policy is determined from the filename pattern, e.g a pattern with a minute precision date format will be rolled every minute.
The following is an example of an appender that rolls based on the size of the log file:

```yaml
  - type: file
    currentLogFilename: logs/app.log
    # The name pattern, where i a sequential number indicating age, where 1 is the most recent
    archivedLogFilenamePattern: logs/app-%i.log
    # The maximum number of rolled files to keep
    archivedFileCount: 10
    # The maximum size of a log file
    maxFileSize: "100MB"
    logFormat: "%-6level [%d{\"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'\",UTC}] [%t] %logger - %X{code} %msg %n"

```

The following is an example of an appender that rolls every minute to gzipped files:

```yaml
  - type: file
    currentLogFilename: logs/app/app.log
    # Rolled and gzipped every minute
    archivedLogFilenamePattern: logs/app/app-%d{yyyy-MM-dd'T'HH:mm}.log.gz
    # One week using minute files
    archivedFileCount: 10080
    logFormat: "%-6level [%d{\"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'\",UTC}] [%t] %logger - %X{code} %msg %n"
```

{{% warning %}}
Log file rolling is event based, so a file will only roll when a new message arrives that would require a roll to happen.
This means that if the application is idle for a long period with no log output then the un-rolled file will remain active until a new message arrives to trigger it to roll. For example, if Stroom is unused overnight, then the last log message from the night before will not be rolled until a new messages arrive in the morning.

For this reason, `archivedFileCount` should be set to a value that is greater than the maximum time the application may be idle, else rolled log files may be deleted as soon as they are rolled.
{{% /warning %}}

