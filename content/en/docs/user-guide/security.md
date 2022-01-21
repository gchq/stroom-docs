---
title: "Security"
linkTitle: "Security"
#weight:
date: 2021-07-27
tags:
  - security
description: >
  There are many aspects of security that should be considered when installing and running Stroom.
---

## Shared Storage

For most large installations Stroom uses shared storage for its data store. This storage could be a CIFS, NFS or similar shared file system. It is recommended that access to this shared storage is protected so that only the application can access it. This could be achieved by placing the storage and application behind a firewall and by requiring appropriate authentication to the shared storage. It should be noted that NFS is unauthenticated so should be used with appropriate safeguards.

## MySQL

### Accounts

It is beyond the scope of this article to discuss this in detail but all MySQL accounts should be secured on initial install. Official guidance for doing this can be found [here (external link)](https://dev.mysql.com/doc/refman/5.6/en/security.html).

### Communication

Communication between MySQL and the application should be secured. This can be achieved in one of the following ways:
* Placing MySQL and the application behind a firewall
* Securing communication through the use of iptables
* Making MySQL and the application communicate over SSL (see [here (external link)](https://dev.mysql.com/doc/refman/5.6/en/encrypted-connections.html) for instructions)

The above options are not mutually exclusive and may be combined to better secure communication.

## Application

### Node to node communication

In a multi node Stroom deployment each node communicates with the master node. This can be configured securely in one of several ways:
* Direct communication to Tomcat on port 8080 - Secured by being behind a firewall or using iptables
* Direct communication to Tomcat on port 8443 - Secured using SSL and certificates
* Removal of Tomcat connectors other than AJP and configuration of Apache to communicate on port 443 using SSL and certificates

### Application to Stroom Proxy Communication

The application can be configured to share some information with Stroom Proxy so that Stroom Proxy can decide whether or not to accept data for certain feeds based on the existence of the feed or it's reject/accept status. The amount of information shared between the application and the proxy is minimal but could be used to discover what feeds are present within the system. Securing this communication is harder as both the application and the proxy will not typically reside behind the same firewall. Despite this communication can still be performed over SSL thus protecting this potential attack vector.

### Admin port

Stroom (v6 and above) and its associated family of stroom-* DropWizard based services all expose an admin port (8081 in the case of stroom). This port serves up various health check and monitoring pages as well as a number of restful services for initiating admin tasks. There is currently no authentication on this admin port so it is assumed that access to this port will be tightly controlled using a firewall, iptables or similar.

### Servlets

There are several servlets in Stroom that are accessible by certain URLs. Considerations should be made about what URLs are made available via Apache and who can access them. The servlets, path and function are described below:

| Servlet | Path | Function | Risk |
| --- | --- | ----- | ----- |
| DataFeed | /datafeed or /datafeed/* | Used to receive data | Possible denial of service attack by posting too much data/noise |
| RemoteFeedService | /remoting/remotefeedservice.rpc | Used by proxy to ask application about feed status (described in previous section) | Possible to systematically discover which feeds are available. Communication with this service should be secured over SSL discussed above |
| DynamicCSSServlet | /stroom/dynamic.css | Serves dynamic CSS based on theme configuration | Low risk as no important data is made available by this servlet |
| DispatchService | /stroom/dispatch.rpc | Service for UI and server communication | All back-end services accessed by this umbrella service are secured appropriately by the application |
| ImportFileServlet | /stroom/importfile.rpc | Used during configuration upload | Users must be authenticated and have appropriate permissions to import configuration |
| ScriptServlet | /stroom/script | Serves user defined visualisation scripts to the UI | The visualisation script is considered to be part of the application just as the CSS so is not secured |
| ClusterCallService | /clustercall.rpc | Used for node to node communication as discussed above | Communication must be secured as discussed above |
| ExportConfig | /export/* | Servlet used to export configuration data | Servlet access must be restricted with Apache to prevent configuration data being made available to unauthenticated users |
| Status | /status | Shows the application status including volume usage | Needs to be secured so that only appropriate users can see the application status |
| Echo | /echo | Block GZIP data posted to the echo servlet is sent back uncompressed. This is a utility servlet for decompression of external data | URL should be secured or not made available |
| Debug | /debug | Servlet for echoing HTTP header arguments including certificate details | Should be secured in production environments |
| SessionList | /sessionList | Lists the logged in users | Needs to be secured so that only appropriate users can see who is logged in |
| SessionResourceStore | /resourcestore/* | Used to create, download and delete temporary files liked to a users session such as data for export | This is secured by using the users session and requiring authentication |

## HDFS, Kafka, HBase, Zookeeper

Stroom and stroom-stats can integrate with HDFS, Kafka, HBase and Zookeeper. It should be noted that communication with these external services is currently not secure. Until additional security measures (e.g. authentication) are put in place it is assumed that access to these services will be careful controlled (using a firewall, iptables or similar) so that only stroom nodes can access the open ports.

## Content

It may be possible for a user to write XSLT, Data Splitter or other content that may expose data that we do not wish to or to cause the application some harm. At present processing operations are not isolated processes and so it is easy to cripple processing performance with a badly written translation whether written accidentally or on purpose. To mitigate this risk it is recommended that users that are given permission to create XSLT, Data Splitter and Pipeline configurations are trusted to do so.

Visualisations can be completely customised with javascript. The javascript that is added is executed in a clients browser potentially opening up the possibility of XSS attacks, an attack on the application to access data that a user shouldn't be able to access, an attack to destroy data or simply failure/incorrect operation of the user interface. To mitigate this risk all user defined javascript is executed within a separate browser IFrame. In addition all javascript should be examined before being added to a production system unless the author is trusted. This may necessitate the creation of a separate development and testing environment for user content.
