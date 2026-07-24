import AppKit
import SwiftUI

// Renders the popover UI to a PNG with mocked (privacy-safe) data by hosting the
// real SwiftUI view in an off-screen window and capturing it — no screen-recording
// permission required, and ScrollView/SF Symbols render correctly.
//   MakeScreenshot <out.png> [dark|light]

@main
struct MakeScreenshot {
    @MainActor
    static func main() {
        let out = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "popover.png"
        let dark = (CommandLine.arguments.count > 2 ? CommandLine.arguments[2] : "dark") != "light"

        let app = NSApplication.shared
        app.setActivationPolicy(.accessory)
        let appearance = NSAppearance(named: dark ? .darkAqua : .aqua)!
        app.appearance = appearance

        // Register bundled icons under the names ContentView looks up.
        for name in ["MenuIcon", "ChatGPTIcon"] {
            if let img = NSImage(contentsOfFile: "Resources/\(name).png") { img.setName(name) }
        }

        // Mocked accounts (fake emails/ids).
        let iso = ISO8601DateFormatter(); iso.formatOptions = [.withInternetDateTime]
        let reset = iso.string(from: Date().addingTimeInterval(4 * 86_400 + 17 * 3_600))
        let json = """
        {"accounts":[
          {"accountId":"a1","chatgptAccountId":"1f2e3d4c-5b6a-4788-9c0d-1122334455ff",
           "email":"you@example.com","displayName":"you@example.com","planType":"plus",
           "routingPolicy":"normal","status":"active","usage":{"secondaryRemainingPercent":68.0},
           "resetAtSecondary":"\(reset)","windowMinutesSecondary":10080,
           "limitWarmupEnabled":false,"availableResetCredits":3},
          {"accountId":"a2","chatgptAccountId":"9a8b7c6d-5e4f-4a1b-8c2d-66aabbccddee",
           "email":"team@example.com","displayName":"team@example.com","planType":"plus",
           "routingPolicy":"normal","status":"active","usage":{"secondaryRemainingPercent":31.0},
           "resetAtSecondary":"\(reset)","windowMinutesSecondary":10080,
           "limitWarmupEnabled":false,"availableResetCredits":3}
        ]}
        """
        let accounts = (try? JSONDecoder().decode(AccountsResponse.self, from: Data(json.utf8)).accounts) ?? []

        let vm = AccountsViewModel()
        vm.accounts = accounts
        vm.lastUpdated = Date()

        let W = PopoverSizing.width
        let H = PopoverSizing.height(forAccountCount: accounts.count)

        let root = ContentView()
            .environmentObject(vm)
            .frame(width: W, height: H)
            .background(Color(nsColor: .windowBackgroundColor))
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

        let host = NSHostingView(rootView: root)
        host.frame = NSRect(x: 0, y: 0, width: W, height: H)
        host.appearance = appearance

        let window = NSWindow(contentRect: host.frame,
                              styleMask: [.borderless], backing: .buffered, defer: false)
        window.appearance = appearance
        window.isOpaque = false
        window.backgroundColor = .clear
        window.contentView = host
        window.alphaValue = 0            // realized on the (retina) screen but invisible
        window.orderFrontRegardless()

        // Let SwiftUI lay out and draw.
        host.layoutSubtreeIfNeeded()
        RunLoop.main.run(until: Date().addingTimeInterval(0.6))

        let bounds = host.bounds
        guard let rep = host.bitmapImageRepForCachingDisplay(in: bounds) else {
            FileHandle.standardError.write(Data("no rep\n".utf8)); exit(1)
        }
        host.cacheDisplay(in: bounds, to: rep)
        guard let png = rep.representation(using: .png, properties: [:]) else {
            FileHandle.standardError.write(Data("encode failed\n".utf8)); exit(1)
        }
        try? png.write(to: URL(fileURLWithPath: out))
        print("wrote \(out) \(rep.pixelsWide)x\(rep.pixelsHigh) (\(dark ? "dark" : "light"))")
        exit(0)
    }
}
