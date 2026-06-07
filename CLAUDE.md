# mestroyka

Guidance for Claude Code (and other coding agents) working in this repository.

## Project

mestroyka is a private, on-device AI agent for Apple platforms. Swift, MLX,
local-first. The model runs on the user's machine; nothing is required to leave
it. The design is a native **cognitive architecture** (Soar/ACT-R lineage) with
an MLX model in the decision slot, built deliberately small. See
[VISION.md](VISION.md) for the north star and, privately,
`mihaelamj/mestroyka-research` for the literature-grounded strategy and module plan.

## Rule loading (do this first)

This is a Swift project. Read this file and [AGENTS.md](AGENTS.md), then load the
shared Swift rule set from `mihaela-agents/Rules/swift/` (resolve the
`mihaela-agents` path via the per-machine table in `~/.claude/CLAUDE.md`).

Always-load: `swift/general.md`, `swift/repo-structure.md`, `swift/gof-di-rules.md`,
`swift/exp/critical-rules.md`, `swift/exp/when-to-create.md`. Load other
`swift/*` rules on demand per `universal/rule-loading.md`. Confirm by naming the
rule files that apply to the current task; if you cannot name them, you have not
loaded them.

## Repository structure

Follows `mihaela-agents/Rules/swift/repo-structure.md`:

- `Main.xcworkspace` at root.
- Single `Packages/Package.swift` holding all library + test targets and the
  `mestroyka` CLI executable.
- Library code under `Packages/Sources/`, tests under `Packages/Tests/`.
- A future native iOS/macOS app, if any, goes in `Apps/<App>.xcodeproj` as a
  minimal entry point; all logic stays in packages.

The intended package layout (one per cognitive-architecture slot):
`MestroykaCore` (decision cycle), `Oracle` (MLX/cloud provider), `ToolCallRepair`,
`WorkingMemory`, `DeclarativeMemory`, `ProceduralMemory`, `Trust`, `Channel`.

## Non-negotiables

- **Swift only.** Interop with MLX / Apple frameworks as needed; no other language
  for build logic or tooling.
- **Apple-only, on-device by design.** The differentiator is native, local-first
  inference. A cloud model may be added as one more provider, never as a requirement.
- **Clarify before coding.** Do not assume requirements; surface real trade-offs.
  Do not pre-abstract; add abstraction at the second real consumer
  (`exp/when-to-create.md`).
- **Inject dependencies through `init`.** No singletons. No force-unwrapping in
  shipping code (`gof-di-rules.md`).
- **Namespace public types**; one non-private type per file; file named for the
  qualified type.
- **Frugality.** Keep the kernel small and tested. The build order and the
  explicit decline list live in the research repo's strategy doc. Resist breadth.
- **Verify before claiming done.** Run `swift build` and `swift test` and cite the
  output. Never say "should pass".
- **No AI attribution, no em dashes** in any committed text.

## Commands

```sh
cd Packages
swift build
swift test
swift run mestroyka
```

(Early scaffold: the agent loop is not wired yet.)
