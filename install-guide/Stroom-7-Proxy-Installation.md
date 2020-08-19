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
&nbsp;  


### Download and install docker
To download and install - docker-ce - from the internet, a new 'repo' file is downloaded first. 
e.g. as *root* user:
&nbsp;  

- wget https://download.docker.com/linux/centos/docker-ce.repo -O /etc/yum.repos.d/docker-ce.repo
- yum install docker-ce.x86_64

This will install the packages - docker-ce docker-ce-cli & containerd.io

&nbsp;  

The docker-compose software can de downloaded from github 
e.g. as *root* user to download docker-compose version 1.25.4 and save it to -  /usr/local/bin/docker-compose 
- curl -L https://github.com/docker/compose/releases/download/1.25.4/docker-compose-Linux-x86_64 -o /usr/local/bin/docker-compose
- chmod 755 /usr/local/bin/docker-compose

&nbsp;  

### Download and install Stroom v7 (docker version)
The installation example below is for stroom version 7.0.beta.45 - but is appliacle to other stroom v7 versions.  
As a suitable stroom user e.g. aasuser - download and unpack the stroom software. 

- wget https://github.com/gchq/stroom-resources/releases/download/stroom-stacks-v7.0-beta.41/stroom_proxy-v7.0-beta.45.tar.gz
- tar zxf stroom-stacks…………..

&nbsp;  

Because this is a stroom proxy, the stroom configuration file - stroom_proxy/stroom_proxy-v7.0-beta.45/stroom_proxy.env  
needs to be edited, with the connection details of the stroom server that data files will be sent to.  
The values that need to be set are:
STROOM_PROXY_REMOTE_FEED_STATUS_API_KEY  
STROOM_PROXY_REMOTE_FEED_STATUS_URL  
STROOM_PROXY_REMOTE_FORWARD_URL  

The 'API key' is generated on the stroom server for a specific user e.g. proxyServiceUser. 
The 2 URL values also refer to the stroom server and can be a fully qualiffued domain name (fqdn) or the IP Address.  
&nbsp;  

If, the stroom server was - stroom-serve.somewhere.co.uk - the URL lines would be:  
export STROOM_PROXY_REMOTE_FEED_STATUS_URL="http://stroom-serve.somewhere.co.uk:8080/api/feedStatus/v1"  
export STROOM_PROXY_REMOTE_FORWARD_URL="http://stroom-serve.somewhere.co.uk:8080/stroom/noauth/datafeed"












