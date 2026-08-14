---
title: "Lookup Functions"
linkTitle: "Lookup Functions"
#weight:
date: 2026-08-13
tags: 
description: >
  Functions for looking values up from a state store.
---

## Get State

Looks up a value from a state store using a key, and an optional effective time for temporally sensitive states.

```clike
getState(map, key)
getState(map, key, effectiveTime)
```

* `map` - The name of the map that contains the state, i.e. the name of the Plan B store.
* `key` - The key to lookup.
* `effectiveTime` - The effective time for the state lookup.

Returns the state value if one is found, else `null`.

Where `effectiveTime` is supplied, the value returned is the one that was effective at that time, which is what you want when looking a value up against the time of an event rather than the time the query is run.
If it is omitted then the current time is used.

Example

```clike
getState('USER_TO_TEAM', 'jbloggs')
> 'Team A'
```
