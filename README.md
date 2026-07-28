<div align="center">

<img src="docs/icon.png" alt="CodexBar" width="128" height="128" />

# CodexBar

**A lightweight native macOS menu-bar app that shows your [codex-lb](https://github.com/AlexShang1992/codex-lb-menubar) account usage at a glance.**

[![Release](https://img.shields.io/github/v/release/AlexShang1992/codex-lb-menubar?sort=semver)](https://github.com/AlexShang1992/codex-lb-menubar/releases)
[![CI](https://github.com/AlexShang1992/codex-lb-menubar/actions/workflows/ci.yml/badge.svg)](https://github.com/AlexShang1992/codex-lb-menubar/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/macOS-13%2B-black?logo=apple)](https://www.apple.com/macos/)
[![Swift](https://img.shields.io/badge/Swift-6-orange?logo=swift)](https://swift.org)

English · [简体中文](README.zh-CN.md)

</div>

---

CodexBar lives in your menu bar as a single icon. Click it to see a clean popover
with one card per account — plan, routing policy, status, weekly usage, reset
countdown, warm-up state and available reset credits — pulled live from a local
[`codex-lb`](#what-is-codex-lb) instance.

It is written in pure Swift (AppKit + SwiftUI), has **zero third-party
dependencies**, idles at **0% CPU** and **~27 MB** of memory, and builds with just
the Xcode Command Line Tools.

## Features

- 🧭 **Menu-bar native.** A single click opens a popover; no Dock icon, no windows.
- 🔄 **Fresh on open.** Data is fetched every time you open the popover — no
  background polling, so it costs nothing while idle.
- 🃏 **At-a-glance cards.** Email, `Normal`/`Active` badges, plan + account id,
  a weekly-usage bar, reset countdown, warm-up state and a reset-credits badge.
- 🌗 **Light & dark aware.** Follows the system appearance.
- 🌐 **One-click dashboard.** Jump straight to the codex-lb web UI.
- 🪶 **Featherweight.** No Electron, no frameworks — ~27 MB RSS, 0% idle CPU.
- 🔧 **Configurable endpoint** via the `CODEXBAR_ENDPOINT` environment variable.

## Screenshots

A single icon sits in the menu bar (<img src="docs/menubar-icon.png" height="18"/>);
clicking it opens the popover:

|                     Dark                     |                     Light                     |
| :------------------------------------------: | :-------------------------------------------: |
| <img src="docs/screenshot-dark.png?v=1.0.3" width="340"/> | <img src="docs/screenshot-light.png?v=1.0.3" width="340"/> |

<sub>Rendered from the app with mock data via `make screenshots`.</sub>

## Requirements

- macOS 13 (Ventura) or later
- A running [`codex-lb`](#what-is-codex-lb) instance reachable at
  `http://127.0.0.1:2455` (the default)
- To build from source: the Xcode Command Line Tools (`xcode-select --install`).
  A full Xcode install is **not** required.

## Installation

### Option A — Download a release

1. Download **`CodexBar.dmg`** from the
   [Releases](https://github.com/AlexShang1992/codex-lb-menubar/releases) page.
2. Open it and drag **CodexBar** onto **Applications**.
3. Because the build is ad-hoc signed (not notarized), clear quarantine once
   (or right-click the app → **Open** on first launch):

   ```sh
   xattr -dr com.apple.quarantine /Applications/CodexBar.app
   ```

> A plain `CodexBar.app.zip` is also attached if you prefer.

### Option B — Build from source

```sh
git clone https://github.com/AlexShang1992/codex-lb-menubar.git
cd codex-lb-menubar
make build      # produces ./CodexBar.app
make run        # build + launch
```

## Usage

- **Open:** click the cloud **LB** icon in the menu bar.
- **Refresh:** it refreshes automatically on open; the ↻ button forces a refresh.
- **Open dashboard:** the ↗ button opens the codex-lb web UI in your browser.
- **Quit:** the “退出 / Quit” button in the footer.

### Start at login

Add `CodexBar.app` under **System Settings → General → Login Items**.

### Custom endpoint

If your codex-lb runs on a different host/port:

```sh
CODEXBAR_ENDPOINT=http://127.0.0.1:9000 open -a CodexBar
```

## What is codex-lb?

`codex-lb` is a local load balancer for Codex/ChatGPT accounts. It exposes a JSON
API at `GET /api/accounts` and a web dashboard at `/accounts`. CodexBar is a thin,
read-only viewer for that API — it does not modify accounts or proxy any traffic.

## How it works

```
┌───────────────┐     GET /api/accounts      ┌──────────────────┐
│   CodexBar    │ ─────────────────────────► │     codex-lb     │
│ (menu bar app)│ ◄───────────────────────── │  127.0.0.1:2455  │
└───────────────┘        accounts JSON       └──────────────────┘
        │
        └── NSStatusItem + NSPopover hosting a SwiftUI card list
```

- `NSStatusItem` renders the menu-bar icon; clicking toggles an `NSPopover`.
- On open, `AccountsViewModel` performs an async `URLSession` fetch and decodes
  the response into `Account` models.
- The popover size is driven from the account count so it never gets clipped by
  the menu bar or leaves empty space.

See [Architecture](#architecture) for the file layout.

## Development

```sh
make build      # compile + assemble the .app (swiftc, ad-hoc signed)
make icons      # regenerate icons from Tools/MakeIcon.swift
make selftest   # headless fetch + decode against the live API
make run        # build + launch
make clean      # remove build output
make help       # list targets
```

### Architecture

```
Sources/
  main.swift              Entry point (+ --selftest headless check)
  AppDelegate.swift       NSStatusItem + NSPopover; refresh-on-open
  AccountsViewModel.swift Async fetch of /api/accounts
  Models.swift            Codable models + presentation helpers
  ContentView.swift       SwiftUI card UI
  Config.swift            Endpoint config (CODEXBAR_ENDPOINT)
Tools/
  MakeIcon.swift          Vector icon generator (menu bar + app icon)
Info.plist                LSUIElement agent app; local HTTP allowed
build.sh                  swiftc compile + bundle + ad-hoc sign
make-icons.sh             Render MenuIcon.png + AppIcon.icns
```

## Roadmap

- [ ] Optional background refresh with a configurable interval
- [ ] Per-account actions (consume reset credit, open dashboard deep-link)
- [ ] Cost / token totals from `requestUsage`
- [ ] Notarized, signed release
- [ ] Homebrew cask

See [open issues](https://github.com/AlexShang1992/codex-lb-menubar/issues) for the
full list.

## Contributing

Contributions are welcome! Please read [CONTRIBUTING.md](CONTRIBUTING.md) and the
[Code of Conduct](CODE_OF_CONDUCT.md) first.

## Security

Found a vulnerability? Please follow the [Security Policy](SECURITY.md).

## License

Distributed under the MIT License. See [LICENSE](LICENSE).

## Acknowledgements

- Built with Swift, AppKit and SwiftUI.
- Icon rendered from scratch with Core Graphics (`Tools/MakeIcon.swift`).
