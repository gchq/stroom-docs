---
title: "Other Changes"
linkTitle: "Other Changes"
weight: 20
date: 2023-10-20
tags: 
description: >
  Other changes in this version of Stroom.
  Changes may be user interface changes, or changes to existing functionality or non-functional performance improvements.
---



## Look and Feel

### New User Interface Design

The user interface has had a bit of a re-design to give it a more modern look and to make it conform to accessibility standards.

{{< image "releases/07.02/new-look.png" "400x" />}}


### User Preferences

Now you can customise Stroom with your own personal preferences.
From the main menu {{< stroom-icon "menu.svg" "Main Menu">}}, select:

{{< stroom-menu "User" "Preferences" >}}

You can also change the following:

* **Layout Density** - This controls the layout spacing to fit more or less user interface elements in the available space.

* **Font** - Change font used in Stroom.

* **Font Size** - Change the font size used in Stroom.

* **Transparency** - Enables partial transparency of dialog windows.
  Entirely cosmetic.


#### Theme

Choose between the traditional light theme and a new dark theme with light text on a dark background.

{{< cardpane >}}
  {{< image "releases/07.02/theme-light.png" "250" />}}
  {{< image "releases/07.02/theme-dark.png" "250" />}}
{{< /cardpane >}}


#### Editor Preferences

The Ace text editor used within Stroom is used for editing things like XSLTs and viewing stream data.
It can now be personalised with the following options:

* **Theme** - The colour theme for the editor.
  The theme options will be applicable to the main user interface theme, i.e. light/dark editor themes.
  The theme affects the colours used for the syntax highlight content.

* **Key Bindings** - Allows you to set the editor to use {{< external-link "Vim" "https://en.wikipedia.org/wiki/Vim_(text_editor)" >}} key bindings for more powerful text editing.
  If you don't know what Vim is then it is best to stick to _Standard_.
  If you would like to learn how to use Vim, install `vimtutor`.
  Note: The Ace editor does not fully emulate Vim, not all Vim key bindings work and there is limited command mode support.

* **Live Auto Completion** - Set this to _On_ if you want the editor code completion to make suggestions as you type.
  When set to _Off_ you need to press `<ctrl>-<space>` to show the suggestion dialog.


#### Date and Time

You can not change the format used for displaying the date and time in the user interface.
You can also set the time zone used for displaying the date and time in the user interface.

{{% note %}}
Stroom works in UTC internally.
Changing the time zone only affects display of dates/times, not how data is stored or the dates/times in events.
{{% /note %}}


### Dashboard Changes

#### Design Mode

A Design Mode has been introduced to {{< glossary "Dashboard" "Dashboards" >}} and is toggled using the button {{< stroom-icon "edit.svg" "Enter/Exit Design Mode">}}.
When a _Dashboard_ is in design mode, the following functionality is enabled:

* Adding components to the _Dashboard_.
* Removing components from the _Dashboard_.
* Moving _Dashboard_ components within panes, to new panes or to existing panes.
* Changing the constraints of the _Dashboard_.

On creation of a new _Dashboard_, Design Mode will be on so the user has full functionality.
On opening an existing _Dashboard_, Design Mode will be off.
This is because typically, _Dashboards_ are viewed more than they are modified.

#### Visual Constraints

Now it is possible to control the horizontal and vertical constraints of a _Dashboard_.
In Stroom 7.0, a dashboard would always scale to fit the user's screen.
Sometimes it is desirable for the dashboard canvas area to be larger than the screen so that you have to scroll to see it all.
For example you may have a dashboard with a large number of component panes and rather than squashing them all into the available space you want to be able to scroll vertically in order to see them all.

It is now possible to change the horizontal and/or vertical constraints to fit the available width/height or to be fixed by clicking the {{< stroom-icon "resize.svg" "Set Constraints" >}} button.

{{< cardpane >}}
  {{< image "releases/07.02/dashboard-canvas.png" "300" />}}
  {{< image "releases/07.02/dashboard-set-constraints.png" "100" />}}
{{< /cardpane >}}

The edges of the canvas can be moved to shrink/grow it.


### Explorer Filter Matches

Filtering in the explorer has been changed to highlight the filter matches and to search in folders that themselves are a match.
In Stroom v7.0 folders that matched were not expanded.
Match highlighting makes it clearer what items have matched.

{{< image "releases/07.02/explorer-filter-matches.png" "200" />}}


### Document Permissions Screen

The document and folder permissions screens have been re-designed with a better layout and item highlighting to make it clearer which permissions have been selected.

{{< image "releases/07.02/folder-permissions.png" "300" />}}


## Partitioned Reference Data Stores

In Stroom v7.0 reference data is loaded using a reference loader pipeline and the key/value pairs are stored in a single disk backed reference data store on each Stroom node for fast lookup.
This single store approach has led to high contention and performance problems when purge operations are running against it at the same time or multiple reference _Feeds_ are being loaded at the same time.

In Stroom v7.2 the reference data key/value pairs are now stored in multiple reference data stores on each node, with one store per _Feed_.
This reduces contention as reference data for one _Feed_ can be loading while a purge operation is running on the store for another _Feed_ or reference data for multiple _Feeds_ can be loaded concurrently.
Performance is still limited by the file system that the stores are hosted on.

All reference data stores are stored in the directory defined by `stroom.pipeline.referenceData.lmdb.localDir`.

{{% see-also %}}
See the [upgrade notes]({{< relref "upgrade-notes#reference-data-store" >}}) for the reference data stores.
{{% /see-also %}}


## Improved OAuth2.0/OpenID Connect Support

The support for Open ID Connect (OIDC) authentication has been improved in v7.2.
Stroom can be integrated with AWS Cognito, MS Azure AD, KeyCloak and other OIDC identity providers (IDP).

Data receipt in Stroom and Stroom-Proxy can now enforce OIDC token authentication as well as certificate authentication.
The data receipt authentication is configured via the properties:

* `stroom.receive.authenticationRequired`
* `stroom.receive.certificateAuthenticationEnabled`
* `stroom.receive.tokenAuthenticationEnabled`

Stroom and Stroom-Proxy have also been changed to use OIDC tokens for API endpoints and inter-node communications.
This currently requires the OIDC IDP to support the client credentials flow.

Stroom can still be used with its own internal IDP if you do not have an external IDP available.


### User Naming Changes

{{% todo %}}
Complete this
{{% /todo %}}


## Proxy

{{% warning %}}
Stroom-Proxy v7.2 has a number of know performance issues and 
{{% /warning %}}
