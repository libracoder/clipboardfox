// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "ClipboardFox",
    platforms: [.macOS(.v13)],
    targets: [
        .executableTarget(
            name: "ClipboardFox",
            path: "ClipboardFox",
            exclude: ["Info.plist", "ClipboardFox.entitlements"]
        )
    ]
)
