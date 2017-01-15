# Stroom HOWTO - MultiNode Complete Install
The following is a HOWTO to set up a Stroom cluster based on Centos 7.3/Mariadb infrastructure that uses Apache's httpd web service as a front end (https) and Apache's mod_jk as the interface between Apache and the Stroom tomcat applications. In this HOWTO, there is a database node and two processing nodes.

The HOWTO results with a running, but not operational, a two processing node Stroom Cluster with separate database node. To make the deployment operational, additional configuration is required thru the Stroom User Interface. Details on this can be found in the [Stroom User Interface - Initial Configuration](StroomHowTo-1.60-a.md "Initial Configuration via User Interface").

Last Update: Burn Alting, 15 Jan 2017

- Corrected http to https forwarding in /etc/httpd/conf.d/ssl.conf configuration
  Burn Alting, 15 Jan 2017
- Initial release (1.40-a)
  Burn Alting, 13 Jan 2017

Assumptions:
 - the user has reasonable RHEL/Centos System administration skills
 - the installation user has the ability to sudo
 - installation on Centos 7.3 minimal systems (fully patched)
 - database nodename is 'stroomdb0.strmdev00.org'
 - processing node names are 'stroomp00.strmdev00.org' and 'stroomp01.strmdev00.org'
 - the first node, 'stroomp00.strmdev00.org' also has a CNAME 'stroomp.strmdev00.org'
 - stroom runs as user 'stroomuser'
 - data will reside in '/stroomdata' which is a link (in this HOWTO) to /home/stroomdata
 - when a screen capture is documented, data entry is identified by the data surrounded by '<__' '__>' . This excludes enter/return presses.
 - better security of password choices, networking, firewalls, data stores, etc can and should be achieved in various ways, but these HOWTOs are just a quick means of getting a working system, so only limited security is applied
 - better configuration of the database (eg more memory. redundancy) should be considered in production environments
 - the use of self signed certificates is appropriate for test systems, but users should consider appropriate CA infrastructure in production environments

## Create Base Operating System and install required packages for Database node
First, create a Centos 7.3 minimal instance, then patch via a yum -y update. Should the kernel be updated when patching, then don't forget to reboot.

### Establish the database
We now install and configure the database. This is a very simple instance of a Stroom database.
In a production environment one should consider redundancy, storage, memory allocation, etc.

### Install Database software
First we install the database software, enable then start it's service.
```bash
sudo yum -y install mariadb mariadb-server
sudo systemctl enable mariadb.service
sudo systemctl start mariadb.service
```

#### Secure database engine
We secure the database engine by running the `mysql_secure_installation` script. One should accept all defaults which means the only entry (aside from pressing returns) is the root database password. Make a note of the password you use.

```bash
sudo mysql_secure_installation
```
to see
```
NOTE: RUNNING ALL PARTS OF THIS SCRIPT IS RECOMMENDED FOR ALL MariaDB
      SERVERS IN PRODUCTION USE!  PLEASE READ EACH STEP CAREFULLY!

In order to log into MariaDB to secure it, we'll need the current
password for the root user.  If you've just installed MariaDB, and
you haven't set the root password yet, the password will be blank,
so you should just press enter here.

Enter current password for root (enter for none): 
OK, successfully used password, moving on...

Setting the root password ensures that nobody can log into the MariaDB
root user without the proper authorisation.

Set root password? [Y/n] 
New password: <__ENTER_ROOT_DATABASE_PASSWORD__>
Re-enter new password: <__ENTER_ROOT_DATABASE_PASSWORD__>
Password updated successfully!
Reloading privilege tables..
 ... Success!


By default, a MariaDB installation has an anonymous user, allowing anyone
to log into MariaDB without having to have a user account created for
them.  This is intended only for testing, and to make the installation
go a bit smoother.  You should remove them before moving into a
production environment.

Remove anonymous users? [Y/n] 
 ... Success!

Normally, root should only be allowed to connect from 'localhost'.  This
ensures that someone cannot guess at the root password from the network.

Disallow root login remotely? [Y/n] 
 ... Success!

By default, MariaDB comes with a database named 'test' that anyone can
access.  This is also intended only for testing, and should be removed
before moving into a production environment.

Remove test database and access to it? [Y/n] 
 - Dropping test database...
 ... Success!
 - Removing privileges on test database...
 ... Success!
 
Reloading the privilege tables will ensure that all changes made so far
will take effect immediately.

Reload privilege tables now? [Y/n] 
... Success!

Cleaning up...

All done!  If you've completed all of the above steps, your MariaDB
installation should now be secure.

Thanks for using MariaDB!
```

### Create the Database
Now we create the Stroom database and prepare to allow the processing user from each node to use it. Thus we execute
```bash
sudo mysql --user=root -p
```

and enter root's mariadb password then at the `MariaDB [(none)]> ` prompt enter

```bash
create database stroom;
grant all privileges on stroom.* to stroomuser@localhost identified by 'stroompassword1';
grant all privileges on stroom.* to stroomuser@stroomp00.strmdev00.org identified by 'stroompassword1';
grant all privileges on stroom.* to stroomuser@stroomp01.strmdev00.org identified by 'stroompassword1';
quit;
```

One could change the specific node permissions with
```bash
grant all privileges on stroom.* to stroomuser@'%.strmdev00.org' identified by 'stroompassword1';
quit;
```

Next we need to modify our database firewall to allow remote access to our database.
```bash
sudo firewall-cmd --zone=public --add-port=3306/tcp --permanent
sudo firewall-cmd --reload
sudo firewall-cmd --zone=public --list-all
```

#### Debugging of Mariadb for Stroom
If there is a need to debug the Mariadb and Stroom interaction, on can turn on auditing for the Mariadb service. To do so, perform the following
```bash
sudo mysql --user=root -p
```
and at the `MariaDB [(none)]> ` prompt enter

```bash
install plugin server_audit SONAME 'server_audit.so';
set global server_audit_logging=ON;
set global server_audit_file_rotate_size=10485760;
quit;
```
At this one can view the audit log file `/var/lib/mysql/server_audit.log`.

If you wish to rotate the log file, manually, just execute
```bash
set global server_audit_file_rotate_now=1;
```
at the `MariaDB [(none)]> ` prompt.

Another useful feature is to get a list of all failed commands separately. This is achieved by installing another standard plugin with
```bash
install plugin SQL_ERROR_LOG soname 'sql_errlog';
```
command at the `MariaDB [(none)]> ` prompt. At this all erroneous SQL command will appear in the file `/var/lib/mysql/sql_errors.log`.

## Create Base Operating System and install required packages for each Stroom Processing system
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

We now create the storage hierarchy. The hierarchy is
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


Now a Stroom processing cluster needs to access all nodes data directory structures - `/stroomdata/stroom-data-pNN`. In this HOWTO we achieve this access via NFS. That is node `stroomp00.strmdev00.org`  will mount `stroomp01.strmdev00.org:/stroomdata/stroom-data-p01` and node `stroomp01.strmdev00.org` will mount `stroomp00.strmdev00.org:/stroomdata/stroom-data-p00`. Both mounts will be in the same relative location.

The above nomenclature of tagging all directories with a node identifier is for simplicity. As we have just stated, we only need to share out the _stroom-data_ directories and hence we need a node identifier, but in some instances you may also want to share out the _working_ areas as well. It is noted that there is no need to share the index directories and you should not share the proxy directories.

So the relevant commands to create this on each node are
- Node: `stroomp00.strmdev00.org`
```bash
sudo mkdir -p /home/stroomdata
sudo ln -s /home/stroomdata /stroomdata
sudo mkdir -p /stroomdata/stroom-data-p00 /stroomdata/stroom-index-p00 /stroomdata/stroom-working-p00 /stroomdata/stroom-working-p00/proxy
sudo mkdir -p /stroomdata/stroom-data-p01
sudo chown -R stroomuser:stroomuser /home/stroomdata
sudo chmod -R 750 /home/stroomdata
```

- Node: `stroomp01.strmdev00.org`
```bash
sudo mkdir -p /home/stroomdata
sudo ln -s /home/stroomdata /stroomdata
sudo mkdir -p /stroomdata/stroom-data-p01 /stroomdata/stroom-index-p01 /stroomdata/stroom-working-p01 /stroomdata/stroom-working-p01/proxy
sudo mkdir -p /stroomdata/stroom-data-p00
sudo chown -R stroomuser:stroomuser /home/stroomdata
sudo chmod -R 750 /home/stroomdata
```

#### Install and Enable NFS software
We install NFS on each node, via
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
We now export the node's /home/stroomdata directory (in case you want to share the working directories) by configuring /etc/exports. For simplicity sake, we will allow all nodes with the hostname nomenclature of stroomp*.strmdev00.org to mount the `/home/stroomdata` directory. This means the same configuration applies to all nodes.
```
# Share Stroom data directory
/home/stroomdata	stroomp*.strmdev00.org(rw,sync,no_root_squash)
```

This can be achieved with the following on both nodes
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
sudo mount -t nfs4 stroomp01.strmdev00.org:/home/stroomdata/stroom-data-p01 /home/stroomdata/stroom-data-p01
```

- Node: `stroomp01.strmdev00.org`
```bash
sudo mount -t nfs4 stroomp00.strmdev00.org:/home/stroomdata/stroom-data-p00 /home/stroomdata/stroom-data-p00
```

If you are concerned you can't see the mount with a `df` try a `df --type=nfs4 -a` or a `sudo df`. Irrespective, once the mounting works, make the mounts permanent by adding the following to each node's /etc/fstab file.
- Node: `stroomp00.strmdev00.org`
```
stroomp01.strmdev00.org:/home/stroomdata/stroom-data-p01 /home/stroomdata/stroom-data-p01 nfs4 soft,bg
```
achieved with
```bash
sudo su -c "printf 'stroomp01.strmdev00.org:/home/stroomdata/stroom-data-p01 /home/stroomdata/stroom-data-p01 nfs4 soft,bg\n' >> /etc/fstab"
```

- Node: `stroomp01.strmdev00.org`
```
stroomp00.strmdev00.org:/home/stroomdata/stroom-data-p00 /home/stroomdata/stroom-data-p00 nfs4 soft,bg
```
achieved with
```bash
sudo su -c "printf 'stroomp00.strmdev00.org:/home/stroomdata/stroom-data-p00 /home/stroomdata/stroom-data-p00 nfs4 soft,bg\n' >> /etc/fstab"
```

At this point reboot both processing nodes to ensure the directories mount automatically. You may need to give the nodes a minute to do this.

### Install the database client software and test access to the database on each node

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

- Node: `stroomp00.strmdev00.org`

```bash
F=~/env.sh
printf '# Environment variables for Stroom services\n' > ${F}
printf 'export JAVA_HOME=/usr/lib/jvm/java-1.8.0\n' >> ${F}
printf 'export PATH=${JAVA_HOME}/bin:${PATH}\n' >> ${F}
printf 'export STROOM_TMP=/stroomdata/stroom-working-p00\n' >> ${F}
chmod 640 ${F}

F=~/env_service.sh
printf '# Environment variables for Stroom services, executed out of systemd service\n' > ${F}
printf 'JAVA_HOME=/usr/lib/jvm/java-1.8.0\n' >> ${F}
printf 'PATH=${JAVA_HOME}/bin:${PATH}\n' >> ${F}
printf 'STROOM_TMP=/stroomdata/stroom-working-p00\n' >> ${F}
chmod 640 ${F}
```

- Node: `stroomp01.strmdev00.org`

```bash
F=~/env.sh
printf '# Environment variables for Stroom services\n' > ${F}
printf 'export JAVA_HOME=/usr/lib/jvm/java-1.8.0\n' >> ${F}
printf 'export PATH=${JAVA_HOME}/bin:${PATH}\n' >> ${F}
printf 'export STROOM_TMP=/stroomdata/stroom-working-p01\n' >> ${F}
chmod 640 ${F}

F=~/env_service.sh
printf '# Environment variables for Stroom services, executed out of systemd service\n' > ${F}
printf 'JAVA_HOME=/usr/lib/jvm/java-1.8.0\n' >> ${F}
printf 'PATH=${JAVA_HOME}/bin:${PATH}\n' >> ${F}
printf 'STROOM_TMP=/stroomdata/stroom-working-p01\n' >> ${F}
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

At this point, we will install the application and proxy on both nodes. So first extract the code

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
TEMP_DIR should be set to '/stroomdata/stroom-working-p00' or '/stroomdata/stroom-working-p01' depending on the node we are installing on
NODE to be the hostname (not FQDN) of your host (i.e. 'stroomp00' or 'stroomp01' in our example)
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
NODE to be the hostname (not FQDN) of your host (i.e. 'stroomp00' or 'stroomp01' depending on the node we are installing on)
PORT_PREFIX should use the default, just press return
REPO_DIR should be set to '/stroomdata/stroom-working-p00/proxy' or '/stroomdata/stroom-working-p01/proxy' depending on the node we are installing on
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

We can now manually start the proxy on all nodes in the cluster. Do so with
```bash
stroom-proxy/bin/start.sh
```
Now monitor the directory `stroom-proxy/instance/logs` for any errors. Initially you will see the log files `localhost_access_log.YYYY-MM-DD.txt` and `catalina.out`. Check them for errors and correct (or pose a question to this arena). The context path and unknown version warnings in `catalina.out` can be ignored.
Eventually (about 60 seconds) the log file `stroom-proxy/instance/logs/stroom.log` will appear. Again check it for errors. If you leave it for a while you
will eventually see cyclic (10 minute cycle) messages of the form
```
INFO  [Repository Reader Thread 1] handler.ProxyRepositoryReader (ProxyRepositoryReader.java:143) - run() - Cron Match at YYYY-MM-DD ...
```

Now we start the application on our first node, `stroomp00.strmdev00.org`, __and then wait__ until it has initialised the database and commenced it's Lifecycle task. You will need to monitor the log files to see it's completed initialisation. To start the application, perform.
```bash
stroom-app/bin/start.sh
```
Now monitor `stroom-app/instance/logs` for any errors. Initially you will see the log files `localhost_access_log.YYYY-MM-DD.txt` and `catalina.out`. Check them for errors and correct (or post a question to this forum). The log4j warnings in `catalina.out` can be ignored.
Eventually the log file `stroom-app/instance/logs/stroom.log` will appear. Again check it for errors and then wait for the application to be initialised. That is, wait for the Lifecycle service thread to start
```
INFO  [Thread-11] lifecycle.LifecycleServiceImpl (LifecycleServiceImpl.java:166) - Started Stroom Lifecycle service
```
The directory `stroom-proxy/instance/logs/events` will also appear with an empty file with the nomenclature `events_YYYY-MM-DDThh:mm:ss.msecZ`. This is the directory for storing Stroom's application event logs. We will return to this directory and it's content in a later HOWTO.

Once the database has initialised, then start the application service on the other node. Again with
```bash
stroom-app/bin/start.sh
```
and then monitor the files in its `stroom-app/instance/logs` for any errors.

Note you will see server.UpdateClusterStateTaskHandler messages of the form
```
WARN  [Stroom P2 #9 - GenericServerTask] server.UpdateClusterStateTaskHandler (UpdateClusterStateTaskHandler.java:150) - discover() - unable to contact stroomp00 - No cluster call URL has been set for node: stroomp00
```
This is ok as we will establish the cluster URL's later.

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

### Create certificates
The first step is to establish a self signed certificate for our Stroom service. If you have a certificate server, then certainly gain an appropriately signed certificate. For this HOWTO, we will stay with a self signed solution and hence no certificate authorities are involved. As we are a cluster, we will only have one certificate for all nodes. We achieve this by setting up an alias for our first node in the cluster and then use that alias for addressing the cluster. That is we will set up a CNAME, `stroomp.strmdev00.org` for `stroomp00.strmdev00.org`. This means within Apache, the ServerName will be `stroomp.strmdev00.org` on each node.

We first set up a directory to house our certificates on the first node. (We will replicate it's content to other nodes later).
```bash
sudo -i -u stroomuser
export H=stroomp
cd ~stroomuser
rm -rf stroom-jks
mkdir -p stroom-jks stroom-jks/public stroom-jks/private
cd stroom-jks
```

Create a server key for Stroom service (enter a password when prompted for both initial and verification prompts)
```bash
openssl genrsa -des3 -out private/$H.key 2048
```
as per
```
Generating RSA private key, 2048 bit long modulus
.................................................................+++
...............................................+++
e is 65537 (0x10001)
Enter pass phrase for private/stroomp.key: <__ENTER_SERVER_KEY_PASSWORD__>
Verifying - Enter pass phrase for private/stroomp.key: <__ENTER_SERVER_KEY_PASSWORD__>

```

Create a signing request. The two important prompts are the password and Common Name. All the rest can use the defaults offered.
The requested password is for the server key and you should use the cluster's CNAME for the Common Name (i.e. stroomp.strmdev00.org).

```bash
openssl req -sha256 -new -key private/$H.key -out $H.csr
```
as per
```
Enter pass phrase for private/stroomp.key: <__ENTER_SERVER_KEY_PASSWORD__>
You are about to be asked to enter information that will be incorporated
into your certificate request.
What you are about to enter is what is called a Distinguished Name or a DN.
There are quite a few fields but you can leave some blank
For some fields there will be a default value,
If you enter '.', the field will be left blank.
-----
Country Name (2 letter code) [XX]:
State or Province Name (full name) []:
Locality Name (eg, city) [Default City]:
Organization Name (eg, company) [Default Company Ltd]:
Organizational Unit Name (eg, section) []:
Common Name (eg, your name or your server's hostname) []:<__ stroomp.strmdev00.org __>
Email Address []:

Please enter the following 'extra' attributes
to be sent with your certificate request
A challenge password []:
An optional company name []:
```

Self sign the certificate (again enter the server key password)
```bash
openssl x509 -req -sha256 -days 720 -in $H.csr -signkey private/$H.key -out public/$H.crt
```
as per
```
Signature ok
subject=/C=XX/L=Default City/O=Default Company Ltd/CN=stroomp.strmdev00.org
Getting Private key
Enter pass phrase for private/stroomp.key: <__ENTER_SERVER_KEY_PASSWORD__>
```

Create insecure version of Private Key for Apache autoboot (you will again need to enter the password)
```bash
openssl rsa -in private/$H.key -out private/$H.key.insecure
```
as per
```
Enter pass phrase for private/stroomp.key: <__ENTER_SERVER_KEY_PASSWORD__>
writing RSA key
```
and then move the insecure keys as appropriate
```bash
mv private/$H.key private/$H.key.secure
chmod 600 private/$H.key.secure
mv private/$H.key.insecure private/$H.key
```

Now replicate the directory ~stroomuser/stroom-jks to each node in the cluster. That is, tar it up, copy the tar file to stroomp01 and untar it. We can make use of the other node's mounted file system. So execute the commands on `stroomp00.strmdev00.org`
```bash
cd ~stroomuser
tar cf stroom-jks.tar stroom-jks
mv stroom-jks.tar /home/stroomdata/stroom-data-p01
```
then on the other node (`stroomp01.strmdev00.org`) we extract the data.
```bash
cd ~stroomuser
tar xf /home/stroomdata/stroom-data-p01/stroom-jks.tar && rm -f /home/stroomdata/stroom-data-p01/stroom-jks.tar
```

Now ensure protection, ownership and SELinux context for these files on _each_ node
```bash
chmod 700 ~stroomuser/stroom-jks/private ~stroomuser/stroom-jks
chown -R stroomuser:stroomuser ~stroomuser/stroom-jks
chcon -R --reference /etc/pki ~stroomuser/stroom-jks
```

### Configure Apache httpd
Now become root and configure the httpd service.

First, create the index file (/var/www/html/index.html) on both nodes so browsing to the root of our node will present the Stroom UI

```bash
F=/var/www/html/index.html
printf '<html>\n' > ${F}
printf '<head>\n' >> ${F}
printf '  <meta http-equiv="Refresh" content="0; URL=stroom"/>\n' >> ${F}
printf '</head>\n' >> ${F}
printf '</html>\n' >> ${F}
chmod 644 ${F}
```

Next, the mod_jk configuration file (/etc/httpd/conf.d/mod_jk.conf) should be created on both nodes.

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

Next, the workers.properties file (/etc/httpd/conf/workers.properties). Since we are doing this for a cluster with load balancing, we need a file per node. Executing the following will result in two files (_workers.properties.stroomp00_ and _workers.properties.stroomp01_) which should be deployed to their respective servers.

```bash
cd /tmp
# Set the list of nodes
Nodes="stroomp00.strmdev00.org stroomp01.strmdev00.org"
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

Now depending in the node you are on, copy the relevant workers.properties.nodename file to /etc/httpd/conf/workers.properties. The following command makes this simple.

```bash
cp workers.properties.`hostname -s` /etc/httpd/conf/workers.properties
```

Now modify `/etc/httpd/conf/httpd.conf` but backup the file first with
```bash
cp /etc/httpd/conf/httpd.conf /etc/httpd/conf/httpd.conf.ORIG
```
then, add before the ServerRoot directive the following directives which are designed to make the httpd service more secure.
```
# Stroom Change: Start - Apply generic security directives
ServerTokens Prod
ServerSignature Off
FileETag None
RewriteEngine On
RewriteCond %{THE_REQUEST} !HTTP/1.1$
RewriteRule .* - [F]
Header set X-XSS-Protection "1; mode=block"
# Stroom Change: End
```
That is,
```
...
# Do not add a slash at the end of the directory path.  If you point
# ServerRoot at a non-local disk, be sure to specify a local disk on the
# Mutex directive, if file-based mutexes are used.  If you wish to share the
# same ServerRoot for multiple httpd daemons, you will need to change at
# least PidFile.
#
ServerRoot "/etc/httpd"

#
# Listen: Allows you to bind Apache to specific IP addresses and/or
...
```
becomes
```
...
# Do not add a slash at the end of the directory path.  If you point
# ServerRoot at a non-local disk, be sure to specify a local disk on the
# Mutex directive, if file-based mutexes are used.  If you wish to share the
# same ServerRoot for multiple httpd daemons, you will need to change at
# least PidFile.
#
# Stroom Change: Start - Apply generic security directives
ServerTokens Prod
ServerSignature Off
FileETag None
RewriteEngine On
RewriteCond %{THE_REQUEST} !HTTP/1.1$
RewriteRule .* - [F]
Header set X-XSS-Protection "1; mode=block"
# Stroom Change: End
ServerRoot "/etc/httpd"

#
# Listen: Allows you to bind Apache to specific IP addresses and/or
...
```

We now block access to the /var/www directory by commenting out
```
<Directory "/var/www">
  AllowOverride None
  # Allow open access:
  Require all granted
</Directory>
```
that is
```
...
#
# Relax access to content within /var/www.
#
<Directory "/var/www">
    AllowOverride None
    # Allow open access:
    Require all granted
</Directory>

# Further relax access to the default document root:
...
```
becomes
```
...
#
# Relax access to content within /var/www.
#
# Stroom Change: Start - Block access to /var/www
# <Directory "/var/www">
#     AllowOverride None
#     # Allow open access:
#     Require all granted
# </Directory>
# Stroom Change: End

# Further relax access to the default document root:
...
```
then within the /var/www/html directory turn off Indexes FollowSymLinks by commenting out the line
```
Options Indexes FollowSymLinks
```
That is
```
...
    # The Options directive is both complicated and important.  Please see
    # http://httpd.apache.org/docs/2.4/mod/core.html#options
    # for more information.
    #
    Options Indexes FollowSymLinks

    #
    # AllowOverride controls what directives may be placed in .htaccess files.
    # It can be "All", "None", or any combination of the keywords:
...
```
becomes
```
...
    # The Options directive is both complicated and important.  Please see
    # http://httpd.apache.org/docs/2.4/mod/core.html#options
    # for more information.
    #
    # Stroom Change: Start - turn off indexes and FollowSymLinks
    # Options Indexes FollowSymLinks
    # Stroom Change: End

    #
    # AllowOverride controls what directives may be placed in .htaccess files.
    # It can be "All", "None", or any combination of the keywords:
...
```
Then finally we add two new log formats and configure the access log to use the new format. This is done within the `<IfModule logio_module>` by adding the two new LogFormat directives
```
LogFormat "%a/%{REMOTE_PORT}e %X %t %l \"%u\" \"%r\" %s/%>s %D %I/%O/%B \"%{Referer}i\" \"%{User-Agent}i\" %V/%p" blackboxUser
LogFormat "%a/%{REMOTE_PORT}e %X %t %l \"%{SSL_CLIENT_S_DN}x\" \"%r\" %s/%>s %D %I/%O/%B \"%{Referer}i\" \"%{User-Agent}i\" %V/%p" blackboxSSLUser
```
and replacing the CustomLog directive
```
CustomLog "logs/access_log" combined
```
with
```
CustomLog logs/access_log blackboxSSLUser
```
That is
```
...
    LogFormat "%h %l %u %t \"%r\" %>s %b" common

    <IfModule logio_module>
      # You need to enable mod_logio.c to use %I and %O
      LogFormat "%h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\" %I %O" combinedio
    </IfModule>

    #
    # The location and format of the access logfile (Common Logfile Format).
    # If you do not define any access logfiles within a <VirtualHost>
    # container, they will be logged here.  Contrariwise, if you *do*
    # define per-<VirtualHost> access logfiles, transactions will be
    # logged therein and *not* in this file.
    #
    #CustomLog "logs/access_log" common

    #
    # If you prefer a logfile with access, agent, and referer information
    # (Combined Logfile Format) you can use the following directive.
    #
    CustomLog "logs/access_log" combined
</IfModule>
...
```
becomes
```
...
    LogFormat "%h %l %u %t \"%r\" %>s %b" common

    <IfModule logio_module>
      # You need to enable mod_logio.c to use %I and %O
      LogFormat "%h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\" %I %O" combinedio
      # Stroom Change: Start - Add new logformats
      LogFormat "%a/%{REMOTE_PORT}e %X %t %l \"%u\" \"%r\" %s/%>s %D %I/%O/%B \"%{Referer}i\" \"%{User-Agent}i\" %V/%p" blackboxUser
      LogFormat "%a/%{REMOTE_PORT}e %X %t %l \"%{SSL_CLIENT_S_DN}x\" \"%r\" %s/%>s %D %I/%O/%B \"%{Referer}i\" \"%{User-Agent}i\" %V/%p" blackboxSSLUser
      # Stroom Change: End
    </IfModule>
    # Stroom Change: Start - Add new logformats without the additional byte values
    <IfModule !logio_module>
      LogFormat "%a/%{REMOTE_PORT}e %X %t %l \"%u\" \"%r\" %s/%>s %D 0/0/%B \"%{Referer}i\" \"%{User-Agent}i\" %V/%p" blackboxUser
      LogFormat "%a/%{REMOTE_PORT}e %X %t %l \"%{SSL_CLIENT_S_DN}x\" \"%r\" %s/%>s %D 0/0/%B \"%{Referer}i\" \"%{User-Agent}i\" %V/%p" blackboxSSLUser
    </IfModule>
    # Stroom Change: End

    #
    # The location and format of the access logfile (Common Logfile Format).
    # If you do not define any access logfiles within a <VirtualHost>
    # container, they will be logged here.  Contrariwise, if you *do*
    # define per-<VirtualHost> access logfiles, transactions will be
    # logged therein and *not* in this file.
    #
    #CustomLog "logs/access_log" common

    #
    # If you prefer a logfile with access, agent, and referer information
    # (Combined Logfile Format) you can use the following directive.
    #
    # Stroom Change: Start - Make the access log use a new format
    # CustomLog "logs/access_log" combined
    CustomLog logs/access_log blackboxSSLUser
    # Stroom Change: End
</IfModule>
...
```

Now modify `/etc/httpd/conf.d/ssl.conf`, backing up first,
```base
cp /etc/httpd/conf.d/ssl.conf /etc/httpd/conf.d/ssl.conf.ORIG
```

Before the <VirtualHost _default_:443> context we add http to https redirection by adding the directives (noting we specify the server name)
```
<VirtualHost *:80>
  ServerName stroomp00.strmdev00.org
  Redirect permanent "/" "https://stroomp00.strmdev00.org/"
</VirtualHost>
```

Within the <VirtualHost _default_:443> context set the directives
```
ServerName stroomp.strmdev00.org
JkMount /stroom* local
JkMount /stroom/remoting/cluster* local
JkMount /stroom/datafeed* loadbalancer_proxy
JkMount /stroom/remoting* loadbalancer_proxy
JkMount /stroom/datafeed/direct* loadbalancer
JkOptions +ForwardKeySize +ForwardURICompat +ForwardSSLCertChain -ForwardDirectories
```
That is, we change
```
...
## SSL Virtual Host Context
##

<VirtualHost _default_:443>

# General setup for the virtual host, inherited from global configuration
#DocumentRoot "/var/www/html"
#ServerName www.example.com:443

# Use separate log files for the SSL virtual host; note that LogLevel
# is not inherited from httpd.conf.
...
```
to
```
...
## SSL Virtual Host Context
##

# Stroom Change: Start - Add http redirection to https
<VirtualHost *:80>
  ServerName stroomp.strmdev00.org
  Redirect permanent "/" "https://stroomp.strmdev00.org/"
</VirtualHost>
# Stroom Change: End

<VirtualHost _default_:443>

# General setup for the virtual host, inherited from global configuration
#DocumentRoot "/var/www/html"
#ServerName www.example.com:443
# Stroom Change: Start - Set servername and mod_jk connectivity
ServerName stroomp.strmdev00.org
JkMount /stroom* local
JkMount /stroom/remoting/cluster* local
JkMount /stroom/datafeed* loadbalancer_proxy
JkMount /stroom/remoting* loadbalancer_proxy
JkMount /stroom/datafeed/direct* loadbalancer
JkOptions +ForwardKeySize +ForwardURICompat +ForwardSSLCertChain -ForwardDirectories
# Stroom Change: End

# Use separate log files for the SSL virtual host; note that LogLevel
# is not inherited from httpd.conf.
...
```
We replace the standard certificate files with the self signed certificates. That is, replace
```
SSLCertificateFile /etc/pki/tls/certs/localhost.crt
```
with
```
SSLCertificateFile /home/stroomuser/stroom-jks/public/stroomp.crt
```
and
```
SSLCertificateKeyFile /etc/pki/tls/private/localhost.key
```
with
```
SSLCertificateKeyFile /home/stroomuser/stroom-jks/private/stroomp.key
```
That is, change
```
...
# pass phrase.  Note that a kill -HUP will prompt again.  A new
# certificate can be generated using the genkey(1) command.
SSLCertificateFile /etc/pki/tls/certs/localhost.crt

#   Server Private Key:
#   If the key is not combined with the certificate, use this
#   directive to point at the key file.  Keep in mind that if
#   you've both a RSA and a DSA private key you can configure
#   both in parallel (to also allow the use of DSA ciphers, etc.)
SSLCertificateKeyFile /etc/pki/tls/private/localhost.key

#   Server Certificate Chain:
#   Point SSLCertificateChainFile at a file containing the
...
```
to
```
...
# pass phrase.  Note that a kill -HUP will prompt again.  A new
# certificate can be generated using the genkey(1) command.
# Stroom Change: Start - Replace with Stroom server certificate
# SSLCertificateFile /etc/pki/tls/certs/localhost.crt
SSLCertificateFile /home/stroomuser/stroom-jks/public/stroomp.crt
# Stroom Change: End

#   Server Private Key:
#   If the key is not combined with the certificate, use this
#   directive to point at the key file.  Keep in mind that if
#   you've both a RSA and a DSA private key you can configure
#   both in parallel (to also allow the use of DSA ciphers, etc.)
# Stroom Change: Start - Replace with Stroom server private key file
# SSLCertificateKeyFile /etc/pki/tls/private/localhost.key
SSLCertificateKeyFile /home/stroomuser/stroom-jks/private/stroomp.key
# Stroom Change: End

#   Server Certificate Chain:
#   Point SSLCertificateChainFile at a file containing the
...
```
If you have signed your Stroom server certificate with a Certificate Authority, then change
```
SSLCACertificateFile /etc/pki/tls/certs/ca-bundle.crt
```
to be your own certificate bundle which you should probably store as `~stroomuser/stroom-jks/public/stroomp-ca-bundle.crt`.

Now as you are using a self signed certificate, you will need to set add the Client Authentication to have a value of
```
SSLVerifyClient optional_no_ca
```
noting that this may change if you actually use a CA.
That is, changing
```
...
#   Client Authentication (Type):
#   Client certificate verification type and depth.  Types are
#   none, optional, require and optional_no_ca.  Depth is a
#   number which specifies how deeply to verify the certificate
#   issuer chain before deciding the certificate is not valid.
#SSLVerifyClient require
#SSLVerifyDepth  10

#   Access Control:
#   With SSLRequire you can do per-directory access control based
...
```
to
```
...
#   Client Authentication (Type):
#   Client certificate verification type and depth.  Types are
#   none, optional, require and optional_no_ca.  Depth is a
#   number which specifies how deeply to verify the certificate
#   issuer chain before deciding the certificate is not valid.
#SSLVerifyClient require
#SSLVerifyDepth  10
# Stroom Change: Start - Set optional_no_ca (given we have a self signed certificate)
SSLVerifyClient optional_no_ca
# Stroom Change: End

#   Access Control:
#   With SSLRequire you can do per-directory access control based
...
```

We now need to secure certain Stroom servlets, to ensure they are only accessed under appropriate control.

This set of servlets will be accessible by all nodes in the subnet 192.168.2 (as well as localhost). We achieve this by adding after the example Location directives
```
<Location ~ "stroom/(status|echo|sessionList|debug)" >
 Require all denied
 Require ip 127.0.0.1 192.168.2
</Location>
```
We further restrict the clustercall and export servlets to just the localhost. If we had multiple Stroom processing nodes, you would specify each node, or preferably, the subnet they are on. In our case this is 192.168.2
```
<Location ~ "stroom/export/|stroom/remoting/clustercall.rpc" >
 Require all denied
 Require ip 127.0.0.1 192.168.2
</Location>
```
That is, the following
```
...
#            and %{TIME_WDAY} >= 1 and %{TIME_WDAY} <= 5 \
#            and %{TIME_HOUR} >= 8 and %{TIME_HOUR} <= 20       ) \
#           or %{REMOTE_ADDR} =~ m/^192\.76\.162\.[0-9]+$/
#</Location>

#   SSL Engine Options:
#   Set various options for the SSL engine.
#   o FakeBasicAuth:
...
```
changes to
```
...
#            and %{TIME_WDAY} >= 1 and %{TIME_WDAY} <= 5 \
#            and %{TIME_HOUR} >= 8 and %{TIME_HOUR} <= 20       ) \
#           or %{REMOTE_ADDR} =~ m/^192\.76\.162\.[0-9]+$/
#</Location>

# Stroom Change: Start - Lock access to certain servlets
<Location ~ "stroom/(status|echo|sessionList|debug)" >
 Require all denied
 Require ip 127.0.0.1 192.168.2
</Location>
# Lock these Servlets more securely - to just localhost and processing node(s)
<Location ~ "stroom/export/|stroom/remoting/clustercall.rpc" >
 Require all denied
 Require ip 127.0.0.1 192.168.2
</Location>
# Stroom Change: End

#   SSL Engine Options:
#   Set various options for the SSL engine.
#   o FakeBasicAuth:
...
```

Finally, as we make use of the Black Box Apache log format, we replace the standard format
```
CustomLog logs/ssl_request_log \
        "%t %h %{SSL_PROTOCOL}x %{SSL_CIPHER}x \"%r\" %b"
```
with
```
CustomLog logs/ssl_request_log blackboxSSLUser
```
That is, change
```
...
#   Per-Server Logging:
#   The home of a custom SSL log file. Use this when you want a
#   compact non-error SSL logfile on a virtual host basis.
CustomLog logs/ssl_request_log \
          "%t %h %{SSL_PROTOCOL}x %{SSL_CIPHER}x \"%r\" %b"

</VirtualHost>
```
to
```
...
#   Per-Server Logging:
#   The home of a custom SSL log file. Use this when you want a
#   compact non-error SSL logfile on a virtual host basis.
# Stroom Change: Start - Change ssl_request log to use our BlackBox format
# CustomLog logs/ssl_request_log \
#           "%t %h %{SSL_PROTOCOL}x %{SSL_CIPHER}x \"%r\" %b"
CustomLog logs/ssl_request_log blackboxSSLUser
# Stroom Change: End

</VirtualHost>
```

Now copy these two files to the other nodes in the cluster, not forgetting to backup the other node's original files. That is, the files
- /var/www/html/index.html
- /etc/httpd/conf.d/mod_jk.conf
- /etc/httpd/conf/httpd.conf
- /etc/httpd/conf.d/ssl.conf

are to be the same on all nodes. Only the workers.properties file change.

Now tidy up the SELinux context for access on all nodes and files via the commands
```bash
setsebool -P httpd_enable_homedirs on
setsebool -P httpd_can_network_connect on
chcon --reference /etc/httpd/conf.d/README /etc/httpd/conf.d/mod_jk.conf
chcon --reference /etc/httpd/conf/magic /etc/httpd/conf/workers.properties
```

We also enable both http and https services via the firewall on all nodes. If you don't want to present a http access point, then don't enable it in the firewall
setting. This is done with
```bash
firewall-cmd --zone=public --add-service=http --permanent
firewall-cmd --zone=public --add-service=https --permanent
firewall-cmd --reload
firewall-cmd --zone=public --list-all
```

Finally enable then start the httpd service, correcting any errors. It should be noted that on any errors, the suggestion of a systemctl status or viewing the journal are good, but most errors have better information in the httpd error logs found in `/var/log/httpd/`.
```bash
systemctl enable httpd.service
systemctl start httpd.service
```

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

### Test posting data
You can test the data posting service with the command
```bash
curl -k --data-binary @/etc/group "https://stroomp.strmdev00.org/stroom/datafeed" -H "Feed:TEST-FEED-V1_0" -H "System:EXAMPLE_SYSTEM" -H "Environment:EXAMPLE_ENVIRONMENT"
```
which *WILL* result in an error as we have not configured Stroom as yet. The error should look like
```
<html><head><title>Apache Tomcat/7.0.53 - Error report</title><style><!--H1 {font-family:Tahoma,Arial,sans-serif;color:white;background-color:#525D76;font-size:22px;} H2 {font-family:Tahoma,Arial,sans-serif;color:white;background-color:#525D76;font-size:16px;} H3 {font-family:Tahoma,Arial,sans-serif;color:white;background-color:#525D76;font-size:14px;} BODY {font-family:Tahoma,Arial,sans-serif;color:black;background-color:white;} B {font-family:Tahoma,Arial,sans-serif;color:white;background-color:#525D76;} P {font-family:Tahoma,Arial,sans-serif;background:white;color:black;font-size:12px;}A {color : black;}A.name {color : black;}HR {color : #525D76;}--></style> </head><body><h1>HTTP Status 406 - Stroom Status 110 - Feed is not set to receive data - </h1><HR size="1" noshade="noshade"><p><b>type</b> Status report</p><p><b>message</b> <u>Stroom Status 110 - Feed is not set to receive data - </u></p><p><b>description</b> <u>The resource identified by this request is only capable of generating responses with characteristics not acceptable according to the request "accept" headers.</u></p><HR size="1" noshade="noshade"><h3>Apache Tomcat/7.0.53</h3></body></html>
```

If you view the Stroom proxy log, `~/stroom-proxy/instance/logs/stroom.log`, on both processing nodes, you will see on one node, the _datafeed.DataFeedRequestHandler_ events running under, in this case, the _ajp-apr-9009-exec-1_ thread indicating the failure
```
...
2017-01-03T03:35:47.366Z WARN  [ajp-apr-9009-exec-1] datafeed.DataFeedRequestHandler (DataFeedRequestHandler.java:131) - "handleException()","Environment=EXAMPLE_ENVIRONMENT","Expect=100-continue","Feed=TEST-FEED-V1_0","GUID=39960cf9-e50b-4ae8-a5f2-449ee670d2eb","ReceivedTime=2017-01-03T03:35:46.915Z","RemoteAddress=192.168.2.220","RemoteHost=192.168.2.220","System=EXAMPLE_SYSTEM","accept=*/*","content-length=1051","content-type=application/x-www-form-urlencoded","host=stroomp.strmdev00.org","user-agent=curl/7.19.7 (x86_64-redhat-linux-gnu) libcurl/7.19.7 NSS/3.21 Basic ECC zlib/1.2.3 libidn/1.18 libssh2/1.4.2","Stroom Status 110 - Feed is not set to receive data"
2017-01-03T03:35:47.367Z ERROR [ajp-apr-9009-exec-1] zip.StroomStreamException (StroomStreamException.java:131) - sendErrorResponse() - 406 Stroom Status 110 - Feed is not set to receive data - 
2017-01-03T03:35:47.368Z INFO  [ajp-apr-9009-exec-1] datafeed.DataFeedRequestHandler$1 (DataFeedRequestHandler.java:104) - "doPost() - Took 478 ms to process (concurrentRequestCount=1) 406","Environment=EXAMPLE_ENVIRONMENT","Expect=100-continue","Feed=TEST-FEED-V1_0","GUID=39960cf9-e50b-4ae8-a5f2-449ee670d2eb","ReceivedTime=2017-01-03T03:35:46.915Z","RemoteAddress=192.168.2.220","RemoteHost=192.168.2.220","System=EXAMPLE_SYSTEM","accept=*/*","content-length=1051","content-type=application/x-www-form-urlencoded","host=stroomp.strmdev00.org","user-agent=curl/7.19.7 (x86_64-redhat-linux-gnu) libcurl/7.19.7 NSS/3.21 Basic ECC zlib/1.2.3 libidn/1.18 libssh2/1.4.2"
...
```

Further, if you execute the data posting command (`curl`) multiple times, you will see the loadbalancer working in that, the above WARN/ERROR/INFO logs will swap between the proxy services (i.e. first error will be in stroomp00.strmdev00.org's proxy log file, then second on stroomp01.strmdev00.org's proxy log file, then back to stroomp00.strmdev00.org and so on).

### Test User Interface availability
__NOTE:__ To attempt the following, see the _HOWTO_ [Stroom User Interface - Initial Configuration](StroomHowTo-1.60-a.md "Initial Configuration via User Interface").

To further test that this has all worked, attempt to access the user interface via a `Chrome` browser using the URL
`https://stroomp.strmdev00.org` which should redirect you to `https://stroomp.strmdev00.org/stroom`. If you have personal certificates loaded in your Chrome, you may be asked which certificate to use to authenticate yourself to `stroomp.strmdev00.org:443`. Further, if you followed the above certificate creation process (i.e. self-signed), then you will see ERR_CERT_AUTHORITY_INVALID errors and you will need to click on the `ADVANCED` link to see
```
This server could not prove that it is stroomp.strmdev00.org; its security
certificate is not trusted by your computer's operating system. This may be caused
by a mis-configuration or an attacker intercepting your connection.
Learn more.

Proceed to stroomp.strmdev00.org (unsafe)
```
If you click on the __Proceed to stroomp.strmdev00.org (unsafe)__ hyper-link you will be presented with the standard Stroom UI login page.

You should login as the user `admin` with the default password `admin`. At this point configure both the nodes Cluster urls and the storage volumes. The cluster urls should be `http://stroomp00.strmdev00.org:8080/stroom/clustercall.rpc` and `http://stroomp01.strmdev00.org:8080/stroom/clustercall.rpc`.
After setting the cluster urls you will see a Ping response from both nodes in the Nodes tab in the Stroom UI (where you just set the URLs) and the `server.UpdateClusterStateTaskHandler` warnings will disappear from the Stroom application log files on both hosts.
