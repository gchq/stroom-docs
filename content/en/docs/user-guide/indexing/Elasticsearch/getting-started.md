---
title: "Getting Started"
linkTitle: "Getting Started"
weight: 2
date: 2022-12-15
tags:
  - search
  - elastic
  - elasticsearch
  - kibana
description: >
  Establishing an Elasticsearch cluster connection
---

## Establish an Elasticsearch cluster connection in Stroom

The first step is to configure Stroom to connect to an Elasticsearch cluster. You can configure multiple cluster connections if required, such as a separate one for production and another for development. Each cluster connection is defined by an `Elastic Cluster` document within the Stroom UI.

1. In the Stroom Explorer pane ({{< stroom-icon "explorer.svg" "Explorer" >}}), right-click on the folder where you want to create the `Elastic Cluster` document.
2. Select `New` -> `Elastic Cluster`.
3. Give the cluster document a name and press `OK`.
4. Complete the fields as explained in the [section below]({{< relref "#elastic-cluster-document-fields" >}}). Any fields not marked as "Optional" are mandatory.
5. Click `Test Connection`. A dialog will display with the test result. If `Connection Success`, details of the target cluster will be displayed. Otherwise, error details will be displayed.
6. Click {{< stroom-icon "save.svg" "Save" >}} to commit changes.

{{% warning %}}
Ensure you restrict permissions to the `Elastic Cluster` document. The `Read` privilege permits retrieval of the Elasticsearch API key and secret, granting the holder the same level of privilege as Stroom. Users authorised to search Elasticsearch indices via Stroom dashboards should only be assigned the `Use` privilege.
{{% /warning %}}

## Elastic Cluster document fields

### Description

(Optional) You might choose to enter the Elasticsearch cluster name or purpose here.

### Connection URLs

Enter one or more node or cluster addresses, including protocol, hostname and port. Only HTTPS is supported; attempts to use plain-text HTTP will fail.

#### Examples

1. Local development node: https://localhost:9200
2. FQDN: https://elasticsearch.example.com:9200
3. Kubernetes service: https://prod-es-http.elastic.svc:9200

### CA certificate

PEM-format CA certificate chain used by Stroom to verify TLS connections to the Elasticsearch HTTPS REST interface. This is usually your organisation's root enterprise CA certificate. For development, you can provide a self-signed certificate.

### Use authentication

(Optional) Tick this box if Elasticsearch requires authentication. This is enabled by default from Elasticsearch version 8.0.

### API key ID

Required if `Use authentication` is checked. Specifies the Elasticsearch API key ID for a valid Elasticsearch user account. This user requires at a minimum the following [privileges](https://www.elastic.co/guide/en/kibana/current/kibana-role-management.html):

#### Cluster privileges

1. monitor
2. manage_own_api_key

#### Index privileges

1. all

### API key secret

Required if `Use authentication` is checked.

### Socket timeout (ms)

Number of milliseconds to wait for an Elasticsearch indexing or search REST call to complete. Set to `-1` (the default) to wait indefinitely, or until Elasticsearch closes the connection.

## Next topic

[Indexing data]({{< relref "indexing.md" >}})