# ClipboardManager

A lightweight, searchable clipboard manager that lives in your macOS menu bar.

![macOS](https://img.shields.io/badge/macOS-13%2B-blue) ![Swift](https://img.shields.io/badge/Swift-5.9-orange)

## Features

- **Search** — Instantly filter clipboard history with the search bar
- **Menu bar app** — Paperclip icon in the menu bar, no dock icon
- **Persistent history** — Clipboard history survives app restarts
- **Auto-backup** — Automatically backs up clips to a JSON file
- **Export / Import** — Manually export or import backups, merges without duplicates
- **Configurable** — Set max clips (10–10,000), backup path, and launch at login
- **Click to copy** — Click any item to copy it and dismiss the popover
- **Rebuild from source** — Rebuild the app directly from the settings panel

## Install

### From source

```bash
git clone https://github.com/libracoder/ClipboardManager.git
cd ClipboardManager
./build.sh
open build/ClipboardManager.app
```

Optionally drag `build/ClipboardManager.app` to `/Applications`.

## Settings

Open settings via the gear icon in the bottom-right corner of the popover:

| Setting | Description |
|---|---|
| Launch at Login | Start automatically when you log in |
| Maximum Clips | How many clips to keep (default: 200) |
| Auto Backup | Save a backup file on every new clip |
| Backup Path | Where the auto-backup file is stored |
| Export / Import | Manual backup and restore |
| Rebuild | Rebuild the app from source |
| Quit | Exit the app |

## Storage

Clipboard history is stored at:

```
~/Library/Application Support/ClipboardManager/history.json
```

Auto-backup defaults to:

```
~/Documents/ClipboardBackup.json
```

## Requirements

- macOS 13+
- Swift 5.9+
