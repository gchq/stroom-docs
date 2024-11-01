---
title: "Processing Users"
linkTitle: "Processing Users"
weight: 40
date: 2022-02-04
tags: 
description: >
  
---

## Processing User Setup

Stroom and Stroom Proxy should be run under a processing user (we assume _stroomuser_ below).

## Create user

{{< command-line "root" "localhost" >}}
/usr/sbin/adduser --system stroomuser
{{</ command-line >}}

You may want to allow normal accounts to sudo to this account for maintenance (visudo).

## Create service script

Create a service script to start/stop on server startup (as root).  

{{< command-line "root" "localhost" >}}
vi /etc/init.d/stroomuser
{{</ command-line >}}

Paste/type the following content into vi.

```bash
#!/bin/bash
#
# stroomuser       This shell script takes care of starting and stopping
#               the stroomuser subsystem (tomcat6, etc)
#
# chkconfig: - 86 14
# description: stroomuser is the stroomuser sub system

STROOM_USER=stroomuser
DEPLOY_DIR=/home/${STROOM_USER}/stroom-deploy

case $1 in
start)
/bin/su ${STROOM_USER} ${DEPLOY_DIR}/stroom-deploy/start.sh
;;
stop)
/bin/su ${STROOM_USER} ${DEPLOY_DIR}/stroom-deploy/stop.sh
;;
restart)
/bin/su ${STROOM_USER} ${DEPLOY_DIR}/stroom-deploy/stop.sh
/bin/su ${STROOM_USER} ${DEPLOY_DIR}/stroom-deploy/start.sh
;;
esac
exit 0
```

Now initialise the script.

{{< command-line "root" "localhost" >}}
/bin/chmod +x /etc/init.d/stroomuser
/sbin/chkconfig --level 345 stroomuser on
{{</ command-line >}}


### Setup user's environment


Setup `env.sh` to include `JAVA_HOME` to point to the installed directory of the JDK (this will be platform specific).

{{< command-line "stroomuser" "localhost" >}}
vi ~/env.sh
{{</ command-line >}}

In vi add the following lines.

```bash
# User specific aliases and functions
export JAVA_HOME=/usr/lib/jvm/java-1.8.0
export PATH=${JAVA_HOME}/bin:${PATH}
```

Setup the user's profile to include source the env script.

{{< command-line "stroomuser" "localhost" >}}
vi ~/.bashrc
{{</ command-line >}}
 
In vi add the following lines.

``` bash
# User specific aliases and functions
. ~/env.sh
```	 

### Verify Java installation

Assuming you are using Stroom without using docker and have installed Java, verify that the processing user can use the Java installation.

> The shell output below may show a different version of Java to the one you are using.

{{< command-line "stroomuser" "localhost" >}}
. .bashrc
which java
(out)/usr/lib/jvm/java-1.8.0/bin/java

which javac
(out)/usr/lib/jvm/java-1.8.0/bin/javac

java -version
(out)openjdk version "1.8.0_65"
(out)OpenJDK Runtime Environment (build 1.8.0_65-b17)
(out)OpenJDK 64-Bit Server VM (build 25.65-b01, mixed mode)
{{</ command-line >}}
