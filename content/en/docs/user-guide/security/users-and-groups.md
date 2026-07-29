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

A Stroom User represents a human user and is linked to either a User Account in Stroom or to a user account in an external {{< glossary "idp" >}}.
It can also represent a non-human processing user, e.g. where a Stroom User is created and has an {{< glossary "API Key" >}} created for it to allow a client system to use Stroom's {{< glossary "API" >}}.

All audited activity in Stroom will be attributed to a Stroom User and their unique identifier will be included in the audit events.

A User can have the following:

* Membership of one or more Groups.
* One or more {{< glossary "Application Permission" "Application Permissions" >}} granted to it.
* One or more {{< glossary "Document Permission" "Document Permissions" >}} granted to it.


## Enabling and Disabling a User

A User can be enabled or disabled using the _Enabled_ tick box on the user, reached by selecting

{{< stroom-menu "Security" "Users" >}}

from the main menu and opening the user.
This requires the `Manage Users` or `Administrator` {{< glossary "Application Permission" >}}.

Disabling a User is the strongest single action available against a person.
It takes effect at once and does three things:

* Every session they hold is ended, across every node in the cluster.
* Every token issued to them is revoked.
* They are refused at authentication from then on, whether signing in interactively or presenting a token.

This is distinct from disabling their _Account_, which only prevents them signing in and leaves any session already running untouched.
An Account exists only where Stroom is its own {{< glossary "idp" >}}, whereas every person has a Stroom User whichever {{< glossary "idp" >}} is in use, so disabling the User is the action that works in all deployments.

See [Sessions and Tokens]({{< relref "sessions-and-tokens" >}}) for how this compares with simply ending someone's sessions, and [User Accounts]({{< relref "user-accounts" >}}) for the Account states.


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

