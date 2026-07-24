#!/bin/bash
# Package CodexBar.app into a drag-to-install DMG (app + Applications alias).
# Builds the app first if the bundle is missing.
set -euo pipefail

DIR="$(cd "$(dirname "$0")" && pwd)"
APP="$DIR/CodexBar.app"
VOL="CodexBar"
OUT="$DIR/dist/CodexBar.dmg"

[ -d "$APP" ] || "$DIR/build.sh"

STAGING="$(mktemp -d)"
trap 'rm -rf "$STAGING"' EXIT

echo "==> Staging"
cp -R "$APP" "$STAGING/"
ln -s /Applications "$STAGING/Applications"   # drag-to-install target

mkdir -p "$DIR/dist"
rm -f "$OUT"

echo "==> Building DMG"
hdiutil create \
    -volname "$VOL" \
    -srcfolder "$STAGING" \
    -fs HFS+ \
    -format UDZO \
    -ov \
    "$OUT" >/dev/null

shasum -a 256 "$OUT" | tee "$OUT.sha256"
echo "==> Done: $OUT"
