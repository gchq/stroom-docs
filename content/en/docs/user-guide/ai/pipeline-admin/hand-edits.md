---
title: "Hand edits"
linkTitle: "Hand edits"
weight: 17
date: 2026-10-31
tags:
  - ai
  - pipeline
  - xslt
description: >
  Editing an XSLT the agent generated in Stroom's own editor: what the agent keeps, what it asks you, and what you can't carry back into a mapping.
---

The agent generates its XSLTs from a plan you agreed: a translation from its _field mapping_, an indexing XSLT from its _index plan_, a CEF XSLT from its _CEF plan_.
The plan is kept with the XSLT, and the agent changes the XSLT by changing the plan and generating it again.

You can still edit the XSLT yourself in Stroom's editor, before or after promotion.
This page is for pipeline developers who do: how the agent notices your edit, what happens on its next change, and how to keep the two in step.


## How the Agent Notices an Edit

When the agent saves an XSLT, Stroom records what it saved.
Before it saves again, it compares three things:

* what the plan generates;
* the XSLT as it is now, with your edit;
* the new code it is about to save.

An edit, here, is a change to what the XSLT writes or reads: an element or JSON key it writes, a constant it writes, or an XPath it reads (e.g. `data[@name='user']` changed to `data[@name='account']`).
Reformatting, comments, and moving things around without changing what is written or read are not edits; nor is reading a field into a variable rather than where it is used.

If the new code would undo something your edit did, it isn't saved, unless you tell the agent to drop your edit.

The XSLT's version history, on its Documentation tab, records each version:

Version | Date | Author | How | Change | By | Digest
--- | --- | --- | --- | --- | --- | ---
1 | 2026-10-12 | jane.doe | agent | Created from its mapping | Stroom 7.14.0, claude-opus-5-5 | #a1060cc4
2 | 2026-10-15 | john.smith | by hand | Changed outside the agent (Stroom's editor) | | #77ab01c2
3 | 2026-10-20 | jane.doe | agent | Mapping rebuilt from the XSLT, carrying in its hand edits; Source IP address written | Stroom 7.14.0, claude-opus-5-5 | #5d2e90b7

_By_ names Stroom's version and what made the change: the model of an Ask Stroom AI chat, or the MCP client by its own name.
All the changes of one build are one row, shown as _Unreleased_ until promotion makes them a version.
An edit you make in Stroom's editor becomes a _by hand_ row when the agent next changes the XSLT, found because the XSLT no longer has the digest of the code the agent last saved; its date and author are those of the XSLT's last save in Stroom, and several saves in Stroom between two of the agent's changes are one row.
The digest leaves out only the XML declaration and the space between tags, so a comment you add makes a _by hand_ row too, though it isn't an edit the agent has to keep.

{{< warning >}}
Don't edit or delete what the agent keeps on a generated XSLT's Documentation tab: the version history, and the hidden content below the note asking you to leave it be.
The hidden content holds the mapping the XSLT was generated from and the build's pending changes.
Without it the agent treats the XSLT as having no mapping, so it can no longer change it from the mapping, rebuild its Field mapping documentation or spot your hand edits.
Change the XSLT through the agent, or edit its code, instead.
{{< /warning >}}


## What Happens on the Agent's Next Change

Say the XSLT was generated, promoted, and you have since edited it.
You then ask the agent to change it, e.g. to fix the records that land in Error streams.
What happens depends on your edit.


### Your Edit and its Change Touch the Same Field

You are asked first, in a short form (or in the chat, from an MCP client without forms):

> _XSLT 'ACME-Events' was edited by hand in Stroom (by john.smith), and the agent's change changes 1 field the edit changed too: common: EventSource/User/Id. Overwrite the XSLT with the change, dropping your hand edits, or decide field by field?_

* **Overwrite the XSLT with the change** drops your edit everywhere it differs.
* **Decide field by field** asks you about each field the two both changed, saying what you did and what the agent proposes: **Keep my hand edit**, or **Use the proposed field**.

The agent then makes its change around the fields you kept.
Your answers are remembered for the rest of the session, while the XSLT stays as it is.
Anything else your edit changed is dealt with as below.


### It Maps a Field Differently, or Maps One the Plan Doesn't Have

For example, you changed which source field `EventSource/User/Id` reads, or you added a `Data` element the mapping never had.
The agent's change is refused, and it tells you so, with what your edit changed.
Then it _carries your edit into the plan_:

* For a translation, `rebuild_mapping` reads the field mapping back from the XSLT as it is now (your edit included) and proves it on the sample: the XSLT and the one regenerated from the rebuilt mapping are both stepped over the pipeline's sample streams (up to 200 records), and every record's output must be the same.
  If any differ, nothing is saved unless you, shown the differences, accept them.
  You confirm the save in a form; the XSLT is then the one regenerated from the mapping, with your edit written the generator's way.
  Its change is then made to that mapping, so the result has both your edit and its change.
* For an indexing XSLT, your edit becomes part of the index plan: a field you added becomes a field of the plan, one you removed is left out, a source you changed is changed.
* For a CEF XSLT, your edit becomes an override in the CEF plan.

From then on, the plan holds your edit, so later changes keep it without asking.


### Your Edit Uses What No Plan Can Hold

A field mapping describes elements, the source fields they read and when they are written.
Some XSLT can't be written that way, for example an `xsl:iterate` that builds a list of distinct users (inline, or in a variable that is then copied into an element).
The agent can't carry such an edit into the mapping, and says so, naming what it couldn't read (e.g. _iterate not read_).

The choice is yours:

* **Keep the XSLT as it is.**
  The agent makes no generated change to it.
  It can still change it by writing the code itself, keeping your edit, and saving it as code written by hand.
* **Drop your edit** with the agent's change.
  The agent does this only when you say so.

If you ask the agent to rebuild the mapping anyway, it lists what it couldn't read, and rebuilds without those parts only if you agree to leave them out.


### Documentation

A translation edited by hand is documented as it runs: the values and counts of the Field mapping section are of what the XSLT actually outputs on the sample, each event under the mapping's rule for its record, so they show your edit's fields and values.
Where each field is read from still comes from the mapping, and a field your edit added is listed as not in the mapping.
A note under the section says the XSLT differs from what its mapping generates; if your edit uses what no mapping can hold, it says so, naming what.


## Editing a Production XSLT

Once promoted, a document is no longer the agent's to change in place.
To change a production XSLT, the agent makes a _working copy_ of it in a build, changes and tests the copy, and promotion writes it back over the original, after a backup (see [Changing production pipelines]({{< relref "editing-pipelines#changing-production-pipelines" >}})).

Your edits to the production XSLT come with the working copy.
Everything above applies to the copy: a change that would undo your edit is refused, and you choose what happens.
So a working copy promoted back keeps your edit, together with the agent's change.

An edit made to the production XSLT after the working copy was made is not in the copy.
Promotion notices it: before the layout is shown to you, you are asked about each such document, told who changed it in production and when, and shown what overwriting would lose from production and what the working copy brings.
You then choose:

* **Overwrite production with the working copy**: the copy is written back, and the production edit is then only in the backup.
* **Keep production as it is**: production isn't touched, and the working copy (with its pipeline) stays in the build; the agent's change can be made again on a fresh working copy, which includes your edit.

The layout you then review shows what you chose.
You are asked once for each promotion: promoting the build again asks again.
Promotion needs a client that can show forms; one that can't is refused.


## Good Practice

* **Ask the agent first.**
  Most changes can be made in the plan (a field, a constant, a condition, a time format), which keeps the XSLT and its plan in step and needs no hand edit.
* **Edit by hand what the plan can't express**, and expect to keep that part by hand.
  Tell the agent when you have, so it reads the XSLT before it changes it.
* **Keep shared code shared.**
  If your pipelines call named templates from shared XSLTs (e.g. one putting the stream's GUID in `Event/Meta`), call them in your edit too.
  The agent follows the same templates (those two or more of your pipelines call) in what it generates, and warns when an XSLT it saves doesn't.
  Where standing instructions require a stage's XSLTs to import a shared XSLT (see [Standing instructions]({{< relref "configuration#standing-instructions-agents-documents" >}})), the agent's save of an XSLT in a build without that import is refused.
* **Look at the version history** on the XSLT's Documentation tab to see who changed it, when and how.
