---
title: "XSLT Conversion"
linkTitle: "XSLT Conversion"
weight: 20
date: 2021-07-27
tags:
  - xslt
description: >
  Using Extensible Stylesheet Language Transformations (XSLT) to transform data.
---

Once the text file has been converted into Intermediary XML (or the feed is already XML), XSLT is used to
translate the XML into event logging XML format.

Event Feeds must be translated into the events schema and Reference
into the reference schema. You can browse documentation relating to the
schemas within the application.

Here is an example XSLT:

```xml
<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet
    xmlns="event-logging:3"
    xmlns:s="stroom"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    version="2.0">

    <xsl:template match="SomeData">
        <Events
        xsi:schemaLocation="event-logging:3 file://event-logging-v3.0.0.xsd"
        Version="3.0.0">
            <xsl:apply-templates/>
        </Events>
    </xsl:template>
    <xsl:template match="SomeEvent">
        <xsl:variable name="dateTime" select="SomeTime"/>
        <xsl:variable name="formattedDateTime" select="s:format-date($dateTime, 'dd/MM/yyyyhh:mm:ss')"/>

        <xsl:if test="SomeAction = 'OPEN'">
            <Event>
            <EventTime>
                <TimeCreated>
                    <xsl:value-of select="$formattedDateTime"/>
                </TimeCreated>
            </EventTime>
            <EventSource>
                <System>Example</System>
                <Environment>Example</Environment>
                <Generator>Very Simple Provider</Generator>
                <Device>
                    <IPAddress>3.3.3.3</IPAddress>
                </Device>
                <User>
                    <Id><xsl:value-of select="SomeUser"/></Id>
                </User>
            </EventSource>
            <EventDetail>
                <View>
                    <Document>
                        <Title>UNKNOWN</Title>
                        <File>
                        <Path><xsl:value-of select="SomeFile"/></Path>
                        <File>
                    </Document>
                </View>
            </EventDetail>
            </Event>
        </xsl:if>
    </xsl:template>
</xsl:stylesheet>
```
