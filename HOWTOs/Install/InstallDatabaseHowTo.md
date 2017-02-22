# Stroom HOWTO - Database Installation
This HOWTO describes the installation of a Stroom database. Following this HOWTO will produce a simple, minimally secured database deployment.
In a production environment consideration needs to be made for redundancy, better security, data-store location, increased memory usage, and the like.

## Assumptions
- we are installing the MariaDB or MySQL Community RDBMS software
- the primary database node is 'stroomdb0.strmdev00.org'.
- installation is on a fully patched minimal Centos 7.3 instance.
- any scripts or commands that should run are in code blocks and are designed to allow the user to cut then paste the commands onto their systems.
- in this document, when a textual screen capture is documented, data entry is identified by the data surrounded by '<__' '__>' . This excludes enter/return presses.

## Installation of Software
### MariaDB Server Installation
As MariaDB is directly supported by Centos 7, we simply install the database server software, then enable and start it's service as per
```bash
sudo yum -y install mariadb mariadb-server
sudo systemctl enable mariadb.service
sudo systemctl start mariadb.service
```
### MySQL Community
#### MySQL Community Repository Installation
As MySQL is not directly supported by Centos 7, we need to install it's repository files prior to installation. 
We get the current MySQL Community release repository rpm and validate it's MD5 checksum against the published value found on the
[MySQL Yum Repository](https://dev.mysql.com/downloads/repo/yum "Download MySQL Yum Repository") site.
```bash
wget https://repo.mysql.com/mysql57-community-release-el7.rpm
md5sum mysql57-community-release-el7.rpm
```

On correct validation of the MD5 checksum, we install the repository files via
```bash
sudo yum -y localinstall mysql57-community-release-el7.rpm
```

#### MySQL Community Server Installation
Next we install server software, then enable and start it's service as per
```bash
sudo yum -y install mysql-community-client mysql-community-server
sudo systemctl enable mysqld.service
sudo systemctl start mysqld.service
```

## Securing the Database
### MariaDB
We secure the database engine by running the `mysql_secure_installation` script. One should accept all defaults, which means the
only entry (aside from pressing returns) is the administrator (root) database password. Make a note of the password you use.

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

### MySQL Community
There is no need to run the (traditional) `mysql_secure_installation` script for MySQL 5.7 versions or beyond, as the function of the program
has already been performed by the yum repository installation.
That said, the initial start up of the mysqld service will have created the administrator (root) account and set it's password.
To reveal the password, run
```bash
sudo grep 'temporary password' /var/log/mysqld.log
```
You should now reset the password. Note that MySQL 5.7 implements the validate_password plugin, so you will need a password that contains
at least one upper case letter, one lower case letter, one digit, and one special character, and that the total password length is at least
8 characters. Change the password via the following, using the password gained from the `/var/log/mysqld.log` above to authenticate to the mysql service.
```bash
mysql -uroot -p
```
then entering the command
```sql
ALTER USER 'root'@'localhost' IDENTIFIED BY '<__ENTER_ROOT_DATABASE_PASSWORD__>';
```
For example, we set the password to `Stroom5User@` as per 
```bash
[burn@stroomdb0 ~]$ mysql -uroot -p
Enter password: < __ENTER_ROOT_DATABASE_PASSWORD_FROM_MYSQLD_LOG__>
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 4
Server version: 5.7.17

Copyright (c) 2000, 2016, Oracle and/or its affiliates. All rights reserved.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql> ALTER USER 'root'@'localhost' IDENTIFIED BY 'Stroom5User@';
Query OK, 0 rows affected (0.00 sec)

mysql> quit
Bye
[burn@stroomdb0 ~]$
```

## Create the Database
Now we create the Stroom database and prepare to allow the processing user from each node to use it. Thus we execute
```bash
sudo mysql --user=root -p
```

and on entering the administrator's password we arrive at the `MariaDB [(none)]> ` or `mysql> ` prompt.
At this we create the database with
```bash
create database stroom;
```

## Enable processing users to access the database
Each Stroom processing node will need to access the database. We will use the database user `stroomuser` with a password
of `stroompassword1` when granting access. One identifies the processing user as `<user>@<host>` on the `grant`
SQL command. In the database instance below, we will grant access for
- stroomuser@localhost for local access for maintenance etc.
- stroomuser@stroomp00.strmdev00.org for access by processing node stroomp00.strmdev00.org
- stroomuser@stroomp01.strmdev00.org for access by processing node stroomp01.strmdev00.org

Thus we execute
```bash
grant all privileges on stroom.* to stroomuser@localhost identified by 'Stroompassword1@';
grant all privileges on stroom.* to stroomuser@stroomp00.strmdev00.org identified by 'Stroompassword1@';
grant all privileges on stroom.* to stroomuser@stroomp01.strmdev00.org identified by 'Stroompassword1@';
```
Clearly if we need to add more processing node, additional `grant` commands would be used. Further, if we were installing the database in a single node Stroom environment, we would just have the first two `grants`.

To exit the `mysql` utility, execute
```bash
quit
```

## Configure Firewall
Next we need to modify our firewall to allow remote access to our database which listens on port 3306 by default.
The simplest way to achieve this is with the commands
```bash
sudo firewall-cmd --zone=public --add-port=3306/tcp --permanent
sudo firewall-cmd --reload
sudo firewall-cmd --zone=public --list-all
```
__Note__ that this allows ANY node to connect to your database. You should give consideration to restricting this to only allowing processing node access.

### Debugging of Mariadb for Stroom
If there is a need to debug the Mariadb and Stroom interaction, on can turn on auditing for the Mariadb service.
To do so, log onto the database as the administrative user as per
```bash
sudo mysql --user=root -p
```
and at the `MariaDB [(none)]> ` prompt enter

```bash
install plugin server_audit SONAME 'server_audit.so';
set global server_audit_logging=ON;
set global server_audit_file_rotate_size=10485760;
install plugin SQL_ERROR_LOG soname 'sql_errlog';
quit;
```

The above will generate two log files, 
- `/var/lib/mysql/server_audit.log` which records all commands the database runs. We have configured the log file will rotate at 10MB in size.
- `/var/lib/mysql/sql_errors.log` which records all erroneous SQL commands. This log file will rotate at 10MB in size.
Both files will, by default, generate up to 9 rotated files.

If you wish to rotate a log file manually, log into the database as the administrative user and execute either
- `set global server_audit_file_rotate_now=1;` to rotate the audit log file
- `set global sql_error_log_rotate=1;` to rotate the sql_errlog log file
