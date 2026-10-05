---
title: "Breaking Changes"
linkTitle: "Breaking Changes"
weight: 30
date: 2026-03-18
tags: 
description: >
  Changes in Stroom version 7.12 that may break existing processing or ways of working.
---

{{% warning %}}
Please read this section carefully in case any of the changes affect you.
{{% /warning %}}


## Stroom

No Stroom specific breaking changes.


## Stroom-Proxy

No Stroom-Proxy specific breaking changes.


## Stroom & Stroom-Proxy

The following breaking changes are common to both Stroom and Stroom Proxy.


### Data Feed Keys

The property `.receive.dataFeedKeysDir` has been renamed to `.receive.dataFeedIdentitiesDir`.

The required structure of the files in this directory has changed.
See [Data Feed Identities]({{< relref "docs/user-guide/data-receipt/data-feed-identities" >}}) for more details.


