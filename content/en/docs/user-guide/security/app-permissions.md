---
title: "Application Permissions"
linkTitle: "Application Permissions"
weight: 40
date: 2024-11-01
tags:
  - permission
  - authorisation
description: >
  Assigning application level permssions (such as 'Manage Users') to users or groups.
---

{{% todo %}}
The Users, Groups and Permissions screens are undergoing significant change in Stroom v7.6.
Therefore this section will be updated with more detail in v7.6.
{{% /todo %}}

An Application Permission is a permission to perform an action that is not associated with a single {{< glossary "Document" >}} or is unrelated to Documents.
Application Permissions can be granted to [Users or Groups]({{< relref "users-and-groups" >}}).

In order to grant Application Permissions to yourself or to other Users/Groups you must have the `Manage Users` or `Administrator` Application Permissions.
If you have one of these permissions then you can access the Application Permissions screen from the main menu:

{{< stroom-menu "Security" "Application Permissions" >}}


## Application Permission Types

The following is the list of different application permissions that can be granted to users/groups.

| Permission | Description |
| ---------- | ----------- |
| **Administrator** | Full administrator rights to access and manage all data, documents and screens, i.e. **everything**. |
| **Annotations** | Create and view annotations in query results. |
| **Change Owner** | Change the ownership of a document or folder to another user. |
| **Data - Delete** | Delete streams. |
| **Data - Export** | Download/export streams from a feed. |
| **Data - Import** | Upload stream data into a feed. |
| **Data - View** | View stream data (e.g. in the Data Viewer or a Dashboard text pane |
| **Data - View With Pipeline** | View data in a _Dashboard_ text pane that uses a pipeline. |
| **Download Search Results** | Download search result data on a _Dashboard_. |
| **Export Configuration** | Export {{< glossary "content" >}} (i.e. documents, that you have permission to view) to a file. |
| **Import Configuration** | Import {{< glossary "content" >}} from a file. |
| **Manage API Keys** | Access the _API Keys_ screen to view, create, edit, delete the user's own API keys. 'Manage Users' permission is also required to managed other users API keys |
| **Manage Cache** | Access the _Caches_ screen to view and clear system caches. |
| **Manage DB** | Access the _Monitoring_ -> _Database Tables_ screen to view the state of the tables in the database. |
| **Manage Index Shards** | Access the _Shards_ sub-tab on an Index {{< stroom-icon "document/Index.svg" >}} document. |
| **Manage Jobs** | Access the _Jobs_ screen to manage Stroom's background jobs. |
| **Manage Nodes** | Access the _Nodes_ screen to view the nodes the cluster and manage their priority and enabled states. |
| **Manage Policies** | Access the _Data Retention_ screen to manage data retention rules. |
| **Manage Processors** | Access the _Processors_ tab and manage the processors/filters used to process stream data through pipelines. |
| **Manage Properties** | Access to the _Properties_ to manage the system configuration. |
| **Manage Tasks** | Access the _Server Tasks_ screen to view/stop tasks running on the nodes. |
| **Manage Users** | Access the screens to manage users, groups, document/application permissions. Also gives the user the ability to manage API keys for other users. |
| **Manage Volumes** | Access the _Data Volumes_ and _Index Volumes_ screens to create/edit/delete the index/data volumes used for Lucene indexing and the stream store. |
| **Pipeline Stepping** | Step data through a pipeline using the Stepper. |
| **View System Information** | Use the System Information API. This is used by the administrators for viewing some of the internal working of Stroom to aid in debugging issues. |
