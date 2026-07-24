# Contributing to CodexBar

Thanks for your interest in improving CodexBar! This document explains how to set
up your environment and the conventions the project follows.

## Prerequisites

- macOS 13 or later
- Xcode Command Line Tools: `xcode-select --install` (full Xcode not required)
- A running `codex-lb` instance for manual testing (default `http://127.0.0.1:2455`)

## Getting started

```sh
git clone https://github.com/AlexShang1992/codex-lb-menubar.git
cd codex-lb-menubar
make build      # compile + assemble CodexBar.app
make selftest   # headless fetch + decode against the live API
make run        # build + launch
```

## Project layout

See the [Architecture](README.md#architecture) section of the README.

## Development workflow

1. Create a feature branch: `git checkout -b feat/my-change`.
2. Make your change. Keep the code dependency-free and idiomatic Swift.
3. Verify it builds and the self-test passes:

   ```sh
   make clean && make build && make selftest
   ```

4. If you touched the icon generator, regenerate assets: `make icons`.
5. Commit using [Conventional Commits](https://www.conventionalcommits.org/)
   (`feat:`, `fix:`, `docs:`, `refactor:`, `chore:` …).
6. Open a pull request against `main` and fill in the template.

## Coding conventions

- Swift, 4-space indentation, no third-party dependencies.
- Prefer small, focused files that match the existing structure.
- Keep the app an agent (`LSUIElement`) with no Dock icon or main window.
- User-facing strings may be bilingual (English / 简体中文) where it already is.

## Reporting bugs & requesting features

Use the [issue templates](https://github.com/AlexShang1992/codex-lb-menubar/issues/new/choose).
Please include your macOS version, how you launched the app, and relevant output
from `make selftest`.

## License

By contributing, you agree that your contributions are licensed under the
[MIT License](LICENSE).
