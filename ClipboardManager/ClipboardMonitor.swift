import SwiftUI
import AppKit

struct ClipItem: Identifiable, Codable, Equatable {
    let id: UUID
    let text: String
    let timestamp: Date

    init(text: String) {
        self.id = UUID()
        self.text = text
        self.timestamp = Date()
    }

    var preview: String {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.count > 120 {
            return String(trimmed.prefix(120)) + "..."
        }
        return trimmed
    }

    var timeAgo: String {
        let interval = Date().timeIntervalSince(timestamp)
        if interval < 60 { return "just now" }
        if interval < 3600 { return "\(Int(interval / 60))m ago" }
        if interval < 86400 { return "\(Int(interval / 3600))h ago" }
        return "\(Int(interval / 86400))d ago"
    }
}

class AppSettings: ObservableObject {
    static let shared = AppSettings()

    @Published var maxClips: Int {
        didSet { UserDefaults.standard.set(maxClips, forKey: "maxClips") }
    }
    @Published var autoBackup: Bool {
        didSet { UserDefaults.standard.set(autoBackup, forKey: "autoBackup") }
    }
    @Published var backupPath: String {
        didSet { UserDefaults.standard.set(backupPath, forKey: "backupPath") }
    }

    init() {
        let defaults = UserDefaults.standard
        if defaults.object(forKey: "maxClips") == nil {
            defaults.set(200, forKey: "maxClips")
        }
        if defaults.object(forKey: "autoBackup") == nil {
            defaults.set(true, forKey: "autoBackup")
        }
        if defaults.object(forKey: "backupPath") == nil {
            let defaultPath = FileManager.default.homeDirectoryForCurrentUser
                .appendingPathComponent("Documents")
                .appendingPathComponent("ClipboardBackup.json")
                .path
            defaults.set(defaultPath, forKey: "backupPath")
        }
        self.maxClips = defaults.integer(forKey: "maxClips")
        self.autoBackup = defaults.bool(forKey: "autoBackup")
        self.backupPath = defaults.string(forKey: "backupPath") ?? ""
    }
}

class ClipboardMonitor: ObservableObject {
    @Published var items: [ClipItem] = []
    private var timer: Timer?
    private var lastChangeCount: Int
    private let storageURL: URL
    let settings = AppSettings.shared

    init() {
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let dir = appSupport.appendingPathComponent("ClipboardManager")
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        storageURL = dir.appendingPathComponent("history.json")

        lastChangeCount = NSPasteboard.general.changeCount
        loadHistory()
        startMonitoring()
    }

    func startMonitoring() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            self?.checkClipboard()
        }
    }

    private func checkClipboard() {
        let pasteboard = NSPasteboard.general
        guard pasteboard.changeCount != lastChangeCount else { return }
        lastChangeCount = pasteboard.changeCount

        guard let text = pasteboard.string(forType: .string), !text.isEmpty else { return }
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        if let first = items.first, first.text == text { return }

        items.removeAll { $0.text == text }

        let item = ClipItem(text: text)
        DispatchQueue.main.async {
            self.items.insert(item, at: 0)
            let max = self.settings.maxClips
            if self.items.count > max {
                self.items = Array(self.items.prefix(max))
            }
            self.saveHistory()
            if self.settings.autoBackup {
                self.autoBackup()
            }
        }
    }

    func copyToClipboard(_ item: ClipItem) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(item.text, forType: .string)
        lastChangeCount = pasteboard.changeCount
    }

    func delete(_ item: ClipItem) {
        items.removeAll { $0.id == item.id }
        saveHistory()
    }

    func clearAll() {
        items.removeAll()
        saveHistory()
    }

    func applyMaxClips() {
        let max = settings.maxClips
        if items.count > max {
            items = Array(items.prefix(max))
            saveHistory()
        }
    }

    func saveHistory() {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        if let data = try? encoder.encode(items) {
            try? data.write(to: storageURL)
        }
    }

    func loadHistory() {
        guard let data = try? Data(contentsOf: storageURL) else { return }
        // Try ISO 8601 first, fall back to default
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        if let saved = try? decoder.decode([ClipItem].self, from: data) {
            items = saved
            return
        }
        // Fallback for old data
        let fallbackDecoder = JSONDecoder()
        if let saved = try? fallbackDecoder.decode([ClipItem].self, from: data) {
            items = saved
        }
    }

    // MARK: - Backup

    private func autoBackup() {
        let path = settings.backupPath
        guard !path.isEmpty else { return }
        let url = URL(fileURLWithPath: path)
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = .prettyPrinted
        if let data = try? encoder.encode(items) {
            try? data.write(to: url)
        }
    }

    func exportBackup(to url: URL) -> Bool {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = .prettyPrinted
        guard let data = try? encoder.encode(items) else { return false }
        do {
            try data.write(to: url)
            return true
        } catch {
            return false
        }
    }

    func importBackup(from url: URL) -> Int {
        guard let data = try? Data(contentsOf: url) else { return 0 }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        guard let imported = try? decoder.decode([ClipItem].self, from: data) else { return 0 }

        var added = 0
        for item in imported {
            if !items.contains(where: { $0.text == item.text }) {
                items.append(item)
                added += 1
            }
        }
        // Sort by timestamp descending
        items.sort { $0.timestamp > $1.timestamp }
        // Trim to max
        let max = settings.maxClips
        if items.count > max {
            items = Array(items.prefix(max))
        }
        saveHistory()
        return added
    }
}
