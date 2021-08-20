---
title: "Testing Stroom Installation"
linkTitle: "Testing Stroom Installation"
#weight:
date: 2021-07-12
tags:
  - testing
  - installation
description: >
  This HOWTO will demonstrate various ways to test that your Stroom installation has been successful.
---

## Assumptions
- Stroom Single or Multi Node Cluster Testing
 - the [Multi Node Stroom Cluster (Proxy and Application)](InstallHowTo.md#multi-node-stroom-cluster-proxy-and-application-deployment "Multi Node Stroom Cluster (Proxy and Application") has been deployed
 - a [Test Feed](InstallHowTo.md#add-a-test-feed "Add a Test Feed"), `TEST-FEED-V1_0` has been added
 - Proxy aggregation has been turned off on all Stroom _Store_ Proxies
 - the Stroom Proxy Repository Format (`REPO_FORMAT`) chosen was the default - `${pathId}/${id`
- Stroom Forwarding Proxy Testing
 - the [Multi Node Stroom Cluster (Proxy and Application)](InstallHowTo.md#multi-node-stroom-cluster-proxy-and-application-deployment "Multi Node Stroom Cluster (Proxy and Application") has been deployed
 - the [Stroom Forwarding Proxy](InstallHowTo.md#forwarding-stroom-proxy-deployment "Stroom Forwarding Proxy") has been deployed
 - a [Test Feed](InstallHowTo.md#add-a-test-feed "Add a Test Feed"), `TEST-FEED-V1_0` has been added
 - the Stroom Proxy Repository Format (`REPO_FORMAT`) chosen was the default - `${pathId}/${id`
- Stroom Standalone Proxy Testing
 - the [Stroom Standalone Proxy](InstallHowTo.md#standalone-stroom-proxy-deployment "Stroom Standalone Proxy") has been deployed
 - the Stroom Proxy Repository Format (`REPO_FORMAT`) chosen was the default - `${pathId}/${id`

## Stroom Single or Multi Node Cluster Testing
### Data Post Tests
#### Simple Post tests

These tests are to ensure the Stroom _Store_ proxy and it's connection to the database is working along with the Apache mod_jk loadbalancer.
We will send a file to the load balanced `stroomp.strmdev00.org` node (really `stroomp00.strmdev00.org`) and each time we send the file,
it's receipt should be managed by alternate proxy nodes. As a number of elements can effect load balancing, it is not always guaranteed
to alternate every time but for the most part it will.

Perform the following
- Log onto the Stroom database node (stroomdb0.strmdev00.org) as any user.
- Log onto both Stroom nodes and become the `stroomuser` and monitor each node's Stroom proxy service using the `Tp` bash macro. That is, on each node, run

```bash
sudo -i -u stroomuser
Tp
```

You will note events of the form from
`stroomp00.strmdev00.org`:

```text
...
2017-01-14T06:22:26.672Z INFO  [ProxyProperties refresh thread 0] datafeed.ProxyHandlerFactory$1 (ProxyHandlerFactory.java:96) - refreshThread() - Started
2017-01-14T06:30:00.993Z INFO  [Repository Reader Thread 1] handler.ProxyRepositoryReader (ProxyRepositoryReader.java:143) - run() - Cron Match at 2017-01-14T06:30:00.993Z
2017-01-14T06:40:00.245Z INFO  [Repository Reader Thread 1] handler.ProxyRepositoryReader (ProxyRepositoryReader.java:143) - run() - Cron Match at 2017-01-14T06:40:00.245Z
```

and from `stroomp01.strmdev00.org`:


```text
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

```text
2017-01-14T06:46:06.411Z INFO  [ajp-apr-9009-exec-1] handler.LogRequestHandler (LogRequestHandler.java:37) - log() - guid=54dc0da2-f35c-4dc2-8a98-448415ffc76b,feed=TEST-FEED-V1_0,system=EXAMPLE_SYSTEM,environment=EXAMPLE_ENVIRONMENT,remotehost=192.168.2.144,remoteaddress=192.168.2.144
2017-01-14T06:46:06.449Z INFO  [ajp-apr-9009-exec-1] datafeed.DataFeedRequestHandler$1 (DataFeedRequestHandler.java:104) - "doPost() - Took 571 ms to process (concurrentRequestCount=1) 200","Environment=EXAMPLE_ENVIRONMENT","Feed=TEST-FEED-V1_0","GUID=54dc0da2-f35c-4dc2-8a98-448415ffc76b","ReceivedTime=2017-01-14T06:46:05.883Z","RemoteAddress=192.168.2.144","RemoteHost=192.168.2.144","System=EXAMPLE_SYSTEM","accept=*/*","content-length=527","content-type=application/x-www-form-urlencoded","host=stroomp.strmdev00.org","user-agent=curl/7.29.0"
```

- On the Stroom database node, again execute the command


```bash
curl -k --data-binary @/etc/group "https://stroomp.strmdev00.org/stroom/datafeed" -H "Feed:TEST-FEED-V1_0" -H "System:EXAMPLE_SYSTEM" -H "Environment:EXAMPLE_ENVIRONMENT"
```

If you are monitoring the proxy log of `stroomp01.strmdev00.org` you should see a new log. As foreshadowed, we didn't as the time delay resulted
in the first node getting the file. That is `stroomp00.strmdev00.org` log file gained the two entries

```text
2017-01-14T06:47:26.642Z INFO  [ajp-apr-9009-exec-2] handler.LogRequestHandler (LogRequestHandler.java:37) - log() - guid=941d2904-734f-4764-9ccf-4124b94a56f6,feed=TEST-FEED-V1_0,system=EXAMPLE_SYSTEM,environment=EXAMPLE_ENVIRONMENT,remotehost=192.168.2.144,remoteaddress=192.168.2.144
2017-01-14T06:47:26.645Z INFO  [ajp-apr-9009-exec-2] datafeed.DataFeedRequestHandler$1 (DataFeedRequestHandler.java:104) - "doPost() - Took 174 ms to process (concurrentRequestCount=1) 200","Environment=EXAMPLE_ENVIRONMENT","Feed=TEST-FEED-V1_0","GUID=941d2904-734f-4764-9ccf-4124b94a56f6","ReceivedTime=2017-01-14T06:47:26.470Z","RemoteAddress=192.168.2.144","RemoteHost=192.168.2.144","System=EXAMPLE_SYSTEM","accept=*/*","content-length=527","content-type=application/x-www-form-urlencoded","host=stroomp.strmdev00.org","user-agent=curl/7.29.0"
```

- Again on the database node, execute the command and this time we see that node `stroomp01.strmdev00.org` received the file as per


```text
2017-01-14T06:47:30.782Z INFO  [ajp-apr-9009-exec-1] handler.LogRequestHandler (LogRequestHandler.java:37) - log() - guid=2cef6e23-b0e6-4d75-8374-cca7caf66e15,feed=TEST-FEED-V1_0,system=EXAMPLE_SYSTEM,environment=EXAMPLE_ENVIRONMENT,remotehost=192.168.2.144,remoteaddress=192.168.2.144
2017-01-14T06:47:30.816Z INFO  [ajp-apr-9009-exec-1] datafeed.DataFeedRequestHandler$1 (DataFeedRequestHandler.java:104) - "doPost() - Took 593 ms to process (concurrentRequestCount=1) 200","Environment=EXAMPLE_ENVIRONMENT","Feed=TEST-FEED-V1_0","GUID=2cef6e23-b0e6-4d75-8374-cca7caf66e15","ReceivedTime=2017-01-14T06:47:30.238Z","RemoteAddress=192.168.2.144","RemoteHost=192.168.2.144","System=EXAMPLE_SYSTEM","accept=*/*","content-length=527","content-type=application/x-www-form-urlencoded","host=stroomp.strmdev00.org","user-agent=curl/7.29.0"
```

- Running the curl post command in quick succession shows the loadbalancer working ... four executions result in seeing our pair of logs appearing on alternate proxies.

`stroomp00`:

```text
2017-01-14T06:52:09.815Z INFO  [ajp-apr-9009-exec-3] handler.LogRequestHandler (LogRequestHandler.java:37) - log() - guid=bf0bc38c-3533-4d5c-9ddf-5d30c0302787,feed=TEST-FEED-V1_0,system=EXAMPLE_SYSTEM,environment=EXAMPLE_ENVIRONMENT,remotehost=192.168.2.144,remoteaddress=192.168.2.144
2017-01-14T06:52:09.817Z INFO  [ajp-apr-9009-exec-3] datafeed.DataFeedRequestHandler$1 (DataFeedRequestHandler.java:104) - "doPost() - Took 262 ms to process (concurrentRequestCount=1) 200","Environment=EXAMPLE_ENVIRONMENT","Feed=TEST-FEED-V1_0","GUID=bf0bc38c-3533-4d5c-9ddf-5d30c0302787","ReceivedTime=2017-01-14T06:52:09.555Z","RemoteAddress=192.168.2.144","RemoteHost=192.168.2.144","System=EXAMPLE_SYSTEM","accept=*/*","content-length=527","content-type=application/x-www-form-urlencoded","host=stroomp.strmdev00.org","user-agent=curl/7.29.0"
```
`stroomp01`:

```text
2017-01-14T06:52:11.139Z INFO  [ajp-apr-9009-exec-2] handler.LogRequestHandler (LogRequestHandler.java:37) - log() - guid=1088fdd8-6869-489f-8baf-948891363734,feed=TEST-FEED-V1_0,system=EXAMPLE_SYSTEM,environment=EXAMPLE_ENVIRONMENT,remotehost=192.168.2.144,remoteaddress=192.168.2.144
2017-01-14T06:52:11.150Z INFO  [ajp-apr-9009-exec-2] datafeed.DataFeedRequestHandler$1 (DataFeedRequestHandler.java:104) - "doPost() - Took 289 ms to process (concurrentRequestCount=1) 200","Environment=EXAMPLE_ENVIRONMENT","Feed=TEST-FEED-V1_0","GUID=1088fdd8-6869-489f-8baf-948891363734","ReceivedTime=2017-01-14T06:52:10.861Z","RemoteAddress=192.168.2.144","RemoteHost=192.168.2.144","System=EXAMPLE_SYSTEM","accept=*/*","content-length=527","content-type=application/x-www-form-urlencoded","host=stroomp.strmdev00.org","user-agent=curl/7.29.0"
```
`stroomp00`:

```text
2017-01-14T06:52:12.284Z INFO  [ajp-apr-9009-exec-4] handler.LogRequestHandler (LogRequestHandler.java:37) - log() - guid=def94a4a-cf78-4c4d-9261-343663f7f79a,feed=TEST-FEED-V1_0,system=EXAMPLE_SYSTEM,environment=EXAMPLE_ENVIRONMENT,remotehost=192.168.2.144,remoteaddress=192.168.2.144
2017-01-14T06:52:12.289Z INFO  [ajp-apr-9009-exec-4] datafeed.DataFeedRequestHandler$1 (DataFeedRequestHandler.java:104) - "doPost() - Took 5.0 ms to process (concurrentRequestCount=1) 200","Environment=EXAMPLE_ENVIRONMENT","Feed=TEST-FEED-V1_0","GUID=def94a4a-cf78-4c4d-9261-343663f7f79a","ReceivedTime=2017-01-14T06:52:12.284Z","RemoteAddress=192.168.2.144","RemoteHost=192.168.2.144","System=EXAMPLE_SYSTEM","accept=*/*","content-length=527","content-type=application/x-www-form-urlencoded","host=stroomp.strmdev00.org","user-agent=curl/7.29.0"
```
`stroomp01`:

```text
2017-01-14T06:52:13.374Z INFO  [ajp-apr-9009-exec-3] handler.LogRequestHandler (LogRequestHandler.java:37) - log() - guid=55dda4c9-2c76-43c8-9b48-dcdb3a1f459b,feed=TEST-FEED-V1_0,system=EXAMPLE_SYSTEM,environment=EXAMPLE_ENVIRONMENT,remotehost=192.168.2.144,remoteaddress=192.168.2.144
2017-01-14T06:52:13.378Z INFO  [ajp-apr-9009-exec-3] datafeed.DataFeedRequestHandler$1 (DataFeedRequestHandler.java:104) - "doPost() - Took 3.0 ms to process (concurrentRequestCount=1) 200","Environment=EXAMPLE_ENVIRONMENT","Feed=TEST-FEED-V1_0","GUID=55dda4c9-2c76-43c8-9b48-dcdb3a1f459b","ReceivedTime=2017-01-14T06:52:13.374Z","RemoteAddress=192.168.2.144","RemoteHost=192.168.2.144","System=EXAMPLE_SYSTEM","accept=*/*","content-length=527","content-type=application/x-www-form-urlencoded","host=stroomp.strmdev00.org","user-agent=curl/7.29.0"
```

At this point we will see what the proxies have received. 
- On each node run the command

```bash
ls -l /stroomdata/stroom-working*/proxy
```
On `stroomp00` we see

```text
[stroomuser@stroomp00 ~]$ ls -l /stroomdata/stroom-working*/proxy
total 16
-rw-rw-r--. 1 stroomuser stroomuser 785 Jan 14 17:46 001.zip
-rw-rw-r--. 1 stroomuser stroomuser 783 Jan 14 17:47 002.zip
-rw-rw-r--. 1 stroomuser stroomuser 784 Jan 14 17:52 003.zip
-rw-rw-r--. 1 stroomuser stroomuser 783 Jan 14 17:52 004.zip
[stroomuser@stroomp00 ~]$
```

and on `stroomp01` we see

```text
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

```text
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

Checking the /etc/group file on `stroomdb0.strmdev00.org` confirms the above contents. For the present, ignore
the metadata file present in the zip archive.

If you execute the same command on the other files, all that changes is the value of the _ReceivedTime:_ attribute in the `.meta` file.

For those curious about the file size differences, this is a function of the compression process within the proxy.
Using `stroomp01`'s files and extracting them manually and renaming them results in the six files
```text
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
In this test we will use the direct feed interface of the Stroom application, rather than sending data via the proxy.
One would normally use this interface for time sensitive data which shouldn't aggregate in a proxy waiting for
the Stroom application to collect it. In this situation we use the command
```bash
curl -k --data-binary @/etc/group "https://stroomp.strmdev00.org/stroom/datafeed/direct" -H "Feed:TEST-FEED-V1_0" -H "System:EXAMPLE_SYSTEM" -H "Environment:EXAMPLE_ENVIRONMENT"
```

To prepare for this test, we monitor the Stroom application log using the `T` bash alias on each node. So on each node run the command

```bash
sudo -i -u stroomuser
T
```

On each node you should see _LifecyleTask_ events, for example,

```text
2017-01-14T07:42:08.281Z INFO  [Stroom P2 #7 - LifecycleTask] spring.StroomBeanMethodExecutable (StroomBeanMethodExecutable.java:47) - Executing nodeStatusExecutor.exec
2017-01-14T07:42:18.284Z INFO  [Stroom P2 #2 - LifecycleTask] spring.StroomBeanMethodExecutable (StroomBeanMethodExecutable.java:47) - Executing SQLStatisticEventStore.evict
2017-01-14T07:42:18.284Z INFO  [Stroom P2 #10 - LifecycleTask] spring.StroomBeanMethodExecutable (StroomBeanMethodExecutable.java:47) - Executing activeQueriesManager.evictExpiredElements
2017-01-14T07:42:18.285Z INFO  [Stroom P2 #7 - LifecycleTask] spring.StroomBeanMethodExecutable (StroomBeanMethodExecutable.java:47) - Executing distributedTaskFetcher.execute
```

To perform the test, on the database node, run the posting command a number of times in rapid succession. This will result
in  _server.DataFeedServiceImpl_ events in both log files. The Stroom application log is quite busy, you may have to look for these logs.

In the following we needed to execute the posting command three times before seeing the data arrive on both nodes. Looking at the arrival
times, the file turned up on the second node twice before appearing on the first node.
`strooomp00:`

```text
2017-01-14T07:43:09.394Z INFO  [ajp-apr-8009-exec-6] server.DataFeedServiceImpl (DataFeedServiceImpl.java:133) - handleRequest response 200 - 0 - OK
```
and on `stroomp01:`

```text
2017-01-14T07:43:05.614Z INFO  [ajp-apr-8009-exec-1] server.DataFeedServiceImpl (DataFeedServiceImpl.java:133) - handleRequest response 200 - 0 - OK
2017-01-14T07:43:06.821Z INFO  [ajp-apr-8009-exec-2] server.DataFeedServiceImpl (DataFeedServiceImpl.java:133) - handleRequest response 200 - 0 - OK
```

To confirm this data arrived, we need to view the __Data__ pane of our `TEST-FEED-V1_0` tab. To do this, log onto the Stroom UI then
move the cursor to the `TEST-FEED-V1_0` entry in the `Explorer` tab and select the item with a left click

{{< screenshot "HOWTOs/UI-TestDirectFeed-00.png" >}}Stroom UI Test Feed - Open Feed{{< /screenshot >}}

and double click on the entry to see our `TEST-FEED-V1_0` tab.

{{< screenshot "HOWTOs/UI-TestDirectFeed-01.png" >}}Stroom UI Test Feed - Opened Feed{{< /screenshot >}}
and it is noted that we are viewing the Feed's attributes as we can see the __Setting__ hyper-link highlighted.
As we want to see the Data we have received for this feed, move the cursor to the __Data__ hyper-link and select it to see
{{< screenshot "HOWTOs/UI-TestDirectFeed-02.png" >}}Stroom UI Test Feed - Opened Feed view Data{{< /screenshot >}}.

These three entries correspond to the three posts we performed.

We have successfully tested direct posting to a Stroom feed and that the Apache mod_jk loadbalancer also works for this posting method.

#### Test Proxy Aggregation is Working

To test that the Proxy Aggregation is working,
we need to [enable](../General/TasksHowTo.md#turn-on-proxy-aggregation "Enable Proxy Aggregation") on each node.

By enabling the Proxy Aggregation process, both nodes immediately performed the task as indicated by each node's Stroom application logs as per
`stroomp00:`

```text
2017-01-14T07:58:58.752Z INFO  [Stroom P2 #3 - LifecycleTask] server.ProxyAggregationExecutor (ProxyAggregationExecutor.java:138) - exec() - started
2017-01-14T07:58:58.937Z INFO  [Stroom P2 #2 - GenericServerTask] server.ProxyAggregationExecutor$2 (ProxyAggregationExecutor.java:203) - processFeedFiles() - Started TEST-FEED-V1_0 (4 Files)
2017-01-14T07:58:59.045Z INFO  [Stroom P2 #2 - GenericServerTask] server.ProxyAggregationExecutor$2 (ProxyAggregationExecutor.java:265) - processFeedFiles() - Completed TEST-FEED-V1_0 in 108 ms
2017-01-14T07:58:59.101Z INFO  [Stroom P2 #3 - LifecycleTask] server.ProxyAggregationExecutor (ProxyAggregationExecutor.java:152) - exec() - completedin 349 ms
```

and `stroomp01:`

```text
2017-01-14T07:59:16.687Z INFO  [Stroom P2 #10 - LifecycleTask] server.ProxyAggregationExecutor (ProxyAggregationExecutor.java:138) - exec() - started
2017-01-14T07:59:16.799Z INFO  [Stroom P2 #5 - GenericServerTask] server.ProxyAggregationExecutor$2 (ProxyAggregationExecutor.java:203) - processFeedFiles() - Started TEST-FEED-V1_0 (3 Files)
2017-01-14T07:59:16.909Z INFO  [Stroom P2 #5 - GenericServerTask] server.ProxyAggregationExecutor$2 (ProxyAggregationExecutor.java:265) - processFeedFiles() - Completed TEST-FEED-V1_0 in 110 ms
2017-01-14T07:59:16.997Z INFO  [Stroom P2 #10 - LifecycleTask] server.ProxyAggregationExecutor (ProxyAggregationExecutor.java:152) - exec() - completed in 310 ms
```

And on refreshing the top pane of the `TEST-FEED-V1_0` tab we see that two more _batches_ of data have arrived.

{{< screenshot "HOWTOs/UI-TestProxyAggregation-01.png" >}}Stroom UI Test Feed - Proxy Aggregated data arrival{{< /screenshot >}}.

This demonstrates that Proxy Aggregation is working.

## Stroom Forwarding Proxy Testing
### Data Post Tests
#### Simple Post tests

This test is to ensure the Stroom _Forwarding_ proxy and it's connection to the central Stroom Processing system is working.

We will send a file to our _Forwarding_ proxy (`stroomfp0.strmdev00.org`) and monitor this nodes' proxy log files as well as all the
destination nodes proxy log files. The reason for monitoring all the destination system's proxy log files is that the destination system is
probably load balancing and hence the forwarded file may turn up on any of the destination nodes.

Perform the following
- Log onto any host where you will perform the `curl` post
- Monitor all proxy log files
 - Log onto the Forwarding Proxy node and become the `stroomuser` and monitor the Stroom proxy service using the `Tp` bash macro.
 - Log onto the destination Stroom nodes and become the `stroomuser` and monitor each node's Stroom proxy service using the `Tp` bash macro. That is, on each node, run

```bash
sudo -i -u stroomuser
Tp
```

- On the 'posting' node, run the command

```bash
curl -k --data-binary @/etc/group "https://stroomfp0.strmdev00.org/stroom/datafeed" -H "Feed:TEST-FEED-V1_0" -H "System:EXAMPLE_SYSTEM" -H "Environment:EXAMPLE_ENVIRONMENT"
```

In the Stroom Forwarding proxy log, `~/stroom-proxy/instance/logs/stroom.log`, you will see the arrival of the
file as per the _datafeed.DataFeedRequestHandler$1_ event running under, in this case, the _ajp-apr-9009-exec-1_ thread.
```text
...
2017-01-01T23:17:00.240Z INFO  [Repository Reader Thread 1] handler.ProxyRepositoryReader (ProxyRepositoryReader.java:143) - run() - Cron Match at 2017-01-01T23:17:00.240Z
2017-01-01T23:18:00.275Z INFO  [Repository Reader Thread 1] handler.ProxyRepositoryReader (ProxyRepositoryReader.java:143) - run() - Cron Match at 2017-01-01T23:18:00.275Z
2017-01-01T23:18:12.367Z INFO  [ajp-apr-9009-exec-1] datafeed.DataFeedRequestHandler$1 (DataFeedRequestHandler.java:104) - "doPost() - Took 782 ms to process (concurrentRequestCount=1) 200","Environment=EXAMPLE_ENVIRONMENT","Expect=100-continue","Feed=TEST-FEED-V1_0","GUID=9601198e-98db-4cae-8b71-9404722ef1f9","ReceivedTime=2017-01-01T23:18:11.588Z","RemoteAddress=192.168.2.220","RemoteHost=192.168.2.220","System=EXAMPLE_SYSTEM","accept=*/*","content-length=1051","content-type=application/x-www-form-urlencoded","host=stroomfp0.strmdev00.org","user-agent=curl/7.19.7 (x86_64-redhat-linux-gnu) libcurl/7.19.7 NSS/3.21 Basic ECC zlib/1.2.3 libidn/1.18 libssh2/1.4.2"
```

And then at the next
periodic interval (60 second intervals) this file will be forwarded to the main stroom proxy
server `stroomp.strmdev00.org` as shown by the _handler.ForwardRequestHandler_ events running under the _pool-10-thread-2_ thread.

```text
2017-01-01T23:19:00.304Z INFO  [Repository Reader Thread 1] handler.ProxyRepositoryReader (ProxyRepositoryReader.java:143) - run() - Cron Match at 2017-01-01T23:19:00.304Z
2017-01-01T23:19:00.586Z INFO  [pool-10-thread-2] handler.ForwardRequestHandler (ForwardRequestHandler.java:109) - handleHeader() - https://stroomp00.strmdev00.org/stroom/datafeed Sending request {ReceivedPath=stroomfp0.strmdev00.org, Feed=TEST-FEED-V1_0, Compression=ZIP}
2017-01-01T23:19:00.990Z INFO  [pool-10-thread-2] handler.ForwardRequestHandler (ForwardRequestHandler.java:89) - handleFooter() - b5722ead-714b-411b-a09f-901fb8b20389 took 403 ms to forward 1.4 kB response 200 - {ReceivedPath=stroomfp0.strmdev00.org, Feed=TEST-FEED-V1_0, GUID=b5722ead-714b-411b-a09f-901fb8b20389, Compression=ZIP}
2017-01-01T23:20:00.064Z INFO  [Repository Reader Thread 1] handler.ProxyRepositoryReader (ProxyRepositoryReader.java:143) - run() - Cron Match at 2017-01-01T23:20:00.064Z
...
```

On one of the central processing nodes, when the file is send by the Forwarding Proxy, you will see the file's arrival as per
the _datafeed.DataFeedRequestHandler$1_ event in the _ajp-apr-9009-exec-3_ thread.

```text
...
2017-01-01T23:00:00.236Z INFO  [Repository Reader Thread 1] handler.ProxyRepositoryReader (ProxyRepositoryReader.java:143) - run() - Cron Match at 2017-01-01T23:00:00.236Z
2017-01-01T23:10:00.473Z INFO  [Repository Reader Thread 1] handler.ProxyRepositoryReader (ProxyRepositoryReader.java:143) - run() - Cron Match at 2017-01-01T23:10:00.473Z
2017-01-01T23:19:00.787Z INFO  [ajp-apr-9009-exec-3] handler.LogRequestHandler (LogRequestHandler.java:37) - log() - guid=b5722ead-714b-411b-a09f-901fb8b20389,feed=TEST-FEED-V1_0,system=null,environment=null,remotehost=null,remoteaddress=null
2017-01-01T23:19:00.981Z INFO  [ajp-apr-9009-exec-3] datafeed.DataFeedRequestHandler$1 (DataFeedRequestHandler.java:104) - "doPost() - Took 196 ms to process (concurrentRequestCount=1) 200","Cache-Control=no-cache","Compression=ZIP","Feed=TEST-FEED-V1_0","GUID=b5722ead-714b-411b-a09f-901fb8b20389","ReceivedPath=stroomfp0.strmdev00.org","Transfer-Encoding=chunked","accept=text/html, image/gif, image/jpeg, *; q=.2, */*; q=.2","connection=keep-alive","content-type=application/audit","host=stroomp00.strmdev00.org","pragma=no-cache","user-agent=Java/1.8.0_111"
2017-01-01T23:20:00.771Z INFO  [Repository Reader Thread 1] handler.ProxyRepositoryReader (ProxyRepositoryReader.java:143) - run() - Cron Match at 2017-01-01T23:20:00.771Z
...
```

## Stroom Standalone Proxy Testing
### Data Post Tests
#### Simple Post tests

This test is to ensure the Stroom _Store NODB_ or _Standalone_ proxy is working.

We will send a file to our _Standalone_ proxy (`stroomsap0.strmdev00.org`) and monitor this nodes' proxy log files as well the directory the
received files are meant to be stored in.

Perform the following
- Log onto any host where you will perform the `curl` post
- Log onto the Standalone Proxy node and become the `stroomuser` and monitor the Stroom proxy service using the `Tp` bash macro. That is run

```bash
sudo -i -u stroomuser
Tp
```

- On the 'posting' node, run the command

```bash
curl -k --data-binary @/etc/group "https://stroomsap0.strmdev00.org/stroom/datafeed" -H "Feed:TEST-FEED-V1_0" -H "System:EXAMPLE_SYSTEM" -H "Environment:EXAMPLE_ENVIRONMENT"
```

In the stroom proxy log, `~/stroom-proxy/instance/logs/stroom.log`, you will see the arrival of the file via both the _handler.LogRequestHandler_ and  _datafeed.DataFeedRequestHandler$1_ events running under, in this case, the _ajp-apr-9009-exec-1_ thread.

```text
...
2017-01-02T02:10:00.325Z INFO  [Repository Reader Thread 1] handler.ProxyRepositoryReader (ProxyRepositoryReader.java:143) - run() - Cron Match at 2017-01-02T02:10:00.325Z
2017-01-02T02:11:34.501Z INFO  [ajp-apr-9009-exec-1] handler.LogRequestHandler (LogRequestHandler.java:37) - log() - guid=ebd11215-7d4c-4be6-a524-358015e2ac38,feed=TEST-FEED-V1_0,system=EXAMPLE_SYSTEM,environment=EXAMPLE_ENVIRONMENT,remotehost=192.168.2.220,remoteaddress=192.168.2.220
2017-01-02T02:11:34.528Z INFO  [ajp-apr-9009-exec-1] datafeed.DataFeedRequestHandler$1 (DataFeedRequestHandler.java:104) - "doPost() - Took 33 ms to process (concurrentRequestCount=1) 200","Environment=EXAMPLE_ENVIRONMENT","Expect=100-continue","Feed=TEST-FEED-V1_0","GUID=ebd11215-7d4c-4be6-a524-358015e2ac38","ReceivedTime=2017-01-02T02:11:34.501Z","RemoteAddress=192.168.2.220","RemoteHost=192.168.2.220","System=EXAMPLE_SYSTEM","accept=*/*","content-length=1051","content-type=application/x-www-form-urlencoded","host=stroomsap0.strmdev00.org","user-agent=curl/7.19.7 (x86_64-redhat-linux-gnu) libcurl/7.19.7 NSS/3.21 Basic ECC zlib/1.2.3 libidn/1.18 libssh2/1.4.2"
...
```

Further, if you check the proxy's storage directory, you will see the file `001.zip`. The file names number upwards from 001.
```bash
ls -l /stroomdata/stroom-working-sap0/proxy
```
shows
```text
[stroomuser@stroomsap0 ~]$ ls -l /stroomdata/stroom-working-sap0/proxy
total 4
-rw-rw-r--. 1 stroomuser stroomuser 1107 Jan  2 13:11 001.zip
[stroomuser@stroomsap0 ~]$ 
```
On viewing the contents of this file we see both a `.dat` and `.meta` file.
```text
[stroomuser@stroomsap0 ~]$ (cd /stroomdata/stroom-working-sap0/proxy; unzip 001.zip)
Archive:  001.zip
  inflating: 001.dat                 
  inflating: 001.meta                
[stroomuser@stroomsap0 ~]$
```
The `.dat` file holds the content of the file we posted - `/etc/group`.
```text
[stroomuser@stroomsap0 ~]$ (cd /stroomdata/stroom-working-sap0/proxy; head -5 001.dat)
root:x:0:
bin:x:1:bin,daemon
daemon:x:2:bin,daemon
sys:x:3:bin,adm
adm:x:4:adm,daemon
[stroomuser@stroomsap0 ~]$ 
```
The `.meta` file is generated by the proxy and holds information about the posted file
```text
[stroomuser@stroomsap0 ~]$ (cd /stroomdata/stroom-working-sap0/proxy; cat 001.meta)
content-type:application/x-www-form-urlencoded
Environment:EXAMPLE_ENVIRONMENT
Feed:TEST-FEED-V1_0
GUID:ebd11215-7d4c-4be6-a524-358015e2ac38
host:stroomsap0.strmdev00.org
ReceivedTime:2017-01-02T02:11:34.501Z
RemoteAddress:192.168.2.220
RemoteHost:192.168.2.220
StreamSize:1051
System:EXAMPLE_SYSTEM
user-agent:curl/7.19.7 (x86_64-redhat-linux-gnu) libcurl/7.19.7 NSS/3.21 Basic ECC zlib/1.2.3 libidn/1.18 libssh2/1.4.2
[stroomuser@stroomsap0 ~]$ (cd /stroomdata/stroom-working-sap0/proxy; rm 001.meta 001.dat)
[stroomuser@stroomsap0 ~]$ 
```
