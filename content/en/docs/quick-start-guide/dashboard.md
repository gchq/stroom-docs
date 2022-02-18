---
title: "Dashboards"
linkTitle: "Dashboards"
weight: 50
date: 2021-07-09
tags: 
  - dashboard
  - visualisation
  - query
description: >
  Querying and visualising the indexed data.

---

Create a new {{< stroom-icon "document/Dashboard.svg">}} {{< glossary "Dashboard" >}} in the _Stroom 101_ folder and call it _Stroom 101_.

{{< image "quick-start-guide/dashboard/001_dashboard_new.png" "500" >}}New Dashboard{{< /image >}}

By default a new Dashboard opens with two panes; a {{< glossary "Query" >}} pane at the top to build the query; and a {{< glossary "Table" >}} pane at the bottom to display the results.
Dashboards are highly configurable; panes can be added and resized; they can contain multiple queries; and a query pane can provide data for multiple output panes (such as {{< glossary "Visualisation" "Visualisations">}}).


## Configuring the query data source

On the query pane click the settings {{< stroom-icon "settings-grey.svg" "Dashboard settings" >}} button on the top right of the panel.

{{< image "quick-start-guide/dashboard/002_dashboard_query_settings.png" "350" >}}Dashboard settings{{< /image >}}

1. Click on the _Data Source_ document picker.
1. Select the index you created earlier:  
   {{< stroom-icon "folder.svg">}} _Stroom 101_ / {{< stroom-icon "document/Index.svg">}} _Stroom 101_


## Configuring the query expression

Now add a term to the query to filter the data.

1. Right click on the root AND operator and click {{< stroom-icon "add.svg" "Add Term" >}} Add Term.
  A new expression is added to the tree as a child of the operator and it has three dropdowns in it ({{< glossary "Field" >}}, {{< glossary "Condition" >}} and value).
1. Create an expression term for the _Application_ field:
    1. Field: `Application`
    1. Condition: `=`
    1. Value: `*ar*`

This will find any records with `ar` in the _Application_ field.


## Configuring the table

All fields are [stored]({{< relref "/docs/user-guide/indexing/lucene#stored-fields" >}}) in our index so we do not need to worry about configuring {{< glossary "Search Extraction" >}}.

We first need to add some columns to our table.
Using the {{< stroom-icon "add.svg" >}} add button, add the following columns to the table.

* _Application_
* _Count_

We want a count of records grouped by _Application_.

{{% note %}}
_Count_ is a special column, not in the index, that applies the aggregate function `count()`.
All columns are actually just an expression which may be a simple field like `${Application}` or a function.
Stroom has a rich library of functions for aggregating and mutating query results.
See [Expressions]({{< relref "/docs/user-guide/dashboards/expressions" >}})
{{% /note %}}

To group our data we need to apply a group level to the _Application_ column.

1. Click on the _Application_ column
1. Click 











Now click the large green and white play button to run the query.

{{< image "quick-start-guide/dashboard/002_dashboard_query_add_term.png" >}}Dashboard query add term{{< /image >}}

For our simple example we’re using a wild card that captures all documents with an Id set.

{{< image "quick-start-guide/dashboard/003_dashboard_query_edit_term.png" >}}Dashboard query edit term{{< /image >}}

Within the table panel we now need to set a few defaults.  On the table pane click the settings {{< stroom-icon "settings-grey.svg" "Dashboard settings" >}}
 button on the top right of the panel.  `Extract Values` needs to be ticked.  If grouping is to be used and the content of the groups is to be viewed then `Show Group Detail` should also be ticked.  The `Maximum Results` field may also be changed from default if required to limit the results or if more results are expected than the default value.  Be aware that setting this value too high may result in excessive memory being used by the query process though.

We now need to select a pipeline to display the results in the table by setting `Extraction Pipeline`.  The simplest way is to create and save a new pipeline based on the existing `Search Extraction` template pipeline.  Within this new pipeline, use either the XSLT used for indexing the data or preferably a copy of this XSLT saved elsewhere.  The extraction pipeline and the dashboard itself should then be saved.

In the table panel we can add the fields we are interested in, in this case we wanted to sort the application field and count how many time the application name appears.

{{< image "quick-start-guide/dashboard/004_dashboard_table_fields.png" >}}Dashboard table fields{{< /image >}}

If at this point, we decide that we'd like to see additional fields in the table extracted from each record then the Extraction Pipeline XSLT can be modified to extract them from the Event:

```xml
...
  <xsl:template match="/xpath/to/usefulField">
    <data name="UsefulField">
      <xsl:attribute name="value" select="text()" />
    </data>
  </xsl:template>
...
```

To be able to select this new field from the table drop-down, it needs to be added back into the list of fields in the original index:

| Name         | Type   | Store  | Index  | Positions  | Analyser       | Case Sensitive
| ----         | ----   | -----  | -----  | ---------  | --------       | --------------
| UsefulField  | Text   | No     | No     | No         | Keyword        | false

If any additionals are made at this point, the index must first be saved and then the dashboard closed and reopened. `UsefulField` will then be available as a drop-down option in the table.

Start the query and we should get this

{{< image "quick-start-guide/dashboard/005_dashboard_table.png" >}}Dashboard table{{< /image >}}

Then we can add an element from the top again and this time use visualisation

{{< image "quick-start-guide/dashboard/006_dashboard_add_visualisation.png" >}}Dashboard add visualisation{{< /image >}}

In the visualisation panel that has been added to the bottom, click the settings {{< stroom-icon "settings-grey.svg" "Dashboard settings" >}}
 button on the top right of the panel.

In our example we have used the Bubble visualisation

{{< image "quick-start-guide/dashboard/008_visualisation_settings_basic.png" >}}Visualisation settings - basic{{< /image >}}

{{< image "quick-start-guide/dashboard/009_visualisation_settings_data.png" >}}Visualisation settings data{{< /image >}}

Which gives us this visualisation when the query is executed

{{< image "quick-start-guide/dashboard/010_visualisation_bubbles.png" >}}Bubble visualisation{{< /image >}}

Where you can hover over elements and get a summary of that representation.

{{< image "quick-start-guide/dashboard/011_visualisation_bubbles_legend.png" >}}Bubble visualisation legends{{< /image >}}
