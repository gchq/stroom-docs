# Link Functions

## Dashboard
A helper function to make forming links to dashboards easier than using [Link](#link).
```
dashboard(text, uuid)
dashboard(text, uuid, params)
```

Example
```
dashboard('Click Here','e177cf16-da6c-4c7d-a19c-09a201f5a2da')
> [Click Here](?uuid=e177cf16-da6c-4c7d-a19c-09a201f5a2da){dashboard)
dashboard('Click Here','e177cf16-da6c-4c7d-a19c-09a201f5a2da', 'userId=user1')
> [Click Here](?uuid=e177cf16-da6c-4c7d-a19c-09a201f5a2da&params=userId%3Duser1){dashboard)
```

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


