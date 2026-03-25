import SwiftUI
import AppKit
import ServiceManagement

struct SettingsView: View {
    @ObservedObject var monitor: ClipboardMonitor
    @ObservedObject var settings = AppSettings.shared
    @Binding var isShowingSettings: Bool
    @State private var maxClipsText: String = ""
    @State private var statusMessage: String = ""
    @State private var showStatus = false

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button(action: { isShowingSettings = false }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 12, weight: .semibold))
                    Text("Back")
                        .font(.system(size: 12))
                }
                .buttonStyle(.plain)
                .foregroundColor(.accentColor)

                Spacer()

                Text("Settings")
                    .font(.system(size: 13, weight: .semibold))

                Spacer()
                // Invisible spacer to balance layout
                Text("Back  ")
                    .font(.system(size: 12))
                    .hidden()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)

            Divider()

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {

                    // Launch at Login
                    VStack(alignment: .leading, spacing: 6) {
                        Text("General")
                            .font(.system(size: 12, weight: .semibold))
                        Toggle("Launch at Login", isOn: Binding(
                            get: { SMAppService.mainApp.status == .enabled },
                            set: { newValue in
                                do {
                                    if newValue {
                                        try SMAppService.mainApp.register()
                                    } else {
                                        try SMAppService.mainApp.unregister()
                                    }
                                } catch {
                                    showStatusMessage("Error: \(error.localizedDescription)")
                                }
                            }
                        ))
                        .font(.system(size: 12))
                        .toggleStyle(.checkbox)
                        Text("Automatically start ClipboardManager when you log in")
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                    }

                    Divider()

                    // Maximum Clips
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Maximum Clips")
                            .font(.system(size: 12, weight: .semibold))
                        HStack(spacing: 8) {
                            TextField("200", text: $maxClipsText)
                                .textFieldStyle(.roundedBorder)
                                .font(.system(size: 12))
                                .frame(width: 80)
                                .onAppear { maxClipsText = "\(settings.maxClips)" }
                                .onSubmit { applyMaxClips() }
                            Button("Apply") { applyMaxClips() }
                                .font(.system(size: 11))
                            Spacer()
                        }
                        Text("Currently storing \(monitor.items.count) clips")
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                    }

                    Divider()

                    // Auto Backup
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Auto Backup")
                            .font(.system(size: 12, weight: .semibold))
                        Toggle("Automatically backup on every new clip", isOn: $settings.autoBackup)
                            .font(.system(size: 12))
                            .toggleStyle(.checkbox)

                        HStack(spacing: 6) {
                            TextField("Backup path", text: $settings.backupPath)
                                .textFieldStyle(.roundedBorder)
                                .font(.system(size: 11))
                            Button("Browse") { chooseBackupPath() }
                                .font(.system(size: 11))
                        }
                        Text("Clips are backed up as JSON for easy recovery")
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                    }

                    Divider()

                    // Manual Backup / Restore
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Backup & Restore")
                            .font(.system(size: 12, weight: .semibold))
                        HStack(spacing: 8) {
                            Button("Export Backup...") { exportBackup() }
                                .font(.system(size: 12))
                            Button("Import Backup...") { importBackup() }
                                .font(.system(size: 12))
                        }
                        Text("Import merges clips without creating duplicates")
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                    }

                    if showStatus {
                        HStack {
                            Image(systemName: statusMessage.contains("Error") ? "xmark.circle.fill" : "checkmark.circle.fill")
                                .foregroundColor(statusMessage.contains("Error") ? .red : .green)
                                .font(.system(size: 12))
                            Text(statusMessage)
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                        }
                        .transition(.opacity)
                    }

                    Divider()

                    // Info
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Storage")
                            .font(.system(size: 12, weight: .semibold))
                        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
                        let storagePath = appSupport.appendingPathComponent("ClipboardManager/history.json").path
                        Text(storagePath)
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }

                    Spacer()
                }
                .padding(14)
            }
        }
        .frame(width: 360, height: 450)
    }

    private func applyMaxClips() {
        if let val = Int(maxClipsText), val >= 10, val <= 10000 {
            settings.maxClips = val
            monitor.applyMaxClips()
            showStatusMessage("Max clips set to \(val)")
        } else {
            maxClipsText = "\(settings.maxClips)"
            showStatusMessage("Error: Enter a number between 10 and 10,000")
        }
    }

    private func chooseBackupPath() {
        let panel = NSSavePanel()
        panel.title = "Choose Backup Location"
        panel.allowedContentTypes = [.json]
        panel.nameFieldStringValue = "ClipboardBackup.json"
        panel.canCreateDirectories = true
        if panel.runModal() == .OK, let url = panel.url {
            settings.backupPath = url.path
        }
    }

    private func exportBackup() {
        let panel = NSSavePanel()
        panel.title = "Export Clipboard Backup"
        panel.allowedContentTypes = [.json]
        panel.nameFieldStringValue = "ClipboardBackup_\(dateString()).json"
        panel.canCreateDirectories = true
        if panel.runModal() == .OK, let url = panel.url {
            if monitor.exportBackup(to: url) {
                showStatusMessage("Exported \(monitor.items.count) clips")
            } else {
                showStatusMessage("Error: Failed to export")
            }
        }
    }

    private func importBackup() {
        let panel = NSOpenPanel()
        panel.title = "Import Clipboard Backup"
        panel.allowedContentTypes = [.json]
        panel.allowsMultipleSelection = false
        if panel.runModal() == .OK, let url = panel.url {
            let added = monitor.importBackup(from: url)
            showStatusMessage("Imported \(added) new clips")
        }
    }

    private func showStatusMessage(_ msg: String) {
        statusMessage = msg
        withAnimation { showStatus = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            withAnimation { showStatus = false }
        }
    }

    private func dateString() -> String {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        return df.string(from: Date())
    }
}
