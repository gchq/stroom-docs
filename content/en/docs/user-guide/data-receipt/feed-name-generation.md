---
title: "Feed Name Generation"
linkTitle: "Feed Name Generation"
weight: 30
date: 2026-03-18
tags: 
description: >
  The auto-generation of Feed names using a Feed name template and various header values.
---

Auto-generation of Feed names allows Stroom and Stroom Proxy to generate the Feed name based on a configured template and the values of various mandatory and optional headers.
This feature was conceived for [Data Feed Identities]({{< relref "data-feed-identities" >}}) but can be used in isolation if required.

When the property `(app|proxy)Config.receive.feedNameGenerationEnabled` is set to `true`, the `Feed` header is no longer required on data receipt and auto-generation of a Feed name will be attempted.

When data is supplied without the `Feed` header, the meta keys specified in `(app|proxy)Config.receive.feedNameGenerationMandatoryHeaders` become mandatory.
If the mandatory headers are not supplied, the data will be rejected.

The property `(app|proxy)Config.receive.feedNameTemplate` is used to control the format of the generated Feed {{< stroom-icon "document/Feed.svg" >}} name.
The template uses values from the headers, so should be configured in tandem with `.receive.feedNameGenerationMandatoryHeaders`, though can use optional headers that the client may or may not supply.

If the template parameter is not in the headers, then it will be replaced with nothing.
The variables in the template (e.g. `${accountId}`) are case-insensitive.

If enabled, Feed name generation happens on data receipt in both Stroom-Proxy and Stroom.
You should therefore ensure the configuration for this feature is identical in Stroom and Stroom-Proxy.

The default configuration for Feed name generation is:

```yaml
appConfig|proxyConfig: # applicable to both appConfig: and proxyConfig:
  receive: 
    ...
    feedNameGenerationEnabled: false
    feedNameGenerationMandatoryHeaders:
    - "AccountId" # A unique identifier for the owner of the system sending the data.
    - "Component" # The system/component that is sending the data (an account may have multiple).
    - "Format" # The data format (e.g. XML, JSON, etc.).
    - "Schema" # The schema that the data conforms to (e.g. event-logging).
    feedNameTemplate: "${accountid}-${component}-${format}-${schema}"
```

{{% see-also %}}
For more explanation of the `receive` configuration branch, see [Receive Configuration]({{< relref "common-configuration#receive-configuration" >}}).
{{% /see-also %}}

Assuming the above default configuration and that the client sends the following headers:

```properties
AccountId: 1234
Component: av-scanner
Format: XML
Schema: event-logging
```

This will result in an auto-generated Feed name of `1234-AV_SCANNER-XML-EVENT_LOGGING`.

{{% note %}}
When a template variable is replaced with a value from the headers, it is converted to upper case and any characters that are NOT in the regular expression character class `[A-Z0-9_]`, will be replaced by a `_` character.

Any static text in the template will also be converted to upper case and the supported characters for static text are `[A-Z0-9_-]`, with all other characters being replaced with a `_`.
{{% /note %}}
