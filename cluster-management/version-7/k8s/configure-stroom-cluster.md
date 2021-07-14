# Configure a Stroom cluster

A `StroomCluster` resource defines the topology and behaviour of a collection of Stroom nodes.

The following key concepts should be understood in order to optimally configure a cluster.

## Concepts

### NodeSet

A logical grouping of nodes intended to together, fulfil a common role. There are three possible roles, as defined by `ProcessingNodeRole`:

1. Undefined (default). Each node in the `NodeSet` can receive and process data, as well as service web frontend requests.
1. `Processing`. Node can receive and process data, but not service web frontend requests.
1. `Frontend`. Node services web frontend requests only.

There is no imposed limit to the number of `NodeSet`s, however it generally doesn't make sense to have more than one assigned to either `Processing` or `Frontend` roles. In clusters where nodes are not very busy, it should not be necessary to have dedicated `Frontend` nodes. In cases where load is prone to spikes, such nodes can greatly help improve the responsiveness of the Stroom user interface.

> It is important to ensure there is at least one `NodeSet` for each role in the `StroomCluster`

The Operator automatically wires up traffic routing to ensure that only non-`Frontend` nodes receive event data. Additionally, `Frontend`-only nodes have server tasks disabled automatically on startup, effectively preventing them from participating in stream processing.

### Ingress

Kubernetes `Ingress` resources determine how requests are routed to an application. `Ingress` resources are configured by the Operator based on the `NodeSet` roles and the provided `StroomCluster.spec.ingress` parameters.

It is possible to disable `Ingress` for a given `NodeSet`, which excludes nodes within that group from receiving any traffic via the public endpoint. This can be useful when creating nodes dedicated to data processing, which do not receive data.

### StroomTaskAutoscaler

`StroomTaskAutoscaler` is an optional resource that if defined, activates "auto-pilot" features for an associated `StroomCluster`. See [this guide](configure-stroomtaskautoscaler.md) on how to configure.

## Creating a Stroom cluster

### 1. Create a `StroomCluster` resource manifest like the example [stroom-cluster.yaml](https://github.com/p-kimberley/stroom-k8s-operator/blob/master/samples/stroom-cluster.yaml)

If you chose to create an Operator-managed `DatabaseServer`, the `StroomCluster.spec.databaseServerRef` should point to the name of the `DatabaseServer`.

> See the `StroomCluster` Custom Resource Definition (CRD) [API documentation](https://doc.crds.dev/github.com/p-kimberley/stroom-k8s-operator/stroom.gchq.github.io/StroomCluster/v1) for an explanation of the various CRD fields

### 2. Provision a `PersistentVolume` for each Stroom node

Each `PersistentVolume` provides persistent local storage for a Stroom node. The amount of storage doesn't generally need to be large, as stream data is stored on another volume. When deciding on a storage quota, be sure to consider the needs of log and reference data, in particular.

This volume should ideally be backed by fast, low-latency storage in order to maximise the performance of LMDB.

### 3. Deploy the `StroomCluster` resource

```
kubectl apply -f stroom-cluster.yaml
```

If the `StroomCluster` configuration is valid, the Operator will deploy a `StatefulSet` for each `NodeSet` defined in `StroomCluster.spec.nodeSets`. Once these `StatefulSet`s reach `Ready` state, you are ready to access the Stroom UI.

> If the `StatefulSet`s don't deploy, there is probably something wrong with your configuration. Check the logs of the pod `stroom-operator-system/stroom-operator-controller-manager` for any errors.

### 4. Log into Stroom

Access the Stroom UI at: `https://<ingress hostname>`. The initial credentials are:

* Username: `admin`
* Password: `admin`

## Further customisation (optional)

The configuration bundled with the Operator provides enough customisation for most use cases, via explicit properties and environment variables.

If you need to further customise Stroom, you have the following methods available:

### Override the Stroom configuration file

Deploy a `ConfigMap` separately. You can then specify the `ConfigMap` `name` and key (`itemName`) containing the configuration file to be mounted into each Stroom node container.

### Provide additional environment variables

Specify custom environment variables in `StroomCluster.spec.extraEnv`. You can reference these in the Stroom configuration file.

### Mount additional files

You can also define additional `Volume`s and `VolumeMount`s to be injected into each Stroom node. This can be useful when providing files like certificates for Kafka integration.

## Reconfiguring the cluster

Some `StroomCluster` configuration properties can be reconfigured while the cluster is still running:

1. `spec.image` Change this to deploy a newer (or different) Stroom version
1. `spec.terminationGracePeriodSecs` Applies the next time a node or cluster is deleted
1. `spec.nodeSets.count` If changed, the `NodeSet`'s `StatefulSet` will be scaled (up or down) to match the corresponding number of replicas

After changing any of the above properties, re-apply the manifest:

```
kubectl apply -f stroom-cluster.yaml
```

If any other changes need to be made, [delete](stop-stroom-cluster.md) then [re-create](configure-stroom-cluster.md) the `StroomCluster`.

## Next steps

[Configure Stroom task autoscaling](configure-stroomtaskautoscaler.md)
[Stop](stop-stroom-cluster.md) a Stroom cluster