#!/bin/bash
set -e

cd "$(dirname "$0")"

echo "Building ClipboardFox (universal arm64 + x86_64)..."
swift build -c release --arch arm64 --arch x86_64

BIN_DIR=$(swift build -c release --arch arm64 --arch x86_64 --show-bin-path)
BINARY="$BIN_DIR/ClipboardFox"

rm -rf build/ClipboardFox.app
mkdir -p build/ClipboardFox.app/Contents/{MacOS,Resources}
cp "$BINARY" build/ClipboardFox.app/Contents/MacOS/
cp AppIcon.icns build/ClipboardFox.app/Contents/Resources/
cp ClipboardFox/Info.plist build/ClipboardFox.app/Contents/

echo "Done! App is at build/ClipboardFox.app"
