---
title: "Feed Management"
linkTitle: "Feed Management"
#weight:
date: 2021-07-09
tags:
  - feed
description: >
  This HOWTO demonstrates how to manage feeds.
---

This HOWTO demonstrates how to manage
[Feeds]({{< relref "../../user-guide/feeds.md" >}})

## Assumptions
- All Sections
  - an account with the `Administrator` Application [Permission]({{< relref "../../user-guide/roles.md" >}}) is currently logged in.


## Creation of an Event Feed

We will be creating an Event Feed with the name `TEST-FEED-V1_0`.

Once you have logged in, move the cursor to the **System** folder within the `Explorer` tab and select it.

{{< screenshot "HOWTOs/UI-CreateFeed-00.png" >}}Stroom UI Create Feed - System selected{{< /screenshot >}}

Once selected, _right click_ to bring up the `New Item` selection sub-menu. By selecting the **System** folder we are
requesting any  _new_ item created to be placed within it.

Select {{< stroom-menu "New" "Feed" >}}

You will be presented with a `New Feed` configuration window.

{{< screenshot "HOWTOs/UI-CreateFeed-02.png" >}}Stroom UI Create Feed - New feed configuration window{{< /screenshot >}}

You will note that the **System** folder has already been selected as the _parent group_ and all we need to do is enter our feed's name in the **Name:** entry box

{{< screenshot "HOWTOs/UI-CreateFeed-03.png" >}}Stroom UI Create Feed - New feed configuration window enter name{{< /screenshot >}}

On pressing {{< stroom-btn "Ok" >}} we are presented with the `Feed` tab for our new feed. The tab is labelled with the feed name `TEST-FEED-V1_0`.

{{< screenshot "HOWTOs/UI-CreateFeed-04.png" >}}Stroom UI Create Feed - New feed tab{{< /screenshot >}}

We will leave the definitions of the Feed attributes for the present, but we _will_ enter a **Description:** for our feed
as we should _ALWAYS_ do this fundamental tenet of data management - document the data. We will use
the description of '_Feed for installation validation only. No data value_'.

{{< screenshot "HOWTOs/UI-CreateFeed-05.png" >}}Stroom UI Create Feed - New feed tab with Description{{< /screenshot >}}

One should note that the {{< stroom-tab "Feed.svg" "TEST-FEED-V1_0" "active" "unsaved" >}} tab has been marked as having unsaved changes.
This is indicated by the asterisk character `*` between the _Feed_ icon {{< stroom-icon "document/Feed.svg">}} and the name of the feed `TEST-FEED-V1_0`.
We can save the changes to our feed by pressing the _Save_ icon {{< stroom-icon "save.svg" >}} in the top left of the `TEST-FEED-V1_0` tab. At this point one should notice two things, the first is that the asterisk
has disappeared from the `Feed` tab and the _Save_ icon {{< stroom-icon "save.svg" "Save" "disabled" >}} is _ghosted_.

{{< screenshot "HOWTOs/UI-CreateFeed-06.png" >}}Stroom UI Create Feed - New feed tab with description saved{{< /screenshot >}}


## Folder Structure for Event Sources

In order to simplify the management of multiple event sources being processed by Stroom, it is suggested that an Event Source folder is created at the root of the **System** folder {{< stroom-icon "oo.svg" "System">}} in the `Explorer` tab.

This can be achieved by right clicking on the {{< stroom-icon "oo.svg" "System">}} _System_ root folder and selecting {{< stroom-menu "New" "Folder" >}}.

You will be presented with a `New Folder` configuration window.

{{< screenshot "HOWTOs/UI-EventSources-01.png" >}}Stroom UI Create Folder - New folder configuration window{{< /screenshot >}}

You will note that the **System** folder has already been selected as the _parent group_ and all we need to do is enter our folders's name in the **Name:** entry box

{{< screenshot "HOWTOs/UI-EventSources-02.png" >}}Stroom UI Create Folder - New folder configuration window enter name{{< /screenshot >}}

On pressing {{< stroom-btn "Ok" >}} we are presented with the {{< stroom-tab "Folder.svg" "Event Sources" "active" >}} tab for our new folder.

{{< screenshot "HOWTOs/UI-EventSources-03.png" >}}Stroom UI Create Folder - New folder tab{{< /screenshot >}}

You will also note that the `Explorer` tab has displayed the **Event Sources** folder in its display.


### Create Folder for specific Event Source

In order to manage all artefacts of a given Event Source (aka `Feed`), one would create an appropriately named sub-folder within the **Event Sources** folder structure.

In this example, we will create one for a BlueCoat Proxy `Feed`.

As we may eventually have multiple proxy event sources, we will first create a **Proxy** folder in the **Event Sources** before creating the desired **BlueCoat** folder that will hold the processing components.

So, right-click on the {{< stroom-icon "document/Folder.svg">}} _Event Sources_ folder in the Explorer tree and select:

{{< stroom-menu "New" "Folder" >}}

You will be presented with a `New Folder` configuration window.

Enter **Proxy** as the folder **Name:**

{{< screenshot "HOWTOs/UI-EventSources-04.png" >}}Stroom UI Create Folder - New sub folder configuration window{{< /screenshot >}}

and press {{< stroom-btn "Ok" >}}.

At this you will be presented with a new {{< stroom-tab "Folder.svg" "Proxy" "active" >}} tab for the new sub-folder and we note that it has been added below the **Event Sources** folder in the Explorer tree.

{{< screenshot "HOWTOs/UI-EventSources-05.png" >}}Stroom UI Create Folder - New sub folder tab{{< /screenshot >}}

Repeat this process to create the desired **BlueCoat** sub-folder with the result

{{< screenshot "HOWTOs/UI-EventSources-06.png" >}}Stroom UI Create Folder - New BlueCoat sub folder tab{{< /screenshot >}}.
