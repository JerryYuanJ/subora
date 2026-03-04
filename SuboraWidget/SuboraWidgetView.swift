//
//  SuboraWidgetView.swift
//  SuboraWidget
//
//  Widget UI for Small, Medium, and Large sizes.
//

import SwiftUI
import WidgetKit

// MARK: - Localization Helper

private enum WL {
    static let subora = String(localized: "widget.subora")
    static let perMonth = String(localized: "widget.per_month")
    static func activeCount(_ count: Int) -> String {
        String(format: String(localized: "widget.active_count"), count)
    }
    static let upcoming = String(localized: "widget.upcoming")
    static let upcomingRenewals = String(localized: "widget.upcoming_renewals")
    static let noUpcoming = String(localized: "widget.no_upcoming")
    static let today = String(localized: "widget.today")
    static let tomorrow = String(localized: "widget.tomorrow")
    static func inDays(_ days: Int) -> String {
        String(format: String(localized: "widget.in_days"), days)
    }
    static let monthlySuffix = String(localized: "widget.monthly_suffix")
    static let upgradeToPro = String(localized: "widget.upgrade_to_pro")
    static let unlockWidgets = String(localized: "widget.unlock_widgets")
    static let emptyTitle = String(localized: "widget.empty_title")
    static let emptySubtitle = String(localized: "widget.empty_subtitle")
}

// MARK: - Entry View (routes to correct size)

struct SuboraWidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    var entry: SuboraWidgetEntry

    var body: some View {
        Group {
            if !entry.data.isProUser {
                ProLockedView(family: family)
            } else if entry.data.subscriptions.isEmpty {
                EmptyStateView()
            } else {
                switch family {
                case .systemSmall:
                    SmallWidgetView(data: entry.data)
                case .systemMedium:
                    MediumWidgetView(data: entry.data)
                case .systemLarge:
                    LargeWidgetView(data: entry.data)
                default:
                    SmallWidgetView(data: entry.data)
                }
            }
        }
    }
}

// MARK: - Small Widget

struct SmallWidgetView: View {
    let data: WidgetData

    private var primaryCurrency: String {
        data.monthlyTotalsByCurrency.max(by: { $0.value < $1.value })?.key ?? "USD"
    }

    private var monthlyTotal: Decimal {
        data.monthlyTotalsByCurrency[primaryCurrency] ?? 0
    }

    private var nextRenewal: WidgetSubscriptionItem? {
        data.subscriptions
            .filter { $0.daysUntilNextBilling >= 0 }
            .sorted { $0.nextBillingDate < $1.nextBillingDate }
            .first
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header
            HStack {
                Image("SuboraIcon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 16, height: 16)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                Text(WL.subora)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            // Monthly total
            Text(WidgetCurrencyFormatter.format(amount: monthlyTotal, currency: primaryCurrency))
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(colorFromHex(data.themeColorHex))
                .minimumScaleFactor(0.6)
                .lineLimit(1)

            Text(WL.perMonth)
                .font(.caption2)
                .foregroundStyle(.secondary)

            // Show other currencies if present
            if data.monthlyTotalsByCurrency.count > 1 {
                let otherTotals = data.monthlyTotalsByCurrency.filter { $0.key != primaryCurrency }
                ForEach(Array(otherTotals.prefix(1)), id: \.key) { currency, amount in
                    Text("+ \(WidgetCurrencyFormatter.format(amount: amount, currency: currency))")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            // Next renewal
            if let next = nextRenewal {
                HStack(spacing: 4) {
                    Circle()
                        .fill(colorFromHex(next.categoryColorHex))
                        .frame(width: 6, height: 6)
                    Text(next.name)
                        .font(.caption2)
                        .lineLimit(1)
                    Spacer()
                    Text(daysText(next.daysUntilNextBilling))
                        .font(.caption2)
                        .foregroundStyle(urgencyColor(next.daysUntilNextBilling))
                }
            }
        }
        .padding(2)
    }
}

// MARK: - Medium Widget

struct MediumWidgetView: View {
    let data: WidgetData

    private var primaryCurrency: String {
        data.monthlyTotalsByCurrency.max(by: { $0.value < $1.value })?.key ?? "USD"
    }

    private var monthlyTotal: Decimal {
        data.monthlyTotalsByCurrency[primaryCurrency] ?? 0
    }

    private var upcomingSubscriptions: [WidgetSubscriptionItem] {
        data.subscriptions
            .filter { $0.daysUntilNextBilling >= 0 }
            .sorted { $0.nextBillingDate < $1.nextBillingDate }
            .prefix(3)
            .map { $0 }
    }

    var body: some View {
        HStack(spacing: 12) {
            // Left: Monthly total
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Image("SuboraIcon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 16, height: 16)
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                    Text(WL.subora)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Text(WidgetCurrencyFormatter.format(amount: monthlyTotal, currency: primaryCurrency))
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(colorFromHex(data.themeColorHex))
                    .minimumScaleFactor(0.6)
                    .lineLimit(1)

                Text(WL.perMonth)
                    .font(.caption2)
                    .foregroundStyle(.secondary)

                if data.monthlyTotalsByCurrency.count > 1 {
                    let otherTotals = data.monthlyTotalsByCurrency.filter { $0.key != primaryCurrency }
                    ForEach(Array(otherTotals.prefix(1)), id: \.key) { currency, amount in
                        Text("+ \(WidgetCurrencyFormatter.format(amount: amount, currency: currency))")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer()

                Text(WL.activeCount(data.subscriptions.count))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            // Divider
            Rectangle()
                .fill(.quaternary)
                .frame(width: 1)
                .padding(.vertical, 4)

            // Right: Upcoming renewals
            VStack(alignment: .leading, spacing: 6) {
                Text(WL.upcoming)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)

                if upcomingSubscriptions.isEmpty {
                    Spacer()
                    Text(WL.noUpcoming)
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                    Spacer()
                } else {
                    ForEach(upcomingSubscriptions) { sub in
                        SubscriptionRow(item: sub)
                    }
                    Spacer(minLength: 0)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(2)
    }
}

// MARK: - Large Widget

struct LargeWidgetView: View {
    let data: WidgetData

    private var primaryCurrency: String {
        data.monthlyTotalsByCurrency.max(by: { $0.value < $1.value })?.key ?? "USD"
    }

    private var monthlyTotal: Decimal {
        data.monthlyTotalsByCurrency[primaryCurrency] ?? 0
    }

    private var upcomingSubscriptions: [WidgetSubscriptionItem] {
        data.subscriptions
            .filter { $0.daysUntilNextBilling >= 0 }
            .sorted { $0.nextBillingDate < $1.nextBillingDate }
            .prefix(6)
            .map { $0 }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header
            HStack {
                HStack(spacing: 4) {
                    Image("SuboraIcon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 16, height: 16)
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                    Text(WL.subora)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Text(WL.activeCount(data.subscriptions.count))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            // Monthly total
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(WidgetCurrencyFormatter.format(amount: monthlyTotal, currency: primaryCurrency))
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundStyle(colorFromHex(data.themeColorHex))
                    .minimumScaleFactor(0.6)
                    .lineLimit(1)

                Text(WL.monthlySuffix)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                if data.monthlyTotalsByCurrency.count > 1 {
                    Spacer()
                    let otherTotals = data.monthlyTotalsByCurrency.filter { $0.key != primaryCurrency }
                    ForEach(Array(otherTotals.prefix(2)), id: \.key) { currency, amount in
                        Text(WidgetCurrencyFormatter.format(amount: amount, currency: currency))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Divider()

            // Upcoming renewals header
            Text(WL.upcomingRenewals)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)

            if upcomingSubscriptions.isEmpty {
                Spacer()
                HStack {
                    Spacer()
                    VStack(spacing: 4) {
                        Image(systemName: "checkmark.circle")
                            .font(.title3)
                            .foregroundStyle(.green)
                        Text(WL.noUpcoming)
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                    Spacer()
                }
                Spacer()
            } else {
                ForEach(upcomingSubscriptions) { sub in
                    SubscriptionDetailRow(item: sub)
                }
                Spacer(minLength: 0)
            }
        }
        .padding(2)
    }
}

// MARK: - Pro Locked View

struct ProLockedView: View {
    let family: WidgetFamily

    var body: some View {
        ZStack {
            // Blurred placeholder
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image("SuboraIcon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 16, height: 16)
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                    Text(WL.subora)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                RoundedRectangle(cornerRadius: 4)
                    .fill(.quaternary)
                    .frame(height: 24)
                    .frame(maxWidth: 120)
                RoundedRectangle(cornerRadius: 3)
                    .fill(.quaternary)
                    .frame(height: 12)
                    .frame(maxWidth: 80)
                Spacer()
                if family != .systemSmall {
                    ForEach(0..<3, id: \.self) { _ in
                        RoundedRectangle(cornerRadius: 3)
                            .fill(.quaternary)
                            .frame(height: 16)
                    }
                }
            }
            .padding(2)
            .blur(radius: 2)

            // Upgrade overlay
            VStack(spacing: 6) {
                Image(systemName: "lock.fill")
                    .font(.title3)
                    .foregroundStyle(.orange)
                Text(WL.upgradeToPro)
                    .font(.caption)
                    .fontWeight(.semibold)
                Text(WL.unlockWidgets)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

// MARK: - Subscription Row (compact, for Medium)

struct SubscriptionRow: View {
    let item: WidgetSubscriptionItem

    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(colorFromHex(item.categoryColorHex))
                .frame(width: 6, height: 6)

            Text(item.name)
                .font(.caption2)
                .fontWeight(.medium)
                .lineLimit(1)

            Spacer()

            Text(daysText(item.daysUntilNextBilling))
                .font(.caption2)
                .foregroundStyle(urgencyColor(item.daysUntilNextBilling))
        }
    }
}

// MARK: - Subscription Detail Row (for Large)

struct SubscriptionDetailRow: View {
    let item: WidgetSubscriptionItem

    var body: some View {
        HStack(spacing: 8) {
            // Category color indicator
            RoundedRectangle(cornerRadius: 2)
                .fill(colorFromHex(item.categoryColorHex))
                .frame(width: 3, height: 28)

            // Name and cycle
            VStack(alignment: .leading, spacing: 1) {
                Text(item.name)
                    .font(.caption)
                    .fontWeight(.medium)
                    .lineLimit(1)
                Text(WidgetCurrencyFormatter.format(amount: item.amount, currency: item.currency) + item.cycleShortText)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            // Days until renewal
            VStack(alignment: .trailing, spacing: 1) {
                Text(daysText(item.daysUntilNextBilling))
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundStyle(urgencyColor(item.daysUntilNextBilling))
                Text(item.nextBillingDate, style: .date)
                    .font(.system(size: 9))
                    .foregroundStyle(.tertiary)
            }
        }
    }
}

// MARK: - Color Scheme Modifier

struct WidgetColorSchemeModifier: ViewModifier {
    let darkMode: Bool?

    func body(content: Content) -> some View {
        if let darkMode {
            content.environment(\.colorScheme, darkMode ? .dark : .light)
        } else {
            content // follow system
        }
    }
}

// MARK: - Empty State View

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "plus.circle")
                .font(.title2)
                .foregroundStyle(.secondary)
            Text(WL.emptyTitle)
                .font(.caption)
                .fontWeight(.semibold)
            Text(WL.emptySubtitle)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Helpers

private func colorFromHex(_ hex: String?) -> Color {
    guard let hex = hex, hex.count >= 7 else { return .blue }

    let cleanHex = hex.hasPrefix("#") ? String(hex.dropFirst()) : hex
    guard cleanHex.count == 6,
          let rgb = UInt64(cleanHex, radix: 16) else { return .blue }

    let r = Double((rgb >> 16) & 0xFF) / 255.0
    let g = Double((rgb >> 8) & 0xFF) / 255.0
    let b = Double(rgb & 0xFF) / 255.0

    return Color(red: r, green: g, blue: b)
}

private func daysText(_ days: Int) -> String {
    switch days {
    case 0:
        return WL.today
    case 1:
        return WL.tomorrow
    default:
        return WL.inDays(days)
    }
}

private func urgencyColor(_ days: Int) -> Color {
    switch days {
    case 0...1:
        return .red
    case 2...3:
        return .orange
    default:
        return .secondary
    }
}
