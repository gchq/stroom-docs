# Stroom HOWTO - Event Forwarding

### Document Properties

* Author: John Doe 
* Last Updated: 15 Apr 2020
* Recommended Additional Documentation: HOWTO - Apache HTTPD Event Feed
* Version Information: Created with Stroom v6

## Introduction

In some situations, you will want to automatically extract stored Events in their XML format to forward to the file system. This is achieved via a Pipeline with an appropriate XSLT translation that is used to decide what events are forwarded. Once the Events have been chosen, the Pipeline would need to validate the Events (via a schemaFilter) and then the Events would be passed to an xmlWriter and then onto a file system writer (fileSystemOutputStreamProvider or RollingFileAppender).

## Example Event Forwarding - Multiple destinations

In this example, we will create a pipeline that writes Events to the file system, but to multiple destinations based on the location of the Event Client element.

We will use the EventSource/Client/Location/Country element to decided where to store the events. Specifically, we store events from clients in AUS in one location, and events from clients in GBR to another. All other client locations will be ignored.

## Create translations

First, we will create two translations - one for each country location Australia (AUS) and Great Britain (GBR). The AUS selection translation is

``` xml

<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="event-logging:3" xmlns:stroom="stroom" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xs="http://www.w3.org/2001/XMLSchema"> 

<!--
ClientAUS Translation: CHANGE  HISTORY
v1.0.0 - 2015-01-19  
v1.5.0 - 2020-04-15

This translation find all  events  where the  EventSource/Client/Location/Country  element contains the string  'AUS' and then copies them.

-->

<!--  Match all  events -->
<xsl:template  match="/Events|/Events/@*">
<xsl:copy>
<xsl:apply-templates  select="node()|@*" />
</xsl:copy>
</xsl:template>

<!-- Find all  events  whose Client location is in the AUS -->
<xsl:template  match="Event">
<xsl:apply-templates select="EventSource/Client/Location/Country[contains(upper-case(text()),  'AUS')]" />
</xsl:template>

<!--  Country template - deep copy the event -->
<xsl:template  match="Country">
<xsl:copy-of select="ancestor::Event"  />
</xsl:template>
</xsl:stylesheet>

```

The Great Britain selection translation is

``` xml

<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="event-logging:3" xmlns:stroom="stroom" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xs="http://www.w3.org/2001/XMLSchema"> 

<!--
ClientGBR Translation: CHANGE  HISTORY
v1.0.0 - 2015-01-19  
v1.5.0 - 2020-04-15

This translation find all  events  where the  EventSource/Client/Location/Country  element contains the string  'GBR' and then copies them.

-->

<!--  Match all  events -->
<xsl:template  match="/Events|/Events/@*">
<xsl:copy>
<xsl:apply-templates  select="node()|@*" />
</xsl:copy>
</xsl:template>

<!-- Find all  events  whose Client location is in the GBR -->
<xsl:template  match="Event">
<xsl:apply-templates select="EventSource/Client/Location/Country[contains(upper-case(text()),  'GBR')]" />
</xsl:template>

<!--  Country template - deep copy the event -->
<xsl:template  match="Country">
<xsl:copy-of select="ancestor::Event"  />
</xsl:template>
</xsl:stylesheet>

```

We will store this capability in the Folder **MultiGeoForwarding**. Having created the two translations we see



