---
title: "New Features"
linkTitle: "New Features"
weight: 10
date: 2025-09-23
tags: 
description: >
  New features in Stroom version 7.10.
---

## Dashboard & StroomQL Functions

### `ceilingTime(..)` & `floorTime(...)` & `roundTime(...)`

Three new functions similar to the existing [`ceilingXXX`]({{< relref "docs/reference-section/expressions/date#ceiling-yearmonthdayhourminutesecond" >}}) and [`floorXXX`]({{< relref "docs/reference-section/expressions/date#floor-yearmonthdayhourminutesecond" >}}) functions, except that an arbitrary duration can be used.

For example, `floorTime($time, 'PT5m')` will floor the time to the latest time that is divisible by 5 minutes.


### `case(...)`

A `case` function has been added for performing simple `if...else if....else if.....end` type logic.
The function takes the arguments:

```
case(input, test1, result1, testN, resultN, otherwise)
```

This is equivalent to
```
if (input == test1) {
    return result1
} else if (input == testN) {
    return resultN
} else {
    return otherwise
}
```

See [case]({{< relref "docs/reference-section/expressions/logic#case" >}}) for details.


### `formatIECByteSize(...)`

A new function for converting an integer amount of bytes into an appropriate byte size unit, e.g. `1024` bytes becomes `1K`.
International Electrotechnical Commission (IEC) units with a base of `1024` rather than `1000` are used.

The function has three forms:

```text
formatIECByteSize(bytes)
formatIECByteSize(bytes, omitTrailingZeros)
formatIECByteSize(bytes, omitTrailingZeros, significantFigures)
```


### `formatMetricByteSize(...)`

A new function for converting an integer amount of bytes into an appropriate byte size unit, e.g. `1000` bytes becomes `1K`.
Metrix units with a base of `1000` rather than `1024` are used.

The function has three forms:

```text
formatMetricByteSize(bytes)
formatMetricByteSize(bytes, omitTrailingZeros)
formatMetricByteSize(bytes, omitTrailingZeros, significantFigures)
```


### `decode(...)`

The existing [`decode(...)`]({{< relref "docs/reference-section/expressions/string#decode" >}}) function has been changed so that you can use any capture groups in the regular expression patterns in the result arguments.
For example:

```clike
decode('TestString123','Test(.....)(123)','$1-$2','Nothing')
```

Which would output `String-123`.


### `data(...)`

The existing [`data(...)`]({{< relref "docs/reference-section/expressions/link#data" >}}) function has been changed so that you can display the stream info and metadata instead of the stream data by setting the `viewType` argument to a value of `info`.

For example:

```clike
data('View Cooked', ${StreamId}, 1, ${eventId}, null(), null(), null(), null(), 'info')
```

### `isWeekend(..)`

Returns whether a date and time is part of the weekend or not.

For example:

```clike
isWeekend('2026-02-04T12:45:11.000Z') returns false
isWeekend('2026-02-01T12:45:11.000Z') returns true
```


## Dashboard Embedded Queries

When creating an Embedded Query Dashboard pane, it is now possible to embed a copy of an existing query rather than embedding a reference to one.
This decouples the Dashboard from the original Query so the original Query can be changed without impacting the Dashboard.

The embedded Query can be edited via the menu on the Dashboard pane.


## Stroom XSLT Functions

### `parse-dateTime(...)`

A `parse-dateTime` function has been added with the following overloads:

```text
parse-dateTime(ISO8601 string)
parse-dateTime(string, pattern)
parse-dateTime(string, pattern, timezone)
```

This function will either parse a date/time string in {{< glossary "ISO8601" >}} standard date/time format or in a custom date/time format using the supplied pattern and optional timezone.

For details of the pattern syntax see [Custom Date Formats]({{< relref "docs/reference-section/dates#custom-date-formats" >}}).

All forms of the function return an `xs:dateTime` value for use by standard XSLT/XPath functions that can consume an `xs:dateTime` value.


### `format-dateTime(...)`

A `format-dateTime` function has been added with the following overloads:

```text
format-dateTime(DateTimeValue)
format-dateTime(DateTimeValue, pattern)
format-dateTime(DateTimeValue, pattern, timezone)
```

All three variants take an `xs:dateTime` value as the first argument.
If only one argument is supplied, the function will output the date/time as a standard {{< glossary "ISO8601" >}} format `xs:string`.
If two or more arguments are supplied then it will output the date/time formatted using the specified [pattern]({{< relref "docs/reference-section/dates#custom-date-formats" >}}) and optionally using the specified timezone.
If no timezone is supplied, the date/time is assumed to be in {{< glossary "UTC" >}}.


### Meta Functions

The following functions have been added for obtaining meta-data relating to the stream being processed or specified streams.

* `manifest()` - Returns manifest attributes for current stream
* `manifest-for-id(streamId)` - Returns manifest attributes for specified stream
* `meta-stream()` - Returns meta stream for current stream
* `meta-stream-for-id(streamId, partNo)` - Returns meta stream for specified stream and part no
* `parent-id()` - Gets parent ID for current stream
* `parent-for-id(streamId)` - Get parent Stream ID for specified stream


## Content Templates

When creating a content template of type `INHERIT_PIPELINE` it is now possible to tick a box so that any dependencies of the pipeline being inherited from (e.g. Data Splitter TextConverter documents or XsltFilter XSLT documents) will be copied as siblings of the generated Pipeline  {{< stroom-icon "document/Pipeline.svg" "title">}}.

This allows the Data Splitter or XSLT to be refined/populated for the new content.


## Index Shards Searchable

The _IndexShards_ {{< glossary "Searchable" >}} has been changed to add the fields `Shard Id` and `Index Version` to the list of available fields.

* `Shard Id` - This is the ID of the shard within the index.
* `Index Version` - This is the Lucene version that this index was created with.
  Currently Stroom supports two different versions of the Lucene search index.


## Plan B Changes

Plan B has evolved in 7.10 as a state store capable of storing the following types of state data:

* State - For a given key provide an unchanging state value.
* Temporal State - For a given key provide a state value valid at a specific point in time (similar to reference data).
* Ranged State - For a given numeric key within a key range provide an unchanging state value.
* Temporal Ranged State - For a given numeric key within a key range provide a state value valid at a specific point in time (similar to reference data for ranges).
* Session - Record session start and end times, e.g. maintain sessions for each application used by a specific user.
* Metrics - Record values at points in time, e.g. CPU use %.
* Histograms - Record counts over time, e.g. number of records per minute, hour etc.

Although still somewhat experimental, Plan B has undergone significant change in 7.10 following feedback from the previous experimental release.
The data structure has changed significantly to reduce data store sizes.
All previous Plan B LMDB instances must be deleted before this new version can be used.

In addition to data structure changes the following features are now available:

* Additional Plan B store types for histograms and metrics.
* Advanced Plan B storage schema settings for specific use cases to improve storage efficiency and performance.
* Better data retention options allowing for retention based on insert time.
* Remote query settings for `get()` and `lookup()` requests to avoid the need for local snapshots.
* Plan B shards can now be queried as a {{< glossary "Searchable" >}} data source to discover stored data and information.
* Writes can now be synchronised if needed to ensure data presence before query.
  This option impacts data processing performance.


## Improved Dashboard Context

Dashboards now maintain a global context that is available to all dashboard components.
The context keeps track of the selection state of each component plus dashboard parameters and time range setting.
Context changes can be handled by certain components such as queries and tables by adding selection handlers.
Handlers allow components to respond to context changes, e.g. by filtering a table based on a selection in another table.


## Annotation Changes

Annotations have been improved in 7.10 and more improvements will be available in 7.11.

For 7.10 the following changes have been made:
* The annotation edit presenter has been improved so that the layout is clearer.
* Annotations now have fine-grained permissions for visibility and edit.
* Creating annotations can now be performed on multiple events just by selecting the events and clicking the annotate button.
* Users can define custom annotation states.
* Custom labels and collections can defined and added to annotations.
* All states and labels have visibility permissions.
* An annotations screen is now available for easier annotation browsing. 
* Annotations can now have retention periods.


## Open ID Connect Authentication

Various minor changes to the way Open ID Connect authentication is performed.


### Audience Validation

Replace the property `stroom.security.authentication.openid.validateAudience` with `stroom.security.authentication.openid.allowedAudiences` (defaults to empty) and `stroom.security.authentication.openid.audienceClaimRequired` (defaults to false).
If the IDP is known to provide the `aud` claim (often populated with the `clientId`) then set `allowedAudiences` to contain that value and set `audienceClaimRequired` to `true`.


### User Full Name

Add the config prop `stroom.security.authentication.openId.fullNameClaimTemplate` to allow the user's full name to be formed from a template containing a mixture of static text and claim variables, e.g. `${firstName} ${lastName}`.
Unknown variables are replaced with an empty string. Default is `${name}`.

This provides full control over the source of the user's full name in stroom and allows it to be formed from multiple claims within the authentication token.


### AWS Integration

Change template syntax of `openid.publicKeyUriPattern` property from positional variables (`{}`) to named variables (`${awsRegion}`).
Default value has changed to `https://public-keys.auth.elb.${awsRegion}.amazonaws.com/${keyId}`.
If this property has been explicitly set in the config.yml or Properties screen, its value will need to be changed to use named variables instead.


### Certificate DN Format

Add new property `.receive.x509CertificateDnFormat` to stroom and proxy to allow extraction of CNs from DNs in legacy `OPEN_SSL` format.
The new property defaults to `LDAP`, which means no change to behaviour if left as is.


## Stroom-Proxy ZIP File Ingest

To make it easier to deal with ZIP files that Stroom-Proxy has failed to forward, Stroom-Proxy now has a ZIP file ingest mechanism.
This mechanism can also be used as an additional means of passing data into Stroom-Proxy (instead of `/datafeed`).
This is controlled by the following new configuration branch (default values shown):

```yaml
proxyConfig:

  dirScanner:
    # The directories to scan for ZIP files. Scanned in this order.
    dirs:
      - "zip_file_ingest"
    # If false, no directory scanning is performed.
    enabled: true
    # The directory to move unknown/failed files to.
    failureDir: "zip_file_ingest_failed"
    # The frequency that the directories are scanned.
    scanFrequency: "PT1M"
```

A typical case scenario is that some data has failed to send to Stroom and the retry age has been reached so the ZIP has been moved to the forward failure directory:

Contents of `data/50_forwarding/downstream/`

```text
./03_failure/20251014/BAD_FEED/0/001/proxy.zip
./03_failure/20251014/BAD_FEED/0/001/proxy.meta
./03_failure/20251014/BAD_FEED/0/001/error.log
```

If you wish to re-send this ZIP you can do the following:

{{< command-line >}}
mv data/50_forwarding/downstream/03_failure/20251014/BAD_FEED/0/001 "./zip_file_ingest/${uuidgen)"
{{</ command-line >}}

This will move the `001` directory into `zip_file_ingest/`, renaming it to a unique {{< glossary "UUID" >}} to ensure it doesn't clash with any existing files/directories.
The name of this directory in the ingest directory has no bearing on processing, other than the order in which directories are scanned.

On the next scan, Stroom-Proxy will discover the `proxy.zip` file.
It will check for the presence of any of the optional associated files (i.e. `proxy.meta` and `error.log`).
The entries in the `.meta` file will be consumed.
The `error.log` file will be deleted following successful ingest.

Stroom-Proxy will scan into all sub-directories within the ingest directory, regardless of depth.

The `.meta` sidecar file is optional, but if provided will be used to provide meta values equivalent to HTTP headers when sending to `/datafeed`.
For a `.meta` file to be consumed, it must have the same base-name as the ZIP file, e.g. `data.zip` and `data.meta`, and be in the same directory as the ZIP file.

{{% warning %}}
Stroom-Proxy may be scanning at the same time as you are moving files in to the `zip_file_ingest` directory.

Therefore, it is important that if you are supplying sidecar files that you move a parent directory rather than the files themselves (as is shown in the above `mv` example).
This will ensure that the move happens atomically, so all files will be visible to the scanner.
{{% /warning %}}

