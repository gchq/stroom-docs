---
title: "Simple Java Client"
linkTitle: "Simple Java Client"
#weight:
date: 2022-01-13
tags: 
description: >
  A simple Java client for sending data files to Stroom.

---

The `stroom-java-client` provides an example Java client that can:

* Read a zip, gzip or uncompressed an input file.
* Perform a HTTP post of data with zip, gzip or uncompressed compression.
* Pass down arguments on the command line as HTTP request arguments.
* Supports HTTP and HTTPS with 1 or 2 way authentication.

*(N.B. arguments must be in lower case).*

To use the example client first compile the Java code:

{{< command-line "user" "localhost" >}}
javac DataFeedClient.java
{{</ command-line >}}


## Example HTTP Post:

{{< command-line "user" "localhost" >}}
java \
-classpath . \
DataFeedClient \
inputfile=datafeed \
url=http://<Stroom_HOST>/stroom/datafeed \
system=EXAMPLE-SYSTEM \
environment=DEV \
feed=EXAMPLE-FEED
{{</ command-line >}}


## Example HTTPS With 1 way SSL authentication:

{{< command-line "user" "localhost" >}}
java \
-classpath . \
-Djavax.net.ssl.trustStore=ca.jks \
-Djavax.net.ssl.trustStorePassword=capass \
DataFeedClient \
inputfile=datafeed \
url=https://<Stroom_HOST>/stroom/datafeed \
system=EXAMPLE-SYSTEM \
environment=DEV \
feed=EXAMPLE-FEED
{{</ command-line >}}


## Example HTTPS With 2 way SSL authentication:

{{< command-line "user" "localhost" >}}
java \
-classpath . \
-Djavax.net.ssl.trustStore=ca.jks \
-Djavax.net.ssl.trustStorePassword=capass \
-Djavax.net.ssl.keyStore=example.jks \
-Djavax.net.ssl.keyStorePassword=<PASSWORD> \
DataFeedClient \
inputfile=datafeed url=https://<Stroom_HOST>/stroom/datafeed \
system=EXAMPLE-SYSTEM \
environment=DEV \
feed=EXAMPLE-FEED
{{</ command-line >}}
