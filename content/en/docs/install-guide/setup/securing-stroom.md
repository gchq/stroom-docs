---
title: "Securing Stroom"
linkTitle: "Securing Stroom"
weight: 20
date: 2022-02-04
tags: 
  - TODO
  - mysql
description: >
  How to secure Stroom and the cluster
---

> *NOTE* This document was written for stroom v4/5. Some parts may not be applicable for v6+.

## Firewall

The following firewall configuration is recommended:

* Outside cluster drop all access except ports HTTP 80, HTTPS 443, and any other system ports your require SSH, etc
* Within cluster allow all access

This will enable nodes within the cluster to communicate on:

* 8080 - Stroom HTTP.
* 8081 - Stroom HTTP (admin).
* 8090 - Stroom Proxy HTTP.
* 8091 - Stroom Proxy HTTP (admin).
* 3306 - MySQL


## MySQL

{{% todo %}}
Update this for MySQL 8
{{% /todo %}}

It is recommended that you run mysql_secure_installation to set a root password and remove test database:

```bash
mysql_secure_installation (provide a root password)
- Set root password? [Y/n] Y
- Remove anonymous users? [Y/n] Y 
- Disallow root login remotely? [Y/n] Y
- Remove test database and access to it? [Y/n] Y
- Reload privilege tables now? [Y/n] Y
```
