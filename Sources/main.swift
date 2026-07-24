import AppKit
import Foundation

// Headless self-test: fetch + decode against the live API, print a summary, exit.
// Usage: CodexBar --selftest
if CommandLine.arguments.contains("--selftest") {
    let sem = DispatchSemaphore(value: 0)
    Task {
        do {
            let accounts = try await AccountsAPI.fetch()
            print("OK: decoded \(accounts.count) account(s)")
            for a in accounts {
                let pct = a.weeklyPercent.map { "\(Int($0.rounded()))%" } ?? "—"
                print("  • \(a.title) | \(a.routingLabel) | \(a.statusLabel) | Weekly \(pct) | \(a.resetText) | \(a.warmupText) | credits \(a.resetCredits)")
            }
            exit(0)
        } catch {
            print("FAIL: \(error)")
            exit(1)
        }
        _ = sem
    }
    dispatchMain()
}

MainActor.assumeIsolated {
    let app = NSApplication.shared
    let delegate = AppDelegate()
    app.delegate = delegate
    app.setActivationPolicy(.accessory) // agent app: no Dock icon, no menu bar app menu
    app.run()
}
