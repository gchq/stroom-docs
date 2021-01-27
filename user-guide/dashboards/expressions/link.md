# Link Functions

<!-- vim-markdown-toc GFM -->

* [Annotation](#annotation)
* [Dashboard](#dashboard)
* [Data](#data)
* [Link](#link)
* [Stepping](#stepping)

<!-- vim-markdown-toc -->

## Annotation
A helper function to make forming links to annotations easier than using [Link](#link).
The Annotation function allows you to create a link to open the Annotation editor, either to view an existing annotation or to begin creating one with pre-populated values.

```
annotation(text, annotationId)
annotation(text, annotationId, [streamId, eventId, title, subject, status, assignedTo, comment])
```

If you provide just the _text_ and an _annotationId_ then it will produce a link that opens an existing annotation with the supplied ID in the Annotation Edit dialog.

Example
```
annotation('Open annotation', ${annotation:Id})
> [Open annotation](?annotationId=1234){annotation}
```

If you don't supply an _annotationId_ then the link will open the Annotation Edit dialog pre-populated with the optional arguments so that an annotation can be created.
If the _annotationId_ is not provided then you must provide a _streamId_ and an _eventId_.
If you don't need to pre-populate a value then you can use `''` or `null()` instead.

Example
```
annotation('Create suspect event annotation', null(), 123, 456, 'Suspect Event', null(), 'assigned', 'jbloggs')
> [Create suspect event annotation](?streamId=123&eventId=456&title=Suspect%20Event&assignedTo=jbloggs){annotation}
```

## Dashboard
A helper function to make forming links to dashboards easier than using [Link](#link).
```
dashboard(text, uuid)
dashboard(text, uuid, params)
```

Example
```
dashboard('Click Here','e177cf16-da6c-4c7d-a19c-09a201f5a2da')
> [Click Here](?uuid=e177cf16-da6c-4c7d-a19c-09a201f5a2da){dashboard}
dashboard('Click Here','e177cf16-da6c-4c7d-a19c-09a201f5a2da', 'userId=user1')
> [Click Here](?uuid=e177cf16-da6c-4c7d-a19c-09a201f5a2da&params=userId%3Duser1){dashboard}
```

## Data
Creates a link to open a source for data for viewing.

```
data(id, partNo, [recordNo, lineFrom, colFrom, lineTo, colTo, viewType, displayType])
```

_viewType_ can be one of:
* `preview` : Display the data as a formatted preview of a limited portion of the data.
* `source` : Display the un-formatted data in its original form with the ability to navigate around all of the data source.

_displayType_ can be one of:
* `dialog` : Open as a modal popup dialog.
* `tab` : Open as a top level tab within the Stroom browser tab.

## Link
Create a string that represents a hyperlink for display in a dashboard table.
```
link(url)
link(text, url)
link(text, url, type)
```

Example
```
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
Open the _Stepping_ tab for the requested data source.

```
stepping(id)
stepping(id, partNo)
stepping(id, partNo, recordNo)
```


