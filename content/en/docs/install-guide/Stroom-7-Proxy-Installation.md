---
title: "Stroom Proxy Installation"
linkTitle: "Stroom Proxy Installation"
#weight:
date: 2021-08-20
tags: 
  - proxy
description: >
  
---

There are 2 versions of the stroom software availble for building a proxy server.  
There is an 'app' version that runs stroom as a Java ARchive (jar) file locally on the server and has settings contained in a configuration file that controls access to the stroom server and database.  
The other version runs stroom proxy within docker containers and also has a settings configuration file that controls access to the stroom server and database.  
The document will cover the installation and configuration of the stroom proxy software for both the docker and 'app' versions.  
&nbsp;


## Assumptions

The following assumptions are used in this document.
- the user has reasonable RHEL/CentOS System administration skills.
- installation is on a fully patched minimal CentOS 7 instance.
- the Stroom database has been created and resides on the host `stroomdb0.strmdev00.org` listening on port 3307.
- the Stroom database user is `stroomuser` with a password of `Stroompassword1@`.
- the application user `stroomuser` has been created.
- the user is or has deployed the two node Stroom cluster described [here]({{< relref "../HOWTOs/Install/InstallHowTo.md#storage-scenario" >}}).
- the user has set up the Stroom processing user as described [here]({{< relref "../HOWTOs/Install/InstallProcessingUserSetupHowTo.md" >}}).
- the prerequisite software has been installed.
- when a screen capture is documented, data entry is identified by the data surrounded by '<__' '__>' . This excludes enter/return presses.  

&nbsp;  

&nbsp;  

## Stroom Remote Proxy (docker version)

The build of a stroom proxy where the stroom applications are running in docker containers.  
The operating system (OS) build for a 'dockerised' stroom proxy is minimal RHEL/CentOS 7 plus the docker-ce & docker-compose packages.  
Neither of the pre-requisites are available from the CentOS ditribution.  
It will also be necessary to open additional ports on the system firewall (where appropriate).  
&nbsp;  


### Download and install docker
To download and install - docker-ce - from the internet, a new 'repo' file is downloaded first, that provides access to the docker.com repository. 
e.g. as *root* user:
&nbsp;  

- wget https://download.docker.com/linux/centos/docker-ce.repo -O /etc/yum.repos.d/docker-ce.repo
- yum install docker-ce.x86_64

The packages - docker-ce docker-ce-cli & containerd.io - will be installed 

&nbsp;  

The docker-compose software can de downloaded from github 
e.g. as *root* user to download docker-compose version 1.25.4 and save it to -  /usr/local/bin/docker-compose 
- curl -L https://github.com/docker/compose/releases/download/1.25.4/docker-compose-Linux-x86_64 -o /usr/local/bin/docker-compose
- chmod 755 /usr/local/bin/docker-compose

&nbsp;  


### Firewall Configuration

If you have a firewall running additional ports will need to be opened, to allow the Docker containers to talk to each other.  
Currently these ports are:  

- 3307
- 8080
- 8081
- 8090
- 8091
- 8543
- 5000
- 2888
- 443
- 80

For example on a RHEL/CentOS server using `firewalld` the commands would be as *root* user:  

```
firewall-cmd --zone=public --permanent --add-port=3307/tcp  
firewall-cmd --zone=public --permanent --add-port=8080/tcp  
firewall-cmd --zone=public --permanent --add-port=8081/tcp  
firewall-cmd --zone=public --permanent --add-port=8090/tcp  
firewall-cmd --zone=public --permanent --add-port=8091/tcp  
firewall-cmd --zone=public --permanent --add-port=8099/tcp  
firewall-cmd --zone=public --permanent --add-port=5000/tcp  
firewall-cmd --zone=public --permanent --add-port=2888/tcp  
firewall-cmd --zone=public --permanent --add-port=443/tcp  
firewall-cmd --zone=public --permanent --add-port=80/tcp  
firewall-cmd --reload  
```

&nbsp;  
&nbsp;  

### Download and install Stroom v7 (docker version)
The installation example below is for stroom version 7.0.beta.45 - but is applicable to other stroom v7 versions.  
As a suitable stroom user e.g. stroomuser - download and unpack the stroom software.  

- wget https://github.com/gchq/stroom-resources/releases/download/stroom-stacks-v7.0-beta.41/stroom_proxy-v7.0-beta.45.tar.gz
- tar zxf stroom-stacks…………..

&nbsp;  

For a stroom proxy, the configuration file - stroom_proxy/stroom_proxy-v7.0-beta.45/stroom_proxy.env  
needs to be edited, with the connection details of the stroom server that data files will be sent to.  
The default network port for connection to the stroom server is 8080
The values that need to be set are:  
STROOM_PROXY_REMOTE_FEED_STATUS_API_KEY  
STROOM_PROXY_REMOTE_FEED_STATUS_URL  
STROOM_PROXY_REMOTE_FORWARD_URL  

The 'API key' is generated on the stroom server and is related to a specific user e.g. proxyServiceUser
The 2 URL values also refer to the stroom server and can be a fully qualified domain name (fqdn) or the IP Address.  
&nbsp;  

e.g. if the stroom server was - stroom-serve.somewhere.co.uk - the URL lines would be:  
export STROOM_PROXY_REMOTE_FEED_STATUS_URL="http://stroom-serve.somewhere.co.uk:8080/api/feedStatus/v1"  
export STROOM_PROXY_REMOTE_FORWARD_URL="http://stroom-serve.somewhere.co.uk:8080/stroom/datafeed"

&nbsp;  

### To Start Stroom Proxy
As the stroom user, run the 'start.sh' script found in the stroom install:

- cd ~/stroom_proxy/stroom_proxy-v7.0-beta.45/
- ./start.sh  

The first time the script is ran it will download from github the docker containers for a stroom proxy  
these are - stroom-proxy-remote, stroom-log-sender and nginx.  
Once the script has completed the stroom proxy server should be running.
There are additional scripts - status.sh - that will show the status of the docker containers (stroom-proxy-remote, stroom-log-sender and nginx)
and - logs.sh - that will tail all of the stroom message files to the screen.   

&nbsp;  

&nbsp;  



## Stroom Remote Proxy (app version)

The build of a stroom proxy server, where the stroom application is running locally as a Java ARchive (jar) file.  
The operating system (OS) build for an 'application' stroom proxy is minimal RHEL/CentOS 7 plus Java.  
&nbsp;  

The Java version required for stroom v7 is 12+ This version of Java is not available from the RHEL/CentOS distribution.  
The version of Java used below is the 'openJDK' version as opposed to Oracle's version.  
This can be downloaded from the internet.  

Version 12.0.1  
wget https://download.java.net/java/GA/jdk12.0.1/69cfe15208a647278a19ef0990eea691/12/GPL/openjdk-12.0.1_lin
ux-x64_bin.tar.gz
*Or version 14.0.2 https://download.java.net/java/GA/jdk14.0.2/205943a0976c4ed48cb16f1043c5c647/12/GPL/openjdk-14.0.2_linux-x64_bin.tar.gz* 
&nbsp;  

The gzipped tar file needs to be untarred and moved to a suitable location. 
- tar xvf openjdk-12.0.1_linux-x64_bin.tar.gz
- mv jdk-12.0.1 /opt/  
&nbsp;  

Create a shell script that will define the Java variables	OR add the statements to .bash_profile
e.g. vi /etc/profile.d/jdk12.sh  
export JAVA_HOME=/opt/jdk-12.0.1  
export PATH=$PATH:$JAVA_HOME/bin  

- source /etc/profile.d/jdk12.sh  
- echo $JAVA_HOME  
/opt/jdk-12.0.1  

- java --version
*openjdk version "12.0.1" 2019-04-16*  
*OpenJDK Runtime Environment (build 12.0.1+12)*  
*OpenJDK 64-Bit Server VM (build 12.0.1+12, mixed mode, sharing)*  

&nbsp;  

**Disable selinux to avoid issues with access and file permissions. **  
 
&nbsp;


### Firewall Configuration

If you have a firewall running additional ports will need to be opened, to allow the Docker containers to talk to each other.  
Currently these ports are:  

- 3307
- 8080
- 8081
- 8090
- 8091
- 8543
- 5000
- 2888
- 443
- 80

For example on a RHEL/CentOS server using `firewalld` the commands would be as *root* user:  

```
firewall-cmd --zone=public --permanent --add-port=3307/tcp  
firewall-cmd --zone=public --permanent --add-port=8080/tcp  
firewall-cmd --zone=public --permanent --add-port=8081/tcp  
firewall-cmd --zone=public --permanent --add-port=8090/tcp  
firewall-cmd --zone=public --permanent --add-port=8091/tcp  
firewall-cmd --zone=public --permanent --add-port=8099/tcp  
firewall-cmd --zone=public --permanent --add-port=5000/tcp  
firewall-cmd --zone=public --permanent --add-port=2888/tcp  
firewall-cmd --zone=public --permanent --add-port=443/tcp  
firewall-cmd --zone=public --permanent --add-port=80/tcp  
firewall-cmd --reload  
```
&nbsp;  
&nbsp;  


### Download and install Stroom v7 (app version)
The installation example below is for stroom version 7.0.beta.45 - but is applicable to other stroom v7 versions.  
As a suitable stroom user e.g. stroomuser - download and unpack the stroom software.  

```
wget https://github.com/gchq/stroom/releases/download/v7.0-beta.45/stroom-proxy-app-v7.0-beta.45.zip
unzip stroom-proxy-app..............
```
&nbsp;  

The configuration file – `stroom-proxy/config/config.yml` – is the principal file to be edited, as it contains  

- connection details to the stroom server
- the locations of the proxy server log files   
- the directory on the proxy server, where data files will be stored prior to forwarding onot stroom 
- the location of the PKI Java keystore (jks) files  
&nbsp;  

The log file locations are changed to be relative to where stroom is started i.e. `~stroomuser/stroom-proxy/logs/…`..

```
currentLogFilename: logs/events/event.log		
archivedLogFilenamePattern: logs/events/event-%d{yyyy-MM-dd'T'HH:mm}.log
currentLogFilename: logs/events/event.log
archivedLogFilenamePattern: logs/events/event-%d{yyyy-MM-dd'T'HH:mm}.log
currentLogFilename: logs/send/send.log
archivedLogFilenamePattern: logs/send/send-%d{yyyy-MM-dd'T'HH:mm}.log.gz
currentLogFilename: logs/app/app.log
archivedLogFilenamePattern: logs/app/app-%d{yyyy-MM-dd'T'HH:mm}.log.gz
```
&nbsp;  

An API key created on the stroom server for a special proxy user is added to the configuration file.
The API key is used to validate access to the application

```
proxyConfig:
  useDefaultOpenIdCredentials: **false**
  proxyContentDir: "/stroom-proxy/content"

  #If you want to use a receipt policy then the RuleSet must exist
  #in Stroom and have the UUID as specified below in receiptPolicyUuid
  #proxyRequestConfig:
  #receiptPolicyUuid: "${RECEIPT_POLICY_UUID:-}"
  feedStatus:
    url: **“http://stroomserver.somewhere.co.uk:8080/api/feedStatus/v1}"**
    apiKey: **" eyJhbGciOiJSUz ……………………….ScdPX0qai5UwlBA"**
  forwardStreamConfig:
    forwardingEnabled: true
```
&nbsp;  

The location of the jks files has to be set, or comment all of the lines that have **sslConfig: & tls:** sections out to not use jks checking. 

Stroom also needs the client & ca ‘jks’ files and by default are located in - **/stroom-proxy/certs/ca.jks & client.jks**
Their location can be changed in the `config.yml`

```
keyStorePath: "/stroom-proxy/certs/client.jks"  
trustStorePath: "/stroom-proxy/certs/ca.jks"  
keyStorePath: "/stroom-proxy/certs/client.jks"  
trustStorePath: "/stroom-proxy/certs/ca.jks"  
```

Could be changed to……………….  
```
keyStorePath: "/home/stroomuser/stroom-proxy/certs/client.jks"  
trustStorePath: "/home/stroomuser/stroom-proxy/certs/ca.jks"  
keyStorePath: "/home/stroomuser/stroom-proxy/certs/client.jks"  
trustStorePath: "/home/stroomuser/stroom-proxy/certs/ca.jks"
```
&nbsp;  

Create a directory - **/stroom-proxy** – and ensure that stroom can write to it  
This is where the proxy data files are stored - **/stroom-proxy/repo**    

```
proxyRepositoryConfig:
    storingEnabled: true
    repoDir: **"/stroom-proxy/repo"**
    format: "${executionUuid}/${year}-${month}-${day}/${feed}/${pathId}/${id}"
```



&nbsp;  




