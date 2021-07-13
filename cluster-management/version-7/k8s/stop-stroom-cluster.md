# Stopping a Stroom cluster

A Stroom cluster can be stopped by deleting the `StroomCluster` resource that was deployed.
When this occurs, the Operator will perform the following actions for each node, in sequence:

1. Disable processing of all tasks.
1. Wait for all processing tasks to be completed. This check is performed once every minute, so there may be a brief
   delay between a node completed its tasks before being shut down.
1. Terminate the container.

The `StroomCluster` resource will be removed from the Kubernetes cluster once all nodes have finished processing tasks.

> The `StroomCluster.spec.nodeTerminationGracePeriodSecs` is an important setting that determines how long the Operator will wait
> for each node's tasks to complete before terminating it. Ensure this is set to a reasonable value, otherwise
> long-running tasks may not have enough time to finish if the `StroomCluster` is taken down (e.g. for maintenance).

## Stopping the cluster

```
kubectl delete -f stroom-cluster.yaml
kubectl delete -f database-server.yaml
```

If a `StroomTaskAutoscaler` was created, remove that as well.

If any of these commands appear to hang with no response, that's normal; the Operator is likely waiting
for tasks to drain. You may press `Ctrl+C` to return to the shell and task termination will continue in the background.

> If the `StroomCluster` deletion appears to be hung, you can inspect the Operator logs to see which nodes are
> holding up deletion due to outstanding tasks. You will see a list of one or more node names, with the number
> of tasks outstanding in brackets (e.g. `StroomCluster deletion waiting on task completing for 1 nodes: stroom-dev-node-data-0 (5)`).

Once the `StroomCluster` is removed, it can be reconfigured (if required) and redeployed, using the same
process as in [Configure a Stroom cluster](configure-stroom-cluster.md).

## `PersistentVolumeClaim` deletion

When a Stroom node is shut down, by default its `PersistentVolumeClaim` will remain. This ensures it gets re-assigned
the same `PersistentVolume` when it starts up again.

This behaviour should satisfy most use cases. However the operator may be configured to delete the PVC in certain situations,
by specifying the `StroomCluster.spec.volumeClaimDeletePolicy`:

1. `DeleteOnScaledownOnly` deletes a node's PVC where the number of nodes in the `NodeSet` is reduced and
   as a result, the node Pod is no longer part of the `NodeSet`
1. `DeleteOnScaledownAndClusterDeletion` deletes the PVC if the node Pod is removed. 

## Next steps

[Removing](remove-operator.md) the Stroom K8s Operator