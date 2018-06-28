# HTTP POST Header Arguments

The following data must be passed in as HTTP header arguments when sending files to Stroom via HTTP POST. These arguments are case insensitive.

* System - The name by which the system is known within the organisation. This could be the name of a project/service or capability.
* Environment - A means to identify the deployed instance of a system. This may indicate the deployment status, e.g. DEV, REF, LIVE, and/or the location where the instance is deployed. An environment may be a combination of these attributes separated with an underscore.
* Feed - The name of the feed this data relates to. This is mandatory and must match a feed defined within Stroom in order for Stroom to accept the data and know what to do with it.
* Compression - Optional compression used in the post payload ("ZIP" or "GZIP")
* EffectiveTime - This is only applicable to reference data. It is used to indicate the point in time that the reference data is applicable to, i.e. all event data that uses the reference data that is created after the effective time will use the reference data until a new reference data item arrives with a later effective time.

''This argument must be in ISO 8601 date time format: yyyy-MM-ddTHH:mm:ss.sssZ.''

Example header arguments for a feed called MYFEED-EVENTS from system MYSYSTEM and environment MYENV:

```
System:MYFEED
Environment:MYENV
Feed:EXAMPLE-EVENTS
```

The post payload must contain the events file. If the compression format is ZIP the payload must contain ZIP entries with the events files and optional context files ending in .ctx. Further details of supported payload formats can be found [here](payloads.md).
