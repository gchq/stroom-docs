---
title: "Node Cluster URL Setup"
linkTitle: "Node Cluster"
#weight:
date: 2021-07-12
tags: 
  - cluster
  - installation
description: >
  Configuring Stroom cluster URLs
---

# Stroom HOWTO - Node Cluster URL Setup
In a Stroom cluster, [Nodes](../../user-guide/nodes.md "Stroom Nodes") are expected to communicate with each other on port 8080 over http. To facilitate this, we need to set each node's Cluster URL and the following demonstrates this process.

## Assumptions
- an account with the `Administrator` Application [Permission](../../user-guide/roles.md "Stroom Application Permissions") is currently logged in.
- we have a multi node Stroom cluster with two nodes, `stroomp00` and `stroomp01`
- appropriate firewall configurations have been made
- in the scenario of adding a new node to our multi node deployment, the node added will be `stroomp02`

## Configure Two Nodes
To configure the nodes, move to the `Monitoring` item of the __Main Menu__ and select it to bring up the `Monitoring` sub-menu.

![Stroom UI Node Management - Monitoring Menu](../resources/UI-MonitoringSubmenu-00.png "Stroom UI Monitoring sub-menu")

then move down and select the `Nodes` sub-item to be presented with the `Nodes` configuration tab as seen below.

![Stroom UI Node Management - Management Tab](../resources/UI-NodeClusterSetup-01.png "Stroom UI Node Management - management tab")

To set `stroomp00`'s Cluster URL, move the it's line in the display and select it. It will be highlighted.

![Stroom UI Node Management - Management Tab - Select first node](../resources/UI-NodeClusterSetup-02.png "Stroom UI Node Management - select first node")

Then move the cursor to the _Edit Node_ icon ![EditNode](../resources/icons/edit.png "Edit Node") in the top left of
the `Nodes` tab and select it. On selection the `Edit Node` configuration window will be displayed and into
the __Cluster URL:__ entry box, enter the first node's URL of `http://stroomp00.strmdev00.org:8080/stroom/clustercall.rpc`

![Stroom UI Node Management - First Node setup](../resources/UI-NodeClusterSetup-03.png "Stroom UI Node Management - set clustercall url for first node")

then press the 
![Stroom UI OkButton](../resources/icons/buttonOk.png "Stroom UI OkButton")
at which we see the _Cluster URL_ has been set for the first node as per

![Stroom UI Node Management - First Node set](../resources/UI-NodeClusterSetup-04.png "Stroom UI Node Management - set clustercall url on first node")

We next select the second node

![Stroom UI Node Management - Management Tab - Select second node](../resources/UI-NodeClusterSetup-05.png "Stroom UI Node Management - select second node")

then move the cursor to the _Edit Node_ icon ![EditNode](../resources/icons/edit.png "Edit Node") in the top left of
the `Nodes` tab and select it. On selection the `Edit Node` configuration window will be displayed and into
the __Cluster URL:__ entry box, enter the second node's URL of `http://stroomp01.strmdev00.org:8080/stroom/clustercall.rpc`

![Stroom UI Node Management - Second Node setup](../resources/UI-NodeClusterSetup-06.png "Stroom UI Node Management - set clustercall url for second node")

then press the 
![Stroom UI OkButton](../resources/icons/buttonOk.png "Stroom UI OkButton")

At this we will see both nodes have the __Cluster URLs__ set.

![Stroom UI Node Management - Both Nodes setup](../resources/UI-NodeClusterSetup-07.png "Stroom UI Node Management - both nodes setup").

You may need to press the _Refresh_ icon
![Stroom UI Refresh](../resources/icons/refresh.png "Stroom UI RefreshButton")
found at top left of `Nodes` configuration tab, until both nodes show healthy pings.

![Stroom UI Node Management - Both Nodes ping](../resources/UI-NodeClusterSetup-08.png "Stroom UI Node Management - both nodes ping").

If you do not get ping results for each node, then they are not configured correctly. In that situation,
review all log files and processes that you have performed.

Once you have set the Cluster URLs of each node you should also set the _master assignment priority_ for each node to
be different to all of the others. In the image above both have been assigned equal priority - `1`. We will
change `stroomp00` to have a different priority - `3`. You should note that the node with the highest
priority gains the `Master` node status.

![Stroom UI Node Management - Node priority](../resources/UI-NodeClusterSetup-09.png "Stroom UI Node Management - set node priorities").

## Configure New Node
When one expands a Multi Node Stroom cluster deployment, after the installation of the Stroom Proxy and Application software and services on
the new node, one has to configure the new node's Cluster URL.

To configure the new node, move to the `Monitoring` item of the __Main Menu__ and select it to bring up the `Monitoring` sub-menu.

![Stroom UI Node Management - Monitoring Menu](../resources/UI-MonitoringSubmenu-00.png "Stroom UI Monitoring sub-menu")

then move down and select the `Nodes` sub-item to be presented with the `Nodes` configuration tab as seen below.

![Stroom UI New Node Management - Management Tab](../resources/UI-AddNewNode-00.png "Stroom UI New Node Management - management tab")

To set `stroomp02`'s Cluster URL, move the it's line in the display and select it. It will be highlighted.

![Stroom UI Node Management - Management Tab - Select new node](../resources/UI-AddNewNode-01.png "Stroom UI Node Management - select new node")

Then move the cursor to the _Edit Node_ icon ![EditNode](../resources/icons/edit.png "Edit Node") in the top left
of the `Nodes` tab and select it. On selection the `Edit Node` configuration window will be displayed
and into the __Cluster URL:__ entry box, enter the first node's URL of `http://stroomp02.strmdev00.org:8080/stroom/clustercall.rpc`

![Stroom UI New Node Management - Node setup](../resources/UI-AddNewNode-02.png "Stroom UI New Node Management - set clustercall url for new node")

then press the 
![Stroom UI OkButton](../resources/icons/buttonOk.png "Stroom UI OkButton")
button at which we see the _Cluster URL_ has been set for the first node as per

![Stroom UI New Node Management - New Node set](../resources/UI-AddNewNode-03.png "Stroom UI New Node Management - set clustercall url on new node")

You need to press the _Refresh_ icon
![Stroom UI Refresh](../resources/icons/refresh.png "Stroom UI RefreshButton")
found at top left of `Nodes` configuration tab, until the new node shows a healthy ping.

![Stroom UI New Node Management - All Nodes ping](../resources/UI-AddNewNode-04.png "Stroom UI New Node Management - all nodes ping").

If you do not get a ping results for the new node, then it is not configured correctly. In that situation, review all log files
and processes that you have performed.

Once you have set the Cluster URL you should also set the _master assignment priority_ for each node to
be different to all of the others. In the image above both `stroomp01` and the new node, `stroomp02`, have been
assigned equal priority - `1`. We will change `stroomp01` to have a different priority - `2`. You should note that the node
with the highest priority maintains the `Master` node status.

![Stroom UI New Node Management - Node priority](../resources/UI-AddNewNode-05.png "Stroom UI New Node Management - set node priorities").

