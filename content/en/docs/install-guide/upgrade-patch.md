---
title: "Stroom Upgrades"
linkTitle: "Stroom Upgrades"
weight: 90
date: 2021-08-20
tags: 
  - upgrade
description: >
  
---

## Stroom v6+

Stroom is designed to detect the version of the database schema present and to run any migrations necessary to bring it up to the version begin deployed.

### Docker stack deployments

*TODO*

### Non-docker deployments

*TODO*

### Major version upgrades

The following notes are specific for these major version upgrades

* [v6 => v7]({{< relref "./upgrades/6_to_7_upgrade.md" >}})


## Stroom v5

The cleanest way to upgrade or patch is to simply remove the installed content and reinstall.  For example: 

```bash
./stroom-deploy/stop.sh
rm -fr stroom-app*

<unzip new builds as per install instructions>
<run setup.sh as per install instructions>

./stroom-deploy/start.sh
```

**It is extremely important** that you enter the configuration parameters correctly.  In particular the node name should match the current node name otherwise Stroom will create a new node in the system thinking it is part of a cluster.  It is recommended that you copy the original parameters file values used in the original installation to help with this (e.g. cp stroom-app/bin/~setup.xml /tmp/orig-stroom-app-setup.xml.

You should remove and reinstall all components you originally installed i.e. stroom-deploy-X-Y-Z, stroom-app-X-Y-X as required.

You should temporary disable the cron auto deploy script if you have it running during the above.

### Patching 

You can choose for a minor patch (1-2-X) to simply copy the new WAR file into relevant lib directory and run the deploy.sh script (which you may have running on a cron tab).  However this would not patch any potential script or tomcat setting changes.
