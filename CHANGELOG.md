# Changelog

All notable changes to mestroyka are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- `Mestroyka.Skill`: progressive-disclosure capability cards (the inert text-only
  skill model of OpenClaw; procedural-memory library of Voyager, Wang 2023).
  Parses a `SKILL.md` (frontmatter `name`/`description` + body); the catalog
  prompt carries only names and descriptions, so the body costs no tokens until a
  task matches and the model reads it. No executable code, safe by construction.
- Trust gate: a `Tool.isIrreversible` flag and an `Approver` seam (reference
  monitor, Anderson 1972). The loop consults the approver before running an
  irreversible tool, so tainted model output cannot reach an irreversible action
  without the host's consent (Denning 1976; the untrusted-prover stance).
  Reversible tools are never gated; the default `AllowAllApprover` permits all.
- `Mestroyka.MemoryStore` (in-memory) + `MemoryItem`: declarative memory whose
  retrieval ranks candidates by min-max-normalized recency/frequency (ACT-R
  activation, Anderson-Schooler 1991), importance, and lexical relevance, the
  scheme of Generative Agents (Park 2023). Recall reinforces what it returns
  (retrieval-as-reinforcement). The SQLite + vector implementation will sit behind
  the same interface once an on-device embedding model lands.
- Multi-turn tool dispatch in `AgentLoop`: the full ReAct loop (run the tools the
  oracle asks for, feed results back, repeat) bounded by a step cap (Floyd 1967).
  `Tool` protocol, `ToolCall` / `ToolResult`, and a `Message.toolResult` case.
  Tool calls leaked as text are recovered via `ToolCallRepair` against the
  registered tool names; an unregistered tool yields an error result, not a crash.

- The kernel seam and the first literature-grounded algorithms, all pure Swift
  and fully tested (no model required yet):
  - `Mestroyka.Message` / `AssistantMessage` / `AssistantEvent` / `StopReason`:
    the conversation model. Failures are values, not thrown errors (von Neumann
    1956): an oracle never throws; a failure is a `.completed` event whose message
    carries a `.failed` stop reason.
  - `Oracle`: the model seam (a stream-returning function), with a deterministic
    `Mestroyka.EchoProvider` fake for testing. An MLX-local model will be one more
    conformer.
  - `Mestroyka.AgentLoop`: the decision cycle (the ReAct recurrence, Yao et al.
    2022). Single-turn for now; multi-turn tool dispatch with a step-bound (Floyd
    1967) is next.
  - `Mestroyka.Activation`: ACT-R base-level activation `B = ln(Σ tⱼ^(−d))` for
    memory promotion (Anderson & Schooler 1991), unifying recency and frequency.
  - `Mestroyka.ToolCallRepair`: recover tool calls a weak model leaks as text;
    noisy-channel decoding (Shannon 1948) made sound by an allowlist codebook.
  - `Mestroyka.TokenBudget`: type-aware token estimation and a four-route
    compaction decision; online paging against an unreachable optimum (Belady
    1966; Denning 1968; Sleator & Tarjan 1985).
- Project conforms to the Swift monorepo repo-structure rules (workspace,
  `Packages/`, config files, `CLAUDE.md`/`AGENTS.md`), `VISION.md`.

### Notes

- 20 tests pass; `swift build`, `swiftformat --lint`, and `swiftlint` are clean.
