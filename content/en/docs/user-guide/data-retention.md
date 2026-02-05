---
title: "Data Retention"
linkTitle: "Data Retention"
weight: 50
date: 2021-07-27
tags:
  - retention
description: >
  Controlling the purging/retention of old data.
---

By default Stroom will retain all the data it ingests and creates forever.
It is likely that storage constraints/costs will mean that data needs to be deleted after a certain time.
It is also likely that certain types of data may need to be kept for longer than other types.

## Rules

Stroom allows for a set of data retention policy rules to be created to control at a fine grained level what data is deleted and what is retained.

The data retention rules are accessible by selecting _Data Retention_ from the _Tools_ menu.
On first use the _Rules_ tab of the _Data Retention_ screen will show a single rule named _Default Retain All Forever Rule_.
This is the implicit rule in stroom that retains all data and is always in play unless another rule overrides it.
This rule cannot be edited, moved or removed.

### Rule Precedence

Rules have a precedence, with a lower rule number being a higher priority.
When running the data retention job, Stroom will look at each stream held on the system and the retention policy of the first rule (starting from the lowest numbered rule) that matches that stream will apply.
One a matching rule is found all other rules with higher rule numbers (lower priority) are ignored.
For example if rule 1 says to retain streams from feed `X-EVENTS` for 10 years and rule 2 says to retain streams from feeds `*-EVENTS` for 1 year then rule 1 would apply to streams from feed `X-EVENTS` and they would be kept for 10 years, but rule 2 would apply to feed `Y-EVENTS` and they would only be kept for 1 year.
Rules are re-numbered as new rules are added/deleted/moved.

### Creating a Rule

To create a rule do the following:

1. Click the {{< stroom-icon "add.svg" "Add" >}} icon to add a new rule.
1. Edit the expression to define the data that the rule will match on.
1. Provide a name for the rule to help describe what its purpose is.
1. Set the retention period for data matching this rule, i.e _Forever_ or a set time period.

The new rule will be added at the top of the list of rules, i.e. with the highest priority.
The {{< stroom-icon "up.svg" "Up" >}} and {{< stroom-icon "down.svg" "Down" >}} icons can be used to change the priority of the rule.

Rules can be enabled/disabled by clicking the checkbox next to the rule.

Changes to rules will not take effect until the {{< stroom-icon "save.svg" "Save" >}} icon is clicked.

Rules can also be deleted ( {{< stroom-icon "delete.svg" "Delete" >}} ) and copied ( {{< stroom-icon "copy.svg" "Copy" >}} ).

## Impact Summary

When you have a number of complex rules it can be difficult to determine what data will actually be deleted next time the _Policy Based Data Retention_ job runs.
To help with this, Stroom has the _Impact Summary_ tab that acts as a dry run for the active rules.
The impact summary provides a count of the number of streams that will be deleted broken down by rule, stream type and feed name.
On large systems with lots of data or complex rules, this query may take a long time to run.

The impact summary operates on the current state of the rules on the _Rules_ tab whether saved or un-saved.
This allows you to make a change to the rules and test its impact before saving it.
