import Foundation

// MARK: - Data model matching GET http://127.0.0.1:2455/api/accounts

struct AccountsResponse: Codable {
    let accounts: [Account]
}

struct Usage: Codable {
    let primaryRemainingPercent: Double?
    let secondaryRemainingPercent: Double?
    let monthlyRemainingPercent: Double?
}

struct Account: Codable, Identifiable {
    var id: String { accountId }

    let accountId: String
    let chatgptAccountId: String?
    let email: String?
    let alias: String?
    let displayName: String?
    let planType: String?
    let routingPolicy: String?
    let status: String?
    let usage: Usage?
    let resetAtSecondary: String?
    let windowMinutesSecondary: Int?
    let limitWarmupEnabled: Bool?
    let availableResetCredits: Int?

    // MARK: Presentation helpers (mirror Image #1)

    var title: String {
        if let a = alias, !a.isEmpty { return a }
        if let d = displayName, !d.isEmpty { return d }
        if let e = email, !e.isEmpty { return e }
        return accountId
    }

    /// e.g. "Plus"
    var planLabel: String {
        guard let p = planType, !p.isEmpty else { return "—" }
        return p.prefix(1).uppercased() + p.dropFirst()
    }

    /// e.g. "cd8f7092-316d-45…"
    var idShort: String {
        guard let cid = chatgptAccountId, !cid.isEmpty else { return "" }
        if cid.count <= 16 { return cid }
        return String(cid.prefix(16)) + "…"
    }

    /// "Plus | cd8f7092-316d-45…"
    var subtitle: String {
        let id = idShort
        return id.isEmpty ? planLabel : "\(planLabel) | \(id)"
    }

    /// e.g. "Normal"
    var routingLabel: String {
        guard let r = routingPolicy, !r.isEmpty else { return "—" }
        return r.prefix(1).uppercased() + r.dropFirst()
    }

    /// e.g. "Active"
    var statusLabel: String {
        guard let s = status, !s.isEmpty else { return "—" }
        return s.prefix(1).uppercased() + s.dropFirst()
    }

    var isActive: Bool { (status ?? "").lowercased() == "active" }

    /// Weekly remaining percent (secondary window == 7 days).
    var weeklyPercent: Double? { usage?.secondaryRemainingPercent }

    var warmupText: String { (limitWarmupEnabled ?? false) ? "Warm-up on" : "Warm-up off" }

    var resetCredits: Int { availableResetCredits ?? 0 }

    /// "Reset in 4d 21h" computed from resetAtSecondary.
    var resetText: String {
        guard let iso = resetAtSecondary, let date = Account.parseISO(iso) else {
            return "Reset —"
        }
        let secs = date.timeIntervalSinceNow
        if secs <= 0 { return "Reset available" }
        let days = Int(secs) / 86_400
        let hours = (Int(secs) % 86_400) / 3_600
        let mins = (Int(secs) % 3_600) / 60
        if days > 0 { return "Reset in \(days)d \(hours)h" }
        if hours > 0 { return "Reset in \(hours)h \(mins)m" }
        return "Reset in \(mins)m"
    }

    private static let isoFormatter: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime]
        return f
    }()

    private static let isoFractional: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return f
    }()

    static func parseISO(_ s: String) -> Date? {
        isoFormatter.date(from: s) ?? isoFractional.date(from: s)
    }
}
