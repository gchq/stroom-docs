---
title: "Java Keystores"
linkTitle: "Java Keystores"
weight: 80
date: 2021-07-27
tags: 
  - keystore
  - truststore
  - java
description: >
  How to create java key/trust stores for use with Java client applications.
---

There are many times when you may wish to create a Java keystore from certificates and keys and vice versa. This guide aims to explain how this can be done.

## Import
If you need to create a Java keystore from a .crt and .key then this is how to do it.

### Convert your keys to der format

{{< command-line >}}
openssl x509 -in <YOUR KEY>.crt -inform PEM -out <YOUR KEY>.crt.der -outform DER
openssl pkcs8 -topk8 -nocrypt -in <YOUR KEY>.key -inform PEM -out <YOUR KEY>.key.der -outform DER
{{< /command-line >}}

### ImportKey
Use the `ImportKey` class in the `stroom-java-client` library to import keys.

For example:

{{< command-line >}}
java ImportKey keystore=<YOUR KEY>.jks keypass=<YOUR PASSWORD> alias=<YOUR KEY> keyfile=<YOUR KEY>.key.der certfile=<YOUR KEY>.crt.der
keytool -import -noprompt -alias CA -file <CA CERT>.crt -keystore ca.jks -storepass ca
{{< /command-line >}}

## Export
### ExportKey
Use the `ExportKey` class in the `stroom-java-client` library to export keys. If you would like to use curl or similar application but only have keys contained within a Java keystore then they can be exported.

For example:

{{< command-line >}}
java ExportKey keystore=<YOUR KEY>.jks keypass=<YOUR PASSWORD> alias=<YOUR KEY>
{{< /command-line >}}

This will print both the key and certificate to standard out. This can then be copied into a PEM file for use with cURL or other similar application.
