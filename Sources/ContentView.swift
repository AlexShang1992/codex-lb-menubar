import AppKit
import SwiftUI

struct ContentView: View {
    @EnvironmentObject var vm: AccountsViewModel

    var body: some View {
        VStack(spacing: 0) {
            header
            Divider()

            if let err = vm.errorMessage, vm.accounts.isEmpty {
                errorState(err)
            } else if vm.accounts.isEmpty && vm.isLoading {
                loadingState
            } else if vm.accounts.isEmpty {
                emptyState
            } else {
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(vm.accounts) { account in
                            AccountCard(account: account)
                        }
                    }
                    .padding(12)
                }
            }

            Divider()
            footer
        }
        .frame(width: PopoverSizing.width,
               height: PopoverSizing.height(forAccountCount: vm.accounts.count))
    }

    private var header: some View {
        HStack(spacing: 8) {
            Image(systemName: "gauge.medium")
                .foregroundStyle(.secondary)
            Text("Accounts")
                .font(.headline)
            if vm.isLoading {
                ProgressView()
                    .controlSize(.small)
                    .padding(.leading, 2)
            }
            Spacer()
            Text("\(vm.accounts.count)")
                .font(.caption.monospacedDigit())
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
    }

    private var footer: some View {
        HStack(spacing: 10) {
            if let d = vm.lastUpdated {
                Text("更新于 \(Self.timeFormatter.string(from: d))")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            } else {
                Text(" ")
                    .font(.caption2)
            }
            Spacer()
            Button {
                openChatGPT()
            } label: {
                Image(systemName: "message")
            }
            .buttonStyle(.borderless)
            .help("打开 ChatGPT")

            Button {
                NSWorkspace.shared.open(Config.accountsPage)
            } label: {
                Image(systemName: "arrow.up.right.square")
            }
            .buttonStyle(.borderless)
            .help("在浏览器打开 accounts 页面")

            Button {
                vm.refresh()
            } label: {
                Image(systemName: "arrow.clockwise")
            }
            .buttonStyle(.borderless)
            .help("刷新")

            Button("退出") {
                NSApp.terminate(nil)
            }
            .buttonStyle(.borderless)
            .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
    }

    private func errorState(_ message: String) -> some View {
        VStack(spacing: 10) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 26))
                .foregroundStyle(.orange)
            Text(message)
                .font(.callout)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
            Button("重试") { vm.refresh() }
        }
        .padding(24)
        .frame(maxHeight: .infinity)
    }

    private var loadingState: some View {
        VStack {
            ProgressView().controlSize(.large)
        }
        .frame(maxHeight: .infinity)
    }

    private var emptyState: some View {
        VStack(spacing: 8) {
            Image(systemName: "tray")
                .font(.system(size: 26))
                .foregroundStyle(.secondary)
            Text("暂无账号")
                .foregroundStyle(.secondary)
        }
        .frame(maxHeight: .infinity)
    }

    /// Launch the ChatGPT desktop app (falls back to its default install path).
    private func openChatGPT() {
        let ws = NSWorkspace.shared
        let config = NSWorkspace.OpenConfiguration()
        if let url = ws.urlForApplication(withBundleIdentifier: "com.openai.codex") {
            ws.openApplication(at: url, configuration: config)
            return
        }
        let fallback = URL(fileURLWithPath: "/Applications/ChatGPT.app")
        if FileManager.default.fileExists(atPath: fallback.path) {
            ws.openApplication(at: fallback, configuration: config)
        }
    }

    static let timeFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "HH:mm"
        return f
    }()
}

// MARK: - Card

struct AccountCard: View {
    let account: Account

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            topRow
            Text(account.subtitle)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)

            weeklyBlock

            HStack {
                Text(account.warmupText)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Spacer()
                Text("No attempts")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color(nsColor: .controlBackgroundColor))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(Color.primary.opacity(0.08), lineWidth: 1)
        )
        .overlay(alignment: .topTrailing) {
            if account.resetCredits > 0 {
                Text("\(account.resetCredits)")
                    .font(.caption2.bold())
                    .foregroundStyle(.white)
                    .frame(width: 20, height: 20)
                    .background(Circle().fill(Color.blue))
                    .offset(x: 7, y: -7)
                    .help("可用 reset credits: \(account.resetCredits)")
            }
        }
    }

    private var topRow: some View {
        HStack(spacing: 8) {
            Text(account.title)
                .font(.system(size: 14, weight: .semibold))
                .lineLimit(1)
                .truncationMode(.middle)
            Spacer(minLength: 4)
            Pill(text: account.routingLabel, style: .neutral)
            Pill(text: account.statusLabel, style: account.isActive ? .active : .neutral)
        }
    }

    private var weeklyBlock: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("Weekly")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                Text(percentText)
                    .font(.caption.weight(.semibold).monospacedDigit())
            }
            ProgressBar(fraction: (account.weeklyPercent ?? 0) / 100.0)
            Text(account.resetText)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }

    private var percentText: String {
        guard let p = account.weeklyPercent else { return "—" }
        return "\(Int(p.rounded()))%"
    }
}

// MARK: - Small components

struct ProgressBar: View {
    let fraction: Double // 0...1

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.primary.opacity(0.10))
                Capsule()
                    .fill(barColor)
                    .frame(width: max(0, min(1, fraction)) * geo.size.width)
            }
        }
        .frame(height: 6)
    }

    private var barColor: Color {
        // amber like the reference; nudges toward red when nearly empty
        if fraction <= 0.1 { return .red }
        return Color(red: 0.95, green: 0.62, blue: 0.11)
    }
}

struct Pill: View {
    enum Style { case neutral, active }
    let text: String
    let style: Style

    var body: some View {
        HStack(spacing: 4) {
            if style == .active {
                Circle()
                    .fill(Color.green)
                    .frame(width: 6, height: 6)
            }
            Text(text)
                .font(.caption2.weight(.medium))
                .foregroundStyle(style == .active ? Color.green : Color.secondary)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 3)
        .background(
            Capsule().fill(style == .active
                ? Color.green.opacity(0.14)
                : Color.primary.opacity(0.07))
        )
    }
}
