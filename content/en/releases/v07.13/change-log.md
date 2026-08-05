---
title: "Change Log"
linkTitle: "Change Log"
weight: 50
date: 2026-03-18
tags: 
description: >
  Full list of changes in this release.
---

<!--
To build this list run get_stroom_changelog_content.sh.
You need to provide it with the path to a stroom repo that has all the latest commits
for the two branches being compared. You can run it between tags (e.g. v7.11-beta.21 v7.11-beta.22) if
you need to add in the changes for a patch release.

E.g. ./get_stroom_changelog_content.sh ../stroom_v7_12 7.12 7.13

OR, if you use Vim use this command (changing the path to the stroom repo) to read it straight into this buffer
(Hash '#' needs to be escaped with '\' to stop vim replacing it with the current file path)
:r !./get_stroom_changelog_content.sh ../stroom_v7_12 7.12 7.13
-->


<!-- Changes between 'v7.12.12' and 'v7.13-beta.9' taken on Wed  5 Aug 15:57:03 BST 2026 -->

## New Features and Changes

* Feature **{{< external-link "#5656" "https://github.com/gchq/stroom/issues/5656" >}}** : Add feature to view sessions and revoke them and associated user tokens.

* Feature **{{< external-link "#5675" "https://github.com/gchq/stroom/issues/5675" >}}** : Add HTTP and TLS configuration to Git repositories.

* Feature **{{< external-link "#5656" "https://github.com/gchq/stroom/issues/5656" >}}** : Add self service account unlocking for the internal identity provider, controlled by the new properties `stroom.security.identity.reactivateInactiveAccountsOnLogin` and `stroom.security.identity.allowLockedAccountPasswordReset`, and rebuild the 'Forgot password' reset page so that an emailed reset link can be completed.

* Feature **{{< external-link "#5652" "https://github.com/gchq/stroom/issues/5652" >}}** : Support Elasticsearch nested field types in search.

* Feature **{{< external-link "#5654" "https://github.com/gchq/stroom/issues/5654" >}}** : Support multiple dense_vector fields in Elasticsearch rerank search.

* Feature **{{< external-link "#5599" "https://github.com/gchq/stroom/issues/5599" >}}** : Add XPath to query functions so that users can pull XML apart in Dashboard Tables.

* Feature **{{< external-link "#5600" "https://github.com/gchq/stroom/issues/5600" >}}** : Add JQ to query functions so that users can pull JSON apart in Dashboard Tables.

* Feature **{{< external-link "#5559" "https://github.com/gchq/stroom/issues/5559" >}}** : Improve node selection for node groups to allow select all and selection inversion.

* Feature **{{< external-link "#5561" "https://github.com/gchq/stroom/issues/5561" >}}** : Add feature to delete individual attachments and messages from AI chat history.

* Feature **{{< external-link "#5561" "https://github.com/gchq/stroom/issues/5561" >}}** : Add time tooltips to AI chat messages.

* Feature **{{< external-link "#5561" "https://github.com/gchq/stroom/issues/5561" >}}** : Fix user preferences resetting stroom AI preferences.

* Feature **{{< external-link "#5561" "https://github.com/gchq/stroom/issues/5561" >}}** : Open and view attachments in the AI chat window.

* Feature **{{< external-link "#5561" "https://github.com/gchq/stroom/issues/5561" >}}** : Add names to tables so they can be identified by stroom AI.

* Feature **{{< external-link "#5565" "https://github.com/gchq/stroom/issues/5565" >}}** : Make vector embedding dimension count configurable.

* Feature **{{< external-link "#5616" "https://github.com/gchq/stroom/issues/5616" >}}** : Add  XSLT function for computing the similarity of two float vectors.

* Feature **{{< external-link "#5622" "https://github.com/gchq/stroom/issues/5622" >}}** : Change Stroom UI auth flow so redirects are no longer required. Allows Stroom UI to be served from another location with BFF proxy.

* Feature **{{< external-link "#5630" "https://github.com/gchq/stroom/issues/5630" >}}** : Make embedding dimensions optional.

* Feature **{{< external-link "#5567" "https://github.com/gchq/stroom/issues/5567" >}}** : Stop the content index rebuilding on first use after a node reboot. Add config props `stroom.contentIndex.contentIndexDir` (defaults to `content_index`), `stroom.contentIndex.storageType` (one of `TEMP|LOCAL|SHARED`, defaults to `LOCAL`) and `stroom.contentIndex.minRebuildAge` (defaults to `PT1M`). Thus the content index can now be stored locally on each node for better performance or on shared storage. Stroom now eagerly builds the content index on boot if the storage type is `SHARED`.

* Feature **{{< external-link "#5515" "https://github.com/gchq/stroom/issues/5515" >}}** : Change JSONParser pipeline element to truncate very long strings values. Currently very long string values can result in Out of Memory errors in Stroom. The following configuration properties have been added to the JSONParser element; `stringTruncateLength` (default 10,000) to truncate very long strings, `maxStringLength` (default 100,000,000) to cause a fatal error if a long string is encountered, `maxDepth` (default 500) to limit the depth of deeply nested documents. The JSONParser has also been changed so that the characters of string values are streamed to the downstream pipeline elements rather than reading the whole string into memory. NOTE: It is still possible for downstream XSLT XPATH functions to result in the entire string being read into memory.

* Feature **{{< external-link "#5303" "https://github.com/gchq/stroom/issues/5303" >}}** : Improve Stroom AI to add dockable panel, chat history, attachments, copy, download, chat details etc.

* Feature **{{< external-link "#5282" "https://github.com/gchq/stroom/issues/5282" >}}** : Add pipeline scheduling.

* Feature **{{< external-link "#5346" "https://github.com/gchq/stroom/issues/5346" >}}** : Choose which external document changes to save when saving a pipeline.

* Feature **{{< external-link "#5377" "https://github.com/gchq/stroom/issues/5377" >}}** : Embedded pipeline docs.

* Feature **{{< external-link "#5387" "https://github.com/gchq/stroom/issues/5387" >}}** : Allow pipeline stepping across multiple streams.

* Feature **{{< external-link "#3103" "https://github.com/gchq/stroom/issues/3103" >}}** : Allow multiple dashboard instances.

* Feature : Editing items in the UI now indicates save required only when changes are made.

* Feature **{{< external-link "#3206" "https://github.com/gchq/stroom/issues/3206" >}}** : User tab sessions.

* Feature **{{< external-link "#5366" "https://github.com/gchq/stroom/issues/5366" >}}** : Rebase on master.

* Feature **{{< external-link "#5366" "https://github.com/gchq/stroom/issues/5366" >}}** : Cleanup.

* Feature **{{< external-link "#5366" "https://github.com/gchq/stroom/issues/5366" >}}** : Checkstyle.

* Feature **{{< external-link "#5232" "https://github.com/gchq/stroom/issues/5232" >}}** : Add standard annotation comments. MIGRATION: Any comments previously configured in standardComments property will need to saved as annotation comments.

* Feature **{{< external-link "#5366" "https://github.com/gchq/stroom/issues/5366" >}}** : Change icon for DataGen.

* Feature **{{< external-link "#5366" "https://github.com/gchq/stroom/issues/5366" >}}** : Add feed name to rule detection.

* Feature : Improve the ProgressMonitor task creation logging output to included counts of errored and skipped filters. Change task creation to re-test filter enabled/deleted state just prior to creating tasks. Add validation to ProcessorConfig to enforce a minimum value of `1` on some properties.

* Feature **{{< external-link "#5366" "https://github.com/gchq/stroom/issues/5366" >}}** : Fix DataGen destination feed not firing dirty event.

* Feature **{{< external-link "#5366" "https://github.com/gchq/stroom/issues/5366" >}}** : Checkstyle.


## Bug Fixes

* Bug **{{< external-link "#5669" "https://github.com/gchq/stroom/issues/5669" >}}** : Fix `HttpClientConfigConverter` not mapping `verifyHostname`, which prevented TLS hostname verification being disabled on HTTP clients.

* Bug **{{< external-link "#5671" "https://github.com/gchq/stroom/issues/5671" >}}** : Run directory-scanner file ingest as the processing user so that receipt checks requiring a user succeed.

* Bug **{{< external-link "#5674" "https://github.com/gchq/stroom/issues/5674" >}}** : Fix dirty behaviour on pipeline structure changes.

* Bug **{{< external-link "#5680" "https://github.com/gchq/stroom/issues/5680" >}}** : Fix account migration script.

* Bug **{{< external-link "#5679" "https://github.com/gchq/stroom/issues/5679" >}}** : Fix slow processor task assignment on large clusters. Task queueing now takes account of processing profiles so that tasks no node is allowed to process are not queued, and are released if a profile stops allowing them. Task assignment no longer repeatedly fills the queue when there is nothing to add, and only one request fills the queue at a time while the others wait for it.

* Bug **{{< external-link "#5679" "https://github.com/gchq/stroom/issues/5679" >}}** : Fix processor task creation not recording errors against the filter tracker, and not stopping when a task creation limit has been reached.

* Bug **{{< external-link "#5685" "https://github.com/gchq/stroom/issues/5685" >}}** : Fix inability to unset _Max Processing Tasks_ on a processor filter.

* Bug **{{< external-link "#5678" "https://github.com/gchq/stroom/issues/5678" >}}** : Fix processor task retention only using the `stroom.processor.deleteAge` value that was current when the node started. The _Processor Task Retention_ job now reads the property on each run, so a change to it takes effect without a node restart.

* Bug **{{< external-link "#5663" "https://github.com/gchq/stroom/issues/5663" >}}** : Fix OpenAPI spec for polymorphic types.

* Bug **{{< external-link "#5647" "https://github.com/gchq/stroom/issues/5647" >}}** : Fix user entered name being ignored when creating a new volume group.

* Bug **{{< external-link "#5646" "https://github.com/gchq/stroom/issues/5646" >}}** : Fix onChange() behaviour for document edits.

* Bug **{{< external-link "#5651" "https://github.com/gchq/stroom/issues/5651" >}}** : Fix file uploads bug introduced by CSRF change.

* Bug **{{< external-link "#5560" "https://github.com/gchq/stroom/issues/5560" >}}** : Fix processing schedule list label.

* Bug **{{< external-link "#5548" "https://github.com/gchq/stroom/issues/5548" >}}** : Fix PlanB filter XML value bug.

* Bug **{{< external-link "#5562" "https://github.com/gchq/stroom/issues/5562" >}}** : Add missing tab types to session restore.

* Bug **{{< external-link "#5617" "https://github.com/gchq/stroom/issues/5617" >}}** : Fix tab visibility on resize.

* Bug **{{< external-link "#5621" "https://github.com/gchq/stroom/issues/5621" >}}** : Support numeric comparators for Elasticsearch float and double fields.

* Bug **{{< external-link "#5573" "https://github.com/gchq/stroom/issues/5573" >}}** : Fix Ask Stroom AI error handling behaviour when requests are too large.

* Bug **{{< external-link "#5574" "https://github.com/gchq/stroom/issues/5574" >}}** : Fix Ask Stroom AI dock behaviour.

* Bug **{{< external-link "#5575" "https://github.com/gchq/stroom/issues/5575" >}}** : Change ask Stroom AI table page menu item.

* Bug **{{< external-link "#5576" "https://github.com/gchq/stroom/issues/5576" >}}** : Increase default AI model HTTP timeouts to 10 minutes.

* Bug **{{< external-link "#5585" "https://github.com/gchq/stroom/issues/5585" >}}** : Fix dashboard tab rename bug.

* Bug **{{< external-link "#5577" "https://github.com/gchq/stroom/issues/5577" >}}** : Fix bug affecting AI chat model selection.

* Bug **{{< external-link "#5601" "https://github.com/gchq/stroom/issues/5601" >}}** : Fix bug stopping embedded queries being edited.

* Bug **{{< external-link "#5568" "https://github.com/gchq/stroom/issues/5568" >}}** : Add analytic rule info to error stream messages.

* Bug **{{< external-link "#5636" "https://github.com/gchq/stroom/issues/5636" >}}** : Fix expression term quote removal bug.

* Bug **{{< external-link "#5640" "https://github.com/gchq/stroom/issues/5640" >}}** : Fix CSRF checks.

* Bug : Change the behaviour of JSON deserialisation to not error when a null value is encountered for a primitive type. This is how it used to behave in 7.12. However it now logs an error if a null primitive is encountered, so the corresponding Java class can be fixed to properly support null values.

* Bug **{{< external-link "#5579" "https://github.com/gchq/stroom/issues/5579" >}}** : Change test collation to utf8mb4_0900_ai_ci.

* Bug **{{< external-link "#5558" "https://github.com/gchq/stroom/issues/5558" >}}** : Fix processor profiles allowing processing for disabled node groups.

* Bug : Fix DocRef hover copy/open links not appearing.

* Bug **{{< external-link "#5535" "https://github.com/gchq/stroom/issues/5535" >}}** : Fix simple string values not appearing in Pipeline Property table.

* Bug : Fix Null Pointer type bug on Data Receipt Rules screen.

* Bug : Fix output of the manage_users --listPermissions command.

* Bug : Fix missing arg validation on reset_password CLI command. Obfuscate password in logging.


## Dependency Changes

* Dependency **{{< external-link "#5624" "https://github.com/gchq/stroom/issues/5624" >}}** : Upgrade langchain4j and openai-java libs.

* Dependency : Uplift AWS SDK to 2.46.7 and hbase-shaded-netty to 4.1.13.

* Dependency : Uplift Dropwizard to 5.0.2.

* Dependency : Uplift DropWizard to v5.0.1.

* Dependency : Uplift `net.openhft:zero-allocation-hashing` to `2026.0`.

* Dependency : Add Jackson JSON library `3.1.2` in addition to the existing `2.21.2` version. Stroom/Stroom-Proxy are now using v3 with the exception of a few specific areas that need legacy capability only available in v2. v3 is a significant change from v2 with some breaking changes and some differences in behaviour. Special attention should be paid to the output of JSONParser pipeline element to ensure it is behaving as expected.

* Dependency : Uplift base docker images to `eclipse-temurin:25.0.3_9-jdk-alpine-3.23`.

* Dependency : Uplift org.apache.commons:commons-pool2 from 2.12.1 to 2.13.1.

* Dependency : Uplift org.flywaydb:flyway-core from 11.20.0 to 12.0.0.

* Dependency : Uplift org.eclipse.jgit:org.eclipse.jgit from 7.3.0.202506031305-r to 7.5.0.202512021534-r.

* Dependency : Uplift org.apache.solr:solr-solrj from 9.8.0 to 9.10.1.

* Dependency : Uplift swagger from 2.2.41 to 2.2.42.

* Dependency : Uplift gwt from 2.12.2 to 2.13.0.

* Dependency : Uplift co.elastic.clients:elasticsearch-java from 9.2.1 to 9.3.2.

* Dependency : Uplift org.yaml:snakeyaml from 2.2 to 2.6.


## Code Refactor

* Refactor **{{< external-link "#5557" "https://github.com/gchq/stroom/issues/5557" >}}** : Change config class constructors to correctly handle and default null primitive values on deserialisation from YAML.

* Refactor : Change json (de)serialisation to not go via a String when dealing only with byte[] data.

* Refactor : Refactor the feedKey locking in PreAggregator and make AttributeMapUtil#readKeys() more lenient when reading `.meta `files.

* Refactor : Remove HBase statistics (may require change to default config).

* Refactor : Remove ScyllaDB based state store.

* Refactor : Replace NullSafe.requireNonNullElse() with Objects.requireNonNullElse().

* Refactor : Replace NullSafe.requireNonNullElseGet() with Objects.requireNonNullElseGet().


## Build Changes

* Build : Fix CI build failure due to missing Docker container prefix.

* Build : Uplift gradle-wrapper from 9.3.0 to 9.3.1.


## Uncategorised Issues

* Issue **{{< external-link "#5366" "https://github.com/gchq/stroom/issues/5366" >}}** : Add level and status to rules.

* Issue **{{< external-link "#5366" "https://github.com/gchq/stroom/issues/5366" >}}** : Create new doc object DataGen.

* Issue **{{< external-link "#5366" "https://github.com/gchq/stroom/issues/5366" >}}** : Add Execution tab to DataGen.

* Issue **{{< external-link "#5366" "https://github.com/gchq/stroom/issues/5366" >}}** : Implement job scheduling for DataGen.

* Issue **{{< external-link "#5366" "https://github.com/gchq/stroom/issues/5366" >}}** : Refactor schedulers.

* Issue **{{< external-link "#5366" "https://github.com/gchq/stroom/issues/5366" >}}** : Refactor schedulers to interface and cleanup.

* Issue **{{< external-link "#5366" "https://github.com/gchq/stroom/issues/5366" >}}** : Fix typo.
