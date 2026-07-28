import Foundation

/// App configuration. The codex-lb base URL can be overridden at launch with
/// the `CODEXBAR_ENDPOINT` environment variable, e.g.
///
///     CODEXBAR_ENDPOINT=http://127.0.0.1:9000 open CodexBar.app
///
enum Config {
    static let defaultBaseURL = "http://127.0.0.1:2455"

    /// Base URL of the running codex-lb server.
    static let baseURL: URL = {
        let raw = ProcessInfo.processInfo.environment["CODEXBAR_ENDPOINT"]?
            .trimmingCharacters(in: .whitespacesAndNewlines)
        if let raw, !raw.isEmpty, let url = URL(string: raw) { return url }
        return URL(string: defaultBaseURL)!
    }()

    /// JSON endpoint the popover polls.
    static var accountsAPI: URL { baseURL.appendingPathComponent("api/accounts") }

    /// Web dashboard opened by the "open in browser" button.
    static var accountsPage: URL { baseURL.appendingPathComponent("accounts") }

    /// This project's GitHub repository, opened by the footer GitHub button.
    static let repoURL = URL(string: "https://github.com/AlexShang1992/codex-lb-menubar")!
}
