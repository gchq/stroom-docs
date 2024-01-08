---
title: "Software Stack"
linkTitle: "Software Stack"
weight: 10
date: 2022-02-10
tags: 
description: >
  The software stack used by the Stroom family of products.

---

## Stroom and Stroom Proxy

Stroom and Stroom Proxy live in the same repository, share some common code and are built by the same Gradle build.


### Languages and key frameworks

* Java 15 - The language for the core application
  * {{< external-link "Dropwizard" "https://www.dropwizard.io/en/latest/#" >}} - A RESTful framework incorporating embedded Jetty.
  * Junit 5
  * SLF4j and Logback
  * Mockito
  * Jooq - Generates Java code for type safe SQL.
  * {{< external-link "Apache Lucene" "https://lucene.apache.org" >}} - The search library used by Stroom's indexes and dashboard queries.
  * {{< external-link "Lightning Memory Mapped Database" "http://www.lmdb.tech/doc/" >}} - Used for memory mapped persistent reference and search data stores.
* React - Some of the new UI screens.
  * Typescript


### Build and development tools

* Gradle - Building the java application and orcestrating related sub-builds, e.g. npm.
* Github Actions - The CI build and release.
* Bash - Various utility shell scripts.
* Docker - Building the stroom and stroom-proxy docker images.
* Docker Compose - 
* Docker containers - Provide consistent build environments for
  * Java
  * npm
  * Plant UML
* npm - For the build of the new React based UI screens.

### Services

* Nginx - Used for SSL termination, load balancing and reverse proxying.
* MySQL - Database for persistence in Stroom.


