---
title: "Volume Maintenance"
linkTitle: "Volume Maintenance"
#weight:
date: 2021-07-12
tags: 
  - volume
  - installation
description: >
  How to maintain Stroom's data and index volumes.
---

Stroom stores data in [volumes]({{< relref "../../user-guide/volumes.md" >}}).
These are the logical link to the Storage hierarchy we setup on the operating system.
This HOWTO will demonstrate how one first sets up volumes and also how to add additional volumes if one expanded an existing Stroom cluster.

## Assumptions
- an account with the `Administrator` Application [Permission]({{< relref "../../user-guide/roles.md" >}}) is currently logged in.
- we will add volumes as per the Multi Node Stroom deployment Storage hierarchy

## Configure the Volumes
We need to configure the volumes for Stroom. The follow demonstrates adding the volumes for two nodes, but demonstrates the process for a single node
deployment as well the volume maintenance needed when expanding a Multi Node Cluster when adding in a new node.

To configure the volumes, move to the `Tools` item of the __Main Menu__ and select it to bring up the `Tools` sub-menu.
{{< screenshot "HOWTOs/UI-ToolsSubmenu-00.png" >}}Stroom UI Tools sub-menu{{< /screenshot >}}

then move down and select the `Volumes` sub-item to be presented with the `Volumes` configuration window as seen below.
{{< screenshot "HOWTOs/UI-ManageVolumes-01.png" >}}Stroom UI Volumes - configuration window{{< /screenshot >}}

The attributes we see for each volume are
- Node - the processing node the volume resides on (this is just the node name entered when configuration the Stroom application)
- Path - the path to the volume
- Volume Type - The type of volume
 - Public - to indicate that all nodes would access this volume
 - Private - to indicate that only the local node will access this volume
- Stream Status
 - Active - to store data within the volume
 - Inactive - to __NOT__ store data within the volume
 - Closed - had stored data within the volume, but now no more data can be stored
- Index Status
 - Active - to store index data within the volume
 - Inactive - to __NOT__ store index data within the volume
 - Closed - had stored index data within the volume, but now no more index data can be stored
- Usage Date - the date and time the volume was last used
- Limit - the maximum amount of data the system will store on the volume
- Used - the amount of data in use on the volume
- Free - the amount of available storage on the volume
- Use% - the usage percentage

If you are setting up Stroom for the first time and you had accepted the default for the __CREATE_DEFAULT_VOLUME_ON_START__ configuration option (_true_) when
configuring the Stroom service application, you will see two default volumes have already been created. Had you set this option to _false_ then the window would be empty.

#### Add Volumes
Now from our two node Stroom Cluster example, our storage hierarchy was

- Node: `stroomp00.strmdev00.org`
 - `/stroomdata/stroom-data-p00`        - location to store Stroom application data files (events, etc.) for this node
 - `/stroomdata/stroom-index-p00`       - location to store Stroom application index files
 - `/stroomdata/stroom-working-p00`     - location to store Stroom application working files (e.g. temporary files, output, etc.) for this node
 - `/stroomdata/stroom-working-p00/proxy`       - location for Stroom proxy to store inbound data files
- Node: `stroomp01.strmdev00.org`
 - `/stroomdata/stroom-data-p01`        - location to store Stroom application data files (events, etc.) for this node
 - `/stroomdata/stroom-index-p01`       - location to store Stroom application index files
 - `/stroomdata/stroom-working-p01`     - location to store Stroom application working files (e.g. temporary files, output, etc.) for this node
 - `/stroomdata/stroom-working-p01/proxy`       - location for Stroom proxy to store inbound data files

From this we need to create four volumes. On `stroomp00.strmdev00.org` we create
 - `/stroomdata/stroom-data-p00`        - location to store Stroom application data files (events, etc.) for this node
 - `/stroomdata/stroom-index-p00`       - location to store Stroom application index files

and on `stroomp01.strmdev00.org` we create
 - `/stroomdata/stroom-data-p01`        - location to store Stroom application data files (events, etc.) for this node
 - `/stroomdata/stroom-index-p01`       - location to store Stroom application index files 

So the first step to configure a volume is to move the cursor to the _New_ icon {{< stroom-icon "add.svg" "Add" >}} in the top left of
the `Volumes` window and select it. This will bring up the `Add Volume` configuration window

{{< screenshot "HOWTOs/UI-ManageVolumes-02.png" >}}Stroom UI Add Volume - Volume configuration window{{< /screenshot >}}

As you can see, the entry box titles reflect the attributes of a volume. So we will add the first
nodes _data_ volume
 - `/stroomdata/stroom-data-p00`        - location to store Stroom application data files (events, etc.) for this node
for node `stroomp00`.

If you move the the *Node* drop down entry box and select it you will be presented with a choice of available
nodes - in this case `stroomp00` and `stroomp01` as we have a two node cluster with these node names.

{{< screenshot "HOWTOs/UI-ManageVolumes-03.png" >}}Stroom UI Add Volume - select node{{< /screenshot >}}

By selecting the node `stroomp00` we see

{{< screenshot "HOWTOs/UI-ManageVolumes-04.png" >}}Stroom UI Add Volume - selected node{{< /screenshot >}}

To configure the rest of the attributes for this volume, we:

- enter the *Path* to our first node's _data_ volume
- select a *Volume Type* of _Public_ as this is a data volume we want all nodes to access
- select a *Stream Status* of _Active_ to indicate we want to store data on it
- select an *Index Status* of _Inactive_ as we do __NOT__ want index data stored on it
- set a *Limit* of 12GB for allowed storage

{{< screenshot "HOWTOs/UI-ManageVolumes-05.png" >}}Stroom UI Add Volume - adding first data volume{{< /screenshot >}}

and on selection of the {{< stroom-btn "Ok" >}} we see the changes in the `Volumes` configuration window

{{< screenshot "HOWTOs/UI-ManageVolumes-06.png" >}}Stroom UI Add Volume - added first data volume{{< /screenshot >}}

We next add the first node's index volume, as per

{{< screenshot "HOWTOs/UI-ManageVolumes-07.png" >}}Stroom UI Add Volume - adding first index volume{{< /screenshot >}}

And after adding the second node's volumes we are finally presented with our configured volumes

{{< screenshot "HOWTOs/UI-ManageVolumes-08.png" >}}Stroom UI Add Volume - all volumes added{{< /screenshot >}}


#### Delete Default Volumes

We now need to deal with our default volumes. We want to delete them.

{{< screenshot "HOWTOs/UI-ManageVolumes-09.png" >}}Stroom UI Delete Default - display default{{< /screenshot >}}

So we move the cursor to the first volume's line (_stroomp00 /home/stroomuser/stroom-app/volumes/defaultindexVolume_ ...) and select the line then move the cursor to the  _Delete_ icon {{< stroom-icon "delete.svg" "Delete" >}} in the top left of the `Volumes` window and select it. On selection you will be given a confirmation request

{{< screenshot "HOWTOs/UI-ManageVolumes-10.png" >}}Stroom UI Delete Default - confirm deletion{{< /screenshot >}}

at which we press the {{< stroom-btn "Ok" >}} button to see the first default volume has been deleted

{{< screenshot "HOWTOs/UI-ManageVolumes-11.png" >}}Stroom UI Delete Default - first volume deleted{{< /screenshot >}}

and after we select then delete the second default volume( _stroomp00 /home/stroomuser/stroom-app/volumes/defaultStreamVolume_ ...), we are left with

{{< screenshot "HOWTOs/UI-ManageVolumes-12.png" >}}Stroom UI Delete Default - all deleted{{< /screenshot >}}

At this one can close the `Volumes` configuration window by pressing the {{< stroom-btn "Close" >}} button.

__NOTE__: At the time of writing there is an issue regarding volumes


##### Stroom Github Issue 84  - 

Due to {{< external-link "Issue 84" "https://github.com/gchq/stroom/issues/84" >}}, if we delete volumes in a multi node environment, the deletion is not propagated to all other nodes in a cluster.
Thus if we attempted to use the volumes we would get a database error.
The current _workaround_ is to restart all the Stroom applications which will cause a reload of all volume information.
This **MUST** be done before sending any data to your multi-node Stroom cluster.


## Adding new Volumes
When one expands a Multi Node Stroom cluster deployment, after the installation of the Stroom Proxy and Application software and services on the new node,
one has to configure the new volumes that are on the new node. The following demonstrates this assuming we are adding
- the new node is `stroomp02`
- the storage hierarchy for this node is
 - `/stroomdata/stroom-data-p02`        - location to store Stroom application data files (events, etc.) for this node
 - `/stroomdata/stroom-index-p02`       - location to store Stroom application index files
 - `/stroomdata/stroom-working-p02`     - location to store Stroom application working files (e.g. tmp, output, etc.) for this node
 - `/stroomdata/stroom-working-p02/proxy`       - location for Stroom proxy to store inbound data files

From this we need to create two volumes on `stroomp02`
 - `/stroomdata/stroom-data-p02`        - location to store Stroom application data files (events, etc.) for this node
 - `/stroomdata/stroom-index-p02`       - location to store Stroom application index files

To configure the volumes, move to the `Tools` item of the __Main Menu__ and select it to bring up the `Tools` sub-menu.
{{< screenshot "HOWTOs/UI-ToolsSubmenu-00.png" >}}Stroom UI Tools sub-menu{{< /screenshot >}}

then move down and select the `Volumes` sub-item to be presented with the `Volumes` configuration window as.
We then move the cursor to the _New_ icon {{< stroom-icon "add.svg" "Add" >}}
 in the top left of the `Volumes` window and select it.
This will bring up the `Add Volume` configuration window where we select our volume's node `stroomp02`.

{{< screenshot "HOWTOs/UI-ManageNewVolume-00.png" >}}Stroom UI Volumes - New Node configuration window start data volume{{< /screenshot >}}

We select this node and then configure the rest of the attributes for this _data_ volume

{{< screenshot "HOWTOs/UI-ManageNewVolume-01.png" >}}Stroom UI Volumes - New Node configuration window data volume{{< /screenshot >}}

then press the {{< stroom-btn "title" >}} button.

We then add another volume for the _index_ volume for this node with attributes as per

{{< screenshot "HOWTOs/UI-ManageNewVolume-02.png" >}}Stroom UI Volumes - New Node configuration window index volume added{{< /screenshot >}}

And on pressing the {{< stroom-btn "Ok" >}} button we see our two new volumes for this node have been added.

{{< screenshot "HOWTOs/UI-ManageNewVolume-03.png" >}}Stroom UI Volumes - New Node configuration window volumes added{{< /screenshot >}}

At this one can close the `Volumes` configuration window by pressing the {{< stroom-btn "Close" >}} button.
