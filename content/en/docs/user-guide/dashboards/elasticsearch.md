---
title: "Elasticsearch"
linkTitle: "Elasticsearch"
#weight:
date: 2022-12-15
tags:
  - search
  - elastic
  - kibana
description: >
  Searching an Elasticsearch index using a Stroom dashboard
---


## Searching using a Stroom dashboard

Searching an Elasticsearch index (or data stream) using a Stroom dashboard is conceptually similar to the process described in [Dashboards]({{< relref "../../quick-start-guide/dashboard/" >}}).

Before you set the dashboard's data source, you must first create an Elastic Index document to tell Stroom which index (or indices) you wish to query.


### Create an Elastic Index document

1. Right-click a folder in the Stroom Explorer pane ({{< stroom-icon "folder-tree.svg" "Explorer" >}}).
1. Select:  
   {{< stroom-menu "New" "Elastic Index" >}}
1. Enter a name for the index document and click {{< stroom-btn "OK" >}}.
1. Click {{< stroom-icon "ellipses-grey.svg" "Ellipsis" >}} next to the `Cluster configuration` field label.
1. In the dialog that appears, select the Elastic Cluster document where the index exists, and click {{< stroom-btn "OK" >}}.
1. Enter the name of an index or data stream in `Index name or pattern`.
   Data view (formerly known as *index pattern*) {{< external-link "syntax" "https://www.elastic.co/guide/en/kibana/current/data-views.html#settings-create-pattern" >}} is supported, which enables you to query multiple indices or data streams at once.
   For example: `stroom-events-v1`.
1. (Optional) Set `Search slices`, which is the number of parallel workers that will query the index.
   For very large indices, increasing this value up to and including the number of shards can increase scroll performance, which will allow you to download results faster.
1. (Optional) Set `Search scroll size`, which specifies the number of documents to return in each search response.
   Greater values generally increase efficiency.
   By default, Elasticsearch limits this number to `10,000`.
1. Click `Test Connection`.
   A dialog will appear with the result, which will state `Connection Success` if the connection was successful and the index pattern matched one or more indices.
1. Click {{< stroom-icon "save.svg" "Save" >}}.


### Set the Elastic Index document as the dashboard data source

1. Open or create a dashboard.
1. Click {{< stroom-icon "settings.svg" "Settings" >}} in the `Query` panel.
1. Click {{< stroom-icon "ellipses-grey.svg" "Ellipsis" >}} next to the `Data Source` field label.
1. Select the Elastic Index document you created and click {{< stroom-btn "OK" >}}.
1. Configure the query expression as explained in [Dashboards]({{< relref "../../quick-start-guide/dashboard/#configuring-the-query-expression" >}}).
   Note the [tips]({{< relref "#query-expression-tips" >}}) for particular Elasticsearch field mapping data types.
1. [Configure the table]({{< relref "../../quick-start-guide/dashboard/#configuring-the-table" >}}).


## Query expression tips

Certain Elasticsearch field mapping types support special syntax when used in a Stroom dashboard query expression.

To identify the field mapping type for a particular field:

1. Click {{< stroom-icon "add.svg" "Add" >}} in the `Query` panel to add a new expression item.
1. Select the Elasticsearch field name in the drop-down list.
1. Note the blue data type indicator to the far right of the row.
   Common examples are: `keyword`, `text` and `number`.

After you identify the field mapping type, move the mouse cursor over the mapping type indicator.
A tooltip appears, explaining various types of queries you can perform against that particular field's type.


## Searching multiple indices

Using data view (index pattern) syntax, you can create powerful dashboards that query multiple indices at a time.
An example of this is where you have multiple indices covering different types of email systems.
Let's assume these indices are named: `stroom-exchange-v1`, `stroom-domino-v1` and `stroom-mailu-v1`.

There is a common set of fields across all three indices: `@timestamp`, `Subject`, `Sender` and `Recipient`.
You want to allow search across all indices at once, in effect creating a unified *email* dashboard.

You can achieve this by creating an Elastic Index document called (for example) `Elastic-Email-Combined` and setting the property `Index name or pattern` to: `stroom-exchange-v1,stroom-domino-v1,stroom-mailu-v1`.
Click {{< stroom-icon "save.svg" "Save" >}} and re-open the dashboard.
You'll notice that the available fields are a union of the fields across all three indices.
You can now search by any of these - in particular, the fields common to all three.
