---
title: "Security"
linkTitle: "Security"
weight: 130
date: 2024-11-01
tags: 
description: >
  All aspects of securing Stroom and the content within it.
  Includes application security, user and group accounts and the permissions model.
---

Stroom has a multi-layered security model covering both application-level permissions and fine-grained document permissions.

* [User Accounts]({{< relref "user-accounts" >}}) — creating and managing user accounts (when using Stroom's internal identity provider).
* [Users and Groups]({{< relref "users-and-groups" >}}) — organising users into groups to simplify permission management.
* [Application Permissions]({{< relref "app-permissions" >}}) — controlling which users or groups can access high-level Stroom functionality.
* [Document Permissions]({{< relref "doc-permissions" >}}) — controlling access to individual content items (feeds, pipelines, indexes, etc.) in the explorer tree.

{{% note %}}
If Stroom is configured to use an external Identity Provider (IDP) such as KeyCloak or Cognito, user accounts are managed in the IDP rather than in Stroom directly.
See [External IDP]({{< relref "/docs/install-guide/setup/open-id/external-idp" >}}) for setup details.
{{% /note %}}

