---
title: "Link Functions"
linkTitle: "Link Functions"
#weight:
date: 2021-07-27
tags: 
description: >
  Functions for linking to other screens in Stroom and/or to particular sets of data.
---

Links can be inserted into dashboard tables using the `link` function.
All link types described in [Internal Links]({{< relref "../internal-links" >}}) can be added to dashboard tables using the `link` function.
In addition to the `link` function there are convenience functions such as `annotation`, `dashboard`, `data` and `stepping` that make it easier to supply the required link parameters.

## Annotation

{{% see-also %}}
[Annotation Links]({{< relref "../internal-links#annotation" >}}).
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
[Dashboard Links]({{< relref "../internal-links#dashboard" >}}).
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
[Data Links]({{< relref "../internal-links#data" >}}).
{{% /see-also %}}

A helper function to make forming links to data easier than using [Link](#link).

```clike
data(text, id, partNo, [recordNo, lineFrom, colFrom, lineTo, colTo, viewType, displayType])
```

Example

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
link('https://www.somehost.com/somepath')
> [https://www.somehost.com/somepath](https://www.somehost.com/somepath)
link('Click Here','https://www.somehost.com/somepath')
> [Click Here](https://www.somehost.com/somepath)
link('Click Here','https://www.somehost.com/somepath', 'dialog')
> [Click Here](https://www.somehost.com/somepath){dialog}
link('Click Here','https://www.somehost.com/somepath', 'dialog|Dialog Title')
> [Click Here](https://www.somehost.com/somepath){dialog|Dialog Title}
```

## Stepping

{{% see-also %}}
[Stepping Links]({{< relref "../internal-links#stepping" >}}).
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
