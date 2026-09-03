---
title: "Table Builder Rules"
linkTitle: "Table Builder"
weight: 70
date: 2026-09-02
tags:
  - analytic
description: >
  An experimental processing type that should not be used.
---

{{% warning %}}
_Table Builder_ is experimental and should not be used.
The in-product help says the same, and the job that runs these rules is disabled by default.

It is documented here only so that anyone who encounters an existing Table Builder rule can recognise what it is.
Use a [Scheduled Query]({{< relref "_index#scheduled-query" >}}) or a [Streaming]({{< relref "streaming" >}}) rule instead.
{{% /warning %}}

A Table Builder rule builds and maintains its own table of data from the streams it processes, and raises detections from that table.
The table is held in shards on the processing node, separately from the rest of Stroom's data.

The rule's _Shards_ tab, which is only shown for this processing type, lists those shards and lets you look at what they contain.


## Settings

Field                         | Description
----------------------------- | ------------
Enabled                       | Whether the rule is processed.
Processing Node               | The node that builds the table.
Min Stream Create Time        | The earliest stream creation time to process.
Max Stream Create Time        | The latest stream creation time to process.
Aggregation Period            | How long to wait for data before processing it.
Time To Keep Data In The Table | How long data is retained in the rule's table.
Processing Info               | A read only summary of what the rule has processed.
