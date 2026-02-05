---
title: "Breaking Changes"
linkTitle: "Breaking Changes"
weight: 30
date: 2025-04-01
tags: 
description: >
  Changes in Stroom version 7.9 that may break existing processing or ways of working.
---

{{% warning %}}
Please read this section carefully in case any of the changes affect you.
{{% /warning %}}

## Stroom

### Feed Status Check

If any proxy instances call into Stroom to make a feed status check using an API key, then the owner of those API keys will now need to be granted the `Check Receipt Status` application permission.


## Stroom-Proxy

### `maxOpenFiles`

The config property `proxyConfig.eventStore.maxOpenFiles` has been replaced with `proxyConfig.eventStore.openFilesCache`.

The default value for this property branch is:

```yaml
proxyConfig:
  eventStore:
    openFilesCache:
      expireAfterAccess: null
      expireAfterWrite: null
      maximumSize: 100
      refreshAfterWrite: null
      statisticsMode: "DROPWIZARD_METRICS"
```

