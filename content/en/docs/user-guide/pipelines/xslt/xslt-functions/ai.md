---
title: "AI"
linkTitle: "AI"
weight: 100
date: 2026-09-01
tags:
  - xslt
description: >
  XSLT functions for asking an AI model about your data.
---

## ai()

Asks a chat model a question and returns its answer.

```text
ai(String model, String message)
ai(String model, String message, String systemPrompt)
```

The arguments are as follows:

* `model` - The name or UUID of the {{< glossary "Document" >}} of type `OpenAIModel` to use.
  The UUID is tried first, so a model whose name happens to be another model's UUID cannot be used to reach that other model.
* `message` - The message to ask the model.
* `systemPrompt` - The system prompt to send to the model ahead of the message, for example to tell it what role to play.
  Optional.

The function returns the model's answer as a string, or an empty sequence if the model had nothing to say or could not be reached.

You must hold the `Use` permission on the model document.
Where the model cannot be found, or you do not have permission to use it, a warning is recorded against the stream and an empty sequence is returned.


### Performance


{{% warning %}}
The model is asked once per call, so a pipeline that calls this for every record will make one request per record, each of which may take seconds or longer.
Consider whether the question really needs asking of every record.
{{% /warning %}}

Repeated identical questions are served from a cache rather than being asked again, so calling this with the same model, message and system prompt costs one request however many records ask it.
The cache is configured by the `chatResponseCache` property of the `ai` configuration branch.
Setting its `maximumSize` to `0` asks the model every time.


### Examples

Asking a model to classify a value.

```xml
<xsl:variable name="answer"
              select="stroom:ai('Event Classifier', concat('Is this user agent a bot? Answer yes or no. ', UserAgent))"/>
```

Giving the model a role with a system prompt.

```xml
<xsl:variable name="answer"
              select="stroom:ai(
                  'Event Classifier',
                  Description,
                  'You are a security analyst. Answer in one short sentence.')"/>
```

{{% see-also %}}
* [`split-document()`]({{< relref "maths-and-vectors#split-document" >}}) for breaking a large document into chunks that fit a model's context window.
* [`cosine-similarity()`]({{< relref "maths-and-vectors#cosine-similarity" >}}) for comparing embeddings.
{{% /see-also %}}
