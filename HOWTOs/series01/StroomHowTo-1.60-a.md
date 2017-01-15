# Stroom HOWTO - Initial Stroom User Interface (UI) Configuration activity.
The following is a HOWTO to demonstrate the initial configuration one would do via the Stroom UI to allow users to complete, and test, installations.

The HOWTO results with a running and configured Stroom deployment. One can use the following for a single node Stroom instance as well.

Last Update: Burn Alting, 13 Jan 2017
- Initial release

Assumptions:
 - the user has installed a single or multi-node Stroom cluster or is adding a new node to an existing Stroom cluster

__NOTE:__ This is a living document and as such screen images will be updated as and when needed. This may mean, that should a sequence of images display a date and or time, these may change and appear out of date/time order. If the displayed date/time is important, this will not be the case and all relevant images will be replaced.

## Logging into the Stroom UI for the first time.
To log into the UI of your newly installed Stroom instance, present the base url to your `Chrome` browser. The urls in our example HOWTOs are typically either `https://stroomp.strmdev00.org` or `https://stroomp.strmdev00.org/stroom`. You should enter such a url into your browser. If you have personal certificates loaded in your Chrome, you may be asked which certificate to use to authenticate yourself to `stroomp.strmdev00.org:443`. As Stroom has not been configured to use user certificates, the choice is not relevant. Additionally, if you followed the usual _HOWTO_ certificate creation process (i.e. self-signed), your browser will generate an alert as per
![Chrome SelfSigned Certificate Issue - Initial](../resources/Series01/UI-Chrome-NoCa-00.png "Self Signed Certificate Initial Warning")

To proceed you need to select the __ADVANCED__ hyperlink to see

![Chrome SelfSigned Certificate Issue - Advanced](../resources/Series01/UI-Chrome-NoCa-01.png "Self Signed Certificate Advanced Warning")

If you select the __Proceed to stroomp.strmdev00.org (unsafe)__ hyper-link you will be presented with the standard Stroom UI login page.

![Stroom User Interface login page](../resources/Series01/UI-Login-00.png "Stroom UI Login Page")

This page has two panels - **About Stroom** and **Login**.

In the **About Stroom** panel we see an introductory description of Stroom in the top left and deployment details in the bottom left of the panel. The deployment details provide
- `Build Version:` - the build version of the Stroom application deployed
- `Build Date:` - the date the version was built
- `Up Date:` - the install date
- `Node Name:` - the node within the Stroom cluster you have connected to

Each new Stroom deployment automatically creates the administrative user `admin` and this user's password is initially set to `admin`. Within the **Login** panel, enter `admin` into the *User Name:* entry box and `admin` into the *Password:* entry box as per

![Stroom UI Login Panel - Enter user](../resources/Series01/UI-Login-01.png "Stroom UI Login - logging in as admin")

<a name="ExpiredPasswordAnchor"></a>When you press the
![Stroom UI LoginButton](../resources/icons/buttonLogin.png "Stroom UI LoginButton")
button, you are advised that your user's password has expired and you need to change it.

![Stroom UI Login Panel - Password Expiry](../resources/Series01/UI-Login-02.png "Stroom UI Login - password expiry")

Press the
![Stroom UI OkButton](../resources/icons/buttonOk.png "Stroom UI OkButton")
button and enter the old password `admin` and a new password with confirmation in the appropriate entry boxes.

![Stroom UI Login Panel - Password Change](../resources/Series01/UI-Login-03.png "Stroom UI Login - password change")

Again press the
![Stroom UI OkButton](../resources/icons/buttonOk.png "Stroom UI OkButton")
button to see the confirmation that the password has changed.

![Stroom UI Login Panel - Password Change Confirmation](../resources/Series01/UI-Login-04.png "Stroom UI Login - password change confirmation").

On pressing
![Stroom UI CloseButton](../resources/icons/buttonClose.png "Stroom UI CloseButton")
you will be logged in as the `admin` user and you will be presented with the __Main Menu__ (`Item Tools Monitoring User Help`), and the `Explorer` and `Welcome` panels (or tabs).

![Stroom UI Login Panel - Logged in](../resources/Series01/UI-Login-06.png "Stroom UI Login - user logged in").

### Create an attributed administrative user
When configuring Stroom, we should do this as an _attributed_ user. That is we should create a user, in our case it will be `burn` and once created, we will perform all future activities within the User Interface as that _attributed_ user. You don't have to do this, but it is good security practice.

To add a new user, move your cursor to the `Tools` item of the __Main Menu__ and select to bring up the `Tools` sub-menu.

![Stroom UI New User - Tools Menu](../resources/Series01/UI-ToolsSubmenu-00.png "Stroom UI Tools sub-menu")

then move down and select the `Users and Groups` sub-item to be presented with the `Users and Groups` configuration window as seen below.

![Stroom UI New User - Users and Groups](../resources/Series01/UI-AddUser-00.png "Stroom UI New User - Users and Groups configuration")

To add the user, move the cursor to the _New_ icon ![New](../resources/icons/add.png "New") in the top left and select it. On selection you will be prompted for a user name. In our case we will enter the user `burn`.

![Stroom UI New User - Add User](../resources/Series01/UI-AddUser-01.png "Stroom UI New User - Add User")

and on pressing
![Stroom UI OkButton](../resources/icons/buttonOk.png "Stroom UI OkButton")
will be presented with the User configuration window.

![Stroom UI New User - User Configuration](../resources/Series01/UI-AddUser-02.png "Stroom UI New User - User configuration")

As we want our user to be an administrator, select the __Administrator__ Permission check-box

![Stroom UI New User - User Configuration Set Permission](../resources/Series01/UI-AddUser-03.png "Stroom UI New User - User configuration - set administrator permission")

and we also need to set `burn's` password (which he will need to reset on first login). So, select the
![Stroom UI ResetPasswordButton](../resources/icons/buttonResetPassword.png "Stroom UI ResetPasswordButton")
button to gain the Reset Password window

![Stroom UI New User - User Configuration Reset Password](../resources/Series01/UI-AddUser-04.png "Stroom UI New User - User configuration - reset password")

After setting a password and pressing the
![Stroom UI OkButton](../resources/icons/buttonOk.png "Stroom UI OkButton")
button we get the informational Alert window as per

![Stroom UI New User - User Configuration Reset Password Complete](../resources/Series01/UI-AddUser-05.png "Stroom UI New User - User configuration - reset password complete")

and on close of the Alert we are presented again with the `User` configuration window.

![Stroom UI New User - User Configuration User Added](../resources/Series01/UI-AddUser-06.png "Stroom UI New User - User configuration - user added")

We should close this window by pressing the 
![Stroom UI CloseButton](../resources/icons/buttonClose.png "Stroom UI CloseButton") button to be presented with the `Users and Groups` window with the new user `burn` added.

![Stroom UI New User - User Configuration Show User Added](../resources/Series01/UI-AddUser-07.png "Stroom UI New User - User configuration - show user added")

At this one can close the `User` configuration window by pressing the 
![Stroom UI CloseButton](../resources/icons/buttonClose.png "Stroom UI CloseButton") button.

### Log out of UI as admin
Having created our administrative user, we should log out. To do this, select the `User` item of the __Main Menu__ and to bring up the `User` sub-menu.

![Stroom UI New User - User Sub-menu](../resources/Series01/UI-UserSubmenu-00.png "Stroom UI - User Sub-menu")

and select the `Logout` sub-item and confirm you wish to log out by selecting the
![Stroom UI OkButton](../resources/icons/buttonOk.png "Stroom UI OkButton")
button.

![Stroom UI New User - User Logout confirmation](../resources/Series01/UI-UserLogout-00.png "Stroom UI - User Logout")

This will return you to the Login page

### Log in as the Attributed User to perform configuration tasks

This time we log in as the user `burn`.
![Stroom UI Login - Attributed User Login](../resources/Series01/UI-Login-05.png "Stroom UI Login - Attributed User Login")

Note that the user `burn` will need to change his password as it would be been set to expire immediately. Follow the same steps as for changing the `admin` user's password [earlier](#ExpiredPasswordAnchor).

### Configure the Volumes for our Stroom Instance
We need to configured the volumes for Stroom. The following example is for a two node Stroom cluster, but works equally well for a single node deployment as well.

To configure the volumes, move to the `Tools` item of the __Main Menu__ and select it to bring up the `Tools` sub-menu.
![Stroom UI Volume Management - Tools Menu](../resources/Series01/UI-ToolsSubmenu-00.png "Stroom UI Tools sub-menu")

then move down and select the `Volumes` sub-item to be presented with the `Volumes` configuration window as seen below.
![Stroom UI Volume Management - Configuration](../resources/Series01/UI-ManageVolumes-01.png "Stroom UI Volumes - configuration window")

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

You can see that two default volumes have already been created. This is because we accepted the default when installing the Stroom application and we accepted the default, of true, for the __CREATE_DEFAULT_VOLUME_ON_START__ configuration option. Had we selected false, there would be no volumes displayed.

It should be noted that at the time of writing, the default Status's of `Closed` are incorrect and they should default to `Inactive`. This will be corrected once issue https://github.com/gchq/stroom/issues/77 is deployed.

#### Add Volumes
Now from our two node Stroom Cluster example, our storage hierarchy was
- Node: `stroomp00.strmdev00.org`
 - `/stroomdata/stroom-data-p00`        - location to store Stroom application data files (events, etc.) for this node
 - `/stroomdata/stroom-index-p00`       - location to store Stroom application index files
 - `/stroomdata/stroom-working-p00`     - location to store Stroom application working files (e.g. tmp, output, etc.) for this node
 - `/stroomdata/stroom-working-p00/proxy`       - location for Stroom proxy to store inbound data files
- Node: `stroomp01.strmdev00.org`
 - `/stroomdata/stroom-data-p01`        - location to store Stroom application data files (events, etc.) for this node
 - `/stroomdata/stroom-index-p01`       - location to store Stroom application index files
 - `/stroomdata/stroom-working-p01`     - location to store Stroom application working files (e.g. tmp, output, etc.) for this node
 - `/stroomdata/stroom-working-p01/proxy`       - location for Stroom proxy to store inbound data files

From this we need to create four volumes. On `stroomp00.strmdev00.org` we create
 - `/stroomdata/stroom-data-p00`        - location to store Stroom application data files (events, etc.) for this node
 - `/stroomdata/stroom-index-p00`       - location to store Stroom application index files

and on `stroomp01.strmdev00.org` we create
 - `/stroomdata/stroom-data-p01`        - location to store Stroom application data files (events, etc.) for this node
 - `/stroomdata/stroom-index-p01`       - location to store Stroom application index files 

So the first step to configure a volume is to move the cursor to the _New_ icon ![New](../resources/icons/add.png "New") in the top left of the `Volumes` window and select it. This will bring up the `Add Volume` configuration window
![Stroom UI Volume Management - Add Volume](../resources/Series01/UI-ManageVolumes-02.png "Stroom UI Add Volume - Volume configuration window")

As you can see, the entry box titles reflect the attributes of a volume. So we will add the first nodes _data_ volume
 - `/stroomdata/stroom-data-p00`        - location to store Stroom application data files (events, etc.) for this node
for node `stroomp00`.

If you move the the *Node* drop down entry box and select it you will be presented with a choice of available nodes - in this case `stroomp00` and `stroomp01` as we have a two node cluster with these node names.
![Stroom UI Volume Management - Add Volume - Select node](../resources/Series01/UI-ManageVolumes-03.png "Stroom UI Add Volume - select node")

By selecting the node `stroomp00` we see

![Stroom UI Volume Management - Add Volume - Selected node](../resources/Series01/UI-ManageVolumes-04.png "Stroom UI Add Volume - selected node")

To configure the rest of the attributes for this volume, we:
- enter the *Path* to our first node's _data_ volume
- select a *Volume Type* of _Public_ as this is a data volume we want all nodes to access
- select a *Stream Status* of _Active_ to indicate we want to store data on it
- select an *Index Status* of _Inactive_ as we do __NOT__ want index data stored on it
- set a *Limit* of 12GB for allowed storage

![Stroom UI Volume Management - Add Volume - Adding First Data Volume](../resources/Series01/UI-ManageVolumes-05.png "Stroom UI Add Volume - adding first data volume")

and on selection of the 
![Stroom UI OkButton](../resources/icons/buttonOk.png "Stroom UI OkButton")
we see the changes in the `Volumes` configuration window
![Stroom UI Volume Management - Add Volume - Added First Data Volume](../resources/Series01/UI-ManageVolumes-06.png "Stroom UI Add Volume - added first data volume")

We next add the first node's index volume, as per

![Stroom UI Volume Management - Add Volume - Adding First Index Volume](../resources/Series01/UI-ManageVolumes-07.png "Stroom UI Add Volume - adding first index volume")

And after adding the second node's volumes we are finally presented with our configured volumes
![Stroom UI Volume Management - Add Volume - All Volumes Added](../resources/Series01/UI-ManageVolumes-08.png "Stroom UI Add Volume - all volumes added")

#### Delete Default Volumes
We now need to deal with our default volumes. We want to delete them.

![Stroom UI Volume Management - Delete Default Volumes](../resources/Series01/UI-ManageVolumes-09.png "Stroom UI Delete Default - display default")

So we move the cursor to the first volume's line (_stroomp00 /home/stroomuser/stroom-app/volumes/defaultindexVolume_ ...) and select the line then move the cursor to the  _Delete_ icon ![Delete](../resources/icons/delete.png "Delete") in the top left of the `Volumes` window and select it. On selection you will be given a confirmation request

![Stroom UI Volume Management - Delete Default Volumes Confirm](../resources/Series01/UI-ManageVolumes-10.png "Stroom UI Delete Default - confirm deletion")

at which we press the 
![Stroom UI OkButton](../resources/icons/buttonOk.png "Stroom UI OkButton")
button to see the first default volume has been deleted
![Stroom UI Volume Management - Delete Default Volumes First Complete](../resources/Series01/UI-ManageVolumes-11.png "Stroom UI Delete Default - first volume deleted")
and after we select then delete the second default volume( _stroomp00 /home/stroomuser/stroom-app/volumes/defaultStreamVolume_ ...), we are left with
![Stroom UI Volume Management - Delete Default Volumes All Deleted](../resources/Series01/UI-ManageVolumes-12.png "Stroom UI Delete Default - all deleted")

At this one can close the `Volumes` configuration window by pressing the 
![Stroom UI CloseButton](../resources/icons/buttonClose.png "Stroom UI CloseButton") button.

__NOTE__: At the time of writing there are a number of Volume issues.
##### Stroom Github Issue 79  - https://github.com/gchq/stroom/issues/79
Due to Issue 79, when configuring our volumes, we note that the directory stroom-index-p01 is created on `stroomp00.strmdev00.org` in `/stroomdata`.
```
[stroomuser@stroomp00 ~]$ cd /stroomdata
[stroomuser@stroomp00 stroomdata]$ ls -la
total 0
drwxr-x---. 7 stroomuser stroomuser 126 Jan 12 12:55 .
drwxr-xr-x. 5 root       root        54 Jan 12 10:00 ..
drwxr-x---. 2 stroomuser stroomuser   6 Jan 12 10:33 stroom-data-p00
drwxr-x---. 2 stroomuser stroomuser   6 Jan 12 12:04 stroom-data-p01
drwxr-x---. 2 stroomuser stroomuser   6 Jan 12 10:00 stroom-index-p00
drwxrwxr-x. 2 stroomuser stroomuser   6 Jan 12 12:55 stroom-index-p01
drwxr-x---. 4 stroomuser stroomuser  36 Jan 12 10:53 stroom-working-p00
[stroomuser@stroomp00 stroomdata]$ 
```
One can simply remove the directory a'la `rmdir stroom-index-p01`.
If the loadbalancer had logged us on to stroomp01 when one configured the volumes, the directory `stroom-index-p00` would have been created on `stroomp01.strmdev00.org` in `/stroomdata`.

##### Stroom Github Issue 84  - https://github.com/gchq/stroom/issues/84
Due to Issue 84, if we delete volumes in a multi node environment, the deletion is not propagated to all other nodes in a cluster. Thus if we attempted to use the volumes we would get a database error.
The current _workaround_ is to restart all the Stroom applications which will cause a reload of all volume information. This **MUST** be done before sending any data to your multi-node Stroom cluster.


## Node Configuration
In a Stroom cluster, nodes are expected to communicate with each other on port 8080 over http. Our installation in a multi node environment ensures the firewall will allow this but we also need to configure the nodes. This is achieved via the Stroom UI where we set a _Cluster URL_ for each node. We first log in as an administrative user.

To configure the nodes, move to the `Monitoring` item of the __Main Menu__ and select it to bring up the `Monitoring` sub-menu.
![Stroom UI Node Management - Monitoring Menu](../resources/Series01/UI-MonitoringSubmenu-00.png "Stroom UI Monitoring sub-menu")

then move down and select the `Nodes` sub-item to be presented with the `Nodes` configuration tab as seen below.

![Stroom UI Node Management - Management Tab](../resources/Series01/UI-NodeClusterSetup-01.png "Stroom UI Node Management - management tab")

To set `stroomp00`'s Cluster URL, move the it's line in the display and select it. It will be highlighted.

![Stroom UI Node Management - Management Tab - Select first node](../resources/Series01/UI-NodeClusterSetup-02.png "Stroom UI Node Management - select first node")

Then move the cursor to the _Edit Node_ icon ![EditNode](../resources/icons/edit.png "Edit Node") in the top left of the `Nodes` tab and select it. On selection the `Edit Node` configuration window will be displayed and into the __Cluster URL:__ entry box, enter the first node's URL of `http://stroomp00.strmdev00.org:8080/stroom/clustercall.rpc`

![Stroom UI Node Management - First Node setup](../resources/Series01/UI-NodeClusterSetup-03.png "Stroom UI Node Management - set clustercall url for first node")

then press the 
![Stroom UI OkButton](../resources/icons/buttonOk.png "Stroom UI OkButton")
at which we see the _Cluster URL_ has been set for the first node as per

![Stroom UI Node Management - First Node set](../resources/Series01/UI-NodeClusterSetup-04.png "Stroom UI Node Management - set clustercall url on first node")

We next select the second node

![Stroom UI Node Management - Management Tab - Select second node](../resources/Series01/UI-NodeClusterSetup-05.png "Stroom UI Node Management - select second node")

then move the cursor to the _Edit Node_ icon ![EditNode](../resources/icons/edit.png "Edit Node") in the top left of the `Nodes` tab and select it. On selection the `Edit Node` configuration window will be displayed and into the __Cluster URL:__ entry box, enter the second node's URL of `http://stroomp01.strmdev00.org:8080/stroom/clustercall.rpc`

![Stroom UI Node Management - Second Node setup](../resources/Series01/UI-NodeClusterSetup-06.png "Stroom UI Node Management - set clustercall url for second node")

then press the 
![Stroom UI OkButton](../resources/icons/buttonOk.png "Stroom UI OkButton")

At this we will see both nodes have the __Cluster URLs__ set.

![Stroom UI Node Management - Both Nodes setup](../resources/Series01/UI-NodeClusterSetup-07.png "Stroom UI Node Management - both nodes setup").

You may need to press the _Refresh_ icon
![Stroom UI Refresh](../resources/icons/refresh.png "Stroom UI RefreshButton")
found at top left of `Nodes` configuration tab, until both nodes show healthy pings.

![Stroom UI Node Management - Both Nodes ping](../resources/Series01/UI-NodeClusterSetup-08.png "Stroom UI Node Management - both nodes ping").

If you do not get ping results for each node, then they are not configured correctly. In that situation, review all log files and processes that you have performed.

Once you have set the Cluster URLs of each node you should also set the _master assignment priority_ for each node to be different to all of the others. In the image above both have been assigned equal priority - `1`. We will change `stroomp00` to have a different priority - `3`. You should note that the node with the highest priority gains the `Master` node status.

![Stroom UI Node Management - Node priority](../resources/Series01/UI-NodeClusterSetup-09.png "Stroom UI Node Management - set node priorities").

### Enable Stream Processors
To enable Stroom to process data, it's `Stream  Processors` need to be enabled. There are NOT enabled by default on installation.

To enable the `Stream Processors` we first log in as an administrative user, move to the `Monitoring` item of the __Main Menu__ and select it to bring up the `Monitoring` sub-menu.

![Stroom UI Node Management - Monitoring Menu](../resources/Series01/UI-MonitoringSubmenu-00.png "Stroom UI Monitoring sub-menu")

then move down and select the `Jobs` sub-item to be presented with the `Jobs` configuration tab as seen below.

![Stroom UI Jobs Management - Management Tab](../resources/Series01/UI-NodeProcessors-00.png "Stroom UI Jobs Management - management tab")

At this we select the `Stream Processor` _Job_ whose check-box is not selected

![Stroom UI Jobs Management - Stream processor](../resources/Series01/UI-NodeProcessors-01.png "Stroom UI Jobs Management - Stream Processor")

We enable both nodes by selecting their check-boxes as well as the main `Stream Processors` check-box.

![Stroom UI Jobs Management - Stream processor enabled](../resources/Series01/UI-NodeProcessors-02.png "Stroom UI Jobs Management - Stream Processor enabled")

## Add A Test Feed
In order for Stroom to be able to handle various data sources, be they Apache HTTPD web access, MicroSoft Windows Event or Squid Proxy logs, Stroom must be told what the data is when it is received. This is achieved using `Event Feeds`. Each feed has a unique name within the system.

To test our installation can accept and ingest data, we will create a test Event feed named `TEST-EVENTS-V1_0`. To do this, log into the UI. Although you don't need to be an administrator to create new feeds, for the present and for the purpose of these _HOWTOs_ we will use our _attributed user_ `burn`.

Once you have logged in, move the cursor to the **System** directory with the `Explorer` tab and select it.

![Stroom UI Create Feed - System Selected](../resources/Series01/UI-CreateFeed-00.png "Stroom UI Create Feed - System selected")

Once selected, _right click_ to bring up the `New Item` selection sub-menu. By selecting the **System** directory we are requesting any  _new_ item created to be placed within in.

![Stroom UI Create Feed - New Item Sub-menu](../resources/Series01/UI-CreateFeed-01.png "Stroom UI Create Feed - New item sub-menu")

Now move the cursor to the _Feed_ sub-item 
![Stroom UI FeedItem](../resources/icons/feedItem.png "Stroom UI FeedItem")
and select it. You will be presented with a `New Feed` configuration window.

![Stroom UI Create Feed - New Feed Configuration](../resources/Series01/UI-CreateFeed-02.png "Stroom UI Create Feed - New feed configuration window")

You will note that the **System** directory has already been selected as the _parent group_ and all we need to do is enter our feed's name in the **Name:** entry box

![Stroom UI Create Feed - New Feed Configuration named](../resources/Series01/UI-CreateFeed-03.png "Stroom UI Create Feed - New feed configuration window enter name")

On pressing
![Stroom UI OkButton](../resources/icons/buttonOk.png "Stroom UI OkButton")
we are presented with the `Feed` tab for our new feed. The tab is labelled with the feed name `TEST-FEED-V1_0`.

![Stroom UI Create Feed - New Feed Tab](../resources/Series01/UI-CreateFeed-04.png "Stroom UI Create Feed - New feed tab").

We will leave the definitions of the Feed attributes for the present, but we _will_ enter a **Description:** for our feed as we should _ALWAYS_ do this fundamental tenet of data management - document the data. We will use the description of '_Feed for installation validation only. No data value_'.

![Stroom UI Create Feed - New Feed Tab with Description](../resources/Series01/UI-CreateFeed-05.png "Stroom UI Create Feed - New feed tab with Description").

One should note that the `Feed` tab as been marked as having unsaved changes. This is indicated by the asterisk character `*` between the _Feed_ icon ![Feed](../resources/icons/feed.png "Feed") and the name of the feed `TEST-FEED-V1_0`.
We can save the changes to our feed by pressing the _Save_ icon ![Save](../resources/icons/save.png "Save") in the top left of the `TEST-FEED-V1_0` tab. At this point one should notice two things, the first is that the asterisk has disappeared from the `Feed` tab and the _Save_ icon ![Save](../resources/icons/save.png "Save") is _ghosted_.

![Stroom UI Create Feed - New Feed Tab with Description saved](../resources/Series01/UI-CreateFeed-06.png "Stroom UI Create Feed - New feed tab with description saved").

### Sending data to our Test Feed

__NOTE:__ Before testing our new feed, we should restart both our Stroom application services so that any volume changes are propagated. This can be achieved by simply running

```bash
sudo -i -u stroomuser
bin/StopServices.sh
bin/StartServices.sh
```
on both nodes. It is suggested you first log out of Stroom, if you are currently logged in and you should monitor the Stroom application logs to ensure it has successfully restarted. Remember to use the `T` and `Tp` bash aliases we set up.

For this test, we will send the contents of /etc/group to our test feed. We will also send the file from the cluster's database machine. The command to send this file is

```bash
curl -k --data-binary @/etc/group "https://stroomp.strmdev00.org/stroom/datafeed" -H "Feed:TEST-FEED-V1_0" -H "System:EXAMPLE_SYSTEM" -H "Environment:EXAMPLE_ENVIRONMENT"
```

We will test a number of features as part of our installation test. These are
- simple post of data
- simple post of data to validate load balancing is working
- simple post to _direct_ feed interface
- simple post to _direct_ feed interface to validate load balancing is working 
- identify that the Stroom _Proxy Aggregation_ is working correctly

As part of our testing will check the presence of files within the proxy landing area and this is the location from which Stroom automatically ingests the data stored by the proxy, we can either turn off proxy aggregation or attempt to perform our tests noting that proxy aggregation occurs every 10 minutes by default. For simplicity, we will turn off the `Proxy Aggregation` job.

#### Turning off Proxy Aggregation
First log into the Stroom UI as an administrative user and by selecting the `Monitoring` item of the __Main Menu__ to bring up the `Monitoring` sub-menu.

![Stroom UI Node Management - Monitoring Menu](../resources/Series01/UI-MonitoringSubmenu-00.png "Stroom UI Monitoring sub-menu")

then move down and select the `Jobs` sub-item to be presented with the `Jobs` configuration tab as seen below.

![Stroom UI Jobs Management - Management Tab](../resources/Series01/UI-JobsTab-00.png "Stroom UI Jobs Management - management tab")

Highlight the `Proxy Aggregation` job to display

![Stroom UI Jobs Management - Proxy Aggregation Job](../resources/Series01/UI-ProxyAggregation-00.png "Stroom UI Jobs Management - Proxy Aggregation Job")

At this, uncheck the `Enabled` check-boxes for both nodes and the main Proxy Aggregation check-box.

![Stroom UI Jobs Management - Proxy Aggregation Job Off](../resources/Series01/UI-ProxyAggregation-01.png "Stroom UI Jobs Management - Proxy Aggregation Job Off")

We know that any files the proxies receive will remain in place until we re-enable `Proxy Aggregation`.

#### Simple Post tests

These tests are to ensure the Stroom proxy and it's connection to the database is working along with the Apache mod_jk loadbalancer. We will send a file to the load balanced `stroomp.strmdev00.org` node (really `stroomp00.strmdev00.org`) and each time we send the file, it's receipt should be managed by alternate proxy nodes. As a number of elements can effect load balancing, it is not always guaranteed to alternate every time but for the most part it will.

Perform the following
- Log onto the Stroom database node (stroomdb0.strmdev00.org) as any user.
- Log onto both Stroom nodes and become the `stroomuser` and monitor each node's Stroom proxy service using the `Tp` bash macro. That is, on each node, run

```bash
sudo -i -u stroomuser
Tp
```

You will note events of the form from
`stroomp00.strmdev00.org`:

```
...
2017-01-14T06:22:26.672Z INFO  [ProxyProperties refresh thread 0] datafeed.ProxyHandlerFactory$1 (ProxyHandlerFactory.java:96) - refreshThread() - Started
2017-01-14T06:30:00.993Z INFO  [Repository Reader Thread 1] handler.ProxyRepositoryReader (ProxyRepositoryReader.java:143) - run() - Cron Match at 2017-01-14T06:30:00.993Z
2017-01-14T06:40:00.245Z INFO  [Repository Reader Thread 1] handler.ProxyRepositoryReader (ProxyRepositoryReader.java:143) - run() - Cron Match at 2017-01-14T06:40:00.245Z
```

and from `stroomp01.strmdev00.org`:


```
...
2017-01-14T06:22:26.828Z INFO  [ProxyProperties refresh thread 0] datafeed.ProxyHandlerFactory$1 (ProxyHandlerFactory.java:96) - refreshThread() - Started
2017-01-14T06:30:00.066Z INFO  [Repository Reader Thread 1] handler.ProxyRepositoryReader (ProxyRepositoryReader.java:143) - run() - Cron Match at 2017-01-14T06:30:00.066Z
2017-01-14T06:40:00.318Z INFO  [Repository Reader Thread 1] handler.ProxyRepositoryReader (ProxyRepositoryReader.java:143) - run() - Cron Match at 2017-01-14T06:40:00.318Z
```
 - On the Stroom database node, execute the command

```bash
curl -k --data-binary @/etc/group "https://stroomp.strmdev00.org/stroom/datafeed" -H "Feed:TEST-FEED-V1_0" -H "System:EXAMPLE_SYSTEM" -H "Environment:EXAMPLE_ENVIRONMENT"
```

If you are monitoring the proxy log of `stroomp00.strmdev00.org` you would see two new logs indicating the successful arrival of the file

```
2017-01-14T06:46:06.411Z INFO  [ajp-apr-9009-exec-1] handler.LogRequestHandler (LogRequestHandler.java:37) - log() - guid=54dc0da2-f35c-4dc2-8a98-448415ffc76b,feed=TEST-FEED-V1_0,system=EXAMPLE_SYSTEM,environment=EXAMPLE_ENVIRONMENT,remotehost=192.168.2.144,remoteaddress=192.168.2.144
2017-01-14T06:46:06.449Z INFO  [ajp-apr-9009-exec-1] datafeed.DataFeedRequestHandler$1 (DataFeedRequestHandler.java:104) - "doPost() - Took 571 ms to process (concurrentRequestCount=1) 200","Environment=EXAMPLE_ENVIRONMENT","Feed=TEST-FEED-V1_0","GUID=54dc0da2-f35c-4dc2-8a98-448415ffc76b","ReceivedTime=2017-01-14T06:46:05.883Z","RemoteAddress=192.168.2.144","RemoteHost=192.168.2.144","System=EXAMPLE_SYSTEM","accept=*/*","content-length=527","content-type=application/x-www-form-urlencoded","host=stroomp.strmdev00.org","user-agent=curl/7.29.0"
```

- On the Stroom database node, again execute the command


```bash
curl -k --data-binary @/etc/group "https://stroomp.strmdev00.org/stroom/datafeed" -H "Feed:TEST-FEED-V1_0" -H "System:EXAMPLE_SYSTEM" -H "Environment:EXAMPLE_ENVIRONMENT"
```

If you are monitoring the proxy log of `stroomp01.strmdev00.org` you should see a new log. As foreshadowed, we didn't as the time delay resulted in the first node getting the file. That is `stroomp00.strmdev00.org` log file gained the two entries

```
2017-01-14T06:47:26.642Z INFO  [ajp-apr-9009-exec-2] handler.LogRequestHandler (LogRequestHandler.java:37) - log() - guid=941d2904-734f-4764-9ccf-4124b94a56f6,feed=TEST-FEED-V1_0,system=EXAMPLE_SYSTEM,environment=EXAMPLE_ENVIRONMENT,remotehost=192.168.2.144,remoteaddress=192.168.2.144
2017-01-14T06:47:26.645Z INFO  [ajp-apr-9009-exec-2] datafeed.DataFeedRequestHandler$1 (DataFeedRequestHandler.java:104) - "doPost() - Took 174 ms to process (concurrentRequestCount=1) 200","Environment=EXAMPLE_ENVIRONMENT","Feed=TEST-FEED-V1_0","GUID=941d2904-734f-4764-9ccf-4124b94a56f6","ReceivedTime=2017-01-14T06:47:26.470Z","RemoteAddress=192.168.2.144","RemoteHost=192.168.2.144","System=EXAMPLE_SYSTEM","accept=*/*","content-length=527","content-type=application/x-www-form-urlencoded","host=stroomp.strmdev00.org","user-agent=curl/7.29.0"
```

- Again on the database node, execute the command and this time we see that node `stroomp01.strmdev00.org` received the file as per


```
2017-01-14T06:47:30.782Z INFO  [ajp-apr-9009-exec-1] handler.LogRequestHandler (LogRequestHandler.java:37) - log() - guid=2cef6e23-b0e6-4d75-8374-cca7caf66e15,feed=TEST-FEED-V1_0,system=EXAMPLE_SYSTEM,environment=EXAMPLE_ENVIRONMENT,remotehost=192.168.2.144,remoteaddress=192.168.2.144
2017-01-14T06:47:30.816Z INFO  [ajp-apr-9009-exec-1] datafeed.DataFeedRequestHandler$1 (DataFeedRequestHandler.java:104) - "doPost() - Took 593 ms to process (concurrentRequestCount=1) 200","Environment=EXAMPLE_ENVIRONMENT","Feed=TEST-FEED-V1_0","GUID=2cef6e23-b0e6-4d75-8374-cca7caf66e15","ReceivedTime=2017-01-14T06:47:30.238Z","RemoteAddress=192.168.2.144","RemoteHost=192.168.2.144","System=EXAMPLE_SYSTEM","accept=*/*","content-length=527","content-type=application/x-www-form-urlencoded","host=stroomp.strmdev00.org","user-agent=curl/7.29.0"
```

- Running the curl post command in quick succession shows the loadbalancer working ... four executions result in seeing our pair of logs appearing on alternate proxies.

`stroomp00`:

```
2017-01-14T06:52:09.815Z INFO  [ajp-apr-9009-exec-3] handler.LogRequestHandler (LogRequestHandler.java:37) - log() - guid=bf0bc38c-3533-4d5c-9ddf-5d30c0302787,feed=TEST-FEED-V1_0,system=EXAMPLE_SYSTEM,environment=EXAMPLE_ENVIRONMENT,remotehost=192.168.2.144,remoteaddress=192.168.2.144
2017-01-14T06:52:09.817Z INFO  [ajp-apr-9009-exec-3] datafeed.DataFeedRequestHandler$1 (DataFeedRequestHandler.java:104) - "doPost() - Took 262 ms to process (concurrentRequestCount=1) 200","Environment=EXAMPLE_ENVIRONMENT","Feed=TEST-FEED-V1_0","GUID=bf0bc38c-3533-4d5c-9ddf-5d30c0302787","ReceivedTime=2017-01-14T06:52:09.555Z","RemoteAddress=192.168.2.144","RemoteHost=192.168.2.144","System=EXAMPLE_SYSTEM","accept=*/*","content-length=527","content-type=application/x-www-form-urlencoded","host=stroomp.strmdev00.org","user-agent=curl/7.29.0"
```
`stroomp01`:

```
2017-01-14T06:52:11.139Z INFO  [ajp-apr-9009-exec-2] handler.LogRequestHandler (LogRequestHandler.java:37) - log() - guid=1088fdd8-6869-489f-8baf-948891363734,feed=TEST-FEED-V1_0,system=EXAMPLE_SYSTEM,environment=EXAMPLE_ENVIRONMENT,remotehost=192.168.2.144,remoteaddress=192.168.2.144
2017-01-14T06:52:11.150Z INFO  [ajp-apr-9009-exec-2] datafeed.DataFeedRequestHandler$1 (DataFeedRequestHandler.java:104) - "doPost() - Took 289 ms to process (concurrentRequestCount=1) 200","Environment=EXAMPLE_ENVIRONMENT","Feed=TEST-FEED-V1_0","GUID=1088fdd8-6869-489f-8baf-948891363734","ReceivedTime=2017-01-14T06:52:10.861Z","RemoteAddress=192.168.2.144","RemoteHost=192.168.2.144","System=EXAMPLE_SYSTEM","accept=*/*","content-length=527","content-type=application/x-www-form-urlencoded","host=stroomp.strmdev00.org","user-agent=curl/7.29.0"
```
`stroomp00`:

```
2017-01-14T06:52:12.284Z INFO  [ajp-apr-9009-exec-4] handler.LogRequestHandler (LogRequestHandler.java:37) - log() - guid=def94a4a-cf78-4c4d-9261-343663f7f79a,feed=TEST-FEED-V1_0,system=EXAMPLE_SYSTEM,environment=EXAMPLE_ENVIRONMENT,remotehost=192.168.2.144,remoteaddress=192.168.2.144
2017-01-14T06:52:12.289Z INFO  [ajp-apr-9009-exec-4] datafeed.DataFeedRequestHandler$1 (DataFeedRequestHandler.java:104) - "doPost() - Took 5.0 ms to process (concurrentRequestCount=1) 200","Environment=EXAMPLE_ENVIRONMENT","Feed=TEST-FEED-V1_0","GUID=def94a4a-cf78-4c4d-9261-343663f7f79a","ReceivedTime=2017-01-14T06:52:12.284Z","RemoteAddress=192.168.2.144","RemoteHost=192.168.2.144","System=EXAMPLE_SYSTEM","accept=*/*","content-length=527","content-type=application/x-www-form-urlencoded","host=stroomp.strmdev00.org","user-agent=curl/7.29.0"
```
`stroomp01`:

```
2017-01-14T06:52:13.374Z INFO  [ajp-apr-9009-exec-3] handler.LogRequestHandler (LogRequestHandler.java:37) - log() - guid=55dda4c9-2c76-43c8-9b48-dcdb3a1f459b,feed=TEST-FEED-V1_0,system=EXAMPLE_SYSTEM,environment=EXAMPLE_ENVIRONMENT,remotehost=192.168.2.144,remoteaddress=192.168.2.144
2017-01-14T06:52:13.378Z INFO  [ajp-apr-9009-exec-3] datafeed.DataFeedRequestHandler$1 (DataFeedRequestHandler.java:104) - "doPost() - Took 3.0 ms to process (concurrentRequestCount=1) 200","Environment=EXAMPLE_ENVIRONMENT","Feed=TEST-FEED-V1_0","GUID=55dda4c9-2c76-43c8-9b48-dcdb3a1f459b","ReceivedTime=2017-01-14T06:52:13.374Z","RemoteAddress=192.168.2.144","RemoteHost=192.168.2.144","System=EXAMPLE_SYSTEM","accept=*/*","content-length=527","content-type=application/x-www-form-urlencoded","host=stroomp.strmdev00.org","user-agent=curl/7.29.0"
```

At this point we will see what the proxies have received. 
- On each node run the command

```bash
ls -l /stroomdata/stroom-working*/proxy
```
On `stroomp00` we see

```
[stroomuser@stroomp00 ~]$ ls -l /stroomdata/stroom-working*/proxy
total 16
-rw-rw-r--. 1 stroomuser stroomuser 785 Jan 14 17:46 001.zip
-rw-rw-r--. 1 stroomuser stroomuser 783 Jan 14 17:47 002.zip
-rw-rw-r--. 1 stroomuser stroomuser 784 Jan 14 17:52 003.zip
-rw-rw-r--. 1 stroomuser stroomuser 783 Jan 14 17:52 004.zip
[stroomuser@stroomp00 ~]$
```

and on `stroomp01` we see

```
[stroomuser@stroomp01 ~]$ ls -l /stroomdata/stroom-working*/proxy
total 12
-rw-rw-r--. 1 stroomuser stroomuser 785 Jan 14 17:47 001.zip
-rw-rw-r--. 1 stroomuser stroomuser 783 Jan 14 17:52 002.zip
-rw-rw-r--. 1 stroomuser stroomuser 784 Jan 14 17:52 003.zip
[stroomuser@stroomp01 ~]$
```

which corresponds to the seven posts of data and the associated events in the proxy logs. To see the contents of one of these files we execute on either node, the command

```bash
unzip -c /stroomdata/stroom-working*/proxy/001.zip
```

to see

```
Archive:  /stroomdata/stroom-working-p00/proxy/001.zip
  inflating: 001.dat
root:x:0:
bin:x:1:
daemon:x:2:
sys:x:3:
adm:x:4:
tty:x:5:
disk:x:6:
lp:x:7:
mem:x:8:
kmem:x:9:
wheel:x:10:burn
cdrom:x:11:
mail:x:12:postfix
man:x:15:
dialout:x:18:
floppy:x:19:
games:x:20:
tape:x:30:
video:x:39:
ftp:x:50:
lock:x:54:
audio:x:63:
nobody:x:99:
users:x:100:
utmp:x:22:
utempter:x:35:
input:x:999:
systemd-journal:x:190:
systemd-bus-proxy:x:998:
systemd-network:x:192:
dbus:x:81:
polkitd:x:997:
ssh_keys:x:996:
dip:x:40:
tss:x:59:
sshd:x:74:
postdrop:x:90:
postfix:x:89:
chrony:x:995:
burn:x:1000:burn
mysql:x:27:

  inflating: 001.meta
content-type:application/x-www-form-urlencoded
Environment:EXAMPLE_ENVIRONMENT
Feed:TEST-FEED-V1_0
GUID:54dc0da2-f35c-4dc2-8a98-448415ffc76b
host:stroomp.strmdev00.org
ReceivedTime:2017-01-14T06:46:05.883Z
RemoteAddress:192.168.2.144
RemoteHost:192.168.2.144
StreamSize:527
System:EXAMPLE_SYSTEM
user-agent:curl/7.29.0

[stroomuser@stroomp00 ~]$
```

Checking the /etc/group file on `stroomdb0.strmdev00.org` confirms the above contents. For the present, ignore the metadata file present in the zip archive.

If you execute the same command on the other files, all that changes is the value of the _ReceivedTime:_ attribute in the `.meta` file.

For those curious about the file size differences, this is a function of the compression process within the proxy. Using `stroomp01`'s files and extracting them manually and renaming them results in the six files
```
[stroomuser@stroomp01 xx]$ ls -l
total 24
-rw-rw-r--. 1 stroomuser stroomuser 527 Jan 14 17:47 A_001.dat
-rw-rw-r--. 1 stroomuser stroomuser 321 Jan 14 17:47 A_001.meta
-rw-rw-r--. 1 stroomuser stroomuser 527 Jan 14 17:52 B_001.dat
-rw-rw-r--. 1 stroomuser stroomuser 321 Jan 14 17:52 B_001.meta
-rw-rw-r--. 1 stroomuser stroomuser 527 Jan 14 17:52 C_001.dat
-rw-rw-r--. 1 stroomuser stroomuser 321 Jan 14 17:52 C_001.meta
[stroomuser@stroomp01 xx]$ cmp A_001.dat B_001.dat
[stroomuser@stroomp01 xx]$ cmp B_001.dat C_001.dat
[stroomuser@stroomp01 xx]$ 
```

We have effectively tested the receipt of our data and the load balancing of the Apache mod_jk installation.

#### Simple Direct Post tests
In this test we will use the direct feed interface of the Stroom application, rather than sending data via the proxy. One would normally use this interface for time sensitive data which shouldn't aggregate in a proxy waiting for the Stroom application to collect it. In this situation we use the command
```bash
curl -k --data-binary @/etc/group "https://stroomp.strmdev00.org/stroom/datafeed/direct" -H "Feed:TEST-FEED-V1_0" -H "System:EXAMPLE_SYSTEM" -H "Environment:EXAMPLE_ENVIRONMENT"
```
To prepare for this test, we monitor the Stroom application log using the `T` bash alias on each node. So on each node run the command
```bash
sudo -i -u stroomuser
T
```
On each node you should see _LifecyleTask_ events, for example,
```
2017-01-14T07:42:08.281Z INFO  [Stroom P2 #7 - LifecycleTask] spring.StroomBeanMethodExecutable (StroomBeanMethodExecutable.java:47) - Executing nodeStatusExecutor.exec
2017-01-14T07:42:18.284Z INFO  [Stroom P2 #2 - LifecycleTask] spring.StroomBeanMethodExecutable (StroomBeanMethodExecutable.java:47) - Executing SQLStatisticEventStore.evict
2017-01-14T07:42:18.284Z INFO  [Stroom P2 #10 - LifecycleTask] spring.StroomBeanMethodExecutable (StroomBeanMethodExecutable.java:47) - Executing activeQueriesManager.evictExpiredElements
2017-01-14T07:42:18.285Z INFO  [Stroom P2 #7 - LifecycleTask] spring.StroomBeanMethodExecutable (StroomBeanMethodExecutable.java:47) - Executing distributedTaskFetcher.execute
```

To perform the test, on the database node, run the posting command a number of times in rapid succession. This will result in  _server.DataFeedServiceImpl_ events in both log files. The Stroom application log is quite busy, you may have to look for these logs.

In the following we needed to execute the posting command three times before seeing the data arrive on both nodes. Looking at the arrival times, the file turned up on the second node twice before appearing on the first node.
`strooomp00:`

```
2017-01-14T07:43:09.394Z INFO  [ajp-apr-8009-exec-6] server.DataFeedServiceImpl (DataFeedServiceImpl.java:133) - handleRequest response 200 - 0 - OK
```
and on `stroomp01:`

```
2017-01-14T07:43:05.614Z INFO  [ajp-apr-8009-exec-1] server.DataFeedServiceImpl (DataFeedServiceImpl.java:133) - handleRequest response 200 - 0 - OK
2017-01-14T07:43:06.821Z INFO  [ajp-apr-8009-exec-2] server.DataFeedServiceImpl (DataFeedServiceImpl.java:133) - handleRequest response 200 - 0 - OK
```

To confirm this data arrived, we need to view the __Data__ pane of our `TEST-FEED-V1_0` tab. To do this, first move the cursor to the `TEST-FEED-V1_0` entry in the `Explorer` tab and select the item with a left click

![Stroom UI Test Feed - Open Feed](../resources/Series01/UI-TestDirectFeed-00.png "Stroom UI Test Feed - Open Feed")

and double click on the entry to see our `TEST-FEED-V1_0` tab.

![Stroom UI Test Feed - Opened Feed](../resources/Series01/UI-TestDirectFeed-01.png "Stroom UI Test Feed - Opened Feed")
and it is noted that we are viewing the Feed's attributes as we can see the __Setting__ hyper-link highlighted. As we want to see the Data we have received for this feed, move the cursor to the __Data__ hyper-link and select it to see
![Stroom UI Test Feed - Opened Feed Data](../resources/Series01/UI-TestDirectFeed-02.png "Stroom UI Test Feed - Opened Feed view Data").

These three entries correspond to the three posts we performed.

We have successfully tested direct posting to a Stroom feed and that the Apache mod_jk loadbalancer also works for this posting method.

#### Test Proxy Aggregation is Working

To test that the Proxy Aggregation is working, return to the `Jobs` tab and re-enable each node's `Proxy Aggregation` check-box and the main `Proxy Aggregation` check-box. After checking the check-boxes, perform a refresh of the display by pressing
the _Refresh_ icon ![Stroom UI Refresh](../resources/icons/refresh.png "Stroom UI RefreshButton")
on the top right of the lower (node display) pane. You should note the `Last Executed` date/time change to see
![Stroom UI Test Feed - Re-enable Proxy Aggregation](../resources/Series01/UI-TestProxyAggregation-00.png "Stroom UI Test Feed - Re-enable Proxy Aggregation").

By enabling the Proxy Aggregation process, both nodes immediately performed the task as indicated by each node's Stroom application logs as per
`stroomp00:`

```
2017-01-14T07:58:58.752Z INFO  [Stroom P2 #3 - LifecycleTask] server.ProxyAggregationExecutor (ProxyAggregationExecutor.java:138) - exec() - started
2017-01-14T07:58:58.937Z INFO  [Stroom P2 #2 - GenericServerTask] server.ProxyAggregationExecutor$2 (ProxyAggregationExecutor.java:203) - processFeedF
iles() - Started TEST-FEED-V1_0 (4 Files)
2017-01-14T07:58:59.045Z INFO  [Stroom P2 #2 - GenericServerTask] server.ProxyAggregationExecutor$2 (ProxyAggregationExecutor.java:265) - processFeedF
iles() - Completed TEST-FEED-V1_0 in 108 ms
2017-01-14T07:58:59.101Z INFO  [Stroom P2 #3 - LifecycleTask] server.ProxyAggregationExecutor (ProxyAggregationExecutor.java:152) - exec() - completed
 in 349 ms
```

and `stroomp01:`

```
2017-01-14T07:59:16.687Z INFO  [Stroom P2 #10 - LifecycleTask] server.ProxyAggregationExecutor (ProxyAggregationExecutor.java:138) - exec() - started
2017-01-14T07:59:16.799Z INFO  [Stroom P2 #5 - GenericServerTask] server.ProxyAggregationExecutor$2 (ProxyAggregationExecutor.java:203) - processFeedF
iles() - Started TEST-FEED-V1_0 (3 Files)
2017-01-14T07:59:16.909Z INFO  [Stroom P2 #5 - GenericServerTask] server.ProxyAggregationExecutor$2 (ProxyAggregationExecutor.java:265) - processFeedF
iles() - Completed TEST-FEED-V1_0 in 110 ms
2017-01-14T07:59:16.997Z INFO  [Stroom P2 #10 - LifecycleTask] server.ProxyAggregationExecutor (ProxyAggregationExecutor.java:152) - exec() - complete
d in 310 ms
```

And on refreshing the top pane of the `TEST-FEED-V1_0` tab we see that two more _batches_ of data have arrived.

![Stroom UI Test Feed - Proxy Aggregated Data Arrival](../resources/Series01/UI-TestProxyAggregation-01.png "Stroom UI Test Feed - Proxy Aggregated data arrival").

This demonstrates that Proxy Aggregation is working.

## Adding a New Node into a Cluster
If we have installed a new node into a cluster, before it can operate, we need to configure it. In the following we are executing the configuration steps that follow from the _HOWTO_ of adding a new volume to a cluster.
We first log into the Stroom UI as an administrator user.

### Configure the New Node's Volumes
Our new node's storage hierarchy is

- Node: `stroomp02.strmdev00.org`
 - `/stroomdata/stroom-data-p02`        - location to store Stroom application data files (events, etc.) for this node
 - `/stroomdata/stroom-index-p02`       - location to store Stroom application index files
 - `/stroomdata/stroom-working-p02`     - location to store Stroom application working files (e.g. tmp, output, etc.) for this node
 - `/stroomdata/stroom-working-p02/proxy`       - location for Stroom proxy to store inbound data files

From this we need to create two volumes on `stroomp02`
 - `/stroomdata/stroom-data-p02`        - location to store Stroom application data files (events, etc.) for this node
 - `/stroomdata/stroom-index-p02`       - location to store Stroom application index files

To configure the volumes, move to the `Tools` item of the __Main Menu__ and select it to bring up the `Tools` sub-menu.
![Stroom UI Volume Management - Tools Menu](../resources/Series01/UI-ToolsSubmenu-00.png "Stroom UI Tools sub-menu")

then move down and select the `Volumes` sub-item to be presented with the `Volumes` configuration window as. We then move the cursor to the _New_ icon ![New](../resources/icons/add.png "New") in the top left of the `Volumes` window and select it. This will bring up the `Add Volume` configuration window where we select our volume's node `stroomp02`.

![Stroom UI Volume Management - Configuration - New Node Data Start](../resources/Series01/UI-ManageNewVolume-00.png "Stroom UI Volumes - New Node configuration window start data volume")

We select this node and then configure the rest of the attributes for this _data_ volume

![Stroom UI Volume Management - Configuration - New Node Data](../resources/Series01/UI-ManageNewVolume-01.png "Stroom UI Volumes - New Node configuration window data volume")

then press the
![Stroom UI OkButton](../resources/icons/buttonOk.png "Stroom UI OkButton") button.

We then add another volume for the _index_ volume for this node with attributes as per

![Stroom UI Volume Management - Configuration - New Index Added](../resources/Series01/UI-ManageNewVolume-02.png "Stroom UI Volumes - New Node configuration window index volume added")

And on pressing the ![Stroom UI OkButton](../resources/icons/buttonOk.png "Stroom UI OkButton") button we see our two new volumes for this node have been added.

![Stroom UI Volume Management - Configuration - New Node Added](../resources/Series01/UI-ManageNewVolume-03.png "Stroom UI Volumes - New Node configuration window volumes added")

At this one can close the `Volumes` configuration window by pressing the 
![Stroom UI CloseButton](../resources/icons/buttonClose.png "Stroom UI CloseButton") button.

### Configure New Node

To configure the new node, move to the `Monitoring` item of the __Main Menu__ and select it to bring up the `Monitoring` sub-menu.

![Stroom UI Node Management - Monitoring Menu](../resources/Series01/UI-MonitoringSubmenu-00.png "Stroom UI Monitoring sub-menu")

then move down and select the `Nodes` sub-item to be presented with the `Nodes` configuration tab as seen below.

![Stroom UI New Node Management - Management Tab](../resources/Series01/UI-AddNewNode-00.png "Stroom UI New Node Management - management tab")

To set `stroomp02`'s Cluster URL, move the it's line in the display and select it. It will be highlighted.

![Stroom UI Node Management - Management Tab - Select new node](../resources/Series01/UI-AddNewNode-01.png "Stroom UI Node Management - select new node")

Then move the cursor to the _Edit Node_ icon ![EditNode](../resources/icons/edit.png "Edit Node") in the top left of the `Nodes` tab and select it. On selection the `Edit Node` configuration window will be displayed and into the __Cluster URL:__ entry box, enter the first node's URL of `http://stroomp02.strmdev00.org:8080/stroom/clustercall.rpc`

![Stroom UI New Node Management - Node setup](../resources/Series01/UI-AddNewNode-02.png "Stroom UI New Node Management - set clustercall url for new node")

then press the 
![Stroom UI OkButton](../resources/icons/buttonOk.png "Stroom UI OkButton")
button at which we see the _Cluster URL_ has been set for the first node as per

![Stroom UI New Node Management - New Node set](../resources/Series01/UI-AddNewNode-03.png "Stroom UI New Node Management - set clustercall url on new node")

You need to press the _Refresh_ icon
![Stroom UI Refresh](../resources/icons/refresh.png "Stroom UI RefreshButton")
found at top left of `Nodes` configuration tab, until the new node shows a healthy ping.

![Stroom UI New Node Management - All Nodes ping](../resources/Series01/UI-AddNewNode-04.png "Stroom UI New Node Management - all nodes ping").

If you do not get a ping results for the new node, then it is not configured correctly. In that situation, review all log files and processes that you have performed.

Once you have set the Cluster URL you should also set the _master assignment priority_ for each node to be different to all of the others. In the image above both `stroomp01` and the new node, `stroomp02`, have been assigned equal priority - `1`. We will change `stroomp01` to have a different priority - `2`. You should note that the node with the highest priority maintains the `Master` node status.

![Stroom UI New Node Management - Node priority](../resources/Series01/UI-AddNewNode-05.png "Stroom UI New Node Management - set node priorities").

### Enable Stream Processors for New Node
To enable Stroom to process data, it's `Stream  Processors` need to be enabled. There are NOT enabled by default on installation.

To enable the `Stream Processors` for this new node, move to the `Monitoring` item of the __Main Menu__ and select it to bring up the `Monitoring` sub-menu.

![Stroom UI Node Management - Monitoring Menu](../resources/Series01/UI-MonitoringSubmenu-00.png "Stroom UI Monitoring sub-menu")

then move down and select the `Jobs` sub-item to be presented with the `Jobs` configuration tab as seen below.

![Stroom UI Jobs Management - Management Tab](../resources/Series01/UI-NodeProcessors-00.png "Stroom UI Jobs Management - management tab")

At this we select the `Stream Processor` _Job_ whose check-box is selected

![Stroom UI Jobs Management - Stream processor New Node](../resources/Series01/UI-NewNodeProcessors-00.png "Stroom UI Jobs Management - Stream Processor new node")

We enable the new node by selecting it's check-box.

![Stroom UI Jobs Management - Stream processor New Node enabled](../resources/Series01/UI-NewNodeProcessors-01.png "Stroom UI Jobs Management - Stream Processor enabled on new node")

## Reload the Apache HTTPD services on existing nodes
To finish the addition of the new node, we need to restart the httpd service on our original nodes so that the new loadbalancer properties are accepted and our new node can participate in the cluster. This can be done by executing on `stroomp00` and `stroomp01`, the command (as root)

```bash
systemctl reload httpd.service
```

At this our new node should be integrated into our cluster and can accept and process data.
