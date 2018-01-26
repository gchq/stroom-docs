# Queries

Dashboard queries are created with the query expression builder. The expression builder allows for complex boolean logic to be created across multiple index fields. The way in which different index fields may be queried depends on the type of data that the index field contains.

## Date Time Fields

Time fields can be queried for times equal, greater than, greater than or equal, less than, less than or equal or between two times.

Times can be specified in two ways:

* Absolute times

* Relative times


### Absolute Times

An absolute time is specified in ISO 8601 date time format, e.g.  `2016-01-23T12:34:11.844Z`

### Relative Times

In addition to absolute times it is possible to specify times using expressions. Relative time expressions create a date time that is relative to the execution time of the query. Supported expressons are as follows:

* now\(\) - The current execution time of the query.

* second\(\) - The current execution time of the query rounded down to the nearest second.

* minute\(\) - The current execution time of the query rounded down to the nearest minute.

* hour\(\) - The current execution time of the query rounded down to the nearest hour.

* day\(\) - The current execution time of the query rounded down to the nearest day.

* week\(\) - The current execution time of the query rounded down to the first day of the week \(Monday\).

* month\(\) - The current execution time of the query rounded down to the start of the current month.

* year\(\) - The current execution time of the query rounded down to the start of the current year.


### Adding\/Subtracting Durations

With relative times it is possible to add or subtract durations so that queries can be constructed to provide for example, the last week of data, the last hour of data etc.

To add\/subtract a duration from a query term the duration is simply appended after the relative time, e.g.

`now() + 2d`

Multiple durations can be combined in the expression, e.g.

`now() + 2d - 10h`

`now() + 2w - 1d10h`

Durations consist of a number and duration unit. Supported duration units are:

* s - Seconds

* m - Minutes

* h - Hours

* d - Days

* w - Weeks

* M - Months

* y - Years


Using these durations a query to get the last weeks data could be as follows:

`between now() - 1w and now()`

Or midnight a week ago to midnight today:

`between day() - 1w and day()`

Or if you just wanted data for the week so far:

`greater than week()`

Or all data for the previous year:

`between year() - 1y and year()`

Or this year so far:

`greater than year()`

## URI Fields
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
extractQueryFromUri(${URI}) | p1=v1&amp;p2=v2
extractPathFromUri(${URI}) | /very/long/path.html
extractPortFromUri(${URI}) | 8080
extractSchemeFromUri(${URI}) | http
extractSchemeSpecificPartFromUri(${URI}) | //foo:bar@w1.superman.com:8080/very/long/path.html?p1=v1&amp;p2=v2
extractUserInfoFromUri(${URI}) | foo:bar
