//
//  WidgetSharedData.swift
//  SuboraWidget
//
//  Shared data models for widget communication.
//  This file MUST be kept in sync with subscription-tracker/Shared/WidgetSharedData.swift
//  Both files share the same source — add this to the widget target in Xcode.
//

import Foundation
import WidgetKit

// MARK: - Constants

let appGroupID = "group.com.subora.app"
let widgetDataKey = "widgetData"
let widgetProStatusKey = "widgetIsProUser"

// MARK: - Shared Data Models

/// Lightweight subscription item for widget display
struct WidgetSubscriptionItem: Codable, Identifiable {
    let id: UUID
    let name: String
    let amount: Decimal
    let currency: String
    let nextBillingDate: Date
    let billingCycle: Int
    let billingCycleUnitRaw: String
    let categoryName: String?
    let categoryColorHex: String?
    let iconURL: String?

    var billingCycleUnit: String {
        billingCycleUnitRaw
    }

    /// Days until next billing
    var daysUntilNextBilling: Int {
        let calendar = Calendar.current
        let now = calendar.startOfDay(for: Date())
        let billing = calendar.startOfDay(for: nextBillingDate)
        return calendar.dateComponents([.day], from: now, to: billing).day ?? 0
    }

    /// Formatted billing cycle text (e.g. "/mo", "/yr")
    var cycleShortText: String {
        switch billingCycleUnitRaw {
        case "day":
            return billingCycle == 1 ? "/day" : "/\(billingCycle)d"
        case "week":
            return billingCycle == 1 ? "/wk" : "/\(billingCycle)wk"
        case "month":
            return billingCycle == 1 ? "/mo" : "/\(billingCycle)mo"
        case "year":
            return billingCycle == 1 ? "/yr" : "/\(billingCycle)yr"
        default:
            return ""
        }
    }

    /// Monthly equivalent amount
    var monthlyEquivalent: Decimal {
        let cycleDecimal = Decimal(billingCycle)
        switch billingCycleUnitRaw {
        case "day":
            return amount / cycleDecimal * Decimal(30.44)
        case "week":
            return amount / cycleDecimal * Decimal(4.33)
        case "month":
            return amount / cycleDecimal
        case "year":
            return amount / (cycleDecimal * 12)
        default:
            return amount
        }
    }
}

/// All data the widget needs
struct WidgetData: Codable {
    let subscriptions: [WidgetSubscriptionItem]
    let monthlyTotalsByCurrency: [String: Decimal]
    let isProUser: Bool
    let themeColorHex: String
    /// nil = follow system, true = dark, false = light
    let darkMode: Bool?
    let lastUpdated: Date

    static var empty: WidgetData {
        WidgetData(
            subscriptions: [],
            monthlyTotalsByCurrency: [:],
            isProUser: false,
            themeColorHex: "#007AFF",
            darkMode: nil,
            lastUpdated: Date()
        )
    }
}

// MARK: - Shared UserDefaults Access

struct WidgetDataStore {

    static var sharedDefaults: UserDefaults? {
        UserDefaults(suiteName: appGroupID)
    }

    /// Save widget data to shared UserDefaults
    static func save(_ data: WidgetData) {
        guard let defaults = sharedDefaults else { return }
        if let encoded = try? JSONEncoder().encode(data) {
            defaults.set(encoded, forKey: widgetDataKey)
        }
    }

    /// Load widget data from shared UserDefaults
    static func load() -> WidgetData {
        guard let defaults = sharedDefaults,
              let data = defaults.data(forKey: widgetDataKey),
              let widgetData = try? JSONDecoder().decode(WidgetData.self, from: data) else {
            return .empty
        }
        return widgetData
    }

    /// Save Pro status to shared UserDefaults
    static func saveProStatus(_ isPro: Bool) {
        sharedDefaults?.set(isPro, forKey: widgetProStatusKey)
    }

    /// Load Pro status from shared UserDefaults
    static func loadProStatus() -> Bool {
        sharedDefaults?.bool(forKey: widgetProStatusKey) ?? false
    }
}

// MARK: - Currency Formatting (simplified for widget)

struct WidgetCurrencyFormatter {

    static func format(amount: Decimal, currency: String) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currency
        formatter.locale = localeForCurrency(currency)
        let nsDecimalNumber = NSDecimalNumber(decimal: amount)
        return formatter.string(from: nsDecimalNumber) ?? "\(symbol(for: currency))\(amount)"
    }

    static func symbol(for currency: String) -> String {
        let locale = localeForCurrency(currency)
        return locale.currencySymbol ?? currency
    }

    private static func localeForCurrency(_ currency: String) -> Locale {
        switch currency {
        case "USD": return Locale(identifier: "en_US")
        case "CNY": return Locale(identifier: "zh_CN")
        case "EUR": return Locale(identifier: "de_DE")
        case "GBP": return Locale(identifier: "en_GB")
        case "JPY": return Locale(identifier: "ja_JP")
        case "HKD": return Locale(identifier: "zh_HK")
        case "TWD": return Locale(identifier: "zh_TW")
        default: return Locale.current
        }
    }
}
