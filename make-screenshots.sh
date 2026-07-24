#!/bin/bash
# Render privacy-safe popover screenshots (mocked data) into docs/ using the
# real SwiftUI view hosted off-screen — no screen-recording permission needed.
set -euo pipefail

DIR="$(cd "$(dirname "$0")" && pwd)"
ARCH="$(uname -m)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
mkdir -p "$DIR/docs"

echo "==> Compiling screenshot renderer"
swiftc -O -target "${ARCH}-apple-macos13.0" \
    -framework AppKit -framework SwiftUI \
    "$DIR/Tools/MakeScreenshot.swift" \
    "$DIR/Sources/Config.swift" \
    "$DIR/Sources/Models.swift" \
    "$DIR/Sources/AccountsViewModel.swift" \
    "$DIR/Sources/ContentView.swift" \
    -o "$TMP/makeshot"

echo "==> Rendering"
cd "$DIR"
"$TMP/makeshot" docs/screenshot-dark.png dark
"$TMP/makeshot" docs/screenshot-light.png light
echo "==> Done: docs/screenshot-{dark,light}.png"
