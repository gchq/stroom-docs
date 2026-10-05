---
title: "Setup"
linkTitle: "Setup"
weight: 50
date: 2021-08-20
tags: 
description: >
  Setting up the dependencies, authentication and first administrator for a Stroom installation.
---

Once Stroom has been installed there are a number of things that need to be set up before it can be used.
The order below is the one that most installations will want to follow.

1. [MySQL Setup]({{< relref "mysql-server-setup" >}}) - creating the database and the accounts Stroom uses to reach it.
1. [Processing Users]({{< relref "processing-user-setup" >}}) - the operating system account that Stroom and Stroom-Proxy run as.
1. [Java Key Store Setup]({{< relref "java-key-store-setup" >}}) - the certificates used for secure communication.
1. [Open ID Connect]({{< relref "open-id" >}}) - choosing and configuring the {{< glossary "idp" >}} that will authenticate your users.
1. [Creating the First Administrator]({{< relref "create-first-admin" >}}) - giving the new installation somebody who can log in and administer it.
1. [Securing Stroom]({{< relref "securing-stroom" >}}) - hardening the deployment.

{{% note %}}
Creating the first administrator is easily missed.
A new installation normally has no administrator at all, so until that step is done nobody can log in and configure Stroom.
{{% /note %}}
