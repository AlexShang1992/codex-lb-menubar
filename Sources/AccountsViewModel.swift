import Foundation
import SwiftUI

/// Single source of truth for the popover size, shared by the SwiftUI layout
/// and the AppKit NSPopover.contentSize so they never disagree.
enum PopoverSizing {
    static let width: CGFloat = 380
    static let cardHeight: CGFloat = 156

    static func height(forAccountCount n: Int) -> CGFloat {
        let chrome: CGFloat = 44 + 40 + 2 // header + footer + dividers
        let body: CGFloat
        if n > 0 {
            let count = CGFloat(n)
            body = 24 + count * cardHeight + (count - 1) * 12
        } else {
            body = 200 // loading / empty / error states
        }
        return min(max(chrome + body, 220), 660)
    }
}

enum AccountsAPI {
    static var endpoint: URL { Config.accountsAPI }

    static func fetch() async throws -> [Account] {
        var req = URLRequest(url: endpoint)
        req.timeoutInterval = 8
        req.cachePolicy = .reloadIgnoringLocalCacheData
        let (data, resp) = try await URLSession.shared.data(for: req)
        if let http = resp as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
            throw NSError(domain: "CodexBar", code: http.statusCode,
                          userInfo: [NSLocalizedDescriptionKey: "HTTP \(http.statusCode)"])
        }
        return try JSONDecoder().decode(AccountsResponse.self, from: data).accounts
    }
}

@MainActor
final class AccountsViewModel: ObservableObject {
    @Published var accounts: [Account] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var lastUpdated: Date?

    func refresh() {
        if isLoading { return }
        isLoading = true
        Task { [weak self] in
            guard let self else { return }
            do {
                let result = try await AccountsAPI.fetch()
                self.accounts = result
                self.errorMessage = nil
                self.lastUpdated = Date()
            } catch {
                self.errorMessage = Self.friendly(error)
            }
            self.isLoading = false
        }
    }

    private static func friendly(_ error: Error) -> String {
        let ns = error as NSError
        if ns.domain == NSURLErrorDomain {
            switch ns.code {
            case NSURLErrorCannotConnectToHost, NSURLErrorCannotFindHost:
                return "连接不上 codex-lb (127.0.0.1:2455)，服务是否在运行？"
            case NSURLErrorTimedOut:
                return "请求超时，codex-lb 未响应。"
            default: break
            }
        }
        return ns.localizedDescription
    }
}
