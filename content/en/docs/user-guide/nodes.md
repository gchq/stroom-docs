---
title: "Nodes"
linkTitle: "Nodes"
#weight:
date: 2021-07-27
tags:
  - TODO
  - cluster
  - node
description: >
  Configuring the nodes in a Stroom cluster.
---

All nodes in an Stroom cluster must be configured correctly for them to communicate with each other.

## Configuring nodes
Open Monitoring/Nodes from the top menu. The nodes screen looks like this:

{{% todo %}}
Screenshot
{{% /todo %}}

You need to edit each line by selecting it and then clicking the edit {{< stroom-icon "edit.svg" "Edit" >}} icon at the bottom.
The URL for each node needs to be set as above but obviously substituting in the host name of the individual node, e.g. `http://<HOST_NAME>:8080/stroom/clustercall.rpc`

Nodes are expected communicate with each other on port 8080 over http.
Ensure you have configured your firewall to allow nodes to talk to each other over this port.
You can configure the URL to use a different port and possibly HTTPS but performance will be better with HTTP as no SSL termination is required.

Once you have set the URLs of each node you should also set the master assignment priority for each node to be different to all of the others.
In the image above the priorities have been set in a random fashion to ensure that node3 assumes the role of master node for as long as it is enabled.
You also need to check all of the nodes are enabled that you want to take part in processing or any other jobs.

Keep refreshing the table until all nodes show healthy pings as above.
If you do not get ping results for each node then they are not configured correctly.

Once a cluster is configured correctly you will get proper distribution of processing tasks and search will be able to access all nodes to take part in a distributed query.
