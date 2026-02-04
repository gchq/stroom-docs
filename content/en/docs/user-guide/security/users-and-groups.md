---
title: "Users and Groups"
linkTitle: "Users and Groups"
weight: 40
date: 2024-11-01
tags:
  - user
  - group
  - authorisation
description: >
  The Stroom user and group entities that can be granted application and document permissions.
---

{{% todo %}}
The Users, Groups and Permissions screens are undergoing significant change in Stroom v7.6.
Therefore this section will be updated with more detail in v7.6.
{{% /todo %}}


## Accounts vs Stroom Users

See [Accounts vs Users]({{< relref "docs/install-guide/setup/open-id/accounts-users" >}}) for details on the difference between a Stroom User Account and a Stroom User.


## User

A Stroom User represents a human user and is linked to either a User Account in Stroom or to a user account in an external {{< glossary "Identity Provider IDP" "Identity Provider" >}}.
It can also represent  non-human processing user, e.g. where a Stroom User is created and has an {{< glossary "API Key" >}} created for it to allow a client system to use Stroom's {{< glossary "API" >}}.

All audited activity in Stroom will be attributed to a Stroom User and their unique identifier will be included in the audit events.

A User can have the following:

* Membership of one or more Groups.
* One or more {{< glossary "Application Permission" "Application Permissions" >}} granted to it.
* One or more {{< glossary "Document Permission" "Document Permissions" >}} granted to it.


## Group

A Group represents a collection of Stroom Users and/or other Groups.
A Group can be used to ease the management of application and document permissions by granting permissions to one Group then adding users to that Group.
For example if all the users in a team require the same application and document permissions, then a Group can be created for them and the permissions assigned to the Group.
When a user joins or leaves the team it is simply a case of editing the membership of the Group.

A Group can have the following:

* One or more members (Users and/or other Groups).
* Membership of one or more other Groups.
* One or more {{< glossary "Application Permission" "Application Permissions" >}} granted to it.
* One or more {{< glossary "Document Permission" "Document Permissions" >}} granted to it.

