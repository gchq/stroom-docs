---
title: "Stroom's Internal IDP"
linkTitle: "Internal IDP"
weight: 20
date: 2022-11-25
tags: 
description: >
  Details about Stroom's own internal identity provider and authentication mechanisms.
  
---

By default a new Stroom instance/cluster will use its own internal IDP for authentication.
A fresh install will come pre-loaded with a user account called `admin` with the password `admin`.
This user is a member of a {{< glossary "group users" "group">}} called `Administrators` which has the `Administrator` application permission.
This admin user can be used to set up the other users on the system.
