# Apache Forwarding

Stroom defaults to listening for HTTP on port 8080.
It is recommended that Apache is used to listen on the standard HTTP port 80 and forward requests on via the Apache mod_jk module and the AJP protocol (on 8009).
Apache can also perform HTTPS on port 443 and pass over requests to Tomcat using the same AJP protocol.

It is additionally recommended that Stroom Proxy is used to front data ingest and so Apache is configured to route traffic to http(s)://server/stroom/datafeed to Stroom Proxy and anything else to Stroom.


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


```
JkMount /stroom* local
JkMount /stroom/remoting/cluster* local
```

```
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

```
LoadModule jk_module modules/mod_jk.so
JkWorkersFile conf/workers.properties
JkLogFile logs/mod_jk.log
JkLogLevel info
JkLogStampFormat  "[%a %b %d %H:%M:%S %Y]"
JkOptions +ForwardKeySize +ForwardURICompat +ForwardSSLCertChain -ForwardDirectories
JkRequestLogFormat "%w %V %T"
```

```
JkMount /stroom* local
JkMount /stroom/remoting/cluster* local
```

```
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

```
worker.list=loadbalancer,local,status
worker.stroom_1.port=8009
worker.stroom_1.host=localhost
worker.stroom_1.type=ajp13
worker.stroom_1.lbfactor=1
worker.stroom_1.max_packet_size=60000
....
....
worker.loadbalancer.type=lb
worker.loadbalancer.balance_workers=stroom_1,stroom_2
worker.loadbalancer.sticky_session=1
worker.local.type=lb
worker.local.balance_workers=stroom_1
worker.local.sticky_session=1
worker.status.type=status
```

- Create a simple redirect page to the stroom web app for the root URL (e.g. DocumentRoot "/var/www/html", index.html)

```
&lt;html&gt;&lt;head&gt;&lt;meta http-equiv="Refresh" content="0; URL=stroom"&gt;&lt;/head&gt;&lt;/html&gt;
```   

- Restart Apache and then test default http / https access.

```bash
sudo /etc/init.d/httpd restart
``` 

## Advanced Forwarding


Typically Stroom is setup so that traffic sent to /stroom* is routed to Stroom and /stroom/datafeed to Stroom Proxy.  It is possible to setup an extra 1 level of datafeed routing so that based on the URL this traffic can be routed differently.

For example to route traffic directly to Stroom under the URL /stroom/datafeed/direct (avoiding any aggregation) the following mod_jk setting could be used.

```
JkMount /stroom/datafeed/direct* loadbalancer
```
