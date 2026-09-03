---
title: "Rule Execution"
linkTitle: "Execution"
weight: 20
date: 2026-09-02
tags:
  - analytic
description: >
  Execution schedules, how a scheduled rule works through time, and the history of what it has run.
---

The _Execution_ tab sets the rule's [processing type]({{< relref "_index#processing-types" >}}), and for a _Scheduled Query_ rule it is where you define when the rule runs.

A scheduled rule does not have a single schedule field.
Instead it has a list of _execution schedules_, each of which runs the rule independently.
The tab is split, with the schedules in the upper pane and the history of what those schedules have done in the lower one.

Everything on this page applies equally to [Reports]({{< relref "docs/user-guide/search/reports" >}}) {{< stroom-icon "document/Report.svg" >}}, which use the same execution machinery.


## Execution Schedules

Use the {{< stroom-icon "add.svg" "Add" >}} button above the schedule list to add a schedule.

Field           | Description
--------------- | ------------
Name            | A name for this schedule, used to identify it in the history and recorded on every detection it raises.
Enabled         | Whether this schedule runs. A schedule that is not enabled is ignored.
Processing Node | The node that will run the rule. Use _Set Default_ to use the node configured for the system.
Schedule        | A frequency or {{< glossary "cron" >}} expression saying how often the rule runs.
Start Time      | The effective time of the first run, see [How Time Works]({{< relref "#how-time-works" >}}).
End Time        | An optional effective time after which the schedule stops running.
Run As User     | The {{< glossary "User" >}} whose permissions the query runs with.

{{% see-also %}}
[Scheduler]({{< relref "docs/user-guide/jobs/scheduler" >}})
{{% /see-also %}}

Having more than one schedule on a rule is useful when you want the same query run over different periods.
A common pattern is a frequent schedule that keeps up with new data, plus a second schedule with a start and end time that is used once to work back over history.


### Run as User

The query runs with the permissions of the _Run As User_, not those of whoever created the rule.
If that user cannot see some of the data, the rule will silently detect nothing in it.

{{% note %}}
Changing what a user can see changes what the rules running as that user will detect.
Stroom records these dependencies so that a user cannot be deleted while schedules still run as them.
{{% /note %}}


## How Time Works

Each run of a schedule has two different times associated with it, and telling them apart is the key to understanding scheduled rules.

Time                     | Meaning
------------------------ | --------
Execution Time           | The wall clock time at which the rule actually ran.
Effective Execution Time | The point in time the run represents. This is what relative date expressions in the query resolve against.

For a rule that is keeping up with new data the two are almost the same.
They diverge whenever a rule is catching up, because a rule that is behind will run now for an effective time in the past.

The effective time of the first run comes from the schedule's _Start Time_, or from the next occurrence of the schedule if no start time is set.
After each successful run Stroom records where it has got to, and the next run picks up from there.


### Contiguous Execution

Whether a schedule catches up or skips ahead is decided by whether it is contiguous.

* A **contiguous** schedule takes its next effective time from the last effective time.
  If the rule has not run for a week, it will work forward through that week one run at a time until it catches up.
  No window of data is missed.
* A **non-contiguous** schedule takes its next effective time from the current time.
  If the rule has not run for a week, that week is skipped.

Contiguous execution is what you want for a rule that must not miss anything.
Be aware that it means a rule which has been disabled for a long time, or whose start time is set well in the past, will have a lot of catching up to do when it is enabled.


## Replaying an Execution

Selecting a row in the execution history and clicking {{< stroom-icon "rerun.svg" "Replay Execution" >}} _Replay Execution_ sets up a re-run of that one execution.

Replaying does not run anything immediately.
It adds a **new execution schedule**, named after the original with ` (replay)` appended, whose start and end times are both the effective execution time of the row you selected.
The new schedule is created **disabled**, so nothing happens until you enable it.

This is deliberate, as it gives you the chance to check the bounds before the rule runs again.
Once enabled, the schedule runs the rule once for that effective time and then has nothing further to do.

Replay works on a single history row at a time.
To re-run a range of executions, add an ordinary schedule with the start and end times you want instead.

{{% warning %}}
Re-running an execution will raise its detections again.
Where this is not what you want, use [Duplicate Management]({{< relref "duplicate-management" >}}) to suppress the repeats.
{{% /warning %}}


## Execution History

The lower pane lists what each schedule has done.

Column                   | Description
------------------------ | ------------
Execution Time           | When the run happened.
Effective Execution Time | The point in time the run represents.
Status                   | `Complete` or `Error`.
Message                  | The error message where the run failed.

History is kept for the period set by the `stroom.analytics.executionHistoryRetention` property and is deleted by the _Analytic Execution History Retention_ job.

{{% warning %}}
**A schedule that fails is disabled.**
When a run fails with an error, Stroom disables that execution schedule rather than letting it fail repeatedly.
The rule then stops running, and stays stopped until someone notices and re-enables it.

This is the most common reason for a rule that appears to have quietly stopped working.
Check the _Enabled_ state of the schedule and the last row of the execution history, then look at the rule's error feed for the detail.
{{% /warning %}}


## The Execution Schedule Manager

The rule's _Execution_ tab only shows that rule's schedules.
{{< stroom-menu "Monitoring" "Execution Schedule Manager" >}} shows every execution schedule in the system, for Analytic Rules and Reports alike, and is where bulk operations live.

The list identifies each schedule by the document it belongs to as well as by its own name, and can be filtered.

Button                | Purpose
--------------------- | ---------
Edit Selected Schedule | Edit one schedule, as on the rule itself.
Batch Edit Schedules   | Change the name, enabled state, processing node, schedule, bounds or run as user of many schedules at once.
Filter Schedules       | Narrow the list, for example to one document or one node.
Run Schedules Now      | Force schedules to run without waiting for them to fall due.
Delete Schedules       | Delete the selected schedules.

_Run Schedules Now_ and _Batch Edit Schedules_ can be applied either to the schedules you have selected or to everything matching the current filter.

{{% warning %}}
_Run Schedules Now_ does not run a schedule once.
It forces the selected schedules to process **until they are up to date**, which for a contiguous schedule that is well behind means working through every window between where it had got to and now.
This can take a long time and raise a great many detections, so check what is selected before confirming.

Disabled schedules are not run, and Stroom warns you when the selection contains any.
{{% /warning %}}


## Error Feed

Errors raised while a rule is running are written as `Error` streams to the rule's error feed.

The feed is set by _Feed For Errors_ on the [Settings]({{< relref "settings" >}}) tab rather than on this one.
Where the rule does not name one, the feed configured in `stroom.ui.analyticUiDefaultConfig.defaultErrorFeed` is used, and a run for which neither is set fails.

A run can fail before there is anywhere to write to, for example when neither the rule nor the system configuration names an error feed.
Failures of that kind are recorded against the execution history instead, which is why it is worth looking at both.
