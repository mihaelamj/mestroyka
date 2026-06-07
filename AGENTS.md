# Agent Guide

CONFIRMATION_PHRASE: "rules-loaded"

Guidance for anyone (human or coding agent) writing code in mestroyka.

## Rule loading (read this first)

At the start of a session, read [CLAUDE.md](CLAUDE.md) and this file, then load
the shared Swift rule set from `mihaela-agents/Rules/swift/` (path per the
per-machine table in `~/.claude/CLAUDE.md`). Confirm with the token
`rules-loaded` and name the rule files that apply to the task. If you cannot name
them, you have not loaded the rules. Mechanical gates (lint, format, hooks, CI)
enforce the checkable rules; the judgment rules depend on you having read them.

## What mestroyka is

A private, on-device AI agent for Apple platforms, in Swift, running its model
through MLX on Apple silicon. No server, no cloud requirement, no JavaScript. The
architecture is a native cognitive architecture (working memory, declarative
memory, procedural memory, a decision cycle) with an MLX model in the operator
slot. See [VISION.md](VISION.md).

## Language policy

Swift for everything. Interop with MLX and Apple system frameworks as required.
No other language for build logic or tooling.

## Rules

Conventions are the shared Swift rule set under `mihaela-agents/Rules/swift/` and
the cross-cutting `mihaela-agents/Rules/universal/`. Always-load:
`general.md`, `repo-structure.md`, `gof-di-rules.md`, `exp/critical-rules.md`,
`exp/when-to-create.md`. Load the rest on demand per `universal/rule-loading.md`.

## Working with the maintainer

- Clarify ambiguity before coding. Do not assume requirements.
- When a real trade-off exists, surface two or three options with their
  trade-offs. On obvious blockers (a build break, a bug in your own change) fix
  without asking. On routine edits with no real choice, just do the work.
- A one-line change with non-trivial blast radius (a version bump, a public API
  break, a license or file-format change) needs the maintainer's call on
  semantics even when the code is trivial.
- Hold the line on frugality. The decline list (what mestroyka deliberately does
  not build) is in the private research repo's strategy doc; respect it.

## Workflow

- Verify before claiming done: run `swift build` and `swift test` from `Packages/`
  and cite the output.
- Commits follow Conventional Commits. One focused change per PR. A CHANGELOG
  entry for any change touching shipping source.
- No AI attribution and no em dashes in any committed text.

## Commands

```sh
cd Packages
swift build
swift test
swift run mestroyka
```

(Early scaffold: the agent loop is not wired yet.)
