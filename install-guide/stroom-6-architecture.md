# Stroom 6 Architecture & Deployment

The diagram below shows the logical architecture of Stroom v6.
It is not concerned with how/where the various services are deployed.

![Logical Architecture Diagram](http://www.plantuml.com/plantuml/proxy?src=https://raw.githubusercontent.com/gchq/stroom-docs/master/setup/stroom-6-architecture.puml&random=2)

In stroom v6, a central nginx is key to the whole architecture.
It acts in the following capacities:

* The termination point for client SSL traffic.
* An API gateway for all service traffic.
* A reverse proxy to abstract clients from the multiple service instances.

All inter-service calls go via the nginx gateway so each service only needs to know the location of the nginx gateway.
Nginx will reverse proxy all requests to the appropriate instance of an upstream service.

All SSL termination is handled by nginx.

The grey dashed lines on the diagram attempt to show the effective inter-service connections that are being made if you ignore the nginx reverse proxying.

## Physical Deployment

### Single Node Docker Deployment

The simplest deployment of stroom is where all services are on a single host and each service runs in its own docker container.
Such a deployment can be achieved by following [these instructions](dev-guide/docker-running.md).

The following diagram shows how a single node deployment would look.

![Logical Architecture Diagram](http://www.plantuml.com/plantuml/proxy?src=https://raw.githubusercontent.com/gchq/stroom-docs/master/setup/stroom-6-deployment-docker-single.puml&random=2)

### Multi Node Mixed Deployment

The typical deployment for a large scale stroom is where stroom is run on multiple hosts to scale out the processing.
In this deployment stroom and MySQL are run directly on the host OS, i.e. without docker.
This approach was taken to gradually introduce docker into the stroom deployment strategies.

The following diagram shows how a multi node deployment would look.

![Logical Architecture Diagram](http://www.plantuml.com/plantuml/proxy?src=https://raw.githubusercontent.com/gchq/stroom-docs/master/setup/stroom-6-deployment-mixed-multi.puml&random=2)

### Multi Node All docker Deployment

The aim in future is to run all services in docker in a multi node deployment.
Such a deployment is still under development and will likely involve kubernetes for container orchestration.
