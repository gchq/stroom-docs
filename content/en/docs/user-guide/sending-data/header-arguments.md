---
title: "Header Arguments"
linkTitle: "Header Arguments"
#weight:
date: 2021-07-27
tags:
  - headers
  - http
description: >
  The various HTTP headers that can be sent with data.
---

The following data must be passed in as HTTP header arguments when sending files to Stroom via HTTP POST. These arguments are case insensitive.

* `System` - The name by which the system is known within the organisation, e.g. `PAYROLL_SYSTEM`. This could be the name of a project/service or capability.

* `Environment` - A means to identify the deployed instance of a system. This may indicate the deployment status, e.g. DEV, REF, LIVE, OPS, etc., and/or the location where the instance is deployed. An environment may be a combination of these attributes separated with an underscore.

* `Feed` - The name of the feed this data relates to. This is mandatory and must match a feed defined within Stroom in order for Stroom to accept the data and know what to do with it.

* `Compression` - This token is optionally used when the POST payload is compressed with either gzip of zip compression. Value of `ZIP` and `GZIP` are valid. **Note**: The `Compression` token MUST not be used in conjunction with the standard HTTP header token `Content-Encoding` otherwise stroom will be unable to un-compress the data. Use either `Compression:GZIP` or `Content-Encoding:gzip`, not both. Using `Compression` is preferred.

* `EffectiveTime` - This is only applicable to reference data. It is used to indicate the point in time that the reference data is applicable to, i.e. all event data that uses the reference data that is created after the effective time will use the reference data until a new reference data item arrives with a later effective time. **Note**: This argument must be in _ISO 8601_ date time format, i.e: `yyyy-MM-ddTHH:mm:ss.sssZ`.

Example header arguments for a feed called _MY_SYSTEM-EVENTS_ from system _MY_SYSTEM_ and environment _OPS_

```text
System:MY_SYSTEM
Environment:OPS
Feed:MY_SYSTEM-EVENTS
```

The post payload must contain the events file. If the compression format is ZIP the payload must contain ZIP entries with the events files and optional context files ending in .ctx. Further details of supported payload formats can be found [here]({{< relref "payloads.md" >}}).
