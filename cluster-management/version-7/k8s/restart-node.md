# Restart a Stroom node

Stroom nodes may occasionally hang or become unresponsive. In these situations, it may be necessary to terminate the Pod.

After you identify the unresponsive Pod (e.g. by finding a node not responding to cluster ping):

```
kubectl delete pod -n <Stroom cluster namespace> <pod name>
```

This will attempt to drain tasks for the node. After the termination grace period has elapsed, the Pod will be killed and a new one will automatically respawn to take its place. Once the new Pod finishes starting up, if functioning correct it should begin responding to cluster ping.

> Prior to a Stroom node being stopped (for whatever reason), task processing for that node is disabled and it is drained of all active tasks. Task processing is resumed once the node starts up again.

## Force deletion

If waiting for the grace period to elapse is unacceptable and you are willing to risk shutting down the node without draining it first (or you are **sure** it has no active tasks), you can force delete the Pod using the procedure outline in the [Kubernetes documentation](https://kubernetes.io/docs/tasks/run-application/force-delete-stateful-set-pod/):

```
kubectl delete pod -n <Stroom cluster namespace> <pod name> --grace-period=0 --force
```