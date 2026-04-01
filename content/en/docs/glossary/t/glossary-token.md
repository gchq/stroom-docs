---
title: "Token"
linkTitle: "Token"
destination: >
  Typically refers to an authentication token that may be used for user authentication.
  A Stroom _API Key_ is a form of authentication token.
---

Tokens are generally set in the HTTP header `Authorization` with a value of the form `Bearer TOKEN_GOES_HERE`.
Tokens may contain information, e.g. a {{< external-link "JSON Web Tokens (JWT)" "https://en.wikipedia.org/wiki/JSON_Web_Token" >}} or simply be long strings of random characters (to essentially make a very secure password), like API Keys.

Tokens are associated with a Stroom User so have the same or less permissions than that user.
Tokens also typically have an expiry time after which they will no longer work.

{{% see-also %}}
{{< glossary "API Key" >}}
{{% /see-also %}}

