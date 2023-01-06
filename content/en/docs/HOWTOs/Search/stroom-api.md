---
title: "Stroom Search API"
linkTitle: "Stroom Search API"
#weight:
date: 2021-07-12
tags: 
description: >
  Stroom v6 introduced an API that allows a user to perform queries against Stroom resources such as indices and statistics.
  This is a guide to show how to perform a Stroom Query directly from bash using Stroom v7.
---

1. Create an API Key for yourself, this will allow the API to authenticate as you and run the query with your privileges.

1. Create a Dashboard that extracts the data you are interested in. You should create a Query and Table.

1. Download the JSON for your Query.
   Press the download icon in the Query Pane to generate a file containing the JSON.
   Save the JSON to a file named *query.json*.

1. Use curl to send the query to Stroom.
   {{< command-line "user" "localhost" >}}
API_KEY='<put your API Key here' \
URI=stroom.host/api/searchable/v2/search \
curl \
-s \
--request POST \
${URL} \
-o response.out \
-H "Authorization:Bearer ${API_KEY}" \
-H "Content-Type: application/json" \
--data-binary @query.json
   {{</ command-line >}}

1. The query response should be in a file named response.out.

1. Optional step: reformat the response to csv using `jq`.

   {{< command-line "user" "localhost" >}}
   cat response.out | jq '.results[0].rows[].values | @csv'
   {{</ command-line >}}
