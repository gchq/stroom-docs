---
title: "Change Log"
linkTitle: "Change Log"
weight: 50
date: 2025-01-30
tags: 
description: >
  Full list of changes in this release.
---

<!--
To build this list run diff_changelog.sh in the root of the stroom repo.
E.g. ./diff_changelog.sh 7.4 7.5 | sed -E -e 's/^/\n/' -e 's|Issue \*\*#([0-9]+)\*\*|Issue **{{< external-link "#\1" "https://github.com/gchq/stroom/issues/\1" >}}**|g'
-->

* Issue **{{< external-link "#4682" "https://github.com/gchq/stroom/issues/4682" >}}** : Improve Plan B filter error handling.

* Change `receiptId` format to `<epoch ms>_<seq no>_<(P|S)>_<proxyId or stroom nodeName>`. `P|S` represents stroom or Proxy.

* Change stroom to also set the `receiptId` meta attribute on receipt or upload.

* Change proxy logging to still log datafeed events even if the `metaKeys` config prop is empty.

* Issue **{{< external-link "#4695" "https://github.com/gchq/stroom/issues/4695" >}}** : Change proxy to re-create the proxy ID in proxy-id.txt if the value in there does not match the required pattern.

* Fix the sleep time in UniqueIdGenerator (from 50ms to 0.1ms).

* Fix tests that were breaking the build.

* Change the format of proxy receiptIds. They now look like `0000001736533752496_0000_TestProxy` with the first part being the epoch millis for when it was generated and the last part is the proxy ID.

* Change default `identityProviderType` to `INTERNAL_IDP` in stroom prod config.

* Issue **{{< external-link "#4661" "https://github.com/gchq/stroom/issues/4661" >}}** : Use Apache HttpClient.

* Issue **{{< external-link "#4378" "https://github.com/gchq/stroom/issues/4378" >}}** : Add reporting.

* Issue **{{< external-link "#2201" "https://github.com/gchq/stroom/issues/2201" >}}** : New proxy implementation.

