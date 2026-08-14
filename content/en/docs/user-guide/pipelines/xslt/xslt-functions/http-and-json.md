---
title: "HTTP & JSON"
linkTitle: "HTTP & JSON"
weight: 60
date: 2026-08-14
tags:
  - xslt
description: >
  XSLT functions for http and json.
---

## fetch-json()

```text
fetch-json(String url)
fetch-json(String url, String clientConfig)
```

* `fetch-json(String url)` - Simplistic version of `http-call` that sends a request to the passed `url` and converts the JSON response body to XML using `json-to-xml`.
* `fetch-json(String url, String clientConfig)` - As above, with the HTTP client configured using the same JSON object as [`http-call()`](#clientconfig), e.g. to supply SSL configuration.


## http-call()

Executes an HTTP(S) request to a remote server and returns the response.

```text
http-call(String url, [String headers], [String mediaType], [String data], [String clientConfig])
```

The arguments are as follows:

* `url` - The URL to send the request to.
* `headers` - A newline (`&#10;`) delimited list of HTTP headers to send.
  Each header is of the form `key:value`.
* `mediaType` - The media (or MIME) type of the request `data`, e.g. `application/json`.
  If not set `application/json; charset=utf-8` will be used.
* `data` - The data to send.
  The data type should be consistent with `mediaType`.
  Supplying the `data` argument means a POST request method will be used rather than the default GET.
* `clientConfig` - A JSON object containing the configuration for the HTTP client to use, including any SSL configuration.

The function returns the response as XML with namespace `stroom-http`.
The XML includes the body of the response in addition to the status code, success status, message and any headers.


### `clientConfig`

The client can be configured using a JSON object containing various optional configuration items.
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


### Example output

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


### Example usage

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


## json-to-xml()

Returns an XML representation of the supplied JSON value for use in XPath expressions

```text
json-to-xml(String json)
```
