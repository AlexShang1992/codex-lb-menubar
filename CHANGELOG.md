# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Changed

- The "open ChatGPT" footer button now uses a cloud + `>_` terminal icon
  (rendered by `Tools/MakeIcon.swift` via the new `term` glyph) instead of a
  generic chat symbol.

## [1.0.1] - 2026-07-24

### Added

- Footer button to launch the ChatGPT desktop app (bundle id `com.openai.codex`,
  with a fallback to `/Applications/ChatGPT.app`).
- Drag-to-install **DMG** packaging (`make-dmg.sh`, `make dmg`); releases now
  publish `CodexBar.dmg` alongside `CodexBar.app.zip`.

## [1.0.0] - 2026-07-24

### Added

- Menu-bar app (`NSStatusItem` + `NSPopover`) built with AppKit + SwiftUI.
- Live account cards from `codex-lb` `GET /api/accounts`: email, routing policy,
  status, plan + account id, weekly-usage bar, reset countdown, warm-up state and
  reset-credits badge.
- Refresh-on-open behaviour (no background polling) plus a manual refresh button.
- One-click button to open the codex-lb web dashboard.
- Light/dark appearance support.
- Custom cloud **LB** icon for the menu bar and the app bundle, rendered from
  scratch with Core Graphics (`Tools/MakeIcon.swift`).
- Configurable endpoint via the `CODEXBAR_ENDPOINT` environment variable.
- Headless `--selftest` mode for CI/debugging.
- `make` targets and build scripts requiring only the Command Line Tools.

[Unreleased]: https://github.com/AlexShang1992/codex-lb-menubar/compare/v1.0.1...HEAD
[1.0.1]: https://github.com/AlexShang1992/codex-lb-menubar/compare/v1.0.0...v1.0.1
[1.0.0]: https://github.com/AlexShang1992/codex-lb-menubar/releases/tag/v1.0.0
