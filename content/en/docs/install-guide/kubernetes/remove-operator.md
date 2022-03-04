---
title: "Remove Operator"
linkTitle: "Remove Operator"
weight: 40
date: 2022-03-04
#tags: 
description: >
  How to remove the Stroom Kubernetes operator.

---

Removing the Stroom K8s Operator must be done with caution, as it causes all resources it manages, including `StroomCluster`, `DatabaseServer` and `StroomTaskAutoscaler` to be deleted.

While the Stroom clusters under its control _will_ be gracefully terminated, they will become inaccessible until re-deployed.

It is good practice to first delete any dependent resources _before_ deleting the Operator.


## Deleting the Operator

Execute this command against the **same version** of manifest that was used to deploy the Operator currently running.

{{< command-line "user" "localhost" >}}
kubectl delete -f all-in-one.yaml
{{</ command-line >}}
