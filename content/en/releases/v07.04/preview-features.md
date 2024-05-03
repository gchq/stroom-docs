---
title: "Preview Features (experimental)"
linkTitle: "Preview Features"
weight: 20
date: 2024-02-29
tags: 
description: >
  Preview features in Stroom version 7.4.
  Preview features are somewhat experimental in nature and are therefore subject to breaking changes in future releases.
---

## Analytic Rules

Analytic Rules were introduced in Stroom v7.2 as a preview feature.
They remain an experimental preview feature but have undergone more changes/improvements.

Analytic rules are a means of writing a query to find matching data.


### Processing Types

Analytic rules have three different processing types:

#### Streaming

A streaming rule uses a processor filter to find streams that match the filter and runs the query against the stream.


#### Scheduled Query

A scheduled query will run the rule's query against a time window of data on a scheduled basis.
The time window can be absolute or relative to when the scheduled query fires.


#### Table Builder

{{% todo %}}
Complete
{{% /todo %}}


### Multiple Notifications

Rules now support having multiple notification types/destinations, for example sending an email as well a {{< glossary "stream" >}}.
Currently Email and Stream are the only notification types supported.


### Email Templating

The email notifications have been improved to allow templating of the email subject and body.
The template enables static text/HTML to be mixed with values taken from the detection.

{{< image "releases/07.04/email-notifications.png" "300x" >}}Email notification settings.{{< /image >}}

The templating uses a template syntax called _jinja_ and specifically the JinJava library.
The templating syntax includes support for variables, filters, condition blocks, loops, etc.
Full details of the syntax see [Templating]({{< relref "docs/reference-section/templating" >}}) and for details of the templating context available in email subject/body templates see [Rule Detections Context]({{< relref "docs/reference-section/templating#rule-detections-context" >}}).


#### Example Template

The following is an example of a detection template producing a HTML email body that includes conditions and loops:

```html
<!DOCTYPE html>
<html lang="en">
<meta charset="UTF-8" />
<title>Detector '{{ detectorName | escape }}' Alert</title>
<body>
  <p>Detector <em>{{ detectorName | escape }}</em> {{ detectorVersion | escape }} fired at {{ detectTime | escape }}</p>

  {%- if (values | length) > 0 -%}
  <p>Detail: {{ headline | escape }}</p>
  <ul>
    {% for key, val in values | dictsort -%}
      <li><strong>{{ key | escape }}</strong>: {{ val | escape }}</li>
    {% endfor %}
  </ul>
  {% endif -%}

  {%- if (linkedEvents | length) > 0 -%}
  <p>Linked Events:</p>
  <ul>
    {% for linkedEvent in linkedEvents -%}
      <li>Environment: {{ linkedEvent.stroom | escape }}, Stream ID: {{ linkedEvent.streamId | escape }}, Event ID: {{ linkedEvent.eventId | escape }}</li>
    {% endfor %}
  </ul>
  {% endif %}
</body>
```


### Improved Date Picker

Scheduled queries make use of a new data picker dialog which makes the process of setting a date/time value much easier for the user.
This new date picker will be rolled out to other screens in Stroom in some later release.

{{< image "releases/07.04/date-picker.png" "300x" >}}New date picker{{< /image >}}

