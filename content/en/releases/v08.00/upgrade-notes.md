---
title: "Upgrade Notes"
linkTitle: "Upgrade Notes"
weight: 40
date: 2026-11-25
tags:
description: >
  Required actions and information relating to upgrading to Stroom version 8.0.
---

{{< warning >}}
Please read this section carefully in case any of it is relevant to your Stroom/Stroom-Proxy instance.
{{< /warning >}}


## Upgrade Path

{{% todo %}}
Complete this section.
{{% /todo %}}


## Configuration File Changes

<!--
Check changes using something like this (run from an up-to-date stroom repo):
old_ver=7.14
new_ver=8.0
git diff origin/${old_ver}..origin/${new_ver} stroom-config/stroom-config-app/src/test/resources/stroom/config/app/expected.yaml | cat
echo
echo
git diff origin/${old_ver}..origin/${new_ver} stroom-proxy/stroom-proxy-app/src/test/resources/stroom/dist/proxy-expected.yaml | cat
-->


### Stroom's `config.yml`

The following changes have been made to Stroom's configuration.
Most of the new properties have suitable defaults and do not need to be set unless you need to change the default behaviour.


#### New `maxCountDistinctValues` Properties

The new properties set the most unique values that `countDistinct()` counts exactly for each group, from 1 to 1,000,000.
The count of a group that has more is an estimate.
`analytics` is used for analytic rules and reports, and `search` for queries, dashboards and other searches.

```yaml
appConfig:
  analytics:
    resultStore:
      maxCountDistinctValues: 10000
  search:
    resultStore:
      maxCountDistinctValues: 10000
```

A Table Builder rule keeps the limit that its table was opened with until the node is restarted.
A group in its table that has gone over the limit remains an estimate if the limit is raised.


### Stroom-Proxy's `config.yml`

{{% todo %}}
Complete this section.
{{% /todo %}}
