---
title: "Internal Links"
linkTitle: "Internal Links"
weight: 50
date: 2024-05-02
tags: 
  - link
description: >
  Adding links within Stroom to internal items or external URLs.
---

Within Stroom links can be created in dashboard tables or dashboard text panes that will direct Stroom to display an item in various ways.

Links are inserted in the form:
```clike
[Link Text](URL and parameters){Link Type}
```

In dashboard tables links can be inserted using the [`link()`]({{< relref "expressions/link#Link" >}}) function or more specialised functions such as [`data()`]({{< relref "expressions/link#Data" >}}) or [`stepping()`]({{< relref "expressions/link#Stepping" >}}).

In dashboard text panes, links can be inserted into the HTML as `link` attributes on elements. Note that the text pane must be set to `Show As HTML`.

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

Dialog links are used to embed any referenced URL in a Stroom popup Dialog. Dialog links look something like this in HTML:

```html
<div style="padding: 5px;">
    <span style="text-decoration:underline;color:blue;cursor:pointer" 
          link="[Show](localhost:8080){dialog|Embedded In Stroom}">
        Show In Stroom Dialog
    </span>
</div>
```

Note that the dialog title can be controlled by adding a `|` and required title after the type, e.g.
```clike
{dialog|Embedded In Stroom}
```

## Tab

Tab links are similar to dialog links are used to embed any referenced URL in a Stroom tab. Tab links look something like this in HTML:

```html
<div style="padding: 5px;">
    <span style="text-decoration:underline;color:blue;cursor:pointer" 
          link="[Show](localhost:8080){tab|Embedded In Stroom}">
        Show In Stroom Tab
    </span>
</div>
```

Note that the tab title can be controlled by adding a `|` and required title after the type, e.g.
```clike
{tab|Embedded In Stroom}
```

## Browser

Browser links are used to open any referenced URL in a new browser tab. In most cases this is easily accomplished via a normal hyperlink but Stroom also provides a mechanism to do this as a link event so that dashboard tables are able to open new browser tabs. Again this can be accomplished by using the [`link()`]({{< relref "expressions/link#Link" >}}) table function but in HTML this might look like:

```html
<div style="padding: 5px;">
    <span style="text-decoration:underline;color:blue;cursor:pointer" 
          link="[Show](localhost:8080){browser}">
        Show In Browser Tab
    </span>
</div>
```

Note that unlike the other link types there is no way to control the browser tab title.

## Dashboard

Instead of viewing/embedding external URLs Stroom links can be used to direct Stroom to show an internal page. The dashboard link type allows Stroom to open a new tab and show a dashboard with the specified parameters. The format for a dashboard link is as follows:

```clike
[Link Text](uuid=<UUID>&params=<PARAMS>&title=<CUSTOM_TITLE>){dashboard}
```

An example of this type of link in HTML:

```html
<div style="padding: 5px;">
    <span style="text-decoration:underline;color:blue;cursor:pointer" 
          link="[link](uuid=e177cf16-da6c-4c7d-a19c-09a201f5a2da&amp;params=user%3Duser1&amp;title=Details%20For%20user1){dashboard}">
        Details For user1
    </span>
</div>
```

Note that using a pipeline with the appropriate XSLT it is possible to dynamically generate links in dashboard text panes that will be specific to the data being displayed.

## Stepping

A stepping link can be used to launch the data stepping feature with the specified data. The format for a stepping link is as follows:

```clike
[Link Text](id=<STREAM_ID>&partNo=<PART_NO>&recordNo=<RECORD_NO>){stepping}
```

An example of this type of link in HTML:

```html
<div style="padding: 5px;">
    <span style="text-decoration:underline;color:blue;cursor:pointer" 
          link="[link](id=1822&amp;partNo=1&amp;recordNo=1){stepping}">
        Step Source</span>
</div>
```

## Data

A link can be used to display a specific portion of the data held by Stroom using a data link. The format for a data link is as follows:

```clike
[Link Text](id=<STREAM_ID>&partNo=<PART_NO>&recordNo=<RECORD_NO>&lineFrom=<LINE_FROM>&colFrom=<COL_FROM>&lineTo=<LINE_TO>&colTo=<COL_TO>){data}
```

The parameters for data links are as follows:
* id - The id of the stream to display.
* partNo - The sub part no within the stream to display (usually 1).
* recordNo - The record or event number within the stream to display.
* viewType - Which type of data display to show, `preview` (default), or `source`.
* displayType - Choose whether to display the data in a `dialog` (default), or Stroom `tab`.
* lineFrom, colFrom, lineTo, colTo - In `preview` mode limit the data displayed to the specified selection. In `source` mode highlight the selection. 

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

## Annotation
A link can be used to edit or create annotations. To view or edit an existing annotation the id must be known or one can be found using a stream and event id. If all parameters are specified an annotation will either be created or edited depending on whether it exists or not. The format for an annotation link is as follows:

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
