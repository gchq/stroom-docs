---
title: "Minor Upgrades and Patches"
linkTitle: "Minor Upgrades and Patches"
weight: 90
date: 2021-08-20
tags: 
  - upgrade
description: >
  How to upgrade to a new minor or patch release.

---

Stroom versioning follows {{< external-link "Semantic Versioning" "https://semver.org" >}}.

Given a version number _MAJOR_._MINOR_._PATCH_:

* _MAJOR_ is incremented when there are major or breaking changes.
* _MINOR_ is incremented when functionality is added in a backwards compatible manner.
* _PATCH_ is incremented when bugs are fixed.

Stroom is designed to detect the version of the existing database schema and to run any migrations necessary to bring it up to the version begin deployed.
This means you can jump from say 7.0.0 => 7.2.0 or from 7.0.0 to 7.0.5.

This document covers minor and patch upgrades only.


## Docker stack deployments

{{% todo %}}
Complete this
{{% /todo %}}


## Non-docker deployments

{{% todo %}}
Complete this
{{% /todo %}}


## Major version upgrades

The following notes are specific for these major version upgrades

* [v6 => v7]({{< relref "./v6-to-v7.md" >}})

