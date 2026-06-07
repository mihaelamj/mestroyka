# Changelog

All notable changes to mestroyka are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

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
