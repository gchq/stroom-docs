---
title: "Internal Links"
linkTitle: "Internal Links"
weight: 50
date: 2024-05-03
tags: 
  - link
description: >
  Adding links within Stroom to internal features/items or external URLs.
---

Within Stroom, links can be created in dashboard tables or dashboard text panes that will direct Stroom to display an item in various ways.

Links are inserted in the form:
```clike
[Link Text](URL and parameters){Link Type}
```

In dashboard tables links can be inserted using the [`link()`]({{< relref "expressions/link#link" >}}) function or more specialised functions such as [`data()`]({{< relref "expressions/link#data" >}}) or [`stepping()`]({{< relref "expressions/link#stepping" >}}).

In dashboard text panes, links can be inserted into the HTML as `link` attributes on elements.

{{% note %}}
The text pane must be set to `Show As HTML` for links to operate.
{{% /note %}}

```html
  <div style="padding: 5px;">
    <span style="text-decoration:underline;color:blue;cursor:pointer" link="[link](uuid=e177cf16-da6c-4c7d-a19c-09a201f5a2da&amp;params=user%3Duser1&amp;title=Details%20For%20user1){dashboard}">Details For user1</span>
  </div>
```

The link type can be one of the following:

* `dialog` : Display the content of a link URL within a stroom popup dialog.
* `tab` : Display the content of a link URL within a stroom tab.
* `browser` : Display the content of a link URL within a new browser tab.
* `dashboard` : Used to launch a Stroom dashboard internally with parameters in the URL.
* `stepping` : Used to launch Stroom stepping internally with parameters in the URL.
* `data` : Used to show Stroom data internally with parameters in the URL.
* `annotation` : Used to show a Stroom annotation internally with parameters in the URL.

## Dialog

Dialog links are used to embed any referenced URL in a Stroom popup Dialog.
Dialog links look something like this in HTML:

```html
<div style="padding: 5px;">
    <span style="text-decoration:underline;color:blue;cursor:pointer" 
          link="[Show](https://www.somehost.com/somepath){dialog|Embedded In Stroom}">
        Show In Stroom Dialog
    </span>
</div>
```

{{% note %}}
The dialog title can be controlled by adding a `|` and required title after the type, e.g.
{{% /note %}}

```clike
{dialog|Embedded In Stroom}
```

## Tab

Tab links are similar to dialog links are used to embed any referenced URL in a Stroom tab.
Tab links look something like this in HTML:

```html
<div style="padding: 5px;">
    <span style="text-decoration:underline;color:blue;cursor:pointer" 
          link="[Show](https://www.somehost.com/somepath){tab|Embedded In Stroom}">
        Show In Stroom Tab
    </span>
</div>
```

{{% note %}}
The tab title can be controlled by adding a `|` and required title after the type, e.g.
{{% /note %}}

```clike
{tab|Embedded In Stroom}
```

## Browser

Browser links are used to open any referenced URL in a new browser tab.
In most cases this is easily accomplished via a normal hyperlink but Stroom also provides a mechanism to do this as a link event so that dashboard tables are also able to open new browser tabs.
This can be accomplished by using the [`link()`]({{< relref "expressions/link#link" >}}) table function.
In a dashboard text pane the HTML could look like this:

```html
<div style="padding: 5px;">
    <span style="text-decoration:underline;color:blue;cursor:pointer" 
          link="[Show](https://www.somehost.com/somepath){browser}">
        Show In Browser Tab
    </span>
</div>
```

{{% note %}}
Unlike the other link types there is no way to control the browser tab title.
{{% /note %}}

## Dashboard

In addition to viewing/embedding external URLs, Stroom links can be used to direct Stroom to show an internal item or feature.
The `dashboard` link type allows Stroom to open a new tab and show a dashboard with the specified parameters.

The format for a dashboard link is as follows:

```clike
[Link Text](uuid=<UUID>&params=<PARAMS>&title=<CUSTOM_TITLE>){dashboard}
```

The parameters for dashboard links are:
* `uuid` - The UUID of the dashboard to open.
* `params` - A URL encoded list of params to supply to the dashboard, e.g. `params=user%3Duser1`.
* `title` - An optional URL encoded title to better identify the specific instance of the dashboard, e.g. `title=Details%20For%20user1`.

{{% note %}}
Parameter values can be URL encoded in XSLT using the `encode-for-uri` function.
{{% /note %}}

An example of this type of link in HTML:

```html
<div style="padding: 5px;">
    <span style="text-decoration:underline;color:blue;cursor:pointer" 
          link="[link](uuid=e177cf16-da6c-4c7d-a19c-09a201f5a2da&amp;params=user%3Duser1&amp;title=Details%20For%20user1){dashboard}">
        Details For user1
    </span>
</div>
```

{{% note %}}
By using a pipeline with the appropriate XSLT it is possible to dynamically generate links in dashboard text panes that will be specific to the data being displayed.
{{% /note %}}

## Data

A link can be created to open a sub-set of a source of data (i.e. part of a stream) for viewing.
The data can either be opened in a popup dialog (`dialog`) or in another stroom tab (`tab`).
It can also be display in `preview` form (with formatting and syntax highlighting) or unaltered `source` form.

{{% note %}}
To make full use of data links for viewing raw data, you need to use the `stroom:source()` [XSLT Function]({{< relref "docs/user-guide/pipelines/xslt/xslt-functions" >}}) to decorate an event with the details of the source location it derived from.
{{% /note %}}

The format for a data link is as follows:

```clike
[Link Text](id=<STREAM_ID>&partNo=<PART_NO>&recordNo=<RECORD_NO>&lineFrom=<LINE_FROM>&colFrom=<COL_FROM>&lineTo=<LINE_TO>&colTo=<COL_TO>&viewType=<VIEW_TYPE>&displayType=<DISPLAY_TYPE>){data}
```

Stroom deals in two main types of stream, segmented and non-segmented (see [Streams]({{< relref "docs/user-guide/concepts/streams" >}})).
Data in a non-segmented (i.e. raw) stream is identified by an `id`, a `partNo` and optionally line and column positions to define the sub-set of that stream part to display.
Data in a segmented (i.e. cooked) stream is identified by an `id`, a `recordNo` and optionally line and column positions to define the sub-set of that record (i.e. event) within that stream.

The parameters for data links are:
* `id` - The stream ID.
* `partNo` - The part number of the stream (one based).
  Always `1` for segmented (cooked) streams.
* `recordNo` - The record number within a segmented stream (optional).
  Not applicable for non-segmented streams so use `null()` instead.
* `lineFrom` - The line number of the start of the sub-set of data (optional, one based).
* `colFrom` - The column number of the start of the sub-set of data (optional, one based).
* `lineTo` - The line number of the end of the sub-set of data (optional, one based).
* `colTo` - The column number of the end of the sub-set of data (optional, one based).
* `viewType` - The type of view of the data (optional, defaults to `preview`):
    * `preview` : Display the data as a formatted preview of a limited portion of the data.
    * `source` : Display the un-formatted data in its original form with the ability to navigate around all of the data source.
* `displayType` - The way of displaying the data (optional, defaults to `dialog`):
    * `dialog` : Open as a modal popup dialog.
    * `tab` : Open as a top level tab within the Stroom browser tab.

In `preview` mode the line and column positions will limit the data displayed to the specified selection.
In `source` mode the line and column positions define a highlight block of text within the part/record.

{{% warning %}}
The `displayType` value `tab` is not supported if the dashboard is viewed via a [Direct URL]({{< relref "direct-urls" >}}).
This is because a direct URL displays only the dashboard without Stroom's top level tab bar so it is not possible to open it as a top level tab.
{{% /warning %}}

An example of this type of link in HTML:

```html
<div style="padding: 5px;">
    <span style="text-decoration:underline;color:blue;cursor:pointer" 
          link="[link](id=1822&amp;partNo=1&amp;recordNo=1){data}">
        Show Source</span>
</div>
```

### View Type
The additional parameter `viewType` can be used to switch the data view mode from `preview` (default) to `source`.

In preview mode the optional parameters `lineFrom`, `colFrom`, `lineTo`, `colTo` can be used to limit the portion of the data that is displayed.

```html
<div style="padding: 5px;">
    <span style="text-decoration:underline;color:blue;cursor:pointer" 
          link="[link](id=1822&amp;partNo=1&amp;recordNo=1&amp;viewType=preview&amp;lineFrom=1&amp;colFrom=1&amp;lineTo=10&amp;colTo=8){data}">
        Show Source Preview
    </span>
</div>
```

In source mode the optional parameters `lineFrom`, `colFrom`, `lineTo`, `colTo` can be used to highlight a portion of the data that is displayed.

```html
<div style="padding: 5px;">
    <span style="text-decoration:underline;color:blue;cursor:pointer" 
          link="[link](id=1822&amp;partNo=1&amp;recordNo=1&amp;viewType=source&amp;lineFrom=1&amp;colFrom=1&amp;lineTo=10&amp;colTo=8){data}">
        Show Source
    </span>
</div>
```

### Display Type
Choose whether to display data in a `dialog` (default) or a Stroom `tab`.

## Stepping

A stepping link can be used to launch the data stepping feature with the specified data.
The format for a stepping link is as follows:

```clike
[Link Text](id=<STREAM_ID>&partNo=<PART_NO>&recordNo=<RECORD_NO>){stepping}
```

The parameters for stepping links are as follows:
* id - The id of the stream to step.
* partNo - The sub part no within the stream to step (usually 1).
* recordNo - The record or event number within the stream to step.

An example of this type of link in HTML:

```html
<div style="padding: 5px;">
    <span style="text-decoration:underline;color:blue;cursor:pointer" 
          link="[link](id=1822&amp;partNo=1&amp;recordNo=1){stepping}">
        Step Source</span>
</div>
```

## Annotation
A link can be used to edit or create annotations.
To view or edit an existing annotation the id must be known or one can be found using a stream and event id.
If all parameters are specified an annotation will either be created or edited depending on whether it exists or not.
The format for an annotation link is as follows:

```clike
[Link Text](annotationId=<ANNOTATION_ID>&streamId=<STREAM_ID>&eventId=<EVENT_ID>&title=<TITLE>&subject=<SUBJECT>&status=<STATUS>&assignedTo=<ASSIGNED_TO>&comment=<COMMENT>){annotation}
```

The parameters for annotation links are as follows:
* annotationId - The optional existing id of an annotation if one already exists.
* streamId - An optional stream id to link to a newly created annotation, or used to lookup an existing annotation if no annotation id is provided.
* eventId - An optional event id to link to a newly created annotation, or used to lookup an existing annotation if no annotation id is provided.
* title - An optional default title to give the annotation if a new one is created.
* subject - An optional default subject to give the annotation if a new one is created.
* status - An optional default status to give the annotation if a new one is created.
* assignedTo - An optional initial assignedTo value to give the annotation if a new one is created.
* comment - An optional initial comment to give the annotation if a new one is created.
