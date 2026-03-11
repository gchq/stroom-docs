---
title: "Breaking Changes"
linkTitle: "Breaking Changes"
weight: 30
date: 2026-01-12
tags: 
description: >
  Changes in Stroom version 7.11 that may break existing processing or ways of working.
---

{{% warning %}}
Please read this section carefully in case any of the changes affect you.
{{% /warning %}}


## Stroom

Breaking changes relating to Stroom.

### Import of Legacy Content

Stroom v7.11 is no longer able to import content that has been exported from a v5/v6 Stroom.
Any such content will have to be imported into Stroom v7.10 or lower then exported for import into Stroom v7.11.


### Elastic Configuration

The property `stroom.elastic.retention.scrollSize` has been removed.
See [Upgrade Notes]({{< relref "upgrade-notes#removed-elastic-property" >}}).


## Stroom-Proxy

Breaking changes relating to Stroom Proxy.


### Feed Status Check Configuration

Various properties have been removed from the `proxyConfig.feedStatus` configuration branch.
See [Upgrade Notes]({{< relref "upgrade-notes#remove-various-feedstatus-properties" >}}).


### Content Sync Configuration

The whole `contentSync` branch has been removed as it is no longer in use.
See [Upgrade Notes]({{< relref "upgrade-notes#removed-contentsync" >}}).


## Stroom & Stroom-Proxy

Breaking changes that are common to both Stroom and Stroom Proxy.


### Receive Configuration

The property `receiptPolicyUuid` has been removed.
See [Upgrade Notes]({{< relref "upgrade-notes#removed-property-proxyconfigreceivereceiptpolicyuuid" >}}).
