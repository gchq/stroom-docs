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

On the query pane click the settings {{< stroom-icon name="settings.svg" title="Dashboard settings" colour="grey"  >}} button on the top right of the panel.

{{< image "quick-start-guide/dashboard/002_dashboard_query_settings.png" "350" >}}Dashboard settings{{< /image >}}

1. Click on the _Data Source_ document picker.
1. Select the index you created earlier:  
   {{< stroom-icon "folder.svg">}} _Stroom 101_ / {{< stroom-icon "document/Index.svg">}} _Stroom 101_

{{% note %}}
Dashboards can be made to automatically run all queries when they are opened and/or to keep refreshing the query every N seconds.
This can be done in the Query settings dialog you used above.
{{% /note %}}


## Configuring the query expression

Now add a term to the query to filter the data.

1. Right click on the root AND operator and click {{< stroom-icon "add.svg" "Add Term" >}} Add Term.
  A new expression is added to the tree as a child of the operator and it has three dropdowns in it ({{< glossary "Field" >}}, {{< glossary "Condition" >}} and value).
1. Create an expression term for the _Application_ field:
    1. Field: `Application`
    1. Condition: `=`
    1. Value: `*b*`

This will find any records with `b` in the _Application_ field value.


## Configuring the table

All fields are [stored]({{< relref "/docs/user-guide/indexing/lucene#stored-fields" >}}) in our index so we do not need to worry about configuring {{< glossary "Search Extraction" >}}.

We first need to add some columns to our table.
Using the {{< stroom-icon "add.svg" "Add Field">}} button on the Table pane, add the following columns to the table.
We want a count of records grouped by _Application_.

* _Application_
* _Count_

{{% note %}}
_Count_ is a special column (not in the index) that applies the aggregate function `count()`.
All columns are actually just an expression which may be a simple field like `${Application}` or a function.
Stroom has a rich library of functions for aggregating and mutating query results.
See [Expressions]({{< relref "/docs/reference-section/expressions" >}}).
{{% /note %}}

To group our data by _Application_ we need to apply a group level to the _Application_ column.

1. Click on the _Application_ column
1. Click  
   {{< stroom-icon "fields/group.svg">}} _Group_ => {{< stroom-icon "fields/group.svg">}} _Level 1_

Now we can reverse sort the data in the table by the count.

1. Click on the _Count_ column.
1. Click  
   {{< stroom-icon "fields/sort-ascending.svg">}} _Sort_ => {{< stroom-icon "fields/sort-descending.svg">}} _Sort Z to A_

Now click the large green and white play button to run the query.
You should see 15 _Applications_ and their counts returned in the table.

Now we are going to add a custom column to show the lowest EventId for each _Application_ group.

1. Click on the {{< stroom-icon "add.svg" "Add Field">}} button on the Table pane.
1. Select _Custom_ (at the bottom of the list).
1. Click on the new _Custom_ column.
1. Click  
   {{< stroom-icon "fields/expression.svg">}} _Expression_
1. In the _Set Expression For 'Custom'_ dialog enter the following:  
   `first(${EventId})`
1. Click _OK_.

Instead of typing out the expression you can use the {{< stroom-icon "function.svg">}} and {{< stroom-icon "field.svg">}} buttons to pick from a list to add expressions and fields respectively.
You can also use {{< key-bind "ctrl,space" >}} to auto-complete your expressions.

To rename the _Custom_ column:

1. Click on the _Custom_ column.
1. Click  
   {{< stroom-icon "edit.svg" "Rename">}} _Rename_
1. Enter the text `First Event ID`.
1. Clico _OK_.

Now run the query again to see the results with the added column.

 
## Add a visualisation

We will add a new pane to the dashboard to display a {{< glossary "Visualisation" >}}.

1. Click on the {{< stroom-icon "add.svg" "Add Component">}} button at the top left of the Dashboard.
1. Select Visualisation.

A new empty _Visualisation_ pane will be added at the bottom of the Dashboard.

To configure the visualisation:

1. Click on the {{< stroom-icon name="settings.svg" title="Settings" colour="grey"  >}} button at the top right of the _Visualisation_ pane.
1. In the _Visualisation_ document picker select  
   {{< stroom-icon "folder.svg">}} _Visualisations_ / {{< stroom-icon "folder.svg">}} _Version3_ / {{< stroom-icon "document/Visualisation.svg" >}} _Bubble_
1. Click _OK_.
1. On the _Data_ tab that has now appeared in the dialog, assign the following table fields to the visualisation:
   1. _Name_: `Application`
   1. _Value_: `Count`
   1. _Series_: `Application`
1. On the _Bubble_ tab on the dialog, set the following:
   1. _Show Labels_: `True`
1. Click _OK_.

To change the look of your Dashboard you can drag the different panes around into different positons.

1. Click and hold on the `Visualisation` text in the top left of the _Visualisation_ pane.
1. Drag the cursor to the right hand side of the _Table_ pane.
   You will see a purple rectangle showing where the pane will be moved to.
1. Once you are happy with the position release the mouse button.
1. Click and hold the mouse button on the borders between the panes to resize the panes to suit.
1. Click {{< stroom-icon "save.svg" >}} to save the Dashboard.

You should now see something like this:

{{< image "quick-start-guide/dashboard/010_visualisation_bubbles.png" "400" >}}Bubble visualisation{{< /image >}}
