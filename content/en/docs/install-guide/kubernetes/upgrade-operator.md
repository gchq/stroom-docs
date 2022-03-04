---
title: "Upgrade Operator"
linkTitle: "Upgrade Operator"
weight: 30
date: 2022-03-04
tags: 
description: >
  How to upgrade the Stroom Kubernetes Operator.
---

Upgrading the Operator can be performed without disrupting any resources it controls, including Stroom clusters.

To perform the upgrade, follow the same steps in [Installing the Stroom K8s Operator]({{< relref "install-operator" >}}).

{{% warning %}}
Ensure you do NOT delete the operator first (i.e. `kubectl delete ...`)
{{% /warning %}}

Once you have initiated the update (by executing `kubectl apply -f all-in-one.yaml`), an instance of the new Operator version will be created.
Once it starts up successfully, the old instance will be removed.

You can check whether the update succeeded by inspecting the image tag of the Operator Pod: `stroom-operator-system/stroom-operator-controller-manager`.
The tag should correspond to the release number that was downloaded (e.g. `1.0.0`)

If the upgrade failed, the existing Operator should still be running.
