---
title: "Logging Configuration"
linkTitle: "Logging Configuration"
weight: 40
date: 2026-09-07
tags: 
description: >
  This section describes how to configure the logging produced by Stroom and Stroom-Proxy.
---

## Overview

Stroom and Stroom-Proxy output a number of different types of log file for various purposes.
They use Logback for the logging and configure it through the Dropwizard's `config.yml` file.

Logback uses the concept of _Loggers_ and _Appenders_.
A _Logger_ is a named thing that produces log messages.
A _Log Level_ is the granularity of logging for a _Logger_.
An _Appender_ is an output that a _Logger_ can append its log messages to.

Typical _Appenders_ are:
* File - appends messages to a file that may or may not be rolled.
* Console - appends messages to `stdout`.
* Syslog - appends messages to `syslog`.

{{% see-also %}}
Dropwizard's logging configuration reference can be found {{< external-link "here" "https://www.dropwizard.io/en/stable/manual/core.html#logging" >}}.

Logback documentation can be found {{< external-link "here" "https://logback.qos.ch/manual/appenders.html" >}}.
{{% /see-also %}}


## Types of Logging

The following types of logging are available:

* **Stroom and Stroom-Proxy**

  * **Application logs** - Application logs record general activity of the application.
    Application logs make use of [log levels]({{< relref "#log-levels" >}}) to control the granularity of logging output.

  * **Access logs** - Access or Request logs log the activity of the web server in Stroom and Stroom-Proxy.
    They log all requests made to the API and servlets.

* **Stroom Only**

  * **User logs** - Stroom logs all user (and API) activity as XML audit events conforming to the `event-logging` XML schema.
  User logs aim to record what the user was attempting to do, e.g. _Delete an XSLT filter_, in a single log event even if this would encompass many application log events.
  These logs are typically sent back into Stroom to be stored and indexed so that they can be queried in the same way as other data in Stroom.
  All events are logged at the `INFO` level.

* **Stroom-Proxy Only**

  * **Receive logs** - These logs record all requests on Stroom-Proxy's `/datafeed` endpoint.
    All events are logged at the `INFO` level.
    The logs record the type of event:

    * `RECEIVE` - Data that has been successfully received by Stroom-Proxy.
    * `REJECT` - Data that has been rejected by a receipt policy or Feed status setting.
      The client will receive an error response when data is rejected.
    * `DROP` - Data that has been silently dropped by Stroom-Proxy.
      The client will receive a `200` response as if it had been successfully received.
    * `ERROR` - An unexpected error occurred while receiving the data.

  * **Send logs** - These logs record all requests made by Stroom-Proxy to a downstream HTTP forward destination.
    All events are logged at the `INFO` level.
    The logs record the type of event:
    * `SEND` - The data has been successfully forwarded to the destination.
    * `ERROR` - An unexpected error occurred while receiving the data.


### Log Levels

Log levels control the granularity of log events that get logged.
They are mainly relevant to application logging as it allows the amount of logging to be increased when debugging issues.

The following log levels are used in descending order of importance:

* `OFF` - No logging is output.

* `ERROR` - Used for logging expected and unexpected errors.

* `WARN` - Used for logging things that an admin should be made aware of but that are not errors.

* `INFO` - Used to log informational messages for low frequency events.
  `INFO` messages are typically aimed at an administrator audience.

* `DEBUG` - Used to log more detail than `INFO`, likely recording the inner workings of the application and variable values.
  These messages may be higher frequency so will produce more log output.
  `DEBUG` messages are typically intended for a developer audience.
  `DEBUG` should only be set for specific classes, not application wide due to the amount of logging it will produce.

* `TRACE` - The finest level of logging available.
  This will potentially produce a very large amount of logging as it is often used inside large code loops.
  `TRACE` messages are intended for a developer audience.

Setting a log level will also set all log levels above it in the list above, e.g. setting the level at `WARN` will result in `WARN` and `ERROR` messages being output.


## Logging in the Configuration File

### Loggers

A logger defines what will be logged.
It is essentially a combination of an identity and a log level.
The identity can be a Class name (e.g. `stroom.security.impl.SecurityFilter`), a package name (e.g. `stroom.security`) or a custom logger name (e.g. `event-logging`).

{{% note %}}
It is likely that you will not need to change the log settings unless specifically asked to by one of the developers or you have a good understanding of the underlying application code.
{{% /note %}}

The following is an example of logging configuration:

```yaml
logging:
  # The root (or default) level used unless overridden
  level: WARN
  loggers:
    # All stroom (& stroom-proxy) code will log at INFO
    # This is an example of configuring package level logging.
    stroom: INFO
    # Logs useful information about the DropWizard framework when booting stroom (& stroom-proxy)
    io.dropwizard: INFO
    # Logs useful information about the jetty server when booting stroom
    org.eclipse.jetty: INFO
    # Set this to INFO if you want to log all REST request/responses with headers/payloads.
    # This is an example of configuring class level logging.
    org.glassfish.jersey.logging.LoggingFeature: OFF
    # Logs summary information about FlyWay database migrations
    org.flywaydb: INFO
```


### Log Appenders

An appender defines an output for all messages that match the criteria for that logger.
Typically an appender will be either the console appender that logs to (`STDOUT`) or a file appender that logs to one or more file(s).
The appender controls things like the format of the log messages output, the structure of the file name and any file rolling/compressing behaviour.

An appender can be defined against a specific logger (as is the case for the `event-logging` logger/appender, but typically one of more root level appenders are defined that will be the default appender(s) for all loggers unless they have their own appender defined.

```yaml
logging:
  level: WARN
  loggers:
    # A logger for the 'stroom' package with no specific appender
    stroom: INFO

    # A named logger with its own appender
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

    # Default appenders for all loggers except for where a logger has a dedicated non-additive appender
    # Here logs will go to two appenders.
    appenders:

      # Console appender that logs to stdout
    - type: console
      # Multi-coloured log format for console output
      logFormat: "%highlight(%-6level) [%d{\"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'\",UTC}] [%green(%t)] %cyan(%logger) - %X{code} %msg %n"
      timeZone: UTC

      # File appender
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


{{% see-also %}}
For a detailed description of the logging configuration, see {{< external-link "Dropwizard Logging Configuration" "https://www.dropwizard.io/en/stable/manual/configuration.html#logging" >}}.
{{% /see-also %}}


### Console Appender

The console appender is typically only used when the application is running as a foreground process, i.e. in a Docker container (so that logging can be captured by Docker's logging driver) or in development.
The following is an example of a console appender in the Stroom `config.yml` file:

```yaml
logging:
  level: WARN
  loggers:
    # ...

  # Appenders that will apply to all loggers that don't have an appender 
  appenders:
    - type: console
      # Multi-coloured log format for console output
      logFormat: "%highlight(%-6level) [%d{\"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'\",UTC}] [%green(%t)] %cyan(%logger) - %X{code} %msg %n"
      timeZone: UTC
```


### File Appender

A file appender will append log messages to a file.
The file can optionally be rolled based on 

```yaml
logging:
  level: WARN
  loggers:
    # ...

  # Appenders that will apply to all loggers that don't have an appender 
  appenders:

      # Files rolled every minute.
      # This is a typicaly configuration where rolled logs will be sent uncompressed to Stroom then deleted.
    - type: file
      # The path and file name of the active log file being appended to
      currentLogFilename: logs/app/app.log
      # Rolled and gzipped every minute
      archivedLogFilenamePattern: logs/app/app-%d{yyyy-MM-dd'T'HH:mm}.log.gz
      # Number of rolled files to keep (one week using minute files)
      archivedFileCount: 10080
      logFormat: "%-6level [%d{\"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'\",UTC}] [%t] %logger - %X{code} %msg %n"
      # Number of messages to buffer before blocking
      queueSize: 256
      discardingThreshold: 0

      # Rolled hourly or when size reaches 100MB
    - type: file
      currentLogFilename: logs/app.log
      discardingThreshold: 0
      archivedLogFilenamePattern: logs/app-%d{yyyy-MM-dd}.%i.log
      # Only keep 7 days worth. (Note: this is maximum number of time periods, not files)
      archivedFileCount: 7
      # Limit the size of each file
      maxFileSize: "100MB"
      # Set a limit on the total size for all log files
      totalSizeCap: "10GB"
      logFormat: "%-6level [%d{\"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'\",UTC}] [%t] %logger - %X{code} %msg %n"
```


#### `discardingThreshold`

The default file appender is asynchronous, so will queue messages so that the application carry on while another thread writes the messages to the file.
`queueSize` controls the size of this buffer.
`discardingThreshold` controls the threshold for when `TRACE`, `DEBUG` and `INFO` messages will start to be discarded.
If `discardingThreshold` is set to `0`, no messages will be discarded and if the queue fills up, the application will be blocked until the queued messages can be written to file.
The value of `discardingThreshold` is remaining capacity of the queue that will trigger discards.
For example, if `queueSize` is set to `1000` and `discardingThreshold` is set to `200`, messages will start being discarded when the queue has `800` items on it, i.e. a remaining capacity of `200`.

A larger `queueSize` means that the application can better cope with surges in logging or contention on the file IO, but at the risk of having more logs in memory that will be lost in the event of an unplanned outage.


#### `archivedLogFilenamePattern`

This property controls both the name and path of the archived files, but the rolling time interval.
Setting a file extension of `.gz` will also instruct the file appender to compress the rolled files using gzip compression.
Setting a file extension of `.zip` will also instruct the file appender to compress the rolled files using Zip compression.

* Time based rolling
  * `logs/app/app-%d{yyyy-MM-dd'T'HH:mm}.log.gz` - Minute rolled files.
  * `logs/app/app-%d{yyyy-MM-dd'T'HH}.log.gz` - Hour rolled files.
  * `logs/app/app-%d{yyyy-MM-dd}.log.gz` - Daily rolled files.

* Time and size based rolling
  * `logs/app/app-%d{yyyy-MM-dd'T'HH}.%i.log.gz` - Files rolled daily and by size (set by `maxFileSize`).
    When the `maxFileSize` is reached within the same time interval as an existing rolled file, `%i` will be set to the next integer value (starting from `0`).

* Size based rolling
  * `logs/app/app-%i.log.gz` - Size rolled files.
    See warning below.

{{% warning %}}
Rolling based on size alone is not recommended as this involves renaming all the existing rolled files on each roll event.
From the Logback documentation:
>Given that file renaming is a relatively slow process and is fraught with problems, we consider FixedWindowRollingPolicy as a deprecated policy and do not recommend its use.
{{% /warning %}}



#### `archivedFileCount`

This property controls the number of archived files that are retained, however it is a little confusing.

For time and size rolling and time only rolling it is actually setting the maximum number of time periods to keep, **not** the maximum number of files.

For example, if `archivedLogFilenamePattern` is set to `logs/app/app-%d{yyyy-MM-dd'T'HH}.%i.log.gz` and `archivedFileCount` is set to `2` then you will have up to two hours worth of logs, regardless of the number of files in that period.

```text
logs/app/app-2026-09-08T15.0.log.gz
logs/app/app-2026-09-08T15.1.log.gz
logs/app/app-2026-09-08T16.0.log.gz
logs/app/app-2026-09-08T16.1.log.gz
logs/app/app-2026-09-08T16.2.log.gz
```

For size based rolling it directly controls the maximum number of rolled files.

For example, if `archivedLogFilenamePattern` is set to `logs/app/app-%i.log.gz` and `archivedFileCount` is set to `5` then you will have up to 5 rolled files.

```text
logs/app/app-1.log.gz
logs/app/app-2.log.gz
logs/app/app-3.log.gz
logs/app/app-4.log.gz
logs/app/app-5.log.gz
```

{{% warning %}}
Log file rolling is event based, so a file will only roll when a new message arrives that would require a roll to happen.
This means that if the application is idle for a long period with no log output then the un-rolled file will remain active until a new message arrives to trigger it to roll. For example, if Stroom is unused overnight, then the last log message from the night before will not be rolled until a new messages arrive in the morning.

For this reason, `archivedFileCount` should be set to a value that is greater than the maximum time the application may be idle, else rolled log files may be deleted as soon as they are rolled.
{{% /warning %}}


#### `totalSizeCap`

This property limits the total size taken up by the log files.
It is useful when you want a hard cap on log storage to avoid filling up a disk.
When this limit is breached old rolled files will be deleted.


### `logFormat`

`logFormat` controls the format of each log message.
The following are some examples of different formats:

Using colour codes for colourful terminal logging.
Colour codes should not be used in file logging.

`%highlight(%-6level) [%d{\"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'\",UTC}] [%green(%t)] %cyan(%logger) - %X{code} %msg %n`

Monochrome logging for file appender use.

`%-6level [%d{\"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'\",UTC}] [%t] %logger - %X{code} %msg %n`

A simple format that only outputs the log message.
This is used for loggers like `event-logging`

`%msg%n`

The format for an access/request log.

`%h %l "%u" [%t] "%r" %s %b "%i{Referer}" "%i{User-Agent}" %D`

{{% note %}}
If the value of `%msg` contains new line characters then a log message can span multiple lines.
{{% /note %}}

{{% see-also %}}
For details of the pattern variables used in `logFormat` value, see {{< external-link "Logback Pattern Layout" "https://logback.qos.ch/manual/layouts.html#ClassicPatternLayout" >}}.
{{% /see-also %}}


### JSON Logging

By default logging output is formatted using the `logFormat` property described above.

In some instances it may be preferable to output the logs in JSON format.

By default, JSON format logging is output as JSON Lines format, i.e. one JSON object per line, with objects delimited by line breaks.

The following are examples of how to configure JSON logging for the various loggers.


#### Request/Access Log

Configuration for Stroom and Stroom-Proxy's request/access logs.

```yaml
server:
  requestLog:
    appenders:
        # Log appender for the web server request logging
      - type: file
        currentLogFilename: logs/access/access.log
        discardingThreshold: 0
        # Rolled and gzipped every minute
        archivedLogFilenamePattern: logs/access/access-%d{yyyy-MM-dd'T'HH:mm}.log.gz
        archivedFileCount: 10080
        # This configures the JSON layout
        layout:
          # Note: Uses a specific type for access logging.
          type: access-json
          timestampFormat: "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
```

This produces logs like (shown indented and multi-line for clarity):

```json
{
  "timestamp": "2026-09-07T11:19:49.741Z",
  "contentLength": 64,
  "method": "POST",
  "protocol": "HTTP/1.1",
  "remoteAddress": "[0:0:0:0:0:0:0:1]",
  "requestTime": 157,
  "uri": "/datafeed",
  "status": 200,
  "userAgent": "curl/8.21.0"
}
```


#### Application Log

Configuration for Stroom and Stroom-Proxy's general application logging.

```yaml
logging:
  level: ${STROOM_LOGGING_LEVEL:- ERROR}
  loggers:
    stroom: INFO
    # ...
  appenders:
    - type: file
      currentLogFilename: logs/app/app.log
      threshold: ALL
      queueSize: 256
      discardingThreshold: 0
      archive: true
      archivedLogFilenamePattern: logs/app/app-%d{yyyy-MM-dd'T'HH:mm}.log
      archivedFileCount: 10
      timeZone: UTC
      # JSON layout
      layout:
        type: json
        timestampFormat: "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
```

This produces logs like (shown indented and multi-line for clarity):

```json
{
  "timestamp": "2026-09-07T11:19:49.601Z",
  "level": "INFO",
  "thread": "dw-147 - POST /datafeed",
  "logger": "stroom.dropwizard.common.AbstractJerseyClientFactory",
  "message": "Building and registering jersey client for name 'DEFAULT', DropWizard metric name 'stroom-proxy_jersey_client_default', userAgent 'stroom-proxy/SNAPSHOT'"
}
```


#### Stroom-Proxy Receive Log

This is the configuration for Stroom-Proxy's `receive` log that logs all data received.

```yaml
logging:
  level: WARN
  loggers:
    stroom: INFO
    # ...
    "receive":
      level: INFO
      # Stops it logging to other loggers.
      additive: false
      appenders:
        - type: file
          currentLogFilename: logs/receive/receive.log
          archivedLogFilenamePattern: logs/receive/receive-%d{yyyy-MM-dd'T'HH:mm}.log
          timeZone: UTC
          #...
          # JSON layout
          layout:
            type: json
            timestampFormat: "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
            customFieldNames:
              # Sets the name of the sub-object in the JSON log event (default is 'mdc')
              mdc: "receive"
```

To enable JSON logging for `receive` and `send` you must also set this property in the Stroom-Proxy `config.yml` file.

```yaml
proxyConfig:
  logStream:
    useMappedDiagnosticContext: true
```

This produces logs like (shown indented and multi-line for clarity):

```json
{
  "timestamp": "2026-09-07T11:15:50.012Z",
  "level": "INFO",
  "thread": "dw-147 - POST /datafeed",
  "logger": "receive",
  "message": "OK",
  "receive": {
    "meta.Type": "Raw Events",
    "meta.RemoteAddress": "[0:0:0:0:0:0:0:1]",
    "stroomStatusCode": "0",
    "meta.RemoteHost": "[0:0:0:0:0:0:0:1]",
    "eventType": "RECEIVE",
    "meta.DataReceiptRule": null,
    "meta.Environment": "DEV",
    "url": "/datafeed",
    "meta.GUID": "fd8acd55-ab1c-4243-ad02-75950e1ee34f",
    "duration": "145",
    "meta.ReceiptId": "1788779749866_0000_P_Proxy-f7dfef15-b89a-4b23-900f-ad39208b1868",
    "meta.RemoteDN": null,
    "bytes": "38",
    "meta.System": "FOO",
    "httpResponseCode": "200",
    "meta.RemoteCertExpiry": null,
    "meta.Feed": "TEST_FEED"
  }
}
```

`eventType` can be one of `RECEIVE`, `REJECT`, `DROP`, `ERROR`.

`meta.` prefixed keys contain the meta data for the keys defined in the property `proxyConfig.logStream.metaKeys`.


#### Stroom-Proxy Send Log

This is the configuration for Stroom-Proxy's `send` log that logs all data forwarded to a downstream host.

```yaml
logging:
  level: WARN
  loggers:
    stroom: INFO
    # ...
    "send":
      level: INFO
      # Stops it logging to other loggers.
      additive: false
      appenders:
        - type: file
          currentLogFilename: logs/send/send.log
          archivedLogFilenamePattern: logs/send/send-%d{yyyy-MM-dd'T'HH:mm}.log
          timeZone: UTC
          #...
          # JSON layout
          layout:
            type: json
            timestampFormat: "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
            customFieldNames:
              # Sets the name of the sub-object in the JSON log event (default is 'mdc')
              mdc: "send"
```

To enable JSON logging for `receive` and `send` you must also set this property in the Stroom-Proxy `config.yml` file.

```yaml
proxyConfig:
  logStream:
    useMappedDiagnosticContext: true
```

This produces logs like (shown indented and multi-line for clarity):

```json
{
  "timestamp": "2026-09-07T11:20:06.254Z",
  "level": "INFO",
  "thread": "forward - upstream 1",
  "logger": "send",
  "message": "OK",
  "send": {
    "meta.Type": "Raw Events",
    "meta.RemoteAddress": "[0:0:0:0:0:0:0:1]",
    "stroomStatusCode": "0",
    "meta.RemoteHost": "[0:0:0:0:0:0:0:1]",
    "eventType": "SEND",
    "meta.DataReceiptRule": null,
    "meta.Environment": "DEV",
    "url": "http://localhost:8080/datafeed",
    "meta.GUID": "95aa59a7-eabb-403b-982b-33bea2b798f7",
    "duration": "53",
    "meta.ReceiptId": "1788779989589_0000_P_Proxy-f7dfef15-b89a-4b23-900f-ad39208b1868",
    "meta.RemoteDN": null,
    "bytes": "805",
    "meta.System": "FOO",
    "httpResponseCode": "200",
    "meta.RemoteCertExpiry": null,
    "meta.Feed": "TEST_FEED"
  }
}
```

`eventType` can be `SEND` or `ERROR`.

`meta.` prefixed keys contain the meta data for the keys defined in the property `proxyConfig.logStream.metaKeys`.

