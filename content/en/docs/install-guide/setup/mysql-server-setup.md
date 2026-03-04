---
title: "MySQL Setup"
linkTitle: "MySQL Setup"
weight: 10
date: 2021-08-20
tags:
  - TODO
description: >
  
---

{{% todo %}}
This needs updating to MySQL 8. Stroom v7 requires MySQL 8.
{{% /todo %}}


## Prerequisites

- MySQL 8.0.x server installed (e.g. yum install mysql-server)
- Processing User Setup

A single MySQL database is required for each Stroom instance.
You do not need to setup a MySQL instance per node in your cluster.

## Check Database installed and running

{{< command-line "root" "stroomdb" >}}
/sbin/chkconfig --list mysqld
(out)mysqld          0:off   1:off   2:on    3:on    4:on    5:on    6:off
mysql --user=root -p
{{< /command-line >}}

{{< sql-shell >}}
(out)Enter password:
(out)Welcome to the MySQL monitor.  Commands end with ; or \g.
(out)...
quit      
{{< /sql-shell >}}

The following commands can be used to auto start mysql if required:

{{< command-line "root" "stroomdb" >}}
/sbin/chkconfig –level 345 mysqld on
/sbin/service httpd start
{{</ command-line >}}


## Overview

MySQL configuration can be simple to complex depending on your requirements.

For a very simple configuration you simply need an out-of-the-box mysql install and create a database user account.

Things get more complicated when considering:

-	Security
-	Replication
-	Tuning memory usage
-	Running Stroom Stats in a different database to Stroom
-	Performance Monitoring

## Simple Install

Ensure the database is running, create the database and access to it

{{< command-line "stroomuser" "host" >}}
mysql --user=root
{{< /command-line >}}

{{< sql-shell >}}
(out)Welcome to the MySQL monitor.  Commands end with ; or \g.
(out)...
create database stroom;
(out)Query OK, 1 row affected (0.02 sec)

grant all privileges on stroom.* to 'stroomuser'@'host' identified by 'password';
(out)Query OK, 0 rows affected (0.00 sec)

create database stroom_stats;
(out)Query OK, 1 row affected (0.02 sec)

grant all privileges on stroom_stats.* to 'stroomuser'@'host' identified by 'password';
(out)Query OK, 0 rows affected (0.00 sec)

flush privileges;
(out)Query OK, 0 rows affected (0.00 sec)
{{< /sql-shell >}}

## Advanced Security

It is recommended to run /usr/bin/mysql_secure_installation to remove test database and accounts.

./stroom-setup/mysql_grant.sh is a utility script that creates accounts for you to use within a
 cluster (or single node setup). Run to see the options:

{{< command-line "stroomuser" "host" >}}
./mysql_grant.sh
(out)usage : --name=<instance name (defaults to my for /etc/my.cnf)>
(out)        --user=<the stroom user for the db>
(out)        --password=<the stroom password for the db>
(out)        --cluster=<the file with a line per node in the cluster>
(out)--user=<db user> Must be set
{{< /command-line >}}

N.B. name is used when multiple mysql instances are setup (see below).

You need to create a file cluster.txt with a line for each member of your cluster
(or single line in the case of a one node Stroom install).
Then run the utility script to lock down the server access.

{{< command-line "stroomuser" "localhost" >}}
hostname >> cluster.txt
./stroom-setup/mysql_grant.sh --name=mysql56_dev --user=stroomuser --password= --cluster=cluster.txt
(out)Enter root mysql password :
(out)--------------
(out)flush privileges
(out)--------------
(out)
(out)--------------
(out)delete from mysql.user where user = 'stroomuser'
(out)--------------
(out)...
(out)...
(out)...
(out)--------------
(out)flush privileges
(out)--------------
{{</ command-line >}}


## Advanced Install

The below example uses the utility scripts to create 3 custom mysql server instances on 2 servers:

- server1 - stroom (source),
- server2 - stroom (replica), stroom_stats

As root on server1:

{{< command-line >}}
yum install "mysql56-mysql-server"
{{< /command-line >}}

Create the master database:

{{< command-line "root" "node1" >}}
./stroom-setup/mysqld_instance.sh --name=mysqld56_stroom --port=3106 --server=mysqld56 --os=rhel6

(out)--master not set ... assuming master database
(out)Wrote base files in tmp (You need to move them as root).  cp /tmp/mysqld56_stroom /etc/init.d/mysqld56_stroom; cp /tmp/mysqld56_stroom.cnf /etc/mysqld56_stroom.cnf
(out)Run mysql client with mysql --defaults-file=/etc/mysqld56_stroom.cnf

cp /tmp/mysqld56_stroom /etc/init.d/mysqld56_stroom; cp /tmp/mysqld56_stroom.cnf /etc/mysqld56_stroom.cnf
/etc/init.d/mysqld56_stroom start

(out)Initializing MySQL database:  Installing MySQL system tables...
(out)OK
(out)Filling help tables...
(out)...
(out)...
(out)Starting mysql56-mysqld:                                   [  OK  ]
{{< /command-line >}}

Check Start up Settings Correct

{{< command-line "root" "node2" >}}
chkconfig mysqld off
chkconfig mysql56-mysqld off
chkconfig --add mysqld56_stroom
chkconfig mysqld56_stroom on

chkconfig --list | grep mysql
(out)mysql56-mysqld  0:off   1:off   2:off   3:off   4:off   5:off   6:off
(out)mysqld          0:off   1:off   2:off   3:off   4:off   5:off   6:off
(out)mysqld56_stroom    0:off   1:off   2:on    3:on    4:on    5:on    6:off
(out)mysqld56_stats  0:off   1:off   2:on    3:on    4:on    5:on    6:off
{{< /command-line >}}

Create a text file will all members of the cluster:

{{< command-line "root" "node1" >}}
vi cluster.txt

(out)node1.my.org
(out)node2.my.org
(out)node3.my.org
(out)node4.my.org 
{{< /command-line >}}

Create the grants:

{{< command-line "root" "node1" >}}
./stroom-setup/mysql_grant.sh --name=mysqld56_stroom --user=stroomuser --password=password --cluster=cluster.txt
{{< /command-line >}}

As root on server2:

{{< command-line "root" "node2" >}}
yum install "mysql56-mysql-server"


./stroom-setup/mysqld_instance.sh --name=mysqld56_stroom --port=3106 --server=mysqld56 --os=rhel6 --master=node1.my.org --user=stroomuser --password=password

(out)--master set ... assuming slave database
(out)Wrote base files in tmp (You need to move them as root).  cp /tmp/mysqld56_stroom /etc/init.d/mysqld56_stroom; cp /tmp/mysqld56_stroom.cnf /etc/mysqld56_stroom.cnf
(out)Run mysql client with mysql --defaults-file=/etc/mysqld56_stroom.cnf

cp /tmp/mysqld56_stroom /etc/init.d/mysqld56_stroom; cp /tmp/mysqld56_stroom.cnf /etc/mysqld56_stroom.cnf
/etc/init.d/mysqld56_stroom start

(out)Initializing MySQL database:  Installing MySQL system tables...
(out)OK
(out)Filling help tables...
(out)...
(out)...
(out)Starting mysql56-mysqld:                                   [  OK  ]
{{< /command-line >}}

Check Start up Settings Correct

{{< command-line "root" "node2" >}}
chkconfig mysqld off
chkconfig mysql56-mysqld off
chkconfig --add mysqld56_stroom
chkconfig mysqld56_stroom on

chkconfig --list | grep mysql
(out)mysql56-mysqld  0:off   1:off   2:off   3:off   4:off   5:off   6:off
(out)mysqld          0:off   1:off   2:off   3:off   4:off   5:off   6:off
(out)mysqld56_stroom    0:off   1:off   2:on    3:on    4:on    5:on    6:off
{{< /command-line >}}

Create the grants:

{{< command-line "root" "node1" >}}
./stroom-setup/mysql_grant.sh --name=mysqld56_stroom --user=stroomuser --password=password --cluster=cluster.txt
{{< /command-line >}}

Make the slave database start to follow:

{{< command-line "root" "node2" >}}
cat /etc/mysqld56_stroom.cnf | grep "change master"
(out)# change master to MASTER_HOST='node1.my.org', MASTER_PORT=3106, MASTER_USER='stroomuser', MASTER_PASSWORD='password';

mysql --defaults-file=/etc/mysqld56_stroom.cnf

{{< /command-line >}}

{{< sql-shell >}}
change master to MASTER_HOST='node1.my.org', MASTER_PORT=3106, MASTER_USER='stroomuser', MASTER_PASSWORD='password';
start slave; 
{{< /sql-shell >}}

As processing user on server1:

{{< command-line "stroomuser" "node1" >}}
mysql --defaults-file=/etc/mysqld56_stroom.cnf --user=stroomuser --password=password
{{< /command-line >}}

{{< sql-shell >}}
create database stroom;
(out)Query OK, 1 row affected (0.00 sec)

use stroom;
(out)Database changed

create table test (a int);
(out)Query OK, 0 rows affected (0.05 sec)
{{< /sql-shell >}}

As processing user on server2 check server replicating OK:

{{< command-line "stroomuser" "node2" >}}
mysql --defaults-file=/etc/mysqld56_stroom.cnf --user=stroomuser --password=password
{{< /command-line >}}

{{< sql-shell >}}
show create table test;
(out)+-------+----------------------------------------------------------------------------------------+
(out)| Table | Create Table                                                                           |
(out)+-------+----------------------------------------------------------------------------------------+
(out)| test  | CREATE TABLE `test` (`a` int(11) DEFAULT NULL  ) ENGINE=InnoDB DEFAULT CHARSET=latin1  |
(out)+-------+----------------------------------------------------------------------------------------+
(out)1 row in set (0.00 sec)
{{< /sql-shell >}}    

As root on server2:

{{< command-line "root" "node2" >}}
/home/stroomuser/stroom-setup/mysqld_instance.sh --name=mysqld56_stats --port=3206 --server=mysqld56 --os=rhel6 --user=statsuser --password=password
cp /tmp/mysqld56_stats /etc/init.d/mysqld56_stats; cp /tmp/mysqld56_stats.cnf /etc/mysqld56_stats.cnf
/etc/init.d/mysqld56_stats start
chkconfig mysqld56_stats on
{{< /command-line >}}

Create the grants:

{{< command-line "root" "node2" >}}
./stroom-setup/mysql_grant.sh --name=mysqld56_stats --database=stats  --user=stroomstats --password=password --cluster=cluster.txt
{{< /command-line >}}

As processing user create the database:

{{< command-line "stroomuser" "node2" >}}
mysql --defaults-file=/etc/mysqld56_stats.cnf --user=stroomstats --password=password
{{< /command-line >}}

{{< sql-shell >}}
(out)Welcome to the MySQL monitor.  Commands end with ; or \g.
(out)....
create database stats;
(out)Query OK, 1 row affected (0.00 sec)
{{< /sql-shell >}}
