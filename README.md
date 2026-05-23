<div align="center">

# ClipboardFox

**The fast, searchable, menu‑bar clipboard manager for macOS.**

Never lose a copied snippet again. ClipboardFox keeps every clip a keystroke away — searchable, persistent, and lighter than your browser tab.

[![Build DMG](https://github.com/libracoder/clipboardfox/actions/workflows/build-dmg.yml/badge.svg)](https://github.com/libracoder/clipboardfox/actions/workflows/build-dmg.yml)
[![Latest Release](https://img.shields.io/github/v/release/libracoder/clipboardfox?include_prereleases&label=release)](https://github.com/libracoder/clipboardfox/releases)
[![Downloads](https://img.shields.io/github/downloads/libracoder/clipboardfox/total)](https://github.com/libracoder/clipboardfox/releases)
[![macOS](https://img.shields.io/badge/macOS-13%2B-blue)](https://www.apple.com/macos/)
[![Swift](https://img.shields.io/badge/Swift-5.9-orange?logo=swift&logoColor=white)](https://swift.org)
[![Stars](https://img.shields.io/github/stars/libracoder/clipboardfox?style=social)](https://github.com/libracoder/clipboardfox/stargazers)

</div>

---

## Why ClipboardFox?

macOS only remembers your *last* copy. ClipboardFox remembers **everything** — the snippet of SQL you copied an hour ago, the customer email you grabbed yesterday, the API key you'll wish you hadn't lost.

- **Instant.** Open the menu bar icon, type, paste. Sub‑second search across thousands of clips.
- **Local‑first.** Your clipboard never leaves your Mac. No cloud, no telemetry, no account.
- **Native.** Pure SwiftUI. No Electron, no JavaScript runtime, no 400 MB Helper process.
- **Yours.** Open source, MIT, and small enough to read in a single sitting.

## Table of Contents

- [Features](#features)
- [Install](#install)
- [Usage](#usage)
- [Settings](#settings)
- [Storage](#storage)
- [Build from Source](#build-from-source)
- [Roadmap](#roadmap)
- [FAQ](#faq)
- [Contributing](#contributing)
- [License](#license)

## Features

| | |
|---|---|
| **Live search** | Filter your entire clipboard history as you type. |
| **Menu‑bar native** | Lives quietly in the menu bar. No dock icon, no clutter. |
| **Persistent** | History survives reboots, updates, and crashes. |
| **Auto‑backup** | Every new clip is mirrored to a JSON file you control. |
| **Export / Import** | Move history between Macs; duplicates merge automatically. |
| **Configurable size** | Keep anywhere from 10 to 10,000 clips. |
| **Launch at login** | Optional, one‑click. Uses the modern `SMAppService` API. |
| **Click to paste** | Click any entry to copy it back and dismiss the popover. |
| **Rebuild in place** | Update the binary from the settings panel without leaving the app. |
| **Private** | 100% local. No network access. No analytics. Ever. |

## Install

### Download the latest DMG (recommended)

Grab the universal `.dmg` from the [Releases page](https://github.com/libracoder/clipboardfox/releases/latest), open it, and drag **ClipboardFox.app** to **Applications**.

> The DMG is built and ad‑hoc signed by [GitHub Actions](.github/workflows/build-dmg.yml) on every tagged release, so you can verify the build provenance directly against this repo.

**First launch (important).** Because the build is ad‑hoc signed (not notarized by Apple), macOS Gatekeeper marks the downloaded app as quarantined and will say *"ClipboardFox is damaged and can't be opened"*. Strip the quarantine flag once and you're done:

```bash
xattr -cr /Applications/ClipboardFox.app
open /Applications/ClipboardFox.app
```

Alternatively, right‑click the app in Finder → **Open** → confirm. macOS will remember the exemption.

### Build from source

```bash
git clone https://github.com/libracoder/clipboardfox.git
cd clipboardfox
./build.sh
open build/ClipboardFox.app
```

### Package a DMG locally

```bash
./build.sh && ./package-dmg.sh
# → build/ClipboardFox-<version>.dmg
```

## Usage

1. Click the paperclip icon in the menu bar.
2. Start typing to filter — matches highlight as you go.
3. Click an entry (or press `Return` on the focused row) to copy it to your clipboard.
4. The popover dismisses automatically so you can paste immediately.

That's the whole loop. Most users never need the settings panel.

## Settings

Open settings via the gear icon in the bottom‑right corner of the popover.

| Setting | Description |
|---|---|
| Launch at Login | Start automatically when you log in. |
| Maximum Clips | How many clips to keep (default: 200). |
| Auto Backup | Save a backup file on every new clip. |
| Backup Path | Where the auto‑backup file is stored. |
| Export / Import | Manual backup and restore. JSON, merges without duplicates. |
| Rebuild | Rebuild the app from source — handy after `git pull`. |
| Quit | Exit the app. |

## Storage

Clipboard history is stored locally at:

```
~/Library/Application Support/ClipboardFox/history.json
```

Auto‑backup defaults to:

```
~/Documents/ClipboardBackup.json
```

Both files are plain JSON. You can inspect, edit, or migrate them with any text editor.

## Build from Source

ClipboardFox is a single Swift Package — no Xcode project, no CocoaPods, no Carthage.

```bash
swift build -c release           # build for your host arch
./build.sh                       # build universal (arm64 + x86_64) and package .app
./package-dmg.sh                 # wrap the .app in a distributable .dmg
```

**Requirements**

- macOS 13 (Ventura) or later
- Xcode 15 / Swift 5.9 or later

The CI workflow at [`.github/workflows/build-dmg.yml`](.github/workflows/build-dmg.yml) does exactly the above on a `macos-14` runner. Pushing a `v*` tag automatically attaches the DMG to a GitHub Release.

## Roadmap

- [ ] Pin favourite clips to the top
- [ ] Image / rich‑text clip support
- [ ] Global hotkey for "open ClipboardFox"
- [ ] Per‑app history filters
- [ ] iCloud sync (opt‑in)
- [ ] Homebrew cask

Have an idea? [Open an issue](https://github.com/libracoder/clipboardfox/issues/new) — feature requests welcome.

## FAQ

**Does ClipboardFox send my clipboard data anywhere?**
No. There is no network code in the app. You can verify this by grepping the source — there is no `URLSession`, no `Network` import, nothing.

**Will it slow down my Mac?**
No. The app idles at <10 MB of RAM and 0% CPU. It only does work when you press ⌘C or open the popover.

**Can I clear individual entries?**
Yes — hover an entry and click the delete icon, or use the search bar to find and remove a specific clip.

**Where is my history if I uninstall?**
Your clipboard history JSON is in `~/Library/Application Support/ClipboardFox/`. Delete it manually if you want a clean wipe.

**Why not just use [`pbpaste`](x-man-page://pbpaste)?**
You should — for the last clip. ClipboardFox is for everything before that.

**Is there a Windows or Linux version?**
Not planned. ClipboardFox is built on AppKit / SwiftUI and is intentionally a small, native macOS app.

## Contributing

Pull requests are welcome. For larger changes, open an issue first so we can discuss the approach.

```bash
git clone https://github.com/libracoder/clipboardfox.git
cd clipboardfox
swift build
```

The whole project is intentionally small — under a thousand lines of Swift across five files. New contributors should be able to read the codebase end‑to‑end in one sitting.

## License

[MIT](LICENSE) — do whatever you want, but don't blame me if it breaks.

---

<div align="center">

If ClipboardFox saves you a single "where did I copy that from?" moment, consider [starring the repo](https://github.com/libracoder/clipboardfox) — it genuinely helps others find it.

</div>
