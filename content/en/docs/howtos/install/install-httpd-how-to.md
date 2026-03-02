---
title: "Apache Httpd/Mod_JK configuration for Stroom"
linkTitle: "Apache Httpd/Mod_JK"
#weight:
date: 2021-07-12
tags: 
  - httpd
  - installation
description: >
  The following is a HOWTO to assist users in configuring Apache's HTTPD with Mod_JK for Stroom.
---

## Assumptions
The following assumptions are used in this document.
 - the user has reasonable RHEL/Centos System administration skills
 - installations are on Centos 7.3 minimal systems (fully patched)
 - the security of the HTTPD deployment should be reviewed for a production environment.


## Installation of Apache httpd and Mod_JK Software

To deploy Stroom using Apache's httpd web service as a front end (https) and Apache's mod_jk as the interface between Apache and the Stroom tomcat applications, we also need
- apr
- apr-util
- apr-devel
- gcc
- httpd
- httpd-devel
- mod_ssl
- epel-release
- tomcat-native
- apache's mod_jk tomcat connector plugin


Most of the required software are packages available via standard repositories and hence we can simply execute
```bash
sudo yum -y install apr apr-util apr-devel gcc httpd httpd-devel mod_ssl epel-release
sudo yum -y install tomcat-native
```
The reason for the distinct `tomcat-native` installation is that this package is from the {{< external-link "EPEL" "https://fedoraproject.org/wiki/EPEL" >}} repository so it must be installed first.

For the Apache mod_jk Tomcat connector we need to acquire a recent {{< external-link "release" "https://tomcat.apache.org/connectors-doc/" >}} and install it.
The following commands achieve this for the 1.2.42 release.
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

Although you could remove the gcc compiler at this point, we leave it installed as one _should_ continue to upgrade the Tomcat Connectors to later releases.

## Configure Apache httpd
We need to configure Apache as the `root` user.

If the Apache httpd service is 'fronting' a Stroom user interface, we should create an index file (/var/www/html/index.html) on all nodes so browsing to
the root of the node will present the Stroom UI. This is not needed if you are deploying a Forwarding or Standalone Stroom proxy.

### Forwarding file for Stroom User Interface deployments
```bash
F=/var/www/html/index.html
printf '<html>\n' > ${F}
printf '<head>\n' >> ${F}
printf '  <meta http-equiv="Refresh" content="0; URL=stroom"/>\n' >> ${F}
printf '</head>\n' >> ${F}
printf '</html>\n' >> ${F}
chmod 644 ${F}
```

Remember, deploy this file on all nodes running the Stroom Application.

### Httpd.conf Configuration
We modify `/etc/httpd/conf/httpd.conf` on all nodes, but backup the file first with
```bash
cp /etc/httpd/conf/httpd.conf /etc/httpd/conf/httpd.conf.ORIG
```

Irrespective of the Stroom scenario being deployed - Multi Node Stroom (Application and Proxy), single Standalone Stroom Proxy or single Forwarding
Stroom Proxy, the configuration of the `/etc/httpd/conf/httpd.conf` file is the same.

We start by modify the configuration file by,
add just before the ServerRoot directive the following directives which are designed to make the httpd service more secure.

```text
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

```text
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

```text
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

Remember, deploy this file on all nodes.

### Configuration of ssl.conf
We modify `/etc/httpd/conf.d/ssl.conf` on all nodes, backing up first,
```base
cp /etc/httpd/conf.d/ssl.conf /etc/httpd/conf.d/ssl.conf.ORIG
```

The configuration of the `/etc/httpd/conf.d/ssl.conf` **does** change depending on the Stroom scenario deployed. In the following we will indicate
differences by tagged sub-headings. If the configuration applies irrespective of scenario, then __All scenarios__ is the tag, else the tag indicated the
type of Stroom deployment.

#### ssl.conf: HTTP to HTTPS Redirection - All scenarios
Before the <VirtualHost _default_:443> context we add http to https redirection by adding the directives (noting we specify the actual server name)
```
<VirtualHost *:80>
  ServerName stroomp00.strmdev00.org
  Redirect permanent "/" "https://stroomp00.strmdev00.org/"
</VirtualHost>
```

That is, we change
```
...
## SSL Virtual Host Context
##

<VirtualHost _default_:443>
...
```
to
```
...
## SSL Virtual Host Context
##

# Stroom Change: Start - Add http redirection to https
<VirtualHost *:80>
  ServerName stroomp00.strmdev00.org
  Redirect permanent "/" "https://stroomp00.strmdev00.org/"
</VirtualHost>
# Stroom Change: End

<VirtualHost _default_:443>
```

#### ssl.conf: VirtualHost directives - Multi Node 'Application and Proxy' deployment
Within the <VirtualHost _default_:443> context we set the directives, in this case, we use the CNAME `stroomp.strmdev00.org`
```
ServerName stroomp.strmdev00.org
JkMount /stroom* loadbalancer
JkMount /stroom/remoting/cluster* local
JkMount /stroom/datafeed* loadbalancer_proxy
JkMount /stroom/remoting* loadbalancer_proxy
JkMount /stroom/datafeeddirect* loadbalancer
JkOptions +ForwardKeySize +ForwardURICompat +ForwardSSLCertChain -ForwardDirectories
```
That is, we change
```
...
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
<VirtualHost _default_:443>

# General setup for the virtual host, inherited from global configuration
#DocumentRoot "/var/www/html"
#ServerName www.example.com:443
# Stroom Change: Start - Set servername and mod_jk connectivity
ServerName stroomp.strmdev00.org
JkMount /stroom* loadbalancer
JkMount /stroom/remoting/cluster* local
JkMount /stroom/datafeed* loadbalancer_proxy
JkMount /stroom/remoting* loadbalancer_proxy
JkMount /stroom/datafeeddirect* loadbalancer
JkOptions +ForwardKeySize +ForwardURICompat +ForwardSSLCertChain -ForwardDirectories
# Stroom Change: End

# Use separate log files for the SSL virtual host; note that LogLevel
# is not inherited from httpd.conf.
...
```

#### ssl.conf: VirtualHost directives - Standalone or Forwarding Proxy deployment
Within the <VirtualHost _default_:443> context set the directives, in this case, for a node named say `stroomfp0.strmdev00.org`
```
ServerName stroomfp0.strmdev00.org
JkMount /stroom/datafeed* local_proxy
JkOptions +ForwardKeySize +ForwardURICompat +ForwardSSLCertChain -ForwardDirectories
```
That is, we change
```
...
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
<VirtualHost _default_:443>

# General setup for the virtual host, inherited from global configuration
#DocumentRoot "/var/www/html"
#ServerName www.example.com:443
# Stroom Change: Start - Set servername and mod_jk connectivity
ServerName stroomfp0.strmdev00.org
JkMount /stroom/datafeed* local_proxy
JkOptions +ForwardKeySize +ForwardURICompat +ForwardSSLCertChain -ForwardDirectories
# Stroom Change: End

# Use separate log files for the SSL virtual host; note that LogLevel
# is not inherited from httpd.conf.
...
```

#### ssl.conf: VirtualHost directives - Single Node 'Application and Proxy' deployment

Within the <VirtualHost _default_:443> context set the directives, in this case, for a node name `stroomp00.strmdev00.org`
```
ServerName stroomp00.strmdev00.org
JkMount /stroom* local
JkMount /stroom/remoting/cluster* local
JkMount /stroom/datafeed* local_proxy
JkMount /stroom/remoting* local_proxy
JkMount /stroom/datafeeddirect* local
JkOptions +ForwardKeySize +ForwardURICompat +ForwardSSLCertChain -ForwardDirectories
```
That is, we change
```
...
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
<VirtualHost _default_:443>

# General setup for the virtual host, inherited from global configuration
#DocumentRoot "/var/www/html"
#ServerName www.example.com:443
# Stroom Change: Start - Set servername and mod_jk connectivity
ServerName stroomp00.strmdev00.org
JkMount /stroom* local
JkMount /stroom/remoting/cluster* local
JkMount /stroom/datafeed* local_proxy
JkMount /stroom/remoting* local_proxy
JkMount /stroom/datafeeddirect* local
JkOptions +ForwardKeySize +ForwardURICompat +ForwardSSLCertChain -ForwardDirectories
# Stroom Change: End

# Use separate log files for the SSL virtual host; note that LogLevel
# is not inherited from httpd.conf.
...
```

#### ssl.conf: Certificate file changes - All scenarios
We replace the standard certificate files with the generated certificates. In the example below, we are using the multi node scenario, in
that the key file names are `stroomp.crt` and `stroomp.key`. For other scenarios, use the appropriate file names generated. We replace
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
#### ssl.conf: Certificate Bundle/NO-CA Verification - All scenarios
If you have signed your Stroom server certificate with a Certificate Authority, then change
```
SSLCACertificateFile /etc/pki/tls/certs/ca-bundle.crt
```
to be your own certificate bundle which you should probably store as `~stroomuser/stroom-jks/public/stroomp-ca-bundle.crt`.

Now if you are using a self signed certificate, you will need to set the Client Authentication to have a value of
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

#### ssl.conf: Servlet Protection - Single or Multi Node scenarios (not for Standalone/Forwarding Proxy)
We now need to secure certain Stroom Application servlets, to ensure they are only accessed under appropriate control.

This set of servlets will be accessible by all nodes in the subnet 192.168.2 (as well as localhost). We achieve this by adding after the example Location directives
```
<Location ~ "stroom/(status|echo|sessionList|debug)" >
 Require all denied
 Require ip 127.0.0.1 192.168.2
</Location>
```
We further restrict the clustercall and export servlets to just the localhost. If we had multiple Stroom processing nodes, you would specify each node, or preferably, the subnet they are on. In our multi node case this is 192.168.2.
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

#### ssl.conf: Log formats - All scenarios
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
Remember, in the case of Multi node stroom Application servers, deploy this file on all servers.

### Apache Mod_JK configuration
Apache Mod_JK has two configuration files
- /etc/httpd/conf.d/mod_jk.conf - for the http server configuration
- /etc/httpd/conf/workers.properties - to configure the Tomcat workers

In multi node scenarios, `/etc/httpd/conf.d/mod_jk.conf` is the same on all servers, but the `/etc/httpd/conf/workers.properties` file is different.
The contents of these two configuration files differ depending on the Stroom deployment. The following provide the various deployment scenarios.

#### Mod_JK Multi Node Application and Proxy Deployment
For a Stroom Multi node Application and Proxy server,

- we configure `/etc/httpd/conf.d/mod_jk.conf` as per

```bash
F=/etc/httpd/conf.d/mod_jk.conf
printf 'LoadModule jk_module modules/mod_jk.so\n' > ${F}
printf 'JkWorkersFile conf/workers.properties\n' >> ${F}
printf 'JkLogFile logs/mod_jk.log\n' >> ${F}
printf 'JkLogLevel info\n' >> ${F}
printf 'JkLogStampFormat  "[%%a %%b %%d %%H:%%M:%%S %%Y]"\n' >> ${F}
printf 'JkOptions +ForwardKeySize +ForwardURICompat +ForwardSSLCertChain -ForwardDirectories\n' >> ${F}
printf 'JkRequestLogFormat "%%w %%V %%T"\n' >> ${F}
printf 'JkMount /stroom* loadbalancer\n' >> ${F}
printf 'JkMount /stroom/remoting/cluster* local\n' >> ${F}
printf 'JkMount /stroom/datafeed* loadbalancer_proxy\n' >> ${F}
printf 'JkMount /stroom/remoting* loadbalancer_proxy\n' >> ${F}
printf 'JkMount /stroom/datafeeddirect* loadbalancer\n' >> ${F}
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

- we configure `/etc/httpd/conf/workers.properties` as per

Since we are deploying for a cluster with load balancing, we need a _workers.properties_ file per node. Executing the following will result in two files (_workers.properties.stroomp00_ and _workers.properties.stroomp01_) which should be deployed to their respective servers.

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

If you were to add an additional node to a multi node cluster, say the node `stroomp02.strmdev00.org`, then you would re-run the above script with
```bash
Nodes="stroomp00.strmdev00.org stroomp01.strmdev00.org stroomp02.strmdev00.org"
```
then redeploy all three files to the respective servers. Also note, that for the newly created workers.properties files for the existing nodes to
take effect you will need to restart the Apache Httpd service on both nodes.

Remember, in multi node cluster deployments, the following files are the same and hence can be created on one node, but copied to the
others not forgetting to backup the other node's original files. That is, the files
- /var/www/html/index.html
- /etc/httpd/conf.d/mod_jk.conf
- /etc/httpd/conf/httpd.conf

are to be the same on all nodes. Only the /etc/httpd/conf.d/ssl.conf and /etc/httpd/conf/workers.properties files change.

#### Mod_JK Standalone or Forwarding Stroom Proxy Deployment

For a Stroom Standalone or Forwarding proxy,

- we configure `/etc/httpd/conf.d/mod_jk.conf` as per

```bash
F=/etc/httpd/conf.d/mod_jk.conf
printf 'LoadModule jk_module modules/mod_jk.so\n' > ${F}
printf 'JkWorkersFile conf/workers.properties\n' >> ${F}
printf 'JkLogFile logs/mod_jk.log\n' >> ${F}
printf 'JkLogLevel info\n' >> ${F}
printf 'JkLogStampFormat  "[%%a %%b %%d %%H:%%M:%%S %%Y]"\n' >> ${F}
printf 'JkOptions +ForwardKeySize +ForwardURICompat +ForwardSSLCertChain -ForwardDirectories\n' >> ${F}
printf 'JkRequestLogFormat "%%w %%V %%T"\n' >> ${F}
printf 'JkMount /stroom/datafeed* local_proxy\n' >> ${F}
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

- we configure `/etc/httpd/conf/workers.properties` as per

The variable **N** in the script below is to be the node name (not FQDN) of your sever (i.e. stroomfp0).

```bash
N=stroomfp0
FQDN=`hostname -f`
F=/etc/httpd/conf/workers.properties
printf 'worker.list=local_proxy,status\n' > ${F}
printf 'worker.%s_proxy.port=9009\n' ${N} >> ${F}
printf 'worker.%s_proxy.host=%s\n' ${N} ${FQDN} >> ${F}
printf 'worker.%s_proxy.type=ajp13\n' ${N} >> ${F}
printf 'worker.%s_proxy.lbfactor=1\n' ${N} >> ${F}
printf 'worker.local_proxy.type=lb\n' >> ${F}
printf 'worker.local_proxy.balance_workers=%s_proxy\n' ${N} >> ${F}
printf 'worker.local_proxy.sticky_session=1\n' >> ${F}
printf 'worker.status.type=status\n' >> ${F}
chmod 640 ${F}
```

#### Mod_JK Single Node Application and Proxy Deployment

For a Stroom Single node Application and Proxy server,

- we configure `/etc/httpd/conf.d/mod_jk.conf` as per

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
printf 'JkMount /stroom/datafeed* local_proxy\n' >> ${F}
printf 'JkMount /stroom/remoting* local_proxy\n' >> ${F}
printf 'JkMount /stroom/datafeeddirect* local\n' >> ${F}
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

- we configure `/etc/httpd/conf/workers.properties` as per

The variable **N** in the script below is to be the node name (not FQDN) of your sever (i.e. stroomp00).

```bash
N=stroomp00
FQDN=`hostname -f`
F=/etc/httpd/conf/workers.properties
printf 'worker.list=local,local_proxy,status\n' > ${F}
printf 'worker.%s.port=8009\n' ${N} >> ${F}
printf 'worker.%s.host=%s\n' ${N} ${FQDN} >> ${F}
printf 'worker.%s.type=ajp13\n' ${N} >> ${F}
printf 'worker.%s.lbfactor=1\n' ${N} >> ${F}
printf 'worker.%s.max_packet_size=65536\n' ${N} >> ${F}
printf 'worker.%s_proxy.port=9009\n' ${N} >> ${F}
printf 'worker.%s_proxy.host=%s\n' ${N} ${FQDN} >> ${F}
printf 'worker.%s_proxy.type=ajp13\n' ${N} >> ${F}
printf 'worker.%s_proxy.lbfactor=1\n' ${N} >> ${F}
printf 'worker.%s_proxy.max_packet_size=65536\n' ${N} >> ${F}
printf 'worker.local.type=lb\n' >> ${F}
printf 'worker.local.balance_workers=%s\n' ${N} >> ${F}
printf 'worker.local.sticky_session=1\n' >> ${F}
printf 'worker.local_proxy.type=lb\n' >> ${F}
printf 'worker.local_proxy.balance_workers=%s_proxy\n' ${N} >> ${F}
printf 'worker.local_proxy.sticky_session=1\n' >> ${F}
printf 'worker.status.type=status\n' >> ${F}
chmod 640 ${F}
```
## Final host configuration and web service enablement
Now tidy up the SELinux context for access on all nodes and files via the commands
```bash
setsebool -P httpd_enable_homedirs on
setsebool -P httpd_can_network_connect on
chcon --reference /etc/httpd/conf.d/README /etc/httpd/conf.d/mod_jk.conf
chcon --reference /etc/httpd/conf/magic /etc/httpd/conf/workers.properties
```

We also enable both http and https services via the firewall on all nodes. If you don't want to present a http access point,
then don't enable it in the firewall setting. This is done with
```bash
firewall-cmd --zone=public --add-service=http --permanent
firewall-cmd --zone=public --add-service=https --permanent
firewall-cmd --reload
firewall-cmd --zone=public --list-all
```

Finally enable then start the httpd service, correcting any errors. It should be noted that on any errors,
the suggestion of a systemctl status or viewing the journal are good, but also review information in the httpd error logs found in `/var/log/httpd/`.
```bash
systemctl enable httpd.service
systemctl start httpd.service
```

