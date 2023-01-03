---
title: "Apache HTTPD Event Feed"
linkTitle: "Apache HTTPD"
#weight:
date: 2021-07-09
tags:
  - processing
  - feed
  - httpd
description: >
  The following will take you through the process of creating an Event Feed in Stroom.
---

<!-- Created with Stroom v6.1-beta.16 -->

{{% see-also %}}
[HOWTO - Enabling Processors for a Pipeline]({{< relref "../General/EnablingProcessorsHowTo" >}})
{{% /see-also %}}


## Introduction

The following will take you through the process of creating an Event Feed in Stroom.

In this example, the logs are in a well-defined, line based, text format so we will use a Data Splitter parser to transform the logs into simple record-based XML and then a XSLT translation to normalise them into the Event schema.

A separate document will describe the method of automating the storage of normalised events for this feed.
Further, we will not Decorate these events.
Again, Event Decoration is described in another document.


## Event Log Source

For this example, we will use logs from an Apache HTTPD Web server.
In fact, the web server in front of Stroom v5 and earlier.

To get the optimal information from the Apache HTTPD access logs, we define our log format based on an extension of the BlackBox format.
The format is described and defined below.
This is an extract from a httpd configuration file (/etc/httpd/conf/httpd.conf)

{{< textfile "HOWTOs/EventFeeds/CreateApacheHTTPDEventFeed/ApacheHTTPDAuditConfig.txt" "text" >}}Apache BlackBox Auditing Configuration{{</textfile >}}

As Stroom can use PKI for login, you can configure Stroom’s Apache to make use of the blackboxSSLUser log format.
A sample set of logs in this format appear below.

{{< textfile "HOWTOs/EventFeeds/CreateApacheHTTPDEventFeed/sampleApacheBlackBox.log" "text" >}}Apache BlackBox sample log{{</textfile >}}

Save a copy of this data to your local environment for use later in this HOWTO.
Save this file as a text document with ANSI encoding.


## Create the Feed and its Pipeline

To reflect the source of these Accounting Logs, we will name our feed and its pipeline Apache-SSLBlackBox-V2.0-EVENTS and it will be stored in the system group Apache HTTPD under the main system group - `Event Sources`.


### Create System Group

To create the system group Apache  HTTPD, navigate to the _Event Sources/Infrastructure/WebServer_ system group within the Explorer pane (if this system group structure does not already exist in your Stroom instance then refer to the **HOWTO Stroom Explorer Management** for guidance).
Left click to highlight the
_WebServer_ system group then right click to bring up the object context menu.
Navigate to the _New_ icon, then the _Folder_ icon to reveal the _New Folder_ selection window.

{{< screenshot "HOWTOs/v6/UI-ApacheHttpEventFeed-00.png" >}}Navigate Explorer{{< /screenshot >}}

In the New Folder window enter Apache HTTPD into the **Name:** text entry box.

{{< screenshot "HOWTOs/v6/UI-ApacheHttpEventFeed-01.png" >}}Create System Group{{< /screenshot >}}

The click on {{< stroom-btn "Ok" >}} at which point you will be presented with the Apache HTTPD system group configuration tab.
Also note, the _WebServer_ system group within the Explorer pane has automatically expanded to display the `Apache HTTPD` system group.

Close the Apache HTTPD system group configuration tab by clicking on the close item icon on the right-hand side of the tab {{< stroom-tab "Folder.svg" "Apache HTTPD" "active" >}}.

We now need to create, in order

* the Feed,
* the Text Parser,
* the Translation and finally,
* the Pipeline.


### Create Feed

Within the Explorer pane, and having selected the Apache HTTPD group, right click to bring up object context menu.
Navigate to New, Feed

{{< screenshot "HOWTOs/v6/UI-ApacheHttpEventFeed-03.png" >}}Apache Create Feed{{< /screenshot >}}

Select the Feed icon {{< stroom-icon "document/Feed.svg" >}}, when the **New Feed** selection window comes up, ensure the `Apache HTTPD` system group is selected or navigate to it.
Then enter the name of the feed, Apache-SSLBlackBox-V2.0-EVENTS, into the **Name:** text entry box the press {{< stroom-btn "Ok" >}}. 

It should be noted that the default Stroom FeedName pattern will not accept this name.
One needs to modify the `stroom.feedNamePattern` stroom property to change the default pattern to `^[a-zA-Z0-9_-\.]{3,}$`.
See the [HOWTO on System Properties]({{< relref "../Administration/SystemProperties.md" >}}) document to see how to make this change.

{{< screenshot "HOWTOs/v6/UI-ApacheHttpEventFeed-04.png" >}}New Feed dialog{{< /screenshot >}}

At this point you will be presented with the new feed's configuration tab and the feed's Explorer object will automatically appear in the Explorer pane within the `Apache HTTPD` system group.

Select the _Settings_ tab on the feed's configuration tab.
Enter an appropriate description into the **Description:** text entry box, for instance:

"Apache HTTPD events for BlackBox Version 2.0.  These events are from a Secure service  (https)."

In the **Classification:** text entry box, enter a Classification of the data that the event feed will contain - that is the classification or sensitivity of the accounting log’s content itself.

As this is not a Reference Feed, leave the **Reference Feed:** check box unchecked. 

We leave the **Feed Status:** at _Receive_.

We leave the **Stream Type:** as _Raw Events_ as this we will be sending batches (streams) of raw event logs.

We leave the **Data Encoding:** as UTF-8 as the raw logs are in this form.

We leave the **Context Encoding:** as UTF-8 as there no context events for this feed. 

We leave the **Retention Period:** at _Forever_ as we do not want to delete the raw logs.

This results in

{{< screenshot "HOWTOs/v6/UI-ApacheHttpEventFeed-05.png" >}}New Feed tab{{< /screenshot >}}

Save the feed by clicking on the save icon {{< stroom-icon "save.svg" >}}.


### Create Text Converter

Within the Explorer pane, and having selected the `Apache HTTPD` system group, right click to bring up object context menu, then select:

{{< stroom-menu "New" "Text Converter" >}}<br/>

When the **New Text Converter** 

{{< screenshot "HOWTOs/v6/UI-ApacheHttpEventFeed-07.png" >}}New Text Converter{{< /screenshot >}}

selection window comes up enter the name of the feed, Apache-SSLBlackBox-V2.0-EVENTS, into the **Name:** text entry box then press {{< stroom-btn "Ok" >}}.
At this point you will be presented with the new text converter's configuration tab.

{{< screenshot "HOWTOs/v6/UI-ApacheHttpEventFeed-08.png" >}}Text Converter configuration tab{{< /screenshot >}}

Enter an appropriate description into the **Description:** text entry box, for instance

"Apache HTTPD events for BlackBox Version 2.0 - text converter.
See Conversion for complete documentation."

Set the **Converter Type:** to be Data Splitter from drop down menu.

{{< screenshot "HOWTOs/v6/UI-ApacheHttpEventFeed-09.png" >}}Text Converter configuration settings{{< /screenshot >}}

Save the text converter by clicking on the save icon {{< stroom-icon "save.svg" >}}.


### Create XSLT Translation

Within the Explorer pane, and having selected the `Apache HTTPD` system group, right click to bring up object context menu, then select:

{{< stroom-menu "New" "XSL Translation" >}}</br>

When the **New XSLT** selection window comes up,

{{< screenshot "HOWTOs/v6/UI-ApacheHttpEventFeed-11.png" >}}New XSLT{{< /screenshot >}}

 enter the name of the feed, Apache-SSLBlackBox-V2.0-EVENTS, into the **Name:** text entry box then press {{< stroom-btn "Ok" >}}.
 At this point you will be presented with the new XSLT's configuration tab.

 {{< screenshot "HOWTOs/v6/UI-ApacheHttpEventFeed-12.png" >}}New XSLT tab{{< /screenshot >}}

 Enter an appropriate description into the **Description:** text entry box, for instance

"Apache HTTPD events for  BlackBox Version 2.0  - translation.
See Translation for complete documentation."

{{< screenshot "HOWTOs/v6/UI-ApacheHttpEventFeed-13.png" >}}New XSLT settings{{< /screenshot >}}

Save the XSLT by clicking on the save {{< stroom-icon "save.svg" >}} icon.


### Create Pipeline

In the process of creating this pipeline we have assumed that the  **Template Pipeline** content pack has been loaded, so that we can _Inherit_ a pipeline structure from this content pack and configure it to support this specific feed.

Within the Explorer pane, and having selected the Apache HTTPD system group, right click to bring up object context menu, then select:

{{< stroom-menu "New" "Pipeline" >}}<br/>

When the **New Pipeline** selection window comes up, navigate to, then select the Apache HTTPD system group and then enter the name of the pipeline, Apache-SSLBlackBox-V2.0-EVENTS into the **Name:** text entry box then press {{< stroom-btn "Ok" >}}.
At this you will be presented with the new pipeline’s configuration tab

{{< screenshot "HOWTOs/v6/UI-ApacheHttpEventFeed-15.png" >}}New Pipeline tab{{< /screenshot >}}

As usual, enter an appropriate **Description:**

"Apache HTTPD events for BlackBox Version 2.0  - pipeline.
This pipeline uses the standard event pipeline to store the events in the Event Store."

{{< screenshot "HOWTOs/v6/UI-ApacheHttpEventFeed-16.png" >}}New Pipeline settings{{< /screenshot >}}

Save the pipeline by clicking on the save icon {{< stroom-icon "save.svg" >}}.

We now need to select the structure this pipeline will use.
We need to move from the **Settings** sub-item on the pipeline configuration tab to the **Structure** sub-item.
This is done by clicking on the **Structure** link, at which we see

{{< screenshot "HOWTOs/v6/UI-ApacheHttpEventFeed-17.png" >}}New Pipeline Structure{{< /screenshot >}}

Next we will choose an Event Data pipeline.
This is done by inheriting it from a defined set of Template Pipelines.
To do this, click on the menu selection icon  to the right of the Inherit From: text display box.

When the **Choose item**

{{< screenshot "HOWTOs/v6/UI-ApacheHttpEventFeed-18.png" >}}New Pipeline inherited from{{< /screenshot >}}

selection window appears, select from the `Template Pipelines` system group.
In this instance, as our input data is text, we select (left click) the {{< stroom-icon "Document/Pipeline.svg" >}} _Event Data (Text)_ pipeline

{{< screenshot "HOWTOs/v6/UI-ApacheHttpEventFeed-19.png" >}}New Pipeline inherited selection{{< /screenshot >}}

then press {{< stroom-btn "Ok" >}}.
At this we see the inherited pipeline structure of

{{< screenshot "HOWTOs/v6/UI-ApacheHttpEventFeed-20.png" >}}New Pipeline inherited structure{{< /screenshot >}}

For the purpose of this HOWTO, we are only interested in two of the eleven (11) elements in this pipeline

 * the Text Converter labelled *dsParser*
 * the XSLT Translation labelled *translationFilter*

We now need to associate our Text Converter and Translation with the pipeline so that we can pass raw events (logs) through our pipeline in order to save them in the Event Store.

To associate the Text Converter, select the Text Converter icon, to display.

{{< screenshot "HOWTOs/v6/UI-ApacheHttpEventFeed-21.png" >}}New Pipeline associate textconverter{{< /screenshot >}}

Now identify to the **Property** pane (the middle pane of the pipeline configuration tab), then and double click on the _textConverter_ Property Name to display the **Edit
Property** selection window that allows you to edit the given property

{{< screenshot "HOWTOs/v6/UI-ApacheHttpEventFeed-22.png" >}}New Pipeline textconverter association{{< /screenshot >}}

We leave the Property **Source:** as Inherit but we need to change the Property **Value:** from _None_ to be our newly created Apache-SSLBlackBox-V2.0-EVENTS Text Converter.

To do this, position the cursor over the menu selection icon {{< stroom-icon "popup.png" "Menu selection">}} to the right of the **Value:** text display box and click to select.
Navigate to the `Apache HTTPD` system group then select the Apache-SSLBlackBox-V2.0-EVENTS text Converter

{{< screenshot "HOWTOs/v6/UI-ApacheHttpEventFeed-23.png" >}}New Pipeline textconverter association{{< /screenshot >}}

then press {{< stroom-btn "Ok" >}}.
At this we will see the Property _Value_ set

{{< screenshot "HOWTOs/v6/UI-ApacheHttpEventFeed-24.png" >}}New Pipeline textconverter association{{< /screenshot >}}

Again press {{< stroom-btn "Ok" >}} to finish editing this property and we see that the _textConverter_ Property has been set to **Apache-SSLBlackBox-V2.0-EVENTS**

{{< screenshot "HOWTOs/v6/UI-ApacheHttpEventFeed-25.png" >}}New Pipeline textconverter association{{< /screenshot >}}

We perform the same actions to associate the translation.

First, we select the translation Filter’s {{< pipe-elm "xsltFilter" "translationFilter" >}} element and then within translation Filter’s **Property** pane we double click on the _xslt_ Property Name to bring up the **Property Editor**.
As before, bring up the **Choose item** selection window, navigate to the `Apache HTTPD` system group and select the
Apache-SSLBlackBox-V2.0-EVENTS xslt Translation.

{{< screenshot "HOWTOs/v6/UI-ApacheHttpEventFeed-26.png" >}}New Pipeline Translation association{{< /screenshot >}}

We leave the remaining properties in the translation Filter’s **Property** pane at their default values.
The result is the assignment of our translation to the _xslt_ Property.

{{< screenshot "HOWTOs/v6/UI-ApacheHttpEventFeed-27.png" >}}New Pipeline Translation association{{< /screenshot >}}

For the moment, we will not associate a decoration filter. 

Save the pipeline by clicking on its {{< stroom-icon "save.svg">}} icon.


### Manually load Raw Event test data

Having established the pipeline, we can now start authoring our text converter and translation.
The first step is to load some Raw Event test data.
Previously in the **Event Log Source** of this HOWTO you saved a copy of the file _sampleApacheBlackBox.log_ to your local environment.
It contains only a few events as the content is consistently formatted.
We could feed the test data by posting the file to Stroom’s accounting/datafeed url, but for this example we will manually load the file.
Once developed, raw data is posted to the web service.

Select the {{< stroom-tab "Feed.svg" "ApacheHHTPDFeed" >}} tab and select the **Data** sub-tab to display

{{< screenshot "HOWTOs/v6/UI-ApacheHttpEventFeed-29.png" >}}Data Loading{{< /screenshot >}}

This window is divided into three panes.

The top pane displays the _Stream Table_, which is a table of the latest streams that belong to the feed (clearly it’s empty).

{{< screenshot "HOWTOs/v6/UI-ApacheHttpEventFeed-30.png" >}}Data Loading - Stream Table{{< /screenshot >}}

Note that a Raw Event _stream_ is made up of data from a single file of data or aggregation of multiple data files and also meta-data associated with the data file(s).
For example, file names, file size, etc.

The middle pane displays a _Specific_ feed and any linked streams.
To display a _Specific_ feed, you select it from the _Stream Table_ above.

{{< screenshot "HOWTOs/v6/UI-ApacheHttpEventFeed-31.png" >}}Data Loading - Specific Stream{{< /screenshot >}}

The bottom pane displays the selected stream’s data or meta-data.

{{< screenshot "HOWTOs/v6/UI-ApacheHttpEventFeed-32.png" >}}Data Loading - Data/Metadata{{< /screenshot >}}

Note the Upload icon {{< stroom-icon "upload.svg">}} in the top left of the Stream table pane.
On clicking the Upload icon, we are presented with the data **Upload** selection window.

{{< screenshot "HOWTOs/v6/UI-ApacheHttpEventFeed-33.png" >}}Data Loading - Upload Data{{< /screenshot >}}

As stated earlier, raw event data is normally posted as a file to the Stroom web server.
As part of this posting action, a set of well-defined HTTP _extra headers_ are sent as part of the post.
These headers, in the form of key value pairs, provide additional context associated with the system sending the logs.
These standard headers become Stroom _feed attributes_ available to the Stroom translation.
Common attributes are

*  System - the name of the System providing the logs
*  Environment - the environment of the system (Production, Quality Assurance, Reference, Development)
*  Feed - the feedname itself
*  MyHost - the fully qualified domain name of the system sending the logs
*  MyIPaddress - the IP address of the system sending the logs
*  MyNameServer - the name server the system resolves names through

Since our translation will want these feed attributes, we will set them in the Meta Data text entry box of the **Upload** selection window.
Note we can skip _Feed_ as this will automatically be assigned correctly as part of the upload action (setting it to Apache-SSLBlackBox-V2.0-EVENTS obviously).
Our **Meta Data:** will have

* System:LinuxWebServer 
* Environment:Production 
* MyHost:stroomnode00.strmdev00.org 
* MyIPaddress:192.168.2.245
* MyNameServer:192.168.2.254

We select a **Stream Type:** of _Raw Events_ as this data is for an _Event Feed_.
As this is not a _Reference Feed_ we ignore the **Effective:** entry box (a date/time selector).

{{< screenshot "HOWTOs/v6/UI-ApacheHttpEventFeed-34.png" >}}Upload Data{{< /screenshot >}}

We now click the **Choose File** button, then navigate to the location of the raw log file you downloaded earlier, _sampleApacheBlackBox.log_

{{< screenshot "HOWTOs/v6/UI-ApacheHttpEventFeed-35.png" >}}Upload Data{{< /screenshot >}}

then click **Open** to return to the **Upload** selection window where we can then press {{< stroom-btn "Ok" >}} to perform the upload.

{{< screenshot "HOWTOs/v6/UI-ApacheHttpEventFeed-36.png" >}}Upload Data{{< /screenshot >}}

An Alert dialog window is presented {{< screenshot "HOWTOs/v6/UI-ApacheHttpEventFeed-37.png" >}}Alert{{< /screenshot >}}  which should be **closed**.

The stream we have just loaded will now be displayed in the  _Streams Table_ pane.
Note that the _Specific Stream_
and _Data/Meta-data_ panes are still blank.

{{< screenshot "HOWTOs/v6/UI-ApacheHttpEventFeed-38.png" >}}Data Loading - Streams Table{{< /screenshot >}}

If we select the stream by clicking anywhere along its line, the stream is highlighted and the _Specific Stream_ and Data/Meta-data_ panes now display data.

{{< screenshot "HOWTOs/v6/UI-ApacheHttpEventFeed-39.png" >}}Data Loading - Streams Table{{< /screenshot >}}

The _Specific Stream_ pane only displays the Raw Event stream and the _Data/Meta-data_ pane displays the content of the log file just uploaded (the **Data** link).
If we were to click on the **Meta** link at the top of the _Data/Meta-data_ pane, the log data is replaced by this stream’s meta-data.

{{< screenshot "HOWTOs/v6/UI-ApacheHttpEventFeed-40.png" >}}Data Loading - Meta-data{{< /screenshot >}}

Note that, in addition to the feed attributes we set, the upload process added additional feed attributes of

*  Feed - the feed name
*  ReceivedTime - the time the feed was received by Stroom
*  RemoteFile - the name of the file loaded
*  StreamSize - the size, in bytes, of the loaded data within the stream
*  user-agent - the user agent used to present the stream to Stroom - in this case, the Stroom user Interface

We now have data that will allow us to develop our text converter and translation.


### Step data through Pipeline - Source

We now need to step our data through the pipeline.

To do this, set the check-box on the _Specific Stream_ pane and we note that the previously grayed out action icons ({{< stroom-icon "process.svg">}} {{< stroom-icon "delete.svg">}} {{< stroom-icon "download.svg" >}}) are now enabled.

{{< screenshot "HOWTOs/v6/UI-ApacheHttpEventFeed-43.png" >}}Select Stream to Step{{< /screenshot >}}

We now want to step our data through the first element of the pipeline, the Text Converter.
We enter Stepping Mode by pressing the stepping button {{< stroom-icon "stepping.svg">}} found at the bottom right corner of the _Data/Meta-data_ pane.

We will then be requested to choose a pipeline to step with, at which, you should navigate to the Apache-SSLBlackBox-V2.0-EVENTS pipeline as per

{{< screenshot "HOWTOs/v6/UI-ApacheHttpEventFeed-44.png" >}}Select pipeline to Step{{< /screenshot >}}

then press {{< stroom-btn "Ok" >}}.

At this point, we enter the pipeline Stepping tab

{{< screenshot "HOWTOs/v6/UI-ApacheHttpEventFeed-45.png" >}}pipeline Stepping tab - Source{{< /screenshot >}}

which, initially displays the Raw Event data from our stream.
This is the Source display for the Event Pipeline.


### Step data through Pipeline - Text Converter

We click on the {{< pipe-elm "dsParser" >}} element to enter the Text Converter stepping window.

{{< screenshot "HOWTOs/v6/UI-ApacheHttpEventFeed-46.png" >}}pipeline Stepping tab - Text Converter{{< /screenshot >}}

This _stepping_ tab is divided into three sub-panes.
The top one is the Text Converter editor and it will allow you to edit the text conversion.
The bottom left window displays the _input_ to the Text Converter.
The bottom right window displays the _output_ from the Text Converter for the given input.

We also note an error indicator - that of an error in the editor pane as indicated by the black back-grounded x and rectangular black boxes to the right of the editor’s scroll bar.

{{< screenshot "HOWTOs/v6/UI-ApacheHttpEventFeed-47.png" >}}pipeline Stepping tab - Error{{< /screenshot >}} 

In essence, this means that we have no text converter to pass the Raw Event data through.

To correct this, we will author our text converter using the Data Splitter _language_.
Normally this is done incrementally to more easily develop the parser.
The minimum text converter contains

```xml
<?xml version="1.1" encoding="UTF-8"?>
<dataSplitter xmlns="data-splitter:3" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="data-splitter:3 file://data-splitter-v3.0.1.xsd" version="3.0">
    <split  delimiter="\n">
        <group>
            <regex pattern="^(.*)$">
                <data name="rest" value="$1" />
            </regex>
        </group>
    </split>
</dataSplitter>
```

If we now press the Step First {{< stroom-icon "fast-backward-green.svg" "Step first">}} icon the error will disappear and the stepping window will show.

{{< screenshot "HOWTOs/v6/UI-ApacheHttpEventFeed-48.png" >}}pipeline Stepping tab - Text Converter Simple A{{< /screenshot >}}

As we can see, the first line of our Raw Event is displayed in the _input_ pane and the _output_ window holds the converted XML output where we just have a single _data_ element with a _name_ attribute of _rest_ and a _value_ attribute of the complete raw event as our regular expression matched the entire line.

The next incremental step in the parser, would be to _parse out_ additional _data_ elements.
For example, in this next iteration we extract the client ip address, the client port and hold the rest of the Event in the rest data element.

With the text converter containing

```xml
<?xml version="1.1" encoding="UTF-8"?>
<dataSplitter xmlns="data-splitter:3" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="data-splitter:3 file://data-splitter-v3.0.1.xsd" version="3.0">
    <split  delimiter="\n">
        <group>
            <regex pattern="^([^/]+)/([^  ]+) (.*)$">
                <data name="clientip"  value="$1" />
                <data name="clientport"  value="$2" />
                <data name="rest" value="$3" />
            </regex>
        </group>
    </split>
</dataSplitter>
```

and a click on the Refresh Current Step {{< stroom-icon "refresh-green.svg" "Refresh">}} icon we will see the _output_ pane contain

{{< screenshot "HOWTOs/v6/UI-ApacheHttpEventFeed-49.png" >}}Text Converter Simple B{{< /screenshot >}}

We continue this incremental parsing until we have our complete parser.

The following is our complete Text Converter which generates xml records as defined by the Stroom **records v3.0** schema.

{{< textfile "HOWTOs/EventFeeds/CreateApacheHTTPDEventFeed/ApacheHTTPDBlackBox-DataSplitter.txt" "xml" >}}ApacheHTTPD BlackBox - Data Splitter{{</textfile >}}

If we now press the Step First {{< stroom-icon "fast-backward-green.svg" "Step first">}} icon we will see the complete parsed record

{{< screenshot "HOWTOs/v6/UI-ApacheHttpEventFeed-50.png" >}}pipeline Stepping tab - Text Converter Complete{{< /screenshot >}}

If we click on the Step Forward {{< stroom-icon "step-forward-green.svg" "Step forward">}} icon we will see the next event displayed in both the _input_ and _output_ panes.

{{< screenshot "HOWTOs/v6/UI-ApacheHttpEventFeed-51.png" >}}pipeline Stepping tab - Text Converter Complete second event{{< /screenshot >}}

we click on the Step Last {{< stroom-icon "fast-forward-green.svg" "Step last">}} icon we will see the last event displayed in both the _input_ and _output_ panes.

{{< screenshot "HOWTOs/v6/UI-ApacheHttpEventFeed-52.png" >}}pipeline Stepping tab - Text Converter Complete last event{{< /screenshot >}}

You should take note of the stepping key that has been displayed in each stepping window. The stepping key are the numbers enclosed in square brackets e.g. [7556:1:16] found in the top right-hand side of the stepping window next to the stepping icons

{{< screenshot "HOWTOs/v6/UI-ApacheHttpEventFeed-53.png" >}}pipeline Stepping tab - Stepping Key{{< /screenshot >}}

The form of these keys is [ streamId ':' subStreamId ':' recordNo]

where

*  **streamId** - is the stream ID and won’t change when stepping through the selected stream.
*  **subStreamId** - is the sub stream ID. When Stroom processes event streams it aggregates multiple input files and this is the file number.
*  **recordNo** - is the record number within the sub stream.

One can double click on either the **subStreamId** or **recordNo** numbers and enter a new number. This allows you to ‘step’ around a stream rather than just relying on first, previous, next and last movement.

Note, you should now Save {{< stroom-icon "save.svg" >}} your edited Text Converter.


### Step data through Pipeline - Translation

To start authoring the xslt Translation Filter, press the {{< pipe-elm "xsltFilter" "translationFilter" >}} element which steps us to the xsl Translation Filter pane.

{{< screenshot "HOWTOs/v6/UI-ApacheHttpEventFeed-54.png" >}}pipeline Stepping tab - Translation Initial{{< /screenshot >}}

As for the _Text Converter_ stepping tab, this tab is divided into three sub-panes. The top one is the xslt translation editor and it will allow you to edit the xslt translation. The bottom left window displays the _input_ to the xslt translation (which is the output from the _Text Converter_). The bottom right window displays the _output_ from the xslt Translation filter for the given input.

We now click on the pipeline Step Forward button {{< stroom-icon "step-forward-green.svg" "Step forward">}} to single step the Text Converter _records_ element data through our xslt Translation. We see no change as an empty translation will just perform a copy of the input data.

To correct this, we will author our xslt translation. Like the Data Splitter this is also authored incrementally. A minimum xslt translation might contain

```xml
<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet 
    xpath-default-namespace="records:2" 
    xmlns="event-logging:3" 
    xmlns:stroom="stroom" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
    xmlns:xs="http://www.w3.org/2001/XMLSchema" 
    version="3.0">

  <!-- Ingest the records tree -->
  <xsl:template match="records">
    <Events xsi:schemaLocation="event-logging:3 file://event-logging-v3.2.3.xsd" Version="3.2.3">
        <xsl:apply-templates />
    </Events>
  </xsl:template>

    <!-- Only generate events if we have an url on input -->
    <xsl:template match="record[data[@name = 'url']]">
        <Event>
            <xsl:apply-templates select="." mode="eventTime" />
            <xsl:apply-templates select="." mode="eventSource" />
            <xsl:apply-templates select="." mode="eventDetail" />
        </Event>
    </xsl:template>

    <xsl:template match="node()"  mode="eventTime">
        <EventTime>
            <TimeCreated/>
        </EventTime>
    </xsl:template>

    <xsl:template match="node()"  mode="eventSource">
        <EventSource>
            <System>
                <Name  />
                <Environment />
            </System>
            <Generator />
            <Device />
            <Client />
            <Server />
            <User>
                <Id />
            </User>
        </EventSource>
    </xsl:template>

    <xsl:template match="node()"  mode="eventDetail">
        <EventDetail>
            <TypeId>SendToWebService</TypeId>
            <Description />
            <Classification />
            <Send />
        </EventDetail>
    </xsl:template>
</xsl:stylesheet>
```

{{< screenshot "HOWTOs/v6/UI-ApacheHttpEventFeed-55.png" >}}Translation Minimal{{< /screenshot >}}

Clearly this doesn’t generate useful events. Our first iterative change might be to generate the TimeCreated element value. The change would be

```xml
    <xsl:template match="node()" mode="eventTime">
        <EventTime>
          <TimeCreated>
             <xsl:value-of select="stroom:format-date(data[@name = 'time']/@value, 'dd/MMM/yyyy:HH:mm:ss XX')" /> 
          </TimeCreated>
        </EventTime>
    </xsl:template>
```

{{< screenshot "HOWTOs/v6/UI-ApacheHttpEventFeed-56.png" >}}Translation Minimal+{{< /screenshot >}}

Adding in the EventSource elements (without ANY error checking!) as per

```xml
    <xsl:template match="node()"  mode="eventSource">
        <EventSource>
            <System>
              <Name>
                <xsl:value-of select="stroom:feed-attribute('System')"  />
              </Name>
              <Environment>
                <xsl:value-of select="stroom:feed-attribute('Environment')"  />
              </Environment>
            </System>
            <Generator>Apache  HTTPD</Generator>
            <Device>
              <HostName>
                <xsl:value-of select="stroom:feed-attribute('MyHost')"  />
              </HostName>
              <IPAddress>
                <xsl:value-of select="stroom:feed-attribute('MyIPAddress')"  />
              </IPAddress>
            </Device>
            <Client>
              <IPAddress>
                <xsl:value-of select="data[@name =  'clientip']/@value"  />
              </IPAddress>
              <Port>
                <xsl:value-of select="data[@name =  'clientport']/@value"  />
              </Port>
            </Client>
            <Server>
              <HostName>
                <xsl:value-of select="data[@name =  'vserver']/@value"  />
              </HostName>
              <Port>
                <xsl:value-of select="data[@name =  'vserverport']/@value"  />
              </Port>
            </Server>
            <User>
              <Id>
                <xsl:value-of select="data[@name='user']/@value" />
              </Id>
            </User>
        </EventSource>
    </xsl:template>
```

And after a Refresh Current Step {{< stroom-icon "refresh-green.svg" "Refresh">}} we see our output event ‘grow’ to

{{< screenshot "HOWTOs/v6/UI-ApacheHttpEventFeed-57.png" >}}Translation Minimal++{{< /screenshot >}}

We now complete our translation by expanding the _EventDetail_ elements to have the completed translation of (again with limited error checking and non-existent documentation!)

{{< textfile "HOWTOs/EventFeeds/CreateApacheHTTPDEventFeed/ApacheHTTPDBlackBox-TranslationXSLT.txt" "xml" >}}Apache BlackBox Translation XSLT{{</textfile >}}

And after a Refresh Current Step {{< stroom-icon "refresh-green.svg" "Refresh">}} we see the completed `<EventDetail>` section of our output event

{{< screenshot "HOWTOs/v6/UI-ApacheHttpEventFeed-58.png" >}}Translation Complete{{< /screenshot >}}

Note, you should now Save {{< stroom-icon "save.svg" >}} your edited xslt Translation.

We have completed the translation and have completed developing our Apache-SSLBlackBox-V2.0-EVENTS event feed.

At this point, this event feed is set up to accept Raw Event data, but it will not automatically process the raw data and hence it will not place events into the Event Store. To have Stroom automatically process Raw Event streams, you will need to enable Processors for this pipeline.
