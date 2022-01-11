---
title: "SSL Certificate Generation"
linkTitle: "SSL Certificate Generation"
#weight:
date: 2021-07-12
tags: 
  - certificates
  - installation
description: >
  A HOWTO to assist users in setting up various SSL Certificates to support a Web interface to Stroom.
---

## Assumptions
The following assumptions are used in this document.
 - the user has reasonable RHEL/Centos System administration skills
 - installations are on Centos 7.3 minimal systems (fully patched)
 - either a Stroom Proxy or Stroom Application has already been deployed
 - processing node names are 'stroomp00.strmdev00.org' and 'stroomp01.strmdev00.org'
 - the first node, 'stroomp00.strmdev00.org' also has a CNAME 'stroomp.strmdev00.org'
 - in the scenario of a Stroom Forwarding Proxy, the node name is 'stroomfp0.strmdev00.org'
 - in the scenario of a Stroom Standalone Proxy, the node name is 'stroomsap0.strmdev00.org'
 - stroom runs as user 'stroomuser'
 - the use of self signed certificates is appropriate for test systems, but users should consider appropriate CA infrastructure in production environments
 - in this document, when a screen capture is documented, data entry is identified by the data surrounded by '<__' '__>' . This excludes enter/return presses.

## Create certificates
The first step is to establish a self signed certificate for our Stroom service. If you have a certificate server, then certainly gain an
appropriately signed certificate. For this HOWTO, we will stay with a self signed solution and hence no certificate authorities are
involved. If you are deploying a cluster, then you will only have one certificate for all nodes. We achieve this by setting up an
alias for the first node in the cluster and then use that alias for addressing the cluster. That is, we have set up a
CNAME, `stroomp.strmdev00.org` for `stroomp00.strmdev00.org`. This means within the web service we deploy, the ServerName will be `stroomp.strmdev00.org`
on each node. Since it's one certificate we only need to set it up on one node then deploy the certificate key files to other nodes.

As the certificates will be stored in the `stroomuser's` home directory, we become the stroom user
```bash
sudo -i -u stroomuser
```

### Use host variable
To make things simpler in the following bash extracts, we establish the bash variable `H` to be used in filename generation. The variable name
is set to the name of the host (or cluster alias) your are deploying the certificates on. In our multi node HOWTO example we are using, we
would use the host CNAME `stroomp`.  Thus we execute

```bash
export H=stroomp
```

Note in our the Stroom Forwarding Proxy HOWTO we would use the name `stroomfp0`. In the case of our Standalone Proxy we would use `stroomsap0`.

We set up a directory to house our certificates via
```bash
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
Enter pass phrase for private/stroomp.key: <__ENTER_SERVER_KEY_PASSWORD__>
Verifying - Enter pass phrase for private/stroomp.key: <__ENTER_SERVER_KEY_PASSWORD__>
```

Create a signing request. The two important prompts are the password and Common Name. All the rest can use the defaults offered.
The requested password is for the server key and you should use the host (or cluster alias) your are deploying the certificates on for
the Common Name. In the output below we will assume a multi node cluster certificate is being generated, so will use `stroomp.strmdev00.org`.

```bash
openssl req -sha256 -new -key private/$H.key -out $H.csr
```
as per
```
Enter pass phrase for private/stroomp.key: <__ENTER_SERVER_KEY_PASSWORD__>
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
Common Name (eg, your name or your server's hostname) []:<__ stroomp.strmdev00.org __> 
Email Address []:

Please enter the following 'extra' attributes
to be sent with your certificate request
A challenge password []:
An optional company name []:
```


We now self sign the certificate (again enter the server key password)
```bash
openssl x509 -req -sha256 -days 720 -in $H.csr -signkey private/$H.key -out public/$H.crt
```
as per
```
Signature ok
subject=/C=XX/L=Default City/O=Default Company Ltd/CN=stroomp.strmdev00.org
Getting Private key
Enter pass phrase for private/stroomp.key: <__ENTER_SERVER_KEY_PASSWORD__>
```
and noting the `subject` will change depending on the host name used when generating the signing request.

Create insecure version of private key for Apache autoboot (you will again need to enter the server key password)
```bash
openssl rsa -in private/$H.key -out private/$H.key.insecure
```
as per
```
Enter pass phrase for private/stroomp.key: <__ENTER_SERVER_KEY_PASSWORD__>
writing RSA key
```
and then move the insecure keys as appropriate
```bash
mv private/$H.key private/$H.key.secure
chmod 600 private/$H.key.secure
mv private/$H.key.insecure private/$H.key
```

We have now completed the creation of our certificates and keys.

### Replication of Keys Directory to other nodes
If you are deploying a multi node Stroom cluster, then you would replicate the directory ~stroomuser/stroom-jks to each node in the cluster. That is,
tar it up, copy the tar file to the other node(s) then untar it. We can make use of the other node's mounted file system for this process.
That is one could execute the commands on the first node, where we created the certificates
```bash
cd ~stroomuser
tar cf stroom-jks.tar stroom-jks
mv stroom-jks.tar /stroomdata/stroom-data-p01
```
then on the another node, say `stroomp01.strmdev00.org`, as the stroomuser we extract the data.
```bash
sudo -i -u stroomuser
cd ~stroomuser
tar xf /stroomdata/stroom-data-p01/stroom-jks.tar && rm -f /stroomdata/stroom-data-p01/stroom-jks.tar
```

### Protection, Ownership and SELinux Context
Now ensure protection, ownership and SELinux context for these key files on **ALL** nodes via
```bash
chmod 700 ~stroomuser/stroom-jks/private ~stroomuser/stroom-jks
chown -R stroomuser:stroomuser ~stroomuser/stroom-jks
chcon -R --reference /etc/pki ~stroomuser/stroom-jks
```

## Stroom Proxy to Proxy Key and Trust Stores
In order for a Stroom Forwarding Proxy to communicate to a central Stroom proxy over https, the JVM running the forwarding proxy needs
relevant keystores set up.

One would set up a Stroom's forwarding proxy SSL certificate as per [above](#create-certificates), with the change that the
hostname would be different. That is, in the initial setup, we would set the hostname variable `H` to be the hostname of the forwarding
proxy. Lets say it is `stroomfp0` thus we would set

```bash
export H=stroomfp0
```
and then proceed as [above](#use-host-variable).

Note that you also need the public key of the central Stroom server you will be connecting to. For the following, we will assume
the central Stroom proxy is the _stroomp.strmdev00.org_ server and it's public key is stored in the file `stroomp.crt`. We will store
this file on the forwarding proxy in `~stroomuser/stroom-jks/public/stroomp.crt`.

So once you have created the forwarding proxy server's SSL keys and have deployed the central proxy's public key, we next
need to convert the proxy server's SSL keys into DER format. This is done by executing the following.
```bash
cd ~stroomuser/stroom-jks
export H=stroomfp0
export S=stroomp
rm -f ${H}_k.jks ${S}_t.jks
H_k=${H}
S_k=${S}
# Convert public key
openssl x509 -in public/$H.crt -inform PERM -out public/$H.crt.der -outform DER
```

When you convert the local server's private key, you will be prompted for the server key password. 
```bash
# Convert the local server's Private key
openssl pkcs8 -topk8 -nocrypt -in private/$H.key.secure -inform PEM -out private/$H.key.der -outform DER
```
as per
```
Enter pass phrase for private/stroomfp0.key.secure: <__ENTER_SERVER_KEY_PASSWORD__>
```

We now import these keys into our Key Store. As part of the Stroom Proxy release, an Import Keystore application has been provisioned. We identify where it's found with the command
```bash
find ~stroomuser/*proxy -name 'stroom*util*.jar' -print | head -1
```
which should return _/home/stroomuser/stroom-proxy/lib/stroom-proxy-util-v5.1-beta.10.jar_ or similar depending on the release version.
To make execution simpler, we set this as a shell variable as per
```bash
Stroom_UTIL_JAR=`find ~/*proxy -name 'stroom*util*.jar' -print | head -1`
```
We now create the keystore and import the proxy's server key
```bash
java -cp ${Stroom_UTIL_JAR} stroom.util.cert.ImportKey keystore=${H}_k.jks keypass=$H alias=$H keyfile=private/$H.key.der certfile=public/$H.crt.der
```
as per
```
One certificate, no chain
```
We now import the destination server's public key
```bash
keytool -import -noprompt -alias ${S} -file public/${S}.crt -keystore ${S}_k.jks -storepass ${S}
```
as per
```
Certificate was added to keystore
```

We now add the key and trust store location and password arguments to our Stroom proxy environment files.
```bash
PWD=`pwd`
echo "export JAVA_OPTS=\"-Djavax.net.ssl.trustStore=${PWD}/${S}_k.jks -Djavax.net.ssl.trustStorePassword=${S} -Djavax.net.ssl.keyStore=${PWD}/${H}_k.jks -Djavax.net.ssl.keyStorePassword=${H}\"" >> ~/env.sh
echo "JAVA_OPTS=\"-Djavax.net.ssl.trustStore=${PWD}/${S}_k.jks -Djavax.net.ssl.trustStorePassword=${S} -Djavax.net.ssl.keyStore=${PWD}/${H}_k.jks -Djavax.net.ssl.keyStorePassword=${H}\"" >> ~/env_service.sh
```

At this point you should restart the proxy service. Using the commands
```bash
cd ~stroomuser
source ./env.sh
stroom-proxy/bin/stop.sh
stroom-proxy/bin/start.sh
```
then check the logs to ensure it started correctly.

