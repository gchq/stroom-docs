# Stroom HOWTO - Explorer Management

### Document Properties

* Version Information: Created with Stroom v6.1-beta.16   
* Last Updated: 15 August 2021  

## Moving a set of Objects

The following shows how to create a System Folder(s) within the Explorer tree and move a set of objects into the new structure. We will create the system group GeoHost Reference and move all the GeoHost reference feed objects into this system group.
Because Stroom Explorer is a flat structure you can move resources around to reorganise the content without any impact on directory paths, configurations etc.

### Create a System Group

First, move your mouse over the `Event Sources` object in the explorer, single click to highlight this object to highlight, you will see

![Stroom UI ExplorerManagement - Highlighted object in Explorer](../resources/v6/UI-ExplorerMgmt-00.png "Highlighted object in Explorer")

Now right click to bring up the object context menu

![Stroom UI ExplorerManagement - Menu in Explorer](../resources/v6/UI-ExplorerMgmt-01.png "Menu in Explorer")

Next move the mouse over the ![NewItemv6](../resources/icons/newItemv6.PNG "NewItemv6")  New icon to reveal the New sub-context menu.

![Stroom UI ExplorerManagement - Sub-Menu in Explorer](../resources/v6/UI-ExplorerMgmt-02.png "Sub-Menu in Explorer")

Click on the ![Folder](../resources/icons/folderItem.PNG "NewItemv6") icon, at which point the _New Folder_ selection window will be presented

![Stroom UI ExplorerManagement - New folder selection](../resources/v6/UI-ExplorerMgmt-03.png "New folder selection")

We will enter the name _Reference_ into the **Name:** entry box

![Stroom UI ExplorerManagement - New folder selection - Name](../resources/v6/UI-ExplorerMgmt-04.png "New folder selection - Name")

With the newly created `Reference` folder highlighted, repeat the above process but use the folder **Name:** of GeoHost

![Stroom UI ExplorerManagement - New folder selection - Name](../resources/v6/UI-ExplorerMgmt-05.png "New folder selection - Name")

then click _OK_ to save.

Note that we could have navigated within the explorer tree but as we want the Reference/GeoHost system group at the top level of the `Event Sources` group, there is no need to perform any navigation. Had we needed to, double click any system group that contains objects, indicated by the   icon and to select the system group you want to store your new group in, just left or right click the mouse once over the group to select it. You will note that the `Event Sources` system group was selected above.

At this point, our new folders will display in the main pane.

![Stroom UI ExplorerManagement - New folders created](../resources/v6/UI-ExplorerMgmt-06.png "New folders created")

You can look at the folder properties by selecting the desired folder, right clicking and choosing *Info* option

![Stroom UI ExplorerManagement - New folder Info](../resources/v6/UI-ExplorerMgmt-07.png "New folder Info")

This will return a window with folder specific information

![Stroom UI ExplorerManagement - New folder Info detail](../resources/v6/UI-ExplorerMgmt-08.png "New folder Info detail")

Should you wish to limit the users who can access this folder, you similarly select the desired folder, right click and choose *Permissions*

![Stroom UI ExplorerManagement - New folder Permissions](../resources/v6/UI-ExplorerMgmt-09.png "New folder Permissions")

You can limit folder access as required in the resultant window. 

![Stroom UI ExplorerManagement - New folder set Permissions](../resources/v6/UI-ExplorerMgmt-10.png "New folder set Permissions")

Make any required changes and click on **OK** to save the changes.

### Moving Objects into a System Group

Now you have created the new folder structure you can move the various GeoHost resources to this location.

Select all four resources by using the mouse right-click button while holding down the _Shift_ key. Then right click on the highlighted group to display the action menu

![Stroom UI CreateReferenceFeed - Organise Resources - move content](../resources/v6/UI-ExplorerMgmt-11.png "Organise Resources - move content")

Select **move** and the _Move Multiple Items_ window will display. Navigate to the `Reference/GeoHost` folder to move the items to this destination.

![Stroom UI CreateReferenceFeed - Organise Resources - select destination](../resources/v6/UI-ExplorerMgmt-12.png "Organise Resources - select destination")

The final structure is seen below

![Stroom UI CreateReferenceFeed - Organise Resources - finished](../resources/v6/UI-ExplorerMgmt-13.png "Organise Resources - finished")

Note that when a folder contains child objects this is indicated by a folder icon with an arrow to the left of the folder . Whether the arrow is pointing right or down indicates whether or not the folder is expanded.

![Stroom UI CreateReferenceFeed - Organise Resources - finished](../resources/v6/UI-ExplorerMgmt-14.png "Organise Resources - finished")

The GeoHost resources move has now been completed.