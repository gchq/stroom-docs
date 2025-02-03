---
title: "Breaking Changes"
linkTitle: "Breaking Changes"
weight: 30
date: 2025-01-30
tags: 
description: >
  Changes in Stroom version 7.8 that may break existing processing or ways of working.
---

{{% warning %}}
Please read this section carefully in case any of the changes affect you.
{{% /warning %}}

## Stroom

#### Service Discovery

See [Configuration File Changes (Service Discovery)]({{< relref "./upgrade-notes#service-discovery" >}}).


## Stroom-Proxy

The new implementation of Stroom-Proxy is not compatible with previous versions.
It uses a different structure for its local repository.
Therefor you **CANNOT** deploy Stroom-Proxy v7.8 on top of a previous Stroom-Proxy version as it will be unable to process existing stored data that has not yet been forwarded.

You have two options:

1. Run the old and new in parallel until the old one has processed all its data, then shutdown and uninstall the old one.

1. Prevent data going to the old Stroom-Proxy and allow it to process all its data.
   Shut it down and remove the installation.
   Install the new v7.8 Stroom-Proxy.
   Allow data to flow in again.

