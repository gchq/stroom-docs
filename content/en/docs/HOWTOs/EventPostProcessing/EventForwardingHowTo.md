---
title: "Event Forwarding"
linkTitle: "Event Forwarding"
#weight:
date: 2022-03-07
tags: 
description: >
  How to write processed events to the file system for use by other systems.

---

<!-- Created with Stroom v6.1-beta.16  -->

{{% see-also %}}
[HOWTO - Apache HTTPD Event Feed]({{< relref "../EventFeeds/CreateApacheHTTPDEventFeed" >}})
{{% /see-also %}}


## Introduction

In some situations, you will want to automatically extract stored Events in their XML format to forward to the file system.
This is achieved via a Pipeline with an appropriate XSLT translation that is used to decide what events are forwarded.
Once the Events have been chosen, the Pipeline would need to validate the Events (via a schemaFilter) and then the Events would be passed to an xmlWriter and then onto a file system writer (fileSystemOutputStreamProvider or RollingFileAppender).


## Example Event Forwarding - Multiple destinations

In this example, we will create a pipeline that writes Events to the file system, but to multiple destinations based on the location of the Event Client element.

We will use the EventSource/Client/Location/Country element to decided where to store the events.
Specifically, we store events from clients in AUS in one location, and events from clients in GBR to another.
All other client locations will be ignored.


## Create translations

First, we will create two translations - one for each country location Australia (AUS) and Great Britain (GBR).
The AUS selection translation is

``` xml

<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet 
    version="3.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns="event-logging:3" 
    xmlns:stroom="stroom" 
    xpath-default-namespace="event-logging:3 
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
    xmlns:xs="http://www.w3.org/2001/XMLSchema"> 

  <!--
  ClientAUS Translation: CHANGE  HISTORY
  v1.0.0 - 2015-01-19  
  v1.5.0 - 2020-04-15

  This translation find all events where the EventSource/Client/Location/Country element
  contains the string 'AUS' and then copies them.
  -->

  <!--  Match all  events -->
  <xsl:template match="/Events|/Events/@*">
  <xsl:copy>
  <xsl:apply-templates  select="node()|@*" />
  </xsl:copy>
  </xsl:template>

  <!-- Find all  events  whose Client location is in the AUS -->
  <xsl:template match="Event">
  <xsl:apply-templates select="EventSource/Client/Location/Country[contains(upper-case(text()),  'AUS')]" />
  </xsl:template>

  <!--  Country template - deep copy the event -->
  <xsl:template match="Country">
  <xsl:copy-of select="ancestor::Event"  />
  </xsl:template>
  </xsl:stylesheet>
```

The Great Britain selection translation is

``` xml
<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet
    version="3.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns="event-logging:3"
    xmlns:stroom="stroom"
    xpath-default-namespace="event-logging:3
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"> 

  <!--
  ClientGBR Translation: CHANGE  HISTORY
  v1.0.0 - 2015-01-19  
  v1.5.0 - 2020-04-15

  This translation find all events where the EventSource/Client/Location/Country
  element contains the string 'GBR' and then copies them.
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

We will store this capability in the Explorer Folder **MultiGeoForwarding**.
Create two new XSLT under this folder, one called **ClientAUS** and one called **ClientGBR**.
Copy and paste the relevant XSL from the above code blocks into its comparable XSLT windows.
Save the XSLT by clicking on the save {{< stroom-icon "save.svg" >}} icon.
Having created the two translations we see

{{< screenshot "HOWTOs/v6/UI-MultiGeoFwd-00.png" >}}Stroom UI MultiGeoFwd - MultiGeoFwd Folder{{< /screenshot >}}


## Create Pipeline

We now create a Pipeline called **MultiGeoFwd** in the Explorer tree.
Within the _MultiGeoForwarding_ folder right click to bring up the object context menu and sub-menu then create a New
Pipeline called **MultiGeoFwd**.
The Explorer should now look like

{{< screenshot "HOWTOs/v6/UI-MultiGeoFwd-01.png" >}}Stroom UI MultiGeoFwd - MultiGeoFwd Pipeline{{< /screenshot >}}

Clicking on the Pipeline **Settings** sub-item and add an appropriate description

{{< screenshot "HOWTOs/v6/UI-MultiGeoFwd-02.png" >}}Stroom UI MultiGeoFwd - MultiGeoFwd Pipeline description{{< /screenshot >}}

Now switch to the **Structure** sub-item and select the {{< pipe-elm "Source" "Source" >}} element.

Next click on the _Add New Pipeline Element_ icon {{< stroom-icon "add.svg" "Add pipeline element" >}}.

{{< screenshot "HOWTOs/v6/UI-MultiGeoFwd-04.png" >}}Stroom UI MultiGeoFwd - MultiGeoFwd Pipeline add new pipeline element{{< /screenshot >}}

Select _Parser, XMLParser_ from the Element context menu

{{< screenshot "HOWTOs/v6/UI-MultiGeoFwd-05.png" >}}Stroom UI MultiGeoFwd - MultiGeoFwd Pipeline select pipeline parser{{< /screenshot >}}

Click on **OK** in the _Create Element_ dialog box to accept the default for the parser Id.

{{< screenshot "HOWTOs/v6/UI-MultiGeoFwd-06.png" >}}Stroom UI MultiGeoFwd - MultiGeoFwd Pipeline select pipeline parser{{< /screenshot >}}

We continue building the pipeline structure by sequentially selecting the last Element and adding the next required Element.
We next add a _SplitFilter_ Element

{{< screenshot "HOWTOs/v6/UI-MultiGeoFwd-07.png" >}}Stroom UI MultiGeoFwd - MultiGeoFwd Pipeline select pipeline SplitFilter{{< /screenshot >}}

We change the SplitFilter **Id:** from _splitFilter_ to _multiGeoSplitFilter_ and click on **OK** to add the Element to the Pipeline

{{< screenshot "HOWTOs/v6/UI-MultiGeoFwd-08.png" >}}Stroom UI MultiGeoFwd - MultiGeoFwd Pipeline select pipeline SplitFilter Id{{< /screenshot >}}

Our Pipeline currently looks like

{{< screenshot "HOWTOs/v6/UI-MultiGeoFwd-09.png" >}}Stroom UI MultiGeoFwd - MultiGeoFwd Pipeline Structure view{{< /screenshot >}}

We now add the two XSLT translation elements, ClientAUS and ClientGBR to the split Filter.
Left click on the split Filter then left click on the Add New Pipeline Element to bring up the pipeline Element context menu and select the XSLTFilter item 

{{< screenshot "HOWTOs/v6/UI-MultiGeoFwd-10.png" >}}Stroom UI MultiGeoFwd - MultiGeoFwd Pipeline XSLT Filter{{< /screenshot >}}

and change the **Id:** from _xsltFilter_ to _ClientAUSxsltFilter_

Now select the multiGeoSplitFilter Element again and add another XSLTFilter as previously

{{< screenshot "HOWTOs/v6/UI-MultiGeoFwd-11.png" >}}Stroom UI MultiGeoFwd - MultiGeoFwd Pipeline XSLT Filter2{{< /screenshot >}}

Name this xsltFilter _ClientGBRxsltFilter_.

At this stage the Pipeline should look like

{{< screenshot "HOWTOs/v6/UI-MultiGeoFwd-12.png" >}}Stroom UI MultiGeoFwd - MultiGeoFwd Pipeline view{{< /screenshot >}}

To continue building the Pipeline Structure, left click the {{< pipe-elm "XSLTFilter" "ClientAUSxlstFilter" >}}

ClientAUSxsltFilter element then left click on the _Add New Pipeline Element_ {{< stroom-icon "add.svg" "Add new pipeline element" >}} to bring up the pipeline Element context menu and select the SchemaFilter item.

{{< screenshot "HOWTOs/v6/UI-MultiGeoFwd-14.png" >}}Stroom UI MultiGeoFwd - MultiGeoFwd Pipeline select SchemaFilter{{< /screenshot >}}

and change the **Id:** from schemaFilter to AUSschemaFilter to show

{{< screenshot "HOWTOs/v6/UI-MultiGeoFwd-15.png" >}}Stroom UI MultiGeoFwd - MultiGeoFwd Pipeline development{{< /screenshot >}}

Now, left click the AUSschemaFilter element then then right click on the _Add New Pipeline Element_ {{< stroom-icon "add.svg" "Add new pipeline element">}} to bring up the pipeline Element context menu and select the XMLWriter item 

{{< screenshot "HOWTOs/v6/UI-MultiGeoFwd-16.png" >}}Stroom UI MultiGeoFwd - MultiGeoFwd Pipeline select XMLWriter{{< /screenshot >}}

and change the **Id:** from xmlWriter to AUSxmlWriter

{{< screenshot "HOWTOs/v6/UI-MultiGeoFwd-17.png" >}}Stroom UI MultiGeoFwd - MultiGeoFwd Pipeline XMLWriter Id{{< /screenshot >}}

Your Pipeline should now look like

{{< screenshot "HOWTOs/v6/UI-MultiGeoFwd-18.png" >}}Stroom UI MultiGeoFwd - MultiGeoFwd Pipeline development2{{< /screenshot >}}

Finally, left click the  AUSxmlWriter element then then right click on the Add New Pipeline Element  _Add New Pipeline Element_ {{< stroom-icon "add.svg" "Add new pipeline element" >}}  to bring up the **Destination** pipeline Element context menu.

Select **RollingFileAppender**

{{< screenshot "HOWTOs/v6/UI-MultiGeoFwd-19.png" >}}Stroom UI MultiGeoFwd - MultiGeoFwd Pipeline select destination{{< /screenshot >}}

and change the **Id:** from rollingFileAppender to AUSrollingFileAppender to show

{{< screenshot "HOWTOs/v6/UI-MultiGeoFwd-20.png" >}}Stroom UI MultiGeoFwd - MultiGeoFwd Pipeline development3{{< /screenshot >}}

This completes the pipeline structure for the AUS branch of the pipeline.  Replicate the process of adding schemaFilter, xmlWriter, and rollingFileAppender Elements for the GBR branch of the pipeline to get the complete pipeline structure as below

{{< screenshot "HOWTOs/v6/UI-MultiGeoFwd-21.png" >}}Stroom UI MultiGeoFwd - MultiGeoFwd Pipeline Structure completed{{< /screenshot >}}

Save your Pipeline development work by clicking on the {{< stroom-icon "save.svg" >}} icon at the top left of the MultiGeoFwd pipeline tab.

We will now assign appropriate properties to each of the pipeline’s elements.
First, the client xsltFilters.
Click the ClientAUSxsltFilter element to show

{{< screenshot "HOWTOs/v6/UI-MultiGeoFwd-22.png" >}}Stroom UI MultiGeoFwd - MultiGeoFwd Pipeline xsltFilter properties{{< /screenshot >}}

In the middle pane click on the _xslt_ **Property Name** line.
Now click on the **Edit Property** {{< stroom-icon "edit.svg" >}} icon

{{< screenshot "HOWTOs/v6/UI-MultiGeoFwd-23.png" >}}Stroom UI MultiGeoFwd - MultiGeoFwd Pipeline xslt Edit Property{{< /screenshot >}}

This will bring up the **Edit Property** selection window

{{< screenshot "HOWTOs/v6/UI-MultiGeoFwd-24.png" >}}Stroom UI MultiGeoFwd - MultiGeoFwd Pipeline xslt Edit Property window{{< /screenshot >}}

Select the **Value:** to be the ClientAUS translation.

{{< screenshot "HOWTOs/v6/UI-MultiGeoFwd-25.png" >}}Stroom UI MultiGeoFwd - MultiGeoFwd Pipeline xslt Edit Property window value{{< /screenshot >}}

Click on **OK** twice to get your back to main MultiGeoFwd tab which should now have an updated _middle pane_ that looks like

{{< screenshot "HOWTOs/v6/UI-MultiGeoFwd-26.png" >}}Stroom UI MultiGeoFwd - MultiGeoFwd Pipeline xslt Edit Property completed{{< /screenshot >}}

Now go back to the top pane of the Pipeline Structure and select the AUSschemaFilter element on the pipeline.
Then click the _schemaGroup_ **Property Name** line.
Now click on the **Edit Property** {{< stroom-icon "edit.svg" "Edit property" >}} icon.
Set the Property Value to be EVENTS.

{{< screenshot "HOWTOs/v6/UI-MultiGeoFwd-27.png" >}}Stroom UI MultiGeoFwd - MultiGeoFwd Pipeline schemaFilter Edit Property{{< /screenshot >}}

then press **OK**.

{{< screenshot "HOWTOs/v6/UI-MultiGeoFwd-28.png" >}}Stroom UI MultiGeoFwd - MultiGeoFwd Pipeline schemaFilter Edit Property completed{{< /screenshot >}}

Now select the AUSxmlWriter element in the pipeline structure and click the _indentOutput_ **Property Name** line.
Click on the **Edit Property** {{< stroom-icon "edit.svg" "Edit property" >}} icon.
Set the Property Value to be _true_.
The completed Element should look like

{{< screenshot "HOWTOs/v6/UI-MultiGeoFwd-29.png" >}}Stroom UI MultiGeoFwd - MultiGeoFwd Pipeline xmlWriter Edit Property completed{{< /screenshot >}}

Next, select the {{< pipe-elm "RollingFileAppender" "AUSrollingFileAppender" >}} and change the Properties as per

* fileName to be `fwd_${ms}.lock`
* frequency to be `15m`
* outputPaths to be `/stroom/volumes/defaultStreamVolume/forwarding/AUS00`
* rolledFileName to be `fwd_${ms}.ready`

Note that these settings are for demonstration purposes only and will depend on your unique Stroom instance's configuration.
The outputPath can contain replacement variables to provide more structure if desired, see [File Output substitution variables]({{< relref "docs/user-guide/pipelines/file-output" >}}).

{{< screenshot "HOWTOs/v6/UI-MultiGeoFwd-31.png" >}}Stroom UI MultiGeoFwd - MultiGeoFwd Pipeline rollingFileAppender Edit Property completed{{< /screenshot >}}

Repeat this Element Property Name assignment for the GBR branch of the pipeline substituting the ClientGBR translation and /stroom/volumes/defaultStreamVolume/forwarding/GBR00  for rollingFileAppender outputPaths where appropriate.

Note, if you expect lots of events to be processed by the pipeline, you may which to create multiple outputPaths.
For example, you could have

```text
/stroom/volumes/defaultStreamVolume/forwarding/_AUS00_,
/stroom/volumes/defaultStreamVolume/forwarding/_AUS01_,
/stroom/volumes/defaultStreamVolume/forwarding/_AUS0n_
```
and 

```text
/stroom/volumes/defaultStreamVolume/forwarding/_GBR00_,
/stroom/volumes/defaultStreamVolume/forwarding/_GBR01_,
/stroom/volumes/defaultStreamVolume/forwarding/_GBR0n_
```

as appropriate. 

Save the pipeline by pressing the Save {{< stroom-icon "save.svg" >}} icon.


## Test Pipeline

We first select a stream of Events which we know to have both AUS and GBR Client locations.
We have such a stream from our Apache-SSLBlackBox-V2.0-EVENTS Feed.

{{< screenshot "HOWTOs/v6/UI-MultiGeoFwd-32.png" >}}Stroom UI MultiGeoFwd - MultiGeoFwd Pipeline Test Events selection{{< /screenshot >}}

We select the Events stream and Enter Stepping Mode by pressing the large {{< stroom-icon "stepping.svg" >}} button in the bottom right.

{{< screenshot "HOWTOs/v6/UI-MultiGeoFwd-33.png" >}}Stroom UI MultiGeoFwd - MultiGeoFwd Pipeline Test Enter Stepping Mode{{< /screenshot >}}

and we will choose the {{< stroom-icon "document/Pipeline.svg">}} _MultiGeoFwd_ to step with.

{{< screenshot "HOWTOs/v6/UI-MultiGeoFwd-35.png" >}}Stroom UI MultiGeoFwd - MultiGeoFwd Pipeline Test selection{{< /screenshot >}}

We are now presented with the _Stepping_ tab positioned at the start
{{< screenshot "HOWTOs/v6/UI-MultiGeoFwd-36.png" >}}Stroom UI MultiGeoFwd - MultiGeoFwd Pipeline start{{< /screenshot >}}

If we step forward by clicking on the {{< stroom-icon "step-forward-green.svg" "Step Forward" >}} icon we will see that our first event in our source stream has a Client Country location of USA.

{{< screenshot "HOWTOs/v6/UI-MultiGeoFwd-37.png" >}}Stroom UI MultiGeoFwd - MultiGeoFwd Pipeline Test first record{{< /screenshot >}}

If we now click on the {{< pipe-elm "XSLTFilter" "ClientAUSxsltFilter" >}} element we will see the ClientAUS translation in the code pane.
The first Event in the _input_ pane and an empty event in the _output_ pane.
The output is empty as the Client/Location/Country is NOT the string _AUS_, which is what the translation is matching on.

{{< screenshot "HOWTOs/v6/UI-MultiGeoFwd-38.png" >}}Stroom UI MultiGeoFwd - MultiGeoFwd Pipeline Test first record output empty{{< /screenshot >}}

If we step forward to the 5th Event we will see the _output_ pane change and become populated.
This is because this Event's Client/Location/Country value is the string _AUS_.

{{< screenshot "HOWTOs/v6/UI-MultiGeoFwd-39.png" >}}Stroom UI MultiGeoFwd - MultiGeoFwd Pipeline Test fifth record output{{< /screenshot >}}

Note, that you can move to the 5th Event on the pipeline by clicking on the {{< stroom-icon "step-forward-green.svg" "Step Forward" >}} icon repeatedly until you get to the 5th event, or you can insert your cursor into the **recordNo** of the stepping key to manually change the recordNo from 1 to 5
{{< screenshot "HOWTOs/v6/UI-MultiGeoFwd-40.png" >}}Stroom UI MultiGeoFwd - MultiGeoFwd Pipeline stepping key{{< /screenshot >}} and then press **Enter**.
This jumps the stepping process to the RecordNo you specify, in this particular case "5". 

If you repeatedly click on the {{< stroom-icon "step-forward-green.svg" "Step Forward" >}} icon seven more times you will continue to see Events in the _output_ pane, as our stream source Client/Location/Country value is _AUS_ for Events 5-11.

Now, double click on the {{< pipe-elm "XSLTFilter" "ClientGBRxsltFilter" >}} element.
The _output_ pane will once again be empty as the Client/Location/Country value of this Event (AUS) does not match what your translation is filtering on (GBR).

If you now step forward one event using the {{< stroom-icon "step-forward-green.svg" "Step Forward" >}} icon, you will see the ClientGBR translation _output_ pane populate as Events 12-16 have a Client/Location/Country of GRC.

{{< screenshot "HOWTOs/v6/UI-MultiGeoFwd-42.png" >}}Stroom UI MultiGeoFwd - MultiGeoFwd Pipeline ClientGBR populated{{< /screenshot >}}

We have thus tested the ‘splitting’ effect of our pipeline.
We now need to turn it on and produce files.


### Enabling Processors for Multi Forwarding Pipeline

To enable the Processors for the pipeline, select the _MultiGeoFwd_ pipeline tab and then select the Processors sub-item.

{{< screenshot "HOWTOs/v6/UI-MultiGeoFwd-43.png" >}}Stroom UI MultiGeoFwd - MultiGeoFwd Pipeline Processors{{< /screenshot >}}

For testing purposes, we will only apply this pipeline to our Apache-SSLBlackBox-V2.0-EVENTS feed to minimise the test output files. 

To create the Processor, click the Add Processor {{< stroom-icon "add.svg" "Add Processor" >}} icon to bring up the _Add Processor_ selection window. 

Add the following items to the processor:
* Feed is `Apache-SSLBlackBox-V2.0-EVENTS`
* Type = `Events`

{{< screenshot "HOWTOs/v6/UI-MultiGeoFwd-44.png" >}}Stroom UI MultiGeoFwd - MultiGeoFwd Pipeline Processors Filters{{< /screenshot >}}

then press **OK** to see

{{< screenshot "HOWTOs/v6/UI-MultiGeoFwd-45.png" >}}Stroom UI MultiGeoFwd - MultiGeoFwd Pipeline Processors Configured{{< /screenshot >}}

Enable the processors by checking both Enabled check boxes

{{< screenshot "HOWTOs/v6/UI-MultiGeoFwd-46.png" >}}Stroom UI MultiGeoFwd - MultiGeoFwd Pipeline Processors Enabled{{< /screenshot >}}

If we switch to the Active Tasks tab of the MultiGeoFwd pipeline, a refresh of the panes {{< stroom-icon "refresh.svg" >}} will show that we have passed streams from the
APACHE-SSLBlackBox-V2.0-EVENTS feed to completion.
If we select the MultiGeoFwd pipeline in the top pane we will see each stream that has run.

{{< screenshot "HOWTOs/v6/UI-MultiGeoFwd-47.png" >}}Stroom UI MultiGeoFwd - MultiGeoFwd Pipeline Processors Active Tasks{{< /screenshot >}}

Take note that all streams have processed on Node node1a. 


### Examine Output Files on Destination Node

If we navigate to the /stroom/volumes/defaultStreamVolume/forwarding directory on the processing node we should be able to view the expected output files.

{{< command-line "testdoc" "localhost" >}}
cd forwarding
ls -lR
(out).:
(out)total 0
(out)drwxr-xr-x. 2 testdoc testdoc 129 May  5 01:13 AUS00
(out)drwxr-xr-x. 2 testdoc testdoc 129 May  5 01:13 GBR00
(out)
(out)./AUS00:
(out)total 136
(out)-rw-r--r--. 1 testdoc testdoc 21702 May  4 22:28 fwd_1588588112856.ready
(out)-rw-r--r--. 1 testdoc testdoc 21702 May  4 22:44 fwd_1588589043294.ready
(out)-rw-r--r--. 1 testdoc testdoc 64452 May  5 01:09 fwd_1588597744865.ready
(out)-rw-r--r--. 1 testdoc testdoc 21692 May  5 01:14 fwd_1588598005439.lock
(out)
(out)./GBR00:
(out)total 96
(out)-rw-r--r--. 1 testdoc testdoc 15660 May  4 22:28 fwd_1588588112809.ready
(out)-rw-r--r--. 1 testdoc testdoc 15660 May  4 22:44 fwd_1588589043293.ready
(out)-rw-r--r--. 1 testdoc testdoc 46326 May  5 01:09 fwd_1588597744865.ready
(out)-rw-r--r--. 1 testdoc testdoc 15650 May  5 01:14 fwd_1588598005408.lock
{{</ command-line >}}

The output directory contains files with suffixes of  *.lock or *.ready.
All the files that are ‘currently processing’ have a nomenclature of *.lock suffix.
These are the files that our pipeline is currently writing to.
Remember we configured the rollingFileAppender to roll the files at a frequency of 15 minutes.
We may need to wait up to 15 minutes before a file move from .lock to .ready status.

If we check one of the AUS00 output files we see the expected result

{{< command-line "testdoc" "localhost" >}}
less AUS00/fwd_1588588112856.ready
(out)<?xml version="1.1" encoding="UTF-8"?>
(out)<Events xmlns="event-logging:3"
(out)        xmlns:stroom="stroom"
(out)        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
(out)        xmlns:xs="http://www.w3.org/2001/XMLSchema"
(out)        xsi:schemaLocation="event-logging:3 file://event-logging-v3.2.3.xsd"
(out)        Version="3.2.3">
(out)   <Event>
(out)      <EventTime>
(out)         <TimeCreated>2020-01-18T22:43:04.000Z</TimeCreated>
(out)      </EventTime>
(out)      <EventSource>
(out)         <System>
(out)            <Name>LinuxWebServer</Name>
(out)            <Environment>Production</Environment>
(out)         </System>
(out)         <Generator>Apache  HTTPD</Generator>
(out)         <Device>
(out)            <HostName>stroomnode00.strmdev00.org</HostName>
(out)            <IPAddress>192.168.2.245</IPAddress>
(out)         </Device>
(out)         <Client>
(out)            <HostName>host32.strmdev01.org</HostName>
(out)            <IPAddress>192.168.8.151</IPAddress>
(out)            <Port>62015</Port>
(out)            <Location>
(out)               <Country>AUS</Country>
(out)               <Site>Sydney-S02</Site>
(out)               <Building>RC45</Building>
(out)               <Room>5-134</Room>
(out)               <TimeZone>+10:00/+11:00</TimeZone>
(out)            </Location>
(out)         </Client>
(out)
(out)         ....
{{</ command-line >}}

Similarly, if we look at one of the GBR00 output files we also see the expected output

{{< command-line "testdoc" "localhost" >}}
less GBR00/fwd_1588588112809.ready
(out)<?xml version="1.1" encoding="UTF-8"?>
(out)<Events xmlns="event-logging:3"
(out)        xmlns:stroom="stroom"
(out)        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
(out)        xmlns:xs="http://www.w3.org/2001/XMLSchema"
(out)        xsi:schemaLocation="event-logging:3 file://event-logging-v3.2.3.xsd"
(out)        Version="3.2.3">
(out)   <Event>
(out)      <EventTime>
(out)         <TimeCreated>2020-01-18T12:50:06.000Z</TimeCreated>
(out)      </EventTime>
(out)      <EventSource>
(out)         <System>
(out)            <Name>LinuxWebServer</Name>
(out)            <Environment>Production</Environment>
(out)         </System>
(out)         <Generator>Apache  HTTPD</Generator>
(out)         <Device>
(out)            <HostName>stroomnode00.strmdev00.org</HostName>
(out)            <IPAddress>192.168.2.245</IPAddress>
(out)         </Device>
(out)         <Client>
(out)            <HostName>host14.strmdev00.org</HostName>
(out)            <IPAddress>192.168.234.9</IPAddress>
(out)            <Port>62429</Port>
(out)            <Location>
(out)               <Country>GBR</Country>
(out)               <Site>Bristol-S22</Site>
(out)               <Building>CAMP2</Building>
(out)               <Room>Rm67</Room>
(out)               <TimeZone>+00:00/+01:00</TimeZone>
(out)            </Location>
(out)         </Client>
(out)
(out)        ....
{{</ command-line >}}

At this point, you can manage the .ready files in any manner you see fit.
