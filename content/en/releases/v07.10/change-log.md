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
To build this list run diff_changelog.sh in the root of the stroom repo.
E.g. ./diff_changelog.sh 7.4 7.5 | sed -E -e 's/^/\n/' -e 's|Issue \*\*#([0-9]+)\*\*|Issue **{{< external-link "#\1" "https://github.com/gchq/stroom/issues/\1" >}}**|g'

OR, if you use Vim use this command to read it straight into this buffer
(Hash '#' needs to be escaped with '\' to stop vim replacing it with the current file path)
:r !../stroom_v7_10/diff_changelog.sh 7.9 7.10 | sed -E -e 's/^/\n/' -e 's|Issue \*\*\#([0-9]+)\*\*|Issue **{{< external-link "\#\1" "https://github.com/gchq/stroom/issues/\1" >}}**|g'
-->


* Issue **{{< external-link "#5137" "https://github.com/gchq/stroom/issues/5137" >}}** : Fix how proxy adds HTTP headers when sending downstream. It now only adds received meta entries to the headers if they are on an allow list. This list is made up of a hard coded base list `accountId, accountName, classification, component, contextEncoding, contextFormat, encoding, environment, feed, format, guid, schema, schemaVersion, system, type` and is supplemented by the new config property `forwardHeadersAdditionalAllowSet` in the `forwardHttpDestinations` items.

* Issue **{{< external-link "#5135" "https://github.com/gchq/stroom/issues/5135" >}}** : Fix proxy multi part gzip handling.

* Uplift JDK to 21.0.8_9 in docker images and sdkmanrc.

* Issue **{{< external-link "#5130" "https://github.com/gchq/stroom/issues/5130" >}}** : Fix raw size meta bug.

* Issue **{{< external-link "#5132" "https://github.com/gchq/stroom/issues/5132" >}}** : Fix missing session when AWS ALB does the code flow.

* Fix the OpenID code flow to stop the session being lost after redirection back to the initiating URL.

* Issue **{{< external-link "#5101" "https://github.com/gchq/stroom/issues/5101" >}}** : Fix select-all filtering when doing a reprocess of everything in a folder. It no longer tries to re-process deleted items streams.

* Issue **{{< external-link "#5086" "https://github.com/gchq/stroom/issues/5086" >}}** : Improve stream error handling.

* Change the resource store to not rely on sessions. Resources are now linked to a user.

* Issue **{{< external-link "#5114" "https://github.com/gchq/stroom/issues/5114" >}}** : Improve handling of loss of connection to IDP.

* Change the way security filter decides whether to authenticate or not, e.g. how it determines what is a static resource that does not need authentication.

* Issue **{{< external-link "#5115" "https://github.com/gchq/stroom/issues/5115" >}}** : Use correct  header during proxy forward requests.

* Issue **{{< external-link "#5121" "https://github.com/gchq/stroom/issues/5121" >}}** : Proxy aggregation now keeps only common headers in aggregated data.

* Fix exception handling of DistributedTaskFetcher so it will restart after failure.

* Issue **{{< external-link "#5127" "https://github.com/gchq/stroom/issues/5127" >}}** : Maintain case for proxy meta attributes when logging.

* Issue **{{< external-link "#5091" "https://github.com/gchq/stroom/issues/5091" >}}** : Stop reference data loads failing if there are no entries in the stream.

* Add `ReceiptId` to the INFO message on data receipt.

* Issue **{{< external-link "#5095" "https://github.com/gchq/stroom/issues/5095" >}}** : Lock the cluster to perform pipeline migration to prevent other nodes clashing.

* Issue **{{< external-link "#5099" "https://github.com/gchq/stroom/issues/5099" >}}** : Fix Plan B session key serialisation.

* Issue **{{< external-link "#5090" "https://github.com/gchq/stroom/issues/5090" >}}** : Fix Plan B getVal() serialisation.

* Issue **{{< external-link "#5106" "https://github.com/gchq/stroom/issues/5106" >}}** : Fix ref loads with XML values where the `<value>` element name is not in lower case.

* Issue **{{< external-link "#5042" "https://github.com/gchq/stroom/issues/5042" >}}** : Allow the import of processor filters when the existing processor filter is in a logically deleted state. Add validation to the import confirm dialog to ensure the parent doc is selected when a processor filter is selected.

* Change DocRef Info Cache to evict entries on document creation to stop stroom saying that a document doesn't exist after import.

* Issue **{{< external-link "#5077" "https://github.com/gchq/stroom/issues/5077" >}}** : Fix bug in user full name templating where it is always re-using the first value, i.e. setting every user to have the full name of the first user to log in.

* Issue **{{< external-link "#5047" "https://github.com/gchq/stroom/issues/5047" >}}** : Replace the property `stroom.security.authentication.openid.validateAudience` with `stroom.security.authentication.openid.allowedAudiences` (defaults to empty) and `stroom.security.authentication.openid.audienceClaimRequired` (defaults to false). If the IDP is known to provide the `aud` claim (often populated with the `clientId`) then set `allowedAudiences` to contain that value and set `audienceClaimRequired` to `true`.

* Issue **{{< external-link "#5068" "https://github.com/gchq/stroom/issues/5068" >}}** : Add the config prop `stroom.security.authentication.openId.fullNameClaimTemplate` to allow the user's full name to be formed from a template containing a mixture of static text and claim variables, e.g. `${firstName} ${lastName}`. Unknown variables are replaced with an empty string. Default is `${name}`.

* Issue **{{< external-link "#5066" "https://github.com/gchq/stroom/issues/5066" >}}** : Change template syntax of `openid.publicKeyUriPattern` prop from positional variables (`{}`) to named variables (`${awsRegion}`). Default value has changed to `https://public-keys.auth.elb.${awsRegion}.amazonaws.com/${keyId}`. If this prop has been explicitly set, its value will need to be changed to named variables.

* Issue **{{< external-link "#5073" "https://github.com/gchq/stroom/issues/5073" >}}** : Trim the unique identity, display name and full name values for a user to ensure no leading/trailing spaces are stored. Includes DB migration `V07_10_00_005__trim_user_identities.sql` that trims existing values in the `name`, `display_name` and `full_name` columns of the `stroom_user` table.

* Issue **{{< external-link "#5046" "https://github.com/gchq/stroom/issues/5046" >}}** : Stop feeds being auto-created when there is no content template match.

* Issue **{{< external-link "#5062" "https://github.com/gchq/stroom/issues/5062" >}}** : Fix permissions issue loading scheduled executors.

* Allow clientSecret to be null/empty for mTLS auth.

* Issue **{{< external-link "#5027" "https://github.com/gchq/stroom/issues/5027" >}}** : Allow users to choose run as user for processing.

* Issue **{{< external-link "#5017" "https://github.com/gchq/stroom/issues/5017" >}}** : Fix stuck spinner copying embedded query.

* Issue **{{< external-link "#4974" "https://github.com/gchq/stroom/issues/4974" >}}** : Fix Plan B condense job.

* Issue **{{< external-link "#5030" "https://github.com/gchq/stroom/issues/5030" >}}** : Add new property `.receive.x509CertificateDnFormat` to stroom and proxy to allow extraction of CNs from DNs in legacy `OPEN_SSL` format. The new property defaults to `LDAP`, which means no change to behaviour if left as is.

* Issue **{{< external-link "#5007" "https://github.com/gchq/stroom/issues/5007" >}}** : Add ceilingTime() and floorTime().

* Issue **{{< external-link "#4977" "https://github.com/gchq/stroom/issues/4977" >}}** : Limit user visibility in annotations.

* Issue **{{< external-link "#4976" "https://github.com/gchq/stroom/issues/4976" >}}** : Exclude deleted annotations.

* Issue **{{< external-link "#5002" "https://github.com/gchq/stroom/issues/5002" >}}** : Fix Plan B env staying open after error.

* Issue **{{< external-link "#5003" "https://github.com/gchq/stroom/issues/5003" >}}** : Fix query date time formatting.

* Issue **{{< external-link "#4974" "https://github.com/gchq/stroom/issues/4974" >}}** : Improve logging.

* Issue **{{< external-link "#3083" "https://github.com/gchq/stroom/issues/3083" >}}** : Allow data() table function to show the Info pane.

* Issue **{{< external-link "#4974" "https://github.com/gchq/stroom/issues/4974" >}}** : NPE debug.

* Issue **{{< external-link "#4965" "https://github.com/gchq/stroom/issues/4965" >}}** : Add dashboard screen to show current selection parameters.

* Issue **{{< external-link "#4496" "https://github.com/gchq/stroom/issues/4496" >}}** : Add parse-dateTime xslt function.

* Issue **{{< external-link "#4496" "https://github.com/gchq/stroom/issues/4496" >}}** : Add format-dateTime xslt function.

* Issue **{{< external-link "#4983" "https://github.com/gchq/stroom/issues/4983" >}}** : Upgrade Flyway to work with newer version of MySQL.

* Issue **{{< external-link "#3122" "https://github.com/gchq/stroom/issues/3122" >}}** : Make date/time rounding functions time zone sensitive.

* Issue **{{< external-link "#4984" "https://github.com/gchq/stroom/issues/4984" >}}** : Add debug for Plan B tagged keys.

* Issue **{{< external-link "#4969" "https://github.com/gchq/stroom/issues/4969" >}}** : Add a checkbox to Content Templates edit screen to make it copy (and re-map) any xslt/textConverter docs in the inherited pipeline.

* Issue **{{< external-link "#4991" "https://github.com/gchq/stroom/issues/4991" >}}** : Add Plan B schema validation to ensure stores remain compatible especially when merging parts.

* Issue **{{< external-link "#4854" "https://github.com/gchq/stroom/issues/4854" >}}** : Maintain scrollbar position on datagrid.

* Issue **{{< external-link "#4726" "https://github.com/gchq/stroom/issues/4726" >}}** : Get meta for parent stream.

* Issue **{{< external-link "#4900" "https://github.com/gchq/stroom/issues/4900" >}}** : Add histogram and metric stores to Plan B.

* Issue **{{< external-link "#4957" "https://github.com/gchq/stroom/issues/4957" >}}** : Default vis settings are not added to Query pane visualisations.

* Issue **{{< external-link "#3861" "https://github.com/gchq/stroom/issues/3861" >}}** : Add Shard Id, Index Version to Index Shards searchable.

* Issue **{{< external-link "#4112" "https://github.com/gchq/stroom/issues/4112" >}}** : Allow use of Capture groups in the decode() function result.

* Issue **{{< external-link "#3955" "https://github.com/gchq/stroom/issues/3955" >}}** : Add case expression function.

* Issue **{{< external-link "#4484" "https://github.com/gchq/stroom/issues/4484" >}}** : Change selection handling to use fully qualified keys.

* Issue **{{< external-link "#4456" "https://github.com/gchq/stroom/issues/4456" >}}** : Fix selection handling across multiple components by uniquely namespacing selections.

* Issue **{{< external-link "#4886" "https://github.com/gchq/stroom/issues/4886" >}}** : Fix ctrl+enter query execution for rules and reports.

* Issue **{{< external-link "#4884" "https://github.com/gchq/stroom/issues/4884" >}}** : Suggest only queryable fields in StroomQL where clause.

* Issue **{{< external-link "#4742" "https://github.com/gchq/stroom/issues/4742" >}}** : Allow embedded queries to be copies rather than references.

* Issue **{{< external-link "#4894" "https://github.com/gchq/stroom/issues/4894" >}}** : Plan B query without snapshots.

* Issue **{{< external-link "#4896" "https://github.com/gchq/stroom/issues/4896" >}}** : Plan B option to synchronise writes.

* Issue **{{< external-link "#4720" "https://github.com/gchq/stroom/issues/4720" >}}** : Add Plan B shards data source.

* Issue **{{< external-link "#4919" "https://github.com/gchq/stroom/issues/4919" >}}** : Add functions to format byte size strings.

* Issue **{{< external-link "#4901" "https://github.com/gchq/stroom/issues/4901" >}}** : Add advanced schema selection to Plan B to improve performance and reduce storage requirements.

* Issue **{{< external-link "#4945" "https://github.com/gchq/stroom/issues/4945" >}}** : Increase index field name length.
