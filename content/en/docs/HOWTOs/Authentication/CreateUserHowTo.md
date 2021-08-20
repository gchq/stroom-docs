---
title: "Create a user"
linkTitle: "Create a user"
#weight:
date: 2021-07-09
tags:
  - users
description: >
  This HOWTO provides the steps to create a user via the Stroom User Interface.
---

## Assumptions

The following assumptions are used in this document.

- An account with the `Administrator` Application [Permission]({{< relref "../../user-guide/roles.md" >}}) is currently logged in.
- We will be adding the user `burn`
- We will make this user an `Administrator` 

## Add a new user

To add a new user, move your cursor to the `Tools` item of the __Main Menu__ and select to bring up the `Tools` sub-menu.

{{< screenshot "HOWTOs/UI-ToolsSubmenu-00.png" >}}Stroom UI Tools sub-menu{{< /screenshot >}}

then move down and select the `Users and Groups` sub-item to be presented with the `Users and Groups` configuration window as seen below.

{{< screenshot "HOWTOs/UI-AddUser-00.png" >}}Stroom UI New User - Users and Groups configuration{{< /screenshot >}}

To add the user, move the cursor to the _New_ icon {{< stroom-icon "add.svg" "Add" >}} in the top left and
select it. On selection you will be prompted for a user name. In our case we will enter the user `burn`.

{{< screenshot "HOWTOs/UI-AddUser-01.png" >}}Stroom UI New User - Add User{{< /screenshot >}}

and on pressing
{{< screenshot "HOWTOs/icons/buttonOk.png" >}}Stroom UI OkButton{{< /screenshot >}}
will be presented with the User configuration window.

{{< screenshot "HOWTOs/UI-AddUser-02.png" >}}Stroom UI New User - User configuration{{< /screenshot >}}

### Set the User Application Permissions

See 
[Permissions](../../../user-guide/roles "Stroom Application Permissions")
for an explanation of the various Application Permissions a user can have.

#### Assign an Administrator Permission

As we want the user to be an administrator, select the __Administrator__ Permission check-box

{{< screenshot "HOWTOs/UI-AddUser-03.png" >}}Stroom UI New User - User configuration - set administrator permission{{< /screenshot >}}

#### Set User's Password

We need to set `burn's` password (which he will need to reset on first login). So, select the
{{< screenshot "HOWTOs/icons/buttonResetPassword.png" >}}Stroom UI ResetPasswordButton{{< /screenshot >}}
button to gain the Reset Password window

{{< screenshot "HOWTOs/UI-AddUser-04.png" >}}Stroom UI New User - User configuration - reset password{{< /screenshot >}}

After setting a password and pressing the
{{< screenshot "HOWTOs/icons/buttonOk.png" >}}Stroom UI OkButton{{< /screenshot >}}
button we get the informational Alert window as per

{{< screenshot "HOWTOs/UI-AddUser-05.png" >}}Stroom UI New User - User configuration - reset password complete{{< /screenshot >}}

and on close of the Alert we are presented again with the `User` configuration window.

{{< screenshot "HOWTOs/UI-AddUser-06.png" >}}Stroom UI New User - User configuration - user added{{< /screenshot >}}

We should close this window by pressing the 
{{< screenshot "HOWTOs/icons/buttonClose.png" >}}Stroom UI CloseButton{{< /screenshot >}} button to be presented with the `Users and Groups` window with the new user `burn` added.

{{< screenshot "HOWTOs/UI-AddUser-07.png" >}}Stroom UI New User - User configuration - show user added{{< /screenshot >}}

At this, one can close the `Users and Groups` configuration window by pressing the 
{{< screenshot "HOWTOs/icons/buttonClose.png" >}}Stroom UI CloseButton{{< /screenshot >}}
button at the bottom right of the window.
