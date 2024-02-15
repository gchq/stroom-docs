---
title: "XSLT Basics"
linkTitle: "XSLT Basics"
weight: 10
date: 2024-02-14
tags:
  - xslt
description: >
  The basics of using XSLT and the XSLTFilter element.
---

{{< glossary "XSLT" >}} is a very powerful language and allows the user to perform very complex transformations of XML data.
This documentation does not aim to document how to write XSLT documents, for that, we strongly recommend you refer to online references (e.g. {{< external-link "W3Schools" "https://www.w3schools.com/xml/xsl_intro.asp" >}} or obtain a book covering XSLT 2.0 and {{< glossary "XPath" >}}).
It does however aim to document aspects of XSLT that are specific to the use of XSLT in Stroom.


## Examples

### Event Normalisation

Here is an example XSLT document that transforms XML data in the `records:2` {{< glossary "namespace" >}} (which is the output of the {{< pipe-elm "DSParser" >}} element) into event XML in the `event-logging:3` namespace.
It is an example of event normalisation from a bespoke format.

{{% warning %}}
This example aims to show some typical uses of XSLT in a typical Stroom use case.
It does not necessarily represent best practice in terms of creation of a normalised event.
{{% /warning %}}


```xml
<?xml version="1.1" encoding="UTF-8" ?>
<xsl:stylesheet 
    xpath-default-namespace="records:2" 
    xmlns="event-logging:3" 
    xmlns:stroom="stroom" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
    version="2.0">

  <!-- Match the root element -->
  <xsl:template match="records">
    <Events 
        xsi:schemaLocation="event-logging:3 file://event-logging-v3.0.0.xsd" 
        Version="3.0.0">
      <xsl:apply-templates />
    </Events>
  </xsl:template>

  <!-- Match each 'record' element -->
  <xsl:template match="record">
    <xsl:variable name="user" select="data[@name='User']/@value" />
    <Event>
      <xsl:call-template name="header" />
      <xsl:value-of select="stroom:log('info', concat('Processing user: ', $user))"/>
      <EventDetail>
        <TypeId>0001</TypeId>
        <Description>
          <xsl:value-of select="data[@name='Message']/@value" />
        </Description>
        <Authenticate>
          <Action>Logon</Action>
          <LogonType>Interactive</LogonType>
          <User>
            <Id>
              <xsl:value-of select="$user" />
            </Id>
          </User>
          <Data Name="FileNo">
            <xsl:attribute name="Value" select="data[@name='FileNo']/@value" />
          </Data>
          <Data Name="LineNo">
            <xsl:attribute name="Value" select="data[@name='LineNo']/@value" />
          </Data>
        </Authenticate>
      </EventDetail>
    </Event>
  </xsl:template>

  <xsl:template name="header">
    <xsl:variable name="date" select="data[@name='Date']/@value" />
    <xsl:variable name="time" select="data[@name='Time']/@value" />
    <xsl:variable name="dateTime" select="concat($date, $time)" />
    <xsl:variable name="formattedDateTime" select="stroom:format-date($dateTime, 'dd/MM/yyyyHH:mm:ss')" />
    <xsl:variable name="user" select="data[@name='User']/@value" />
    <EventTime>
      <TimeCreated>
        <xsl:value-of select="$formattedDateTime" />
      </TimeCreated>
    </EventTime>
    <EventSource>
      <System>
        <Name>Test</Name>
        <Environment>Test</Environment>
      </System>
      <Generator>CSV</Generator>
      <Device>
        <IPAddress>1.1.1.1</IPAddress>
        <MACAddress>00-00-00-00-00-00</MACAddress>
        <xsl:variable name="location" select="stroom:lookup('FILENO_TO_LOCATION_MAP', data[@name='FileNo']/@value, $formattedDateTime)" />
        <xsl:if test="$location">
          <xsl:copy-of select="$location" />
        </xsl:if>
        <Data Name="Zone1">
          <xsl:attribute name="Value" select="stroom:lookup('IPToLocation', stroom:numeric-ip('192.168.1.1'))" />
        </Data>
      </Device>
      <User>
        <Id>
          <xsl:value-of select="$user" />
        </Id>
      </User>
    </EventSource>
  </xsl:template>
</xsl:stylesheet>
```


### Reference Data

Here is an example of transforming [Reference Data]({{< relref "../reference-data" >}}) in the `records:2` {{< glossary "namespace" >}} (which is the output of the {{< pipe-elm "DSParser" >}} element) into XML in the `reference-data:2` namespace that is suitable for loading using the {{< pipe-elm "ReferenceDataFilter">}}

```xml
<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet 
    xpath-default-namespace="records:2" 
    xmlns="reference-data:2" 
    xmlns:evt="event-logging:3"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    version="2.0">

    <xsl:template match="records">
        <referenceData 
           xsi:schemaLocation="reference-data:2 file://reference-data-v2.0.1.xsd event-logging:3 file://event-logging-v3.0.0.xsd"
           version="2.0.1">
            <xsl:apply-templates/>
        </referenceData>
    </xsl:template>

    <xsl:template match="record">
        <reference>
            <map>USER_ID_TO_STAFF_NO_MAP</map>
            <key><xsl:value-of select="data[@name='userId']/@value"/></key>
            <value><xsl:value-of select="data[@name='staffNo']/@value"/></value>
        </reference>
    </xsl:template>
    
</xsl:stylesheet>
```


## Identity Transformation

If you want an XSLT to decorate an Events XML document with some additional data or to change it slightly without changing its namespace then a good starting point is the identity transformation.

```xml
<xsl:stylesheet 
    version="1.0" 
    xpath-default-namespace="event-logging:3" 
    xmlns="event-logging:3" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <!-- Match Root Object -->
  <xsl:template match="Events">
    <Events 
        xmlns="event-logging:3" 
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
        xsi:schemaLocation="event-logging:3 file://event-logging-v3.4.2.xsd" 
        Version="3.4.2">

      <xsl:apply-templates />
    </Events>
  </xsl:template>
  

  <!-- Whenever you match any node or any attribute -->
  <xsl:template match="node( )|@*">

    <!-- Copy the current node -->
    <xsl:copy>

      <!-- Including any attributes it has and any child nodes -->
      <xsl:apply-templates select="@*|node( )" />
    </xsl:copy>
  </xsl:template>
</xsl:stylesheet>
```

This XSLT will copy every node and attribute as they are, returning the input document completely un-changed.
You can then add additional templates to match on specific elements and modify them, for example decorating a user's `UserDetails` elements with value obtained from a reference data lookup on a user ID.

{{% note %}}
You can insert this identity skeleton into an XSLT editor using this editor [snippet]({{< relref "/docs/user-guide/content/editing-text/snippet-reference#events-identity-skeleton" >}}).
{{% /note %}}


## `<xsl:message>`

Stroom supports the standard `<xsl:message>` element from the {{< external-link "http://www.w3.org/1999/XSL/Transform" "http://www.w3.org/1999/XSL/Transform" >}}.
This element behaves in a similar way to the [`stroom:log()`]({{< relref "./xslt-functions#log" >}}) XSLT function.
The element text is logged to the Error stream with a default severity of `ERROR`.

A child element can optionally be used to set the severity level (one of `FATAL|ERROR|WARN|INFO`).
The namespace of this element does not matter.
You can also set the attribute `terminate="yes"` to log the message at severity `FATAL` and halt processing of that stream part.
If the stream is multi-part then processing will continue with the next part.

{{% note %}}
Setting `terminate="yes"` will trump any severity defined by a child element.
It will always be logged at `FATAL`.
{{% /note %}}

The following are some examples of using `<xsl:message>`.

```xml
<!-- Log a message using default severity of ERROR -->
<xsl:message>Invalid length</xsl:message>

<!-- terminate="yes" means log the message as a FATAL ERROR and halt processing of the stream part -->
<xsl:message terminate="yes">Invalid length</xsl:message>

<!-- Log a message with a child element name specifying the severity. -->
<xsl:message>
  <warn>Invalid length</warn>
</xsl:message>

<!-- Log a message with a child element name specifying the severity. -->
<xsl:message>
  <info>Invalid length</info>
</xsl:message>

<!-- Log a message, specifying the severity and using a dynamic value. -->
<xsl:message>
  <info>
    <xsl:value-of select="concat('User ID ', $userId, ' is invalid')" />
  </info>
</xsl:message>
```

