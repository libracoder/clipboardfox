import SwiftUI
import AppKit

@main
struct ClipboardFoxApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}

extension Notification.Name {
    static let dismissPopover = Notification.Name("dismissPopover")
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem!
    var popover: NSPopover!
    var clipboardMonitor: ClipboardMonitor!
    var eventMonitor: Any?

    func applicationDidFinishLaunching(_ notification: Notification) {
        clipboardMonitor = ClipboardMonitor()

        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem.button {
            button.image = makeMenuBarIcon()
            button.action = #selector(togglePopover)
            button.target = self
        }

        popover = NSPopover()
        popover.contentSize = NSSize(width: 360, height: 450)
        popover.behavior = .transient
        popover.animates = true
        popover.contentViewController = NSHostingController(
            rootView: ClipboardView(monitor: clipboardMonitor)
        )

        eventMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] _ in
            if let popover = self?.popover, popover.isShown {
                popover.performClose(nil)
            }
        }

        NotificationCenter.default.addObserver(
            forName: .dismissPopover, object: nil, queue: .main
        ) { [weak self] _ in
            self?.popover.performClose(nil)
        }
    }

    private func makeMenuBarIcon() -> NSImage {
        let size = NSSize(width: 18, height: 18)
        let image = NSImage(size: size, flipped: false) { rect in
            NSGraphicsContext.current?.cgContext.translateBy(x: 0, y: 0)

            let path = NSBezierPath()
            let lineWidth: CGFloat = 1.6
            path.lineWidth = lineWidth
            path.lineCapStyle = .round
            path.lineJoinStyle = .round

            // Draw a paperclip shape
            // Starting from bottom-right, going up, around top, down, around bottom, up
            let left: CGFloat = 5.5
            let right: CGFloat = 12.5
            let midLeft: CGFloat = 7.5
            let midRight: CGFloat = 10.5

            // Outer clip path
            path.move(to: NSPoint(x: right, y: 3))
            path.line(to: NSPoint(x: right, y: 13))
            path.appendArc(
                withCenter: NSPoint(x: (left + right) / 2, y: 13),
                radius: (right - left) / 2,
                startAngle: 0, endAngle: 180
            )
            path.line(to: NSPoint(x: left, y: 5.5))
            path.appendArc(
                withCenter: NSPoint(x: (left + right) / 2, y: 5.5),
                radius: (right - left) / 2,
                startAngle: 180, endAngle: 360
            )
            path.line(to: NSPoint(x: right, y: 5.5))

            // Inner return path
            let innerPath = NSBezierPath()
            innerPath.lineWidth = lineWidth
            innerPath.lineCapStyle = .round
            innerPath.lineJoinStyle = .round

            innerPath.move(to: NSPoint(x: midLeft, y: 6))
            innerPath.line(to: NSPoint(x: midLeft, y: 12))
            innerPath.appendArc(
                withCenter: NSPoint(x: (midLeft + midRight) / 2, y: 12),
                radius: (midRight - midLeft) / 2,
                startAngle: 180, endAngle: 0, clockwise: true
            )
            innerPath.line(to: NSPoint(x: midRight, y: 7))

            NSColor.white.setStroke()
            path.stroke()
            innerPath.stroke()

            return true
        }
        image.isTemplate = true
        return image
    }

    @objc func togglePopover() {
        guard let button = statusItem.button else { return }
        if popover.isShown {
            popover.performClose(nil)
        } else {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            popover.contentViewController?.view.window?.makeKey()
            NSApp.activate(ignoringOtherApps: true)
        }
    }
}
