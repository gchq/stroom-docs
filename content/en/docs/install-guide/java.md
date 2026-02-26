---
title: "Java"
linkTitle: "Java"
#weight:
date: 2026-02-26
tags: 
description: >
  Stroom and Stroom-Proxy both run on Java.
  This section details the requirements they have in terms of Java.
---

## Recommended Java Distribution

There are multiple distributions of Java available (Oracle, OpenJDK, Adoptium, Azul, etc).
Our recommendation is to use {{< external-link "Adoptium Eclipse Temurin" "https://adoptium.net/en-GB/temurin/releases" >}} as this is free and Open Source and has 4 year support periods for Long Term Support (LTS) releases of Java.

## JDK or JRE

Java distributions are available as a Java Development Kit or a Java Runtime Environment.
The JDK is primarily intended for development of Java applications (i.e. compiling code) while the JRE is simply for running a compiled application.

However, we recommend installing the JDK as this can run an application in the same way as the JRE, but also provides additional tools to aid in debugging the application if required.
For example the JDK includes the `jmap` binary that can be used by Stroom to capture statistics on object use within the Java Heap.


## Java Releases

Java now has a regular release cycle of new major versions.
Periodically a Java release will be deemed a Long Term Support (LTS) releases, e.g. Java v11, v17 & v25.
Intermediate version have a short support lifecycle.

Stroom and Stroom-Proxy versions will now typically require an LTS releases of Java as a minimum.
While you can run a later release of Java than that required by the Stroom/Stroom-Proxy release, it is generally simpler to run the minimum required version. Using the same LTS release means you will get security/bug updates for 4 or so years and you don't need to worry about any breaking changes that a later version of Java may have introduced.

The following lists the minimum required Java version required by each Stroom release.

| Stroom/Stroom-Proxy Version | Minimum Java Version |
| --------------------------- | -------------------- |
| v7.11                       | v25                  |
| v7.10                       | v21                  |
| v7.9                        | v21                  |
| v7.8                        | v21                  |
| v7.7                        | v21                  |
| v7.6                        | v21                  |
| v7.5                        | v21                  |
| v7.4                        | v21                  |
| v7.3                        | v21                  |
| v7.2                        | v17                  |
| v7.1                        | v17                  |
| v7.0                        | v15                  |


## Installing Java

See {{< external-link "Linux Installation Instructions" "https://adoptium.net/en-GB/installation/linux#centosrhelfedora-instructions" >}} for details of how to install the JDK using your package manager.

Alternatively, see {{< external-link "Adoptium Eclipse Temurin" "https://adoptium.net/en-GB/temurin/releases" >}} for links to download the Java binaries for manual installation.

