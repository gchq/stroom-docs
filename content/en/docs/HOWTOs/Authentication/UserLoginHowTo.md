---
title: "Login"
linkTitle: "Login"
#weight:
date: 2026-07-29
tags:
  - authentication
description: >
  This HOWTO shows how to log into the Stroom User Interface.
---

This walks through a first login as the default `admin` account.
For what happens behind these screens, and for account states, lockouts and password resets, see [Signing In]({{< relref "docs/user-guide/security/signing-in" >}}).


## Assumptions

- The deployment uses Stroom's internal {{< glossary "idp" >}}.
- The default `admin` account exists with the password `admin`.
  This account is only created when `stroom.security.identity.autoCreateAdminAccountOnBoot` is enabled, which is not the default.
  See [Internal IDP]({{< relref "docs/install-guide/setup/open-id/internal-idp" >}}).
- For certificate login, the deployment has `stroom.security.identity.allowCertificateAuthentication` enabled.


## Manual Login

Enter `admin` into the *User Name:* entry box and `admin` into the *Password:* entry box.

{{< screenshot "HOWTOs/UI-Login-01.png" >}}Stroom UI Login - logging in as admin{{< /screenshot >}}

Press the {{< stroom-btn "Login" >}} button.
As this is the account's first login, you are told the password must be changed before you can continue.

{{< screenshot "HOWTOs/UI-Login-02.png" >}}Stroom UI Login - password expiry{{< /screenshot >}}

Press {{< stroom-btn "Ok" >}}, then enter the old password `admin` and a new password with confirmation.
The new password must meet the configured password policy.

{{< screenshot "HOWTOs/UI-Login-03.png" >}}Stroom UI Login - password change{{< /screenshot >}}

Press {{< stroom-btn "Ok" >}} again to see the confirmation that the password has changed.

{{< screenshot "HOWTOs/UI-Login-04.png" >}}Stroom UI Login - password change confirmation{{< /screenshot >}}

On pressing {{< stroom-btn "Close" >}} you are logged in as the `admin` user, and are presented with the __Main Menu__, and the `Explorer` and `Welcome` panels.

{{< screenshot "HOWTOs/UI-Login-06.png" >}}Stroom UI Login - user logged in{{< /screenshot >}}

You will not be asked to change this password again until it reaches the age set by `stroom.security.identity.passwordPolicy.mandatoryPasswordChangeDuration`.


## Certificate Login

Load your personal PKI certificate into your browser, selecting it if you hold more than one, then go to the Stroom UI URL.
Provided you have an account, you are logged in without being asked for a password.

{{% see-also %}}
[Signing In]({{< relref "docs/user-guide/security/signing-in" >}})
[User Accounts]({{< relref "docs/user-guide/security/user-accounts" >}})
{{% /see-also %}}
