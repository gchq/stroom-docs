# Dashboard Direct URLs

It is possible to navigate directly to a specific _Stroom_ dashboard using a direct URL.
This can be useful when you have a dashboard that needs to be viewed by users that would otherwise not be using the _Stroom_ user interface.

## URL format

The format for the URL is as follows:

`https://<HOST>/stroom/dashboard?type=Dashboard&uuid=<DASHBOARD UUID>`

Where `<HOTST>` is the hostname/IP for for _Stroom_ and `<DASHBOARD UUID>` is the UUID for the dashboard you want a direct URL to.
The UUID for the dashboard can be found by right clicking on the dashboard icon in the explorer tree and selecting Info.
The Info dialog will display something like this and the UUID can be copied from it:

```
DB ID: 4
UUID: c7c6b03c-5d47-4b8b-b84e-e4dfc6c84a09
Type: Dashboard
Name: Stroom Family App Events Dashboard
Created By: INTERNAL
Created On: 2018-12-10T06:33:03.275Z
Updated By: admin
Updated On: 2018-12-10T07:47:06.841Z
```

## Permissions

In order for as user to view a dashboard they will need the necessary permission on the various entities that make up the dashboard.

For a Lucene index query the following permissions will be required:

* _Read_ permission on the Dashboard
* _Use_ permission on the Index being queried
* _Use_ permission on the Index being queried
* _Use_ permission on the search extraction pipeline used in the dashboard
* _Use_ permission on the XSLT used by the search extraction pipeline
* _Use_ permission on ancestor pipelines (if the search extraction pipeline inherits from other pipelines)

For a SQL Statistics query the following permissions will be required:

* _Read_ permission on the Dashboard
* _Use_ permission on the StatisticStore being queried

