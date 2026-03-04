//
//  SuboraWidget.swift
//  SuboraWidget
//
//  Widget entry, timeline provider, and configuration.
//

import WidgetKit
import SwiftUI

// MARK: - Timeline Entry

struct SuboraWidgetEntry: TimelineEntry {
    let date: Date
    let data: WidgetData

    static var placeholder: SuboraWidgetEntry {
        SuboraWidgetEntry(
            date: Date(),
            data: WidgetData(
                subscriptions: [
                    WidgetSubscriptionItem(
                        id: UUID(),
                        name: "Netflix",
                        amount: 15.99,
                        currency: "USD",
                        nextBillingDate: Calendar.current.date(byAdding: .day, value: 3, to: Date())!,
                        billingCycle: 1,
                        billingCycleUnitRaw: "month",
                        categoryName: String(localized: "widget.category_entertainment"),
                        categoryColorHex: "#FF2D55",
                        iconURL: nil
                    ),
                    WidgetSubscriptionItem(
                        id: UUID(),
                        name: "Spotify",
                        amount: 9.99,
                        currency: "USD",
                        nextBillingDate: Calendar.current.date(byAdding: .day, value: 7, to: Date())!,
                        billingCycle: 1,
                        billingCycleUnitRaw: "month",
                        categoryName: String(localized: "widget.category_entertainment"),
                        categoryColorHex: "#FF2D55",
                        iconURL: nil
                    ),
                    WidgetSubscriptionItem(
                        id: UUID(),
                        name: "iCloud+",
                        amount: 2.99,
                        currency: "USD",
                        nextBillingDate: Calendar.current.date(byAdding: .day, value: 12, to: Date())!,
                        billingCycle: 1,
                        billingCycleUnitRaw: "month",
                        categoryName: String(localized: "widget.category_tools"),
                        categoryColorHex: "#007AFF",
                        iconURL: nil
                    ),
                    WidgetSubscriptionItem(
                        id: UUID(),
                        name: "ChatGPT Plus",
                        amount: 20.00,
                        currency: "USD",
                        nextBillingDate: Calendar.current.date(byAdding: .day, value: 15, to: Date())!,
                        billingCycle: 1,
                        billingCycleUnitRaw: "month",
                        categoryName: String(localized: "widget.category_ai_tool"),
                        categoryColorHex: "#AF52DE",
                        iconURL: nil
                    ),
                    WidgetSubscriptionItem(
                        id: UUID(),
                        name: "YouTube Premium",
                        amount: 13.99,
                        currency: "USD",
                        nextBillingDate: Calendar.current.date(byAdding: .day, value: 20, to: Date())!,
                        billingCycle: 1,
                        billingCycleUnitRaw: "month",
                        categoryName: String(localized: "widget.category_entertainment"),
                        categoryColorHex: "#FF2D55",
                        iconURL: nil
                    ),
                    WidgetSubscriptionItem(
                        id: UUID(),
                        name: "Claude Pro",
                        amount: 20.00,
                        currency: "USD",
                        nextBillingDate: Calendar.current.date(byAdding: .day, value: 25, to: Date())!,
                        billingCycle: 1,
                        billingCycleUnitRaw: "month",
                        categoryName: String(localized: "widget.category_ai_tool"),
                        categoryColorHex: "#AF52DE",
                        iconURL: nil
                    ),
                ],
                monthlyTotalsByCurrency: ["USD": 82.96],
                isProUser: true,
                themeColorHex: "#007AFF",
                darkMode: nil,
                lastUpdated: Date()
            )
        )
    }
}

// MARK: - Timeline Provider

struct SuboraWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> SuboraWidgetEntry {
        .placeholder
    }

    func getSnapshot(in context: Context, completion: @escaping (SuboraWidgetEntry) -> Void) {
        if context.isPreview {
            completion(.placeholder)
        } else {
            let data = WidgetDataStore.load()
            completion(SuboraWidgetEntry(date: Date(), data: data))
        }
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SuboraWidgetEntry>) -> Void) {
        let data = WidgetDataStore.load()
        let entry = SuboraWidgetEntry(date: Date(), data: data)

        // Refresh every 2 hours
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 2, to: Date())!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
}

// MARK: - Widget Configuration

struct SuboraWidget: Widget {
    let kind: String = "SuboraWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: SuboraWidgetProvider()) { entry in
            if #available(iOS 17.0, *) {
                SuboraWidgetEntryView(entry: entry)
                    .modifier(WidgetColorSchemeModifier(darkMode: entry.data.darkMode))
                    .containerBackground(for: .widget) {
                        if let darkMode = entry.data.darkMode {
                            Color(darkMode ? .systemBackground : .systemBackground)
                                .environment(\.colorScheme, darkMode ? .dark : .light)
                        } else {
                            Color(.systemBackground)
                        }
                    }
            } else {
                SuboraWidgetEntryView(entry: entry)
                    .modifier(WidgetColorSchemeModifier(darkMode: entry.data.darkMode))
                    .padding()
                    .background(Color(.systemBackground))
            }
        }
        .configurationDisplayName("Subora")
        .description("Track your subscriptions and upcoming renewals.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

// MARK: - Previews

#Preview(as: .systemSmall) {
    SuboraWidget()
} timeline: {
    SuboraWidgetEntry.placeholder
}

#Preview(as: .systemMedium) {
    SuboraWidget()
} timeline: {
    SuboraWidgetEntry.placeholder
}

#Preview(as: .systemLarge) {
    SuboraWidget()
} timeline: {
    SuboraWidgetEntry.placeholder
}
