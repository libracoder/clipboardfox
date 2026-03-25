// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "ClipboardManager",
    platforms: [.macOS(.v13)],
    targets: [
        .executableTarget(
            name: "ClipboardManager",
            path: "ClipboardManager",
            exclude: ["Info.plist", "ClipboardManager.entitlements"]
        )
    ]
)
