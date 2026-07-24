import AppKit
import Combine
import SwiftUI

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private let popover = NSPopover()
    private let viewModel = AccountsViewModel()
    private var eventMonitor: Any?
    private var cancellables = Set<AnyCancellable>()

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Status bar item — pure icon, no title.
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem.button {
            let img = NSImage(named: "MenuIcon")
                ?? NSImage(systemSymbolName: "gauge.medium", accessibilityDescription: "CodexBar")
            img?.isTemplate = false          // keep the blue/purple colour
            if let img, img.size.height > 0 {
                let h: CGFloat = 20          // match neighbouring menu-bar icons
                img.size = NSSize(width: h * img.size.width / img.size.height, height: h)
            }
            button.image = img
            button.action = #selector(togglePopover(_:))
            button.target = self
        }

        popover.behavior = .transient
        popover.animates = true
        popover.contentSize = NSSize(width: PopoverSizing.width,
                                     height: PopoverSizing.height(forAccountCount: 0))
        popover.contentViewController = NSHostingController(
            rootView: ContentView().environmentObject(viewModel)
        )

        // Keep the AppKit popover size in lockstep with the account list.
        viewModel.$accounts
            .receive(on: RunLoop.main)
            .sink { [weak self] accounts in
                self?.popover.contentSize = NSSize(
                    width: PopoverSizing.width,
                    height: PopoverSizing.height(forAccountCount: accounts.count))
            }
            .store(in: &cancellables)

        // Prime data so the first open shows something immediately.
        viewModel.refresh()
    }

    @objc private func togglePopover(_ sender: AnyObject?) {
        if popover.isShown {
            closePopover()
        } else {
            showPopover()
        }
    }

    private func showPopover() {
        guard let button = statusItem.button else { return }
        // Refresh on every open, per the requested behavior.
        viewModel.refresh()
        popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
        popover.contentViewController?.view.window?.makeKey()

        // Close when clicking outside the popover.
        eventMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] _ in
            self?.closePopover()
        }
    }

    private func closePopover() {
        popover.performClose(nil)
        if let monitor = eventMonitor {
            NSEvent.removeMonitor(monitor)
            eventMonitor = nil
        }
    }
}
