---
title: "Rule Notifications"
linkTitle: "Notifications"
weight: 30
date: 2026-09-02
tags:
  - analytic
description: >
  Delivering detections to a feed or to people by email, and limiting how many notifications a rule can send.
---

The _Notifications_ tab decides what happens to the detections a rule raises.
Settings that describe the rule as a whole, such as what its detections contain, are on the [Settings]({{< relref "settings" >}}) tab instead.

The tab is a list of notifications.
A rule can have any number of notifications and each one is delivered independently.
A rule that both writes detections to a feed for later analysis and emails a few people about them has two notifications, not one.

Column     | Description
---------- | ------------
Enabled    | Whether this notification is delivered.
Type       | _Stream_ or _Email_.
Destination | The feed or email address that detections go to.
Limit      | Whether the number of notifications is limited.
Max        | The limit, where one is set.

{{% note %}}
A rule with no notifications at all will fail when it runs, because there is nowhere for its detections to go.
{{% /note %}}

Everything on this page applies to [Reports]({{< relref "docs/user-guide/search/reports" >}}) {{< stroom-icon "document/Report.svg" >}} as well, except that a report delivers a file rather than a detection.
The differences are covered in [Report Delivery]({{< relref "docs/user-guide/search/reports/delivery" >}}).


## Stream Destinations

A _Stream_ notification writes detections into a {{< glossary "Feed" >}} as XML conforming to the `detection:1` {{< glossary "XML Schema" >}}.
This is the right choice when detections are themselves data, to be indexed, searched, or fed into another rule.

Field                       | Description
--------------------------- | ------------
Destination Feed            | The feed the detections are written to. Use _Set Default_ to use the feed configured for the system.
Use Source Feed If Possible | Writes detections to the feed the source data came from rather than to the destination feed.

_Use Source Feed If Possible_ is useful for a [streaming]({{< relref "streaming" >}}) rule that runs across many feeds and whose detections are best kept alongside the data that produced them.

{{% note %}}
The option only applies to streaming rules, and is disabled for any other processing type.
A scheduled rule looks across many streams and so has no single source feed to write back to, and a rule that is not streaming always uses the _Destination Feed_.
{{% /note %}}

{{% see-also %}}
[Detections]({{< relref "detections" >}})
{{% /see-also %}}


## Email Destinations

An _Email_ notification sends each detection to people as an email.

Field                  | Description
---------------------- | ------------
To                     | Recipient addresses.
Cc                     | Addresses to copy.
Bcc                    | Addresses to copy without other recipients seeing.
Email Subject Template | A template for the subject line.
Email Body Template    | A template for the body.

Each field accepts more than one address.

{{% note %}}
Email will not work until an SMTP server has been configured for the installation.
The _from_ address and name also come from that configuration rather than from the rule.
See [Email Setup]({{< relref "docs/install-guide/setup/email-setup" >}}).
{{% /note %}}


### Templates

The subject and body are _Jinja_ templates rather than fixed text, so that each email can describe the detection that triggered it.

The values from the detection are put into the template context before the template is rendered, so `{{ detectTime }}` renders when the detection happened and `values.SourceIp` renders the value of the query's `SourceIp` column.

If the rendered body looks like HTML it is sent as an HTML email, otherwise it is sent as plain text.

{{% see-also %}}
[Templating]({{< relref "docs/reference-section/templating" >}})
[Rule Detections Context]({{< relref "docs/reference-section/templating#rule-detections-context" >}})
{{% /see-also %}}


### Testing

Two buttons let you check a template without waiting for a real detection.

* _Test Template_ renders the template against an example detection and shows you the result, including any errors in the template.
* _Send Test Email_ sends that example detection to the configured recipients, which also proves the SMTP configuration works.


## Limiting Notifications

A rule that suddenly matches far more data than expected can send a very large number of emails.
The limit settings exist to bound that.

Field                       | Description
--------------------------- | ------------
Limit Notifications         | Whether a limit applies.
Maximum Notifications       | How many notifications may be sent before this one stops.
Resume Notifications After  | How long to wait before allowing notifications again.

Once _Maximum Notifications_ have been sent the notification switches itself off and nothing further is delivered through it.
It comes back on when _Resume Notifications After_ has elapsed since the last notification was sent, at which point the count starts again from zero.

{{% warning %}}
Detections suppressed by a limit are discarded, not queued.
A rule that hits its limit will not deliver the detections it raised while switched off, even after it resumes.

Where the aim is to avoid being told the same thing repeatedly rather than to bound the volume, [Duplicate Management]({{< relref "duplicate-management" >}}) is usually the better tool, because it suppresses repeats of a detection you have already seen while still delivering new ones.
{{% /warning %}}

The count is held per notification and is not persisted, so restarting the node resets it.
