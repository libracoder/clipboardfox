import SwiftUI

struct ClipboardView: View {
    @ObservedObject var monitor: ClipboardMonitor
    @State private var searchText = ""
    @State private var isShowingSettings = false
    @FocusState private var isSearchFocused: Bool

    var filteredItems: [ClipItem] {
        if searchText.isEmpty {
            return monitor.items
        }
        return monitor.items.filter {
            $0.text.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        if isShowingSettings {
            SettingsView(monitor: monitor, isShowingSettings: $isShowingSettings)
        } else {
            mainView
        }
    }

    var mainView: some View {
        VStack(spacing: 0) {
            // Search bar
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                    .font(.system(size: 13))
                TextField("Search clipboard history...", text: $searchText)
                    .textFieldStyle(.plain)
                    .font(.system(size: 13))
                    .focused($isSearchFocused)
                if !searchText.isEmpty {
                    Button(action: { searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                            .font(.system(size: 12))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color(nsColor: .controlBackgroundColor))

            Divider()

            // Clip list
            if filteredItems.isEmpty {
                VStack(spacing: 8) {
                    Spacer()
                    Image(systemName: searchText.isEmpty ? "clipboard" : "magnifyingglass")
                        .font(.system(size: 28))
                        .foregroundColor(.secondary)
                    Text(searchText.isEmpty ? "Clipboard history is empty" : "No matches found")
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(filteredItems) { item in
                            ClipItemRow(item: item) {
                                monitor.copyToClipboard(item)
                                NotificationCenter.default.post(name: .dismissPopover, object: nil)
                            } onDelete: {
                                withAnimation(.easeOut(duration: 0.2)) {
                                    monitor.delete(item)
                                }
                            }
                        }
                    }
                }
            }

            Divider()

            // Footer
            HStack {
                Text("\(monitor.items.count) items")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
                Spacer()
                Button(action: { monitor.clearAll() }) {
                    Text("Clear All")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
                .opacity(monitor.items.isEmpty ? 0.5 : 1)
                .disabled(monitor.items.isEmpty)

                Button(action: { isShowingSettings = true }) {
                    Image(systemName: "gearshape")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
        }
        .frame(width: 360, height: 450)
        .onAppear {
            isSearchFocused = true
        }
    }
}

struct ClipItemRow: View {
    let item: ClipItem
    let onCopy: () -> Void
    let onDelete: () -> Void
    @State private var isHovered = false

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            VStack(alignment: .leading, spacing: 3) {
                Text(item.preview)
                    .font(.system(size: 12.5))
                    .lineLimit(2)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text(item.timeAgo)
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
            }

            if isHovered {
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .contentShape(Rectangle())
        .background(isHovered ? Color(nsColor: .selectedContentBackgroundColor).opacity(0.3) : Color.clear)
        .onHover { hovering in
            isHovered = hovering
        }
        .onTapGesture {
            onCopy()
        }
    }
}
