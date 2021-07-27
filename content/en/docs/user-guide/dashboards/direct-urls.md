---
title: "Direct URLs"
linkTitle: "Direct URLs"
#weight:
date: 2021-07-27
tags: 
  - dashboard
description: >
  Navigating directly to a specific _Stroom_ dashboard using a direct URL.
---

It is possible to navigate directly to a specific _Stroom_ dashboard using a direct URL.
This can be useful when you have a dashboard that needs to be viewed by users that would otherwise not be using the _Stroom_ user interface.

## URL format

The format for the URL is as follows:

`https://<HOST>/stroom/dashboard?type=Dashboard&uuid=<DASHBOARD UUID>[&title=<DASHBOARD TITLE>][&params=<DASHBOARD PARAMETERS>]`

Example:

`https://localhost/stroom/dashboard?type=Dashboard&uuid=c7c6b03c-5d47-4b8b-b84e-e4dfc6c84a09&title=My%20Dash&params=userId%3DFred%20Bloggs`

### Host and path
The host and path are typically `https://<HOST>/stroom/dashboard` where `<HOST>` is the hostname/IP for _Stroom_.

### type
`type` is a required parameter and must always be `Dashboard` since we are opening a dashboard.

### uuid
`uuid` is a required parameter where `<DASHBOARD UUID>` is the UUID for the dashboard you want a direct URL to, e.g. `uuid=c7c6b03c-5d47-4b8b-b84e-e4dfc6c84a09`

The UUID for the dashboard that you want to link to can be found by right clicking on the dashboard icon in the explorer tree and selecting Info.

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

### title (Optional)
`title` is an optional URL parameter where `<DASHBOARD TITLE>` allows the specification of a specific title for the opened dashboard instead of the default dashboard name.

The inclusion of `${name}` in the title allows the default dashboard name to be used and appended with other values, e.g. `'title=${name}%20-%20' + param.name`

### params (Optional)
`params` is an optional URL parameter where `<DASHBOARD PARAMETERS>` includes any parameters that have been defined for the dashboard in any of the expressions, e.g. `params=userId%3DFred%20Bloggs`

## Permissions

In order for as user to view a dashboard they will need the necessary permission on the various entities that make up the dashboard.

For a Lucene index query and associated table the following permissions will be required:

* _Read_ permission on the _Dashboard_ entity.
* _Use_ permission on any _Indexe_ entities being queried in the dashboard.
* _Use_ permission on any _Pipeline_ entities set as search extraction _Pipelines_ in any of the dashboard's tables.
* _Use_ permission on any _XSLT_ entities used by the above search extraction _Pipeline_ entites.
* _Use_ permission on any ancestor pipelines of any of the above search extraction _Pipeline_ entites (if applicable).
* _Use_ permission on any _Feed_ entities that you want the user to be able to see data for.

For a SQL Statistics query and associated table the following permissions will be required:

* _Read_ permission on the _Dashboard_ entity.
* _Use_ permission on the _StatisticStore_ entity being queried.

For a visualisation the following permissions will be required:

* _Read_ permission on any _Visualiation_ entities used in the dashboard.
* _Read_ permission on any _Script_ entities used by the above _Visualiation_ entities.
* _Read_ permission on any _Script_ entities used by the above _Script_ entities.
