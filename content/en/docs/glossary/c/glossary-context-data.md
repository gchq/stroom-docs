---
title: "Context data"
linkTitle: "Context data"
description: >
  This is an additional stream of contextual data that is sent along side the main event stream.
  It provides a means for the sending system to send additional data that relates only to the event stream it is sent alongside.
---

This can be useful where the sending system has no control over the data in the event stream and the event stream does not contain contextual information such as what machine it is running on or the location of that machine.

The contextual information (such as hostname, FQDN, physical location, etc.) can be sent in a Context Stream so that the two can be combined together during pipeline processing using `stroom:lookup()`.

{{% see-also %}}
* [Context Data]({{< relref "context-data" >}})
* [Stream Concepts]({{< relref "docs/user-guide/concepts/streams" >}})
* [`stroom:lookup()`]({{< relref "docs/user-guide/pipelines/xslt/xslt-functions#lookup" >}})
{{% /see-also %}}

