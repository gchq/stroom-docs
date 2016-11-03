# MySQL Setup

## Prerequisites

- MySQL 5.5.y server installed (e.g. yum install mysql-server)
- Processing User Setup

A single MySQL database is required for each Stroom instance.
You do not need to setup a MySQL instance per node in your cluster.

## Check Database installed and running

```bash
[root@stroomdb ~]# /sbin/chkconfig --list mysqld
mysqld          0:off   1:off   2:on    3:on    4:on    5:on    6:off
[root@stroomdb ~]# mysql --user=root -p
Enter password:
Welcome to the MySQL monitor.  Commands end with ; or \g.
...
mysql> quit      
```

The following commands can be used to auto start mysql if required:

```bash
[root@stroomdb ~]# /sbin/chkconfig –level 345 mysqld on
[root@stroomdb ~]# /sbin/service httpd start
```

## Overview

MySQL configuration can be simple to complex depending on your requirements.  
For a very simple configuration you simply need an out-of-the-box mysql 
install and create a database user account.  

Things get more complicated when considering:

-	Security
-	Master Slave Replication
-	Tuning memory usage
-	Running Stroom Stats in a different database to Stroom
-	Performance Monitoring

## Simple Install

Ensure the database is running, create the database and access to it 

```bash
[stroomuser@host stroom-setup]$ mysql --user=root
Welcome to the MySQL monitor.  Commands end with ; or \g.
...

mysql> create database stroom;
Query OK, 1 row affected (0.02 sec)

mysql> grant all privileges on stroom.* to 'stroomuser'@'host' identified by 'password';
Query OK, 0 rows affected (0.00 sec)

mysql> flush privileges;
Query OK, 0 rows affected (0.00 sec)
```

## Advanced Security

It is recommended to run /usr/bin/mysql_secure_installation to remove test database and accounts.

./stroom-setup/mysql_grant.sh is a utility script that creates accounts for you to use within a
 cluster (or single node setup).  Run to see the options:

```bash
[stroomuser@host stroom-setup]$ ./mysql_grant.sh
usage : --name=<instance name (defaults to my for /etc/my.cnf)>
        --user=<the stroom user for the db>
        --password=<the stroom password for the db>
        --cluster=<the file with a line per node in the cluster>
--user=<db user> Must be set
```

N.B. name is used when multiple mysql instances are setup (see below).
 
You need to create a file cluster.txt with a line for each member of your cluster 
(or single line in the case of a one node Stroom install).
Then run the utility script to lock down the server access.

```bash
[stroomuser@host ~]$ hostname >> cluster.txt
[stroomuser@host ~]$ ./stroom-setup/mysql_grant.sh --name=mysql56_dev --user=stroomuser --password= --cluster=cluster.txt
Enter root mysql password :
--------------
flush privileges
--------------

--------------
delete from mysql.user where user = 'stroomuser'
--------------
...
...
...
--------------
flush privileges
--------------

[stroomuser@host ~]$
```    

## Advanced Install

The below example uses the utility scripts to create 3 custom mysql server instances on 2 servers:

- server1 - master stroom,
- server2 - slave stroom, stroom_stats

As root on server1: 

```bash
yum install "mysql56-mysql-server"
```

Create the master database:

```bash
[root@node1 stroomuser]# ./stroom-setup/mysqld_instance.sh --name=mysqld56_stroom --port=3106 --server=mysqld56 --os=rhel6

--master not set ... assuming master database
Wrote base files in tmp (You need to move them as root).  cp /tmp/mysqld56_stroom /etc/init.d/mysqld56_stroom; cp /tmp/mysqld56_stroom.cnf /etc/mysqld56_stroom.cnf
Run mysql client with mysql --defaults-file=/etc/mysqld56_stroom.cnf

[root@node1 stroomuser]# cp /tmp/mysqld56_stroom /etc/init.d/mysqld56_stroom; cp /tmp/mysqld56_stroom.cnf /etc/mysqld56_stroom.cnf
[root@node1 stroomuser]# /etc/init.d/mysqld56_stroom start

Initializing MySQL database:  Installing MySQL system tables...
OK
Filling help tables...
...
...
Starting mysql56-mysqld:                                   [  OK  ]
```

Check Start up Settings Correct

```bash
[root@node2 stroomuser]# chkconfig mysqld off
[root@node2 stroomuser]# chkconfig mysql56-mysqld off
[root@node1 stroomuser]# chkconfig --add mysqld56_stroom
[root@node1 stroomuser]# chkconfig mysqld56_stroom on

[root@node2 stroomuser]# chkconfig --list | grep mysql
mysql56-mysqld  0:off   1:off   2:off   3:off   4:off   5:off   6:off
mysqld          0:off   1:off   2:off   3:off   4:off   5:off   6:off
mysqld56_stroom    0:off   1:off   2:on    3:on    4:on    5:on    6:off
mysqld56_stats  0:off   1:off   2:on    3:on    4:on    5:on    6:off
```

Create a text file will all members of the cluster:

```bash
[root@node1 stroomuser]# vi cluster.txt

node1.my.org
node2.my.org
node3.my.org
node4.my.org 
```

Create the grants:

```bash
[root@node1 stroomuser]# ./stroom-setup/mysql_grant.sh --name=mysqld56_stroom --user=stroomuser --password=password --cluster=cluster.txt
```

As root on server2: 

```bash
[root@node2 stroomuser]# yum install "mysql56-mysql-server"


[root@node2 stroomuser]# ./stroom-setup/mysqld_instance.sh --name=mysqld56_stroom --port=3106 --server=mysqld56 --os=rhel6 --master=node1.my.org --user=stroomuser --password=password

--master set ... assuming slave database
Wrote base files in tmp (You need to move them as root).  cp /tmp/mysqld56_stroom /etc/init.d/mysqld56_stroom; cp /tmp/mysqld56_stroom.cnf /etc/mysqld56_stroom.cnf
Run mysql client with mysql --defaults-file=/etc/mysqld56_stroom.cnf

[root@node2 stroomuser]# cp /tmp/mysqld56_stroom /etc/init.d/mysqld56_stroom; cp /tmp/mysqld56_stroom.cnf /etc/mysqld56_stroom.cnf
[root@node1 stroomuser]# /etc/init.d/mysqld56_stroom start

Initializing MySQL database:  Installing MySQL system tables...
OK
Filling help tables...
...
...
Starting mysql56-mysqld:                                   [  OK  ]
```

Check Start up Settings Correct

```bash
[root@node2 stroomuser]# chkconfig mysqld off
[root@node2 stroomuser]# chkconfig mysql56-mysqld off
[root@node1 stroomuser]# chkconfig --add mysqld56_stroom
[root@node1 stroomuser]# chkconfig mysqld56_stroom on

[root@node2 stroomuser]# chkconfig --list | grep mysql
mysql56-mysqld  0:off   1:off   2:off   3:off   4:off   5:off   6:off
mysqld          0:off   1:off   2:off   3:off   4:off   5:off   6:off
mysqld56_stroom    0:off   1:off   2:on    3:on    4:on    5:on    6:off
```

Create the grants:

```bash
[root@node1 stroomuser]# ./stroom-setup/mysql_grant.sh --name=mysqld56_stroom --user=stroomuser --password=password --cluster=cluster.txt
```

Make the slave database start to follow:
 
```bash
[root@node2 stroomuser]# cat /etc/mysqld56_stroom.cnf | grep "change master"
# change master to MASTER_HOST='node1.my.org', MASTER_PORT=3106, MASTER_USER='stroomuser', MASTER_PASSWORD='password';

[root@node2 stroomuser]# mysql --defaults-file=/etc/mysqld56_stroom.cnf

mysql> change master to MASTER_HOST='node1.my.org', MASTER_PORT=3106, MASTER_USER='stroomuser', MASTER_PASSWORD='password';
mysql> start slave; 
```
    
As processing user on server1:

```bash
[stroomuser@node1 ~]$ mysql --defaults-file=/etc/mysqld56_stroom.cnf --user=stroomuser --password=password

mysql> create database stroom;
Query OK, 1 row affected (0.00 sec)

mysql> use stroom;
Database changed

mysql> create table test (a int);
Query OK, 0 rows affected (0.05 sec)
```

As processing user on server2 check server replicating OK:

```bash
[stroomuser@node2 ~]$ mysql --defaults-file=/etc/mysqld56_stroom.cnf --user=stroomuser --password=password

mysql> show create table test;
+-------+----------------------------------------------------------------------------------------+
| Table | Create Table                                                                           |
+-------+----------------------------------------------------------------------------------------+
| test  | CREATE TABLE `test` (`a` int(11) DEFAULT NULL  ) ENGINE=InnoDB DEFAULT CHARSET=latin1  |
+-------+----------------------------------------------------------------------------------------+
1 row in set (0.00 sec)
```    

As root on server2: 

```bash
[root@node2 stroomuser]# /home/stroomuser/stroom-setup/mysqld_instance.sh --name=mysqld56_stats --port=3206 --server=mysqld56 --os=rhel6 --user=statsuser --password=password
[root@node2 stroomuser]# cp /tmp/mysqld56_stats /etc/init.d/mysqld56_stats; cp /tmp/mysqld56_stats.cnf /etc/mysqld56_stats.cnf
[root@node2 stroomuser]# /etc/init.d/mysqld56_stats start
[root@node2 stroomuser]# chkconfig mysqld56_stats on
```

Create the grants:

```bash
[root@node2 stroomuser]# ./stroom-setup/mysql_grant.sh --name=mysqld56_stats --database=stats  --user=stroomstats --password=password --cluster=cluster.txt
```

As processing user create the database:

```bash
[stroomuser@node2 ~]$ mysql --defaults-file=/etc/mysqld56_stats.cnf --user=stroomstats --password=password
Welcome to the MySQL monitor.  Commands end with ; or \g.
....
mysql> create database stats;
Query OK, 1 row affected (0.00 sec)
```
