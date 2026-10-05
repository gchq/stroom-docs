---
title: "Param Functions"
linkTitle: "Param Functions"
#weight:
date: 2026-08-13
tags: 
description: >
  Functions that return details of the user running the query.
---

## Current User

Returns the display name of the current logged in user, falling back to their subject id, then their full name, if they do not have one.

```clike
currentUser()
```

Example

```clike
currentUser()
> 'jbloggs'
```


## Current User Display Name

Returns the display name of the current logged in user, or null if they do not have one.

```clike
currentUserDisplayName()
```

Example

```clike
currentUserDisplayName()
> 'jbloggs'
```


## Current User Full Name

Returns the full name of the current logged in user, or null if they do not have one.

```clike
currentUserFullName()
```

Example

```clike
currentUserFullName()
> 'Joe Bloggs'
```


## Current User Subject Id

Returns the subject id of the current logged in user, i.e. the unique identifier for the user as supplied by the identity provider, or null if they do not have one.

```clike
currentUserSubjectId()
```

Example

```clike
currentUserSubjectId()
> 'a1b2c3d4-1234-5678-90ab-cdef12345678'
```


## Current User Uuid

Returns the UUID of the current logged in user, i.e. the identifier that Stroom itself holds for the user.
Unlike the other values on this page, every user has one.

```clike
currentUserUuid()
```

Example

```clike
currentUserUuid()
> '9f8e7d6c-4321-8765-ba09-fedc87654321'
```
