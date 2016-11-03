## Securing Stroom

### Firewall

The following firewall configuration is recommended:

- Outside cluster drop all access except ports HTTP 80, HTTPS 443, and any other system ports your require SSH, etc
- Within cluster allow all access

This will enable nodes within the cluster to communicate on:

- Native tomcat HTTP 8080, 9080
- Tomcat AJP 8009, 9009
- MySQL 3006

### MySQL

- It is recommended that you run mysql_secure_installation to set a root password and remove test database:

```bash
mysql_secure_installation (provide a root password)
- Set root password? [Y/n] Y
- Remove anonymous users? [Y/n] Y 
- Disallow root login remotely? [Y/n] Y
- Remove test database and access to it? [Y/n] Y
- Reload privilege tables now? [Y/n] Y
```

- stroom-setup includes a version of this script designed to be run on instances create using mysqld_instance.sh
(i.e. non standard or multiple instances of mysql) 

```bash
[stroomuser@stroom_1 stroom-setup]$ ./mysql_secure_installation.sh --name=mysqld_ref1m
```
