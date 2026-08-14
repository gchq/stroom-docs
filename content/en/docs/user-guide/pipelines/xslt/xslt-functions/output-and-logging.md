---
title: "Output & Logging"
linkTitle: "Output & Logging"
weight: 70
date: 2026-08-14
tags:
  - xslt
description: >
  XSLT functions for output and logging.
---

## add-meta()

Add meta to be written to output destination.

```text
add-meta(String key, String value)
```


## link()

Create a string that represents a hyperlink for display in a dashboard table.

```
link(url)
link(title, url)
link(title, url, type)
```

Example

```
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

If you wish to override the default title or URL of the target link in either a tab or dialog you can.
Both `dialog` and `tab` types allow titles to be specified after a `|`, e.g. `dialog|My Title`.


## log()

The log() function writes a message to the processing log with the specified severity.
 Severities of INFO, WARN, ERROR and FATAL can be used.
 Severities of ERROR and FATAL will result in records being omitted from the output if a RecordOutputFilter is used in the pipeline.
 The counts for RecWarn, RecError will be affected by warnings or errors generated in this way therefore this function is useful for adding business rules to XML output.

E.g. Warn if a SID is not the correct length.

```xml
<xsl:if test="string-length($sid) != 7">
  <xsl:value-of select="stroom:log('WARN', concat($sid, ' is not the correct length'))"/>
</xsl:if>
```

The same functionality can also be achieved using the standard `xsl:message` element, see [`<xsl:message>`]({{< relref "xslt-basics#xslmessage" >}})
