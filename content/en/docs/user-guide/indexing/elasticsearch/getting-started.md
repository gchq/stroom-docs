---
title: "Getting Started"
linkTitle: "Getting Started"
weight: 2
date: 2022-12-15
tags:
  - search
  - elastic
  - kibana
description: >
  Establishing an Elasticsearch cluster connection
---


## Establish an Elasticsearch Cluster Connection in Stroom

The first step is to configure Stroom to connect to an Elasticsearch cluster.
You can configure multiple cluster connections if required, such as a separate one for production and another for development.
Each cluster connection is defined by an `Elastic Cluster` document within the Stroom UI.

1. In the Stroom Explorer pane ({{< stroom-icon "folder-tree.svg" "Explorer" >}}), right-click on the folder where you want to create the `Elastic Cluster` document.
1. Select:
   {{< stroom-menu "New" "Elastic Cluster" >}}
1. Give the cluster document a name and press {{< stroom-btn "OK" >}}.
1. On the **Settings** tab, complete the fields as explained in the [section below]({{< relref "#elastic-cluster-document-fields" >}}).
   Any fields not marked as "Optional" are mandatory.
1. Click {{< stroom-btn "Test Connection" >}}.
   A dialog will display with the test result.
   If `Connection Success`, details of the target cluster will be displayed, i.e. its name, UUID, node name and version.
   Otherwise, error details will be displayed.
   Testing needs `Edit` permission on the `Elastic Cluster` document, as the test uses the settings in the form, which may not have been saved yet.
1. Click {{< stroom-icon "save.svg" "Save" >}} to commit changes.

{{< warning >}}
Ensure you restrict permissions to the `Elastic Cluster` document and to the credential holding its API key.
Any processing or search that uses the cluster connects with that API key, granting it the key's privileges in Elasticsearch.
Users authorised to search Elasticsearch indices via Stroom dashboards should only be assigned the `Use` privilege on the `Elastic Cluster` document.
{{< /warning >}}


## Elastic Cluster Document Fields

### Connection URLs

Enter the URLs of the cluster's nodes, one per line, each including its scheme, hostname and port.
Blank lines are ignored.
Requests are spread across the nodes listed, so listing several keeps Stroom connected when one is down.
If the port is omitted, it defaults to `443` for `https` and `80` for `http`.
Use `https` unless the cluster is only reachable over a trusted network.


#### Examples

1. Local development node: `https://localhost:9200`
1. FQDN: `https://elasticsearch.example.com:9200`
1. Kubernetes service: `https://prod-es-http.elastic.svc:9200`


### API Key

(Optional) Select the credential holding the Elasticsearch API key, if the cluster requires authentication.
Authentication is enabled by default from Elasticsearch version 8.0.

The credential must be an `Access Token` credential (see {{< stroom-menu "Security" "Credentials" >}}), whose access token is the base64 encoded API key.
This is the `encoded` value returned by Elasticsearch when the key is created.

The API key requires at a minimum the following {{< external-link "privileges" "https://www.elastic.co/guide/en/kibana/current/kibana-role-management.html" >}}:


#### Cluster Privileges

1. monitor
1. manage_own_api_key


#### Index Privileges

1. all


### Compress Requests

(Optional) Tick this box to compress the body of each request to the cluster with gzip, and accept compressed responses.
Bulk indexing requests usually compress to a fraction of their size, which helps where the network between Stroom and the cluster is slow, at the cost of some CPU on both.
See [Compress Requests over a Slow Network]({{< relref "indexing#compress-requests-over-a-slow-network" >}}).


### Set Http Client Config

(Optional) Click {{< stroom-btn "Set Http Client Config" >}} to set how Stroom connects to the cluster, including:

* Timeouts.
  By default, Stroom waits up to 3 seconds to connect to a node, so that it quickly fails over to another node if one is unreachable, and up to 5 minutes for each response.
* TLS, e.g. a _Trust Store_ holding your organisation's CA certificate, used to verify the cluster's HTTPS certificate.
  For development, you can tick _Trust Self Signed Certificates_ instead, though this accepts any self-signed certificate.
* A proxy.

---

{{< next-page >}}

