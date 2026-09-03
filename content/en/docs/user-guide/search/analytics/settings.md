---
title: "Rule Settings"
linkTitle: "Settings"
weight: 15
date: 2026-09-03
tags:
  - analytic
description: >
  What a rule declares about itself, whether its documentation is included in detections, and where its errors go.
---

The _Settings_ tab holds the settings that describe the rule itself, rather than its query, its schedule or the notifications it sends.


## Level and Status

Field  | Description
------ | ------------
Level  | The severity of the rule.
Status | How reliable the rule is.

Neither is mandatory.
A rule that sets neither produces detections without them, which is how every rule created before these settings existed behaves.

Both are written to every detection the rule produces, whatever its processing type, and both are available to notification email templates as `{{ level }}` and `{{ status }}`.

_Level_ describes how urgent a detection from this rule is, so that whoever receives it can prioritise.

Level    | Meaning
-------- | --------
Low      | Little urgency. Worth recording, but not worth interrupting anyone for.
Medium   | Ordinary priority.
High     | Should be looked at ahead of lower level detections.
Critical | The most urgent. Reserve it, or it stops meaning anything.

_Status_ describes how much the rule can be trusted, which tells an analyst how much weight to give a detection and how many false positives to expect.

Status       | Meaning
------------ | --------
Experimental | An early-stage rule that may be incomplete. Expect more false positives.
Testing      | More mature than an experimental rule. Actively being validated in real environments. Expect some false positives.
Stable       | Considered production-ready. Has been thoroughly tested across multiple environments. Expect a reasonable false positive rate.
Deprecated   | An outdated or superseded rule that may rely on old techniques or assumptions. Generally avoid using these in production.

{{% note %}}
_Level_ and _Status_ describe the rule, not the individual detection, so every detection a rule produces carries the same values.
Raising the level of a rule affects only the detections it produces from that point on.
{{% /note %}}


## Include Rule Documentation

Field                      | Description
-------------------------- | ------------
Include Rule Documentation | Whether the rule's documentation is included in the detections it produces.

The content of the rule's _Documentation_ tab is written to each detection as `detailedDescription`, which means it leaves Stroom with the detection, for example by email.
Untick this where the documentation is for whoever maintains the rule rather than for whoever receives its detections.

{{% see-also %}}
[How a Detection is Built]({{< relref "detections#how-a-detection-is-built" >}})
{{% /see-also %}}


## Feed for Errors

Field           | Description
--------------- | ------------
Feed For Errors | The {{< glossary "Feed" >}} that errors occurring during execution are written to. Use _Set Default_ to use the feed configured for the system.

{{% see-also %}}
[Error Feed]({{< relref "execution#error-feed" >}})
{{% /see-also %}}


## Reports

A [Report]({{< relref "docs/user-guide/search/reports" >}}) {{< stroom-icon "document/Report.svg" >}} has a _Settings_ tab of its own, holding _Feed For Errors_ along with the settings that decide what kind of file it produces.

A report has no _Level_, _Status_ or _Include Rule Documentation_, because it delivers a file rather than detections.

{{% see-also %}}
[Report Settings]({{< relref "docs/user-guide/search/reports/settings" >}})
{{% /see-also %}}
