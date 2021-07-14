# Stroom on Kubernetes (K8s)

[Kubernetes](https://kubernetes.io/) is an open-source system for automating deployment scaling and management of containerised applications.

Stroom is a distributed application designed to handle large-scale dataflows. As such, it is ideally suited to a Kubernetes deployment, especially when operated at scale. Features standard to Kubernetes, like [Ingress](https://kubernetes.io/docs/concepts/services-networking/ingress/) and [Cluster Networking](https://kubernetes.io/docs/concepts/cluster-administration/networking/), simplify the installation and ongoing operation of Stroom.

Running applications in K8s can be challenging for applications not designed to operate in a K8s cluster natively. A purpose-built Kubernetes Operator ([stroom-k8s-operator](https://github.com/p-kimberley/stroom-k8s-operator)) has been developed to make deployment easier, while taking advantage of several key Kubernetes features to further automate Stroom cluster management.

The concept of Kubernetes operators is discussed [here](https://kubernetes.io/docs/concepts/extend-kubernetes/operator/).

## Key features

The Stroom K8s Operator provides the following key features:

### Deployment

1. Simplified configuration, enabling administrators to define the entire state of a Stroom cluster in one file
1. Designate separate processing and UI nodes, to ensure the Stroom user interface remains responsive, regardless of processing load
1. Automatic secrets management

### Operations

1. Scheduled database backups
1. Stroom node audit log shipping
1. Automatically drain Stroom tasks before node shutdown
1. Automatic Stroom task limit tuning, to attempt to keep CPU usage within configured parameters
1. Rolling Stroom version upgrades

## Next steps

Install the [Stroom K8s Operator](install-operator.md)