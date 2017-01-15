# Stroom HOWTO - Adding a new processing node to a MultiNode Cluster
The following is a HOWTO add an additional processing node to an existing Stroom cluster based on Centos 7.3/Mariadb/Httpd/mod_jk. In this HOWTO we are adding a third processing node

The HOWTO results in a third processing node added to the cluster, but it will not be operational. To make the deployment operational, additional configuration is required thru the Stroom User Interface. Details on this can be found in the [Stroom User Interface - Initial Configuration](StroomHowTo-1.60-a.md "Initial Configuration via User Interface").

Last Update: Burn Alting, 13 Jan 2017
- Initial release (1.50-a)

Assumptions:
 - the user has reasonable RHEL/Centos System administration skills
 - the installation user has the ability to sudo
 - installation on Centos 7.3 minimal systems (fully patched)
 - database nodename is 'stroomdb0.strmdev00.org'
 - the exiting processing node names are 'stroomp00.strmdev00.org' and 'stroomp01.strmdev00.org' and this new node is 'stroomp02.strmdev00.org'
 - the first node, 'stroomp00.strmdev00.org' also has a CNAME 'stroomp.strmdev00.org'
 - stroom runs as user 'stroomuser'
 - data will reside in '/stroomdata' which is a link (in this HOWTO) to /home/stroomdata
 - when a screen capture is documented, data entry is identified by the data surrounded by '<__' '__>' . This excludes enter/return presses.
 - better security of password choices, networking, firewalls, data stores, etc can and should be achieved in various ways, but these HOWTOs are just a quick means of getting a working system, so only limited security is applied
 - better configuration of the database (eg more memory. redundancy) should be considered in production environments

## Modify the database to allow access from this new node

Connect to the Stroom database as the `root` user using the root password already set, via the command
```bash
sudo mysql --user=root -p
```

and at the `MariaDB [(none)]> ` prompt enter

```bash
grant all privileges on stroom.* to stroomuser@stroomp02.strmdev00.org identified by 'stroompassword1';
quit;
```

## Create Base Operating System and install required packages for the new Stroom Processing system
First, create a Centos 7.3 minimal instance, then patch via a yum -y update. Should the kernel be updated when patching, then don't forget to reboot.

### Install required software
Once you have an up to date Centos 7.3 install the following packages. Note that we do a `yum -y update` after the initial package installation as the system may need to update the epel repository files. Finally we install tomcat-native separately as it's available via epel which must be installed first.

```bash
sudo yum -y install java-1.8.0-openjdk java-1.8.0-openjdk-devel unzip zip mod_ssl httpd apr apr-util apr-devel gcc httpd-devel epel-release policycoreutils-python
sudo yum -y update
sudo yum -y install tomcat-native
```

Next, acquire a recent Apache mod_jk Tomcat connector release and install it. Note we do this as root.

```bash
sudo bash
cd /tmp
V=1.2.42
wget https://www.apache.org/dist/tomcat/tomcat-connectors/jk/tomcat-connectors-${V}-src.tar.gz
tar xf tomcat-connectors-${V}-src.tar.gz
cd tomcat-connectors-*-src/native
./configure --with-apxs=/bin/apxs
make && make install
cd /tmp
rm -rf tomcat-connectors-*-src
```

### Set up Storage Hierarchy

We first create the processing user, as per
```bash
sudo useradd stroomuser
```

We now create the storage hierarchy. We note the existing hierarchy is
- Node: `stroomp00.strmdev00.org`
 - `/stroomdata/stroom-data-p00`	- location to store Stroom application data files (events, etc.) for this node
 - `/stroomdata/stroom-index-p00`	- location to store Stroom application index files
 - `/stroomdata/stroom-working-p00`	- location to store Stroom application working files (e.g. tmp, output, etc.) for this node
 - `/stroomdata/stroom-working-p00/proxy`	- location for Stroom proxy to store inbound data files
- Node: `stroomp01.strmdev00.org`
 - `/stroomdata/stroom-data-p01`	- location to store Stroom application data files (events, etc.) for this node
 - `/stroomdata/stroom-index-p01`	- location to store Stroom application index files
 - `/stroomdata/stroom-working-p01`	- location to store Stroom application working files (e.g. tmp, output, etc.) for this node
 - `/stroomdata/stroom-working-p01/proxy`	- location for Stroom proxy to store inbound data files

so we add

- Node: `stroomp02.strmdev00.org`
 - `/stroomdata/stroom-data-p02`	- location to store Stroom application data files (events, etc.) for this node
 - `/stroomdata/stroom-index-p02`	- location to store Stroom application index files
 - `/stroomdata/stroom-working-p02`	- location to store Stroom application working files (e.g. tmp, output, etc.) for this node
 - `/stroomdata/stroom-working-p02/proxy`	- location for Stroom proxy to store inbound data files


Now a Stroom processing cluster needs to access all nodes data directory structures - `/stroomdata/stroom-data-pNN`. As before, we achieve this access via NFS. Now we note that already, node `stroomp00.strmdev00.org` mounts `stroomp01.strmdev00.org:/stroomdata/stroom-data-p01` and node `stroomp01.strmdev00.org` mounts `stroomp00.strmdev00.org:/stroomdata/stroom-data-p00`. So we now need to have `stroomp00.strmdev00.org` and `stroomp01.strmdev00.org` mount our new node's data directory and the new node, `stroomp02.strmdev00.org`, will need to mount the other two nodes data directories.

So the relevant commands to create this on each node are

- Node: `stroomp00.strmdev00.org`
```bash
sudo mkdir -p /stroomdata/stroom-data-p02
sudo chmod 750 /stroomdata/stroom-data-p02
sudo chown stroomuser:stroomuser /stroomdata/stroom-data-p02
```

- Node: `stroomp01.strmdev00.org`
```bash
sudo mkdir -p /stroomdata/stroom-data-p02
sudo chmod 750 /stroomdata/stroom-data-p02
sudo chown stroomuser:stroomuser /stroomdata/stroom-data-p02
```

- Node: `stroomp02.strmdev00.org`
```bash
sudo mkdir -p /home/stroomdata
sudo ln -s /home/stroomdata /stroomdata
sudo mkdir -p /stroomdata/stroom-data-p02 /stroomdata/stroom-index-p02 /stroomdata/stroom-working-p02 /stroomdata/stroom-working-p02/proxy
sudo mkdir -p /stroomdata/stroom-data-p00
sudo mkdir -p /stroomdata/stroom-data-p01
sudo chown -R stroomuser:stroomuser /home/stroomdata
sudo chmod -R 750 /home/stroomdata
```

#### Install and Enable NFS software
We install NFS on the new node, via
```bash
sudo yum -y install nfs-utils
```
and enable the relevant services, via
```base
sudo systemctl enable rpcbind
sudo systemctl enable nfs-server
sudo systemctl enable nfs-lock
sudo systemctl enable nfs-idmap
sudo systemctl start rpcbind
sudo systemctl start nfs-server
sudo systemctl start nfs-lock
sudo systemctl start nfs-idmap
```

#### Configure NFS exports
We now export the node's /home/stroomdata directory by configuring /etc/exports. For simplicity sake, we will allow all nodes with the hostname nomenclature of stroomp*.strmdev00.org to mount the `/home/stroomdata` directory. This means the same configuration applies to all nodes.
```
# Share Stroom data directory
/home/stroomdata	stroomp*.strmdev00.org(rw,sync,no_root_squash)
```

This can be achieved with the following on for our new node
```bash
sudo su -c "printf '# Share Stroom data directory\n' >> /etc/exports"
sudo su -c "printf '/home/stroomdata\tstroomp*.strmdev00.org(rw,sync,no_root_squash)\n' >> /etc/exports"
```

On both nodes start the NFS service via
```bash
sudo systemctl restart nfs-server
```
then enable firewall access via
```bash
sudo firewall-cmd --zone=public --add-service=nfs --permanent
sudo firewall-cmd --reload
sudo firewall-cmd --zone=public --list-all
```

At this you should do test mounts on each node.
- Node: `stroomp00.strmdev00.org`
```bash
sudo mount -t nfs4 stroomp02.strmdev00.org:/home/stroomdata/stroom-data-p02 /home/stroomdata/stroom-data-p02
```

- Node: `stroomp01.strmdev00.org`
```bash
sudo mount -t nfs4 stroomp02.strmdev00.org:/home/stroomdata/stroom-data-p02 /home/stroomdata/stroom-data-p02
```

- Node: `stroomp02.strmdev00.org`
```bash
sudo mount -t nfs4 stroomp00.strmdev00.org:/home/stroomdata/stroom-data-p00 /home/stroomdata/stroom-data-p00
sudo mount -t nfs4 stroomp01.strmdev00.org:/home/stroomdata/stroom-data-p01 /home/stroomdata/stroom-data-p01
```

If you are concerned you can't see the mount with a `df` try a `df --type=nfs4 -a` or a `sudo df`. Irrespective, once the mounting works, make the mounts permanent by adding the following to each node's /etc/fstab file.

- Node: `stroomp00.strmdev00.org`
```
stroomp02.strmdev00.org:/home/stroomdata/stroom-data-p02 /home/stroomdata/stroom-data-p02 nfs4 soft,bg
```
achieved with
```bash
sudo su -c "printf 'stroomp02.strmdev00.org:/home/stroomdata/stroom-data-p02 /home/stroomdata/stroom-data-p02 nfs4 soft,bg\n' >> /etc/fstab"
```

- Node: `stroomp01.strmdev00.org`
```
stroomp02.strmdev00.org:/home/stroomdata/stroom-data-p02 /home/stroomdata/stroom-data-p02 nfs4 soft,bg
```
achieved with
```bash
sudo su -c "printf 'stroomp02.strmdev00.org:/home/stroomdata/stroom-data-p02 /home/stroomdata/stroom-data-p02 nfs4 soft,bg\n' >> /etc/fstab"
```

- Node: `stroomp02.strmdev00.org`
```
stroomp00.strmdev00.org:/home/stroomdata/stroom-data-p00 /home/stroomdata/stroom-data-p00 nfs4 soft,bg
stroomp01.strmdev00.org:/home/stroomdata/stroom-data-p01 /home/stroomdata/stroom-data-p01 nfs4 soft,bg
```
achieved with
```bash
sudo su -c "printf 'stroomp00.strmdev00.org:/home/stroomdata/stroom-data-p00 /home/stroomdata/stroom-data-p00 nfs4 soft,bg\n' >> /etc/fstab"
sudo su -c "printf 'stroomp01.strmdev00.org:/home/stroomdata/stroom-data-p01 /home/stroomdata/stroom-data-p01 nfs4 soft,bg\n' >> /etc/fstab"
```

At this point reboot all processing nodes to ensure the directories mount automatically. You may need to give the nodes a minute to do this.

### Install the database client software and test access to the database on the new node

We install the database client software as per

```bash
sudo yum -y install mariadb
```

We then test access to the Stroom database server - `stroomdb0.strmdev00.org`. We do this using the client `mysql` command. We note that we must enter the _stroomuser_ user password set up in the creation of the database earlier.

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

### Install the Stroom Applications

Now become the stroomuser and acquire the current Stroom Application and Proxy releases from github.

```bash
sudo -i -u stroomuser
App=5.0-beta.8
Prx=5.1-beta.3
wget https://github.com/gchq/stroom/releases/download/v${App}/stroom-app-distribution-${App}-bin.zip
wget https://github.com/gchq/stroom-proxy/releases/download/v${Prx}/stroom-proxy-distribution-${Prx}-bin.zip
```

Now we set up the processing user's environment. This is made up of two environment variable files (one for the Stroom services and the other for the systemd Stroom service). The JAVA_HOME and PATH variables are to support Java running the Tomcat instances. The STROOM_TMP variable is set a working area which capability within Stroom can use via the ${stroom_tmp} context variable.

- Node: `stroomp02.strmdev00.org`
```bash
F=~/env.sh
printf '# Environment variables for Stroom services\n' > ${F}
printf 'export JAVA_HOME=/usr/lib/jvm/java-1.8.0\n' >> ${F}
printf 'export PATH=${JAVA_HOME}/bin:${PATH}\n' >> ${F}
printf 'export STROOM_TMP=/stroomdata/stroom-working-p02\n' >> ${F}
chmod 640 ${F}

F=~/env_service.sh
printf '# Environment variables for Stroom services, executed out of systemd service\n' > ${F}
printf 'JAVA_HOME=/usr/lib/jvm/java-1.8.0\n' >> ${F}
printf 'PATH=${JAVA_HOME}/bin:${PATH}\n' >> ${F}
printf 'STROOM_TMP=/stroomdata/stroom-working-p02\n' >> ${F}
chmod 640 ${F}
```

And we integrate the environment into our bash instantiation script as well as setting up some useful bash functions. This is the same for all nodes.

```bash
F=~/.bashrc
printf '. ~/env.sh\n\n' >> ${F}
printf '# Simple functions to support Stroom\n' >> ${F}
printf '# T - continually monitor (tail) the Stroom application log\n'  >> ${F}
printf '# Tp - continually monitor (tail) the Stroom proxy log\n'  >> ${F}
printf 'function T {\n  tail --follow=name ~/stroom-app/instance/logs/stroom.log\n}\n' >> ${F}
printf 'function Tp {\n  tail --follow=name ~/stroom-proxy/instance/logs/stroom.log\n}\n' >> ${F}
```

And test it has set up correctly

```bash
. ./.bashrc
which java
```
which should return `/usr/lib/jvm/java-1.8.0/bin/java`

At this point, we will install the application and proxy. So first extract the code

```bash
unzip stroom-app-distribution-${App}-bin.zip
unzip stroom-proxy-distribution-${Prx}-bin.zip
chmod 750 stroom-app stroom-proxy
```

We install the application via

```bash
stroom-app/bin/setup.sh
```
during which one is prompted for a number of configuration settings. Use the following
```
TEMP_DIR should be set to '/stroomdata/stroom-working-p02'
NODE to be the hostname (not FQDN) of your host (i.e. 'stroomp02' in our example)
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
CREATE_DEFAULT_VOLUME_ON_START should be set to 'false' as we will not use default volumes.
```

At this point, the script will configure the application. There should be no errors, but review the output.

Given we are using mod_jk then we need to modify the application's AJP connector to specify a larger packetSize.
Edit the file `stroom-app/instance/conf/server.xml` to change
```
<Connector port="8009" protocol="AJP/1.3" connectionTimeout="20000" redirectPort="8443" maxThreads="200" />
```
to
```
<Connector port="8009" protocol="AJP/1.3" connectionTimeout="20000" redirectPort="8443" maxThreads="200" packetSize="65536" />
```

Now, we install the proxy. The script must be given _one_ of three arguments, indicating the proxy type
- store
- store_nodb
- forward

In our instance, since we are installing a Stroom processing instance, we need to install the `store` proxy. This means that as batches of events are sent to our Stroom instance, the `store` proxy will validate the 'feed' with the database then store the batches as files in the given directory. Thus to install we run

```bash
stroom-proxy/bin/setup.sh store
```
during which one is prompted for a number of configuration settings. Use the following
```
NODE to be the hostname (not FQDN) of your host (i.e. 'stroomp02')
PORT_PREFIX should use the default, just press return
REPO_DIR should be set to '/stroomdata/stroom-working-p02/proxy'
JDBC_CLASSNAME should use the default, just press return
JDBC_URL should be set to 'jdbc:mysql://stroomdb0.strmdev00.org/stroom'
DB_USERNAME should be our processing user, 'stroomuser'
DB_PASSWORD should be the one we set when creating the stroom database, that is 'stroompassword1'
JAVA_OPTS can use the defaults, but ensure you have sufficient memory, either change or accept the default
```

At this point, the script will configure the proxy. There should be no errors, but review the output.

**NOTE:** The selection of the `REPO_DIR` above and the setting of the `STROOM_TMP` environment variable earlier ensure that not only inbound files are placed in the `REPO_DIR` location but the Stroom Application itself will access the same directory when it aggregates inbound data for ingest in it's proxy aggregation threads.

Given we are using mod_jk then we need to modify the proxy's AJP connector to specify a larger packetSize. Edit the file `stroom-proxy/instance/conf/server.xml` to change
```
<Connector port="9009" protocol="AJP/1.3"
    redirectPort="8443" />
```
to
```
<Connector port="9009" protocol="AJP/1.3"
    redirectPort="8443" packetSize="65536" />
```

We can now manually start the proxy. Do so with
```bash
stroom-proxy/bin/start.sh
```
Now monitor the directory `stroom-proxy/instance/logs` for any errors. Initially you will see the log files `localhost_access_log.YYYY-MM-DD.txt` and `catalina.out`. Check them for errors and correct (or pose a question to this arena). The context path and unknown version warnings in `catalina.out` can be ignored.
Eventually (about 60 seconds) the log file `stroom-proxy/instance/logs/stroom.log` will appear. Again check it for errors. If you leave it for a while you
will eventually see cyclic (10 minute cycle) messages of the form
```
INFO  [Repository Reader Thread 1] handler.ProxyRepositoryReader (ProxyRepositoryReader.java:143) - run() - Cron Match at YYYY-MM-DD ...
```

We also start the application via
```bash
stroom-app/bin/start.sh
```
Now monitor `stroom-app/instance/logs` for any errors. Initially you will see the log files `localhost_access_log.YYYY-MM-DD.txt` and `catalina.out`. Check them for errors and correct (or post a question). The log4j warnings in `catalina.out` can be ignored.
Eventually the log file `stroom-app/instance/logs/stroom.log` will appear. Again check it for errors and then wait for the application to be initialised. That is, wait for the Lifecycle service thread to start
```
INFO  [Thread-11] lifecycle.LifecycleServiceImpl (LifecycleServiceImpl.java:166) - Started Stroom Lifecycle service
```
The directory `stroom-proxy/instance/logs/events` will also appear with an empty file with the nomenclature `events_YYYY-MM-DDThh:mm:ss.msecZ`. This is the directory for storing Stroom's application event logs. We will return to this directory and it's content in a later HOWTO.

Note you will see server.UpdateClusterStateTaskHandler messages of the form
```
WARN  [Stroom P2 #9 - GenericServerTask] server.UpdateClusterStateTaskHandler (UpdateClusterStateTaskHandler.java:150) - discover() - unable to contact stroomp02 - No cluster call URL has been set for node: stroomp02
```
in the first two nodes application log files `stroom-app/instance/logs/stroom.log`. This is ok as we will establish the cluster URL for this node later.

Next we need to open some firewall ports to allow Tomcat to communicate. Execute the following on all nodes. Note you will need to drop out of the `stroomuser` shell prior to execution.
```bash
exit; # To drop out of the stroomuser shell
sudo firewall-cmd --zone=public --add-port=8080/tcp --permanent
sudo firewall-cmd --zone=public --add-port=9080/tcp --permanent
sudo firewall-cmd --zone=public --add-port=8009/tcp --permanent
sudo firewall-cmd --zone=public --add-port=9009/tcp --permanent
sudo firewall-cmd --reload
sudo firewall-cmd --zone=public --list-all
```

## Integration of Services with Apache's Httpd service

### Gain certificates from existing node in cluster
As we are a cluster, we use the same certificate for all node within it. Thus we need to gain the certificate package from an existing node.

So, on `stroomp00.strmdev00.org`, we replicate the directory ~stroomuser/stroom-jks to our new node. That is, tar it up, copy the tar file to stroomp02 and untar it. We can make use of the other node's mounted file system.
```bash
cd ~stroomuser
tar cf stroom-jks.tar stroom-jks
mv stroom-jks.tar /home/stroomdata/stroom-data-p02
```
then on our new node (`stroomp02.strmdev00.org`) we extract the data.
```bash
cd ~stroomuser
tar xf /home/stroomdata/stroom-data-p02/stroom-jks.tar && rm -f /home/stroomdata/stroom-data-p02/stroom-jks.tar
```

Now ensure protection, ownership and SELinux context for these files by running
```bash
chmod 700 ~stroomuser/stroom-jks/private ~stroomuser/stroom-jks
chown -R stroomuser:stroomuser ~stroomuser/stroom-jks
chcon -R --reference /etc/pki ~stroomuser/stroom-jks
```

### Configure Apache httpd
Now become root and configure the httpd service.

First, create the index file (/var/www/html/index.html) so browsing to the root of our node will present the Stroom UI

```bash
F=/var/www/html/index.html
printf '<html>\n' > ${F}
printf '<head>\n' >> ${F}
printf '  <meta http-equiv="Refresh" content="0; URL=stroom"/>\n' >> ${F}
printf '</head>\n' >> ${F}
printf '</html>\n' >> ${F}
chmod 644 ${F}
```

Next, the mod_jk configuration file (/etc/httpd/conf.d/mod_jk.conf)

```bash
F=/etc/httpd/conf.d/mod_jk.conf
printf 'LoadModule jk_module modules/mod_jk.so\n' > ${F}
printf 'JkWorkersFile conf/workers.properties\n' >> ${F}
printf 'JkLogFile logs/mod_jk.log\n' >> ${F}
printf 'JkLogLevel info\n' >> ${F}
printf 'JkLogStampFormat  "[%%a %%b %%d %%H:%%M:%%S %%Y]"\n' >> ${F}
printf 'JkOptions +ForwardKeySize +ForwardURICompat +ForwardSSLCertChain -ForwardDirectories\n' >> ${F}
printf 'JkRequestLogFormat "%%w %%V %%T"\n' >> ${F}
printf 'JkMount /stroom* local\n' >> ${F}
printf 'JkMount /stroom/remoting/cluster* local\n' >> ${F}
printf 'JkMount /stroom/datafeed* loadbalancer_proxy\n' >> ${F}
printf 'JkMount /stroom/remoting* loadbalancer_proxy\n' >> ${F}
printf 'JkMount /stroom/datafeed/direct* loadbalancer\n' >> ${F}
printf '# Note: Replaced JkShmFile logs/jk.shm due to SELinux issues. Refer to\n' >> ${F}
printf '# https://bugzilla.redhat.com/bugzilla/show_bug.cgi?id=225452\n' >> ${F}
printf '# The following makes use of the existing /run/httpd directory\n' >> ${F}
printf 'JkShmFile run/jk.shm\n' >> ${F}
printf '<Location /jkstatus/>\n' >> ${F}
printf '  JkMount status\n' >> ${F}
printf '  Order deny,allow\n' >> ${F}
printf '  Deny from all\n' >> ${F}
printf '  Allow from 127.0.0.1\n' >> ${F}
printf '</Location>\n' >> ${F}
chmod 640 ${F}
```

Next, the workers.properties file (/etc/httpd/conf/workers.properties). Since we are doing this for a cluster with load balancing, we need a file per node. As we are adding a node, we need to not only create a file for the new node, we also need to regenerate the files on the existing two nodes.
Executing the following on _all_ nodes will result in three files (_workers.properties.stroomp00_ , _workers.properties.stroomp01_ and the new _workers.properties.stroomp02_), of which the appropriate one should be deployed to it's server. So we run this on all three nodes.

```bash
cd /tmp
# Set the list of nodes
Nodes="stroomp00.strmdev00.org stroomp01.strmdev00.org stroomp02.strmdev00.org"
for oN in ${Nodes}; do
  _n=`echo ${oN} | cut -f1 -d\.`
  (
  printf '# Workers.properties for Stroom Cluster member: %s %s\n' ${oN}
  printf 'worker.list=loadbalancer,loadbalancer_proxy,local,local_proxy,status\n'
  L_t=""
  Lp_t=""
  for FQDN in ${Nodes}; do
    N=`echo ${FQDN} | cut -f1 -d\.`
    printf 'worker.%s.port=8009\n' ${N}
    printf 'worker.%s.host=%s\n' ${N} ${FQDN}
    printf 'worker.%s.type=ajp13\n' ${N}
    printf 'worker.%s.lbfactor=1\n' ${N}
    printf 'worker.%s.max_packet_size=65536\n' ${N}
    printf 'worker.%s_proxy.port=9009\n' ${N}
    printf 'worker.%s_proxy.host=%s\n' ${N} ${FQDN}
    printf 'worker.%s_proxy.type=ajp13\n' ${N}
    printf 'worker.%s_proxy.lbfactor=1\n' ${N}
    printf 'worker.%s_proxy.max_packet_size=65536\n' ${N}
    L_t="${L_t}${N},"
    Lp_t="${Lp_t}${N}_proxy,"
  done
  L=`echo $L_t | sed -e 's/.$//'`
  Lp=`echo $Lp_t | sed -e 's/.$//'`
  printf 'worker.loadbalancer.type=lb\n'
  printf 'worker.loadbalancer.balance_workers=%s\n' $L
  printf 'worker.loadbalancer.sticky_session=1\n'
  printf 'worker.loadbalancer_proxy.type=lb\n'
  printf 'worker.loadbalancer_proxy.balance_workers=%s\n' $Lp
  printf 'worker.loadbalancer_proxy.sticky_session=1\n'
  printf 'worker.local.type=lb\n'
  printf 'worker.local.balance_workers=%s\n' ${_n}
  printf 'worker.local.sticky_session=1\n'
  printf 'worker.local_proxy.type=lb\n'
  printf 'worker.local_proxy.balance_workers=%s_proxy\n' ${_n}
  printf 'worker.local_proxy.sticky_session=1\n'
  printf 'worker.status.type=status\n'
  ) > workers.properties.${_n}
  chmod 640 workers.properties.${_n}
done
```

Now depending in the node you are on, copy the relevant workers.properties.nodename file to /etc/httpd/conf/workers.properties. That is _workers.properties.stroomp00_ is used on stroomp00.strmdev00.org, _workers.properties.stroomp01_ on stroomp01.strmdev00.org, etc. The following makes this simple, execute this command on each node.

```bash
cp workers.properties.`hostname -s` /etc/httpd/conf/workers.properties
```

Now we need modify `/etc/httpd/conf/httpd.conf`  and `/etc/httpd/conf.d/ssl.conf` but backup them up first as per
```bash
cp /etc/httpd/conf/httpd.conf /etc/httpd/conf/httpd.conf.ORIG
cp /etc/httpd/conf.d/ssl.conf /etc/httpd/conf.d/ssl.conf.ORIG
```

As our node is part of an existing cluster, we can take a copy of these files from say `stroomp00.strmdev00.org` can copy them into place. To make this _really_ simple for you, do the following

On node `stroomp00.strmdev00.org` as root run
```bash
cp /etc/httpd/conf/httpd.conf /etc/httpd/conf.d/ssl.conf /stroomdata/stroom-data-p00
```
On our new node, `stroomp02.strmdev00.org` as root run
```bash
cp /stroomdata/stroom-data-p00/httpd.conf /etc/httpd/conf/httpd.conf
cp /stroomdata/stroom-data-p00/ssl.conf /etc/httpd/conf.d/ssl.conf
rm -f /stroomdata/stroom-data-p00/httpd.conf /stroomdata/stroom-data-p00/ssl.conf
```

Now tidy up the SELinux context for access on all nodes and files via
```bash
setsebool -P httpd_enable_homedirs on
setsebool -P httpd_can_network_connect on
chcon --reference /etc/httpd/conf.d/README /etc/httpd/conf.d/mod_jk.conf
chcon --reference /etc/httpd/conf/magic /etc/httpd/conf/workers.properties
```

We also enable both http and https services via the firewall on all nodes. If you don't want to present a http access point, then don't enable it in the firewall
setting
```bash
firewall-cmd --zone=public --add-service=http --permanent
firewall-cmd --zone=public --add-service=https --permanent
firewall-cmd --reload
firewall-cmd --zone=public --list-all
```

New enable then start the httpd service, correcting any errors. It should be noted that the suggestion of a systemctl status or viewing the journal are good, but most errors have better information in the httpd error logs found in `/var/log/httpd/`.
```bash
systemctl enable httpd.service
systemctl start httpd.service
```

__NOTE__ we don't restart the existing two node's httpd service yet (to accept the new workers.properties files). In fact, after configuring our new node, via the Stroom UI, we will restart the servers themselves.

## Establish a systemd service for our Stroom services

We first create some simple start/stop scripts that start, or stop, all the available Stroom services. At this point, it's just the Stroom application and proxy.
```bash
sudo -i -u stroomuser
if [ ! -d ~/bin ]; then mkdir ~/bin; fi
F=~/bin/StartServices.sh
printf '#!/bin/bash\n' > ${F}
printf '# Start all Stroom services\n' >> ${F}
printf '# Set list of services\n' >> ${F}
printf 'Services="stroom-proxy stroom-app"\n' >> ${F}
printf 'for service in ${Services}; do\n' >> ${F}
printf '  if [ -f ${service}/bin/start.sh ]; then\n' >> ${F}
printf '    bash ${service}/bin/start.sh\n' >> ${F}
printf '  fi\n' >> ${F}
printf 'done\n' >> ${F}
chmod 750 ${F}

F=~/bin/StopServices.sh
printf '#!/bin/bash\n' > ${F}
printf '# Stop all Stroom services\n' >> ${F}
printf '# Set list of services\n' >> ${F}
printf 'Services="stroom-proxy stroom-app"\n' >> ${F}
printf 'for service in ${Services}; do\n' >> ${F}
printf '  if [ -f ${service}/bin/stop.sh ]; then\n' >> ${F}
printf '    bash ${service}/bin/stop.sh\n' >> ${F}
printf '  fi\n' >> ${F}
printf 'done\n' >> ${F}
chmod 750 ${F}

exit;	# To become root
```

Now we create the system service file for Stroom. (Noting this is done as root). Also __NOTE__ that our services do not have a dependency on a local database as this is just a processing node only.
```bash
F=/etc/systemd/system/stroom-services.service
printf '# Install in /etc/systemd/system\n' > ${F}
printf '# Enable via systemctl enable stroom-services.service\n\n' >> ${F}
printf '[Unit]\n' >> ${F}
printf '# Who we are\n' >> ${F}
printf 'Description=Stroom Service\n' >> ${F}
printf '# We want the network, nfs and httpd up before us\n' >> ${F}
printf 'Requires=network-online.target nfs-server.service httpd.service\n' >> ${F}
printf 'After=httpd.service nfs-server.service network-online.target\n\n' >> ${F}
printf '[Service]\n' >> ${F}
printf '# Source our environment file so the Stroom service start/stop scripts work\n' >> ${F}
printf 'EnvironmentFile=/home/stroomuser/env_service.sh\n' >> ${F}
printf 'Type=oneshot\n' >> ${F}
printf 'ExecStart=/bin/su --login stroomuser /home/stroomuser/bin/StartServices.sh\n' >> ${F}
printf 'ExecStop=/bin/su --login stroomuser /home/stroomuser/bin/StopServices.sh\n' >> ${F}
printf 'RemainAfterExit=yes\n\n' >> ${F}
printf '[Install]\n' >> ${F}
printf 'WantedBy=multi-user.target\n' >> ${F}
chmod 640 ${F}
```

Now we enable and start the Stroom service.
```bash
systemctl enable stroom-services.service
systemctl start stroom-services.service
```

### Configure New node via User Interface
__NOTE:__ To attempt the following, see the _HOWTO_ [Stroom User Interface - Initial Configuration](StroomHowTo-1.60-a.md#adding-a-new-node-into-a-cluster "Initial Configuration via User Interface").

You should login as your administrative user and configure both the nodes Cluster urls and the storage volumes. The cluster url should be `http://stroomp02.strmdev00.org:8080/stroom/clustercall.rpc`.  After setting the cluster urls you will see a Ping response from all nodes in the Nodes tab in the Stroom UI (where you just set the URLs) and the `server.UpdateClusterStateTaskHandler` warnings will disappear from the Stroom application log files on both hosts.

### Restart all servers
At this point restart all processing severs via a reboot.

### Test new node
Once all servers are back up, you should test that the new node has been successfully integrated. This can be achieved via say, posting data to our test feed three times ... we should see a log of each post in each successive nodes proxy log files.

That is, on a given node, run the command
```bash
curl -k --data-binary @/etc/group "https://stroomp.strmdev00.org/stroom/datafeed" -H "Feed:TEST-FEED-V1_0" -H "System:EXAMPLE_SYSTEM" -H "Environment:EXAMPLE_ENVIRONMENT"
```
three times and on the nodes we will see in succession (it's suggested you become the stroomuser and run the `Tp` bash alias for this)

- Node: `stroomp00.strmdev00.org` proxy log file
```
...
2017-01-13T02:05:39.052Z INFO  [localhost-startStop-1] datafeed.ProxyHandlerFactory (ProxyHandlerFactory.java:162) - load() - Loaded context /META-INF/spring/stroomProxyStoreHandlerFactoryContext.xml
2017-01-13T02:05:39.124Z INFO  [localhost-startStop-1] spring.StroomBeanLifeCycleReloadableContextBeanProcessor (StroomBeanLifeCycleReloadableContextBeanProcessor.java:113) - ** webContext 0 STARTED  -> proxyHandlerFactory.start **
2017-01-13T02:05:39.124Z INFO  [localhost-startStop-1] spring.StroomBeanLifeCycleReloadableContextBeanProcessor (StroomBeanLifeCycleReloadableContextBeanProcessor.java:109) - ** webContext 0 START COMPLETE **
2017-01-13T02:05:39.197Z INFO  [ProxyProperties refresh thread 0] datafeed.ProxyHandlerFactory$1 (ProxyHandlerFactory.java:96) - refreshThread() - Started
2017-01-13T02:09:34.325Z INFO  [ajp-apr-9009-exec-1] handler.LogRequestHandler (LogRequestHandler.java:37) - log() - guid=24eda049-b7e5-44b6-9316-08825d21af3c,feed=TEST-FEED-V1_0,system=EXAMPLE_SYSTEM,environment=EXAMPLE_ENVIRONMENT,remotehost=192.168.2.220,remoteaddress=192.168.2.220
2017-01-13T02:09:34.353Z INFO  [ajp-apr-9009-exec-1] datafeed.DataFeedRequestHandler$1 (DataFeedRequestHandler.java:104) - "doPost() - Took 708 ms to process (concurrentRequestCount=1) 200","Environment=EXAMPLE_ENVIRONMENT","Expect=100-continue","Feed=TEST-FEED-V1_0","GUID=24eda049-b7e5-44b6-9316-08825d21af3c","ReceivedTime=2017-01-13T02:09:33.659Z","RemoteAddress=192.168.2.220","RemoteHost=192.168.2.220","System=EXAMPLE_SYSTEM","accept=*/*","content-length=1051","content-type=application/x-www-form-urlencoded","host=stroomp.strmdev00.org","user-agent=curl/7.19.7 (x86_64-redhat-linux-gnu) libcurl/7.19.7 NSS/3.21 Basic ECC zlib/1.2.3 libidn/1.18 libssh2/1.4.2"
```

- Node: `stroomp01.strmdev00.org` proxy log file
```
...
2017-01-13T02:05:47.321Z INFO  [localhost-startStop-1] spring.StroomBeanLifeCycleReloadableContextBeanProcessor (StroomBeanLifeCycleReloadableContextBeanProcessor.java:109) - ** proxyContext 0 START COMPLETE **
2017-01-13T02:05:47.328Z INFO  [localhost-startStop-1] datafeed.ProxyHandlerFactory (ProxyHandlerFactory.java:162) - load() - Loaded context /META-INF/spring/stroomProxyStoreHandlerFactoryContext.xml
2017-01-13T02:05:47.342Z INFO  [localhost-startStop-1] spring.StroomBeanLifeCycleReloadableContextBeanProcessor (StroomBeanLifeCycleReloadableContextBeanProcessor.java:113) - ** webContext 0 STARTED  -> proxyHandlerFactory.start **
2017-01-13T02:05:47.343Z INFO  [localhost-startStop-1] spring.StroomBeanLifeCycleReloadableContextBeanProcessor (StroomBeanLifeCycleReloadableContextBeanProcessor.java:109) - ** webContext 0 START COMPLETE **
2017-01-13T02:05:47.786Z INFO  [ProxyProperties refresh thread 0] datafeed.ProxyHandlerFactory$1 (ProxyHandlerFactory.java:96) - refreshThread() - Started
2017-01-13T02:09:37.478Z INFO  [ajp-apr-9009-exec-1] handler.LogRequestHandler (LogRequestHandler.java:37) - log() - guid=a926cd29-fbd5-47ff-b8ea-73d40c777489,feed=TEST-FEED-V1_0,system=EXAMPLE_SYSTEM,environment=EXAMPLE_ENVIRONMENT,remotehost=192.168.2.220,remoteaddress=192.168.2.220
2017-01-13T02:09:37.582Z INFO  [ajp-apr-9009-exec-1] datafeed.DataFeedRequestHandler$1 (DataFeedRequestHandler.java:104) - "doPost() - Took 840 ms to process (concurrentRequestCount=1) 200","Environment=EXAMPLE_ENVIRONMENT","Expect=100-continue","Feed=TEST-FEED-V1_0","GUID=a926cd29-fbd5-47ff-b8ea-73d40c777489","ReceivedTime=2017-01-13T02:09:36.746Z","RemoteAddress=192.168.2.220","RemoteHost=192.168.2.220","System=EXAMPLE_SYSTEM","accept=*/*","content-length=1051","content-type=application/x-www-form-urlencoded","host=stroomp.strmdev00.org","user-agent=curl/7.19.7 (x86_64-redhat-linux-gnu) libcurl/7.19.7 NSS/3.21 Basic ECC zlib/1.2.3 libidn/1.18 libssh2/1.4.2"
```

- Node: `stroomp02.strmdev00.org` proxy log file
```
...
2017-01-13T02:06:00.004Z INFO  [localhost-startStop-1] spring.StroomBeanMethodExecutable (StroomBeanMethodExecutable.java:31) - Starting proxyRepositoryReader.start
2017-01-13T02:06:00.047Z INFO  [localhost-startStop-1] spring.StroomBeanLifeCycleReloadableContextBeanProcessor (StroomBeanLifeCycleReloadableContextBeanProcessor.java:113) - ** proxyContext 0 STARTED  -> proxyRepositoryReader.start **
2017-01-13T02:06:00.047Z INFO  [localhost-startStop-1] spring.StroomBeanLifeCycleReloadableContextBeanProcessor (StroomBeanLifeCycleReloadableContextBeanProcessor.java:109) - ** proxyContext 0 START COMPLETE **
2017-01-13T02:06:00.051Z INFO  [localhost-startStop-1] datafeed.ProxyHandlerFactory (ProxyHandlerFactory.java:162) - load() - Loaded context /META-INF/spring/stroomProxyStoreHandlerFactoryContext.xml
2017-01-13T02:06:00.081Z INFO  [localhost-startStop-1] spring.StroomBeanLifeCycleReloadableContextBeanProcessor (StroomBeanLifeCycleReloadableContextBeanProcessor.java:113) - ** webContext 0 STARTED  -> proxyHandlerFactory.start **
2017-01-13T02:06:00.082Z INFO  [localhost-startStop-1] spring.StroomBeanLifeCycleReloadableContextBeanProcessor (StroomBeanLifeCycleReloadableContextBeanProcessor.java:109) - ** webContext 0 START COMPLETE **
2017-01-13T02:06:00.280Z INFO  [ProxyProperties refresh thread 0] datafeed.ProxyHandlerFactory$1 (ProxyHandlerFactory.java:96) - refreshThread() - Started
2017-01-13T02:09:40.040Z INFO  [ajp-apr-9009-exec-1] handler.LogRequestHandler (LogRequestHandler.java:37) - log() - guid=9b6dd80c-2996-4acc-8717-0a60592cd7d7,feed=TEST-FEED-V1_0,system=EXAMPLE_SYSTEM,environment=EXAMPLE_ENVIRONMENT,remotehost=192.168.2.220,remoteaddress=192.168.2.220
2017-01-13T02:09:40.057Z INFO  [ajp-apr-9009-exec-1] datafeed.DataFeedRequestHandler$1 (DataFeedRequestHandler.java:104) - "doPost() - Took 1.2 s to process (concurrentRequestCount=1) 200","Environment=EXAMPLE_ENVIRONMENT","Expect=100-continue","Feed=TEST-FEED-V1_0","GUID=9b6dd80c-2996-4acc-8717-0a60592cd7d7","ReceivedTime=2017-01-13T02:09:38.853Z","RemoteAddress=192.168.2.220","RemoteHost=192.168.2.220","System=EXAMPLE_SYSTEM","accept=*/*","content-length=1051","content-type=application/x-www-form-urlencoded","host=stroomp.strmdev00.org","user-agent=curl/7.19.7 (x86_64-redhat-linux-gnu) libcurl/7.19.7 NSS/3.21 Basic ECC zlib/1.2.3 libidn/1.18 libssh2/1.4.2"
```
