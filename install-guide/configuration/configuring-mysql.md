# MySQL Configuration

> **Version Information:** Created with Stroom v7.0  
> **Last Updated:** 2021-06-07  
> **See Also:** [MySQL Server Setup](../setup/mysql-server-setup.md)  
> **See Also:** [MySQL Server Administration (external link)](https://dev.mysql.com/doc/refman/8.0/en/server-administration.html)

## General configuration

MySQL is configured via the `.cnf` file which is typically located in one of these locations:

* `/etc/my.cnf`
* `/etc/mysql/my.cnf`
* `$MYSQL_HOME/my.cnf`
* `<data dir>/my.cnf`
* `~/.my.cnf`

> **TODO** - 


## Deploying without Docker

When MySQL is deployed without a docker stack then MySQL should be installed and configured according to the MySQL documentation.
How MySQL is deployed and configured will depend on the requirements of the environment, e.g. clustered, primary/standby, etc.


## As part of a docker stack
