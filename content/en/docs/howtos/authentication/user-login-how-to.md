---
title: "Login"
linkTitle: "Login"
#weight:
date: 2021-07-09
tags:
  - authentication
description: >
  This HOWTO shows how to log into the Stroom User Interface.
---

## Assumptions

The following assumptions are used in this document.
- for manual login, we will log in as the user `admin` whose password is set to `admin` and the password is pre-expired
- for PKI Certificate login, the Stroom deployment would have been configured to accept PKI Logins


## Manual Login 

Within the **Login** panel, enter `admin` into the *User Name:* entry box and `admin` into the *Password:* entry box as per

{{< screenshot "HOWTOs/UI-Login-01.png" >}}Stroom UI Login - logging in as admin{{< /screenshot >}}

When you press the {{< stroom-btn "Login" >}} button, you are advised that your user's password has expired and you need to change it.

{{< screenshot "HOWTOs/UI-Login-02.png" >}}Stroom UI Login - password expiry{{< /screenshot >}}

Press the {{< stroom-btn "Ok" >}} button and enter the old password `admin` and a new password with confirmation in the appropriate entry boxes.

{{< screenshot "HOWTOs/UI-Login-03.png" >}}Stroom UI Login - password change{{< /screenshot >}}

Again press the {{< stroom-btn "Ok" >}} button to see the confirmation that the password has changed.

{{< screenshot "HOWTOs/UI-Login-04.png" >}}Stroom UI Login - password change confirmation{{< /screenshot >}}.

On pressing {{< stroom-btn "Close" >}} you will be logged in as the `admin` user and you will be presented with the __Main Menu__ (`Item Tools Monitoring User Help`), and the `Explorer` and `Welcome` panels (or tabs).

{{< screenshot "HOWTOs/UI-Login-06.png" >}}Stroom UI Login - user logged in{{< /screenshot >}}

We have now successfully logged on as the `admin` user.

The next time you login with this account, you will not be prompted to change the password until the password expiry period has been met.


## PKI Certificate Login

To login using a PKI Certificate, a user should have their Personal PKI certificate loaded in the browser (and selected if
you have multiple certificates) and the user just needs to go to the Stroom UI URL, and providing you have an account, you will be
automatically logged in.

