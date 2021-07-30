---
title: "System Properties"
linkTitle: "System Properties"
#weight:
date: 2021-07-09
tags: 
  - properties
  - configuration
description: >
  This HOWTO is provided to assist users in managing Stroom **System Properties** via the User Interface.
---

## Assumptions
The following assumptions are used in this document.
- the user successfully logged into Stroom with the appropriate administrative privilege (**Manage Properties**).


## Introduction
Certain Stroom **System Properties** can be edited via the Stroom User Interface.


## Editing a System Property
To edit a **System Property** select the `Tools` item of the __Main Menu__ and select to bring up the `Tools` sub-menu.

{{< image "HOWTOs/UI-ToolsSubmenu-00.png" >}}Stroom UI Tools sub-menu{{< /image >}}

Then move down and select the `Properties` sub-item to be presented with `System Properties` configuration window as seen below.

![Stroom UI System Properties - System Properties](HOWTOs/UI-Tools-SystemProperties-00.png "Stroom UI Tools System Properties")

Using the Scrollbar to the right of the **System Properties** configuration window and scroll down to the line where the property one wants to modify is displayed then select (_left click_) the line. In the example below we have selected the `stroom.maxStreamSize` property.

![Stroom UI System Properties - System Properties](HOWTOs/UI-Tools-SystemProperties-01.png "Stroom UI Tools System Properties - Selected Property")

Now bring up the editing window by _double clicking_ on the selected line. At this we will be presented with the
`Application Property - stroom.maxStreamSize` editing window.

![Stroom UI System Properties - System Properties](HOWTOs/UI-Tools-SystemProperties-02.png "Stroom UI Tools System Properties - Editing Property")

Now edit the property, by _double clicking_ the string in the `Value` entry box. In this case we select the `1G` value to see

![Stroom UI System Properties - System Properties](HOWTOs/UI-Tools-SystemProperties-03.png "Stroom UI Tools System Properties - Editing Property - Value selected")

Now change the selected `1G` value to the value we want. In this example, we are changing the value to `512M`.

![Stroom UI System Properties - System Properties](HOWTOs/UI-Tools-SystemProperties-04.png "Stroom UI Tools System Properties - Editing Property - Value changed")

At this, press the ![Stroom UI OkButton](HOWTOs/icons/buttonOk.png "Stroom UI OkButton") to see the new value
updated in the **System Properties** configuration window

![Stroom UI System Properties - System Properties](HOWTOs/UI-Tools-SystemProperties-05.png "Stroom UI Tools System Properties - Value changed")
