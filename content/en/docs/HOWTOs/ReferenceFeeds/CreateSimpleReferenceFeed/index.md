---
title: "Create a Simple Reference Feed"
linkTitle: "Create a Reference Feed"
#weight:
date: 2021-07-12
#tags: 
description: >
  How to create a reference feed for decorating event data using reference data lookups.

---

<!-- Created with Stroom v6.1-beta.16 -->


## Introduction

A **Reference Feed** is a temporal set of data that a pipeline's translation can look up to gain additional information to decorate the subject data of the translation.
For example, an XML Event.

A Reference Feed is temporal, in that, each time a new set of reference data is loaded into Stroom, the effective date (for the data) is also recorded.
Thus by using a timestamp field with the subject data, the appropriate batch of reference data can be accessed.

A typical reference data set to support the Stroom XML Event schema might be on that relates to devices.
Such a data set can contain the device logical identifiers such as fully qualified domain name and ip address and their geographical location information such as country, site, building, room and timezone.

The following example will describe how to create a reference feed for such device data.
We will call the reference feed `GeoHost-V1.0-REFERENCE`.


## Reference Data

Our reference data will be supplied in a <TAB> separated file containing the fields

* the device Fully Qualified Domain Name
* the device IP Address
* the device Country location (using ISO 3166-1 alpha-3 codes)
* the device Site location
* the device Building location
* the device TimeZone location (both standard then daylight timezone offsets from UTC)

For simplicity, our example will use a file with just 5 entries

{{< screenshot "HOWTOs/v6/UI-CreateReferenceFeed-75.png" >}}Stroom UI CreateReferenceFeed - Raw Data{{< /screenshot >}}

A copy of this sample data source can be found [here](GeoHostReference.log "GeoHost REFERENCE  sample logs").
Save a copy of this data to your local environment for use later in this HOWTO.
Save this file as a text document with ANSI encoding.


## Creation

To create our Reference Event stream we need to create:

* the **Feed**
* a **Pipeline** to automatically process and store the Reference data
* a **Text Parser** to convert the text file into simple XML record format, and 
* a **Translation** to create reference data maps


### Create Feed

First, within the Explorer pane, and with the cursor having selected the Event Sources group, right click the mouse to have the object context menu appear.

{{< screenshot "HOWTOs/v6/UI-CreateReferenceFeed-00.png" >}}New Feed{{< /screenshot >}}

If you hover over the {{< stroom-icon "add.svg" "New">}} New icon then the New sub-context menu will be revealed.

Now hover the mouse over the {{< stroom-icon "feed.svg" >}} Feed icon and right click to select.

{{< screenshot "HOWTOs/v6/UI-CreateReferenceFeed-01.png" >}}New Feed Selection window{{< /screenshot >}}

When the **New Feed** selection windows comes up, navigate to the `Event Sources` system group.
Then enter the name of the reference feed `GeoHost-V1.0-REFERENCE` onto the **Name:** text entry box.
On pressing the OK button we will see the following Feed configuration tab appear.

{{< screenshot "HOWTOs/v6/UI-CreateReferenceFeed-03.png" >}}New Feed Data tab{{< /screenshot >}}

Click on the **Settings** sub-item in the `GeoHost-V1.0-REFERENCE` Feed tab to populate the initial Settings configuration.
Enter an appropriate description, classification and click on the **Reference Feed** check box

{{< screenshot "HOWTOs/v6/UI-CreateReferenceFeed-04.png" >}}New Feed Settings tab{{< /screenshot >}}

and we then use the Stream Type drop-down menu to set the stream type as Raw Reference.
At this point we save our configuration so far, by clicking on the {{< stroom-icon "save.svg" >}} save icon.
The save icon becomes ghosted and our feed configuration has been saved.

{{< screenshot "HOWTOs/v6/UI-CreateReferenceFeed-05.png" >}}New Feed Settings window configuration{{< /screenshot >}}


### Load sample Reference data

At this point we want to load our sample reference data, in order to develop our reference feed.
We can do this two ways - posting the file to our Stroom web server, or directly upload the data using the user interface.
For this example we will use Stroom's user interface upload facility.

First, open the **Data** sub-item in the `GeoHost-V1.0-REFERENCE` feed configuration tab to reveal

{{< screenshot "HOWTOs/v6/UI-CreateReferenceFeed-06.png" >}}Reference Data configuration tab{{< /screenshot >}}

Note the {{< stroom-icon "upload.svg" >}} Upload icon in the bottom left of the **Stream table** (top pane).
On clicking the Upload icon, we are presented with the data upload selection window.

{{< screenshot "HOWTOs/v6/UI-CreateReferenceFeed-07.png" >}}Upload Selection window{{< /screenshot >}}

Naturally, as this is a reference feed we are creating and this is raw data we are uploading, we select a **Stream Type:** of Raw Reference.
We need to set the **Effective:** date (really a timestamp) for this specific _stream_ of reference data.
Clicking in the **Effective:** entry box will cause a calendar selection window to be displayed (initially set to the current date).

{{< screenshot "HOWTOs/v6/UI-CreateReferenceFeed-08.png" >}}Upload data settings{{< /screenshot >}}

We are going to set the effective date to be late in 2019.
Normally, you would choose a time stamp that matches the generation of the reference data.
Click on the blue Previous Month icon (a less than symbol `<`) on the Year/Month line to move back to December 2019.

{{< screenshot "HOWTOs/v6/UI-CreateReferenceFeed-09.png" >}}Calendar Effective Date Selection{{< /screenshot >}}

Select the 1st (clicking on 1) at which point the calendar selection window will disappear and a time of 2019-12-01T00:00:00.000Z is displayed.
This is the default whenever  using the calendar selection window in Stroom - the resultant timestamp is that of the day selected at 00:00:00 (Zulu time).
To get the calendar selection window to disappear, click anywhere outside of the timestamp entry box.

{{< screenshot "HOWTOs/v6/UI-CreateReferenceFeed-10.png" >}}Upload data choose file{{< /screenshot >}}

Note, if you happen to click on the **OK** button before selecting the **File** (or Stream Type for that matter), an appropriate Alert dialog box will be displayed

{{< screenshot "HOWTOs/v6/UI-CreateReferenceFeed-11.png" >}}Upload Data No file set{{< /screenshot >}}

We don't need to set **Meta Data** for this stream of reference data, but we (obviously) need to select the file.
For the purposes of this example, we will utilise the file **GeoHostReference.log** you downloaded earlier in the **Reference Data** section of this document.
This file contains a header and five lines of reference data as per

{{< screenshot "HOWTOs/v6/UI-CreateReferenceFeed-75.png" >}}Stroom UI CreateReferenceFeed - Raw Data{{< /screenshot >}}

When we construct the pipeline for this reference feed, we will see how to make use of the header line.

So, click on the **Choose File** button to bring up a file selector window.
Navigate within the selector window to the location on your location machine where you have saved the GeoHostReference.log file.
On clicking **Open** we return to the **Upload** window with the file selected.

{{< screenshot "HOWTOs/v6/UI-CreateReferenceFeed-12.png" >}}Upload Reference Data - File chosen{{< /screenshot >}}

On clicking **OK** we get an Alert dialog window to advise a file has been uploaded.

{{< screenshot "HOWTOs/v6/UI-CreateReferenceFeed-13.png" >}}Upload Alert window{{< /screenshot >}}

at which point we press **Close**.

At this point, the **Upload** selection window closes, and we see our file displayed  in the `GeoHost-V1.0-REFERENCE` **Data** stream table.

{{< screenshot "HOWTOs/v6/UI-CreateReferenceFeed-14.png" >}}Upload Display raw reference stream{{< /screenshot >}}

When we click on the newly up-loaded stream in the _Stream Table_ pane we see the other two panes fill with information.

{{< screenshot "HOWTOs/v6/UI-CreateReferenceFeed-15.png" >}}Upload Selected stream{{< /screenshot >}}

The middle pane shows the selected or _Specific_ feed and any linked streams.
A linked stream could be the resultant Reference data set generated from a Raw Reference stream.
If errors occur during processing of the stream, then a linked stream could be an Error stream.

The bottom pane displays the selected stream's data or meta-data.
If we click on the **Meta** link at the top of this pane, we will see the _Metadata_ associated with this stream.
We also note that the **Meta** link at the bottom of the pane is now embolden.

{{< screenshot "HOWTOs/v6/UI-CreateReferenceFeed-16.png" >}}Upload Selected stream - meta-data{{< /screenshot >}}

We can see the metadata we set - the EffectiveTime, and implicitly, the Feed but we also see additional fields that Stroom has added that provide more detail about the data and its delivery to Stroom such as how and when it was received.
We now need to switch back to the Data display as we need to author our reference feed translation.


### Create Pipeline

We now need to create the pipeline for our reference feed so that we can create our translation and hence create reference data for our feed.

Within the Explorer pane, and having selected the `Event Sources` system group, right click to bring up the object context menu, then the New sub-context menu.
Move to the {{< stroom-icon "document/Pipeline.svg">}} and left click to select.
When the _New Pipeline_ selection window appears, navigate to, then select the `Feeds and Translations` system group then enter the name of the reference feed, GeoHost-V1.0-REFERENCE in the **Name:** text entry box.

{{< screenshot "HOWTOs/v6/UI-CreateReferenceFeed-17.png" >}}New Pipeline - GeoHost-V1.0-REFERENCE{{< /screenshot >}}

On pressing the **OK** button you will be presented with the new pipeline's configuration tab

{{< screenshot "HOWTOs/v6/UI-CreateReferenceFeed-18.png" >}}New Pipeline - Configuration tab{{< /screenshot >}}

Within **Settings**, enter an appropriate description as per

{{< screenshot "HOWTOs/v6/UI-CreateReferenceFeed-19.png" >}}New Pipeline - Configured settings{{< /screenshot >}}

We now need to select the structure this pipeline will use.
We need to move from the **Settings** sub-item on the pipeline configuration tab to the **Structure** sub-item.
This is done by clicking on the **Structure** link, at which we will see

{{< screenshot "HOWTOs/v6/UI-CreateReferenceFeed-20.png" >}}New Pipeline - Structure configuration{{< /screenshot >}}

As this pipeline will be processing reference data, we would use a `Reference Data` pipeline.
This is done by inheriting it from a defined set of Standard Pipelines.
To do this, click on the menu selection icon {{< stroom-icon "assorted/popup.png" "Menu selection">}} to the right of the **Inherit From:** test display box.

When the **Choose item** selection window appears, navigate to the `Template Pipelines` system group (if not already displayed), and select (left click) the {{< stroom-icon "document/Pipeline.svg" >}} `Reference Data` pipeline.
You can find further information about the Template Pipelines {{< external-link "here" "https://github.com/gchq/stroom-content/blob/master/source/template-pipelines/README.md" >}}.

{{< screenshot "HOWTOs/v6/UI-CreateReferenceFeed-21.png" >}}New Pipeline - Reference Data pipeline inherited{{< /screenshot >}}

Then press **OK**.
At this we will see the inherited pipeline structure of 

{{< screenshot "HOWTOs/v6/UI-CreateReferenceFeed-22.png" >}}New Pipeline - Inherited set{{< /screenshot >}}

Noting that this pipeline has not yet been saved - indicated by the * in the tab label and the highlighted {{< stroom-icon "save.svg" >}} to save, which results in

{{< screenshot "HOWTOs/v6/UI-CreateReferenceFeed-23.png" >}}New Pipeline - saved{{< /screenshot >}}

This ends the first stage of the pipeline creation.
We need to author the feed's translation.


### Create Text Converter

To turn our tab delimited data in Stroom reference data, we first need to convert the text into simple XML.
We do this using a _Text Converter_. _Test Converters_ use a _Stroom Data Splitter_ to convert text into simple XML.

Within the Explorer pane, and having selected the `Event Sources` system group, right click to bring up the object context menu.
Navigate to the {{< stroom-icon "pipeline/text.svg" "Text converter">}} item and left click to select.

When the _New Text Converter_ selection window comes up, navigate to and select `Event Sources` system group, then enter the name of the feed, GeoHost-V1.0-REFERENCE into the **Name:** text entry box as per

{{< screenshot "HOWTOs/v6/UI-CreateReferenceFeed-24.png" >}}New TextConverter{{< /screenshot >}}

On pressing the **OK** button we see the next text converter's configuration tab displayed.

{{< screenshot "HOWTOs/v6/UI-CreateReferenceFeed-25.png" >}}New TextConverter Settings{{< /screenshot >}}

Enter an appropriate description into the **Description:** text entry box, for instance

```text
Text converter for device Logical and Geographic reference feed holding FQDN, IPAddress, Country, Site, Building, Room and Time Zones.
Feed has a header and is tab separated.
```

Set the **Converter Type:** to be `Data Splitter` from the drop-down menu.

{{< screenshot "HOWTOs/v6/UI-CreateReferenceFeed-26.png" >}}New TextConverter Settings configured{{< /screenshot >}}

We next press the **Conversion** sub-item on the TextConverter tab to bring up the _Data Splitter_ editing window.

The following is our Data Splitter code (see **Data Splitter** documentation for more complete details)

```xml
<?xml version="1.1" encoding="UTF-8"?>
<dataSplitter xmlns="data-splitter:3" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="data-splitter:3 file://data-splitter-v3.0.1.xsd" version="3.0">
  <!-- 
  GEOHOST REFERENCE FEED:
  
  CHANGE HISTORY
  v1.0.0 - 2020-02-09 John Doe
  
  This is a reference feed for device Logical and Geographic data.
  
  The feed provides for each device
  * the device FQDN
  * the device IP Address
  * the device Country location (using ISO 3166-1 alpha-3 codes)
  * the device Site location
  * the device Building location
  * the device Room location
  *the device TimeZone location (both standard then daylight timezone offsets from UTC)
  
  The data is a TAB delimited file with the first line providing headings.
  
  Example data:
  
  FQDN	IPAddress	Country	Site	Building	Room	TimeZones
stroomnode00.strmdev00.org	192.168.2.245	GBR	Bristol-S00	GZero	R00	+00:00/+01:00
stroomnode01.strmdev01.org	192.168.3.117	AUS	Sydney-S04	R6	5-134	+10:00/+11:00
host01.company4.org	192.168.4.220	USA	LosAngeles-S19	ILM	C5-54-2	-08:00/-07:00
  
   -->
   
   <!-- Match the heading line - split on newline and match a maximum of one line  -->
   <split delimiter="\n" maxMatch="1">
    
    <!-- Store each heading and note we split fields on the TAB (&#9;) character -->
      <group>
        <split delimiter="&#9;">
          <var id="heading"/>
        </split>
      </group>
    </split>
    
  <!-- Match all other data lines - splitting on newline -->
   <split delimiter="\n">
     <group>
       <!-- Store each field using the column heading number for each column ($heading$1) and note we split fields on the TAB (&#9;) character -->
        <split delimiter="&#9;">
          <data name="$heading$1" value="$1"/>
        </split>
     </group>
   </split>
   </dataSplitter>
```

At this point we want to save our Text Converter, so click on the {{< stroom-icon "save.svg" >}} icon.

A copy of this data splitter can be found [here](GeoHost-data-splitter.txt "GEOHOST Data Splitter").


## Assign Text Converter to Pipeline

To test our Text Converter, we need to modify our `GeoHost-V1.0-REFERENCE` pipeline to use it.
Select the `GeoHost-V1.0-REFERENCE` pipeline tab and then select the **Structure** sub-item

{{< screenshot "HOWTOs/v6/UI-CreateReferenceFeed-27.png" >}}Associated text converter with pipeline{{< /screenshot >}}

To associate our new Text Converter with the pipeline, click on the {{< pipe-elm "combinedParser" >}} pipeline element then move the cursor to the _Property_ (middle) pane then double click on the **textConverter** Property Name to allow you to edit the property as per

{{< screenshot "HOWTOs/v6/UI-CreateReferenceFeed-28.png" >}}textConverter Edit property{{< /screenshot >}}

We leave the Property **Source:** as _Inherit_ but we need to change the Property **Value:** from _None_ to be our newly created `GeoHost-V1.0-REFERENCE` text Converter

{{< screenshot "HOWTOs/v6/UI-CreateReferenceFeed-29.png" >}}textConverter select GeoHost-V1.0-REFERENCE{{< /screenshot >}}

then press **OK**.
At this we will see the Property _Value_ set

{{< screenshot "HOWTOs/v6/UI-CreateReferenceFeed-30.png" >}}textConverter set Property Value{{< /screenshot >}}

Again press **OK** to finish editing this property and we then see that the **textConverter** property has been set to GeoHost-V1.0-REFERENCE.
Similarly set the **type** property _Value_ to "Data Splitter".

At this point, we should save our changes, by clicking on the highlighted {{< stroom-icon "save.svg" >}} icon.
The combined Parser window panes should now look like

{{< screenshot "HOWTOs/v6/UI-CreateReferenceFeed-31.png" >}}textConverter set Property Value type{{< /screenshot >}}


## Test Text Converter

To test our Text Converter, we select the {{< stroom-tab "Feed.svg" "GeoHost-V1.0-REFERENCE" >}} tab then click on our uploaded stream in the _Stream Table_ pane, then click the check box of the _Raw Reference_ stream in the _Specific Stream_ table (middle pane)

{{< screenshot "HOWTOs/v6/UI-CreateReferenceFeed-33.png" >}}textConverter - select raw reference data{{< /screenshot >}}

We now want to step our data through the Text Converter.
We enter Stepping Mode by pressing the stepping button {{< stroom-icon "stepping.svg">}} found at the bottom of the right of the stream _Raw Data_ display.

You will then be requested to choose a pipeline to step with, at which, you should navigate to the `GeoHost-V1.0-REFERENCE` pipeline as per

{{< screenshot "HOWTOs/v6/UI-CreateReferenceFeed-34.png" >}}textConverter - select pipeline to step with{{< /screenshot >}}

then press **OK**.

At this point we enter the pipeline Stepping tab

{{< screenshot "HOWTOs/v6/UI-CreateReferenceFeed-35.png" >}}textConverter - stepping tab{{< /screenshot >}}

which initially displays the Raw Reference data from our stream.

We click on the {{< pipe-elm "combinedParser" >}} icon, to display.

{{< screenshot "HOWTOs/v6/UI-CreateReferenceFeed-36.png" >}}textConverter - stepping editor workspace{{< /screenshot >}}

This _stepping_ window is divided into three sub-panes. the top one is the Text Converter editor and it will allow you to adjust the text conversion should you wish too.
The bottom left window displays the _input_ to the Text Converter.
The bottom right window displays the _output_ from the Text Converter for the given input.

We now click on the pipeline Step Forward button {{< stroom-icon "step-forward-green.svg" "Step Forward">}} to single step the Raw reference data throughout text converter.
We see that the Stepping function has displayed the heading and first data line of our raw reference data in the _input_ sub-pane and the resultant simple _records_ XML (adhering to the Stroom **records v2.0** schema) in the _output_ pane.

{{< screenshot "HOWTOs/v6/UI-CreateReferenceFeed-37.png" >}}textConverter - pipeline stepping - 1st record{{< /screenshot >}}

If we again press the {{< stroom-icon "step-forward-green.svg" "Step Forward">}} button we see the second line in our raw reference data in the _input_ sub-pane and the resultant simple _records_ XML in the _output_ pane.

{{< screenshot "HOWTOs/v6/UI-CreateReferenceFeed-38.png" >}}textConverter - pipeline stepping - 2nd record{{< /screenshot >}}

Pressing the Step Forward button {{< stroom-icon "step-forward-green.svg" "Step Forward">}} again displays our third line of our raw and converted data.
Repeat this process to view the fourth and fifth lines of converted data.

{{< screenshot "HOWTOs/v6/UI-CreateReferenceFeed-39.png" >}}textConverter - pipeline stepping - 3rd record{{< /screenshot >}}

We have now successfully tested the Text Converter for our reference feed.
Our next step is to author our translation to generate reference data records that Stroom can use.


## Create XSLT Translation

We now need to create our translation.
This XSLT translation will convert simple _records_ XML data into _ReferenceData_ records - see the Stroom **reference-data v2.0.1** Schema for details.
More information can be found {{< external-link "here" "https://github.com/gchq/stroom-content/blob/master/source/core-xml-schemas/README.md" >}}.

We first need to create an XSLT translation for our feed.
Move back to the Explorer window, and with the cursor having selected the `Event Sources` system group, right click the mouse to display the object context menu, select {{< stroom-icon "add.svg" "New" >}} _New_ => {{< stroom-icon "document/XSLT.svg" >}} _XSLT_.

{{< screenshot "HOWTOs/v6/UI-CreateReferenceFeed-40.png" >}}translation object sub-contect menu{{< /screenshot >}}

When the **New XSLT** selection window comes up, navigate to the `Event Sources` system group and enter the name of the reference feed - GeoHost-V1.0-REFERENCE into the **Name:** text entry box as per 

{{< screenshot "HOWTOs/v6/UI-CreateReferenceFeed-41.png" >}}New xslt Translation selection window{{< /screenshot >}}

On pressing the **OK** button we see the XSL tab for our translation and as previously, we enter an appropriate description before selecting the **XSLT** sub-item.

{{< screenshot "HOWTOs/v6/UI-CreateReferenceFeed-42.png" >}}New xslt - Configuration tab{{< /screenshot >}}

On selection of the **XSLT** sub-item, we are presented with the XSLT editor window

{{< screenshot "HOWTOs/v6/UI-CreateReferenceFeed-43.png" >}}xslt Translation - XSLT editor{{< /screenshot >}}

At this point, rather than edit the translation in this editor and then assign this translation to the GeoHost-V1.0-REFERENCE pipeline, we will first make the assignment in the pipeline and then develop the translation whilst stepping through the raw data.
This is to demonstrate there are a number of ways to _develop a translation_.

So, to start, save the XSLT by clicking on the {{< stroom-tab "Pipeline.svg" "GeoHost-V1.0-REFERENCE Pipeline" >}} tab to raise the GeoHost-V1.0-REFERENCE pipeline.
Then select the **Structure** sub-item followed by selecting the **XSL translationFilter** icon.
We now see the  **XSL translationFilter** Property Table for our pipeline in the middle pane.

{{< screenshot "HOWTOs/v6/UI-CreateReferenceFeed-45.png" >}}xslt translation element - property pane{{< /screenshot >}}

To associate our new translation with the pipeline, move the cursor to the _Property Table_, click on the grayed out _xslt_ Property Name and then click on the Edit Property {{< stroom-icon "edit.svg" >}} icon to allow you to edit the property as per

{{< screenshot "HOWTOs/v6/UI-CreateReferenceFeed-46.png" >}}xslt -property editor{{< /screenshot >}}

We leave the Property **Source:** as _Inherit_ and we need to change the Property **Value:** from _None_ to be our newly created GeoHost-V1.0-REFERENCE XSL translation.
To do this, position the cursor over the menu selection icon {{< stroom-icon "assorted/popup.png" "Menu Selection">}} of the **Value:** chooser and right click, at which the `Choose item` selection window appears.
Navigate to the `Event Sources` system group then select the GeoHost-V1.0-REFERENCE xsl translation.

{{< screenshot "HOWTOs/v6/UI-CreateReferenceFeed-47.png" >}}xslt - value selection{{< /screenshot >}}

then press **OK**.
At this point we will see the property **Value:** set

{{< screenshot "HOWTOs/v6/UI-CreateReferenceFeed-48.png" >}}xslt - value selected{{< /screenshot >}}

Again press **OK** to finish editing this property and we see that the _xslt_ property has been set to GeoHost-V1.0-REFERENCE.

{{< screenshot "HOWTOs/v6/UI-CreateReferenceFeed-49.png" >}}xslt - property set{{< /screenshot >}}

At this point, we should save our changes, by clicking on the highlighted {{< stroom-icon "save.svg" >}} save icon.


## Test XSLT Translation

We now go back to the {{< stroom-tab "Feed.svg" "GeoHost-V1.0-REFERENCE" >}}tab then click on our uploaded stream in the _Stream Table_ pane.
Next click the check box of the _Raw Reference_ stream in the _Specific Stream_ table (middle pane) as per

{{< screenshot "HOWTOs/v6/UI-CreateReferenceFeed-33.png" >}}GeoHost-V1.0-REFERENCE feedTab - Specific Stream{{< /screenshot >}}

We now want to step our data through the xslt Translation.
We enter Stepping Mode by pressing the stepping button {{< stroom-icon "stepping.svg">}} found at the bottom of the right of the stream _Raw Data_ display.

You will then be requested to choose a pipeline to step with, at which, you should navigate to the GeoHost-V1.0-REFERENCE pipeline as per

{{< screenshot "HOWTOs/v6/UI-CreateReferenceFeed-50.png" >}}xslt Translation - select pipeline to step with{{< /screenshot >}}

then press **OK**.

At this point we enter the pipeline through the Stepping tab {{< screenshot "HOWTOs/v6/UI-CreateReferenceFeed-35.png" >}}xslt Translation - stepping tab{{< /screenshot >}}

which initially displays the Raw Reference data from our stream.

We click on the {{< pipe-elm "xsltFilter" "translationFilter" >}} element to enter the _xslt Translation_ stepping window and all panes are empty.

{{< screenshot "HOWTOs/v6/UI-CreateReferenceFeed-51.png" >}}xslt Translation - editor{{< /screenshot >}}

As for the Text Converter, this translation _stepping_ window is divided into three sub-panes.
The top one is the XSLT Translation.
The bottom right window displays the _output_ from the XSLT Translation for the given input.

We now click on the pipeline Step Forward button {{< stroom-icon "step-forward-green.svg" "Step Forward">}} to single step the Raw reference data through our translation.
We see that the Stepping function has displayed the first _records_ XML entry in the _input_ sub-pane and the same data is displayed in the _output_ sub-pane. 

{{< screenshot "HOWTOs/v6/UI-CreateReferenceFeed-52.png" >}}xslt Translation - editor 1st record{{< /screenshot >}}

But we also note if we move along the pipeline structure to the {{< stroom-icon "fatal.svg" "Fatal Error">}} icon.

{{< screenshot "HOWTOs/v6/UI-CreateReferenceFeed-53.png" >}}xslt Translation - schema fault{{< /screenshot >}}

In essence, since the _translation_ has done nothing, and the data is simple _records_ XML, the system is indicating that it expects the _output_ data to be in the _reference-data v2.0.1_ format.

We can correct this by adding the skeleton xslt translation for reference data into our translationFilter.
Move back to the {{< pipe-elm "xsltFilter" "translationFilter" >}} element on the pipeline structure and add the following to the xsl window.

```xml
<?xml version="1.1" encoding="UTF-8" ?>
<xsl:stylesheet xpath-default-namespace="records:2"
xmlns="reference-data:2"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
xmlns:stroom="stroom" 
xmlns:evt="event-logging:3"
version="2.0">

 <xsl:template match="records">
  <referenceData xmlns="reference-data:2"
  xsi:schemaLocation="reference-data:2 file://reference-data-v2.0.xsd" version="2.0.1"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
  <xsl:apply-templates/>
  </referenceData>
  </xsl:template>
  
<!-- MAIN TEMPLATE -->
<xsl:template match="record">
  <reference>
    <map></map>
    <key></key>
    <value></value>
  </reference>
  </xsl:template>
</xsl:stylesheet>
```

And on pressing the refresh button {{< stroom-icon "refresh.svg" >}} we see that the _output_ window is an empty ReferenceData element.

{{< screenshot "HOWTOs/v6/UI-CreateReferenceFeed-54.png" >}}xslt Translation - null translation{{< /screenshot >}}

Also note that if we move to the {{< pipe-elm "schemaFilter" >}} element on the pipeline structure, we no longer have an "Invalid Schema Location" error.

We next extend the translation to actually generate reference data.
The translation will now look like

```xml
<?xml version="1.1" encoding="UTF-8" ?>
<xsl:stylesheet xpath-default-namespace="records:2"
xmlns="reference-data:2"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
xmlns:stroom="stroom" 
xmlns:evt="event-logging:3"
version="2.0">

 <!--
  GEOHOST REFERENCE FEED:
  
  CHANGE HISTORY
  v1.0.0 - 2020-02-09 John Doe
  
  This is a reference feed for device Logical and Geographic data.
  
  The feed provides for each device
  * the device FQDN
  * the device IP Address
  * the device Country location (using ISO 3166-1 alpha-3 codes)
  * the device Site location
  * the device Building location
  * the device Room location
  *the device TimeZone location (both standard then daylight timezone offsets from UTC)  
  
  The reference maps are
  FQDN_TO_IP - Fully Qualified Domain Name to IP Address
  IP_TO_FQDN - IP Address to FQDN (HostName)
  FQDN_TO_LOC - Fully Qualified Domain Name to Location element
  -->

 <xsl:template match="records">
  <referenceData xmlns="reference-data:2"
  xsi:schemaLocation="reference-data:2 file://reference-data-v2.0.xsd" version="2.0.1">
  <xsl:apply-templates/>
  </referenceData>
  </xsl:template>
  
<!-- MAIN TEMPLATE -->
<xsl:template match="record">
  <!-- FQDN_TO_IP map -->
  <reference>
    <map>FQDN_TO_IP</map>
    <key>
      <xsl:value-of select="lower-case(data[@name='FQDN']/@value)" />
    </key>
    <value>
      <IPAddress>
        <xsl:value-of select="data[@name='IPAddress']/@value" />
      </IPAddress>
    </value>
  </reference>
  
  <!-- IP_TO_FQDN map -->
  <reference>
    <map>IP_TO_FQDN</map>
    <key>
      <xsl:value-of select="lower-case(data[@name='IPAddress']/@value)" />
    </key>
    <value>
      <HostName>
        <xsl:value-of select="data[@name='FQDN']/@value" />
      </HostName>
    </value>
  </reference>
</xsl:template>
</xsl:stylesheet>
```

and when we refresh, by pressing the _Refresh Current Step_ button {{< stroom-icon "refresh-green.svg" "Refresh Step" >}} we see that the _output_ window now has _Reference_ elements within the parent _ReferenceData_ element

{{< screenshot "HOWTOs/v6/UI-CreateReferenceFeed-55.png" >}}xslt Translation - basic translation{{< /screenshot >}}

If we press the Step Forward button {{< stroom-icon "step-forward-green.svg" "Step Forward" >}} we see the second _record_ of our raw reference data in the _input_ sub-pane and the resultant _Reference_ elements

{{< screenshot "HOWTOs/v6/UI-CreateReferenceFeed-56.png" >}}xslt Translation - basic translation next record{{< /screenshot >}}

At this point it would be wise to save our translation.
This is done by clicking on the highlighted {{< stroom-icon "save.svg" >}} icon in the top left-hand area of the window under the tabs.

We can now further our Reference by adding a Fully Qualified Domain Name to Location reference - FQDN_TO_LOC and so now the translation looks like

```xml
<?xml version="1.1" encoding="UTF-8" ?>
<xsl:stylesheet xpath-default-namespace="records:2"
xmlns="reference-data:2"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
xmlns:stroom="stroom" 
xmlns:evt="event-logging:3"
version="2.0">

 <!--
  GEOHOST REFERENCE FEED:
  
  CHANGE HISTORY
  v1.0.0 - 2020-02-09 John Doe
  
  This is a reference feed for device Logical and Geographic data.
  
  The feed provides for each device
  * the device FQDN
  * the device IP Address
  * the device Country location (using ISO 3166-1 alpha-3 codes)
  * the device Site location
  * the device Building location
  * the device Room location
  *the device TimeZone location (both standard then daylight timezone offsets from UTC)  
  
  The reference maps are
  FQDN_TO_IP - Fully Qualified Domain Name to IP Address
  IP_TO_FQDN - IP Address to FQDN (HostName)
  FQDN_TO_LOC - Fully Qualified Domain Name to Location element
  -->

 <xsl:template match="records">
  <referenceData xmlns="reference-data:2"
  xsi:schemaLocation="reference-data:2 file://reference-data-v2.0.xsd" version="2.0.1">
  <xsl:apply-templates/>
  </referenceData>
  </xsl:template>
  
<!-- MAIN TEMPLATE -->
<xsl:template match="record">
  <!-- FQDN_TO_IP map -->
  <reference>
    <map>FQDN_TO_IP</map>
    <key>
      <xsl:value-of select="lower-case(data[@name='FQDN']/@value)" />
    </key>
    <value>
      <IPAddress>
        <xsl:value-of select="data[@name='IPAddress']/@value" />
      </IPAddress>
    </value>
  </reference>
  
  <!-- IP_TO_FQDN map -->
  <reference>
    <map>IP_TO_FQDN</map>
    <key>
      <xsl:value-of select="lower-case(data[@name='IPAddress']/@value)" />
    </key>
    <value>
      <HostName>
        <xsl:value-of select="data[@name='FQDN']/@value" />
      </HostName>
    </value>
  </reference>
  
   <!-- FQDN_TO_LOC map -->
  <reference>
    <map>FQDN_TO_LOC</map>
    <key>
      <xsl:value-of select="lower-case(data[@name='FQDN']/@value)" />
    </key>
    <value>
    <!--
    Note, when mapping to a XML node set, we make use of the Event namespace - i.e. evt: 
    defined on our stylesheet element. This is done, so that, when the node set is returned,
    it is within the correct namespace.
    -->
      <evt:Location>
        <evt:Country>
        <xsl:value-of select="data[@name='Country']/@value" />
        </evt:Country>
        <evt:Site>
        <xsl:value-of select="data[@name='Site']/@value" />
        </evt:Site>
        <evt:Building>
        <xsl:value-of select="data[@name='Building']/@value" />
        </evt:Building>
        <evt:Room>
        <xsl:value-of select="data[@name='Room']/@value" />
        </evt:Room>
        <evt:TimeZone>
        <xsl:value-of select="data[@name='TimeZones']/@value" />
        </evt:TimeZone>
      </evt:Location>
    </value>
  </reference>
</xsl:template>
</xsl:stylesheet>
```
and our second ReferenceData element would now look like

{{< screenshot "HOWTOs/v6/UI-CreateReferenceFeed-57.png" >}}xslt Translation - complete translation 2nd record{{< /screenshot >}}

We have completed the translation and have hence completed the development of our GeoHost-V1.0-REFERENCE reference feed.

At this point, the reference feed is set up to accept Raw Reference data, but it will not automatically process the raw data and hence it will not place reference data into the reference data store.
To have Stroom automatically process Raw Reference streams, you will need to enable _Processors_ for this pipeline.


## Enabling the Reference Feed Processors

We now create the pipeline Processors for this feed, so that the raw reference data will be transformed into Reference Data on ingest and save to Reference Data stores.

Open the reference feed pipeline by selecting the {{< stroom-tab "Pipeline.svg" "GeoHost-V1.0-REFERENCE" >}} tab to raise the GeoHost-V1.0-REFERENCE pipeline.
Then select the **Processors** sub-tab to show

{{< screenshot "HOWTOs/v6/UI-CreateReferenceFeed-58.png" >}}pipeline Processors{{< /screenshot >}}

This configuration tab is divided into two panes.
The top pane shows the current enabled Processors and any recently processed streams and the bottom pane provides meta-data about each Processor or recently processed streams.

First, move the mouse to the Add Processor {{< stroom-icon "add.svg" "Add Processor" >}} icon at the top left of the top pane.
Select by left clicking this icon to have displayed the **Add Filter** selection window

{{< screenshot "HOWTOs/v6/UI-CreateReferenceFeed-59.png" >}}pipeline Processors - Add Filter{{< /screenshot >}}

This selection window allows us to _filter_ what set of data streams we want our Processor to process.
As our intent is to enable processing for all GeoHost-V1.0-REFERENCE streams, both already received and yet to be received, then our filtering criteria is just to process all Raw Reference for this feed, ignoring all other conditions.

To do this, first click on the **Add Term** {{< stroom-icon "add.svg" "Add Term">}} icon to navigate to the desired feed name (GeoHost-V1.0-REFERENCE) object

{{< screenshot "HOWTOs/v6/UI-CreateReferenceFeed-60.png" >}}pipeline Processors - Choose Feed name{{< /screenshot >}}

and press **OK** to make the selection.

Next, we select the required _stream type_.
To do this click on the **Add Term** {{< stroom-icon "add.svg" "Add Term">}} icon again.
Click on the down arrow to change the Term selection from _Feed_ to _Type_.
Click in the **Value** position on the highlighted line (it will be currently empty).
Once you have clicked here a drop-down box will appear as per

{{< screenshot "HOWTOs/v6/UI-CreateReferenceFeed-61.png" >}}pipeline Processors - Choose Stream Type{{< /screenshot >}}

at which point, select the _Stream Type_ of **Raw Reference**and then press **OK**.
At this we return to the **Add Processor** selection window to see that the _Raw Reference_ stream type has been added.

{{< screenshot "HOWTOs/v6/UI-CreateReferenceFeed-62.png" >}}pipeline Processors - pipeline criteria set{{< /screenshot >}}

Note the Processor has been added but it is in a **disabled** state.
We **enable** both pipeline processor and the processor filter

{{< screenshot "HOWTOs/v6/UI-CreateReferenceFeed-63.png" >}}pipeline Processors - Enable{{< /screenshot >}}

Note - if this is the first time you have set up pipeline processing on your Stroom instance you may need to check that the **Stream Processor** job is enabled on your Stroom instance.
To do this go to the Stroom main menu and select _Monitoring>Jobs>_
Check the status of the Stream Processor job and enable if required.
If you need to enable the job also ensure you enable the job on the individual nodes as well (go to the bottom window pane and select the enable box on the far right)

{{< screenshot "HOWTOs/v6/UI-CreateReferenceFeed-64.png" >}}pipeline Processors - Enable node processing{{< /screenshot >}}

{{< screenshot "HOWTOs/v6/UI-CreateReferenceFeed-65.png" >}}pipeline Processors - Enable{{< /screenshot >}}

Returning to the {{< stroom-tab "Pipeline.svg" "GeoHost-V1.0-REFERENCE" >}} tab, **Processors** sub-item, if everything is working on your Stroom instance you should now see that Raw Reference streams are being processed by your processor - the **Streams** count is incrementing and the **Tracker%** is incrementing (when the Tracker% is 100% then all streams you selected (Filtered for) have been processed)

{{< screenshot "HOWTOs/v6/UI-CreateReferenceFeed-66.png" >}}pipeline Processors - Enable{{< /screenshot >}}

Navigating back to the **Data** sub-item and clicking on the reference feed stream in the _Stream Table_ we see

{{< screenshot "HOWTOs/v6/UI-CreateReferenceFeed-67.png" >}}pipeline Display Data{{< /screenshot >}}

In the top pane, we see the _Streams table_ as per normal, but in the _Specific stream_ table we see that we have both a **Raw Reference** stream and its child **Reference** stream.
By clicking on and highlighting the **Reference** stream we see its content in the bottom pane.

The complete ReferenceData for this stream is

```xml
<?xml version="1.1" encoding="UTF-8"?>
<referenceData xmlns="reference-data:2" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:stroom="stroom" xmlns:evt="event-logging:3" xsi:schemaLocation="reference-data:2 file://reference-data-v2.0.xsd" version="2.0.1">
  <reference>
    <map>FQDN_TO_IP</map>
    <key>stroomnode00.strmdev00.org</key>
    <value>
      <IPAddress>192.168.2.245</IPAddress>
    </value>
  </reference>
  <reference>
    <map>IP_TO_FQDN</map>
    <key>192.168.2.245</key>
    <value>
      <HostName>stroomnode00.strmdev00.org</HostName>
    </value>
  </reference>
  <reference>
    <map>FQDN_TO_LOC</map>
    <key>stroomnode00.strmdev00.org</key>
    <value>
      <evt:Location>
        <evt:Country>GBR</evt:Country>
        <evt:Site>Bristol-S00</evt:Site>
        <evt:Building>GZero</evt:Building>
        <evt:Room>R00</evt:Room>
        <evt:TimeZone>+00:00/+01:00</evt:TimeZone>
      </evt:Location>
    </value>
  </reference>
  <reference>
    <map>FQDN_TO_IP</map>
    <key>stroomnode01.strmdev01.org</key>
    <value>
      <IPAddress>192.168.3.117</IPAddress>
    </value>
  </reference>
  <reference>
    <map>IP_TO_FQDN</map>
    <key>192.168.3.117</key>
    <value>
      <HostName>stroomnode01.strmdev01.org</HostName>
    </value>
  </reference>
  <reference>
    <map>FQDN_TO_LOC</map>
    <key>stroomnode01.strmdev01.org</key>
    <value>
      <evt:Location>
        <evt:Country>AUS</evt:Country>
        <evt:Site>Sydney-S04</evt:Site>
        <evt:Building>R6</evt:Building>
        <evt:Room>5-134</evt:Room>
        <evt:TimeZone>+10:00/+11:00</evt:TimeZone>
      </evt:Location>
    </value>
  </reference>
  <reference>
    <map>FQDN_TO_IP</map>
    <key>host01.company4.org</key>
    <value>
      <IPAddress>192.168.4.220</IPAddress>
    </value>
  </reference>
  <reference>
    <map>IP_TO_FQDN</map>
    <key>192.168.4.220</key>
    <value>
      <HostName>host01.company4.org</HostName>
    </value>
  </reference>
  <reference>
    <map>FQDN_TO_LOC</map>
    <key>host01.company4.org</key>
    <value>
      <evt:Location>
        <evt:Country>USA</evt:Country>
        <evt:Site>LosAngeles-S19</evt:Site>
        <evt:Building>ILM</evt:Building>
        <evt:Room>C5-54-2</evt:Room>
        <evt:TimeZone>-08:00/-07:00</evt:TimeZone>
      </evt:Location>
    </value>
  </reference>
</referenceData>
<reference>
    <map>FQDN_TO_IP</map>
    <key>host32.strmdev01.org</key>
    <value>
      <IPAddress>192.168.8.151</IPAddress>
    </value>
  </reference>
  <reference>
    <map>IP_TO_FQDN</map>
    <key>192.168.8.151</key>
    <value>
      <HostName>host32.strmdev01.org</HostName>
    </value>
  </reference>
  <reference>
    <map>FQDN_TO_LOC</map>
    <key>host32.strmdev01.org</key>
    <value>
      <evt:Location>
        <evt:Country>AUS</evt:Country>
        <evt:Site>Sydney-S02</evt:Site>
        <evt:Building>RC45</evt:Building>
        <evt:Room>5-134</evt:Room>
        <evt:TimeZone>+10:00/+11:00</evt:TimeZone>
      </evt:Location>
    </value>
  </reference>
  <reference>
    <map>FQDN_TO_IP</map>
    <key>host14.strmdev00.org</key>
    <value>
      <IPAddress>192.168.234.9</IPAddress>
    </value>
  </reference>
  <reference>
    <map>IP_TO_FQDN</map>
    <key>192.168.234.9</key>
    <value>
      <HostName>host14.strmdev00.org</HostName>
    </value>
  </reference>
  <reference>
    <map>FQDN_TO_LOC</map>
    <key>host14.strmdev00.org</key>
    <value>
      <evt:Location>
        <evt:Country>GBR</evt:Country>
        <evt:Site>Bristol-S22</evt:Site>
        <evt:Building>CAMP2</evt:Building>
        <evt:Room>Rm67</evt:Room>
        <evt:TimeZone>+00:00/+01:00</evt:TimeZone>
      </evt:Location>
    </value>
  </reference>
</referenceData>
```
If we go back to the reference feed itself (and click on the {{< stroom-icon "refresh.svg" >}} button on the far right of the top and middle panes), we now see both the _Reference_ and _Raw Reference_ streams in the _Streams Table_ pane.

{{< screenshot "HOWTOs/v6/UI-CreateReferenceFeed-68.png" >}}reference feed - Data tab{{< /screenshot >}}

Selecting the _Reference_ stream in the _Stream Table_ will result in the _Specific stream_ pane displaying the _Raw Reference_ and its child _Reference_ stream (highlighted) and the actual ReferenceData output in the _Data_ pane at the bottom.

{{< screenshot "HOWTOs/v6/UI-CreateReferenceFeed-69.png" >}}reference feed - Select reference{{< /screenshot >}}

Selecting the _Raw Reference_ stream in the _Streams Table_ will result in the _Specific stream_ pane displaying the _Raw Reference_ and its child _Reference_ stream as before, but with the _Raw Reference_ stream highlighted and the actual Raw Reference input data displayed in the _Data_ pane at the bottom.

{{< screenshot "HOWTOs/v6/UI-CreateReferenceFeed-70.png" >}}reference feed - Select raw reference{{< /screenshot >}}

The creation of the _Raw Reference_ is now complete.

At this point you may wish to organise the resources you have created within the Explorer pane to a more appropriate location such as `Reference/GeoHost`.
Because Stroom Explorer is a flat structure you can move resources around to reorganise the content without any impact on directory paths, configurations etc.

{{< screenshot "HOWTOs/v6/UI-CreateReferenceFeed-71.png" >}}reference feed - Organise Resources{{< /screenshot >}}

Now you have created the new folder structure you can move the various GeoHost resources to this location.
Select all four resources by using the mouse right-click button while holding down the _Shift_ key.
Then right click on the highlighted group to display the action menu

{{< screenshot "HOWTOs/v6/UI-CreateReferenceFeed-72.png" >}}Organise Resources - move content{{< /screenshot >}}

Select **move** and the _Move Multiple Items_ window will display.
Navigate to the `Reference/GeoHost` folder to move the items to this destination.

{{< screenshot "HOWTOs/v6/UI-CreateReferenceFeed-73.png" >}}Organise Resources - select destination{{< /screenshot >}}

The final structure is seen below

{{< screenshot "HOWTOs/v6/UI-CreateReferenceFeed-74.png" >}}Organise Resources - finished{{< /screenshot >}}
