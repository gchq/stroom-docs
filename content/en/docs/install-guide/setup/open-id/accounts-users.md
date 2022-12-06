---
title: "Accounts vs Users"
linkTitle: "Accounts vs Users"
weight: 10
date: 2022-11-25
tags: 
description: >
  The distinction between Accounts and Users in Stroom.
  
---

In Stroom we have the concept of Users and Accounts, and it is important to understand the distinction.


## Accounts

Accounts are user identities in the internal {{< glossary "identity provider idp" "Identity Provider (IDP)" >}}.
The internal IDP is used when you want Stroom to manage all the authentication.
The internal IDP is the default option and the simplest for test environments.
Accounts are not applicable when using an external 3rd party IDP.

Accounts are managed in Stroom using the _Manage Accounts_ screen available from the _Tools => _Users_ menu item.
An administrator can create and manage user accounts allowing users to log in to Stroom.

Accounts are for authentication only, and play no part in authorisation (permissions).
A Stroom user account has a unique identity that will be associated with a Stroom User to link the two together.

When using a 3rd party IDP this screen is not available as all management of users with respect to authentication is done in the 3rd party IDP.

Accounts are stored in the `account` database table.


## Stroom Users

A user in Stroom is used for managing authorisation, i.e. permissions and group memberships.
It plays no part in authentication.
A user has a unique identifier that is provided by the IDP (internal or 3rd party) to identify it.
This ID is also the link it to the Stroom _Account_ in the case of the internal IDP or the identity on a 3rd party IDP.

Stroom users and groups are managed in the `stroom_user` and `stroom_user_group` database tables respectively.
