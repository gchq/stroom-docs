# Configure Stroom task autoscaling

## Motivation

Setting optimal Stroom stream processor task limits is a crucial factor in running a healthy, performant cluster.
If a node is allocated too many tasks, it may become unresponsive or crash. Conversely, if allocated too few tasks,
it may have CPU cycles to spare.

The optimal number of tasks is often time-dependent, as load will usually fluctuate during the day and night.
In large deployments, it's not ideal to set static limits, as doing so risks over-committing nodes during intense spikes
in activity (such as backlog processing or multiple concurrent searches). Therefore an automated solution,
factoring in system load, is called for.

## Stroom task autoscaling

When a `StroomTaskAutoscaler` resource is deployed to a linked `StroomCluster`, the Operator will periodically
compare each Stroom node's average Pod CPU usage against user-defined thresholds.

## Enabling autoscaling

### 1. Create an `StroomTaskAutoscaler` resource manifest like the example [autoscaler.yaml](https://github.com/p-kimberley/stroom-k8s-operator/blob/master/samples/autoscaler.yaml)

Below is an explanation of some of the main parameters.
The rest are documented [here](https://doc.crds.dev/github.com/p-kimberley/stroom-k8s-operator/stroom.gchq.github.io/StroomTaskAutoscaler/v1).

* `adjustmentIntervalMins` Determines how often the Operator will check whether a node has exceeded its CPU
parameters. It should be often enough to catch brief load spikes, but not too often as to overload the Operator
and Kubernetes cluster through excessive API calls and other overhead.
* `metricsSlidingWindowMin` is the window of time over which CPU usage is averaged. Should not be too small,
otherwise momentary load spikes could cause task limits to be reduced unnecessarily. Too large and spikes
  may not cause throttling to occur.
* `minCpuPercent` and `maxCpuPercent` should be set to a reasonably tight range, in order to keep the task limit as close to optimal as possible.
* `minTaskLimit` and `maxTaskLimit` are considered safeguards to avoid nodes ever being allocated an unreasonable
  number of task. Setting `maxTaskLimit` to be equal to the number of assigned CPUs would be a reasonable
  starting point.
  
> A node's task limits will only be adjusted while its task queue is full. That is, unless a node is fully-committed,
> it will not be scaled. This is to avoid continually downscaling each node to the minimum during periods of
> inactivity. Because of this, be realistic with setting `maxTaskLimit` to ensure the node is actually capable of
> hitting that maximum. If it can't, the autoscaler will continue adjusting upwards, potentially causing the node to
> become unresponsive.

### 2. Deploy the resource manifest

```
kubectl apply -f autoscaler.yaml
```

## Disable autoscaling

Delete the `StroomTaskAutoscaler` resource

```
kubectl delete -f autoscaler.yaml
```