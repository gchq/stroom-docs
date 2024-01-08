---
title: "Database Installation"
linkTitle: "Database Installation"
#weight:
date: 2021-07-12
tags: 
  - database
  - installation
description: >
  This HOWTO describes the installation of the Stroom databases.
---

Following this HOWTO will produce a simple, minimally secured database deployment. In a production environment consideration needs to be made for redundancy, better security, data-store location, increased memory usage, and the like.

Stroom has two databases. The first, `stroom`, is used for management of Stroom itself and the second, `statistics` is used for the Stroom Statistics capability. There are many ways to deploy these two databases. One could
- have a single database instance and serve both databases from it
- have two database instances on the same server and serve one database per instance
- have two separate nodes, each with it's own database instance
- the list goes on.

In this HOWTO, we describe the deployment of two database instances on the one node, each serving a single database. We provide example deployments using either the {{< external-link "MariaDB" "https://mariadb.com" >}} or {{< external-link "MySQL Community" "https://www.mysql.com/products/community/" >}} versions of MySQL.

## Assumptions
- we are installing the MariaDB or MySQL Community RDBMS software.
- the primary database node is 'stroomdb0.strmdev00.org'.
- installation is on a fully patched minimal Centos 7.3 instance.
- we are installing BOTH databases (`stroom` and `statistics`) on the same node - 'stroomdb0.stromdev00.org' but with two distinct database engines. The first database will communicate on port `3307` and the second on `3308`.
- we are deploying with SELinux in enforcing mode.
- any scripts or commands that should run are in code blocks and are designed to allow the user to cut then paste the commands onto their systems.
- in this document, when a textual screen capture is documented, data entry is identified by the data surrounded by '<__' '__>' . This excludes enter/return presses.

## Installation of Software
### MariaDB Server Installation
As MariaDB is directly supported by Centos 7, we simply install the database server software and SELinux policy files, as per
```bash
sudo yum -y install policycoreutils-python mariadb-server
```
### MySQL Community Server Installation
As MySQL is not directly supported by Centos 7, we need to install it's repository files prior to installation.
We get the current MySQL Community release repository rpm and validate it's MD5 checksum against the published value found on the {{< external-link "MySQL Yum Repository" "https://dev.mysql.com/downloads/repo/yum" >}} site.

```bash
wget https://repo.mysql.com/mysql57-community-release-el7.rpm
md5sum mysql57-community-release-el7.rpm
```

On correct validation of the MD5 checksum, we install the repository files via
```bash
sudo yum -y localinstall mysql57-community-release-el7.rpm
```

**NOTE:** Stroom currently does not support the latest production MySQL version - 5.7. You will need to install MySQL Version 5.6.

Now since we must use MySQL Version 5.6 you will need to edit the MySQL repo file `/etc/yum.repos.d/mysql-community.repo` to
disable the `mysql57-community` channel and enable the `mysql56-community` channel. We start by, backing up the repo file with
```bash
sudo cp /etc/yum.repos.d/mysql-community.repo /etc/yum.repos.d/mysql-community.repo.ORIG
```

Then edit the file to change

```toml
...
# Enable to use MySQL 5.6
[mysql56-community]
name=MySQL 5.6 Community Server
baseurl=http://repo.mysql.com/yum/mysql-5.6-community/el/7/$basearch/
enabled=0
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-mysql

[mysql57-community]
name=MySQL 5.7 Community Server
baseurl=http://repo.mysql.com/yum/mysql-5.7-community/el/7/$basearch/
enabled=1
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-mysql
...
```

to become

```toml
...
# Enable to use MySQL 5.6
[mysql56-community]
name=MySQL 5.6 Community Server
baseurl=http://repo.mysql.com/yum/mysql-5.6-community/el/7/$basearch/
enabled=1
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-mysql

[mysql57-community]
name=MySQL 5.7 Community Server
baseurl=http://repo.mysql.com/yum/mysql-5.7-community/el/7/$basearch/
enabled=0
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-mysql
...
```

Next we install server software and SELinux policy files, as per
```bash
sudo yum -y install policycoreutils-python mysql-community-server
```

## Preparing the Database Deployment

### MariaDB Variant

#### Create and instantiate both database instances

To set up two MariaDB database instances on the one node, we will use `mysql_multi` and systemd service templates. The `mysql_multi` utility is a capability that manages multiple MariaDB databases on the same node and systemd service templates manage multiple services from one configuration file.  A systemd service template is unique in that it has an `@` character before the `.service` suffix.

To use this multiple-instance capability, we need to create two data directories for each database instance and also replace the main MariaDB configuration file, `/etc/my.cnf`, with one that includes configuration of key options for each instance. We will name our instances, `mysqld0` and `mysqld1`. We will also create specific log files for each instance.

We will use the directories, `/var/lib/mysql-mysqld0` and `/var/lib/mysql-mysqld1` for the data directories and `/var/log/mariadb/mysql-mysqld0.log` and `/var/log/mariadb/mysql-mysqld1.log` for the log files. Note you should modify /etc/logrotate.d/mariadb to manage these log files. Note also, we need to set the appropriate SELinux file contexts on the created directories and any files.

We create the data directories and log files and set their respective SELinux contexts via

```bash
sudo mkdir /var/lib/mysql-mysqld0
sudo chown mysql:mysql /var/lib/mysql-mysqld0
sudo semanage fcontext -a -t mysqld_db_t "/var/lib/mysql-mysqld0(/.*)?"
sudo restorecon -Rv /var/lib/mysql-mysqld0

sudo touch /var/log/mariadb/mysql-mysqld0.log
sudo chown mysql:mysql /var/log/mariadb/mysql-mysqld0.log
sudo chcon --reference=/var/log/mariadb/mariadb.log /var/log/mariadb/mysql-mysqld0.log

sudo mkdir /var/lib/mysql-mysqld1
sudo chown mysql:mysql /var/lib/mysql-mysqld1
sudo semanage fcontext -a -t mysqld_db_t "/var/lib/mysql-mysqld1(/.*)?"
sudo restorecon -Rv /var/lib/mysql-mysqld1

sudo touch /var/log/mariadb/mysql-mysqld1.log
sudo chown mysql:mysql /var/log/mariadb/mysql-mysqld1.log
sudo chcon --reference=/var/log/mariadb/mariadb.log /var/log/mariadb/mysql-mysqld1.log
```

We now initialise the our two database data directories via

```bash
sudo mysql_install_db --user=mysql --datadir=/var/lib/mysql-mysqld0
sudo mysql_install_db --user=mysql --datadir=/var/lib/mysql-mysqld1
```

We now replace the  MySQL configuration file to set the options for each instance. Note that we will serve `mysqld0` and `mysqld1` via TCP ports `3307` and `3308` respectively. First backup the existing configuration file with

```bash
sudo cp /etc/my.cnf /etc/my.cnf.ORIG
```
then setup `/etc/my.cnf` as per

```bash
sudo bash
F=/etc/my.cnf
printf '[mysqld_multi]\n' > ${F}
printf 'mysqld = /usr/bin/mysqld_safe --basedir=/usr\n' >> ${F}
printf '\n' >> ${F}
printf '[mysqld0]\n' >> ${F}
printf 'port=3307\n' >> ${F}
printf 'mysqld = /usr/bin/mysqld_safe --basedir=/usr\n' >> ${F}
printf 'datadir=/var/lib/mysql-mysqld0/\n' >> ${F}
printf 'socket=/var/lib/mysql-mysqld0/mysql.sock\n' >> ${F}
printf 'pid-file=/var/run/mariadb/mysql-mysqld0.pid\n' >> ${F}
printf '\n' >> ${F}
printf 'log-error=/var/log/mariadb/mysql-mysqld0.log\n' >> ${F}
printf '\n' >> ${F}
printf '# Disabling symbolic-links is recommended to prevent assorted security\n' >> ${F}
printf '# risks\n' >> ${F}
printf 'symbolic-links=0\n' >> ${F}
printf '\n' >> ${F}
printf '[mysqld1]\n' >> ${F}
printf 'mysqld = /usr/bin/mysqld_safe --basedir=/usr\n' >> ${F}
printf 'port=3308\n' >> ${F}
printf 'datadir=/var/lib/mysql-mysqld1/\n' >> ${F}
printf 'socket=/var/lib/mysql-mysqld1/mysql.sock\n' >> ${F}
printf 'pid-file=/var/run/mariadb/mysql-mysqld1.pid\n' >> ${F}
printf '\n' >> ${F}
printf 'log-error=/var/log/mariadb/mysql-mysqld1.log\n' >> ${F}
printf '\n' >> ${F}
printf '# Disabling symbolic-links is recommended to prevent assorted security risks\n' >> ${F}
printf 'symbolic-links=0\n' >> ${F}
exit # To exit the root shell
```
We also need to associate the ports with the `mysqld_port_t` SELinux context as per
```bash
sudo semanage port -a -t mysqld_port_t -p tcp 3307
sudo semanage port -a -t mysqld_port_t -p tcp 3308
```
We next create the systemd service template as per
```bash
sudo bash
F=/etc/systemd/system/mysqld@.service

printf '# Install in /etc/systemd/system\n' > ${F}
printf '# Enable via systemctl enable mysqld@0 or systemctl enable mysqld@1\n' >> ${F}
printf '[Unit]\n' >> ${F}
printf 'Description=MySQL Multi Server for instance %%i\n' >> ${F}
printf 'After=syslog.target\n' >> ${F}
printf 'After=network.target\n' >> ${F}
printf '\n' >> ${F}
printf '[Service]\n' >> ${F}
printf 'User=mysql\n' >> ${F}
printf 'Group=mysql\n' >> ${F}
printf 'Type=forking\n' >> ${F}
printf 'ExecStart=/usr/bin/mysqld_multi start %%i\n' >> ${F}
printf 'ExecStop=/usr/bin/mysqld_multi stop %%i\n' >> ${F}
printf 'Restart=always\n' >> ${F}
printf 'PrivateTmp=true\n' >> ${F}
printf '\n' >> ${F}
printf '[Install]\n' >> ${F}
printf 'WantedBy=multi-user.target\n' >> ${F}
chmod 644 ${F}
exit; # to exit the root shell
```

We next enable and start both instances via
```bash
sudo systemctl enable mysqld@0
sudo systemctl enable mysqld@1
sudo systemctl start mysqld@0
sudo systemctl start mysqld@1
```
At this we should have both instances running. One should check each instance's log file for any errors.

#### Secure each database instance
We secure each database engine by running the `mysql_secure_installation` script. One should accept all defaults, which means the
only entry (aside from pressing returns) is the administrator (root) database password. Make a note of the password you use. In this case
we will use `Stroom5User@`.
The utility `mysql_secure_installation` expects to find the Linux socket file to access the database it's securing at `/var/lib/mysql/mysql.sock`.
Since we have used other locations, we temporarily link the real socket file to `/var/lib/mysql/mysql.sock` for each invocation of the
utility. Thus we execute

```bash
sudo ln /var/lib/mysql-mysqld0/mysql.sock /var/lib/mysql/mysql.sock
sudo mysql_secure_installation
```
to see

```text
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
New password: <__ Stroom5User@ __>
Re-enter new password: <__ Stroom5User@ __>
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

then we execute

```bash
sudo rm /var/lib/mysql/mysql.sock
sudo ln /var/lib/mysql-mysqld1/mysql.sock /var/lib/mysql/mysql.sock
sudo mysql_secure_installation
sudo rm /var/lib/mysql/mysql.sock
```
and process as before (for when running mysql_secure_installation). At this both database instances should be secure.

### MySQL Community Variant

#### Create and instantiate both database instances

To set up two MySQL database instances on the one node, we will use `mysql_multi` and systemd service templates. The `mysql_multi` utility is a capability that manages multiple MySQL databases on the same node and systemd service templates manage multiple services from one configuration file.  A systemd service template is unique in that it has an `@` character before the `.service` suffix.

To use this multiple-instance capability, we need to create two data directories for each database instance and also replace the main MySQL configuration file, `/etc/my.cnf`, with one that includes configuration of key options for each instance. We will name our instances, `mysqld0` and `mysqld1`. We will also create specific log files for each instance.

We will use the directories, `/var/lib/mysql-mysqld0` and `/var/lib/mysql-mysqld1` for the data directories and `/var/log/mysql-mysqld0.log` and `/var/log/mysql-mysqld1.log` for the log directories. Note you should modify /etc/logrotate.d/mysql to manage these log files. Note also, we need to set the appropriate SELinux file context on the created directories and files.

```bash
sudo mkdir /var/lib/mysql-mysqld0
sudo chown mysql:mysql /var/lib/mysql-mysqld0
sudo semanage fcontext -a -t mysqld_db_t "/var/lib/mysql-mysqld0(/.*)?"
sudo restorecon -Rv /var/lib/mysql-mysqld0

sudo touch /var/log/mysql-mysqld0.log
sudo chown mysql:mysql /var/log/mysql-mysqld0.log
sudo chcon --reference=/var/log/mysqld.log /var/log/mysql-mysqld0.log

sudo mkdir /var/lib/mysql-mysqld1
sudo chown mysql:mysql /var/lib/mysql-mysqld1 
sudo semanage fcontext -a -t mysqld_db_t "/var/lib/mysql-mysqld1(/.*)?"
sudo restorecon -Rv /var/lib/mysql-mysqld1

sudo touch /var/log/mysql-mysqld1.log
sudo chown mysql:mysql /var/log/mysql-mysqld1.log
sudo chcon --reference=/var/log/mysqld.log /var/log/mysql-mysqld1.log
```

We now initialise the our two database data directories via

```bash
sudo mysql_install_db --user=mysql --datadir=/var/lib/mysql-mysqld0
sudo mysql_install_db --user=mysql --datadir=/var/lib/mysql-mysqld1
```

Disable the default database via

```bash
sudo systemctl disable mysqld
```

We now modify the  MySQL configuration file to set the options for each instance. Note that we will serve `mysqld0` and `mysqld1` via TCP ports `3307` and `3308` respectively.  First backup the existing configuration file with

```bash
sudo cp /etc/my.cnf /etc/my.cnf.ORIG
```
then setup `/etc/my.cnf` as per

```bash
sudo bash
F=/etc/my.cnf
printf '[mysqld_multi]\n' > ${F}
printf 'mysqld = /usr/bin/mysqld_safe --basedir=/usr\n' >> ${F}
printf '\n' >> ${F}
printf '[mysqld0]\n' >> ${F}
printf 'port=3307\n' >> ${F}
printf 'mysqld = /usr/bin/mysqld_safe --basedir=/usr\n' >> ${F}
printf 'datadir=/var/lib/mysql-mysqld0/\n' >> ${F}
printf 'socket=/var/lib/mysql-mysqld0/mysql.sock\n' >> ${F}
printf 'pid-file=/var/run/mysqld/mysql-mysqld0.pid\n' >> ${F}
printf '\n' >> ${F}
printf 'log-error=/var/log/mysql-mysqld0.log\n' >> ${F}
printf '\n' >> ${F}
printf '# Disabling symbolic-links is recommended to prevent assorted security\n' >> ${F}
printf '# risks\n' >> ${F}
printf 'symbolic-links=0\n' >> ${F}
printf '\n' >> ${F}
printf '[mysqld1]\n' >> ${F}
printf 'mysqld = /usr/bin/mysqld_safe --basedir=/usr\n' >> ${F}
printf 'port=3308\n' >> ${F}
printf 'datadir=/var/lib/mysql-mysqld1/\n' >> ${F}
printf 'socket=/var/lib/mysql-mysqld1/mysql.sock\n' >> ${F}
printf 'pid-file=/var/run/mysqld/mysql-mysqld1.pid\n' >> ${F}
printf '\n' >> ${F}
printf 'log-error=/var/log/mysql-mysqld1.log\n' >> ${F}
printf '\n' >> ${F}
printf '# Disabling symbolic-links is recommended to prevent assorted security risks\n' >> ${F}
printf 'symbolic-links=0\n' >> ${F}
exit # To exit the root shell
```

We also need to associate the ports with the `mysqld_port_t` SELinux context as per

```bash
sudo semanage port -a -t mysqld_port_t -p tcp 3307
sudo semanage port -a -t mysqld_port_t -p tcp 3308
```

We next create the systemd service template as per

```bash
sudo bash
F=/etc/systemd/system/mysqld@.service

printf '# Install in /etc/systemd/system\n' > ${F}
printf '# Enable via systemctl enable mysqld@0 or systemctl enable mysqld@1\n' >> ${F}
printf '[Unit]\n' >> ${F}
printf 'Description=MySQL Multi Server for instance %%i\n' >> ${F}
printf 'After=syslog.target\n' >> ${F}
printf 'After=network.target\n' >> ${F}
printf '\n' >> ${F}
printf '[Service]\n' >> ${F}
printf 'User=mysql\n' >> ${F}
printf 'Group=mysql\n' >> ${F}
printf 'Type=forking\n' >> ${F}
printf 'ExecStart=/usr/bin/mysqld_multi start %%i\n' >> ${F}
printf 'ExecStop=/usr/bin/mysqld_multi stop %%i\n' >> ${F}
printf 'Restart=always\n' >> ${F}
printf 'PrivateTmp=true\n' >> ${F}
printf '\n' >> ${F}
printf '[Install]\n' >> ${F}
printf 'WantedBy=multi-user.target\n' >> ${F}
chmod 644 ${F}
exit; # to exit the root shell
```

We next enable and start both instances via

```bash
sudo systemctl enable mysqld@0
sudo systemctl enable mysqld@1
sudo systemctl start mysqld@0
sudo systemctl start mysqld@1
```

At this we should have both instances running. One should check each instance's log file for any errors.

#### Secure each database instance

We secure each database engine by running the `mysql_secure_installation` script. One should accept all defaults, which means the
only entry (aside from pressing returns) is the administrator (root) database password. Make a note of the password you use. In this case
we will use `Stroom5User@`.
The utility `mysql_secure_installation` expects to find the Linux socket file to access the database it's securing at `/var/lib/mysql/mysql.sock`.
Since we have used other locations, we temporarily link the real socket file to `/var/lib/mysql/mysql.sock` for each invocation of the
utility. Thus we execute

```bash
sudo ln /var/lib/mysql-mysqld0/mysql.sock /var/lib/mysql/mysql.sock
sudo mysql_secure_installation
```

to see

```text
NOTE: RUNNING ALL PARTS OF THIS SCRIPT IS RECOMMENDED FOR ALL MySQL
      SERVERS IN PRODUCTION USE!  PLEASE READ EACH STEP CAREFULLY!

In order to log into MySQL to secure it, we'll need the current
password for the root user.  If you've just installed MySQL, and
you haven't set the root password yet, the password will be blank,
so you should just press enter here.

Enter current password for root (enter for none): 
OK, successfully used password, moving on...

Setting the root password ensures that nobody can log into the MySQL
root user without the proper authorisation.

Set root password? [Y/n] y
New password: <__ Stroom5User@ __>
Re-enter new password: <__ Stroom5User@ __>
Password updated successfully!
Reloading privilege tables..
 ... Success!


By default, a MySQL installation has an anonymous user, allowing anyone
to log into MySQL without having to have a user account created for
them.  This is intended only for testing, and to make the installation
go a bit smoother.  You should remove them before moving into a
production environment.

Remove anonymous users? [Y/n] 
 ... Success!

Normally, root should only be allowed to connect from 'localhost'.  This
ensures that someone cannot guess at the root password from the network.

Disallow root login remotely? [Y/n] 
 ... Success!

By default, MySQL comes with a database named 'test' that anyone can
access.  This is also intended only for testing, and should be removed
before moving into a production environment.

Remove test database and access to it? [Y/n] 
 - Dropping test database...
ERROR 1008 (HY000) at line 1: Can't drop database 'test'; database doesn't exist
 ... Failed!  Not critical, keep moving...
 - Removing privileges on test database...
 ... Success!

Reloading the privilege tables will ensure that all changes made so far
will take effect immediately.

Reload privilege tables now? [Y/n] 
 ... Success!




All done!  If you've completed all of the above steps, your MySQL
installation should now be secure.

Thanks for using MySQL!


Cleaning up...
```

then we execute

```bash
sudo rm /var/lib/mysql/mysql.sock
sudo ln /var/lib/mysql-mysqld1/mysql.sock /var/lib/mysql/mysql.sock
sudo mysql_secure_installation
sudo rm /var/lib/mysql/mysql.sock
```
and process as before (for when running mysql_secure_installation). At this both database instances should be secure.

## Create the Databases and Enable access by the Stroom processing users

We now create the `stroom` database within the first instance, `mysqld0` and the `statistics` database within the second
instance `mysqld1`. It does not matter which database variant used as all commands are the same for both.

As well as creating the databases, we also need to establish the Stroom processing users
that the Stroom processing nodes will use to access each database.
For the `stroom` database, we will use the database user `stroomuser` with a password of `Stroompassword1@` and for the `statistics` database, we will use the database user `stroomstats` with a password of `Stroompassword2@`. One identifies a processing user as `<user>@<host>` on a `grant` SQL command.

In the `stroom` database instance, we will grant access for

- `stroomuser@localhost` for local access for maintenance etc.
- `stroomuser@stroomp00.strmdev00.org` for access by processing node `stroomp00.strmdev00.org`
- `stroomuser@stroomp01.strmdev00.org` for access by processing node `stroomp01.strmdev00.org`

and in the `statistics` database instance, we will grant access for

- `stroomstats@localhost` for local access for maintenance etc.
- `stroomstats@stroomp00.strmdev00.org` for access by processing node `stroomp00.strmdev00.org`
- `stroomstats@stroomp01.strmdev00.org` for access by processing node `stroomp01.strmdev00.org`

Thus for the `stroom` database we execute

```bash
mysql --user=root --port=3307 --socket=/var/lib/mysql-mysqld0/mysql.sock --password
```
and on entering the administrator's password, we arrive at the `MariaDB [(none)]>` or `mysql>` prompt. At this we create the database with

```sql
create database stroom;
```

and then to establish the users, we execute

```sql
grant all privileges on stroom.* to stroomuser@localhost identified by 'Stroompassword1@';
grant all privileges on stroom.* to stroomuser@stroomp00.strmdev00.org identified by 'Stroompassword1@';
grant all privileges on stroom.* to stroomuser@stroomp01.strmdev00.org identified by 'Stroompassword1@';
```
then

```sql
quit;
```

to exit.

And for the `statistics` database 

```bash
mysql --user=root --port=3308 --socket=/var/lib/mysql-mysqld1/mysql.sock --password
```

with

```sql
create database statistics;
```

and then to establish the users, we execute

```sql
grant all privileges on statistics.* to stroomstats@localhost identified by 'Stroompassword2@';
grant all privileges on statistics.* to stroomstats@stroomp00.strmdev00.org identified by 'Stroompassword2@';
grant all privileges on statistics.* to stroomstats@stroomp01.strmdev00.org identified by 'Stroompassword2@';
```
then

```sql
quit;
```

to exit.

Clearly if we need to add more processing nodes, additional `grant` commands would be used. Further, if we were installing the databases in a single node Stroom environment, we would just have the first two pairs of `grants`.

## Configure Firewall

Next we need to modify our firewall to allow remote access to our databases which listens on ports 3307 and 3308.
The simplest way to achieve this is with the commands

```bash
sudo firewall-cmd --zone=public --add-port=3307/tcp --permanent
sudo firewall-cmd --zone=public --add-port=3308/tcp --permanent
sudo firewall-cmd --reload
sudo firewall-cmd --zone=public --list-all
```

{{% note %}}
That this allows ANY node to connect to your databases. You should give consideration to restricting this to only allowing processing node access.
{{% /note %}}

### Debugging of Mariadb for Stroom

If there is a need to debug the Mariadb database and Stroom interaction, one can turn on auditing for the Mariadb service.
To do so, log onto the relevant database as the administrative user as per

```bash
mysql --user=root --port=3307 --socket=/var/lib/mysql-mysqld0/mysql.sock --password
or
mysql --user=root --port=3308 --socket=/var/lib/mysql-mysqld1/mysql.sock --password
```

and at the `MariaDB [(none)]> ` prompt enter

```bash
install plugin server_audit SONAME 'server_audit';
set global server_audit_file_path='/var/log/mariadb/mysqld-mysqld0_server_audit.log';
or
set global server_audit_file_path='/var/log/mariadb/mysqld-mysqld1_server_audit.log';
set global server_audit_logging=ON;
set global server_audit_file_rotate_size=10485760;
install plugin SQL_ERROR_LOG soname 'sql_errlog';
quit;
```

The above will generate two log files, 

- `/var/log/mariadb/mysqld-mysqld0_server_audit.log` or `/var/log/mariadb/mysqld-mysqld1_server_audit.log` which records all commands the respective databases run. We have configured the log file will rotate at 10MB in size.
- `/var/lib/mysql-mysqld0/sql_errors.log` or `/var/lib/mysql-mysqld1/sql_errors.log` which records all erroneous SQL commands. This log file will rotate at 10MB in size. Note we cannot set this filename via the UI, but it will be appear in the data directory.

All files will, by default, generate up to 9 rotated files.

If you wish to rotate a log file manually, log into the database as the administrative user and execute either

- `set global server_audit_file_rotate_now=1;` to rotate the audit log file
- `set global sql_error_log_rotate=1;` to rotate the sql_errlog log file

### Initial Database Access

It should be noted that if you monitor the sql_errors.log log file on a new Stooom deployment, when the Stoom Application first starts, it's initial access to the `stroom` database will result in the following attempted sql statements.

```sql
2017-04-16 16:24:50 stroomuser[stroomuser] @ stroomp00.strmdev00.org [192.168.2.126] ERROR 1146: Table 'stroom.schema_version' doesn't exist : SELECT version FROM schema_version ORDER BY installed_rank DESC
2017-04-16 16:24:50 stroomuser[stroomuser] @ stroomp00.strmdev00.org [192.168.2.126] ERROR 1146: Table 'stroom.STROOM_VER' doesn't exist : SELECT VER_MAJ, VER_MIN, VER_PAT FROM STROOM_VER ORDER BY VER_MAJ DESC, VER_MIN DESC, VER_PAT DESC LIMIT 1
2017-04-16 16:24:50 stroomuser[stroomuser] @ stroomp00.strmdev00.org [192.168.2.126] ERROR 1146: Table 'stroom.FD' doesn't exist : SELECT ID FROM FD LIMIT 1
2017-04-16 16:24:50 stroomuser[stroomuser] @ stroomp00.strmdev00.org [192.168.2.126] ERROR 1146: Table 'stroom.FEED' doesn't exist : SELECT ID FROM FEED LIMIT 1
```

After this access the application will realise the database does not exist and it will initialise the database.

In the case of the `statistics` database you may note the following attempted access

```sql
2017-04-16 16:25:09 stroomstats[stroomstats] @ stroomp00.strmdev00.org [192.168.2.126] ERROR 1146: Table 'statistics.schema_version' doesn't exist : SELECT version FROM schema_version ORDER BY installed_rank DESC 
```

Again, at this point the application will initialise this database.
