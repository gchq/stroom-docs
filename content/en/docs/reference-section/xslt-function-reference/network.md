---
title: "Network Functions"
linkTitle: "Network Functions"
#weight:
date: 2025-09-25
tags: 
description: >
  Functions relating to networking (host names, IP addresses, etc.) or making remote calls.
---

<!-- 
The xslt-func shortcode outputs all the XsltFunctionDef annotation content for the function.
You can add any additional content for the function (e.g. examples) underneath the shortcode call.
-->

## cidr-to-numeric-ip-range

{{< xslt-func "cidr-to-numeric-ip-range" >}}


### Example

**XSLT:**
```xml
<xsl:variable name="range" select="stroom:cidr-to-numeric-ip-range('192.168.1.0/24')" as="xs:string*" />
<Range>
  <Start><xsl:value-of select="$range[1]" /></Start>
  <End><xsl:value-of select="$range[2]" /></End>
</Range>
```

**XML:**

```xml
<Range>
  <Start>3232235776</Start>
  <End>3232236031</End>
</Range>
```


## fetch-json

{{< xslt-func "fetch-json" >}}


## host-address

{{< xslt-func "host-address" >}}


## host-name

{{< xslt-func "host-name" >}}


## http-call

{{< xslt-func "http-call" >}}


### `clientConfig`

The HTTP client can be configured using the `clienConfig` argument.
This is a JSON object containing various optional configuration items.
The following is an example of the client configuration object with all keys populated.

```json
{
  "callTimeout": "PT30S",
  "connectionTimeout": "PT30S",
  "followRedirects": false,
  "followSslRedirects": false,
  "httpProtocols": [
    "http/2",
    "http/1.1"
  ],
  "readTimeout": "PT30S",
  "retryOnConnectionFailure": true,
  "sslConfig": {
    "keyStorePassword": "password",
    "keyStorePath": "/some/path/client.jks",
    "keyStoreType": "JKS",
    "trustStorePassword": "password",
    "trustStorePath": "/some/path/ca.jks",
    "trustStoreType": "JKS",
    "sslProtocol": "TLSv1.2",
    "hostnameVerificationEnabled": false
  },
  "writeTimeout": "PT30S"
}
```

If you are using two-way SSL then you may need to set the protocol to `HTTP/1.1`.

```json
  "httpProtocols": [
    "http/1.1"
  ],
```


### Example Output

The following is an example of the XML returned from the `http-call` function:

```xml
<response xmlns="stroom-http">
  <successful>true</successful>
  <code>200</code>
  <message>OK</message>
  <headers>
    <header>
      <key>cache-control</key>
      <value>public, max-age=600</value>
    </header>
    <header>
      <key>connection</key>
      <value>keep-alive</value>
    </header>
    <header>
      <key>content-length</key>
      <value>108</value>
    </header>
    <header>
      <key>content-type</key>
      <value>application/json;charset=iso-8859-1</value>
    </header>
    <header>
      <key>date</key>
      <value>Wed, 29 Jun 2022 13:03:38 GMT</value>
    </header>
    <header>
      <key>expires</key>
      <value>Wed, 29 Jun 2022 13:13:38 GMT</value>
    </header>
    <header>
      <key>server</key>
      <value>nginx/1.21.6</value>
    </header>
    <header>
      <key>vary</key>
      <value>Accept-Encoding</value>
    </header>
    <header>
      <key>x-content-type-options</key>
      <value>nosniff</value>
    </header>
    <header>
      <key>x-frame-options</key>
      <value>sameorigin</value>
    </header>
    <header>
      <key>x-xss-protection</key>
      <value>1; mode=block</value>
    </header>
  </headers>
  <body>{"buildDate":"2022-06-29T09:22:41.541886118Z","buildVersion":"SNAPSHOT","upDate":"2022-06-29T11:06:26.869Z"}</body>
</response>
```


### Example Usage

This is an example of how to use the function call in your XSLT.
It is recommended to place the `clientConfig` JSON in a {{< glossary "Dictionary" >}} to make it easier to edit and to avoid having to escape all the quotes.

```xml
  ...
  <xsl:template match="record">
    ...
    <!-- Read the client config from a Dictionary into a variable -->
    <xsl:variable name="clientConfig" select="stroom:dictionary('HTTP Client Config')" />
    <!-- Make the HTTP call and store the response in a variable -->
    <xsl:variable name="response" select="stroom:http-call('https://reqbin.com/echo', null, null, null, $clientConfig)" />
    <!-- Apply 'response' templates to the response -->
    <xsl:apply-templates mode="response" select="$response" />
    ...
  </xsl:template>
  
  <xsl:template mode="response" match="http:response">
    <!-- Extract just the body of the response -->
    <val><xsl:value-of select="./http:body/text()" /></val>
  </xsl:template>
  ...
```


## ip-in-cidr

{{< xslt-func "ip-in-cidr" >}}




## numeric-ip

{{< xslt-func "numeric-ip" >}}

