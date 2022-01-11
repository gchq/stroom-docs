---
title: "Apache Forwarding"
linkTitle: "Apache Forwarding"
weight: 5
description: >
  

---

{{% page-warning %}}
This document refers to v5.
{{% /page-warning %}}

Stroom Proxy defaults to listening for HTTP on port 9080.
It is recommended that Apache is used to listen on the standard HTTP port 80 and forward requests on via the Apache mod_jk module and the AJP protocol (on 9009).
Apache can also perform HTTPS on port 443 and pass over requests to Tomcat using the same AJP protocol.

It is additionally recommended that Stroom Proxy is used to front data ingest and so Apache is configured to route traffic to http(s)://server/stroom/datafeed to Stroom Proxy.


## Prerequisites

- tomcat-connectors-1.2.31-src.tar.gz

## Setup Apache


- As root
- Patch mod_jk

```bash
cd ~/tmp
tar -xvzf tomcat-connectors-1.2.31-src.tar.gz 
cd tomcat-connectors-1.2.31-src/native
./configure --with-apxs=/usr/sbin/apxs 
make
sudo cp apache-2.0/mod_jk.so /etc/httpd/modules/
cd
```

- Put the web server cert, private key, and CA cert into the web servers conf directory  /etc/httpd/conf.  E.g.

```bash
[user@node1 stroom-doc]$ ls -al /etc/httpd/conf
....
-rw-r--r-- 1 root root  1729 Aug 27  2013 host.crt
-rw-r--r-- 1 root root  1675 Aug 27  2013 host.key
-rw-r--r-- 1 root root  1289 Aug 27  2013 CA.crt
....
```

- Make changes to /etc/http/conf.d/ssl.conf as per below

```text
JkMount /stroom/datafeed* loadbalancer_proxy
JkMount /stroom* loadbalancer_proxy
```    

```text
JkOptions +ForwardKeySize +ForwardURICompat +ForwardSSLCertChain -ForwardDirectories

SSLCertificateFile /etc/httpd/conf/[YOUR SERVER].crt
SSLCertificateKeyFile /etc/httpd/conf/[YOUR SERVER].key
SSLCertificateChainFile /etc/httpd/conf/[YOUR CA].crt
SSLCACertificateFile /etc/httpd/conf/[YOUR CA APPENDED LIST].crt
```

- Remove /etc/httpd/conf.d/nss.conf to avoid a 8443 port clash

```bash
rm /etc/httpd/conf.d/nss.conf 
```

- Create a /etc/httpd/conf.d/mod_jk.conf configuration

```text
LoadModule jk_module modules/mod_jk.so
JkWorkersFile conf/workers.properties
JkLogFile logs/mod_jk.log
JkLogLevel info
JkLogStampFormat  "[%a %b %d %H:%M:%S %Y]"
JkOptions +ForwardKeySize +ForwardURICompat +ForwardSSLCertChain -ForwardDirectories
JkRequestLogFormat "%w %V %T"
```

```text
JkMount /stroom/datafeed* loadbalancer_proxy
JkMount /stroom* loadbalancer_proxy
```

```text
JkShmFile logs/jk.shm
<Location /jkstatus/>
    JkMount status
    Order deny,allow
    Deny from all
    Allow from 127.0.0.1
</Location>
```

- Setup stroom-setup/cluster.txt, generate the workers file and copy into Apache.  (as root and replace stroomuser with your processing user)

```bash
/home/stroomuser/stroom-setup/workers.properties.sh --cluster=/home/stroomuser/cluster.txt > /etc/httpd/conf/workers.properties
```

- Inspect /etc/httpd/conf/workers.properties to make sure it looks as you expect for your cluster
text
```
worker.list=loadbalancer_proxy,local_proxy
worker.stroom_1_proxy.port=9009
worker.stroom_1_proxy.host=localhost
worker.stroom_1_proxy.type=ajp13
worker.stroom_1_proxy.lbfactor=1
worker.stroom_1_proxy.max_packet_size=65536
....
....
worker.loadbalancer_proxy.type=lb
worker.loadbalancer_proxy.balance_workers=stroom_1_proxy,stroom_2_proxy
worker.loadbalancer_proxy.sticky_session=1
worker.local_proxy.type=lb
worker.local_proxy.balance_workers=stroom_1_proxy
worker.local_proxy.sticky_session=1
```

- Create a simple redirect page to the stroom web app for the root URL (e.g. DocumentRoot "/var/www/html", index.html)

```text
&lt;html&gt;&lt;head&gt;&lt;meta http-equiv="Refresh" content="0; URL=stroom"&gt;&lt;/head&gt;&lt;/html&gt;
```   

- Restart Apache and then test default http / https access.

```bash
sudo /etc/init.d/httpd restart
``` 
