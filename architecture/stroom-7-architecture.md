# Stroom 7 Architecture

Stroom v7 features a number of key changes to architecture compared to v5 and v6. They are:

1. The authentication service is now integrated with the Stroom app as it was with v5, instead of in v6 where it existed as a separate microservice.
There is now an option for Stroom to authenticate via an external sign-on provider, using the Open ID Connect (OIDC) Protocol.
1. The API has been expanded and the local `stroom-proxy` now uses the API to query feed status, instead of querying MySQL directly.

Stroom's architecture varies, depending on largely the choice of deployment method. The types of deployment currently supported are:

1. Traditional, bare-metal install without the use of containers
1. Docker deployment, through the use of startup scripts and Docker Compose
1. Kubernetes, using 

An architecture diagram is included below, depicting a notional Stroom cluster consisting of two nodes.

![Architecture Diagram](/diagrams/stroom-7-non-containerised.puml.svg)