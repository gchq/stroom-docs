---
title: "Event Processing"
linkTitle: "Event Processing"
#weight:
date: 2021-07-09
tags:
  - processing
description: >
  This HOWTO is provided to assist users in setting up Stroom to process inbound raw event logs and transform them into the Stroom Event Logging XML Schema.
---

<!-- Created with Stroom v6.1-beta.16 -->


## Introduction

This HOWTO is provided to assist users in setting up Stroom to process inbound raw event logs and transform them into the Stroom Event Logging XML Schema.

This HOWTO will demonstrate the process by which an Event Processing pipeline for a given Event Source is developed and deployed.

The sample event source used will be based on BlueCoat Proxy logs.
An extract of BlueCoat logs were sourced from {{< external-link "log-sharing.dreamhosters.com" "http://log-sharing.dreamhosters.com" >}} (a Public Security Log Sharing Site) but modified to add sample user attribution.

Template pipelines are being used to simplify the establishment of this processing pipeline.

The sample BlueCoat Proxy log will be transformed into an intermediate simple XML key value pair structure, then into the {{< external-link "Stroom Event Logging XML Schema" "https://github.com/gchq/event-logging-schema" >}} format.

## Assumptions

The following assumptions are used in this document.
1. The user successfully deployed Stroom 
1. The following Stroom content packages have been installed:
    - Template Pipelines
    - XML Schemas


## Event Source

As mentioned, we will use BlueCoat Proxy logs as a sample event source.
Although BlueCoat logs can be customised, the default is to use the W2C Extended Log File Format (ELF).
Our sample data set looks like

{{< textfile "HOWTOs/EventFeeds/ProcessingHowTo/sampleBluecoat.log" "text" >}}Sample BlueCoat logs{{</textfile >}}

Later in this HOWTO, one will be required to upload this file.
If you save this file now, ensure the file is saved
as a text document with ANSI encoding.


## Establish the Processing Pipeline

We will create the components that make up the processing pipeline for transforming these raw logs into the Stroom Event Logging XML Schema.
They will be placed a folder appropriately named **BlueCoat** in the path **System/Event Sources/Proxy**.
See [Folder Creation]({{< relref "../General/FeedManagementHowTo.md#create-folder-for-specific-event-source" >}}) for details on creating such a folder.

There will be four components
- the Event Feed to group the BlueCoat log files
- the Text Converter to convert the BlueCoat raw logs files into simple XML
- the XSLT Translation to translate the simple XML formed by the Text Converter into the Stroom Event Logging XML form, and
- the Processing pipeline which manages how the processing is performed.

All components will have the same Name **BlueCoat-Proxy-V1.0-EVENTS**.
It should be noted that the default Stroom FeedName pattern will not accept this name.
One needs to modify the `stroom.feedNamePattern` stroom property to change the default pattern to `^[a-zA-Z0-9_-\.]{3,}$`.
See the [HOWTO on System Properties]({{< relref "../Administration/SystemProperties.md" >}}) docment to see how to make this change.


### Create the Event Feed

We first select (with a _left click_) the **System/Event Sources/Proxy/BlueCoat** folder in the `Explorer` tab then _right click_ and select:

{{< stroom-menu "New" "Feed" >}}

This will open the `New Feed` configuration window into which we enter **BlueCoat-Proxy-V1.0-EVENTS** into the `Name:` entry box

{{< screenshot "HOWTOs/UI-FeedProcessing-00.png" >}}Stroom UI Create Feed - New feed configuration window enter name{{< /screenshot >}}

and press {{< stroom-btn "Ok" >}} to see the new Event Feed tab

{{< screenshot "HOWTOs/UI-FeedProcessing-01.png" >}}Stroom UI Create Feed - New feed tab{{< /screenshot >}}

and it's corresponding reference in the `Explorer` display.

The configuration items for a Event Feed are

 * _Description_ - a description of the feed
 * _Classification_ - the classification or sensitivity of the Event Feed data
 * _Reference Feed Flag_ - to indicate if this is a `Reference Feed` or not
 * _Feed Status_ - which indicates if we accept data, reject it or silently drop it
 * _Stream Type_ - to indicate if the `Feed` contains raw log data or reference data
 * _Data Encoding_ - the character encoding of the data being sent to the `Feed`
 * _Context Encoding_ - the character encoding of context data associated with this `Feed`
 * _Retention Period_ - the amount of time to retain the Event data

In our example, we will set the above to

 * _Description_ - *BlueCoat Proxy log data sent in W2C Extended Log File Format (ELFF)*
 * _Classification_ - We will leave this blank
 * _Reference Feed Flag_ - We leave the check-box unchecked as this is not a *Reference Feed*
 * _Feed Status_ - We set to *Receive*
 * _Stream Type_ - We set to *Raw Events* as we will be sending batches (streams) of raw event logs
 * _Data Encoding_ - We leave at the default of *UTF-8* as this is the proposed character encoding
 * _Context Encoding_ - We leave at the default of *UTF-8* as there are no Context Events for this Feed
 * _Retention Period_ - We leave at *Forever* was we do not want to delete any collected BlueCoat event data.

{{< screenshot "HOWTOs/UI-FeedProcessing-02.png" >}}Stroom UI Create Feed - New feed tab configuration{{< /screenshot >}}

One should note that the `Feed` tab {{< stroom-tab "Feed.svg" "BlueCoat-Proxy-V1.0-EVENTS" "active" "unsaved" >}} has been marked as having unsaved changes.
This is indicated by the asterisk character `*` between the _Feed_ icon {{< stroom-icon "document/Feed.svg">}} and the name of the feed **BlueCoat-Proxy-V1.0-EVENTS**.

We can save the changes to our feed by pressing the _Save_ icon {{< stroom-icon "save.svg" >}} in the top left of the **BlueCoat-Proxy-V1.0-EVENTS** tab.
At this point one should notice two things, the first is that the asterisk
has disappeared from the `Feed` tab and the the second is that the _Save_ icon {{< stroom-icon "save.svg" "Save" "disabled">}} is now disabled.

{{< screenshot "HOWTOs/UI-FeedProcessing-03.png" >}}Stroom UI Create Feed - New feed tab saved{{< /screenshot >}}


### Create the Text Converter

We now create the Text Converter for this `Feed` in a similar fashion to the `Event Feed`.
We first select (with a _left click_) the **System/Event Sources/Proxy/BlueCoat** folder in the `Explorer` tab then _right click_ and select 

{{< stroom-menu "New" "Text Converter" >}}

Enter **BlueCoat-Proxy-V1.0-EVENTS** into the `Name:` entry box and press the {{< stroom-btn "Ok" >}} which results in the creation of the Text Converter tab

{{< screenshot "HOWTOs/UI-FeedProcessing-04.png" >}}Stroom UI Create Feed - New TextConverter tab{{< /screenshot >}}

and it's corresponding reference in the `Explorer` display.

We set the configuration for this `Text Converter` to be

 * Description - *Simple XML transform for BlueCoat Proxy log data sent in W2C Extended Log File Format (ELFF)*
 * Converter Type - We set to *Data Splitter* was we will be using the Stroom Data Splitter facility to convert the raw log data into simple XML.
 
Again, press the _Save_ icon {{< stroom-icon "save.svg" >}} to save the configuration items.


### Create the XSLT Translation

We now create the XSLT translation for this `Feed` in a similar fashion to the `Event Feed` or `Text Converter`.
We first select (with a _left click_) the **System/Event Sources/Proxy/BlueCoat** folder in the `Explorer` tab then _right click_ and select:

{{< stroom-menu "New" "XSL Translation" >}}

Enter **BlueCoat-Proxy-V1.0-EVENTS** into the `Name:` entry box and press the {{< stroom-btn "Ok" >}} which results in the creation of the XSLT Translation tab

{{< screenshot "HOWTOs/UI-FeedProcessing-05.png" >}}Stroom UI Create Feed - New Translation tab{{< /screenshot >}}

and it's corresponding reference in the `Explorer` display.

We set the configuration for this `XSLT Translation` to be

 * Description - *Transform simple XML of BlueCoat Proxy log data into Stroom Event Logging XML form*

Again, press the _Save_ icon {{< stroom-icon "save.svg" >}} to save the configuration items.


### Create the Pipeline

We now create the Pipeline for this `Feed` in a similar fashion to the `Event Feed`, `Text Converter` or `XSLT Translation`.
We first select (with a _left click_) the **System/Event Sources/Proxy/BlueCoat** folder in the `Explorer` tab then _right click_ and select:

{{< stroom-menu "New" "Pipeline" >}}

Enter **BlueCoat-Proxy-V1.0-EVENTS** into the `Name:` entry box and press the {{< stroom-btn "Ok" >}} which results in the creation of the Pipeline tab

{{< screenshot "HOWTOs/UI-FeedProcessing-06.png" >}}Stroom UI Create Feed - New Pipeline tab{{< /screenshot >}}

and it's corresponding reference in the `Explorer` display.

We set the configuration for this `Pipeline` to be

 * Description - *Processing of XML of BlueCoat Proxy log data into Stroom Event Logging XML*
 * Type - We leave as *Event Data* as this is an *Event Data* pipeline


### Configure Pipeline Structure

We now need to configure the *Structure* of this `Pipeline`.

We do this by selecting the `Structure` hyper-link of the **BlueCoat-Proxy-V1.0-EVENTS* `Pipeline` tab.

At this we see the `Pipeline Structure` configuration tab

{{< screenshot "HOWTOs/UI-FeedProcessing-07.png" >}}Stroom UI Create Feed - Pipeline Structure tab{{< /screenshot >}}

As noted in the Assumptions at the start, we have loaded the **Template Pipeline** content pack, so that we can _Inherit_ a pipeline structure from this content pack and configure it to support this specific feed.

We find a template by selecting the **Inherit From:** _None_ {{< stroom-icon "ellipses-horizontal.svg" "Menu selection">}} entry box to reveal a **Choose Item** configuration item window.

{{< screenshot "HOWTOs/UI-FeedProcessing-08.png" >}}Stroom UI Create Feed - Pipeline Structure tab - Inherit{{< /screenshot >}}

Select the **Template Pipelines** folder by pressing the {{< stroom-icon "arrow-right.svg" "Open tree branch">}} icon to the left of the folder to reveal the choice of available templates.

{{< screenshot "HOWTOs/UI-FeedProcessing-09.png" >}}Stroom UI Create Feed - Pipeline Structure tab - Templates{{< /screenshot >}}

For our BlueCoat feed we will select the `Event Data (Text)` template.
This is done by moving the cursor to the relevant line and select via a _left click_

{{< screenshot "HOWTOs/UI-FeedProcessing-10.png" >}}Stroom UI Create Feed - Pipeline Structure tab - Template Selection{{< /screenshot >}}

then pressing {{< stroom-btn "Ok" >}} to see the inherited pipeline structure

{{< screenshot "HOWTOs/UI-FeedProcessing-11.png" >}}Stroom UI Create Feed - Pipeline Structure tab - Template Selected{{< /screenshot >}}


### Configure Pipeline Elements

For the purpose of this HOWTO, we are only interested in two of the eleven (11) elements in this pipeline

 * the Text Converter labeled *dsParser*
 * the XSLT Translation labeled *translationFilter*

We need to assign our BlueCoat-Proxy-V1.0-EVENTS Text Converter and XSLT Translation to these elements respectively.


#### Text Converter Configuration

We do this by first selecting (_left click_) the *dsParser* element at which we see the _Property_ sub-window displayed

{{< screenshot "HOWTOs/UI-FeedProcessing-12.png" >}}Stroom UI Create Feed - Pipeline Structure tab - dsParser{{< /screenshot >}}

We then select (_left click_) the _textConverter_ **Property Name**

{{< screenshot "HOWTOs/UI-FeedProcessing-13.png" >}}Stroom UI Create Feed - Pipeline Structure tab - dsParser selected Property{{< /screenshot >}}

then press the `Edit Property` button {{< stroom-icon "edit.svg" >}}.
At this, the `Edit Property` configuration window is displayed.

{{< screenshot "HOWTOs/UI-FeedProcessing-14.png" >}}Stroom UI Create Feed - Pipeline Structure tab - dsParser Edit Property{{< /screenshot >}}

We select the **Value:** _None_ {{< stroom-icon "ellipses-horizontal.svg" "Menu selection" >}} entry box labeled to reveal a **Choose Item** configuration item window.

{{< screenshot "HOWTOs/UI-FeedProcessing-15.png" >}}Stroom UI Create Feed - Pipeline Structure tab - dsParser Edit Property choose item{{< /screenshot >}}

We traverse the folder structure until we can select the **BlueCoat-Proxy-V1.0-EVENTS** `Text Converter` as per

{{< screenshot "HOWTOs/UI-FeedProcessing-16.png" >}}Stroom UI Create Feed - Pipeline Structure tab - dsParser Edit Property chosen item{{< /screenshot >}}

and then press the {{< stroom-btn "Ok" >}} to see that the Property **Value:** has been selected.

{{< screenshot "HOWTOs/UI-FeedProcessing-17.png" >}}Stroom UI Create Feed - Pipeline Structure tab - dsParser set Property chosen item{{< /screenshot >}}

and pressing the {{< stroom-btn "Ok" >}} button of the `Edit Property` configuration window results in the pipelines `dsParser` property being set. 

{{< screenshot "HOWTOs/UI-FeedProcessing-18.png" >}}Stroom UI Create Feed - Pipeline Structure tab - dsParser set Property{{< /screenshot >}}


#### XSLT Translation Configuration

We do this by first selecting (_left click_) the *translationFilter* element at which we see the _Property_ sub-window displayed

{{< screenshot "HOWTOs/UI-FeedProcessing-19.png" >}}Stroom UI Create Feed - Pipeline Structure tab - translationFilter{{< /screenshot >}}

We then select (_left click_) the _xslt_ **Property Name**

{{< screenshot "HOWTOs/UI-FeedProcessing-20.png" >}}Stroom UI Create Feed - Pipeline Structure tab - xslt selected Property{{< /screenshot >}}

and following the same steps as for the Text Converter property selection, we assign the **BlueCoat-Proxy-V1.0-EVENTS** `XSLT Translation` to the `xslt` property.

{{< screenshot "HOWTOs/UI-FeedProcessing-21.png" >}}Stroom UI Create Feed - Pipeline Structure tab - xslt selected Property{{< /screenshot >}}

At this point, we save these changes by pressing the _Save_ icon {{< stroom-icon "save.svg" >}}.


## Authoring the Translation

We are now ready to author the translation.
Close all tabs except for the **Welcome** and **BlueCoat-Proxy-V1.0-EVENTS** `Feed` tabs.

On the **BlueCoat-Proxy-V1.0-EVENTS** `Feed` tab, select the **Data** hyper-link to be presented with the **Data** pane of our tab.

{{< screenshot "HOWTOs/UI-FeedProcessing-22.png" >}}Stroom UI Create Feed - Translation - Data Pane{{< /screenshot >}}

Although we can post our test data set to this feed, we will manually upload it via the **Data** pane.
To do this we press the Upload button {{< stroom-icon "upload.svg" >}} in the top **Data** pane to display the `Upload` configuration window

{{< screenshot "HOWTOs/UI-FeedProcessing-23.png" >}}Stroom UI Create Feed - Translation - Data Pane Upload{{< /screenshot >}}

In a _Production_ situation, where we would post log files to Stroom, we would include certain HTTP Header variables that, as we shall see, will be used
as part of the translation.
These header variables typically provide situational awareness of the source system sending the events.

For our purposes we set the following HTTP Header variables

```text
Environment:Development
LogFileName:sampleBluecoat.log
MyHost:"somenode.strmdev00.org"
MyIPaddress:"192.168.2.220 192.168.122.1"
MyMeta:"FQDN:somenode.strmdev00.org\nipaddress:192.168.2.220\nipaddress_eth0:192.168.2.220\nipaddress_lo:127.0.0.1\nipaddress_virbr0:192.168.122.1\n"
MyNameServer:"gateway.strmdev00.org."
MyTZ:+1000
Shar256:056f0d196ffb4bc6c5f3898962f1708886bb48e2f20a81fb93f561f4d16cb2aa
System:Site http://log-sharing.dreamhosters.com/ Bluecoat Logs
Version:V1.0
```

These are set by entering them into the **Meta Data:** entry box.

{{< screenshot "HOWTOs/UI-FeedProcessing-24b.png" >}}Stroom UI Create Feed - Translation - Data Pane Upload Metadata{{< /screenshot >}}

Having done this we select a **Stream Type:** of `Raw Events`

We leave the **Effective:** entry box empty as this stream of raw event logs does not have an `Effective Date` (only Reference Feeds set this).

And we choose our file `sampleBluecoat.log`, by clicking on the `Browse` button in the **File:** entry box, which brings up the brower's standard file upload selection window.
Having selected our file, we see

{{< screenshot "HOWTOs/UI-FeedProcessing-24.png" >}}Stroom UI Create Feed - Translation - Data Pane Upload Complete{{< /screenshot >}}

On pressing {{< stroom-btn "Ok" >}} and `Alert` pop-up window is presented indicating the file was uploaded

{{< screenshot "HOWTOs/UI-FeedProcessing-25.png" >}}Stroom UI Create Feed - Translation - Data Pane Upload Complete Verify{{< /screenshot >}}

Again press {{< stroom-btn "Close" >}} to show that the data has been uploaded as a Stream into the **BlueCoat-Proxy-V1.0-EVENTS** Event Feed.

{{< screenshot "HOWTOs/UI-FeedProcessing-26.png" >}}Stroom UI Create Feed - Translation - Data Pane Show Batch{{< /screenshot >}}

The top pane holds a table of the latest streams that pertain to the feed.
We see the one item which is the stream we uploaded.
If we select it, we see that a stream summary is also displayed in the centre pane (which shows details of the _specific_ selected feed and associated streams.
We also see that the bottom pane displays the data associated with the selected item.
In this case, the first lines of content from the BlueCoat sample log file.

{{< screenshot "HOWTOs/UI-FeedProcessing-27.png" >}}Stroom UI Create Feed - Translation - Data Pane Show Data{{< /screenshot >}}

If we were to select the **Meta** hyper-link of the lower pane, one would see the metadata Stroom records for this Stream of data.

{{< screenshot "HOWTOs/UI-FeedProcessing-28.png" >}}Stroom UI Create Feed - Translation - MetaData Pane Show Data{{< /screenshot >}}

You should see all the HTTP variables we set as part of the Upload step as well as some that Stroom has automatically set.

We now switch back to the **Data** hyper-link before we start to develop the actual translation.


### Stepping the Pipeline

We will now author the two translation components of the pipeline, the data splitter that will transform our lines of BlueCoat data into a simple xml format and then the XSLT translation that will take this simple xml format and translate it into appropriate Stroom Event Logging XML form.

We start by ensuring our `Raw Events` Data stream is selected and we press the `Enter Stepping Mode` {{< stroom-icon "stepping.svg" >}} button on the lower right hand side of the bottom `Stream Data` pane.

You will be prompted to select a pipeline to step with.
Choose the `BlueCoat-Proxy-V1.0-EVENTS` pipeline

{{< screenshot "HOWTOs/UI-FeedProcessing-29.png" >}}Stroom UI Create Feed - Translation - Stepping Choose Pipeline{{< /screenshot >}}

then press {{< stroom-btn "Ok" >}}.


### Stepping the Pipeline - Source

You will be presented with the `Source` element of the pipeline that shows our selected stream's raw data.

{{< screenshot "HOWTOs/UI-FeedProcessing-30.png" >}}Stroom UI Create Feed - Translation - Stepping Source Element{{< /screenshot >}}

We see two panes here.

The top pane displays the Pipeline structure with `Source` selected (we could refer to this as the _stepping pane_) and it also displays a _step indicator_ (three colon separated numbers enclosed in square brackets initially the numbers are dashes i.e. `[-:-:-]` as we have yet to step) and a set of green _Stepping Actions_.
The step indicator and Stepping Actions allows one the _step through_ a log file, selecting data event by event (an event is typically a line, but some events can be multi-line).

The bottom pane displays the first page (up to 100 lines) of data along with a set of blue _Data Selection Actions_.
The Data Selection Actions are used to step through the source data 100 lines at a time.
When multiple source log files have been aggregated into a single stream, two _Data Selection Actions_ control buttons will be offered.
The right hand one will allow a user to step though the source data as before, but the left hand set of control buttons allows one to step between files from the aggregated event log files.


### Stepping the Pipeline - dsParser

We now select the `dsParser` pipeline element that results in the window below

{{< screenshot "HOWTOs/UI-FeedProcessing-31.png" >}}Stroom UI Create Feed - Translation - Stepping dsParser Element{{< /screenshot >}}

This window is made up of four panes.

The top pane remains the same - a display of the pipeline structure and the _step indicator_ and green _Stepping Actions_.

The next pane down is the editing pane for the Text Converter.
This pane is used to edit the text converter that converts our _line based_ BlueCoat Proxy logs into a XML format.
We make use of the Stroom Data Splitter facility to perform this transformation.
See [here]({{< relref "../../user-guide/data-splitter" >}}) for complete details on the data splitter.

The lower two panes are the _input_ and _output_ displays for the text converter.

The authoring of this data splitter translation is outside the scope of this HOWTO.
It is recommended that one reads up on the [Data Splitter]({{< relref "../../user-guide/data-splitter" >}}) and review the various samples found in the Stroom Context packs published, or the Pull Requests of {{< external-link "github.com/gchq/stroom-content" "https://github.com/gchq/stroom-content" >}}.

For the purpose of this HOWTO, the Datasplitter appears below.
The author believes the comments should support the understanding of the transformation.

{{< textfile "HOWTOs/EventFeeds/ProcessingHowTo/BlueCoat.ds" "xml" >}}BlueCoat dataspliter{{</textfile >}}

It should be entered into the Text Converter's editing pane as per

{{< screenshot "HOWTOs/UI-FeedProcessing-32.png" >}}Stroom UI Create Feed - Translation - Stepping dsParser textConverter code{{< /screenshot >}}

As mentioned earlier, to _step_ the translation, one uses the green  _Stepping Actions_.

The actions are

   * {{< stroom-icon name="fast-backward.svg" title="Step First" colour="green" >}} - progress the transformation to the first line of the translation input
   * {{< stroom-icon name="step-backward.svg" title="Step back" colour="green" >}} - progress the transformation one step backward
   * {{< stroom-icon name="step-forward.svg" title="Step forward" colour="green" >}} - progress the transformation one step forward
   * {{< stroom-icon name="fast-forward.svg" title="Step last" colour="green" >}} - progress the transformation to the end of the translation input
   * {{< stroom-icon name="refresh.svg" title="Refresh step" colour="green" >}} - refresh the transformation based on the current translation input

So, if one was to press the {{< stroom-icon name="step-forward.svg" title="Step forward" colour="green" >}} _stepping action_ we would be presented with

{{< screenshot "HOWTOs/UI-FeedProcessing-33.png" >}}Stroom UI Create Feed - Translation - Stepping dsParser textConverter 1{{< /screenshot >}}

We see that the _input_ pane has the first line of input from our sample file and the _output_ pane has an XML **record** structure where we have defined a **data** element with the _name_ attribute of _bc_software_ and it's _value_ attribute of _SGOS 3.2.4.28_.
The definition of the **record** structure can be found in the **System/XML Schemas/records** folder.

This is the result of the code in our editor

```xml
<!-- Match the software comment line and save it in _bc_software -->
<regex id="software" pattern="^#Software: (.+) ?\n*">
  <data name="_bc_software" value="$1" />
</regex>
```

If one presses the {{< stroom-icon name="step-forward.svg" title="Step forward" colour="green" >}} _stepping action_ again, we see that we have moved to the second line of the input file with the resultant output of a **data** element with the _name_ attribute of _bc_version_ and it's _value_ attribute of _1.0_.

{{< screenshot "HOWTOs/UI-FeedProcessing-34.png" >}}Stroom UI Create Feed - Translation - Stepping dsParser textConverter 2{{< /screenshot >}}

Stepping forward once more causes the translation to ignore the Date comment line, define a Data Splitter $headings variable from the Fields comment line and transform the first line of actual event data.


{{< screenshot "HOWTOs/UI-FeedProcessing-35.png" >}}Stroom UI Create Feed - Translation - Stepping dsParser textConverter 3{{< /screenshot >}}

We see that a `<record>` element has been formed with multiple key value pair `<data>` elements where the _name_ attribute is the key and the _value_ attribute the value.
You will note that the keys have been taken from the Fields comment line which where placed in the $headings variable.

You should also take note that the _stepping indicator_ has been incrementing the last number, so at this point it is displaying `[1:1:3]`.

The general form of this _indicator_ is 

```text
'[' streamId ':' subStreamId ':' recordNo ']'
```

where

   * **streamId** - is the stream ID and won't change when stepping through the selected stream,
   * **subStreamId** - is the sub stream ID.
     When Stroom aggregates multiple event sources for a feed, it aggregates multiple input files and this is, in effect, the file number.
   * **recordNo** - is the record number within the sub stream.

One can double click on either the **subStreamId** or **recordNo** entry and enter a new value.
This allows you to _jump_ around a stream rather than just relying on first, previous, next and last movements.

Hovering the mouse over the _stepping indicator_ will change the cursor to a `hand pointer`.
Selecting (by a left click) the `recordNo` will allow you to edit it's value (and the other values for that matter).
You will see the display change from

{{< screenshot "HOWTOs/UI-FeedProcessing-36.png" >}}Stroom UI Create Feed - Translation - Stepping Indicator 1{{< /screenshot >}}
to
{{< screenshot "HOWTOs/UI-FeedProcessing-37.png" >}}Stroom UI Create Feed - Translation - Stepping Indicator 2{{< /screenshot >}}

If we change the record number from __3__ to __12__ then either press Enter or press the {{< stroom-icon name="refresh.svg" title="Refresh" colour="green" >}} action we see

{{< screenshot "HOWTOs/UI-FeedProcessing-38.png" >}}Stroom UI Create Feed - Translation - Stepping Indicator 3{{< /screenshot >}}

and note that a new record has been processed in the _input_ and _output_ panes.
Further, if one steps back to the `Source` element of the pipeline to view the raw source file, we see that the highlighted __current__ line is the 12th line of processed data.
It is the 10th actual bluecoat event, but remember the #Software, #Version lines are considered as processed data (2+10 = 12).
Also noted that the #Date and #Fields lines are not considered processed data, and hence do not contribute to the **recordNo** value.

{{< screenshot "HOWTOs/UI-FeedProcessing-39.png" >}}Stroom UI Create Feed - Translation - Stepping Indicator 4{{< /screenshot >}}

If we select the `dsParser` pipeline element then press the {{< stroom-icon name="fast-forward.svg" title="Step last" colour="green" >}} action we see the `recordNo` jump to 31 which is the last processed line of our sample log file.

{{< screenshot "HOWTOs/UI-FeedProcessing-40.png" >}}Stroom UI Create Feed - Translation - Stepping Indicator 5{{< /screenshot >}}


### Stepping the Pipeline - translationFilter

We now select the `translationFilter` pipeline element that results in 

{{< screenshot "HOWTOs/UI-FeedProcessing-41.png" >}}Stroom UI Create Feed - Translation - Stepping translationFilter Element{{< /screenshot >}}

As for the `dsParser`, this window is made up of four panes.

The top pane remains the same - a display of the pipeline structure and the _step indicator_ and green _Stepping Actions_.

The next pane down is the editing pane for the Translation Filter.
This pane is used to edit an _xslt_ translation that converts our simple key value pair `<records>` XML structure into another XML form.

The lower two panes are the _input_ and _output_ displays for the xslt translation.
You will note that the _input_ and _output_ displays are identical for a null xslt translation is effectively a direct copy.

In this HOWTO we will transform the `<records>` XML structure into the _GCHQ Stroom Event Logging XML Schema_ form which is documented {{< external-link "here" "https://github.com/gchq/event-logging-schema" >}}.

The authoring of this xslt translation is outside the scope of this HOWTO, as is the use of the Stroom XML Schema.
It is recommended that one reads up on [XSLT Conversion]({{< relref "../../user-guide/pipelines/xslt" >}}) and the {{< external-link "Stroom Event Logging XML Schema" "https://github.com/gchq/event-logging-schema" >}} and review the various samples found in the Stroom Context packs published, or the Pull Requests of {{< external-link "https://github.com/gchq/stroom-content" >}}.

We will build the translation in steps.
We enter an initial portion of our xslt transformation that just consumes the `Software` and `Version` key values and converts the `date` and `time` values (which are in UTC) into the `EventTime/TimeCreated` element.
This code segment is

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

  <!-- Bluecoat Proxy logs in W2C Extended Log File Format (ELF) -->

  <!-- Ingest the record key value pair elements -->
  <xsl:template match="records">
    <Events xsi:schemaLocation="event-logging:3 file://event-logging-v3.2.4.xsd" Version="3.2.4">
      <xsl:apply-templates />
    </Events>
  </xsl:template>

  <!-- Main record template for single event -->
  <xsl:template match="record">
    <xsl:choose>

      <!-- Store the Software and Version information of the Bluecoat log file for use 
      in the Event Source elements which are processed later -->
      <xsl:when test="data[@name='_bc_software']">
        <xsl:value-of select="stroom:put('_bc_software', data[@name='_bc_software']/@value)" />
      </xsl:when>
      <xsl:when test="data[@name='_bc_version']">
        <xsl:value-of select="stroom:put('_bc_version', data[@name='_bc_version']/@value)" />
      </xsl:when>

      <!-- Process the event logs -->
      <xsl:otherwise>
        <Event>
          <xsl:call-template name="event_time" />
        </Event>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Time -->
  <xsl:template name="event_time">
    <EventTime>
      <TimeCreated>
        <xsl:value-of select="concat(data[@name = 'date']/@value,'T',data[@name='time']/@value,'.000Z')" />
      </TimeCreated>
    </EventTime>
  </xsl:template>
</xsl:stylesheet>
```

After entering this translation and pressing the {{< stroom-icon name="refresh.svg" title="Refresh" colour="green" >}} action shows the display

{{< screenshot "HOWTOs/UI-FeedProcessing-42.png" >}}Stroom UI Create Feed - Translation - Stepping XSLT Translation 1{{< /screenshot >}}

Note that this is the 31st record, so if we were to jump to the first record using the {{< stroom-icon name="fast-backward.svg" title="Step first" colour="green" >}} action, we see that the _input_ and _output_ change appropriately.

{{< screenshot "HOWTOs/UI-FeedProcessing-43.png" >}}Stroom UI Create Feed - Translation - Stepping XSLT Translation 2{{< /screenshot >}}

You will note that there is no `Event` element in the _output_ pane as the _record_ template in our xslt translation above is only storing the input's key value (_bc_software's value).

Further note that the **BlueCoat_Proxy-V1.0-EVENTS** tab {{< stroom-tab "../stepping.svg" "BlueCoat_Proxy-V1.0-EVENTS" "active" "unsaved" >}} has a _star_ in front of it and also the _Save_ icon {{< stroom-icon "save.svg" >}} is highlighted.
This indicates that a component of the pipeline needs to be saved.
In this case, the XSLT translation.

By pressing the _Save_ icon, you will save the XSLT translation as it currently stands and both the _star_ will be removed from the tab {{< stroom-tab "../stepping.svg" "BlueCoat_Proxy-V1.0-EVENTS" "active" "saved" >}}and the _Save_ icon {{< stroom-icon "save.svg" "Save" "disabled" >}}will no longer be highlighted.

{{< screenshot "HOWTOs/UI-FeedProcessing-45.png" >}}Stroom UI Create Feed - Translation - Stepping XSLT Translation 4{{< /screenshot >}}

We next extend out translation by authoring a **event_source** template to form an appropriate Stroom Event Logging `EventSource` element structure.
Thus our translation now is

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

  <!-- Bluecoat Proxy logs in W2C Extended Log File Format (ELF) -->

  <!-- Ingest the record key value pair elements -->
  <xsl:template match="records">
    <Events xsi:schemaLocation="event-logging:3 file://event-logging-v3.2.4.xsd" Version="3.2.4">
      <xsl:apply-templates />
    </Events>
  </xsl:template>

  <!-- Main record template for single event -->
  <xsl:template match="record">
    <xsl:choose>

      <!-- Store the Software and Version information of the Bluecoat log file for use in
      the Event Source elements which are processed later -->
      <xsl:when test="data[@name='_bc_software']">
        <xsl:value-of select="stroom:put('_bc_software', data[@name='_bc_software']/@value)" />
      </xsl:when>
      <xsl:when test="data[@name='_bc_version']">
        <xsl:value-of select="stroom:put('_bc_version', data[@name='_bc_version']/@value)" />
      </xsl:when>

      <!-- Process the event logs -->
      <xsl:otherwise>
        <Event>
          <xsl:call-template name="event_time" />
          <xsl:call-template name="event_source" />
        </Event>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Time -->
  <xsl:template name="event_time">
    <EventTime>
      <TimeCreated>
        <xsl:value-of select="concat(data[@name = 'date']/@value,'T',data[@name='time']/@value,'.000Z')" />
      </TimeCreated>
    </EventTime>
  </xsl:template>

  <!-- Template for event source-->
  <xsl:template name="event_source">

    <!--
    We extract some situational awareness information that the posting script includes when posting the event data 
    -->
    <xsl:variable name="_mymeta" select="translate(stroom:meta('MyMeta'),'&quot;', '')" />

    <!-- Form the EventSource node -->
    <EventSource>
      <System>
        <Name>
          <xsl:value-of select="stroom:meta('System')" />
        </Name>
        <Environment>
          <xsl:value-of select="stroom:meta('Environment')" />
        </Environment>
      </System>
      <Generator>
        <xsl:variable name="gen">
          <xsl:if test="stroom:get('_bc_software')">
            <xsl:value-of select="concat(' Software: ', stroom:get('_bc_software'))" />
          </xsl:if>
          <xsl:if test="stroom:get('_bc_version')">
            <xsl:value-of select="concat(' Version: ', stroom:get('_bc_version'))" />
          </xsl:if>
        </xsl:variable>
        <xsl:value-of select="concat('Bluecoat', $gen)" />
      </Generator>
      <xsl:if test="data[@name='s-computername'] or data[@name='s-ip']">
        <Device>
          <xsl:if test="data[@name='s-computername']">
            <Name>
              <xsl:value-of select="data[@name='s-computername']/@value" />
            </Name>
          </xsl:if>
          <xsl:if test="data[@name='s-ip']">
            <IPAddress>
              <xsl:value-of select=" data[@name='s-ip']/@value" />
            </IPAddress>
          </xsl:if>
          <xsl:if test="data[@name='s-sitename']">
            <Data Name="ServiceType" Value="{data[@name='s-sitename']/@value}" />
          </xsl:if>
        </Device>
      </xsl:if>

      <!-- -->
      <Client>
        <xsl:if test="data[@name='c-ip']/@value != '-'">
          <IPAddress>
            <xsl:value-of select="data[@name='c-ip']/@value" />
          </IPAddress>
        </xsl:if>

        <!-- Remote Port Number -->
        <xsl:if test="data[@name='c-port']/@value !='-'">
          <Port>
            <xsl:value-of select="data[@name='c-port']/@value" />
          </Port>
        </xsl:if>
      </Client>

      <!-- -->
      <Server>
        <HostName>
          <xsl:value-of select="data[@name='cs-host']/@value" />
        </HostName>
      </Server>

      <!-- -->
      <xsl:variable name="user">
        <xsl:value-of select="data[@name='cs-user']/@value" />
        <xsl:value-of select="data[@name='cs-username']/@value" />
        <xsl:value-of select="data[@name='cs-userdn']/@value" />
      </xsl:variable>
      <xsl:if test="$user !='-'">
        <User>
          <Id>
            <xsl:value-of select="$user" />
          </Id>
        </User>
      </xsl:if>
      <Data Name="MyMeta">
        <xsl:attribute name="Value" select="$_mymeta" />
      </Data>
    </EventSource>
  </xsl:template>
</xsl:stylesheet>
```

Stepping to the 3 record (the first real data record in our sample log) will reveal that our _output_ pane has gained an `EventSource` element.

{{< screenshot "HOWTOs/UI-FeedProcessing-46.png" >}}Stroom UI Create Feed - Translation - Stepping XSLT Translation 5{{< /screenshot >}}

Note also, that our _Save_ icon {{< stroom-icon "save.svg" >}} is also highlighted, so we should at some point save the extensions to our translation.

The complete translation now follows.

{{< textfile "HOWTOs/EventFeeds/ProcessingHowTo/BlueCoat.xslt" "xml" >}}BlueCoat XSLT Translation{{</textfile >}}

Refreshing the current event will show the _output_ pane contains

```xml
<?xml version="1.1" encoding="UTF-8"?>
<Events 
    xmlns="event-logging:3" 
    xmlns:stroom="stroom" 
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
    xmlns:xs="http://www.w3.org/2001/XMLSchema" 
    xsi:schemaLocation="event-logging:3 file://event-logging-v3.2.4.xsd" 
    Version="3.2.4">
  <Event>
    <EventTime>
      <TimeCreated>2005-05-04T17:16:12.000Z</TimeCreated>
    </EventTime>
    <EventSource>
      <System>
        <Name>Site http://log-sharing.dreamhosters.com/ Bluecoat Logs</Name>
        <Environment>Development</Environment>
      </System>
      <Generator>Bluecoat Software: SGOS 3.2.4.28 Version: 1.0</Generator>
      <Device>
        <IPAddress>192.16.170.42</IPAddress>
        <Data Name="ServiceType" Value="SG-HTTP-Service" />
      </Device>
      <Client>
        <IPAddress>45.110.2.82</IPAddress>
      </Client>
      <Server>
        <HostName>www.inmobus.com</HostName>
      </Server>
      <User>
        <Id>george</Id>
      </User>
      <Data Name="MyMeta" Value="FQDN:somenode.strmdev00.org\nipaddress:192.168.2.220\nipaddress_eth0:192.168.2.220\nipaddress_lo:127.0.0.1\nipaddress_virbr0:192.168.122.1\n" />
    </EventSource>
    <EventDetail>
      <TypeId>Bluecoat-GET-http</TypeId>
      <Description>Receipt of information from a Resource via Proxy</Description>
      <Receive>
        <Source>
          <Device>
            <IPAddress>45.110.2.82</IPAddress>
          </Device>
        </Source>
        <Destination>
          <Device>
            <HostName>www.inmobus.com</HostName>
          </Device>
        </Destination>
        <Payload>
          <Resource>
            <URL>http://www.inmobus.com/wcm/assets/images/imagefileicon.gif</URL>
            <HTTPMethod>GET</HTTPMethod>
            <UserAgent>Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1; SV1; .NET CLR 1.1.4322)</UserAgent>
            <InboundSize>941</InboundSize>
            <OutboundSize>729</OutboundSize>
            <RequestTime>1</RequestTime>
            <ResponseCode>200</ResponseCode>
            <MimeType>image/gif</MimeType>
            <Data Name="s-action" Value="TCP_HIT" />
            <Data Name="cs-uri-scheme" Value="http" />
            <Data Name="s-hierarchy" Value="DIRECT" />
            <Data Name="sc-filter-result" Value="PROXIED" />
            <Data Name="x-icap-error-code" Value="none" />
          </Resource>
        </Payload>
      </Receive>
    </EventDetail>
  </Event>
</Events>
```

for the given input

```xml
<?xml version="1.1" encoding="UTF-8"?>
<records xmlns="records:2" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="records:2 file://records-v2.0.xsd" version="2.0">
  <record>
    <data name="date" value="2005-05-04" />
    <data name="time" value="17:16:12" />
    <data name="time-taken" value="1" />
    <data name="c-ip" value="45.110.2.82" />
    <data name="sc-status" value="200" />
    <data name="s-action" value="TCP_HIT" />
    <data name="sc-bytes" value="941" />
    <data name="cs-bytes" value="729" />
    <data name="cs-method" value="GET" />
    <data name="cs-uri-scheme" value="http" />
    <data name="cs-host" value="www.inmobus.com" />
    <data name="cs-uri-path" value="/wcm/assets/images/imagefileicon.gif" />
    <data name="cs-uri-query" value="-" />
    <data name="cs-username" value="george" />
    <data name="s-hierarchy" value="DIRECT" />
    <data name="s-supplier-name" value="38.112.92.20" />
    <data name="rs(Content-Type)" value="image/gif" />
    <data name="cs(User-Agent)" value="Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1; SV1; .NET CLR 1.1.4322)" />
    <data name="sc-filter-result" value="PROXIED" />
    <data name="sc-filter-category" value="none" />
    <data name="x-virus-id" value="-" />
    <data name="s-ip" value="192.16.170.42" />
    <data name="s-sitename" value="SG-HTTP-Service" />
    <data name="x-virus-details" value="-" />
    <data name="x-icap-error-code" value="none" />
    <data name="x-icap-error-details" value="-" />
  </record>
</records>
```

Do not forget to Save {{< stroom-icon "save.svg" >}} the translation as we are complete.


### Schema Validation

One last point, validating the use of the Stroom Event Logging Schema is performed in the `schemaFilter` component of the pipeline.
Had our translation resulted in a malformed Event, this pipeline component displays any errors.
In the screen below, we have purposely changed the `EventTime/TimeCreated` element to be `EventTime/TimeCreatd`.
If one selects the `schemaFilter` component and then Refresh {{< stroom-icon name="refresh.svg" title="Refresh step" colour="green" >}} the current step, we will see that

* there is an error as indicated by a square **Red** box {{< stroom-icon "../HOWTOs/icons/errorIndicator.png" "Error indicator">}} in the top right hand corner

* there is a **Red** rectangle line indicator mark {{< stroom-icon "../HOWTOs/icons/errorLine.png" "Error line indicator" >}} on the right hand side in the display slide bar

* there is a **Red** error marker {{< stroom-icon "error.svg" >}} in the left hand gutter.

{{< screenshot "HOWTOs/UI-FeedProcessing-47.png" >}}Stroom UI Create Feed - Translation - Stepping XSLT Translation 6{{< /screenshot >}}

Hovering over the error marker {{< stroom-icon "error.svg" >}} on the left hand side will bring a pop-up describing the error.

{{< screenshot "HOWTOs/UI-FeedProcessing-48.png" >}}Stroom UI Create Feed - Translation - Stepping XSLT Translation 7{{< /screenshot >}}

At this point, close the **BlueCoat-Proxy-V1.0-EVENTS** stepping tab, acknowledging you do not want to save your errant changes

{{< screenshot "HOWTOs/UI-FeedProcessing-49.png" >}}Stroom UI Create Feed - Translation - Stepping XSLT Translation 8{{< /screenshot >}}

by pressing the {{< stroom-btn "Ok" >}} button.


## Automated Processing

Now that we have authored our translation, we want to enable Stroom to automatically process streams of raw event log data as it arrives.
We do this by configuring a `Processor` in the **BlueCoat-Proxy-V1.0-EVENTS** `pipeline`.


### Adding a Pipeline Processor

Open the **BlueCoat-Proxy-V1.0-EVENTS** `pipeline` by selecting it (_double left click_) in the `Explorer` display to show

{{< screenshot "HOWTOs/UI-FeedProcessing-50.png" >}}Stroom UI Enable Processing{{< /screenshot >}}

To configure a Processor we select the `Processors` hyper-link of the **BlueCoat-Proxy-V1.0-EVENTS** `Pipeline` tab to reveal

{{< screenshot "HOWTOs/UI-FeedProcessing-51.png" >}}Stroom UI Enable Processing - Processors table{{< /screenshot >}}

We add a Processor by pressing the add processor button {{< stroom-icon "add.svg" "Add processor">}} in the top left hand corner.
At this you will be presented with an `Add Filter` configuration window.

{{< screenshot "HOWTOs/UI-FeedProcessing-52.png" >}}Stroom UI Enable Processing - Add Filter 1{{< /screenshot >}}

As we wish to create a Processor that will automatically process all **BlueCoat-Proxy-V1.0-EVENTS** feed `Raw Events` we will select the BlueCoat-Proxy-V1.0-EVENTS `Feed` and Raw Event `Stream Type`.

To select the feed, we press the `Edit` button {{< stroom-icon "edit.svg" >}}.
At this, the `Choose Feeds To Include And Exclude` configuration window is displayed.

{{< screenshot "HOWTOs/UI-FeedProcessing-53.png" >}}Stroom UI Enable Processing - Add Filter 2{{< /screenshot >}}

As we need to `Include` the BlueCoat-Proxy-V1.0-EVENTS `Feed` in our selection, press the {{< stroom-icon "add.svg" >}} button in the `Include:` pane of the window to be presented with a `Choose Item` configuration window.

{{< screenshot "HOWTOs/UI-FeedProcessing-54.png" >}}Stroom UI Enable Processing - Add Filter 3{{< /screenshot >}}

Navigate to the **Event Sources/Proxy/BlueCoat** folder and select the **BlueCoat-Proxy-V1.0-EVENTS** `Feed`

{{< screenshot "HOWTOs/UI-FeedProcessing-55.png" >}}Stroom UI Enable Processing - Add Filter 4{{< /screenshot >}}

then press the {{< stroom-btn "Ok" >}} button to select and see that the feed is included.

{{< screenshot "HOWTOs/UI-FeedProcessing-56.png" >}}Stroom UI Enable Processing - Add Filter 5{{< /screenshot >}}

Again press the {{< stroom-btn "Ok" >}} button to close the `Choose Feeds To Include And Exclude` window to show that we have selected our feed in the `Feeds:` selection pane of the `Add Filter` configuration window.

{{< screenshot "HOWTOs/UI-FeedProcessing-57.png" >}}Stroom UI Enable Processing - Add Filter 6{{< /screenshot >}}

We now need to select our `Stream Type`.
Press the {{< stroom-icon "add.svg" >}} button in the `Stream Types:` pane of the window to be presented with a `Add Stream Type` window with a `Stream Type:` selection drop down.

{{< screenshot "HOWTOs/UI-FeedProcessing-58.png" >}}Stroom UI Enable Processing - Add Filter 7{{< /screenshot >}}

We select (_left click_) the drop down selection to display the types of Stream we can choose

{{< screenshot "HOWTOs/UI-FeedProcessing-59.png" >}}Stroom UI Enable Processing - Add Filter 8{{< /screenshot >}}

and as we are selecting `Raw Events` we select that item then press the {{< stroom-btn "Ok" >}} button at which we see that our `Add Filter` configuration window displays

{{< screenshot "HOWTOs/UI-FeedProcessing-60.png" >}}Stroom UI Enable Processing - Add Filter 9{{< /screenshot >}}

As we have selected our filter items, press the {{< stroom-btn "Ok" >}} button to display our configured Processors.

{{< screenshot "HOWTOs/UI-FeedProcessing-61.png" >}}Stroom UI Enable Processing - Configured Processors{{< /screenshot >}}

We now see our display is divided into two panes.
The Processors table pane at the top and the specific Processor pane below.
In our case, our filter selection has left the **BlueCoat-Proxy-V1.0-EVENTS** `Filter` selected in the Processors table

{{< screenshot "HOWTOs/UI-FeedProcessing-62.png" >}}Stroom UI Enable Processing - Configured Processors - Selected Processor{{< /screenshot >}}

and the specific filter's details in the bottom pane.

{{< screenshot "HOWTOs/UI-FeedProcessing-63.png" >}}Stroom UI Enable Processing - Configured Processors - Selected Processor Detail{{< /screenshot >}}

The column entries in the Processors Table pane describe

 * Pipeline - the name of the Processor pipeline ({{< stroom-icon "filter.svg">}})
 * Tracker Ms - the last time the tracker updated
 * Tracker % - the percentage of available streams completed
 * Last Poll Age - the last time the processor found new streams to process
 * Task Count - the number of processor tasks currently running
 * Priority - the queue scheduling priority of task submission to available stream processors
 * Streams - the number of streams that have been processed (includes currently running streams)
 * Events - ??
 * Status - the status of the processor.
 * Normally empty if the number of stream is open-ended.
 * If only are subset of streams were chosen (e.g. a time range in the filter) then the status will be _Complete_
 * Enabled - check box to indicate the processor is enabled

We now need only `Enable` both the pipeline Processor and the pipeline Filter for automatic processing to occur.
We do this by selecting both check boxes in the `Enabled` column.

{{< screenshot "HOWTOs/UI-FeedProcessing-64.png" >}}Stroom UI Enable Processing - Configured Processors - Enable Processor{{< /screenshot >}}

If we refresh our Processor table by pressing the {{< stroom-icon "refresh.svg" >}} button in the top right hand corner, we will see that more table entries have been filled in.

{{< screenshot "HOWTOs/UI-FeedProcessing-65.png" >}}Stroom UI Enable Processing - Configured Processors - Enable Processor Result{{< /screenshot >}}

We see that the tracker last updated at _2018-07-14T04:00:35.289Z_, the percentage complete is _100_ (we only had one stream after all), the last time active streams were checked for was _2.3_ minutes ago, there are no tasks running and that _1_ stream has completed.
Note that the `Status` column is blank as we have an _open ended_ filter in that the processor will continue to select and process any new stream of `Raw Events` coming into the **BlueCoat-Proxy-V1.0-EVENTS** feed.

If we return to the *BlueCoat-Proxy-V1.0-EVENTS** `Feed` tab, ensuring the **Data** hyper-link is selected and then refresh ({{< stroom-icon "refresh.svg">}}) the top pane that holds the summary of the latest Feed streams

{{< screenshot "HOWTOs/UI-FeedProcessing-66.png" >}}Stroom UI Enable Processing - Configured Processors - Feed Display{{< /screenshot >}}

We see a new entry in the table.
The columns display

 * Created - The time the stream was created.
 * Type - The type of stream.
   Our new entry has a type of 'Events' as we have processed our `Raw Events` data.
 * Feed - The name of the stream's feed
 * Pipeline - The name of the pipeline involved in the generation of the stream
 * Raw - The size in bytes of the raw stream data
 * Disk - The size in bytes of the raw stream data when stored in compressed form on the disk
 * Read - The number of records read by a pipeline
 * Write - The number of records (events) written by a pipeline.
   In this case the difference is that we did not generate events for the `Software` or `Version` records we read.
 * Fatal - The number of fatal errors the pipeline encountered when processing this stream
 * Error - The number of errors the pipeline encountered when processing this stream
 * Warn - The number of warnings the pipeline encountered when processing this stream
 * Info - The number of informational alerts the pipeline encountered when processing this stream
 * Retention - The retention period for this stream of data


If we also refresh ({{< stroom-icon "refresh.svg">}}) the specific feed pane (middle) we again see a new entry of the `Events` _Type_

{{< screenshot "HOWTOs/UI-FeedProcessing-67.png" >}}Stroom UI Enable Processing - Configured Processors - Specific Feed Display{{< /screenshot >}}

If we select (_left click_) on the `Events` _Type_ in either pane, we will see that the data pane displays the first event in the _GCHQ Stroom Event Logging XML Schema_ form.

{{< screenshot "HOWTOs/UI-FeedProcessing-68.png" >}}Stroom UI Enable Processing - Configured Processors - Event Display{{< /screenshot >}}

We can now send a file of BlueCoat Proxy logs to our Stroom instance from a Linux host using _curl_ command and see how Stroom will automatically processes the file.
Use the command

{{< command-line "user" "localhost" >}}
curl \
-k \
--data-binary @sampleBluecoat.log \
https://stroomp.strmdev00.org/stroom/datafeed \
-H"Feed:BlueCoat-Proxy-V1.0-EVENTS" \
-H"Environment:Development" \
-H"LogFileName:sampleBluecoat.log" \
-H"MyHost:\"somenode.strmdev00.org\"" \
-H"MyIPaddress:\"192.168.2.220 192.168.122.1\"" \
-H"System:Site http://log-sharing.dreamhosters.com/ Bluecoat Logs" \
-H"Version:V1.0"
{{</ command-line >}}

After Stroom's Proxy aggregation has occurred, we will see that the new file posted via _curl_ has been loaded into Stroom as per

{{< screenshot "HOWTOs/UI-FeedProcessing-69.png" >}}Stroom UI Enable Processing - Configured Processors - New Posted Stream{{< /screenshot >}}

and this new _Raw Event_ stream is automatically processed a few seconds later as per

{{< screenshot "HOWTOs/UI-FeedProcessing-70.png" >}}Stroom UI Enable Processing - Configured Processors - New Posted Stream Processed{{< /screenshot >}}

We note that since we have used the same sample file again, the Stream sizes and record counts are the same.

If we switch to the `Processors` tab of the pipeline we see that the Tracker timestamp has changed and the number of Streams processed has increased.

{{< screenshot "HOWTOs/UI-FeedProcessing-71.png" >}}Stroom UI Enable Processing - Configured Processors - New Posted Stream Processors{{< /screenshot >}}
