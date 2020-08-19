# Installation of Stroom Proxy
The installation and configuration of the Stroom Proxy software for the docker and 'app' versions.  
&nbsp;


## Assumptions
The following assumptions are used in this document.
- the user has reasonable RHEL/CentOS System administration skills.
- installation is on a fully patched minimal CentOS 7 instance.
- the Stroom database has been created and resides on the host `stroomdb0.strmdev00.org` listening on port 3307.
- the Stroom database user is `stroomuser` with a password of `Stroompassword1@`.
- the application user `stroomuser` has been created.
- the user is or has deployed the two node Stroom cluster described [here](InstallHowTo.md#storage-scenario "HOWTO Storage Scenario").
- the user has set up the Stroom processing user as described [here](InstallProcessingUserSetupHowTo.md "Processing User Setup").
- the prerequisite software has been installed.
- when a screen capture is documented, data entry is identified by the data surrounded by '<__' '__>' . This excludes enter/return presses.  

&nbsp;

&nbsp;

  
## Stroom Remote Proxy (docker version)

The operating system (OS) build for a stroom proxy is minimal CentOS plus a pre-requisite of docker-ce & docker-compose.
Neither of the pre-requisites are available from the CentOS ditribution.


### Download and install docker
To download and install - docker-ce - from the internet, a new 'repo' file is downloaded first. 
e.g. as *root* user:

- wget https://download.docker.com/linux/centos/docker-ce.repo -O /etc/yum.repos.d/docker-ce.repo
- yum install docker-ce.x86_64

This will install the packages - docker-ce docker-ce-cli & containerd.io

 
The docker-compose software can de downloaded from github 
e.g. as *root* user to download docker-compose version 1.25.4 and save it to - /usr/local/bin/docker-compose 
- curl -L https://github.com/docker/compose/releases/download/1.25.4/docker-compose-Linux-x86_64 -o /usr/local/bin/docker-compose
- chmod 755 /usr/local/bin/docker-compose



Installed docker version of stroom proxy - stroom_proxy-v7.0-beta.41.tar.gz
wget https://github.com/gchq/stroom-resources/releases/download/stroom-stacks-v7.0-beta.41/stroom_proxy-v7.0-beta.41.tar.gz
tar zxf stroom-stacks…………..

