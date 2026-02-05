---
title: "Change Log"
linkTitle: "Change Log"
weight: 50
date: 2025-06-16
tags: 
description: >
  Full list of changes in this release.
---

<!--
To build this list run diff_changelog.sh in the root of the stroom repo that is on the appropriate branch

E.g. ./diff_changelog.sh 7.10 7.11 | sed -E -e 's/^/\n/' -e 's@(Issue|Bug|Feature|Build|Dependency|Refactor) \*\*#([0-9]+)\*\*@\1 **{{< external-link "#\2" "https://github.com/gchq/stroom/issues/\2" >}}**@g'

OR, if you use Vim use this command (changing the path to the stroom repo) to read it straight into this buffer
(Hash '#' needs to be escaped with '\' to stop vim replacing it with the current file path)
:r !../stroom_v7_11/diff_changelog.sh 7.10 7.11 | sed -E -e 's/^/\n/' -e 's@(Issue|Bug|Feature|Build|Dependency|Refactor) \*\*\#([0-9]+)\*\*@\1 **{{< external-link "\#\2" "https://github.com/gchq/stroom/issues/\2" >}}**@g'
-->

## New Features and Changes

* Feature **{{< external-link "#5282" "http://github.com/gchq/stroom/issues/5282" >}}** : Processor task creation now supports feed dependencies to delay processing until reference data is available.

* Feature **{{< external-link "#5256" "http://github.com/gchq/stroom/issues/5256" >}}** : Add option to omit documentation from rule detection.

* Feature **{{< external-link "#5309" "http://github.com/gchq/stroom/issues/5309" >}}** : Add long support to pathway values.

* Feature **{{< external-link "#5303" "http://github.com/gchq/stroom/issues/5303" >}}** : Make AI HTTP connection configurable.

* Feature **{{< external-link "#5303" "http://github.com/gchq/stroom/issues/5303" >}}** : Make AI HTTP SSL certificate stores configurable.

* Feature **{{< external-link "#5303" "http://github.com/gchq/stroom/issues/5303" >}}** : Add KNN dense vector support to Lucene indexes.

* Feature **{{< external-link "#5303" "http://github.com/gchq/stroom/issues/5303" >}}** : Pass only visible columns to the Ask Stroom AI service.

* Feature **{{< external-link "#4123" "http://github.com/gchq/stroom/issues/4123" >}}** : New pipeline stepping mode.

* Feature **{{< external-link "#5290" "http://github.com/gchq/stroom/issues/5290" >}}** : Plan B trace store now requires data to conform to Plan B trace schema.

* Feature : Make the Quick Filter Help button hide the help popup if it is visible.

* Feature : Add the same Quick Filter help popup as used on the explorer QF to the QFs on Dashboard table columns, Query help and Expression Term editors.

* Feature **{{< external-link "#5263" "http://github.com/gchq/stroom/issues/5263" >}}** : Add copy for selected rows.

* Remove default value for `feedStatus.url` in the proxy config yaml as downstream host should now be used instead.

* Feature **{{< external-link "#5192" "http://github.com/gchq/stroom/issues/5192" >}}** : Support Elasticsearch kNN search on dense_vector fields.

* Feature **{{< external-link "#5124" "http://github.com/gchq/stroom/issues/5124" >}}** : Change cluster lock `tryLock` to use the database record locks rather than the inter-node lock handler.

* Feature **{{< external-link "#656" "http://github.com/gchq/stroom/issues/656" >}}** : Allow table filters to use dictionaries.

* Feature **{{< external-link "#672" "http://github.com/gchq/stroom/issues/672" >}}** : Dashboards will only auto refresh when selected.

* Feature **{{< external-link "#2029" "http://github.com/gchq/stroom/issues/2029" >}}** : Add OS memory stats to the node status stats.

* Feature **{{< external-link "#3799" "http://github.com/gchq/stroom/issues/3799" >}}** : Search for tags in Find In Content.

* Feature **{{< external-link "#3335" "http://github.com/gchq/stroom/issues/3335" >}}** : Preserve escape chars not preceding delimiters.

* Feature **{{< external-link "#1429" "http://github.com/gchq/stroom/issues/1429" >}}** : Protect against large file ingests.

* Feature **{{< external-link "#4121" "http://github.com/gchq/stroom/issues/4121" >}}** : Add rename option for pipeline elements.

* Feature **{{< external-link "#2374" "http://github.com/gchq/stroom/issues/2374" >}}** : Add pipeline element descriptions.

* Feature **{{< external-link "#4099" "http://github.com/gchq/stroom/issues/4099" >}}** : Add InRange function.

* Feature **{{< external-link "#2374" "http://github.com/gchq/stroom/issues/2374" >}}** : Add description is now editable for pipeline elements.

* Feature **{{< external-link "#268" "http://github.com/gchq/stroom/issues/268" >}}** : Add not contains and not exists filters to pipeline stepping.

* Feature **{{< external-link "#844" "http://github.com/gchq/stroom/issues/844" >}}** : Add functions for hostname and hostaddress.

* Feature **{{< external-link "#4579" "http://github.com/gchq/stroom/issues/4579" >}}** : Add table name/id to conditional formatting exceptions.

* Feature **{{< external-link "#4124" "http://github.com/gchq/stroom/issues/4124" >}}** : Show severity of search error messages.

* Feature **{{< external-link "#4369" "http://github.com/gchq/stroom/issues/4369" >}}** : Add new rerun scheduled execution icon.

* Feature **{{< external-link "#3207" "http://github.com/gchq/stroom/issues/3207" >}}** : Add maxStringFieldLength table setting.

* Feature **{{< external-link "#1249" "http://github.com/gchq/stroom/issues/1249" >}}** : Dashboard links can open in the same tab.

* Feature **{{< external-link "#1304" "http://github.com/gchq/stroom/issues/1304" >}}** : Copy dashboard components between dashboards.

* Feature **{{< external-link "#2145" "http://github.com/gchq/stroom/issues/2145" >}}** : New add-meta xslt function.

* Feature **{{< external-link "#370" "http://github.com/gchq/stroom/issues/370" >}}** : Perform schema validation on save.

* Feature **{{< external-link "#397" "http://github.com/gchq/stroom/issues/397" >}}** : Copy user permissions.

* Feature **{{< external-link "#5088" "http://github.com/gchq/stroom/issues/5088" >}}** : Add table column filter dashboard component.

* Feature **{{< external-link "#2571" "http://github.com/gchq/stroom/issues/2571" >}}** : Show Tasks for processor filter.

* Feature **{{< external-link "#4177" "http://github.com/gchq/stroom/issues/4177" >}}** : Add stream id links.

* Feature **{{< external-link "#2279" "http://github.com/gchq/stroom/issues/2279" >}}** : Drag and drop tabs.

* Feature **{{< external-link "#2584" "http://github.com/gchq/stroom/issues/2584" >}}** : Close all tabs to right/left.

* Feature **{{< external-link "#5013" "http://github.com/gchq/stroom/issues/5013" >}}** : Add row data to annotations.

* Feature **{{< external-link "#3049" "http://github.com/gchq/stroom/issues/3049" >}}** : Check for full/inactive/closed index volumes.

* Feature **{{< external-link "#4070" "http://github.com/gchq/stroom/issues/4070" >}}** : Show column information on hover tip.

* Feature **{{< external-link "#3815" "http://github.com/gchq/stroom/issues/3815" >}}** : Add selected tab colour property.

* Feature **{{< external-link "#4790" "http://github.com/gchq/stroom/issues/4790" >}}** : Add copy option for property names.

* Feature **{{< external-link "#4121" "http://github.com/gchq/stroom/issues/4121" >}}** : Add rename option for pipeline elements.

* Feature **{{< external-link "#2823" "http://github.com/gchq/stroom/issues/2823" >}}** : Add `autoImport` servlet to simplify importing content.

* Feature **{{< external-link "#5013" "http://github.com/gchq/stroom/issues/5013" >}}** : Add data to existing annotations.

* Feature **{{< external-link "#5013" "http://github.com/gchq/stroom/issues/5013" >}}** : Add links to other annotations and allow comments to make references to events and other annotations.

* Feature **{{< external-link "#2374" "http://github.com/gchq/stroom/issues/2374" >}}** : Add pipeline element descriptions.

* Feature **{{< external-link "#2374" "http://github.com/gchq/stroom/issues/2374" >}}** : Add description is now editable for pipeline elements.

* Feature **{{< external-link "#4048" "http://github.com/gchq/stroom/issues/4048" >}}** : Add query csv API.

* Feature: Change the proxy config properties `forwardUrl`, `livenessCheckUrl`, `apiKeyVerificationUrl` and `feedStatusUrl` to be empty by default and to allow them to be populated with either just a path or a full URL. `downstreamHost` config will be used to provide the host details if these properties are empty or only contain a path. Added the property `livenessCheckEnabled` to `forwardHttpDestinations` to control whether the forward destination liveness is checked (defaults to true).

* Feature **{{< external-link "#5028" "http://github.com/gchq/stroom/issues/5028" >}}** : Add build info metrics `buildVersion`, `buildDate` and `upTime`.

* Add admin port servlets for Prometheus to scrape metrics from stroom and proxy. Servlet is available as `http://host:<admin port>/(stroom|proxy)Admin/prometheusMetrics`.

* Feature **{{< external-link "#4735" "http://github.com/gchq/stroom/issues/4735" >}}** : Add expand/collapse to result tables.

* Feature **{{< external-link "#5013" "http://github.com/gchq/stroom/issues/5013" >}}** : Allow annotation status update without requery.

* Feature **{{< external-link "#259" "http://github.com/gchq/stroom/issues/259" >}}** : Maximise dashboard panes.

* Feature **{{< external-link "#3874" "http://github.com/gchq/stroom/issues/3874" >}}** : Add copy context menu to tables.

* Feature : Add the Receive Data Rules screen to the Administration menu which requires the `Manage Data Receipt Rules` app permission. Add the following new config properties to the `receive` branch: `obfuscatedFields`, `obfuscationHashAlgorithm`, `receiptCheckMode` and `receiptRulesInitialFields`. Remove the property `receiptPolicyUuid`. Add the proxy config property `contentSync.receiveDataRulesUrl`.

* Feature: The proxy config property `feedStatus.enabled` has been replaced by `receive.receiptCheckMode` which takes values `FEED_STATUS`, `RECEIPT_POLICY` or `NONE`.

* Feature: In the proxy config, the named Jersey clients CONTENT_SYNC and FEED_STATUS have been removed and replaced with DOWNSTREAM.


## Bug Fixes

* Bug **{{< external-link "#5384" "http://github.com/gchq/stroom/issues/5384" >}}** : Improvements to annotations database code.

* Bug **{{< external-link "#5360" "http://github.com/gchq/stroom/issues/5360" >}}** : Fix NPE when annotation data retention fires change events.

* Bug **{{< external-link "#5361" "http://github.com/gchq/stroom/issues/5361" >}}** : Fix invalid SQL error when annotation data retention runs.

* Bug : Fix 'Data source already in use' errors when using annotations.

* Bug : Add missing cluster lock protection for annotation data retention job.

* Bug **{{< external-link "#5359" "http://github.com/gchq/stroom/issues/5359" >}}** : Fix 'Data source already in use' errors in the _Data Delete_ job.

* Bug **{{< external-link "#5185" "http://github.com/gchq/stroom/issues/5185" >}}** : Fix dashboard maximise NPE.

* Bug **{{< external-link "#5370" "http://github.com/gchq/stroom/issues/5370" >}}** : Hide rule notification doc checkbox on reports as it is not applicable.

* Bug **{{< external-link "#5234" "http://github.com/gchq/stroom/issues/5234" >}}** : Fix spaces in `createAnnotation()` function link text.

* Bug **{{< external-link "#5355" "http://github.com/gchq/stroom/issues/5355" >}}** : Fix HttpClient being closed by cache while in use.

* Bug **{{< external-link "#5303" "http://github.com/gchq/stroom/issues/5303" >}}** : Add debug to index dense vector retrieval.

* Bug **{{< external-link "#5344" "http://github.com/gchq/stroom/issues/5344" >}}** : Fix credential manager UI.

* Bug **{{< external-link "#5342" "http://github.com/gchq/stroom/issues/5342" >}}** : Fix issue querying Plan B shards where some stores have been deleted.

* Bug **{{< external-link "#5351" "http://github.com/gchq/stroom/issues/5351" >}}** : Make SSH key and known host configuration clearer.

* Bug **{{< external-link "#5353" "http://github.com/gchq/stroom/issues/5353" >}}** : Fix keystore config issue.

* Bug **{{< external-link "#5339" "http://github.com/gchq/stroom/issues/5339" >}}** : Fix NPE thrown when adding vises to dashboards.

* Bug **{{< external-link "#5337" "http://github.com/gchq/stroom/issues/5337" >}}** : Fix analytic doc serialisation.

* Bug **{{< external-link "#4124" "http://github.com/gchq/stroom/issues/4124" >}}** : Fix NodeResultSerialiser and add node name to errors.

* Bug **{{< external-link "#5317" "http://github.com/gchq/stroom/issues/5317" >}}** : Pathways now load current state to not endlessly output mutations.

* Bug : Fix build issue causing Stroom to not boot.

* Bug **{{< external-link "#5304" "http://github.com/gchq/stroom/issues/5304" >}}** : Fix error when unzipping the stroom-app-all jar file. This problem was also leading to AV scan alerts.

* Bug : Fix Files list on Stream Info pane so that you can copy each file path individually.

* Bug **{{< external-link "#5297" "http://github.com/gchq/stroom/issues/5297" >}}** : Fix missing execute permissions and incorrect file dates in stroom and stroom-proxy distribution ZIP files.

* Bug **{{< external-link "#5259" "http://github.com/gchq/stroom/issues/5259" >}}** : Fix PlanB Val.toString() NPE.

* Bug **{{< external-link "#5291" "http://github.com/gchq/stroom/issues/5291" >}}** : Fix explorer item sort order.

* Bug **{{< external-link "#5152" "http://github.com/gchq/stroom/issues/5152" >}}** : Fix position of the Clear icon on the Quick Filter.

* Bug **{{< external-link "#5293" "http://github.com/gchq/stroom/issues/5293" >}}** : Fix pipeline element type and name display.

* Bug **{{< external-link "#5254" "http://github.com/gchq/stroom/issues/5254" >}}** : Fix document NPE.

* Bug **{{< external-link "#5218" "http://github.com/gchq/stroom/issues/5218" >}}** : When `autoContentCreation` is enabled, don't attempt to find a content template if the `Feed` header has been provided and the feed exists.

* Bug **{{< external-link "#5244" "http://github.com/gchq/stroom/issues/5244" >}}** : Fix proxy throwing an error when attempting to do a feed status check.

* Bug **{{< external-link "#5149" "http://github.com/gchq/stroom/issues/5149" >}}** : Fix context menus not appearing on dashboard tables.

* Bug **{{< external-link "#4614" "http://github.com/gchq/stroom/issues/4614" >}}** : Fix StroomQL highlight.

* Bug **{{< external-link "#5064" "http://github.com/gchq/stroom/issues/5064" >}}** : Fix ref data store discovery.

* Bug **{{< external-link "#5022" "http://github.com/gchq/stroom/issues/5022" >}}** : Fix weird spinner behaviour.

* Bug : Fix NPE when proxy tries to fetch the receipt rules from downstream.


## Code Refactor

* Refactor : Remove static imports except in test classes.


## Dependency Changes

* Dependency : Uplift base docker images to eclipse-temurin:25.0.1_8-jdk-alpine-3.23.

* Dependency : Uplift dependency com.hubspot.jinjava:jinjava from 2.7.2 to 2.8.2.

* Dependency : Uplift dependency swagger-* from 2.2.38 to 2.2.41.

* Dependency : Uplift com.sun.xml.bind:jaxb-impl from 4.0.5 to 4.0.6.

* Dependency : Uplift lanchain4j dependencies from 1.8.0-beta15 to 1.10.0-beta18 and 1.8.0 to 1.10.0.

* Dependency : Uplift Gradle to v9.2.1.

* Dependency : Uplift docker image JDK to `eclipse-temurin:25_36-jdk-alpine-3.22`.

* Dependency **{{< external-link "#5257" "http://github.com/gchq/stroom/issues/5257" >}}** : Upgrade Lucene to 10.3.1.

* Dependency : Uplift dependency java-jwt 4.4.0 => 4.5.0.

* Dependency : Uplift org.apache.commons:commons-csv from 1.10.0 to 1.14.1.

* Dependency : Uplift dependency org.apache.commons:commons-pool2 from 2.12.0 to 2.12.1.

* Dependency : Bumps org.quartz-scheduler:quartz from 2.5.0-rc1 to 2.5.1.

* Dependency : Bumps org.eclipse.transformer:org.eclipse.transformer.cli from 0.5.0 to 1.0.0.

* Dependency : Bumps jooq from 3.20.5 to 3.20.8.

* Dependency : Bumps com.mysql:mysql-connector-j from 9.2.0 to 9.4.0.

* Dependency : Bumps flyway from 11.9.1 to 11.14.0.
