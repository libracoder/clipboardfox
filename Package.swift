// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "ClipboardFox",
    platforms: [.macOS(.v13)],
    targets: [
        .target(
            name: "ClipboardCore",
            path: "Sources"
        ),
        .executableTarget(
            name: "ClipboardFox",
            dependencies: ["ClipboardCore"],
            path: "ClipboardFox",
            exclude: ["Info.plist", "ClipboardFox.entitlements"]
        ),
        .testTarget(
            name: "ClipboardFoxTests",
            dependencies: ["ClipboardCore"],
            path: "Tests"
        )
    ]
)
