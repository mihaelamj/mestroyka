# mestroyka

[![Swift](https://img.shields.io/badge/swift-6.0%2B-orange)](https://swift.org)
[![Platform](https://img.shields.io/badge/platform-macOS%2015%2B-black)](https://www.apple.com/macos/)
[![Engine](https://img.shields.io/badge/inference-MLX%20(on--device)-blue)](https://github.com/ml-explore/mlx-swift)
[![License: AGPL-3.0](https://img.shields.io/badge/license-AGPL--3.0-blue.svg)](LICENSE)

A private, on-device AI agent for Apple platforms. Swift, MLX, local-first.

*mestroyka* is **me** + **stroj** (Croatian for *machine*): your machine. Say it
meh-STROY-kah.

## What it is

mestroyka is a personal AI agent that runs entirely on your Mac. It loads a
model with **MLX** (Apple's array framework for Apple Silicon), runs the agent
loop in Swift, and uses **Apple's own on-device frameworks** for everything it
can, rather than shelling out to cloud APIs:

- **Inference** runs locally through MLX. No tokens billed, nothing leaves the
  machine.
- **Vision, speech, and language** lean on Apple's native frameworks (Vision,
  Speech, NaturalLanguage, AVFoundation) instead of paid third-party services.
- **Reach it where you already are.** The first channel is the terminal; the
  intended home is iMessage, building on the
  [iRelay](https://github.com/mihaelamj/iRelay) daemon.

## Why Apple-only

This is a deliberate constraint, not a limitation. Targeting Apple platforms
exclusively is what lets mestroyka use on-device intelligence a cross-platform
agent cannot: native vision and speech, the on-device foundation model, MLX
inference tuned for Apple Silicon, and the system integration points
(Shortcuts, iMessage, Focus) that make an assistant feel native. Cross-platform
agents pay for cloud APIs to do what a Mac already does locally. mestroyka does
not.

## Status

Early scaffold. The package layout, license, and direction are in place; the
agent loop, tool surface, and MLX wiring are the next steps. Not yet usable.

## Build

```sh
cd Packages
swift build          # resolves MLX and builds the library + `mestroyka` CLI
swift run mestroyka  # (stub for now)
```

## License

mestroyka is dual licensed as [AGPL-3.0](LICENSE) / commercial.

The AGPL is a free, open-source license, but that does not mean the software is
free of obligations. It is a copyleft license: any derivative work, including a
service that incorporates mestroyka, must also be released under the AGPL-3.0
with its complete corresponding source. If you are building something that
cannot comply with the AGPL terms, a [commercial license](COMMERCIAL.md) is
available that exempts you from them.
