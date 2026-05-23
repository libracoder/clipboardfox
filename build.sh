#!/bin/bash
set -e

cd "$(dirname "$0")"

echo "Building ClipboardManager (universal arm64 + x86_64)..."
swift build -c release --arch arm64 --arch x86_64

BIN_DIR=$(swift build -c release --arch arm64 --arch x86_64 --show-bin-path)
BINARY="$BIN_DIR/ClipboardManager"

rm -rf build/ClipboardManager.app
mkdir -p build/ClipboardManager.app/Contents/{MacOS,Resources}
cp "$BINARY" build/ClipboardManager.app/Contents/MacOS/
cp AppIcon.icns build/ClipboardManager.app/Contents/Resources/
cp ClipboardManager/Info.plist build/ClipboardManager.app/Contents/

echo "Done! App is at build/ClipboardManager.app"
