---
title: "Stroom Architecture"
linkTitle: "Architecture"
weight: 20
date: 2022-01-24
tags: 
description: >
  
---

## Overview

Stroom's architecture varies, depending on largely the choice of deployment method.
The types of deployment currently supported are:

1. Traditional, bare-metal install without the use of containers
1. Docker deployment
    1. Using Docker Compose with a Stroom stack and the stroom docker images.
    1. Using Kubernetes with the stroom docker images.
1. A mixed deployment with some containers and some bare metal installations.

An architecture diagram is included below, depicting a notional Stroom cluster consisting of two nodes.
This represents a reference architecture and deployment for stroom but it is possible to deploy the various services in many different ways, e.g. using a different web server to Nginx or introducing hardware load balancers.

{{< image "architecture/architecture.puml.svg" >}}Architecture Diagram{{< /image >}}


## Changes from previous versions

Stroom v7 features a number of key changes to architecture compared to v5 and v6.
They are:

1. The authentication service is now integrated with the Stroom app as it was with v5, instead of in v6 where it existed as a separate microservice.
  There is now an option for Stroom to authenticate via an external sign-on provider, using the Open ID Connect (OIDC) Protocol.
1. The API has been expanded and the local `stroom-proxy` now uses the API to query feed status, instead of querying MySQL directly.


## Nginx

In a reference deployment Nginx is key to the whole architecture.
It acts in the following capacities:

* A reverse proxy to abstract clients from the multiple service instances.
* An API gateway to route all service traffic.
* The termination point for client SSL traffic.
* A load balancer to balance the load across all the nodes.


### Reverse Proxy

Nginx is used to reverse proxy all client connections (even those from within the estate) to the various services that sit behind it.
For example, a client request to `https://nginx-host/stroom` will be reverse proxied to `http://a-stroom-host:8080/stroom`.
Nginx is responsible for selecting the upstream server to reverse proxy to.
It is possible to use multiple instances of Nginx for redundancy or improved performance, however care needs to be taken to ensure all requests for a session go to the same Nginx instance, i.e. sticky sessions.
Some requests are stateful and some are stateless but the Nginx configuration will reverse proxy them accordingly.


### API Gateway

Nginx is also used as an API gateway.
This means all inter-service calls go via the Nginx gateway so each service only needs to know the location of the Nginx gateway.
Nginx will then reverse proxy all requests to the appropriate instance of an upstream service.

The grey dashed lines on the diagram attempt to show the effective inter-service connections that are being made if you ignore the Nginx reverse proxying.


### SSL Termination

All SSL termination is handled by Nginx.
Nginx holds the server and certificate authority certificate and will authenticate the client requests if the client has a certificate.
Any client certificate details will be passed on to the service that is being reverse proxied.


## Physical Deployment


### Single Node Docker Deployment

The simplest deployment of stroom is where all services are on a single host and each service runs in its own docker container.
Such a deployment can be achieved by following [these instructions]({{< relref "single-node-docker" >}}).

The following diagram shows how a single node deployment would look.

{{< image "architecture/stroom-6-deployment-docker-single.puml.svg" >}}Logical Architecture Diagram{{< /image >}}


### Multi Node Mixed Deployment

The typical deployment for a large scale stroom is where stroom is run on multiple hosts to scale out the processing.
In this deployment stroom and MySQL are run directly on the host OS, i.e. without docker.
This approach was taken to gradually introduce docker into the stroom deployment strategies.

The following diagram shows how a multi node deployment would look.

{{< image "architecture/stroom-6-deployment-mixed-multi.puml.svg" >}}Logical Architecture Diagram{{< /image >}}


### Multi Node Docker Deployment

The aim in future is to run all services in docker in a multi node deployment.
Such a deployment is still under development and will likely involve kubernetes for container orchestration.
