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

In a Stroom cluster, [Nodes]({{< relref "../../user-guide/nodes.md" >}}) are expected to communicate with each other on port 8080 over http. To facilitate this, we need to set each node's Cluster URL and the following demonstrates this process.

## Assumptions
- an account with the `Administrator` Application [Permission]({{< relref "../../user-guide/roles.md" >}}) is currently logged in.
- we have a multi node Stroom cluster with two nodes, `stroomp00` and `stroomp01`
- appropriate firewall configurations have been made
- in the scenario of adding a new node to our multi node deployment, the node added will be `stroomp02`

## Configure Two Nodes

To configure the nodes, move to the `Monitoring` item of the __Main Menu__ and select it to bring up the `Monitoring` sub-menu.

{{< screenshot "HOWTOs/UI-MonitoringSubmenu-00.png" >}}Stroom UI Monitoring sub-menu{{< /screenshot >}}

then move down and select the `Nodes` sub-item to be presented with the `Nodes` configuration tab as seen below.

{{< screenshot "HOWTOs/UI-NodeClusterSetup-01.png" >}}Stroom UI Node Management - management tab{{< /screenshot >}}

To set `stroomp00`'s Cluster URL, move the it's line in the display and select it. It will be highlighted.

{{< screenshot "HOWTOs/UI-NodeClusterSetup-02.png" >}}Stroom UI Node Management - select first node{{< /screenshot >}}

Then move the cursor to the _Edit Node_ icon {{< stroom-icon "edit.svg" "Edit" >}} in the top left of
the `Nodes` tab and select it. On selection the `Edit Node` configuration window will be displayed and into
the __Cluster URL:__ entry box, enter the first node's URL of `http://stroomp00.strmdev00.org:8080/stroom/clustercall.rpc`

{{< screenshot "HOWTOs/UI-NodeClusterSetup-03.png" >}}Stroom UI Node Management - set clustercall url for first node{{< /screenshot >}}

then press the 
{{< screenshot "HOWTOs/icons/buttonOk.png" >}}Stroom UI OkButton{{< /screenshot >}}
at which we see the _Cluster URL_ has been set for the first node as per

{{< screenshot "HOWTOs/UI-NodeClusterSetup-04.png" >}}Stroom UI Node Management - set clustercall url on first node{{< /screenshot >}}

We next select the second node

{{< screenshot "HOWTOs/UI-NodeClusterSetup-05.png" >}}Stroom UI Node Management - select second node{{< /screenshot >}}

then move the cursor to the _Edit Node_ icon {{< stroom-icon "edit.svg" "Edit" >}} in the top left of
the `Nodes` tab and select it. On selection the `Edit Node` configuration window will be displayed and into
the __Cluster URL:__ entry box, enter the second node's URL of `http://stroomp01.strmdev00.org:8080/stroom/clustercall.rpc`

{{< screenshot "HOWTOs/UI-NodeClusterSetup-06.png" >}}Stroom UI Node Management - set clustercall url for second node{{< /screenshot >}}

then press the 
{{< screenshot "HOWTOs/icons/buttonOk.png" >}}Stroom UI OkButton{{< /screenshot >}}

At this we will see both nodes have the __Cluster URLs__ set.

{{< screenshot "HOWTOs/UI-NodeClusterSetup-07.png" >}}Stroom UI Node Management - both nodes setup{{< /screenshot >}}.

You may need to press the _Refresh_ icon {{< stroom-icon "refresh.svg" "Refresh" >}} found at top left of `Nodes` configuration tab, until both nodes show healthy pings.

{{< screenshot "HOWTOs/UI-NodeClusterSetup-08.png" >}}Stroom UI Node Management - both nodes ping{{< /screenshot >}}.

If you do not get ping results for each node, then they are not configured correctly. In that situation,
review all log files and processes that you have performed.

Once you have set the Cluster URLs of each node you should also set the _master assignment priority_ for each node to
be different to all of the others. In the image above both have been assigned equal priority - `1`. We will
change `stroomp00` to have a different priority - `3`. You should note that the node with the highest
priority gains the `Master` node status.

{{< screenshot "HOWTOs/UI-NodeClusterSetup-09.png" >}}Stroom UI Node Management - set node priorities{{< /screenshot >}}.

## Configure New Node
When one expands a Multi Node Stroom cluster deployment, after the installation of the Stroom Proxy and Application software and services on
the new node, one has to configure the new node's Cluster URL.

To configure the new node, move to the `Monitoring` item of the __Main Menu__ and select it to bring up the `Monitoring` sub-menu.

{{< screenshot "HOWTOs/UI-MonitoringSubmenu-00.png" >}}Stroom UI Monitoring sub-menu{{< /screenshot >}}

then move down and select the `Nodes` sub-item to be presented with the `Nodes` configuration tab as seen below.

{{< screenshot "HOWTOs/UI-AddNewNode-00.png" >}}Stroom UI New Node Management - management tab{{< /screenshot >}}

To set `stroomp02`'s Cluster URL, move the it's line in the display and select it. It will be highlighted.

{{< screenshot "HOWTOs/UI-AddNewNode-01.png" >}}Stroom UI Node Management - select new node{{< /screenshot >}}

Then move the cursor to the _Edit Node_ icon {{< stroom-icon "edit.svg" "Edit" >}} in the top left
of the `Nodes` tab and select it. On selection the `Edit Node` configuration window will be displayed
and into the __Cluster URL:__ entry box, enter the first node's URL of `http://stroomp02.strmdev00.org:8080/stroom/clustercall.rpc`

{{< screenshot "HOWTOs/UI-AddNewNode-02.png" >}}Stroom UI New Node Management - set clustercall url for new node{{< /screenshot >}}

then press the 
{{< screenshot "HOWTOs/icons/buttonOk.png" >}}Stroom UI OkButton{{< /screenshot >}}
button at which we see the _Cluster URL_ has been set for the first node as per

{{< screenshot "HOWTOs/UI-AddNewNode-03.png" >}}Stroom UI New Node Management - set clustercall url on new node{{< /screenshot >}}

You need to press the _Refresh_ icon {{< stroom-icon "refresh.svg" "Refresh" >}} found at top left of `Nodes` configuration tab, until the new node shows a healthy ping.

{{< screenshot "HOWTOs/UI-AddNewNode-04.png" >}}Stroom UI New Node Management - all nodes ping{{< /screenshot >}}.

If you do not get a ping results for the new node, then it is not configured correctly. In that situation, review all log files
and processes that you have performed.

Once you have set the Cluster URL you should also set the _master assignment priority_ for each node to
be different to all of the others. In the image above both `stroomp01` and the new node, `stroomp02`, have been
assigned equal priority - `1`. We will change `stroomp01` to have a different priority - `2`. You should note that the node
with the highest priority maintains the `Master` node status.

{{< screenshot "HOWTOs/UI-AddNewNode-05.png" >}}Stroom UI New Node Management - set node priorities{{< /screenshot >}}.

