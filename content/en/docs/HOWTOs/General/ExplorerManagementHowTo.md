---
title: "Explorer Management"
linkTitle: "Explorer Management"
#weight:
date: 2022-03-07
tags: 
description: >
  How to manage Documents and Entities in the Explorer Tree.

---

<!-- Created with Stroom v6.1-beta.16  -->

## Moving a set of Objects

The following shows how to create a System Folder(s) within the Explorer tree and move a set of objects into the new structure.
We will create the system group GeoHost Reference and move all the GeoHost reference feed objects into this system group.
Because Stroom Explorer is a flat structure you can move resources around to reorganise the content without any impact on directory paths, configurations etc.


### Create a System Group

First, move your mouse over the `Event Sources` object in the explorer, single click to highlight this object to highlight, you will see

{{< screenshot "HOWTOs/v6/UI-ExplorerMgmt-00.png" >}}Stroom UI ExplorerManagement - Highlighted object in Explorer{{< /screenshot >}}

Now right click to bring up the object context menu

{{< screenshot "HOWTOs/v6/UI-ExplorerMgmt-01.png" >}}Stroom UI ExplorerManagement - Menu in Explorer{{< /screenshot >}}

Next move the mouse over the {{< stroom-icon "add.svg" "New" >}} New icon to reveal the New sub-context menu.

{{< screenshot "HOWTOs/v6/UI-ExplorerMgmt-02.png" >}}Stroom UI ExplorerManagement - Sub-Menu in Explorer{{< /screenshot >}}

Click on the folder {{< stroom-icon "folder.svg" >}} icon, at which point the _New Folder_ selection window will be presented

{{< screenshot "HOWTOs/v6/UI-ExplorerMgmt-03.png" >}}Stroom UI ExplorerManagement - New folder selection{{< /screenshot >}}

We will enter the name _Reference_ into the **Name:** entry box

{{< screenshot "HOWTOs/v6/UI-ExplorerMgmt-04.png" >}}Stroom UI ExplorerManagement - New folder selection - Name{{< /screenshot >}}

With the newly created `Reference` folder highlighted, repeat the above process but use the folder **Name:** of GeoHost

{{< screenshot "HOWTOs/v6/UI-ExplorerMgmt-05.png" >}}Stroom UI ExplorerManagement - New folder selection - Name{{< /screenshot >}}

then click {{< stroom-btn "Ok" >}} to save.

Note that we could have navigated within the explorer tree but as we want the Reference/GeoHost system group at the top level of the `Event Sources` group, there is no need to perform any navigation.
Had we needed to, double click any system group that contains objects, indicated by the   icon and to select the system group you want to store your new group in, just left or right click the mouse once over the group to select it.
You will note that the `Event Sources` system group was selected above.

At this point, our new folders will display in the main pane.

{{< screenshot "HOWTOs/v6/UI-ExplorerMgmt-06.png" >}}Stroom UI ExplorerManagement - New folders created{{< /screenshot >}}

You can look at the folder properties by selecting the desired folder, right clicking and choosing *Info* option

{{< screenshot "HOWTOs/v6/UI-ExplorerMgmt-07.png" >}}Stroom UI ExplorerManagement - New folder Info{{< /screenshot >}}

This will return a window with folder specific information

{{< screenshot "HOWTOs/v6/UI-ExplorerMgmt-08.png" >}}Stroom UI ExplorerManagement - New folder Info detail{{< /screenshot >}}

Should you wish to limit the users who can access this folder, you similarly select the desired folder, right click and choose *Permissions*

{{< screenshot "HOWTOs/v6/UI-ExplorerMgmt-09.png" >}}Stroom UI ExplorerManagement - New folder Permissions{{< /screenshot >}}

You can limit folder access as required in the resultant window. 

{{< screenshot "HOWTOs/v6/UI-ExplorerMgmt-10.png" >}}Stroom UI ExplorerManagement - New folder set Permissions{{< /screenshot >}}

Make any required changes and click on {{< stroom-btn "Ok" >}} to save the changes.


### Moving Objects into a System Group

Now you have created the new folder structure you can move the various GeoHost resources to this location.

Select all four resources by using the mouse right-click button while holding down the _Shift_ key.
Then right click on the highlighted group to display the action menu

{{< screenshot "HOWTOs/v6/UI-ExplorerMgmt-11.png" >}}Stroom UI CreateReferenceFeed - Organise Resources - move content{{< /screenshot >}}

Select **move** {{< stroom-icon "move.svg" >}} and the _Move Multiple Items_ window will display.
Navigate to the `Reference/GeoHost` folder to move the items to this destination.

{{< screenshot "HOWTOs/v6/UI-ExplorerMgmt-12.png" >}}Stroom UI CreateReferenceFeed - Organise Resources - select destination{{< /screenshot >}}

The final structure is seen below

{{< screenshot "HOWTOs/v6/UI-ExplorerMgmt-13.png" >}}Stroom UI CreateReferenceFeed - Organise Resources - finished{{< /screenshot >}}

Note that when a folder contains child objects this is indicated by a folder icon with an arrow to the left of the folder.
Whether the arrow is pointing right {{< stroom-icon "tree-closed.svg" "Tree branch closed">}} or down {{< stroom-icon "tree-open.svg" "Tree branch open">}} indicates whether or not the folder is expanded.

{{< screenshot "HOWTOs/v6/UI-ExplorerMgmt-14.png" >}}Stroom UI CreateReferenceFeed - Organise Resources - finished{{< /screenshot >}}

The GeoHost resources move has now been completed.
