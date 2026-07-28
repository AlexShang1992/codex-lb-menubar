#!/bin/bash
# Generate the menu-bar icon (MenuIcon.png) and app icon (AppIcon.icns)
# into Resources/. Run this whenever Tools/MakeIcon.swift changes.
set -euo pipefail

DIR="$(cd "$(dirname "$0")" && pwd)"
RES="$DIR/Resources"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
mkdir -p "$RES"

echo "==> Compiling icon generator"
swiftc -O -framework AppKit "$DIR/Tools/MakeIcon.swift" -o "$TMP/makeicon"

echo "==> Menu-bar icon"
"$TMP/makeicon" "$RES/MenuIcon.png" 176 bar

echo "==> ChatGPT launcher button icon (cloud + terminal prompt)"
"$TMP/makeicon" "$RES/ChatGPTIcon.png" 256 app term

echo "==> GitHub mark (template, for the repo button)"
"$TMP/makeicon" "$RES/GitHubIcon.png" 176 github

echo "==> App iconset"
ICONSET="$TMP/AppIcon.iconset"
mkdir -p "$ICONSET"
"$TMP/makeicon" "$ICONSET/icon_16x16.png"       16   app
"$TMP/makeicon" "$ICONSET/icon_16x16@2x.png"    32   app
"$TMP/makeicon" "$ICONSET/icon_32x32.png"       32   app
"$TMP/makeicon" "$ICONSET/icon_32x32@2x.png"    64   app
"$TMP/makeicon" "$ICONSET/icon_128x128.png"     128  app
"$TMP/makeicon" "$ICONSET/icon_128x128@2x.png"  256  app
"$TMP/makeicon" "$ICONSET/icon_256x256.png"     256  app
"$TMP/makeicon" "$ICONSET/icon_256x256@2x.png"  512  app
"$TMP/makeicon" "$ICONSET/icon_512x512.png"     512  app
"$TMP/makeicon" "$ICONSET/icon_512x512@2x.png"  1024 app
iconutil -c icns "$ICONSET" -o "$RES/AppIcon.icns"

echo "==> Done:"
ls -la "$RES"
