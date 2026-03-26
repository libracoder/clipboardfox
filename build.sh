#!/bin/bash
set -e

cd "$(dirname "$0")"

echo "Building ClipboardManager..."
swift build -c release

BINARY=$(swift build -c release --show-bin-path)/ClipboardManager

mkdir -p build/ClipboardManager.app/Contents/{MacOS,Resources}
cp "$BINARY" build/ClipboardManager.app/Contents/MacOS/
cp AppIcon.icns build/ClipboardManager.app/Contents/Resources/
cp ClipboardManager/Info.plist build/ClipboardManager.app/Contents/

echo "Done! App is at build/ClipboardManager.app"
