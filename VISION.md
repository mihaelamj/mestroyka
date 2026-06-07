# Vision

mestroyka is a private, on-device AI agent for Apple platforms. Swift, MLX,
local-first. The model runs on your own machine; nothing is required to leave it.

## What it is

An agent is not its model. It is the small machine that drives a model in a loop,
intercepts the parts of the model's output that are requests to act, performs
them, and folds the results back into context until the model is done. That
machine is old and well understood: it is a **cognitive architecture** in the
sense of Newell and Laird's Soar (1987) and Anderson's ACT-R, with a neural model
in the slot that used to hold hand-written rules.

mestroyka builds that machine natively, one part per Swift package:

- **Working memory** (the context window) under an explicit budget.
- **Declarative memory** (a local store) that strengthens what is retrieved and
  lets the unused decay, following the activation rule of the memory literature.
- **Procedural memory** (skills and tools): skills are prose the model reads, not
  code it runs; third-party code is reached out-of-process via MCP.
- **The decision cycle** (the loop), with repair for the malformed tool calls a
  small local model tends to emit.
- **Trust**: the model's output is never a trusted principal. Authority lives in
  the host; irreversible actions are confirmed.

## What it is not

mestroyka is deliberately small. It is not a platform, not a plugin marketplace,
not a multi-channel chatbot, and not a cloud service with a thin native shell. It
targets Apple platforms exclusively, because that constraint is what lets it use
on-device intelligence, MLX inference, native vision and speech, and system
integration, that a cross-platform agent cannot. It declines the breadth that
turns agents into unmaintainable everything-machines.

## Why Apple-only, on-device

A cross-platform agent pays a cloud provider to do what a Mac already does
locally. mestroyka does not. Inference runs through MLX on Apple silicon; speech,
vision, and language lean on the system frameworks; the first channel is the one
you already use. The cost is that a local model is weaker than a frontier cloud
model, and mestroyka is built around that fact rather than hiding it: more
scaffolding, more repair, honest limits. A cloud model can be added as one more
provider when you want it, without pretending the local one is something it isn't.

## Status

Early. The package layout and direction are set; the kernel is being built as a
small, tested, literate core before anything wide is added.
