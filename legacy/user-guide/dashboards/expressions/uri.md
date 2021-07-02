# URI Functions

Fields containing a Uniform Resource Identifier (URI) in string form can queried to extract the URI's individual components of `authority`, `fragment`, `host`, `path`, `port`, `query`, `scheme`, `schemeSpecificPart` and `userInfo`. See either [RFC 2306: Uniform Resource Identifiers (URI): Generic Syntax](http://www.ietf.org/rfc/rfc2396.txt) or Java's java.net.URI Class for details regarding the components. If any component is not present within the passed URI, then an empty string is returned.

The extraction functions are

* extractAuthorityFromUri\(\) - extract the Authority component
* extractFragmentFromUri\(\) - extract the Fragment component
* extractHostFromUri\(\) - extract the Host component
* extractPathFromUri\(\) - extract the Path component
* extractPortFromUri\(\) - extract the Port component
* extractQueryFromUri\(\) - extract the Query component
* extractSchemeFromUri\(\) - extract the Scheme component
* extractSchemeSpecificPartFromUri\(\) - extract the Scheme specific part component
* extractUserInfoFromUri\(\) - extract the UserInfo component

If the URI is `http://foo:bar@w1.superman.com:8080/very/long/path.html?p1=v1&amp;p2=v2#more-details` the table below displays the extracted components

Expression | Extraction
--- | ---
extractAuthorityFromUri(${URI})	| foo:bar@w1.superman.com:8080
extractFragmentFromUri(${URI}) | more-details
extractHostFromUri(${URI}) | w1.superman.com
extractPathFromUri(${URI}) | /very/long/path.html
extractPortFromUri(${URI}) | 8080
extractQueryFromUri(${URI}) | p1=v1&amp;p2=v2
extractSchemeFromUri(${URI}) | http
extractSchemeSpecificPartFromUri(${URI}) | //foo:bar@w1.superman.com:8080/very/long/path.html?p1=v1&amp;p2=v2
extractUserInfoFromUri(${URI}) | foo:bar

<!-- vim-markdown-toc GFM -->

* [extractAuthorityFromUri](#extractauthorityfromuri)
* [extractFragmentFromUri](#extractfragmentfromuri)
* [extractHostFromUri](#extracthostfromuri)
* [extractPathFromUri](#extractpathfromuri)
* [extractPortFromUri](#extractportfromuri)
* [extractQueryFromUri](#extractqueryfromuri)
* [extractSchemeFromUri](#extractschemefromuri)
* [extractSchemeSpecificPartFromUri](#extractschemespecificpartfromuri)
* [extractUserInfoFromUri](#extractuserinfofromuri)

<!-- vim-markdown-toc -->

## extractAuthorityFromUri
Extracts the Authority component from a URI

`extractAuthorityFromUri(uri)`

Example
```
extractAuthorityFromUri('http://foo:bar@w1.superman.com:8080/very/long/path.html?p1=v1&p2=v2#more-details')
> 'foo:bar@w1.superman.com:8080'
```

## extractFragmentFromUri
Extracts the Fragment component from a URI

`extractFragmentFromUri(uri)`

Example
```
extractFragmentFromUri('http://foo:bar@w1.superman.com:8080/very/long/path.html?p1=v1&p2=v2#more-details')
> 'more-details'
```

## extractHostFromUri
Extracts the Host component from a URI

`extractHostFromUri(uri)`

Example
```
extractHostFromUri('http://foo:bar@w1.superman.com:8080/very/long/path.html?p1=v1&p2=v2#more-details')
> 'w1.superman.com'
```

## extractPathFromUri
Extracts the Path component from a URI

`extractPathFromUri(uri)`

Example
```
extractPathFromUri('http://foo:bar@w1.superman.com:8080/very/long/path.html?p1=v1&p2=v2#more-details')
> '/very/long/path.html'
```

## extractPortFromUri
Extracts the Port component from a URI

`extractPortFromUri(uri)`

Example
```
extractPortFromUri('http://foo:bar@w1.superman.com:8080/very/long/path.html?p1=v1&p2=v2#more-details')
> '8080'
```

## extractQueryFromUri
Extracts the Query component from a URI

`extractQueryFromUri(uri)`

Example
```
extractQueryFromUri('http://foo:bar@w1.superman.com:8080/very/long/path.html?p1=v1&p2=v2#more-details')
> 'p1=v1&p2=v2'
```

## extractSchemeFromUri
Extracts the Scheme component from a URI

`extractSchemeFromUri(uri)`

Example
```
extractSchemeFromUri('http://foo:bar@w1.superman.com:8080/very/long/path.html?p1=v1&p2=v2#more-details')
> 'http'
```

## extractSchemeSpecificPartFromUri
Extracts the SchemeSpecificPart component from a URI

`extractSchemeSpecificPartFromUri(uri)`

Example
```
extractSchemeSpecificPartFromUri('http://foo:bar@w1.superman.com:8080/very/long/path.html?p1=v1&p2=v2#more-details')
> '//foo:bar@w1.superman.com:8080/very/long/path.html?p1=v1&p2=v2'
```

## extractUserInfoFromUri
Extracts the UserInfo component from a URI

`extractUserInfoFromUri(uri)`

Example
```
extractUserInfoFromUri('http://foo:bar@w1.superman.com:8080/very/long/path.html?p1=v1&p2=v2#more-details')
> 'foo:bar'
```
