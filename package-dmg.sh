#!/bin/bash
set -e

cd "$(dirname "$0")"

APP="build/ClipboardFox.app"
if [ ! -d "$APP" ]; then
  echo "App not found at $APP — run ./build.sh first." >&2
  exit 1
fi

# Strip any inherited quarantine on the .app before signing.
xattr -cr "$APP" 2>/dev/null || true

# Ad-hoc sign so the app can launch without a "damaged" warning when copied locally.
codesign --force --deep --sign - "$APP"

# Version: explicit env var wins (CI passes the tag); otherwise read Info.plist; else "dev".
if [ -z "${VERSION:-}" ]; then
  VERSION=$(/usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString" "$APP/Contents/Info.plist" 2>/dev/null || echo "dev")
fi
DMG="build/ClipboardFox-${VERSION}.dmg"

STAGING=$(mktemp -d)
cp -R "$APP" "$STAGING/"
ln -s /Applications "$STAGING/Applications"

rm -f "$DMG"
hdiutil create \
  -volname "ClipboardFox" \
  -srcfolder "$STAGING" \
  -ov \
  -format UDZO \
  "$DMG"

rm -rf "$STAGING"

echo "Done! DMG is at $DMG"
