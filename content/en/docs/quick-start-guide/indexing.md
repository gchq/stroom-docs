---
title: "Indexing"
linkTitle: "Indexing"
weight: 40
date: 2021-07-09
tags:
  - index
  - xslt
description: >
  Indexing the ingested data so we can search it.

---

Before you can visualise your data with dashboards you have to {{< glossary "index" >}} the data.

{{% note %}}
Stroom uses Apache Lucene for indexing its data but can also can also integrate with Solr and {{< glossary "Elasticsearch" >}}.
For this Quick Start Guide we are going to use Stroom's internal Lucence indexing.
{{% /note %}}


## Create the index

We can create an index by adding an index entity {{< stroom-icon "document/Index.svg" "Index" >}}to the explorer tree.
You do this in the same way you create any of the items.

1. Right click on the {{< stroom-icon "folder.svg" >}} _Stroom 101_ folder and select:

   {{< stroom-menu "New" "Lucene Index" >}}

1. Call the index _Stroom 101_.
   Click OK.

This will open the new {{< stroom-icon "document/Index.svg" >}} _Stroom 101_ index as a new tab, {{< stroom-tab "Index.svg" "Stroom 101" >}}.


## Assign a volume group

In the settings tab we need to specify the {{< glossary "Volume" >}} where we will store our index shards.

1. Click the _Settings_ sub-tab.
1. In the _Volume Group_ dropdown select _Default Volume Group_.
1. Click the {{< stroom-icon "save.svg" "Save" >}} button.


## Adding fields

Now you need to add fields to this index.

The fields in the index may map 1:1 with the fields in the source data but you may want to index only a sub-set of the fields, e.g. if you would only ever want to filter the data on certain fields.
Fields can also be created that are an abstraction of multiple fields in the data, e.g. adding all text in the record into one field to allow filtering on some text appearing anywhere in the record/event.

Click the _Fields_ sub-tab.

We need to create fields in our index to match the fields in our source data so that we can query against them.

Click on the {{< stroom-icon "add.svg" "Add" >}} button to add a new index field.

{{< image "quick-start-guide/index/006_index_field.png" >}}Creating an index field{{< /image >}}

Now create the fields using these values.

Name         | Type   | Store  | Index  | Positions  | Analyser       | Case Sensitive
----         | ----   | -----  | -----  | ---------  | --------       | --------------
StreamId     | Id     | Yes    | Yes    | No         | Keyword        | false
EventId      | Id     | Yes    | Yes    | No         | Keyword        | false
Id           | Id     | Yes    | Yes    | No         | Keyword        | false
Guid         | Text   | Yes    | Yes    | No         | Keyword        | false
FromIp       | Text   | Yes    | Yes    | No         | Keyword        | false
ToIp         | Text   | Yes    | Yes    | No         | Keyword        | false
Application  | Text   | Yes    | Yes    | Yes        | Alpha numeric  | false

{{% note %}}
There are two mandatory fields that need to be added: `StreamId` and `EventId`.
These are not in the source records but are assigned to cooked events/records by Stroom.
You will see later how these fields get populated.
{{% /note %}}

You should now have:

{{< image "quick-start-guide/index/007_index_field_list.png" >}}Index field list{{< /image >}}

When you've done that, save the new index by clicking the {{< stroom-icon "save.svg" "Save" >}} button.


## Create empty index XSLT

In order for Stroom to index the data, an {{< glossary "XSLT" >}} is required to convert the event XML into an Index record.
This can be a simple 1:1 mapping from event field to index field or something more complex, e.g. combining multiple event fields into one index field.

To create the XSLT for the Index:

1. Right click on the {{< stroom-icon "folder.svg" >}} _Stroom 101_ folder in the explorer tree, then select:

   {{< stroom-menu "New" "XSL Translation" >}}

1. Name it `Stroom 101`.
1. Click OK.

We will add the XSLT content later on.


## Index pipeline

Now we are going to create a pipeline to send the processed data (_Events_) to the index we just created.
Typically in Stroom all {{< glossary "Raw Events" >}} are first processed into normalised {{< glossary "Events" >}} conforming to the same XML schema to allow common onward processing of events from all sources.

We will create a pipeline to index the processed _Event_ streams containing XML data.

1. Right click on the {{< stroom-icon "folder.svg" "Folder" >}} _Stroom 101_ folder in the explorer tree, then select:

   {{< stroom-menu "New" "Pipeline" >}}

1. Name it `Stroom 101`.
1. Click OK.

Select the _Structure_ sub-tab to edit the structure of the pipeline.

Pipelines can inherit from other pipelines in Stroom so that you can benefit from re-use.
We will inherit from an existing indexing template pipeline and then modify it for our needs.

1. On the _Structure_ sub tab, click the {{< stroom-icon "ellipses-horizontal.svg" "Ellipses">}} in the _Inherit From_ entity picker.
1. Select {{< stroom-icon "folder.svg">}} _Template Pipelines_ / {{< stroom-icon "document/Pipeline.svg">}} _Indexing_

You should now see the following structure:

{{< image "quick-start-guide/index/012_indexing_pipeline.png" >}}Indexing pipeline{{< /image >}}

Inheriting from another pipeline often means the structure is there but some properties may not have been set, e.g. `xslt` in the _xsltFilter_.
If a property has been set in the partent pipeline then you can either use the inherited value or override it.

See the [Pipeline Element Reference]({{< relref "docs/user-guide/pipelines/element-reference.md" >}}) for details of what each element does.

Now we need to set the `xslt` property on the _xsltFilter_ to point at the XSLT document we created earlier and set the `index` property on the _indexFilter_ to point to the index we created.

1. Assign the XSLT document
   1. Click on the {{< pipe-elm "XSLTFilter" >}} element.
   1. In the middle Properties pane double-click on the `xslt` row.
   1. Click the {{< stroom-icon "ellipses-horizontal.svg" "Ellipses">}}in the _Value_ document picker
   1. Select:  
      {{< stroom-icon "folder.svg">}} _Stroom 101_ / {{< stroom-icon "document/XSLT.svg">}} _Stroom 101_.
   1. Click {{< stroom-btn "OK" >}}.
1. Assign the Index document
   1. Click on the {{< pipe-elm "IndexingFilter" >}} element.
   1. In the middle Properties pane double-click on the `index` row.
   1. Click the `...` in the _Value_ document picker
   1. Select:  
      {{< stroom-icon "folder.svg">}} _Stroom 101_ / {{< stroom-icon "document/Index.svg">}} _Stroom 101_.
   1. Click {{< stroom-btn "OK" >}}.

Once that's done you can save your new pipeline by clicking the {{< stroom-icon "save.svg" >}} button.


## Develop index translation

Next we need to create an XSLT that the `indexingFilter` understands.
The best place to develop a translation is in the {{< glossary "Stepper" >}} as it allows you to simulate running the data through the pipeline without producing any persistent output.

Open the {{< stroom-icon "feed.svg" >}} _CSV_FEED_ {{< glossary "Feed" >}} we created earlier in the quick-start guide.

1. In the top pane of the Data Browser select the _Events_ {{< glossary "Events" >}} stream.
1. In the bottom pane you will see the XML data the you processed earlier.
1. Click the {{< stroom-icon "stepping.svg" >}} button to open the Stepper.
1. In the _Choose Pipeline To Step With_ dialog select our index pipeline:  
   {{< stroom-icon "folder.svg">}} _Stroom 101_ / {{< stroom-icon "document/Pipeline.svg">}} _Stroom 101_.

This will open a Stepper tab showing only the elements of the selected pipeline that can be stepped.
The data pane of the _Source_ element will show the first event in the stream.

To add XSLT content click the {{< stroom-icon "pipeline/xslt.svg">}} _xsltFilter_ element.
This will show the three pane view with editable content (empty) in the top pane and input and output in the bottom two panes.

The input and output panes will be identical as there is no XSLT content to transform the input.

{{< cardpane >}}
  {{< card header="Input" >}}
```xml
<?xml version="1.1" encoding="UTF-8"?>
<Events xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
  <Event StreamId="25884" EventId="1">
    <Id>1</Id>
    <Guid>10990cde-1084-4006-aaf3-7fe52b62ce06</Guid>
    <FromIp>159.161.108.105</FromIp>
    <ToIp>217.151.32.69</ToIp>
    <Application>Tres-Zap</Application>
  </Event>
</Events>
```
  {{< /card >}}
  {{< card header="Output" >}}
```xml
<?xml version="1.1" encoding="UTF-8"?>
<Events xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
  <Event StreamId="25884" EventId="1">
    <Id>1</Id>
    <Guid>10990cde-1084-4006-aaf3-7fe52b62ce06</Guid>
    <FromIp>159.161.108.105</FromIp>
    <ToIp>217.151.32.69</ToIp>
    <Application>Tres-Zap</Application>
  </Event>
</Events>
```
  {{< /card >}}
{{< /cardpane >}}

Paste the following content into the top pane.

```xml
<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet
    xmlns="records:2"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    version="2.0">
  
  <!-- Match on the top level Events element -->
  <xsl:template match="/Events">
    <!-- Create the wrapper element for all the events/records -->
    <records
        xsi:schemaLocation="records:2 file://records-v2.0.xsd"
        version="2.0">
      <!-- Apply any templates to this element or its children -->
      <xsl:apply-templates />
    </records>
  </xsl:template>
  
  <!-- Match on any Event element at this level -->
  <xsl:template match="Event">
    <!-- Create a record element and populate its data items -->
    <record>
      <data name="StreamId">
        <!-- Added to the event by the IdEnrichmentFiler -->
        <xsl:attribute name="value" select="@StreamId" />
      </data>
      <data name="EventId">
        <!-- Added to the event by the IdEnrichmentFiler -->
        <xsl:attribute name="value" select="@EventId" />
      </data>
      <data name="Id">
        <xsl:attribute name="value" select="./Id" />
      </data>
      <data name="Guid">
        <xsl:attribute name="value" select="./Guid" />
      </data>
      <data name="FromIp">
        <xsl:attribute name="value" select="./FromIp" />
      </data>
      <data name="ToIp">
        <xsl:attribute name="value" select="./ToIp" />
      </data>
      <data name="Application">
        <xsl:attribute name="value" select="./Application" />
      </data>
    </record>
  </xsl:template>
</xsl:stylesheet>
```

The XSLT is converting `Events/Event` elements into `Records/Record` elements conforming to the `records:2` XML Schema, which is the expected input format for the {{< element "IndexingFilter" >}}.

The _IndexingFilter_ expects a set of `Record` elements wrapped in a `Records` element.
Each `Record` element needs to contain one `Data` element for each Field in the Index.
Each `Data` element needs a `Name` attribute (the Index Field name) and a `Value` attribute (the value from the event to index).

Now click the {{< stroom-icon name="refresh.svg" title="Refresh" colour="green" >}} refresh button to refresh the step with the new XSLT content.

The Output should have changed so that the Input and Output now look like this:

{{< cardpane >}}
  {{< card header="Input" >}}
```xml
<?xml version="1.1" encoding="UTF-8"?>
<Events xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
  <Event StreamId="25884" EventId="1">
    <Id>1</Id>
    <Guid>10990cde-1084-4006-aaf3-7fe52b62ce06</Guid>
    <FromIp>159.161.108.105</FromIp>
    <ToIp>217.151.32.69</ToIp>
    <Application>Tres-Zap</Application>
  </Event>
</Events>
```
  {{< /card >}}
  {{< card header="Output" >}}
```xml
<?xml version="1.1" encoding="UTF-8"?>
<records
    xmlns="records:2"
    xmlns:stroom="stroom"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xsi:schemaLocation="records:2 file://records-v2.0.xsd"
    version="2.0">
  <record>
    <data name="StreamId" value="25884" />
    <data name="EventId" value="1" />
    <data name="Id" value="1" />
    <data name="Guid" value="10990cde-1084-4006-aaf3-7fe52b62ce06" />
    <data name="FromIp" value="159.161.108.105" />
    <data name="ToIp" value="217.151.32.69" />
    <data name="Application" value="Tres-Zap" />
  </record>
</records>
```
  {{< /card >}}
{{< /cardpane >}}

You can use the stepping controls ({{< stroom-icon name="fast-backward.svg" title="Fast Backward" colour="green" >}}{{< stroom-icon name="step-backward.svg" title="Step Backward" colour="green" >}}{{< stroom-icon name="step-forward.svg" title="Step Forward" colour="green" >}}{{< stroom-icon name="fast-forward.svg" title="Fast Forward" colour="green" >}}) to check that the ouput is correct for other input events.

Once you are happy with your translation click the {{< stroom-icon "save.svg" >}} button to save the XSLT content to the _Stroom 101_ XSLT document.


## Processing the indexing pipeline

To get our indexing pipeline processing data we need to create a {{< glossary "Processor Filter" >}} to select the data to process through the pipeline.

Go back to your {{< stroom-icon "document/Pipeline.svg">}} _Stroom 101_ pipeline and go to the Processors sub-tab.

Click the add button {{< stroom-icon "add.svg" >}} and you will be presented with a Filter {{< glossary "Expression Tree" >}} in the _Add Filter_ dialog.
To configure the filter do the following:

1. Right click on the root AND operator and click {{< stroom-icon "add.svg" "Add Term" >}} Add Term.
  A new expression is added to the tree as a child of the operator and it has three dropdowns in it ({{< glossary "Field" >}}, {{< glossary "Condition" >}} and value).
1. To create an expression term for the Feed:
    1. Field: `Feed`
    1. Condition: `is`
    1. Value: `CSV_FEED`
1. To create an expression term for the Stream Type:
    1. Field: `Type`
    1. Condition: `=`
    1. Value: `Events`

This filter will process all Streams of type `Events` in the Feed `CSV_FEED`.
Enable processing for the {{< stroom-icon "document/Pipeline.svg">}} Pipeline and the {{< stroom-icon "filter.svg" "Processor Filter">}} Processor Filter by clicking the checkboxes in the _Enabled_ column.

Stroom should then index the data, assuming everything is correct.

If there are errors you'll see error streams produced in the data browsing page of the _CSV_FEED_ Feed or the _Stroom 101_ Pipeline.
If no errors have occurred, there will be no rows in the data browser page as the IndexFilter does not output any Streams.

To verify the data has been written to the Index:

1. Open the {{< stroom-icon "document/Index.svg" >}} _Stroom 101_ Index.
1. Select the _Shards_ sub-tab.
1. Click {{< stroom-icon "refresh.svg" >}} refresh.
   You many need to wait a bit for the data to be flushed to the index shards.

You should eventually see a _Doc Count_ of 2,000 to match the number of events processed in the source Stream.

Now that we have finished indexing we can display data on a [dashboard]({{< relref "dashboard.md" >}}).
