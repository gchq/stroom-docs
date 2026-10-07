---
title: "String Functions"
linkTitle: "String Functions"
#weight:
date: 2025-09-25
tags: 
description: >
  Functions for string parsing and manipulation. 
---

<!-- 
The xslt-func shortcode outputs all the XsltFunctionDef annotation content for the function.
You can add any additional content for the function (e.g. examples) underneath the shortcode call.
-->

## link

{{< xslt-func "link" >}}


### Examples

```text
link('https://www.somehost.com/somepath')
> [https://www.somehost.com/somepath](https://www.somehost.com/somepath)

link('Click Here','https://www.somehost.com/somepath')
> [Click Here](https://www.somehost.com/somepath)

link('Click Here','https://www.somehost.com/somepath', 'dialog')
> [Click Here](https://www.somehost.com/somepath){dialog}

link('Click Here','https://www.somehost.com/somepath', 'dialog|Dialog Title')
> [Click Here](https://www.somehost.com/somepath){dialog|Dialog Title}
```

Type can be one of:
* `dialog` : Display the content of the link URL within a stroom popup dialog.
* `tab` : Display the content of the link URL within a stroom tab.
* `browser` : Display the content of the link URL within a new browser tab.
* `dashboard` : Used to launch a stroom dashboard internally with parameters in the URL.
* `stepping` : Opens the stepper using the parameters in the URL.
* `browser` : Opens a new browser tab.
* `annotation` : Opens (and creates) the annotation using the URL parameters.

If you wish to override the default title or URL of the target link in either a tab or dialog you can.
Both `dialog` and `tab` types allow titles to be specified after a `|`, e.g. `dialog|My Title`.
