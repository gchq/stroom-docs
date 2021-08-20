---
title: "Processing Users"
linkTitle: "Processing Users"
#weight:
date: 2021-08-20
tags: 
description: >
  
---

## Processing User Setup

Stroom / Stroom Proxy should be run under a processing user (we assume stroomuser below).

- Setup this user

```bash
/usr/sbin/adduser --system stroomuser
```

- You may want to allow normal accounts to sudo to this account for maintenance (visudo)

- Create a service script to start/stop on server startup (as root).  

```bash
vi /etc/init.d/stroomuser

#!/bin/bash
#
# stroomuser       This shell script takes care of starting and stopping
#               the stroomuser subsystem (tomcat6, etc)
#
# chkconfig: - 86 14
# description: stroomuser is the stroomuser sub system

Stroom_USER=stroomuser

case $1 in
start)
/bin/su ${Stroom_USER} /home/${Stroom_USER}/stroom-deploy/start.sh
;;
stop)
/bin/su ${Stroom_USER} /home/${Stroom_USER}/stroom-deploy/stop.sh
;;
restart)
/bin/su ${Stroom_USER} /home/${Stroom_USER}/stroom-deploy/stop.sh
/bin/su ${Stroom_USER} /home/${Stroom_USER}/stroom-deploy/start.sh
;;
esac
exit 0
```

- Initialise Script

```bash
/bin/chmod +x /etc/init.d/stroomuser
/sbin/chkconfig --level 345 stroomuser on
```

## Install Java 8

```bash
yum install java-1.8.0-openjdk.x86_64
yum install java-1.8.0-openjdk-devel.x86_64
```

## Setup Deployment Scripts 

- As the processing user unpack the stroom-deploy-X-Y-Z-bin.zip generic deployment
scripts in the processing users home directory.

```bash
unzip stroom-deploy-5.0.beta1-bin.zip
```

- Setup env.sh to include JAVA_HOME to point to the installed directory of the JDK 
(this will be platform specific).  vi ~/env.sh

```
# User specific aliases and functions
export JAVA_HOME=/usr/lib/jvm/java-1.8.0
export PATH=${JAVA_HOME}/bin:${PATH}
```
    
- Setup users profile to include the same.  vi ~/.bashrc
 
``` 
# User specific aliases and functions
. ~/env.sh
```	 

- Check that java is installed OK

```bash
[stroomuser@node1 ~]$ . .bashrc
[stroomuser@node1 ~]$ which java
/usr/lib/jvm/java-1.8.0/bin/java

[stroomuser@node1 ~]$ which javac
/usr/lib/jvm/java-1.8.0/bin/javac

[stroomuser@node1 ~]$ java -version
openjdk version "1.8.0_65"
OpenJDK Runtime Environment (build 1.8.0_65-b17)
OpenJDK 64-Bit Server VM (build 25.65-b01, mixed mode)
```
   
- Setup auto deployment crontab script as below (crontab -e)

```bash
[stroomuser@node1 ~]$ crontab -l
# Deploy Script
0,5,10,15,20,25,30,35,40,45,50,55 * * * * /home/stroomuser/stroom-deploy/deploy.sh >> /home/stroomuser/stroom-deploy.log
59 0 * * * rm -f /home/stroomuser/stroom-deploy.log
# Clean system
0 0 * * * /home/stroomuser/stroom-deploy/clean.sh > /dev/null
```
