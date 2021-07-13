# Configuring a Stroom database server

Before creating a Stroom cluster, a database server must first be configured.

There are two options for deploying a MySQL database for Stroom:

## 1. Managed by Stroom K8s Operator

A Database server can be created and managed by the Operator. This is the recommended option, as the Operator will take care
of the creation and storage of database credentials, which are shared securely with the Pod via the use of a `Secret` cluster resource.

### 1.1. Create a `DatabaseServer` resource manifest like the example [database-server.yaml](https://github.com/p-kimberley/stroom-k8s-operator/blob/master/samples/database-server.yaml)

> See the `DatabaseServer` Custom Resource Definition (CRD) [API documentation](https://doc.crds.dev/github.com/p-kimberley/stroom-k8s-operator/stroom.gchq.github.io/DatabaseServer/v1)
> for an explanation of the various CRD fields

### 1.2. Provision a `PersistentVolume` for the `DatabaseServer`

General instructions on creating a Kubernetes Persistent Volume (PV) are explained [here](https://kubernetes.io/docs/concepts/storage/persistent-volumes/).

The Operator will create `StatefulSet` when the `DatabaseServer` is deployed, which will attempt to claim a
`PersistentVolume` matching the specification provided in `DatabaseServer.spec.volumeClaim`.

Fast, low-latency storage should be used for the Stroom database

### 1.3. Deploy the `DatabaseServer` to the cluster

```
kubectl apply -f database-server.yaml
```

Observe the Pod `stroom-<database server name>-db` start up. Once it's reached `Ready` state, the server has started, and
the databases you specified have been created.

### 1.4. Backup the created credentials

The Operator generates a `Secret` containing the passwords of the users `root` and `stroomuser` when it initially
creates the `DatabaseServer` resource. These credentials should be backed up to a secure location, in the event the
`Secret` is inadvertently deleted.

The `Secret` is named using the format: `stroom-<db server name>-db` (e.g. `stroom-dev-db`).

## 2. External

You may alternatively provide the connection details of an existing MySQL (or compatible) database server.
This may be desirable if you have for instance, a replication-enabled MySQL InnoDB cluster.

### 2.1. Provision the server and Stroom databases

### 2.2. Store credentials in a `Secret`

Create a `Secret` in the same namespace as the `StroomCluster`, containing the key `stroomuser`, with the value set to
the password of that user.

> **IMPORTANT**: If at any time the MySQL password is updated, the value of the `Secret` must also be changed.
> Otherwise, Stroom will stop functioning.

## Upgrading or removing a `DatabaseServer`

A `DatabaseServer` cannot shut down while its dependent `StroomCluster` is running. This is a necessary safeguard
to prevent database connectivity from being lost.

Upgrading or removing a `DatabaseServer` requires the `StroomCluster` be [removed](stop-stroom-cluster.md) first.

## Next steps

[Configure](configure-stroom-cluster.md) a Stroom cluster