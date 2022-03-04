---
title: "Install Operator"
linkTitle: "Install Operator"
weight: 20
date: 2022-03-04
tags: 
description: >
  How to install the Stroom Kubernetes operator.

---

## Prerequisites

1. Kubernetes cluster, version >= 1.20.2
1. {{< external-link "metrics-server" "https://github.com/kubernetes-sigs/metrics-server" >}} (pre-installed with some K8s distributions)
1. `kubectl` and cluster-wide admin access


## Preparation

Stage the following images in a locally-accessible container registry:

1. All images listed in: {{< external-link "https://github.com/p-kimberley/stroom-k8s-operator/blob/master/deploy/images.txt" >}}
1. MySQL (e.g. `mysql/mysql-server:8.0.25`)
1. Stroom (e.g. `gchq/stroom:v7-LATEST`)
1. `gchq/stroom-log-sender:v2.2.0` (only required if log forwarding is enabled)


## Install the Stroom K8s Operator

1. Clone the repository

{{< command-line "user" "localhost" >}}
git clone https://github.com/p-kimberley/stroom-k8s-operator.git
{{</ command-line >}}

1. Edit `./deploy/all-in-one.yaml`, prefixing any referenced images with your private registry URL.
   For example, if your private registry is `my-registry.example.com`, the image `gcr.io/kubebuilder/kube-rbac-proxy:v0.8.0` will become: `my-registry.example.com:5000/gcr.io/kubebuilder/kube-rbac-proxy:v0.8.0`.
1. Deploy the Operator

{{< command-line "user" "localhost" >}}
kubectl apply -f ./deploy/all-in-one.yaml
{{</ command-line >}}

The Stroom K8s Operator is now deployed to namespace `stroom-operator-system`.
You can monitor its progress by watching the Pod named `stroom-operator-controller-manager`.
Once it reaches `Ready` state, you can deploy a Stroom cluster.


## Allocating more resources

If the Operator Pod is killed due to running out of memory, you may want to increase the amount allocated to it.

This can be done by:

1. Editing the `resources.limits` settings of the controller Pod in `all-in-one.yaml`
1. `kubectl apply -f all-in-one.yaml`

{{% note %}}
The Operator retains CPU and memory metrics for all `StroomCluster` Pods for a 60-minute window.
In very large deployments, this may cause it to run out of memory.
{{% /note %}}


## Next steps

[Configure]({{< relref "configure-database-server" >}}) a Stroom database server  
[Upgrade]({{< relref "upgrade-operator" >}})  
[Remove]({{< relref "remove-operator" >}})
