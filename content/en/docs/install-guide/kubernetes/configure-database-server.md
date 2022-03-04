---
title: "Configure Database"
linkTitle: "Configure Database"
weight: 50
date: 2022-03-04
tags: 
description: >
  How to configure the database server for a Stroom cluster.

---

Before creating a Stroom cluster, a database server must first be configured.

There are two options for deploying a MySQL database for Stroom:


## Managed by Stroom K8s Operator

A Database server can be created and managed by the Operator.
This is the recommended option, as the Operator will take care of the creation and storage of database credentials, which are shared securely with the Pod via the use of a `Secret` cluster resource.


### Create a `DatabaseServer` resource manifest 

Use the example at {{< external-link "database-server.yaml" "https://github.com/p-kimberley/stroom-k8s-operator/blob/master/samples/database-server.yaml" >}}.

See the `DatabaseServer` Custom Resource Definition (CRD) {{< external-link "API documentation" "https://doc.crds.dev/github.com/p-kimberley/stroom-k8s-operator/stroom.gchq.github.io/DatabaseServer/v1" >}} for an explanation of the various CRD fields.

By default, MySQL imposes a limit of 151 concurrent connections.
If your Stroom cluster is larger than a few nodes, it is likely you will exceed this limit.
Therefore, it is recommended to set the MySQL property `max_connections` to a suitable value.

Bear in mind the Operator generally consumes one connection per `StroomCluster` it manages, so be sure to include some headroom in your allocation.

You can specify this value via the `spec.additionalConfig` property as in the example below:

```yaml
apiVersion: stroom.gchq.github.io/v1
kind: DatabaseServer
...
spec:
  additionalConfig:
    - max_connections=1000
...
```

### Provision a `PersistentVolume` for the `DatabaseServer`

General instructions on creating a Kubernetes Persistent Volume (PV) are explained {{< external-link "here" "https://kubernetes.io/docs/concepts/storage/persistent-volumes/" >}}.

The Operator will create `StatefulSet` when the `DatabaseServer` is deployed, which will attempt to claim a `PersistentVolume` matching the specification provided in `DatabaseServer.spec.volumeClaim`.

Fast, low-latency storage should be used for the Stroom database


### Deploy the `DatabaseServer` to the cluster

{{< command-line "user" "localhost" >}}
kubectl apply -f database-server.yaml
{{</ command-line >}}

Observe the Pod `stroom-<database server name>-db` start up.
Once it's reached `Ready` state, the server has started, and the databases you specified have been created.


### Backup the created credentials

The Operator generates a `Secret` containing the passwords of the users `root` and `stroomuser` when it initially creates the `DatabaseServer` resource.
These credentials should be backed up to a secure location, in the event the `Secret` is inadvertently deleted.

The `Secret` is named using the format: `stroom-<db server name>-db` (e.g. `stroom-dev-db`).


## External

You may alternatively provide the connection details of an existing MySQL (or compatible) database server.
This may be desirable if you have for instance, a replication-enabled MySQL InnoDB cluster.


### Provision the server and Stroom databases

{{% todo %}}
Complete this secion.
{{% /todo %}}


### Store credentials in a `Secret`

Create a `Secret` in the same namespace as the `StroomCluster`, containing the key `stroomuser`, with the value set to the password of that user.

{{% warning %}}
If at any time the MySQL password is updated, the value of the `Secret` must also be changed.
Otherwise, Stroom will stop functioning.
{{% /warning %}}

## Upgrading or removing a `DatabaseServer`

A `DatabaseServer` cannot shut down while its dependent `StroomCluster` is running.
This is a necessary safeguard to prevent database connectivity from being lost.

Upgrading or removing a `DatabaseServer` requires the `StroomCluster` be [removed]({{< relref "stop-stroom-cluster" >}}) first.


## Next steps

[Configure](configure-stroom-cluster.md) a Stroom cluster
