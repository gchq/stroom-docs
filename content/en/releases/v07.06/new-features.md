---
title: "New Features"
linkTitle: "New Features"
weight: 10
date: 2025-01-30
tags: 
description: >
  New features in Stroom version 7.6.
---

## Document and Application Permissions

The document and permissions model has undergone significant changes.
Both the user interface and underlying data model has changed.

The legacy screens for managing users, groups and their permissions were often very confusing to use.
The new screens attempt to make it much more intuitive.

### Terminology

* _Explicit_ / _Direct_ - This means a permission is specifically granted to the User/Group in question.
* _Inherited_ / _Effective_ - This means a permission is granted to the Group that a User/Group is a member of or is granted to an ancestor Group.


### Groups of Groups

Previously in Stroom it was not possible for a Group to be a member of a Group.
This has been changed so now a Group's membership can include both Users and Groups.
This allows a richer permissions structure to be created.

For example you can have a _Basic Users_ group that has limited application permissions and a _Super Users_ group that is a member of _Basic Users_ so it inherits all the basic permissions and adds its own set of explicit permissions.


### Users Screen

A Users screen has been added to list all {{< glossary "user" "Stroom Users" >}} (as distinct from {{< glossary "account" "Accounts" >}}.
This screen is only available to users that hold the `Manage Users` application permission.
It is accessible from:

{{< stroom-menu "Security" "Users" >}}

Or the key bind {{< key-bind "g" "g" >}}.

{{< image "releases/07.06/Users.png" "900x" >}}The Users screen{{</ image >}}

It lists all users and allows the user to jump to various other screens relating to that user.

{{< image "releases/07.06/UsersContextMenu.png" "900x" >}}The context menu on the Users screen{{</ image >}}

It is also possible to jump to User screen for a specific user by clicking the {{< stroom-icon "open.svg" "Open User">}} hover icon.


### Groups Screen

A Groups screen has been added for managing {{< glossary "group-users" "User Groups" >}} and their memberships.
It is accessible from:

{{< stroom-menu "Security" "User Groups" >}}

Or the key bind {{< key-bind "g" "g" >}}.

{{< image "releases/07.06/Groups.png" "900x" >}}The Groups screen{{</ image >}}

This screen is split into two or three panes depending on whether you have selected a User or Group in the top pane.
The top pane lists all users {{< stroom-icon "user.svg" >}} and groups {{< stroom-icon "users.svg" "User Group" >}} in stroom, with the icon indicating the type.
In this pane you can add/edit Groups.

If you have selected a User {{< stroom-icon "user.svg" >}} then you will see only two panes.
The bottom pane will display all the Groups that the user is a direct member of, i.e. one that they have been explicitly added to.
This pane can be used to add the selected User to another Group or to remove them from a Group that they are already a member of.

If you have selected a Group {{< stroom-icon "users.svg" "Group">}} in the top pane then you will see three panes.

The bottom left pane will show Groups that the selected Group is a direct member of.
This pane can be used to add the selected Group to another Group or to remove them from a Group that they are already a member of.

The bottom right pane will show all direct members of the selected Group.
It can be used to add/remove members, be they Users or Groups.


### Application Permissions Screen

This screen has been added to manages the application level permissions that are granted to Users/Groups.
It replaces the previous modal dialog screen.
It is accessible from:

{{< stroom-menu "Security" "Application Permissions" >}}

Or the key bind {{< key-bind "g" "a" >}}.

{{< image "releases/07.06/AppPerms.png" "900x" >}}The Application Permissions screen{{</ image >}}

This screen is split into three panes.

* Top pane - Lists the Users and Groups, depending on the selection in the Permission Visibility drop-down.
  The Permission Visibility has the following values:
  * `Show Explicit` - Shows only those Users/Groups that have at least one application permission explicitly granted to them.
  * `Show Effective` - Shows only those Users/Groups that have at least one application permission explicitly granted to them or to a group that they are a member of (directly or indirectly).
  * `Show All` - Shows all Users/Groups.
  The _Permissions_ column lists all the permissions granted to the User/Group, explicitly or otherwise.
  Permissions that are not explicitly granted are greyed out.

* Middle pane - Lists **ALL** application permissions whether granted or not along with a checkbox next to each one to indicate/control the granted state.
  This is a three state check box:
  * Empty - The permission is not granted to the User/Group.
  * Half Ticked - The permission has been granted to a Group that the selected User/Group is a member or (directly or otherwise).
  * Ticked - The permission has been explicitly granted to the selected User/Group.
  This pane allows the user to modify the explicit application permissions for the selected user.
  If a permission is inherited from the membership of a Group, the user may make grant the permission explicitly, but they cannot remove the inherited grant except by modifying the explicit grants of the ancestor group.

* Bottom pane - Provides the detail for the currently selected permission in the middle pane.
  If the currently selected User/Group holds the permission indirectly, it will details which of the ancestor groups have been granted that permission explicitly.


### Document Permissions

#### Permission Names

The permission names have changed as follows:

* `Use` => `Use` - Can use a document without being able to view it, e.g. using an Index as part of a search process, but not being able to view the Index.
* `Read` => `View` - Can see the document in the explorer tree and open it to view its contents.
* `Update` => `Edit` - Can open and edit documents.
* `Delete` => `Delete` - Can delete documents.
* `Owner` => `Owner` - Can change the permissions of the document, e.g. granting access to other Users/Groups.
  A document can have more than one owner.
  `Owner` will automatically be granted to a user when they create a document.

{{% note %}}
Each permission in the list above inherits the permissions of the one above it in the list.
{{% /note %}}

A document now has only one permission granted per user (excluding the create permissions).
Previously a User/Group could be granted multiple, e.g. `Use` and `Read`.
Now a User/Group can have only one permission or no permission at all, so in the previous example they would now hold `View` (formally `Read`).


#### Document Permissions Screen

A new screen has been added for managing document permissions.
It is accessible from:

{{< stroom-menu "Security" "Document Permissions" >}}

{{< image "releases/07.06/DocPerms.png" "900x" >}}The Document Permissions screen{{</ image >}}

This screen lists all the documents that the current user has `View` permission on.
The {{< stroom-icon "filter.svg" >}} button can be used to filter the list of documents for making batch changes to the permissions.

The {{< stroom-icon "generate.svg" "Batch Edit Permissions">}} button allows you to make batch changes to the filtered list of Users/Groups.

{{< image "releases/07.06/DocPerms_BatchEdit.png" "500x" >}}The Batch Change Permissions screen{{</ image >}}

The _Batch Change Permissions_ screen provides a number of different idempotent operations (i.e. can be repeated with no change in effect) that can be performed.

For example having filtered the list, you could do a _Set permission_ change to grant `View` permission to user _jbloggs_.
_jbloggs_ will now have `View` permission on all documents in that filtered list, regardless of whether they previously had a lower or higher permission.

The options for making batch changes are as follows:

* _Set permission_ - Set a specific User/Group permission.
* _Add permission to create_ - Add permission to create documents in the selected folders.
* _Remove permission to create_ - Remove permission to create documents in the selected folders.
* _Add permission to create any document_ - Add permission to create documents in the selected folders.
* _Remove permission to create any document_ - Remove permission to create documents in the selected folders.
* _Add all permissions_ - Add all permissions from the specified document to the selection.
* _Set all permissions_ - Set all permissions in the selection to be exactly the same as the specified document.
* _Remove all permissions for all users [**DANGEROUS**]_ - Removes all permissions for all Users/Groups.

When you click {{< stroom-btn "ok" >}} Stroom will present a confirmation dialog telling you how many documents will be affected by the change, giving you the opportunity to cancel.

{{% warning %}}
Batch changes cannot be undone.
{{% /warning %}}


#### Document Permissions Sub-Tab

The previous Document Permissions modal dialog has been replaced with a sub-tab on the document screen.
It can be accessed by:

* Directly opening the document and selecting the _Permissions_ sub-tab.
* Clicking _Permissions_ in the explorer tree context menu.
  {{< stroom-menu "Permissions" >}}
* Double clicking the Document in the [Document Permissions Screen]({{< relref "#document-permissions-screen" >}}).

{{< image "releases/07.06/Document_Permissions.png" "500x" >}}The Permissions sub-tab on the Document screen{{</ image >}}

This screen works in a very similar way to the [Application Permissions screen]({{< relref "#application-permissions-screen" >}}).

* Top pane - Lists the Users and Groups, depending on the selection in the Permission Visibility drop-down.

  The Permission Visibility has the following values:
  * `Show Explicit` - Shows only those Users/Groups that have at least one document permission explicitly granted to them.
  * `Show Effective` - Shows only those Users/Groups that have at least one document permission explicitly granted to them or to a group that they are a member of (directly or indirectly).
  * `Show All` - Shows all Users/Groups regardless of whether any permission is held or not.

  The _Explicit Permission_ column shows the permission explicitly granted to the corresponding User/Group.

  The _Effective Permission_ column shows the permission effectively granted to the corresponding User/Group, either via explicit grant or inherited from an ancestor Group.
  The effective permission is what counts when Stroom makes decisions about what a User/Group can do or see.

* Bottom pane - Shows the permission details for the selected row in the top pane.
  It will show which ancestor Groups have been explicitly granted any inherited permissions.


#### Folder Permissions Sub-Tab

Folders are a special kind of document so their Permission sub-tab is slightly different to that on the Document screen.

It can be accessed by:

* Directly opening the Folder and selecting the _Permissions_ sub-tab.
* Clicking _Permissions_ in the explorer tree context menu.
  {{< stroom-menu "Permissions" >}}
* Double clicking the Folder in the [Document Permissions Screen]({{< relref "#document-permissions-screen" >}}).

{{< image "releases/07.06/Folder_Permissions.png" "500x" >}}The Permissions sub-tab on the Folder screen{{</ image >}}

The columns are the same as for the Permissions sub-tab of the Document screen except for the addition of:

  The _Explicit Create Document Types_ column shows the document create permissions explicitly granted to the corresponding User/Group.
  It shows each document type as an icon.
  The hover tooltip will show the type name.

  The _Effective Create Document Types_ column shows the document create permissions effectively granted to the corresponding User/Group, either via explicit grant or inherited from an ancestor Group.


### User/Group Profile Screen

A new screen has been added to essentially show a user profile for a User/Group.
The idea is that it will show everything you might need to know about a User/Group.
It is likely that more information relating to a User/Group will be added to this screen in future versions.

A user can view their own profile regardless of permissions, but to view another User or a Group the current User must hold the _Manage Users_ application permission.

The screen is accessible from a number of places:

* The Stroom menu
  {{< stroom-menu "User" "User Profile" >}}
* From a hover link {{< stroom-icon "open.svg" "Open User">}} on the various User/Group related tables.
* From the Actions context menu {{< stroom-icon "ellipses-horizontal.svg" "Actions...">}} on the various User/Group related tables.

The following sub-tabs are available:

* **Info** - Basic information such as their identifiers, name and enabled state.

{{< image "releases/07.06/User_Info.png" "500x" >}}The Info sub-tab on the User/Group Profile screen{{</ image >}}

* **User Groups** - Lists the Groups that this User/Group is a member of with the ability to join/leave Groups (subject to having _Manage Users_ permission).

{{< image "releases/07.06/User_Groups.png" "500x" >}}The Groups sub-tab on the User/Group Profile screen{{</ image >}}

* **Application Permissions** - Lists all application permissions with a check box indicating the grant state.
  Very similar to the main Application Permissions screen, without the User/Group list pane.
  * Empty - The permission is not granted to the User/Group.
    The whole row is also greyed out.
  * Half Ticked - The permission has been granted to a Group that the selected User/Group is a member or (directly or otherwise).
  * Ticked - The permission has been explicitly granted to the selected User/Group.

{{< image "releases/07.06/User_AppPerms.png" "500x" >}}The Application Permissions sub-tab on the User/Group Profile screen{{</ image >}}

* **Document Permissions** - Lists all the documents that the user has visibility with the explicit and inherited permission on each.
  The Permission Visibility drop-down has the following values:
  * `Show Explicit` - Shows only those documents where the User/Group has a document permission explicitly granted to them.
  * `Show Effective` - Shows only those documents where the User/Group has a document permission explicitly granted or inherited from an ancestor Group.
  * `Show All` - Shows all documents that the logged in User can see, regardless of whether any permission is held or not.

{{< image "releases/07.06/User_DocPerms.png" "500x" >}}The Document Permissions sub-tab on the User/Group Profile screen{{</ image >}}

* **Dependencies** - This list various dependencies on the User/Group, e.g. a  that is configured to [_Run As_]({{< relref "#pipeline-_run-as-user_" >}}) this user.
  It is useful in cases where a User is leaving the organisation and administrator needs to see what Stroom content depends on that user.
  Currently the following things can appear in the Dependencies sub-tab:
  * Pipelines {{< stroom-icon "document/Pipeline.svg">}} that _Run As_ the User/Group.
  * Analytic Rules {{< stroom-icon "document/AnalyticRule.svg">}} that _Run As_ the User/Group.

{{< image "releases/07.06/User_Deps.png" "500x" >}}The Dependencies sub-tab on the User/Group Profile screen{{</ image >}}

* **API Keys** - This lists the API Keys held by the User/Group with the ability to create/delete API Keys.
  _Manage API Keys_ application permission is required to see this sub-tab and to see the logged in User's own API Keys.
  _Manage Users_ application permission is required to see this sub-tab for another User/Group.


### User/Group Enable State

It is now possible to change the enabled state of a Stroom User.
This is as distinct from changing the enabled state of an Account.

This is mostly useful for cases where Stroom is configured to use an external {{< glossary "identity-provider-idp" "Identity Provider" >}} and an administrator wants to create the Stroom User associated with an IDP user but does not want to allow them to log in yet.

A disabled user will be unable to log in and anything running as the User (e.g. a Pipeline processor filter) will fail.


### User Deletion

User/Group deletion has been improved.
Deletion of a User/Group will remove them from any Groups and delete any API Keys that they hold.
Any documents that are solely owned by them will then be only accessible by an administrator.

It is not possible to delete a User/Group where dependencies exist on that User/Group, e.g. a Pipeline processor filter.
The Dependencies sub-tab of the User Profile screen can be used to track down these dependencies prior to deletion.


### Pipeline _Run As User_

The permissions that a Pipeline {{< stroom-icon "document/Pipeline.svg" >}} runs with are now controlled by setting a _Run As_ User/Group on the processor filter.
It is advised to use a Group for this as it mitigates against having to change processor filters when a User leaves the organisation.


## Viewing Document Dependencies

Previously, the _Dependencies_ and _Dependants_ items in the explorer tree context menu were only available if the logged in User had `Owner` permission on the selected Document.
Now the User only needs `View` permission to see the dependences/dependants.


## User Account Creation

When a Stroom User Account is created it will now create the corresponding Stroom User record.
Previously this was a two step process.
This is only applicable when using the internal {{< glossary "identity-provider-idp" "Identity Provider">}}.


## Analytic Email Notifications

Now when a failure occurs sending an email notification for an Analytic Rule {{< stroom-icon "document/AnalyticRule.svg" "Analytic Rule">}}, the error will be written to the configured error Feed {{< stroom-icon "document/Feed.svg" >}}.

