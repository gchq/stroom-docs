---
title: "Writing an XSLT Translation"
linkTitle: "Writing a Translation"
#weight:
date: 2022-06-07
tags:
  - processing
  - feed
description: >
  This HOWTO will take you through the production of an XSLT for a feed, including issues such as event filtering, common errors and testing.
---

<!-- Created with Stroom v6.1-beta.16 -->

{{% see-also %}}
[HOWTO - Event Processing]({{< relref "ProcessingHowTo" >}})
{{% /see-also %}}


## Introduction

This document is intended to explain how and why to produce a translation within stroom and how the translation fits into the overall processing within stroom.
It is intended for use by the developers/admins of client systems that want to send data to stroom and need to transform their events into event-logging XML format.
It's not intended as an XSLT tutorial so a basic XSLT knowledge must be assumed.
The document will contain potentially useful XSLT fragments to show how certain processing activities can be carried out.
As with most programming languages, there are likely to be multiple ways of producing the same end result with different degrees of complexity and efficiency.
Examples here may not be the best for all situations but do reflect experience built up from many previous translation jobs.

The document should be read in conjunction with other online stroom documentation, in particular [Event Processing]({{< relref "ProcessingHowTo" >}}).


## Translation Overview

The translation process for raw logs is a multi-stage process defined by the processing pipeline:


### Parser

The parser takes raw data and converts it into an intermediate XML document format.
This is only required if source data is not already within an XML document.
There are various standard parsers available (although not all may be available on a default stroom build) to cover the majority of standard source formats such as CSV, TSV, CSV with header row and XML fragments.

The language used within the parser is defined within an XML schema located at `XML Schemas / data-splitter / data-splitter v3.0` within the tree browser.
The data splitter schema may have been provided as part of the core schemas content pack.
It is not present in a vanilla stroom.
The language can be quite complex so if non-standard format logs are being parsed, it may be worth speaking to your stroom sysadmin team to at least get an initial parser configured for your data.

Stroom also has a built-in parser for JSON fragments.
This can be set either by using the {{< pipe-elm "CombinedParser" >}} and setting the `type` property to JSON or preferably by just using the {{< pipe-elm "JSONParser" >}}.

The parser has several minor limitations.
The most significant is that it's unable to deal with records that are interleaved.
This occasionally happens within multi-line syslog records where a syslog server receives the first x lines of record A followed by the first y lines of record B, then the rest of record A and finally the rest of record B (or the start of record C etc).
If data is likely to arrive like this then some sort of pre-processing within the source system would be necessary to ensure that each record is a contiguous block before being forwarded to stroom.

The other main limitation of the parser is actually its flexibility.
If forwarding large streams to stroom and one or more regexes within the parser have been written inefficiently or incorrectly then it's quite possible for the parser to try to read the entire stream in one go rather than a single record or part of a record.
This will slow down the overall processing and may even cause memory issues in the worst cases.
This is one of the reasons why the stroom team would prefer to be involved in the production of any non-standard parsers as mentioned above.


### XSLT

The actual translation takes the XML document produced by the parser and converts it to a new XML document format in what's known as "stroom schema format".
The current latest schema is documented at `XML Schemas / event-logging / event-logging v3.5.2` within the tree browser.
The version is likely to change over time so you should aim to use the latest non-beta version.


### Other Pipeline Elements

The pipeline functionality is flexible in that multiple XSLTs may be used in sequence to add decoration (e.g. Job Title, Grade, Employee type etc. from an HR reference database), schema validation and other business-related tasks.
However, this is outside the scope of this document and pipelines should not be altered unless agreed with the stroom sysadmins.
As an example, we've seen instances of people removing schema validation tasks from a pipeline so that processing appears to occur without error.
In practice, this just breaks things further down the processing chain.


## Translation Basics

Assuming you have a simple pipeline containing a working parser and an empty XSLT, the output of the parser will look something like this:

```xml
<?xml version="1.1" encoding="UTF-8"?>
<records
    xmlns="records:2"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xsi:schemaLocation="records:2 file://records-v2.0.xsd"
    version="2.0">
  <record>
    <data value="2022-04-06 15:45:38.737" />
    <data value="fakeuser2" />
    <data value="192.168.0.1" />
    <data value="1000011" />
    <data value="200" />
    <data value="Query success" />
    <data value="1" />
  </record>
</records>
```

The data nodes within the **record** node will differ as it's possible to have nested data nodes as well as named data nodes, but for a non-JSON and non-XML fragment source data format, the top-level structure will be similar.

The XSLT needed to recognise and start processing the above example data needs to do several things.
The following initial XSLT provides the minimum required function:

{{< code-block language="xml" >}}
<?xml version="1.1" encoding="UTF-8" ?>
<xsl:stylesheet
    xpath-default-namespace="records:2" 
    xmlns="event-logging:3" 
    xmlns:stroom="stroom"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    version="2.0">

  <xsl:template match="records">
    <Events
        xsi:schemaLocation="event-logging:3 file://event-logging-v3.5.2.xsd" Version="3.5.2">
      <xsl:apply-templates />
    </Events>
  </xsl:template>

  <xsl:template match="record">
    <Event>
      ...
    </Event>
  </xsl:template>
</xsl:stylesheet>
{{< /code-block >}}

The following lists the necessary functions of the XSLT, along with the line numbers where they're implemented in the above example:

* Match the source namespace - `line 3`;
* Specify the output namespace - `lines 4, 12`;
* Specify the namespace for any functions - `lines 5-8`;
* Match the top-level **records** node - `line 10`;
* Provide any output in stroom schema format - `lines 11, 14, 18-20`;
* Individually match subsequent **record** nodes - `line 17`.

This XSLT will generate the following output data:

```xml
<?xml version="1.1" encoding="UTF-8"?>
<Events
    xmlns="event-logging:3"
    xmlns:stroom="stroom"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xsi:schemaLocation="event-logging:3 file://event-logging-v3.5.2.xsd"
    Version="3.5.2">
  <Event>
    ...
  </Event>
  ...
<Events>
```

It's normally best to get this part of the XSLT correctly stepping before getting any further into the code.

Similarly for JSON fragments, the output of the parser will look like:

```xml
<?xml version="1.1" encoding="UTF-8"?>
<map xmlns="http://www.w3.org/2013/XSL/json">
  <map>
    <string key="version">0</string>
    <string key="id">2801bbff-fafa-4427-32b5-d38068d3de73</string>
    <string key="detail-type">xyz_event</string>
    <string key="source">my.host.here</string>
    <string key="account">223592823261</string>
    <string key="time">2022-02-15T11:01:36Z</string>
    <array key="resources" />
    <map key="detail">
      <number key="id">1644922894335</number>
      <string key="userId">testuser</string>
    </map>
  </map>
</map>
```

The following initial XSLT will carry out the same tasks as before:

{{< code-block language="xml" >}}
<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet
    xpath-default-namespace="http://www.w3.org/2013/XSL/json"
    xmlns="event-logging:3"
    xmlns:stroom="stroom"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    version="2.0">

  <xsl:template match="/map">
    <Events
        xsi:schemaLocation="event-logging:3 file://event-logging-v3.5.2.xsd" Version="3.5.2">
      <xsl:apply-templates />
    </Events>
  </xsl:template>

  <xsl:template match="/map/map">
    <Event>
      ...
    </Event>
  </xsl:template>
</xsl:stylesheet>
{{< /code-block >}}

The necessary functions of the XSLT, along with the line numbers where they're implemented in the above example as before:

* Match the source namespace - `line 3`;
* Specify the output namespace - `lines 4, 12`;
* Specify the namespace for any functions - `lines 5-8`;
* Match the top-level **/map** node - `line 10`;
* Provide any output in stroom schema format - `lines 11, 14, 18-20`;
* Individually match subsequent **/map/map** nodes - `line 17`.

This XSLT will generate the following output data which is identical to the previous output:

```xml
<?xml version="1.1" encoding="UTF-8"?>
<Events
    xmlns="event-logging:3"
    xmlns:stroom="stroom"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xsi:schemaLocation="event-logging:3 file://event-logging-v3.5.2.xsd"
    Version="3.5.2">
  <Event>
    ...
  </Event>
  ...
<Events>
```
Once the initial XSLT is correct, it's a fairly simple matter to populate the correct nodes using standard XSLT functions and a knowledge of XPaths.


## Extending the Translation to Populate Specific Nodes

The above examples of `<xsl:apply-templates match="..."/>` for an Event all point to a specific path within the XML document - often at `/records/record/` or at `/map/map/`.
XPath references to nodes further down inside the record should normally be made relative to this node.

Depending on the output format from the parser, there are two ways of referencing a field to populate an output node.

If the intermedia XML is of the following format:

```xml
<record>
  <data value="2022-04-06 15:45:38.737" />
  <data value="fakeuser2" />
  <data value="192.168.0.1" />
  ...
</record>
```

Then the developer needs to understand which field contains what data and then to reference based upon the index, e.g:

```xml
<IPAddress>
  <xsl:value-of select="data[3]/@value"/>
</IPAddress>
```

However, if the intermediate XML is of this format:

```xml
<record>
  <data name="time" value="2022-04-06 15:45:38.737" />
  <data name="user" value="fakeuser2" />
  <data name="ip" value="192.168.0.1" />
  ...
</record>
```

Then, although the first method is still acceptable, it's easier and safer to reference by @name:

```xml
<IPAddress>
  <xsl:value-of select="data[@name='ip']/@value"/>
</IPAddress>
```

This second method also has the advantage that if the field positions differ for different event types, the names will hopefully stay the same, saving the need to add `if TypeA then do X, if TypeB then do Y, ...` code into the XSLT.

More complex field references are likely to be required at times, particularly for data that's been converted using the internal JSON parser.
Assuming source data of:

```xml
<map>
  <string key="version">0</string>
  ...
  <array key="resources" />
  <map key="detail">
    <number key="id">1644922894335</number>
    <string key="userId">testuser</string>
  </map>
</map>
```

Then selecting the id field requires something like:

```xml
<xsl:value-of select="map[@key='detail']/number[@key='id']"/>
```

It's important at this stage to have a reasonable understanding of which fields in the source data provide what detail in terms of stroom schema values, which fields can be ignored and which can be used but modified to control the flow of the translation.
For example - there may be an IP address within the log, but is it of the device itself or of the client?
It's normally best to start with several examples of each event type requiring translation to ensure that fields are translated correctly.


## Structuring the XSLT

There are many different ways of structuring the overall XSLT and it's ultimately for the developer to decide the best way based upon the requirements of their own data.
However, the following points should be noted:

* When working on e.g a CreateDocument event, it's far easier to edit a 10-line template named **CreateDocument** than lines 841-850 of a template named **MainTemplate**.
Therefore, keep each template relatively small and helpfully named.
* Both the logic and XPaths required for EventTime and EventSource are normally common to all or most events for a given log.
Therefore, it usually makes sense to have a common EventTime and EventSource template for all event types rather than a duplicate of this code for each event type.
* If code needs to be repeated in multiple templates, then it's often simpler to move that code into a separate template and call it from multiple places.
This is often used for e.g. adding an Outcome node for multiple failed event types.
* Use comments within the XSLT even when the code appears obvious.
If nothing else, a comment field will ensure a newline prior to the comment once auto-formatted.
This allows the end of one template and the start of the next template to be differentiated more easily if each template is prefixed by something like `<!-- Template for EventDetail -->`.
Comments are also useful for anybody who needs to fix your code several years later when you've moved on to far more interesting work.
* For most feeds, the main development work is within the EventDetail node.
This will normally contain a lot of code effectively doing `if CreateDocument do X; if DeleteFile do Y; if SuccessfulLogin do Z; ...`.
From experience, the following type of XSLT is normally the easiest to write and to follow:

```xml
  <!-- Event Detail template -->
  <xsl:template name="EventDetail">
    <xsl:variable name="typeId" select="..."/>
      <EventDetail>
        <xsl:choose>
          <xsl:when test="$typeId='A'">
            <xsl:call-template name="Logon"/>
          </xsl:when>
          <xsl:when test="$typeId='B'">
            <xsl:call-template name="CreateDoc"/>
          </xsl:when>
          ...
        </xsl:choose>
      </EventDetail>
    </xsl:template>
```

* If in the above example, the various values of `$typeId` are sufficiently descriptive to use as text values then the **TypeId** node can be implemented prior to the `<xsl:choose>` to avoid specifying it once in each child template.
* It's common for systems to generate `Create/Delete/View/Modify/...` events against a range of different `Document/File/Email/Object/...` types.
Rather than looking at events such as `CreateDocument/DeleteFile/...` and creating a template for each, it's often simpler to work in two stages.
Firstly create templates for the `Create/Delete/...`  types within `EventDetail` and then from each of these templates, call another template which then checks and calls the relevant object template.
* It's also sometimes possible to take the above multi-step process further and use a common template for Create/Delete/View.
The following code assumes that the variable `${evttype}` is a valid schema action such as `Create/Delete/View`.
Whilst it can be used to produce more compact XSLT code, it tends to lose readability and makes extending the code for additional types more difficult.
The inner `<xsl:choose>` can even be simplified again by populating an `<xsl:element>` with `{objType}` to make the code even more compact and more difficult to follow.
There may occasionally be times when this sort of thing is useful but care should be taken to use it sparingly and provide plenty of comments.

```xml
  <xsl:variable name="evttype" select="..."/>
  <xsl:element name="${evttype}">
    <xsl:choose>
      <xsl:when test="objType='Document'">
        <xsl:call-template name="Document"/>
      </xsl:when>
      <xsl:when test="objType='File'">
        <xsl:call-template name="File"/>
      </xsl:when>
      ...
    </xsl:choose>
  </xsl:element>
```

There are always exceptions to the above advice.
If a feed will only ever contain e.g. successful logins then it may be easier to create the entire event within a single template, for example.
But if there's ever a possibility of e.g. logon failures, logoffs or anything else in the future then it's safer to structure the XSLT into separate templates.


## Filtering Wanted/Unwanted Event Types

It's common that not all received events are required to be translated.  Depending upon the data being received and the auditing requirements that have been set against the source system, there are several ways to filter the events.


### Remove Unwanted Events

The first method is best to use when the majority of event types are to be translated and only a few types, such as debug messages are to be dropped.
Consider the code fragment from earlier:

```xml
<xsl:template match="record">
  <Event>
    ...
  </Event>
</xsl:template>
```

This will create an Event node for every source record.
However, if we replace this with something like:

```xml
<xsl:template match="record[data[@name='logLevel' and @value='DEBUG']]"/>

<xsl:template match="record[data[@name='msgType'
                                 and (@value='drop1' or @value='drop2')
                                ]]"/>

<xsl:template match="record">
  <Event>
    ...
  </Event>
</xsl:template>
```

This will filter out all DEBUG messages and messages where the msgType is either “drop1" or “drop2".
All other messages will result in an Event being generated.

This method is often not suited to systems where the full set of message types isn't known prior to translation development, such as for closed source software where the full set of possible messages isn't already known.
If an unexpected message type appears in the logs then it's likely that the translation won't know how to deal with it and may either make incorrect assumptions about it or fail to produce a schema-compliant output.


### Translate Wanted Events

This is the opposite of the previous method and the XSLT just ignores anything that it's not expecting.
This method is best used where only a few event types are of interest such as the scenario of translation logons/logoffs from a vast range of possible types. 

For this, we'd use something like:

```xml
<xsl:template match="record[data[@name='msgType'
                                   and (@value='logon' or @value='logoff')
                                  ]]">
  <Event>
    ...
  </Event>
</xsl:template>

<xsl:template match="text()"/>
```

The final line stops the XSLT outputting a sequence of unformatted text nodes for any unmatched event types when an `<xsl:apply-templates/>` is used elsewhere within the XSLT.
It isn't always needed but does no harm if present.

This method starts to become messy and difficult to understand if a large number of wanted types are to be matched.


### Advanced Removal Method (With Optional Warnings)

Where the full list of event types isn't known or may expand over time, the best method may be to filter out the definite unwanted events and handle anything unexpected as well as the known and wanted events.
This would use code similar to before to drop the specific unwanted types but handle everything else including unknown types:

```xml
<xsl:template match="record[data[@name='logLevel' and @value='DEBUG']]"/>
...
<xsl:template match="record[data[@name='msgType'
                                   and (@value='drop1' or @value='drop2')
                                  ]]"/>

<xsl:template match="record">
  <Event>
    ...
  </Event>
</xsl:template>
```

However, the XSLT must then be able to handle unknown arbitrary event types.
In practice, most systems provide a consistent format for logging the “who/where/when" and it's only the “what" that differs between event types.
Therefore, it's usually possible to add something like this into the XSLT:

```xml
<EventDetail>
  <xsl:choose>
    <xsl:when test="$evtType='1'">
      ...
    </xsl:when>
    ...
    <xsl:when test="$evtType='n'">
      ...
    </xsl:when>
    <!-- Unknown event type -->
    <xsl:otherwise>
      <Unknown>
        <xsl:value-of select="stroom:log(‘WARN',concat('Unexpected Event Type - ', $evtType))"/>
        ...
      </Unknown>
    </xsl:otherwise>
</EventDetail>
```

This will create an Event of type `Unknown`.
The Unknown node is only able to contain data name/value pairs and it should be simple to extract these directly from the intermediate XML using an `<xsl:for-each>`.
This will allow the attributes from the source event to populate the output event for later analysis but will also generate an error stream of level **WARN** which will record the event type.
Looking through these error streams will allow the developer to see which unexpected events have appeared then either filter them out within a top-level `<xsl:template match="record[data[@name='...' and @value='...']]"/>` statement or to produce an additional `<xsl:when>` within the EventDetail node to translate the type correctly.


## Common Mistakes


### Performance Issues

The way that the code is written can affect its overall performance.
This may not matter for low-volume logs but can greatly affect processing time for higher volumes.
Consider the following example:

```xml
<!-- Event Detail template -->
<xsl:template name="EventDetail">
  <xsl:variable name="X" select="..."/>
  <xsl:variable name="Y" select="..."/>
  <xsl:variable name="Z" select="..."/>

  <EventDetail>
    <xsl:choose>
      <xsl:when test="$X='A' and $Y='foo' and matches($Z,'blah.*blah')">
        <xsl:call-template name="AAA"/>
      </xsl:when>
      <xsl:when test="$X='B' or $Z='ABC'">
        <xsl:call-template name="BBB"/>
      </xsl:when>
      ...
      <xsl:otherwise>
        <xsl:call-template name="ZZZ"/>
      </xsl:otherwise>
    </xsl:choose>
  </EventDetail>
</xsl:template>
```

If none of the `<xsl:when>` choices match, particularly if there are many of them or their logic is complex then it'll take a significant time to reach the `<xsl:otherwise>` element.
If this is by far the most common type of source data (i.e. none of the specific `<xsl:when>` elements is expected to match very often) then the XSLT will be slow and inefficient.
It's therefore better to list the most common examples first, if known.

It's also usually better to have a hierarchy of smaller numbers of options within an `<xsl:choose>`.
So rather than the above code, the following is likely to be more efficient:

```xml
<xsl:choose>
  <xsl:when test="$X='A'">
    <xsl:choose>
      <xsl:when test="$Y='foo'">
        <xsl:choose>
          <xsl:when test="matches($Z,'blah.*blah')">
            <xsl:call-template name="AAA"/>
          </xsl:when>
          <xsl:otherwise>
            ...
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      ...
    </xsl:choose>
    ...
  </xsl:when>
  ...
</xsl:choose>
```

Whilst this code looks more complex, it's far more efficient to carry out a shorter sequence of checks, each based upon the result of the previous check, rather than a single consecutive list of checks where the data may only match the final check.

Where possible, the most commonly appearing choices in the source data should be dealt with first to avoid running through multiple `<xsl:when>` statements.


### Stepping Works Fine But Errors Whilst Processing

When data is being stepped, it's only ever fed to the XSLT as a single event, whilst a pipeline is able to process multiple events within a single input stream.
This apparently minor difference sometimes results in obscure errors if the translation has incorrect XPaths specified.
Taking the following input data example:

```xml
<TopLevelNode>
  <EventNode>
    <Field1>1</Field1>
    ...
  </EventNode>
  <EventNode>
    <Field1>2</Field1>
    ...
  </EventNode>
  ...
  <EventNode>
    <Field1>n</Field1>
    ...
  </EventNode>
</TopLevelNode>
```

If an XSLT is stepped, all XPaths will be relative to `<EventNode>`.
To extract the value of Field1, you'd use something similar to ```<xsl:value-of select="Field1"/>```.
The following examples would also work in stepping mode or when there was only ever one Event per input stream:

```xml
<xsl:value-of select="//Field1"/>
<xsl:value-of select="../EventNode/Field1"/>
<xsl:value-of select="../*/Field1"/>
<xsl:value-of select="/TopLevelNode/EventNode/Field1"/>
```

However, if there's ever a stream with multiple event nodes, the output from pipeline processing would be a sequence of the Field1 node values i.e. `12...n` for each event.
Whilst it's easy to spot the issues in these basic examples, it's harder to see in more complex structures.
It's also worth mentioning that just because your test data only ever has a single event per stream, there's nothing to say it'll stay this way when operational or when the next version of the software is installed on the source system, so you should always guard against using XPaths that go to the root of the tree.


## Unexpected Data Values Causing Schema Validation Errors

A source system may provide a log containing an IP address.
All works fine for a while with the following code fragment:

```xml
<Client>
  <IPAddress>
    <xsl:value-of select="$ipAddress"/>
  </IPAddress>
</Client>
```

However, let's assume that in certain circumstances (e.g. when accessed locally rather than over a network) the system provides a value of `localhost` or something else that's not an IP address.
Whilst the majority of schema values are of type `string`, there are still many that are limited in character set in some way.
The most common is probably IPAddress and it must match a fairly complex regex to be valid.
In this instance, the translation will still succeed but any schema validation elements within the pipeline will throw an error and stop the invalid event (not just the invalid element) from being output within the Events stream.
Without the event in the stream, it's not indexable or searchable so is effectively dropped by the system.

To resolve this issue, the XSLT should be aware of the possibility of invalid input using something like the following:

```xml
<Client>
  <xsl:choose>
    <xsl:when test="matches($ipAddress,'^[.0-9]+$')">
      <IPAddress>
        <xsl:value-of select="$ipAddress"/>
      </IPAddress>
    </xsl:when>
    <xsl:otherwise>
      <HostName>
        <xsl:value-of select="$ipAddress"/>
      </HostName>
    </xsl:otherwise>
  </xsl:choose>
</Client>
```

This would need to be modified slightly for IPv6 and also wouldn't catch obvious errors such as `999.1..8888` but if we can assume that the source will generate either a valid IP address or a valid hostname then the events will at least be available within the output stream.


## Testing the Translation

When stepping a stream with more than a few events in it, it's possible to filter the stepping rather than just moving to first/previous/next/last.
In the bottom right hand corner of the bottom right hand pane within the XSLT tab, there's a small *filter* icon {{< stroom-icon "filter.svg" >}} that's often not spotted.
The icon will be **grey** if no filter is set or **green** if set.
Opening this filter gives choices such as:

* Jump to error
* Jump to empty/non-empty output
* Jump to specific XPath exists/contains/equals/unique

Each of these options can be used to move directly to the next/previous event that matches one of these attributes.

A filter on e.g. the {{< pipe-elm "XSLTFilter" >}} will still be active even if viewing the {{< pipe-elm "DSParser" >}} or any other pipeline entry, although the filter that's present in the parser step will not show any values.
This may cause confusion if you lose track of which filters have been set on which steps.

Filters can be entered for multiple pipeline elements, e.g. Empty output in translationFilter and Error in schemaFilter.
In this example, all empty outputs AND schema errors will be seen, effectively providing an OR of the filters.

The XPath syntax is fairly flexible.
If looking for specific TypeId values, the shortcut of `//TypeId` will work just as well as `/Events/Event/EventDetail/TypeId`, for example.

Using filters will allow a developer to find a wide range of types of records far quicker than stepping through a large file of events. 

