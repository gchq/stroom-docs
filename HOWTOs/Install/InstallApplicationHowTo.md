# Stroom HOWTO - Installation of Stroom Application
This HOWTO describes the installation and initial configuration of the Stroom Application.

## Assumptions
- the user has reasonable RHEL/Centos System administration skills
- installation is on a fully patched minimal Centos 7.3 instance.
- the Stroom database has been created and resides on the host `stroomdb0.strmdev00.org`
- the application user `stroomuser` has been created
- the user is or has deployed the two node Stroom cluster described [here](InstallHowTo.md#storage-scenario "HOWTO Storage Scenario")
- the user has set up the Stroom processing user as described [here](InstallProcessingUserSetupHowTo.md "Processing User Setup")
- the prerequisite software has been installed
- when a screen capture is documented, data entry is identified by the data surrounded by '<__' '__>' . This excludes enter/return presses.

## Confirm Prerequisite Software Installation
The following command will ensure the prerequisite software has been deployed

```bash
sudo yum -y install java-1.8.0-openjdk java-1.8.0-openjdk-devel policycoreutils-python unzip zip mariadb
```

## Test Database connectivity
We need to test access to the Stroom database server - `stroomdb0.strmdev00.org`. We do this using the client `mysql` utility. We note that we
must enter the _stroomuser_ user's password set up in the creation of the database earlier (`stroompassword1`).

Our test connects to the database and sets the default database to be the `stroom` database.
```
[root@stroomp00 tmp]# mysql --user=stroomuser --host=stroomdb0.strmdev00.org -p
Enter password: <__ stroompassword1 __>
Welcome to the MariaDB monitor.  Commands end with ; or \g.
Your MariaDB connection id is 2
Server version: 5.5.52-MariaDB MariaDB Server

Copyright (c) 2000, 2016, Oracle, MariaDB Corporation Ab and others.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

MariaDB [(none)]> use stroom;
Database changed
MariaDB [stroom]> exit
Bye
[root@stroomp00 tmp]# 
```
If there are any errors, correct them.

## Get the Software
The following will gain the identified, in this case release `5.0-beta.9`, Stroom Application software release from github, then deploy it. You should regularly monitor the site for newer releases.

```bash
sudo -i -u stroomuser
App=5.0-beta.9
wget https://github.com/gchq/stroom/releases/download/v${App}/stroom-app-distribution-${App}-bin.zip
unzip stroom-app-distribution-${App}-bin.zip
find stroom-app -name '*.sh' -exec chmod 755 {} \+;
chmod 750 stroom-app
```

## Configure the Software
We install the application via

```bash
stroom-app/bin/setup.sh
```
during which one is prompted for a number of configuration settings. Use the following
```
TEMP_DIR should be set to '/stroomdata/stroom-working-p00' or '/stroomdata/stroom-working-p01' etc depending on the node we are installing on
NODE to be the hostname (not FQDN) of your host (i.e. 'stroomp00' or 'stroomp01' in our multi node scenario)
RACK can be ignored, just press return
PORT_PREFIX should use the default, just press return
JDBC_CLASSNAME should use the default, just press return
JDBC_URL to 'jdbc:mysql://stroomdb0.strmdev00.org/stroom?useUnicode=yes&characterEncoding=UTF-8'
DB_USERNAME should be our processing user, 'stroomuser'
DB_PASSWORD should be the one we set when creating the stroom database, that is 'stroompassword1'
JPA_DIALECT should use the default, just press return
JAVA_OPTS can use the defaults, but ensure you have sufficient memory, either change or accept the default
STATS_ENGINES should use the default, just press return
CONTENT_PACK_IMPORT_ENABLED should use the default, just press return
CREATE_DEFAULT_VOLUME_ON_START should use the default, just press return
```

At this point, the script will configure the application. There should be no errors, but review the output.
If you made an error then just re-run the script.

You will note that __TEMP_DIR__ is the same directory we used for our __STROOM_TMP__ environment variable when we set up the processing user scripts.
Note that if you are deploying a single node environment, where the database is also running on your Stroom node, then the __JDBC_URL__ setting can be the default.

Given we are using mod_jk then we need to modify the application's AJP connector to specify a larger packetSize.
Edit the file `stroom-app/instance/conf/server.xml` to change
```
<Connector port="8009" protocol="AJP/1.3" connectionTimeout="20000" redirectPort="8443" maxThreads="200" />
```
to
```
<Connector port="8009" protocol="AJP/1.3" connectionTimeout="20000" redirectPort="8443" maxThreads="200" packetSize="65536" />
```

## Start the Application service
Now we start the application. In the case of multi node Stroom deployment, we start the Stroom application on the first node in the cluster,
then __wait__ until it has initialised the database commenced it's Lifecycle task. You will need to monitor the log file to see it's
completed initialisation.

So as the `stroomuser` start the application with the command
```bash
stroom-app/bin/start.sh
```
Now monitor `stroom-app/instance/logs` for any errors. Initially you will see the log files `localhost_access_log.YYYY-MM-DD.txt`
and `catalina.out`. Check them for errors and correct (or post a question). The log4j warnings in `catalina.out` can be ignored.
Eventually the log file `stroom-app/instance/logs/stroom.log` will appear. Again check it for errors and then wait for the application to
be initialised. That is, wait for the Lifecycle service thread to start. This is indicated by the message
```
INFO  [Thread-11] lifecycle.LifecycleServiceImpl (LifecycleServiceImpl.java:166) - Started Stroom Lifecycle service
```
The directory `stroom-proxy/instance/logs/events` will also appear with an empty file with
the nomenclature `events_YYYY-MM-DDThh:mm:ss.msecZ`. This is the directory for storing Stroom's application event logs. We will return to this
directory and it's content in a later HOWTO.

If you have a multi node configuration, then once the database has initialised, start the application service on all other nodes. Again with
```bash
stroom-app/bin/start.sh
```
and then monitor the files in its `stroom-app/instance/logs` for any errors. Note that in multi node configurations,
you will see server.UpdateClusterStateTaskHandler messages in the log file of the form
```
WARN  [Stroom P2 #9 - GenericServerTask] server.UpdateClusterStateTaskHandler (UpdateClusterStateTaskHandler.java:150) - discover() - unable to contact stroomp00 - No cluster call URL has been set for node: stroomp00
```
This is ok as we will establish the cluster URL's later.

### Multi Node Firewall Provision
In the case of a multi node Stroom deployment, you will need to open certain ports to allow Tomcat to communicate to all nodes participating
in the cluster. Execute the following on all nodes. Note you will need to drop out of the `stroomuser` shell prior to execution.
```bash
exit; # To drop out of the stroomuser shell

sudo firewall-cmd --zone=public --add-port=8080/tcp --permanent
sudo firewall-cmd --zone=public --add-port=9080/tcp --permanent
sudo firewall-cmd --zone=public --add-port=8009/tcp --permanent
sudo firewall-cmd --zone=public --add-port=9009/tcp --permanent
sudo firewall-cmd --reload
sudo firewall-cmd --zone=public --list-all
```

In a production environment you would improve the above firewall settings - to perhaps limit the communication to just the Stroom processing nodes.
