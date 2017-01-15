# Stroom HOWTO - Standalone Proxy Install
The following is a HOWTO to set up Stroom Standalone proxy on Centos 7.3 infrastructure that uses Apache's httpd web service as a front end (https) and Apache's mod_jk as the interface between Apache and the Stroom Proxy tomcat application.

The HOWTO results with Stroom Standalone proxy that stores received logs for manual movement to Stroom system.

Last Update: Burn Alting, 02 Jan 2017
- Initial release (1.20-a)

Assumptions:
 - the user has reasonable RHEL/Centos System administration skills
 - the installation user has the ability to sudo
 - installation on a Centos 7.3 minimal system (fully patched)
 - proxy nodename is 'stroomsap0.strmdev00.org'
 - stroom runs as user 'stroomuser'
 - data will reside in '/stroomdata' which is a link (in this HOWTO) to /home/stroomdata
 - when a screen capture is documented, data entry is identified by the data surrounded by '<__' '__>' . This excludes enter/return presses.
 - better security of password choices, networking, firewalls, data stores, etc can and should be achieved in various ways, but these HOWTOs are just a quick means of getting a working system, so only limited security is applied
 - the use of self signed certificates is appropriate for test systems, but users should consider appropriate CA infrastructure in production environments

## Create Base Operating System and install required packages
First, create a Centos 7.3 minimal instance, then patch via a yum -y update. Should the kernel be updated when patching, then don't forget to reboot.

Once you have an up to date Centos 7.3 install the following packages. Note that we do a `yum -y update` after the initial package installation as the system may need to update the epel repository files. Finally we install tomcat-native separately as it's available via epel which must be installed first.

```bash
sudo yum -y install java-1.8.0-openjdk java-1.8.0-openjdk-devel unzip zip mod_ssl httpd apr apr-util apr-devel gcc httpd-devel epel-release policycoreutils-python
sudo yum -y update
sudo yum -y install tomcat-native
```

Next, acquire a recent Apache mod_jk Tomcat connector release and install it. Note we do this as root.

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

## Create the processing user and instantiate the Stroom Storage
We create the processing user, as per

```bash
sudo useradd stroomuser
```

And create the storage hierarchy. Since we are a proxy that stores data sent to it we have only one directory
- `/stroomdata/stroom-working/proxy`	- location for Stroom proxy to store inbound data files prior to forwarding

so we execute the commands

```bash
sudo mkdir -p /home/stroomdata
sudo ln -s /home/stroomdata /stroomdata
sudo mkdir -p /stroomdata/stroom-working/proxy
sudo chown -R stroomuser:stroomuser /home/stroomdata
sudo chmod -R 750 /home/stroomdata
```

## Install the Stroom Proxy Application

Now become the stroomuser and acquire the current Stroom Proxy release from github.

```bash
sudo -i -u stroomuser
Prx=5.1-beta.3
wget https://github.com/gchq/stroom-proxy/releases/download/v${Prx}/stroom-proxy-distribution-${Prx}-bin.zip
```

Now we set up the processing user's environment. This is made up of two environment variable files (one for the Stroom services and the other for the systemd Stroom service). The JAVA_HOME and PATH variables are to support Java running the Tomcat instances.

```bash
F=~/env.sh
printf '# Environment variables for Stroom services\n' > ${F}
printf 'export JAVA_HOME=/usr/lib/jvm/java-1.8.0\n' >> ${F}
printf 'export PATH=${JAVA_HOME}/bin:${PATH}\n' >> ${F}
chmod 640 ${F}

F=~/env_service.sh
printf '# Environment variables for Stroom services, executed out of systemd service\n' > ${F}
printf 'JAVA_HOME=/usr/lib/jvm/java-1.8.0\n' >> ${F}
printf 'PATH=${JAVA_HOME}/bin:${PATH}\n' >> ${F}
chmod 640 ${F}
```

And we integrate the environment into our bash instantiation script as well as setting up some useful bash functions

```bash
F=~/.bashrc
printf '. ~/env.sh\n\n' >> ${F}
printf '# Simple functions to support Stroom\n' >> ${F}
printf '# Tp - continually monitor (tail) the Stroom proxy log\n'  >> ${F}
printf 'function Tp {\n  tail --follow=name ~/stroom-proxy/instance/logs/stroom.log\n}\n' >> ${F}
```

And test it has set up correctly

```bash
. ./.bashrc
which java
```
which should return `/usr/lib/jvm/java-1.8.0/bin/java`

At this point, we will install the application and proxy. So first extract the code

```bash
unzip stroom-proxy-distribution-${Prx}-bin.zip
chmod 750 stroom-proxy
```

We now install the proxy. The script must be given _one_ of three arguements, indicating the proxy type
- store
- store_nodb
- forward

In our instance, since we are installing a standalone proxy, we need to install the `store_nodb` proxy. The `nodb` suffix indicates there is no Stroom database available to validate event feeds. This means that as batches of events are sent to our Stroom instance, the `store_nodb` proxy assumes all 'feeds' are valid and will store the batches as files in the given directory until they are manually collected. Thus to install we run

```bash
stroom-proxy/bin/setup.sh store_nodb
```
during which one is prompted for a number of configuration settings. Use the following
```
NODE to be the hostname (not FQDN) of your host (i.e. 'stroomsap0' in our example)
PORT_PREFIX should use the default, just press return
REPO_DIR should be set to '/stroomdata/stroom-working/proxy' which we created earlier.
JAVA_OPTS can use the defaults, but ensure you have sufficient memory, either change or accept the default
```

At this point, the script will configure the proxy. There should be no errors, but review the output.

Given we are using mod_jk then we need to modify the proxy's AJP connector to specify a larger packetSize. Edit the file `stroom-proxy/instance/conf/server.xml` to change
```
<Connector port="9009" protocol="AJP/1.3"
    redirectPort="8443" />
```
to
```
<Connector port="9009" protocol="AJP/1.3"
    redirectPort="8443" packetSize="65536" />
```

We can now manually start the proxy. Do so with
```bash
stroom-proxy/bin/start.sh
```
Now monitor the directory `stroom-proxy/instance/logs` for any errors. Initially you will see the log files
`localhost_access_log.YYYY-MM-DD.txt` and `catalina.out`. Check them for errors and correct (or pose a question to this arena). The context path and unknown version warnings in `catalina.out` can be ignored.
Eventually the log file `stroom-proxy/instance/logs/stroom.log` will appear. Again check it for errors. If you leave it for a while you
will eventually see cyclic (10 minute cycle) messages of the form
```
INFO  [Repository Reader Thread 1] handler.ProxyRepositoryReader (ProxyRepositoryReader.java:143) - run() - Cron Match at YYYY-MM-DD ...
```


## Integration of Services with Apache's Httpd service

### Create certificates
The first step is to establish a self signed certificate for our Stroom service. If you have a certificate server, then certainly gain an appropriately signed certificate. For this HOWTO, we will stay with a self signed solution and hence no certificate authorities are involved.

We first set up a directory to house our certificates
```bash
export H=stroomsap0
cd ~stroomuser
rm -rf stroom-jks
mkdir -p stroom-jks stroom-jks/public stroom-jks/private
cd stroom-jks
```

Create a server key for Stroom service (enter a password when prompted for both initial and verification prompts)
```bash
openssl genrsa -des3 -out private/$H.key 2048
```
as per
```
Generating RSA private key, 2048 bit long modulus
.................................................................+++
...............................................+++
e is 65537 (0x10001)
Enter pass phrase for private/stroomsap0.key: <__ENTER_SERVER_KEY_PASSWORD__>
Verifying - Enter pass phrase for private/stroomsap0.key: <__ENTER_SERVER_KEY_PASSWORD__>

```

Create a signing request. The two important prompts are the password and Common Name. All the rest can use the defaults offered.
The requested password is for the server key and you should use the node's FQDN for the Common Name (i.e. stroomsap0.strmdev00.org).

```bash
openssl req -sha256 -new -key private/$H.key -out $H.csr
```
as per
```
Enter pass phrase for private/stroomsap0.key: <__ENTER_SERVER_KEY_PASSWORD__>
You are about to be asked to enter information that will be incorporated
into your certificate request.
What you are about to enter is what is called a Distinguished Name or a DN.
There are quite a few fields but you can leave some blank
For some fields there will be a default value,
If you enter '.', the field will be left blank.
-----
Country Name (2 letter code) [XX]:
State or Province Name (full name) []:
Locality Name (eg, city) [Default City]:
Organization Name (eg, company) [Default Company Ltd]:
Organizational Unit Name (eg, section) []:
Common Name (eg, your name or your server's hostname) []:<__ stroomsap0.strmdev00.org __>
Email Address []:

Please enter the following 'extra' attributes
to be sent with your certificate request
A challenge password []:
An optional company name []:
```

Self sign the certificate (again enter the server key password)
```bash
openssl x509 -req -sha256 -days 720 -in $H.csr -signkey private/$H.key -out public/$H.crt
```
as per
```
Signature ok
subject=/C=XX/L=Default City/O=Default Company Ltd/CN=stroomsap0.strmdev00.org
Getting Private key
Enter pass phrase for private/stroomsap0.key: <__ENTER_SERVER_KEY_PASSWORD__>
```

Create insecure version of Private Key for Apache autoboot (you will again need to enter the password)
```bash
openssl rsa -in private/$H.key -out private/$H.key.insecure
```
as per
```
Enter pass phrase for private/stroomsap0.key: <__ENTER_SERVER_KEY_PASSWORD__>
writing RSA key
```
and then move the insecure keys as appropriate
```bash
mv private/$H.key private/$H.key.secure
chmod 600 private/$H.key.secure
mv private/$H.key.insecure private/$H.key
```

Now ensure protection, ownership and SELinux context for these files
```bash
chmod 700 ~stroomuser/stroom-jks/private ~stroomuser/stroom-jks
chown -R stroomuser:stroomuser ~stroomuser/stroom-jks
chcon -R --reference /etc/pki ~stroomuser/stroom-jks
```

### Configure Apache httpd
Now become root and configure the httpd service.

We create the mod_jk configuration file (/etc/httpd/conf.d/mod_jk.conf)

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

Next, the workers.properties file (/etc/httpd/conf/workers.properties). The variable **N** in the script
below is to be the node name (not FQDN) of your sever (i.e. stroomsap0).

```bash
N=stroomsap0
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
Now modify `/etc/httpd/conf/httpd.conf` but backup the file first with
```bash
cp /etc/httpd/conf/httpd.conf /etc/httpd/conf/httpd.conf.ORIG
```
then, add before the ServerRoot directive the following directives which are designed to make the httpd service more secure.
```
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
```
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
```
...
# Do not add a slash at the end of the directory path.  If you point
# ServerRoot at a non-local disk, be sure to specify a local disk on the
# Mutex directive, if file-based mutexes are used.  If you wish to share the
# same ServerRoot for multiple httpd daemons, you will need to change at
# least PidFile.
#
# Stroom Change: Start - Apply security directives
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
Then finally we add two new log formats and configure the access log to use the new format. This is
done within the `<IfModule logio_module>` by adding the two new LogFormat directives
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

Now modify `/etc/httpd/conf.d/ssl.conf`, backing up first,
```base
cp /etc/httpd/conf.d/ssl.conf /etc/httpd/conf.d/ssl.conf.ORIG
```

Before the <VirtualHost _default_:443> context we add http to https redirection by adding
the directives (noting we specify the server name)
```
<VirtualHost *:80>
  ServerName stroomsap0.strmdev00.org
  Redirect permanent "/" "https://stroomsap0.strmdev00.org/"
</VirtualHost>
```

Within the <VirtualHost _default_:443> context set the directives
```
ServerName stroomsap0.strmdev00.org
JkMount /stroom/datafeed* local_proxy
JkOptions +ForwardKeySize +ForwardURICompat +ForwardSSLCertChain -ForwardDirectories
```
That is, we change
```
...
## SSL Virtual Host Context
##

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
## SSL Virtual Host Context
##

# Stroom Change: Start - Add http redirection to https
<VirtualHost *:80>
  ServerName stroomsap0.strmdev00.org
  Redirect permanent "/" "https://stroomsap0.strmdev00.org/"
</VirtualHost>
# Stroom Change: End

<VirtualHost _default_:443>

# General setup for the virtual host, inherited from global configuration
#DocumentRoot "/var/www/html"
#ServerName www.example.com:443
# Stroom Change: Start - Set servername and mod_jk connectivity
ServerName stroomsap0.strmdev00.org
JkMount /stroom/datafeed* local_proxy
JkOptions +ForwardKeySize +ForwardURICompat +ForwardSSLCertChain -ForwardDirectories
# Stroom Change: End

# Use separate log files for the SSL virtual host; note that LogLevel
# is not inherited from httpd.conf.
...
```
We replace the standard certificate files with the self signed certificates. That is, replace
```
SSLCertificateFile /etc/pki/tls/certs/localhost.crt
```
with
```
SSLCertificateFile /home/stroomuser/stroom-jks/public/stroomsap0.crt
```
and
```
SSLCertificateKeyFile /etc/pki/tls/private/localhost.key
```
with
```
SSLCertificateKeyFile /home/stroomuser/stroom-jks/private/stroomsap0.key
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
SSLCertificateFile /home/stroomuser/stroom-jks/public/stroomsap0.crt
# Stroom Change: End

#   Server Private Key:
#   If the key is not combined with the certificate, use this
#   directive to point at the key file.  Keep in mind that if
#   you've both a RSA and a DSA private key you can configure
#   both in parallel (to also allow the use of DSA ciphers, etc.)
# Stroom Change: Start - Replace with Stroom server private key file
# SSLCertificateKeyFile /etc/pki/tls/private/localhost.key
SSLCertificateKeyFile /home/stroomuser/stroom-jks/private/stroomsap0.key
# Stroom Change: End

#   Server Certificate Chain:
#   Point SSLCertificateChainFile at a file containing the
...
```
If you have signed your Stroom server certificate with a Certificate Authority, then change
```
SSLCACertificateFile /etc/pki/tls/certs/ca-bundle.crt
```
to be your own certificate bundle which you should probably store as `~stroomuser/stroom-jks/public/stroom-ca-bundle.crt`.

Now if you are using a self signed certificate, you will need to set add the Client Authentication to have a value of
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

Now tidy up the SELinux context for access and files via
```bash
setsebool -P httpd_enable_homedirs on
setsebool -P httpd_can_network_connect on
chcon --reference /etc/httpd/conf.d/README /etc/httpd/conf.d/mod_jk.conf
chcon --reference /etc/httpd/conf/magic /etc/httpd/conf/workers.properties
```

We also enable both http and https services via the firewall. If you don't want to present a http access point, then don't enable it in the firewall
setting
```bash
firewall-cmd --zone=public --add-service=http --permanent
firewall-cmd --zone=public --add-service=https --permanent
firewall-cmd --reload
firewall-cmd --zone=public --list-all
```

Finally enable then start the httpd service, correcting any errors. It should be noted that the suggestion of a systemctl status or viewing the journal are good, but most errors have better information in the httpd error logs found in `/var/log/httpd`.
```bash
systemctl enable httpd.service
systemctl start httpd.service
```

## Establish a systemd service for our Stroom services

We first create some simple start/stop scripts that start, or stop, all the available Stroom services. At this point, it's just the Stroom application and proxy. Although this is just a Stroom proxy, we use a generic script for consistency.
```bash
sudo -i -u stroomuser
if [ ! -d ~/bin ]; then mkdir ~/bin; fi
F=~/bin/StartServices.sh
printf '#!/bin/bash\n' > ${F}
printf '# Start all Stroom services\n' >> ${F}
printf '# Set list of services\n' >> ${F}
printf 'Services="stroom-proxy stroom-app"\n' >> ${F}
printf 'for service in ${Services}; do\n' >> ${F}
printf '  if [ -f ${service}/bin/start.sh ]; then\n' >> ${F}
printf '    bash ${service}/bin/start.sh\n' >> ${F}
printf '  fi\n' >> ${F}
printf 'done\n' >> ${F}
chmod 750 ${F}

F=~/bin/StopServices.sh
printf '#!/bin/bash\n' > ${F}
printf '# Stop all Stroom services\n' >> ${F}
printf '# Set list of services\n' >> ${F}
printf 'Services="stroom-proxy stroom-app"\n' >> ${F}
printf 'for service in ${Services}; do\n' >> ${F}
printf '  if [ -f ${service}/bin/stop.sh ]; then\n' >> ${F}
printf '    bash ${service}/bin/stop.sh\n' >> ${F}
printf '  fi\n' >> ${F}
printf 'done\n' >> ${F}
chmod 750 ${F}

exit;	# To become root
```

Now we create the system service file for Stroom. (Noting this is done as root)
```bash
F=/etc/systemd/system/stroom-services.service
printf '# Install in /etc/systemd/system\n' > ${F}
printf '# Enable via systemctl enable stroom-services.service\n\n' >> ${F}
printf '[Unit]\n' >> ${F}
printf '# Who we are\n' >> ${F}
printf 'Description=Stroom Service\n' >> ${F}
printf '# We want the network and httpd up before us\n' >> ${F}
printf 'Requires=network-online.target httpd.service\n' >> ${F}
printf 'After=httpd.service network-online.target\n\n' >> ${F}
printf '[Service]\n' >> ${F}
printf '# Source our environment file so the Stroom service start/stop scripts work\n' >> ${F}
printf 'EnvironmentFile=/home/stroomuser/env_service.sh\n' >> ${F}
printf 'Type=oneshot\n' >> ${F}
printf 'ExecStart=/bin/su --login stroomuser /home/stroomuser/bin/StartServices.sh\n' >> ${F}
printf 'ExecStop=/bin/su --login stroomuser /home/stroomuser/bin/StopServices.sh\n' >> ${F}
printf 'RemainAfterExit=yes\n\n' >> ${F}
printf '[Install]\n' >> ${F}
printf 'WantedBy=multi-user.target\n' >> ${F}
chmod 640 ${F}
```

Now we enable and start the Stroom service.
```bash
systemctl enable stroom-services.service
systemctl start stroom-services.service
```

At this point, you should test posting data to this proxy service.
First, you should identify, or establish, a feed within your Stroom service. For the purposes of testing, we will use the Stroom feed **TEST-FEED-V1_0**.

So to test the proxy, either from the proxy itself or another connected server, execute the command

```bash
curl -k --data-binary @/etc/group "https://stroomsap0.strmdev00.org/stroom/datafeed" -H "Feed:TEST-FEED-V1_0" -H "System:EXAMPLE_SYSTEM" -H "Environment:EXAMPLE_ENVIRONMENT"
```

In the stroom proxy log, `~/stroom-proxy/instance/logs/stroom.log`, you will see the arrival of the file via both the _handler.LogRequestHandler_ and  _datafeed.DataFeedRequestHandler$1_ events running under, in this case, the _ajp-apr-9009-exec-1_ thread.
```
...
2017-01-02T02:10:00.325Z INFO  [Repository Reader Thread 1] handler.ProxyRepositoryReader (ProxyRepositoryReader.java:143) - run() - Cron Match at 2017-01-02T02:10:00.325Z
2017-01-02T02:11:34.501Z INFO  [ajp-apr-9009-exec-1] handler.LogRequestHandler (LogRequestHandler.java:37) - log() - guid=ebd11215-7d4c-4be6-a524-358015e2ac38,feed=TEST-FEED-V1_0,system=EXAMPLE_SYSTEM,environment=EXAMPLE_ENVIRONMENT,remotehost=192.168.2.220,remoteaddress=192.168.2.220
2017-01-02T02:11:34.528Z INFO  [ajp-apr-9009-exec-1] datafeed.DataFeedRequestHandler$1 (DataFeedRequestHandler.java:104) - "doPost() - Took 33 ms to process (concurrentRequestCount=1) 200","Environment=EXAMPLE_ENVIRONMENT","Expect=100-continue","Feed=TEST-FEED-V1_0","GUID=ebd11215-7d4c-4be6-a524-358015e2ac38","ReceivedTime=2017-01-02T02:11:34.501Z","RemoteAddress=192.168.2.220","RemoteHost=192.168.2.220","System=EXAMPLE_SYSTEM","accept=*/*","content-length=1051","content-type=application/x-www-form-urlencoded","host=stroomsap0.strmdev00.org","user-agent=curl/7.19.7 (x86_64-redhat-linux-gnu) libcurl/7.19.7 NSS/3.21 Basic ECC zlib/1.2.3 libidn/1.18 libssh2/1.4.2"
...
```

Further, if you check the proxy's repository directory, you will see the file `001.zip`. The file names number upwards from 001.
```bash
ls -l /stroomdata/stroom-working/proxy
```
shows
```
[stroomuser@stroomsap0 ~]$ ls -l /stroomdata/stroom-working/proxy
total 4
-rw-rw-r--. 1 stroomuser stroomuser 1107 Jan  2 13:11 001.zip
[stroomuser@stroomsap0 ~]$ 
```
On viewing the contents of this file we see both a `.dat` and `.meta` file.
```
[stroomuser@stroomsap0 ~]$ (cd /stroomdata/stroom-working/proxy; unzip 001.zip)
Archive:  001.zip
  inflating: 001.dat                 
  inflating: 001.meta                
[stroomuser@stroomsap0 ~]$
```
The `.dat` file holds the content of the file we posted - `/etc/group`.
```
[stroomuser@stroomsap0 ~]$ (cd /stroomdata/stroom-working/proxy; head -5 001.dat)
root:x:0:
bin:x:1:bin,daemon
daemon:x:2:bin,daemon
sys:x:3:bin,adm
adm:x:4:adm,daemon
[stroomuser@stroomsap0 ~]$ 
```
The `.meta` file is generated by the proxy and holds information about the posted file
```
[stroomuser@stroomsap0 ~]$ (cd /stroomdata/stroom-working/proxy; cat 001.meta)
content-type:application/x-www-form-urlencoded
Environment:EXAMPLE_ENVIRONMENT
Feed:TEST-FEED-V1_0
GUID:ebd11215-7d4c-4be6-a524-358015e2ac38
host:stroomsap0.strmdev00.org
ReceivedTime:2017-01-02T02:11:34.501Z
RemoteAddress:192.168.2.220
RemoteHost:192.168.2.220
StreamSize:1051
System:EXAMPLE_SYSTEM
user-agent:curl/7.19.7 (x86_64-redhat-linux-gnu) libcurl/7.19.7 NSS/3.21 Basic ECC zlib/1.2.3 libidn/1.18 libssh2/1.4.2
[stroomuser@stroomsap0 ~]$ (cd /stroomdata/stroom-working/proxy; rm 001.meta 001.dat)
[stroomuser@stroomsap0 ~]$ 
```

