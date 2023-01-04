---
title: "Pipeline Processing"
linkTitle: "Pipeline Processing"
weight: 30
date: 2022-02-03
tags:
  - processing
  - pipeline
  - data-splitter
description: >
  Creating pipelines to process and transform data.

---

Pipelines control how data is processed in Stroom.
Typically you're going to want to do a lot of the same stuff for every pipeline, i.e. similar transformations, indexing, writing out data.
You can actually create a template pipeline and inherit from it, tweaking what you need to for this or that feed.
We're not doing that now because we want to show how to create one from scratch.


## Create a pipeline

1. Create a pipeline by right-clicking our {{< stroom-icon "folder.svg" >}} `Stroom 101` folder and selecting:

   {{< stroom-menu "New" "Pipeline" >}}

1. Call it something like `CSV to XML pipeline`.

1. Select _Structure_ from the top of the new tab. This is the most important view for the pipeline because it shows what will actually happen on the pipeline.

We already have a `Source` element.
Unlike most other pipeline elements this isn't something we need to configure.
It's just there to show the starting point.
Data gets into the pipeline via other means - we'll describe this in detail later.


### Add a data splitter

Data splitters are powerful, and there is [a lot we can say]({{< relref "../user-guide/data-splitter" >}}) about them.
Here we're just going to make a basic one.


#### Create a CSV splitter

We have CSV data in the following form:

```csv
id,guid,from_ip,to_ip,application
1,10990cde-1084-4006-aaf3-7fe52b62ce06,159.161.108.105,217.151.32.69,Tres-Zap
2,633aa1a8-04ff-442d-ad9a-03ce9166a63a,210.14.34.58,133.136.48.23,Sub-Ex
```

To process this we need to know if there's a header row, and what the delimiters are.
This is a job for a _Data Splitter_. 

The splitter is actually a type of _Text Converter_ {{< stroom-icon "document/TextConverter.svg" >}}, so lets create one of those:

1. Right click on our {{< stroom-icon "folder.svg" >}} `Stroom 101` folder and selecting:

   {{< stroom-menu "New" "Text Converter" >}}

1. Call it something like `CSV splitter`.

In the new tab you need to tell the _Text Converter_ that it'll be a _Data Splitter_:

Click the _Settings_ sub-tab then select _Data Splitter_ in the _Converter Type_ drop-down.

{{< image "quick-start-guide/process/configure-csvSplitter-type.png" >}}Configuring the data splitter{{< /image >}}

Now go to the _Conversion_ tab.
What you need to put in here is specific to the built-in _Data Splitter_ functionality, so I'm just going to tell you what you're going to need:

```xml
<?xml version="1.1" encoding="UTF-8"?>
<dataSplitter
    xmlns="data-splitter:3"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xsi:schemaLocation="data-splitter:3 file://data-splitter-v3.0.xsd"
    version="3.0">

  <!-- The first line contains the field names -->
  <split delimiter="\n" maxMatch="1">
    <group>
      <split delimiter="," containerStart="&#34;" containerEnd="&#34;">
        <var id="heading" />
      </split>
    </group>
  </split>

  <!-- All subsequent lines are records -->
  <split delimiter="\n">
    <group>
      <split delimiter="," containerStart="&#34;" containerEnd="&#34;">
        <data name="$heading$1" value="$1" />
      </split>
    </group>
  </split>
</dataSplitter>
```

> This guide assumes you are running the _stroom_core_test_ stack which has the _data_splitter-v3.0.xsd_ schema pre-loaded.

Save it by clicking the save button {{< stroom-icon "save.svg" >}}.

So we now have a configured, re-usable data splitter for CSV files that have headers.
We need to add this to our pipeline as a filter, so head back to the pipeline's Structure section and add a DSParser.

1. Right-click the {{< pipe-elm "Source" >}} element and select:

   {{< stroom-menu "Add" "Parser" "DSParser" >}}

1. Call it _CSV Parser_ and click OK.

We need to tell the new _CSV parser_ to use the {{< stroom-icon "document/TextConverter.svg" >}} _TextConverter_ (_CSV splitter_) we created earlier.

1. Click on the {{< pipe-elm "DSParser" "CSV Parser" >}} element and the pane below will show it's properties.
1. Double click the `textConverter` property and change `Value` to our _CSV splitter_ entity.

{{< image "quick-start-guide/process/configuring-dsSplitter.png" >}}Configuring the CSV splitter{{< /image >}}

Now save the pipeline by clicking the add button {{< stroom-icon "add.svg" >}}.


#### Test the csv splitter

So now we have CSV data in Stroom and a pipeline that is configured to process CSV data.
We've done a fair few things so far and are we sure the pipeline is correctly configured?
We can do some debugging and find out.

In Stroom you can step through you records and see what the output is at each stage.
It's easy to start doing this.
The first thing to do is to open your `CSV_FEED` feed, click on the {{< glossary "stream" >}} in the top pane then click the big blue stepping button {{< stroom-icon "stepping.svg" >}} at the bottom right of the bottom data pane.

You'll be asked to select a pipeline:

{{< image "quick-start-guide/process/configure-debug.png" >}}Selecting a pipeline to step through{{< /image >}}

Now you get a view that's similar to your feed view, except it also shows the pipeline.
The Stepper allows you to step through each record in the source data, where a record is defined by your Data Splitter parser.
The Stepper will highlight the currently selected record/event.

{{< image "quick-start-guide/process/debug-source.png" >}}Stepping - source data{{< /image >}}

The Stepper also has stepping controls to allow you to move forward/backward through the source data.
Click the green step forward button {{< stroom-icon "step-forward.svg" >}}.

You should see the highlighted section advance to the next record/event.

{{< image "quick-start-guide/process/stepping-01.png" >}}Stepping through the CSV data{{< /image >}}

Click on the _CSV parser_ element.
You will now see the stepping view for this element that is split into three panes:

* Top pane - this shows the content of your _CSV parser_ element, i.e. the _TextConverter_ (_CSV splitter_) XML.
  This can be used to modify your _TextConverter_.
* Bottom left pane - this shows the input to the pipeline element.
* Bottom right pane - this shows the output from the pipeline element.
  The output from the Data Splitter is XML in _records_ format.
  You can see the schema for _records_ in the `XML schemas` folder.

{{< image "quick-start-guide/process/stepping-02.png" >}}The output from a working data splitter{{< /image >}}

If there are any errors then you will see an error icon {{< stroom-icon "error.svg" >}} in the gutter of the top pane.
In the example below, an invalid XML element has been added to the Data Splitter content to demonstrate an error occurring.

{{< image "quick-start-guide/process/stepping-error.png" "700" />}}


### Add XSLT to transform records format XML into something else

{{< glossary "XSLT" >}} is the language used to transform record/event data from one form into another in Stroom pipelines.
An {{< element "XSLTFilter" >}} pipeline element takes XML input and uses an XSLT to transform it into different XML or some other text format.


#### Create the XSLT filter

This process is very similar to creating the `CSV splitter`: 

1. Create the [XSLT]({{< relref "/docs/user-guide/pipelines/xslt" >}}) filter
1. Add it to the pipeline 
1. Step through to make sure it's doing what we expect

To create the new _XSLT_ entity do the following:

1. Right click the {{< stroom-icon "folder.svg" >}} _Stroom 101_ folder in the {{< glossary "Explorer Tree" >}} and select:

   {{< stroom-menu "New" "XSL Translation" >}}

1. Name it _XSLT_.
1. Click _OK_.

This will open a new tab for the _XSLT_ entity.

On the new tab ensure the `XSLT` sub-tab is selected.
This is another text editor pane but this one accepts _XSLT_.
This _XSLT_ will be very basic and just takes the record data from the split filter and puts it into fields.
The XSLT for this is below but if you'd like to tinker then go ahead.

```xml
<?xml version="1.1" encoding="UTF-8" ?>
<xsl:stylesheet
    xpath-default-namespace="records:2"
    xmlns:stroom="stroom"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    version="2.0">

  <xsl:template match="records">
    <Events>
      <xsl:apply-templates />
    </Events>
  </xsl:template>
  <xsl:template match="record">
    <xsl:variable name="id" select="data[@name='id']/@value" />
    <xsl:variable name="guid" select="data[@name='guid']/@value" />
    <xsl:variable name="from_ip" select="data[@name='from_ip']/@value" />
    <xsl:variable name="to_ip" select="data[@name='to_ip']/@value" />
    <xsl:variable name="application" select="data[@name='application']/@value" />

    <Event>
      <Id><xsl:value-of select="$id" /></Id>
      <Guid><xsl:value-of select="$guid" /></Guid>
      <FromIp><xsl:value-of select="$from_ip" /></FromIp>
      <ToIp><xsl:value-of select="$to_ip" /></ToIp>
      <Application><xsl:value-of select="$application" /></Application>
    </Event>
  </xsl:template>
</xsl:stylesheet>
```

Make sure you save it by clicking the save button {{< stroom-icon "save.svg" >}}.

Go back to the Structure sub-tab of the pipeline and add an {{< element "XSLTFilter" >}} element downstream of the _CSV parser_ element.
Call it something like _XSLT filter_. 

Select the _XSLT filter_ element and configure it to use the actual XSLT you just created by double-clicking `xslt` in the properties pane at the bottom:

In the dialog make sure you select the `XSLT` filter in the _Stroom 101_ folder.
Save the pipeline.


#### Test the XSLT filter

We're going to test this in the same way we tested the CSV splitter, by clicking the large stepping button {{< stroom-icon "stepping.svg" >}}on the feed data pane.
Click the step forward button {{< stroom-icon "step-forward.svg" >}} a few times to make sure it's working then click on the XSLT element.
This time you should see the XSLT filter there too, as well as the basic XML being transformed into more useful XML:

{{< image "quick-start-guide/process/stepping-03.png" "500" >}}Stepping the XSLT filter{{< /image >}}

There's a few more things to get this pipeline ready for doing this [task]({{< relref "../user-guide/jobs.md" >}}) for real.
We need to get this data to a destination.


### Outputting the transformed data

The XSLT filter doesn't actually write XML but instead it just outputs XML events to the next element in the pipeline.
In order to write these XML events out to a destination you need a writer.
If your transofmration is producing XML then you need an {{< element "XMLWriter" >}}, if it is producing JSON then you need a {{< element "JSONWriter" >}} and for plain text you need a {{< element "TextWriter" >}}.

Our _XSLT filter_ element is outputting XML so we will create an _XMLWriter_.


#### Create the XML writer

You don't need to create one outside the pipeline (in the way you did with the `CSV splitter` and the `XSLT` filter).
Just do the following:

1. Right click on the {{< pipe-elm "XSLTFilter" "XSLT filter" >}} element and select:

   {{< stroom-menu "Add" "Writer" "XMLWriter" >}}

1. Name it _XML writer_.
1. Click OK.

That's it, no other configuration necessary.


#### Create the destination

We need to do something with the serialised XML.
We'll write it to a {{< glossary "Stream" >}}.
To do this we create a {{< element "StreamAppender" >}}:

1. Right click on the {{< pipe-elm "XMLWriter" "XML Writer" >}} element and select:

   {{< stroom-menu "Add" "Destination" "StreamAppender" >}}

1. Name it _Stream appender_.
1. Click OK.

Streams only exist within feeds and have a type.
We could set the feed that the stream will be written into but by default the _StreamAppender_ will write to the same _Feed_ as the input stream.
We must however set the type of the _Stream_ to distinguish it from the _Raw Events_ _Stream_ that we POSTed to Stroom.

To set the {{< glossary "Stream Type" >}} do the following:

1. Click on the {{< stroom-icon "pipeline/stream.svg" "Stream Appender" >}} _Stream appender_ pipeline element and the pane below will show it's properties.
1. Double click the `streamType` property and change `Value` to the _Events_ stream type.


#### Test the destination

We can test the XML writer and the streamAppender using the same stepping feature.
Make sure you've saved the pipeline and set a **new** stepping session running.
If you click on the `stream appender` you'll see something like this:

{{< image "quick-start-guide/process/stepping-05.png" >}}The final output from the pipeline{{< /image >}}


## Set the pipeline running

Obviously you don't want to step through your data one by one.
This all needs automation, and this is what {{< glossary "Processor" "Processors" >}} and {{< glossary "Processor Filter" "Processor Filters" >}} are for.
The processor works in the background to take any unprocessed streams (as determined by the Processor Filter and its {{< glossary "Tracker" >}}) and process them through the pipeline.
So far everything on our _EXAMPLE_IN_ feed is unprocessed. 


### Create a processor and filter

Processors are created from the _Processors_ sub-tab of the pipeline.

Click the add button {{< stroom-icon "add.svg" >}} and you will be presented with a Filter {{< glossary "Expression Tree" >}}.
To configure the filter do the following:

1. Right click on the root AND operator and click {{< stroom-icon "add.svg" "Add Term" >}} Add Term.
  A new expression is added to the tree as a child of the operator and it has three dropdowns in it ({{< glossary "Field" >}}, {{< glossary "Condition" >}} and value).
1. Create an expression term for the Feed:
    1. Field: `Feed`
    1. Condition: `is`
    1. Value: `CSV_FEED`
1. Create an expression term for the Stream Type:
    1. Field: `Type`
    1. Condition: `=`
    1. Value: `Raw Events`


You only need to set the incoming feed and the stream types:

{{< image "quick-start-guide/process/configure-processor.png" >}}Configure the new processor filter{{< /image >}}

You will now see the newly created processor and its filter.

{{< image "quick-start-guide/process/show-processors.png" >}}The new processor and filter{{< /image >}}

Ensure that both the processor and its filter are enabled by clicking the checkbox at the left of the row.
This is it, everything we've done is about to start working on its own, just like it would in a real configuration.

If you keep refreshing this table it will show you the processing status which should change after a few seconds to show that the data you have uploaded is being or has been processed.
The fields in the filter row will have been updated to reflect the new position of the Filter Tracker.
Once this has happened you should be able to open the destination feed `CSV_FEED` and see the output data (or errors if there were any).
If the `CSV_FEED` tab was already open then you will likely need to click refresh {{< stroom-icon "refresh.svg" >}} on the top pane.

{{< image "quick-start-guide/process/show-output.png" "400" >}}The output of the pipeline{{< /image >}}

You can see that there are the `Raw Events` and the processed `Events`.
If you click on the `Events` then you can see all the XML that we've produced.

Now you've processed your data you can go ahead and [index]({{< relref "indexing.md" >}}) it.
