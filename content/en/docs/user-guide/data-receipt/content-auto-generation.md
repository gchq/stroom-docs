---
title: "Content Auto-Creation"
linkTitle: "Content Auto-Creation"
weight: 40
date: 2026-02-05
tags: 
description: >
 Describes how Stroom can auto-generate Feed names and content (i.e. Feeds and Pipelines) upon receipt of new data.
---

The aim of Content Auto-Generation is to simplify the process of client systems sending data into Stroom.
Instead of having to pre-create a Feed {{< stroom-icon "document/Feed.svg" >}} and Pipeline {{< stroom-icon "document/Pipeline.svg" >}} before a client can send data, Content Templates can be created to auto-create the content on receipt of the first {{< glossary "Stream" >}}.

It also removes the need for the client to supply a Feed {{< stroom-icon "document/Feed.svg" >}} name.
Instead the client system can provide a set of mandatory headers to describe their data, which can then be used to generate a Feed name.

Content Auto-Creation relies on a number aspects in order to function:

* **Feed name generation** - Generating a Feed name based on a set of mandatory headers and a Feed name template.
* **Content Templates** - A set of expression rules to match against incoming data, with associated template content to generate when there is a match.


## Feed Name Generation

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


## Content Templates

Content Templates are a set of expression rules with associated template content to generate when the rule matches.

In order to use Content Templates, the property `appConfig.autoContentCreation.enable` must be set to `true`.

Content Templates can be managed in the Content Templates screen that is accessed from the main menu:

{{< stroom-menu "Administration" "Content Templates" >}}

{{< image "user-guide/data-receipt/ContentTemplates.png" "900x" >}}The Content Templates screen{{</ image >}}

This screen allows a user with the _Manage Content Templates_ application permission to create a number of content templates.

The settings available on a Content Template are as follows:

Template Name
: A name for the template to aid the administrator when looking through a list of different templates.

Descriptions
: An optional and more detailed description of the purpose of the template.

Template Type
: Determines how the Pipeline specified by the  _Pipeline_ setting is used.

  * `INHERIT_PIPELINE` - A new pipeline will be created that inherits from the pipeline specified by _Pipeline_.
    The new pipeline will be created in the explorer tree folder defined by `(app|proxy)Config.receive.destinationExplorerPathTemplate`.

  * `PROCESSOR_FILTER` - A new processor filter will be added to the existing pipeline specified in the template.
    No new documents will be created.

Copy Pipeline Element Dependencies
: If _Copy Pipeline Element Dependencies_ is ticked and the _Template Type_ is `INHERIT_PIPELINE`, any documents that are direct dependencies of the specified Pipeline (e.g. Text Converter {{< stroom-icon "document/TextConverter.svg" >}} or XSLT {{< stroom-icon "document/XSLT.svg" >}}) will be copied into the destination folder.
  The new Pipeline will have its dependencies changed to use the copied dependencies, allowing them to be edited without affecting the parent Pipeline.

Pipeline
: An existing Pipeline to either inherit from or add a processor filter to, depending on the _Template Type_.

Processor Priority
: The priority to assign to the pipeline processor when created.
  The higher the number the higher the priority.
  Value must be between 1 and 100.
  The default priority is 10.

Processor Max Concurrent Tasks
: The maximum number of concurrent tasks to assign to the pipeline processor when created. Zero means un-bounded.

Expression
: Each template has an expression that will be used to match on the headers when auto-generation of content has been triggered.
  The template expressions are evaluated in order from the top, the first to match the data is used.

  If a template's expression matches, content will be created according to settings in the template.






