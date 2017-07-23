# Stroom HOWTO - Installation of Stroom Proxy
This HOWTO describes the installation and configuration of the Stroom Proxy software.

## Assumptions
The following assumptions are used in this document.
- the user has reasonable RHEL/Centos System administration skills.
- installation is on a fully patched minimal Centos 7.3 instance.
- the Stroom database has been created and resides on the host `stroomdb0.strmdev00.org` listening on port 3307.
- the Stroom database user is `stroomuser` with a password of `Stroompassword1@`.
- the application user `stroomuser` has been created.
- the user is or has deployed the two node Stroom cluster described [here](InstallHowTo.md#storage-scenario "HOWTO Storage Scenario").
- the user has set up the Stroom processing user as described [here](InstallProcessingUserSetupHowTo.md "Processing User Setup").
- the prerequisite software has been installed.
- when a screen capture is documented, data entry is identified by the data surrounded by '<__' '__>' . This excludes enter/return presses.

## Confirm Prerequisite Software Installation
The following command will ensure the prerequisite software has been deployed

```bash
sudo yum -y install java-1.8.0-openjdk java-1.8.0-openjdk-devel policycoreutils-python unzip zip
sudo yum -y install mariadb
or
sudo yum -y install mysql-community-client
```

Note that we do __NOT__ need the database client software for a Forwarding or Standalone proxy.

## Get the Software
The following will gain the identified, in this case release `5.1-beta.3`, Stroom Application software release from github, then deploy it. You should regularly monitor the site for newer releases.

```bash
sudo -i -u stroomuser
Prx=v5.1-beta.8
wget https://github.com/gchq/stroom-proxy/releases/download/${Prx}/stroom-proxy-distribution-${Prx}.zip
unzip stroom-proxy-distribution-${Prx}.zip
```

## Configure the Software
There are three different types of Stroom Proxy
- Store

 A _store_ proxy accepts batches of events, as files. It will validate the batch with the database then store the batches as files in a configured directory.
- Store_NoDB

 A _store_nodb_ proxy accepts batches of events, as files. It has no connectivity to the database, so it assumes all batches are valid, so it stores the batches as files in a configured directory.
- Forwarding

 A _forwarding_ proxy accepts batches of events, as files. It has indirect connectivity to the database via the destination proxy, so it validates the batches then stores the batches as files in a configured directory until they are periodically forwarded to the configured destination Stroom proxy.

We will demonstrate the installation of each.

### Store Proxy Configuration
In our _Store_ Proxy description below, we will use the multi node deployment scenario. That is we are deploying the _Store_ proxy on multiple
Stroom nodes (stroomp00, stroomp01) and we have configured our storage as per the [Storage Scenario](InstallHowTo.md#storage-scenario "HOWTO Storage Scenario")
which means the directories to install the inbound batches of data are
`/stroomdata/stroom-working-p00/proxy` and `/stroomdata/stroom-working-p01/proxy` depending on the node.

To install a _Store_ proxy, we run

```bash
stroom-proxy/bin/setup.sh store
```
during which one is prompted for a number of configuration settings. Use the following
```
NODE to be the hostname (not FQDN) of your host (i.e. 'stroomp00' or 'stroomp01' depending on the node we are installing on)
PORT_PREFIX should use the default, just press return
REPO_DIR should be set to '/stroomdata/stroom-working-p00/proxy' or '/stroomdata/stroom-working-p01/proxy' depending on the node we are installing on
REPO_FORMAT can be left as the default, just press return
JDBC_CLASSNAME should use the default, just press return
JDBC_URL should be set to 'jdbc:mysql://stroomdb0.strmdev00.org:3307/stroom'
DB_USERNAME should be our processing user, 'stroomuser'
DB_PASSWORD should be the one we set when creating the stroom database, that is 'Stroompassword1@'
JAVA_OPTS can use the defaults, but ensure you have sufficient memory, either change or accept the default
```

At this point, the script will configure the proxy. There should be no errors, but review the output.
If you make a mistake in the above, just re-run the script.

**NOTE:** The selection of the `REPO_DIR` above and the setting of the `STROOM_TMP` environment variable [earlier](InstallProcessingUserSetupHowTo.md "Processing User Setup") ensure that not only inbound files are placed in the `REPO_DIR` location but the Stroom Application itself will access the same directory when it aggregates inbound data for ingest in it's proxy aggregation threads.

### Forwarding Proxy Configuration
In our _Forwarding_ Proxy description below, we will deploy on a host named `stroomfp0` and it will store the files
in `/stroomdata/stroom-working-fp0/proxy`. Remember, we are being consistent with our Storage hierarchy to make documentation and scripting
simpler. Our destination host to periodically forward the files to will be `stroomp.strmdev00.org` (the CNAME for `stroomp00.strmdev00.org`).

To install a _Forwarding_ proxy, we run

```bash
stroom-proxy/bin/setup.sh forward
```
during which one is prompted for a number of configuration settings. Use the following
```
NODE to be the hostname (not FQDN) of your host (i.e. 'stroomfp0' in our example)
PORT_PREFIX should use the default, just press return
REPO_DIR should be set to '/stroomdata/stroom-working-fp0/proxy' which we created earlier.
REPO_FORMAT can be left as the default, just press return
FORWARD_SERVER should be set to our stroom server. (i.e. 'stroomp.strmdev00.org' in our example)
JAVA_OPTS can use the defaults, but ensure you have sufficient memory, either change or accept the default
```
At this point, the script will configure the proxy. There should be no errors, but review the output.

### Store No Database Proxy Configuration
In our _Store_NoDB_ Proxy description below, we will deploy on a host named `stroomsap0` and it will store the files
in `/stroomdata/stroom-working-sap0/proxy`. Remember, we are being consistent with our Storage hierarchy to make documentation and scripting simpler.

To install a _Store_NoDB_ proxy, we run

```bash
stroom-proxy/bin/setup.sh store_nodb
```
during which one is prompted for a number of configuration settings. Use the following
```
NODE to be the hostname (not FQDN) of your host (i.e. 'stroomsap0' in our example)
PORT_PREFIX should use the default, just press return
REPO_DIR should be set to '/stroomdata/stroom-working-sap0/proxy' which we created earlier.
REPO_FORMAT can be left as the default, just press return
JAVA_OPTS can use the defaults, but ensure you have sufficient memory, either change or accept the default
```

At this point, the script will configure the proxy. There should be no errors, but review the output.

## Apache/Mod_JK change
For all proxy deployments,
if we are using Apache's mod_jk then we need to ensure the proxy's AJP connector specifies a 64K packetSize. View the file `stroom-proxy/instance/conf/server.xml` to ensure the Connector element for the AJP protocol has a packetSize attribute of `65536`. For example,
```bash
grep AJP stroom-proxy/instance/conf/server.xml
```
shows
```
<Connector port="9009" protocol="AJP/1.3" connectionTimeout="20000" redirectPort="8443" maxThreads="200" packetSize="65536" />
```
This check is required for earlier releases of the Stroom Proxy. Releases since `v5.1-beta.4` have set the AJP packetSize.

## Start the Proxy Service
We can now manually start our proxy service. Do so as the `stroomuser` with the command
```bash
stroom-proxy/bin/start.sh
```
Now monitor the directory `stroom-proxy/instance/logs` for any errors. Initially you will see the log
files `localhost_access_log.YYYY-MM-DD.txt` and `catalina.out`. Check them for errors and correct (or pose a question to this arena).
The context path and unknown version warnings in `catalina.out` can be ignored.

Eventually (about 60 seconds) the log file `stroom-proxy/instance/logs/stroom.log` will appear. Again check it for errors.
The proxy will have completely started when you see the messages
```
INFO  [localhost-startStop-1] spring.StroomBeanLifeCycleReloadableContextBeanProcessor (StroomBeanLifeCycleReloadableContextBeanProcessor.java:109) - ** proxyContext 0 START COMPLETE **
```
and
```
INFO  [localhost-startStop-1] spring.StroomBeanLifeCycleReloadableContextBeanProcessor (StroomBeanLifeCycleReloadableContextBeanProcessor.java:109) - ** webContext 0 START COMPLETE **
```

If you leave it for a while you will eventually see cyclic (10 minute cycle) messages of the form
```
INFO  [Repository Reader Thread 1] repo.ProxyRepositoryReader (ProxyRepositoryReader.java:170) - run() - Cron Match at YYYY-MM-DD ...
```

If a proxy takes too long to start, you should read the section on [Entropy Issues](InstallHowTo.md#entropy-issues-in-virtual-environments "Entropy Issues in Virtual environments").

## Proxy Repository Format
A Stroom Proxy stores inbound files in a hierarchical file system whose root is supplied during the proxy setup (`REPO_DIR`) and
as files arrive they are given a _repository id_ that is a one-up number starting at one (1). The files are stored in a specific _repository format_.
The default template is `${pathId}/${id}` and this pattern will produce the following output files under `REPO_DIR` for the given repository id

| Repository Id | FilePath |
| ------------: | -----------: |
| 1 | 000.zip |
| 100 | 100.zip |
| 1000 | 001/001000.zip |
| 10000 | 010/010000.zip |
| 100000 | 100/100000.zip |

Since version v5.1-beta.4, this template can be specified during proxy setup via the entry to the `Stroom Proxy Repository Format` prompt
```
...
@@REPO_FORMAT@@ : Stroom Proxy Repository Format [${pathId}/${id}] > 
...
```

The template uses replacement variables to form the file path. As indicated above, the default template is `${pathId}/${id}` where `${pathId}` is
the automatically generated directory for a given _repository id_ and `${id}` is the _repository id_.

Other replacement variables can be used to in the template including http header meta data parameters (e.g. '${feed}') and time based
parameters (e.g. '${year}'). Replacement variables that cannot be resolved will be output as '_'. You must ensure
that all templates include the '${id}' replacement variable at the start of the file name, failure to do this will result in an invalid repository.

Available time based parameters are based on the file's time of processing and are zero filled (excluding `ms`).

| Parameter | Description |
| --------- | :---------- |
| year | four digit year |
| month | two digit month |
| day | two digit day |
| hour | two digit hour |
| minute | two digit minute |
| second | two digit second |
| millis | three digit milliseconds value |
| ms | milliseconds since Epoch value |

### Proxy Repository Template Examples
For each of the following templates applied to a Store NoDB Proxy, the resultant proxy directory tree is shown after three posts were sent
to the test feed `TEST-FEED-V1_0` and two posts to the test feed `FEED-NOVALUE-V9_0`

#### Example A - The default - `${pathId}/${id}`
```bash
[stroomuser@stroomsap0 ~]$ find /stroomdata/stroom-working-sap0/proxy/
/stroomdata/stroom-working-sap0/proxy/
/stroomdata/stroom-working-sap0/proxy/001.zip
/stroomdata/stroom-working-sap0/proxy/002.zip
/stroomdata/stroom-working-sap0/proxy/003.zip
/stroomdata/stroom-working-sap0/proxy/004.zip
/stroomdata/stroom-working-sap0/proxy/005.zip
[stroomuser@stroomsap0 ~]$ 
```

#### Example B - A feed orientated structure - `${feed}/${year}/${month}/${day}/${pathId}/${id}`
```bash
[stroomuser@stroomsap0 ~]$ find /stroomdata/stroom-working-sap0/proxy/
/stroomdata/stroom-working-sap0/proxy/
/stroomdata/stroom-working-sap0/proxy/TEST-FEED-V1_0
/stroomdata/stroom-working-sap0/proxy/TEST-FEED-V1_0/2017
/stroomdata/stroom-working-sap0/proxy/TEST-FEED-V1_0/2017/07
/stroomdata/stroom-working-sap0/proxy/TEST-FEED-V1_0/2017/07/23
/stroomdata/stroom-working-sap0/proxy/TEST-FEED-V1_0/2017/07/23/001.zip
/stroomdata/stroom-working-sap0/proxy/TEST-FEED-V1_0/2017/07/23/002.zip
/stroomdata/stroom-working-sap0/proxy/TEST-FEED-V1_0/2017/07/23/003.zip
/stroomdata/stroom-working-sap0/proxy/FEED-NOVALUE-V9_0
/stroomdata/stroom-working-sap0/proxy/FEED-NOVALUE-V9_0/2017
/stroomdata/stroom-working-sap0/proxy/FEED-NOVALUE-V9_0/2017/07
/stroomdata/stroom-working-sap0/proxy/FEED-NOVALUE-V9_0/2017/07/23
/stroomdata/stroom-working-sap0/proxy/FEED-NOVALUE-V9_0/2017/07/23/004.zip
/stroomdata/stroom-working-sap0/proxy/FEED-NOVALUE-V9_0/2017/07/23/005.zip
[stroomuser@stroomsap0 ~]$ 
```

#### Example C - A date orientated structure - `${year}/${month}/${day}/${pathId}/${id}`
```bash
[stroomuser@stroomsap0 ~]$ find /stroomdata/stroom-working-sap0/proxy/
/stroomdata/stroom-working-sap0/proxy/
/stroomdata/stroom-working-sap0/proxy/2017
/stroomdata/stroom-working-sap0/proxy/2017/07
/stroomdata/stroom-working-sap0/proxy/2017/07/23
/stroomdata/stroom-working-sap0/proxy/2017/07/23/001.zip
/stroomdata/stroom-working-sap0/proxy/2017/07/23/002.zip
/stroomdata/stroom-working-sap0/proxy/2017/07/23/003.zip
/stroomdata/stroom-working-sap0/proxy/2017/07/23/004.zip
/stroomdata/stroom-working-sap0/proxy/2017/07/23/005.zip
[stroomuser@stroomsap0 ~]$ 
```

#### Example D - A feed orientated structure, but with a bad parameter - `${feed}/${badparam}/${day}/${pathId}/${id}`
```bash
[stroomuser@stroomsap0 ~]$ find /stroomdata/stroom-working-sap0/proxy/
/stroomdata/stroom-working-sap0/proxy/
/stroomdata/stroom-working-sap0/proxy/TEST-FEED-V1_0
/stroomdata/stroom-working-sap0/proxy/TEST-FEED-V1_0/_
/stroomdata/stroom-working-sap0/proxy/TEST-FEED-V1_0/_/23
/stroomdata/stroom-working-sap0/proxy/TEST-FEED-V1_0/_/23/001.zip
/stroomdata/stroom-working-sap0/proxy/TEST-FEED-V1_0/_/23/002.zip
/stroomdata/stroom-working-sap0/proxy/TEST-FEED-V1_0/_/23/003.zip
/stroomdata/stroom-working-sap0/proxy/FEED-NOVALUE-V9_0
/stroomdata/stroom-working-sap0/proxy/FEED-NOVALUE-V9_0/_
/stroomdata/stroom-working-sap0/proxy/FEED-NOVALUE-V9_0/_/23
/stroomdata/stroom-working-sap0/proxy/FEED-NOVALUE-V9_0/_/23/004.zip
/stroomdata/stroom-working-sap0/proxy/FEED-NOVALUE-V9_0/_/23/005.zip
[stroomuser@stroomsap0 ~]$ 
```
and one would also see a warning for each post in the proxy's log file of the form
```
WARN  [ajp-apr-9009-exec-4] repo.StroomFileNameUtil (StroomFileNameUtil.java:133) - Unused variables found: [badparam]
```
