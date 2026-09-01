---
title: "AI Functions"
linkTitle: "AI Functions"
#weight:
date: 2026-09-01
tags: 
description: >
  Functions for asking an AI model about your data.
---

## AI

Asks a chat model a question and returns its answer.

```clike
ai(model, message)
ai(model, message, systemPrompt)
```

* `model` - The name or UUID of the {{< glossary "Document" >}} of type `OpenAIModel` to use.
  The UUID is tried first, so a model whose name happens to be another model's UUID cannot be used to reach that other model.
* `message` - The message to ask the model.
* `systemPrompt` - The system prompt to send to the model ahead of the message, for example to tell it what role to play.

Returns the model's answer, or `null` if the model had nothing to say.
Where the model cannot be found, or you do not hold the `Use` permission on it, an error value is returned so that the problem shows in the results rather than looking like an absent value.

The model is asked once per value, so prefer to use this on a grouped or otherwise small set of rows.
Repeated identical questions are served from a cache rather than being asked again.

Example

```clike
ai('Event Classifier', concat('Summarise this user agent: ', ${UserAgent}))
> 'A headless Chrome browser, commonly used by automated tooling.'
```
