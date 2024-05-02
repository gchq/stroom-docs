---
title: "Link Functions"
linkTitle: "Link Functions"
#weight:
date: 2021-07-27
tags: 
description: >
  Functions for linking to other screens in Stroom and/or to particular sets of data.
---

Links can be inserted into dashboard tables using the `link` function. Links behave as described in [Internal Links]({{< relref "../internal-links" >}}) and the `link` function is just a convenient way to add them to tables. In addition to the `link` function there are other functions such as `annotation`, `dashboard`, `data` and `stepping` that make it easier to supply the required link parameters.

## Annotation

{{% see-also %}}
[Annotation Links]({{< relref "../internal-links#Annotation" >}}).
{{% /see-also %}}

A helper function to make forming links to annotations easier than using [Link](#link).
The Annotation function allows you to create a link to open the Annotation editor, either to view an existing annotation or to begin creating one with pre-populated values.

```clike
annotation(text, annotationId)
annotation(text, annotationId, [streamId, eventId, title, subject, status, assignedTo, comment])
```

If you provide just the _text_ and an _annotationId_ then it will produce a link that opens an existing annotation with the supplied ID in the Annotation Edit dialog.

Example

```clike
annotation('Open annotation', ${annotation:Id})
> [Open annotation](?annotationId=1234){annotation}
annotation('Create annotation', '', ${StreamId}, ${EventId})
> [Create annotation](?annotationId=&streamId=1234&eventId=45){annotation}
annotation('Escalate', '', ${StreamId}, ${EventId}, 'Escalation', 'Triage required')
> [Escalate](?annotationId=&streamId=1234&eventId=45&title=Escalation&subject=Triage%20required){annotation}
```

If you don't supply an _annotationId_ then the link will open the Annotation Edit dialog pre-populated with the optional arguments so that an annotation can be created.
If the _annotationId_ is not provided then you must provide a _streamId_ and an _eventId_.
If you don't need to pre-populate a value then you can use `''` or `null()` instead.

Example

```clike
annotation('Create suspect event annotation', null(), 123, 456, 'Suspect Event', null(), 'assigned', 'jbloggs')
> [Create suspect event annotation](?streamId=123&eventId=456&title=Suspect%20Event&assignedTo=jbloggs){annotation}
```


## Dashboard

{{% see-also %}}
[Dashboard Links]({{< relref "../internal-links#Dashboard" >}}).
{{% /see-also %}}

A helper function to make forming links to dashboards easier than using [Link](#link).

```clike
dashboard(text, uuid)
dashboard(text, uuid, params)
```

Example

```clike
dashboard('Click Here','e177cf16-da6c-4c7d-a19c-09a201f5a2da')
> [Click Here](?uuid=e177cf16-da6c-4c7d-a19c-09a201f5a2da){dashboard}
dashboard('Click Here','e177cf16-da6c-4c7d-a19c-09a201f5a2da', 'userId=user1')
> [Click Here](?uuid=e177cf16-da6c-4c7d-a19c-09a201f5a2da&params=userId%3Duser1){dashboard}
```


## Data

{{% see-also %}}
[Data Links]({{< relref "../internal-links#Data" >}}).
{{% /see-also %}}

Creates a clickable link to open a sub-set of a source of data (i.e. part of a stream) for viewing.
The data can either be opened in a popup dialog (`dialog`) or in another stroom tab (`tab`).
It can also be display in `preview` form (with formatting and syntax highlighting) or unaltered `source` form.

```clike
data(text, id, partNo, [recordNo, lineFrom, colFrom, lineTo, colTo, viewType, displayType])
```

Stroom deals in two main types of stream, segmented and non-segmented (see [Streams]({{< relref "docs/user-guide/concepts/streams" >}})).
Data in a non-segmented (i.e. raw) stream is identified by an `id`, a `partNo` and optionally line and column positions to define the sub-set of that stream part to display.
Data in a segmented (i.e. cooked) stream is identified by an `id`, a `recordNo` and optionally line and column positions to define the sub-set of that record (i.e. event) within that stream.

The line and column positions will define a highlight block of text within the part/record.

Arguments:

* `text` - The link text that will be displayed in the table.
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

{{% warning %}}
The `displayType` value `tab` is not supported if the dashboard is viewed via a [Direct URL]({{< relref "../direct-urls" >}}). This is because a direct URL displays only the dashboard without Stroom's top level tab bar so it is not possible to open it as a top level tab.
{{% /warning %}}

```clike
data('Quick View', ${StreamId}, 1)
> [Quick View]?id=1234&&partNo=1)
```

Example of non-segmented raw data section, viewed un-formatted in a stroom tab:

```clike
data('View Raw', ${StreamId}, ${partNo}, null(), 5, 1, 5, 342, 'source', 'tab')
```

Example of a single record (event) from a segmented stream, viewed formatted in a popup dialog:

```clike
data('View Cooked', ${StreamId}, 1, ${eventId})
```

Example of a single record (event) from a segmented stream, viewed formatted in a stroom tab:

```clike
data('View Cooked', ${StreamId}, 1, ${eventId}, null(), null(), null(), null(), 'preview', 'tab')
```

{{% note %}}
To make full use of the `data()` function foe viewing raw data, you need to use the `stroom:source()` [XSLT Function]({{< relref "docs/user-guide/pipelines/xslt/xslt-functions" >}}) to decorate an event with the details of the source location it derived from.
{{% /note %}}


## Link

{{% see-also %}}
[Internal Links]({{< relref "../internal-links" >}}).
{{% /see-also %}}

Create a string that represents a hyperlink for display in a dashboard table.

```clike
link(url)
link(text, url)
link(text, url, type)
```

Example

```clike
link('http://www.somehost.com/somepath')
> [http://www.somehost.com/somepath](http://www.somehost.com/somepath)
link('Click Here','http://www.somehost.com/somepath')
> [Click Here](http://www.somehost.com/somepath)
link('Click Here','http://www.somehost.com/somepath', 'dialog')
> [Click Here](http://www.somehost.com/somepath){dialog}
link('Click Here','http://www.somehost.com/somepath', 'dialog|Dialog Title')
> [Click Here](http://www.somehost.com/somepath){dialog|Dialog Title}
```

Type can be one of:

* `dialog` : Display the content of the link URL within a stroom popup dialog.
* `tab` : Display the content of the link URL within a stroom tab.
* `browser` : Display the content of the link URL within a new browser tab.
* `dashboard` : Used to launch a stroom dashboard internally with parameters in the URL.

If you wish to override the default title or URL of the target link in either a tab or dialog you can. Both `dialog` and `tab` types allow titles to be specified after a `|`, e.g. `dialog|My Title`.


## Stepping

{{% see-also %}}
[Stepping Links]({{< relref "../internal-links#Stepping" >}}).
{{% /see-also %}}

Open the _Stepping_ tab for the requested data source.

```clike
stepping(text, id)
stepping(text, id, partNo)
stepping(text, id, partNo, recordNo)
```

Example

```clike
stepping('Click here to step',${StreamId})
> [Click here to step](?id=1)
```
