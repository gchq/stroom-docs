---
title: "LDAP Data Connections"
linkTitle: "LDAP"
weight: 30
date: 2026-11-12
tags:
  - data-source
  - search
  - data-connection
  - ldap
description: >
  Searching an LDAP directory, such as OpenLDAP or Active Directory, with a search filter.
---

An LDAP {{< stroom-doc "DataConnection" >}} searches an LDAP directory.
Each query gives an LDAP search filter in a `sql` clause, and each entry it finds becomes a row.
The fields are `dn` and the attributes listed in the document.


## Settings

_LDAP URL_
: The directory's URL: its scheme, host and port only, e.g. `ldaps://directory.example.org:636`.
  It must match one of the patterns an administrator has allowed in the `stroom.dataConnection.allowedLdapUrlPatterns` property.
  A URL that also gives a base DN, attributes, scope or filter is refused; set those in their own places.

_Use StartTLS_
: Whether to start TLS on an `ldap://` connection before binding, so the password and results are encrypted.
  An `ldaps://` connection is always encrypted.
  Plain `ldap://` without StartTLS can only be used if an administrator turns on the `stroom.dataConnection.allowPlainLdap` property.
  Default: off.

_Credential_
: The _Username / Password_ [credential]({{< relref "docs/user-guide/security/credentials" >}}) to bind with.
  Its username is the full bind DN, e.g. `cn=stroom-reader,ou=Services,dc=example,dc=org`.
  You need _Use_ permission on it, as does anyone who queries this Data Connection.
  Anonymous binds are not allowed, so a credential is required, and it must have a password.

_Base DN_
: Where searches start, e.g. `ou=People,dc=example,dc=org`.
  Queries cannot search outside it.

_Scope_
: How far below the base DN searches reach: the base entry only, the entries directly below it, or the whole subtree.
  Default: the whole subtree.

_Page Size_
: How many entries are fetched in each page of results.
  Default: `500`.

_Minimum Refresh (minutes)_
: The shortest interval at which a dashboard may rerun a query of this Data Connection automatically, to limit the load on the directory.
  `0` sets no minimum beyond the dashboard's own 10 seconds.
  Default: `0`.

_Attributes_
: The attributes read from each entry, each with a type.
  See [Attributes]({{< relref "#attributes" >}}).

The _Time Column_, _Query Timeout_ and _Max Rows_ settings are described in [Settings for Every Type]({{< relref "docs/user-guide/search/data-sources/data-connections#settings-for-every-type" >}}).

{{< stroom-btn "Test Connection" >}} connects, starts TLS if set, binds and reads the base DN's entry.
It reports the directory's vendor, and whether the directory supports paged results.


## Attributes

The fields of a query are `dn`, which every entry has, then each attribute in the _Attributes_ table, in order.
An attribute an entry does not have is empty.

{{< stroom-btn "Detect Attributes" >}} reads the first 100 entries below the base DN and adds the attributes they have to the table, with the type their values suggest.
Attributes already in the table stay, in their place and with their type, so a type you chose survives detecting the attributes again.
It also asks for `createTimestamp` and `modifyTimestamp`, which most directories keep but only return when asked for by name.

Directories return some attributes only when asked for by name, such as operational attributes, and an attribute may only be on later entries.
Add these to the table by name, and remove the ones you do not need, as each attribute is fetched from the directory for every entry.

Each attribute is read as its type:

| Type | Reads |
|------|-------|
| Text | Any attribute. An attribute with several values, such as `memberOf`, gives them all, joined by `; `. Binary values, such as `objectGUID`, are given in base64. |
| Long, Double | A number. |
| Boolean | `TRUE` or `FALSE`, as LDAP writes them, in any case. |
| Date | An LDAP time (GeneralizedTime), such as `createTimestamp` or `whenCreated`, or an Active Directory FILETIME number, such as `lastLogonTimestamp` or `pwdLastSet`. A FILETIME of `0`, or the largest possible value, means no time and is empty. |

An attribute with more than one value, or a binary value, can only be read as Text.
A value that is not of its attribute's type is empty, and the query warns about it.
Detect Attributes suggests Date only for LDAP times, so set FILETIME attributes to Date yourself.


## Writing the Filter

The filter is a standard LDAP search filter, given in a triple-quoted `sql` clause, e.g.

```stroomql
from "Directory"
sql """
(&(objectClass=person)(departmentNumber=:department))
"""
sort by cn
select cn, uid, mail
```

The brackets around a filter may be left off, e.g. `objectClass=person`.

A placeholder takes the value of the query parameter of its name, and `:from` and `:to` take the time range as LDAP times, e.g. `(modifyTimestamp>=:from)`.
See [Parameters]({{< relref "docs/user-guide/search/data-sources/data-connections#parameters" >}}) and [Time Range]({{< relref "docs/user-guide/search/data-sources/data-connections#time-range" >}}).

Each value is escaped as an LDAP filter value, so it can only ever be matched and never change the filter.

* A colon also appears in extensible match filters, such as `(cn:caseExactMatch:=Fred)`, and in values such as times and URLs.
  So a colon only starts a placeholder where a value starts, straight after `=`, `~=`, `>=` or `<=`, or after a `*` wildcard.
  A value that must start with a colon followed by a letter writes the colon as `\3a`.
* Values are escaped for the filter, not for a DN.
  So in a DN-valued filter such as `(member=uid=:user,ou=People,dc=example,dc=org)`, a parameter holding a comma could compare a different DN, though never change the filter.
  Give the whole DN as one parameter instead, e.g. `(member=:memberDn)`.


## Searching

* Entries are fetched a page at a time with the simple paged results control, so a search can read more entries than the directory returns at once.
  The control is not marked critical, so a directory without it still answers, within its own size limit.
* The search stops at the Data Connection's _Max Rows_.
* If the directory's own size or time limit for the bind account ends a search, the query keeps the entries read so far and warns.
  Narrow the filter, or ask the directory's administrator to raise the limit.
* Referrals to other servers are not followed, as the allowed LDAP URLs may not include them.
  The query warns how many there were.
  Search those servers with Data Connections of their own.


## Security

* The URL must match one of the `stroom.dataConnection.allowedLdapUrlPatterns` patterns.
* The connection must be encrypted, with `ldaps://` or StartTLS, unless `stroom.dataConnection.allowPlainLdap` is on.
  Plain LDAP sends the bind password and every result unencrypted, so only use it for test directories.
* The directory's certificate must be trusted by Stroom's Java trust store and name the host in the URL.
* Directories hold personal data, so use a bind account the directory lets read only the entries and attributes Stroom needs.
* Stroom's LDAP client never turns what a directory returns into Java objects, so a directory cannot make Stroom load code.


## Active Directory

Active Directory names some attributes differently from the standard `inetOrgPerson` ones, e.g.:

| Standard | Active Directory |
|----------|------------------|
| `uid` | `sAMAccountName` |
| `departmentNumber` | `department` |
| `createTimestamp` | `whenCreated` |
| `modifyTimestamp` | `whenChanged` |

Its global catalog, on ports 3268 and 3269, can search a whole forest without referrals.
Times such as `lastLogonTimestamp`, `pwdLastSet` and `accountExpires` are FILETIME numbers: set their type to Date to read them as dates.
