#!/bin/bash
# Build CodexBar.app using the Command Line Tools' swiftc (no full Xcode needed).
set -euo pipefail

DIR="$(cd "$(dirname "$0")" && pwd)"
APP="$DIR/CodexBar.app"
ARCH="$(uname -m)" # arm64 or x86_64

echo "==> Cleaning previous build"
rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"
cp "$DIR/Info.plist" "$APP/Contents/Info.plist"

# Generate icons on first build (or if missing), then bundle Resources.
if [ ! -f "$DIR/Resources/AppIcon.icns" ] || [ ! -f "$DIR/Resources/MenuIcon.png" ]; then
    "$DIR/make-icons.sh"
fi
cp -R "$DIR/Resources/." "$APP/Contents/Resources/"

echo "==> Compiling ($ARCH)"
swiftc -O \
    -target "${ARCH}-apple-macos13.0" \
    -framework AppKit -framework SwiftUI \
    "$DIR"/Sources/*.swift \
    -o "$APP/Contents/MacOS/CodexBar"

echo "==> Ad-hoc signing"
codesign --force --sign - "$APP"

echo "==> Done: $APP"
