---
title: "User Accounts"
linkTitle: "User Accounts"
weight: 20
date: 2024-11-01
tags:
  - authentication
  - user
  - account
description: >
  User accounts for authentication when using Stroom's internal identity provider.
---

{{% note %}}
If Stroom is configured to use an external Identity Provider (e.g. Azure Active Directory or AWS Cognito) then all user accounts are managed within that Identity Provider and the Manage Accounts screen in Stroom will not be available.
{{% /note %}}

## Accounts vs Stroom Users

There is a distinction between User Accounts in Stroom and Stroom Users (as see on the [Document Permission]({{< relref "doc-permissions" >}}) and [Application Permission]({{< relref "app-permissions" >}}) screens).


### User Account

A user account is only used for authenticating a human user against some credentials stored in Stroom (i.e. a username, password and or certificate details).
If you are not using an external Identity Provider





