#!/bin/bash
set -e

cd "$(dirname "$0")"

APP="build/ClipboardManager.app"
if [ ! -d "$APP" ]; then
  echo "App not found at $APP — run ./build.sh first." >&2
  exit 1
fi

# Ad-hoc sign so the app can launch without a "damaged" warning when copied locally.
codesign --force --deep --sign - "$APP"

VERSION=$(/usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString" "$APP/Contents/Info.plist" 2>/dev/null || echo "dev")
DMG="build/ClipboardManager-${VERSION}.dmg"

STAGING=$(mktemp -d)
cp -R "$APP" "$STAGING/"
ln -s /Applications "$STAGING/Applications"

rm -f "$DMG"
hdiutil create \
  -volname "ClipboardManager" \
  -srcfolder "$STAGING" \
  -ov \
  -format UDZO \
  "$DMG"

rm -rf "$STAGING"

echo "Done! DMG is at $DMG"
