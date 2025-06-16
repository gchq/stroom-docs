---
title: "Change Log"
linkTitle: "Change Log"
weight: 50
date: 2025-04-01
tags: 
description: >
  Full list of changes in this release.
---

<!--
To build this list run diff_changelog.sh in the root of the stroom repo.
E.g. ./diff_changelog.sh 7.4 7.5 | sed -E -e 's/^/\n/' -e 's|Issue \*\*#([0-9]+)\*\*|Issue **{{< external-link "#\1" "https://github.com/gchq/stroom/issues/\1" >}}**|g'
-->


* Fix primitive value conversion of query field types.

* Issue **{{< external-link "#4940" "https://github.com/gchq/stroom/issues/4940" >}}** : Fix duplicate store error log.

* Issue **{{< external-link "#4941" "https://github.com/gchq/stroom/issues/4941" >}}** : Fix annotation data retention.

* Issue **{{< external-link "#4968" "https://github.com/gchq/stroom/issues/4968" >}}** : Improve Plan B file receipt.

* Issue **{{< external-link "#4956" "https://github.com/gchq/stroom/issues/4956" >}}** : Add error handling to duplicate check deletion.

* Issue **{{< external-link "#4967" "https://github.com/gchq/stroom/issues/4967" >}}** : Fix SQL deadlock.

* Fix compile issues.

* Issue **{{< external-link "#4875" "https://github.com/gchq/stroom/issues/4875" >}}** : Fix select *.

* Issue **{{< external-link "#3928" "https://github.com/gchq/stroom/issues/3928" >}}** : Add merge filter for deeply nested data.

* Issue **{{< external-link "#4211" "https://github.com/gchq/stroom/issues/4211" >}}** : Prevent stream status in processing filters.

* Issue **{{< external-link "#4927" "https://github.com/gchq/stroom/issues/4927" >}}** : Fix TOKEN data feed auth when DATA_FEED_KEY is enabled.

* Issue **{{< external-link "#4862" "https://github.com/gchq/stroom/issues/4862" >}}** : Add select * to StroomQL.

* Annotations 2.0.

* Uplift BCrypt lib to 0.4.3.

* Add BCrypt as a hashing algorithm to data feed keys. Change Data feed key auth to require the header as configured by `dataFeedKeyOwnerMetaKey`. Change `hashAlgorithmId` to `hashAlgorithm` in the data feed keys json file.

* Issue **{{< external-link "#4109" "https://github.com/gchq/stroom/issues/4109" >}}** : Add `receive` config properties `x509CertificateHeader`, `x509CertificateDnHeader` and `allowedCertificateProviders` to control the use of certificates and DNs placed in the request headers by load balancers or reverse proxies that are doing the TLS termination. Header keys were previously hard coded. `allowedCertificateProviders` is an allow list of FQDN/IPs that are allowed to use the cert/DN headers.

* Add Dropwizard Metrics to proxy.

* Change proxy to use the same caching as stroom.

* Remove unused proxy config property `maxAggregateAge`. `aggregationFrequency` controls the aggregation age/frequency.

* Stroom-Proxy instances that are making remote feed status requests using an API key or token, will now need to hold the application permission `Check Receipt Status` in Stroom. This prevents anybody with an API key from checking feed statuses.

* Issue **{{< external-link "#4312" "https://github.com/gchq/stroom/issues/4312" >}}** : Add Data Feed Keys to proxy and stroom to allow their use in data receipt authentication. Replace `proxyConfig.receive.(certificateAuthenticationEnabled|tokenAuthenticationEnabled)` with `proxyConfig.receive.enabledAuthenticationTypes` that takes values: `DATA_FEED_KEY|TOKEN|CERTIFICATE` (where `TOKEN` means an oauth token or an API key). The feed status check endpoint `/api/feedStatus/v1` has been deprecated. Proxies with a version >=v7.9 should now use `/api/feedStatus/v2`.

* Replace proxy config prop `proxyConfig.eventStore.maxOpenFiles` with `proxyConfig.eventStore.openFilesCache`.

* Add optional auto-generation of the `Feed` attribute using property `proxyConfig.receive.feedNameGenerationEnabled`. This is used alongside properties `proxyConfig.receive.feedNameTemplate` (which defines a template for the auto-generated feed name using meta keys and their values) and `feedNameGenerationMandatoryHeaders` which defines the mandatory meta headers that must be present for a auto-generation of the feed name to be possible.

* Add a new _Content Templates_ screen to stroom (requires `Manage Content Templates` application permission). This screen is used to define rules for matching incoming data where the feed does not exist and creating content to process data for that feed.

* Feed status check calls made by a proxy into stroom now require the application permission `Check Receipt Status`. This is to stop anyone with an API key from discovering the feeds available in stroom. Any existing API keys used for feed status checks on proxy will need to have `Check Receipt Status` granted to the owner of the key.

* Issue **{{< external-link "#4839" "https://github.com/gchq/stroom/issues/4839" >}}** : Change record count filter to allow counting of records at a custom depth to match split filter.

* Issue **{{< external-link "#4828" "https://github.com/gchq/stroom/issues/4828" >}}** : Fix recursive cache invalidation for index load.

* Issue **{{< external-link "#4827" "https://github.com/gchq/stroom/issues/4827" >}}** : Fix NPE when opening the Nodes screen.

* Issue **{{< external-link "#4733" "https://github.com/gchq/stroom/issues/4733" >}}** : Fix report shutdown error.

* Issue **{{< external-link "#4778" "https://github.com/gchq/stroom/issues/4778" >}}** : Improve menu text rendering.

* Issue **{{< external-link "#4552" "https://github.com/gchq/stroom/issues/4552" >}}** : Update dynamic index fields via the UI.

* Issue **{{< external-link "#3921" "https://github.com/gchq/stroom/issues/3921" >}}** : Make QuickFilterPredicateFactory produce an expression tree.

* Issue **{{< external-link "#3820" "https://github.com/gchq/stroom/issues/3820" >}}** : Add OR conditions to quick filter.

* Issue **{{< external-link "#3551" "https://github.com/gchq/stroom/issues/3551" >}}** : Fix character escape in quick filter.

* Issue **{{< external-link "#4553" "https://github.com/gchq/stroom/issues/4553" >}}** : Fix word boundary matching.

* Issue **{{< external-link "#4776" "https://github.com/gchq/stroom/issues/4776" >}}** : Fix column value `>`, `>=`, `<`, `<=`, filtering.

* Issue **{{< external-link "#4772" "https://github.com/gchq/stroom/issues/4772" >}}** : Uplift GWT to version 2.12.1.

* Issue **{{< external-link "#4773" "https://github.com/gchq/stroom/issues/4773" >}}** : Improve cookie config.

* Issue **{{< external-link "#4692" "https://github.com/gchq/stroom/issues/4692" >}}** : Add table column filtering by unique value selection.


