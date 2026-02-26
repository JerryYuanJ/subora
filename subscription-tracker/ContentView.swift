//
//  ContentView.swift
//  subscription-tracker
//
//  Created by Jerry　 on 2026/2/24.
//

import SwiftUI
import SwiftData
import UserNotifications

struct ContentView: View {
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Subscriptions Tab
            SubscriptionListView(modelContext: modelContext)
                .tabItem {
                    Label(L10n.Tab.subscriptions, systemImage: "list.bullet.rectangle")
                }
                .tag(0)
            
            // Insights Tab (formerly Dashboard)
            InsightsView(modelContext: modelContext)
                .tabItem {
                    Label(L10n.Tab.insights, systemImage: "chart.bar.fill")
                }
                .tag(1)
            
            // Categories Tab
            CategoryManagementView(modelContext: modelContext)
                .tabItem {
                    Label(L10n.Tab.categories, systemImage: "folder.fill")
                }
                .tag(2)
            
            // Settings Tab
            SettingsView(modelContext: modelContext)
                .tabItem {
                    Label(L10n.Tab.settings, systemImage: "gearshape.fill")
                }
                .tag(3)
        }
        .onChange(of: scenePhase) { oldPhase, newPhase in
            if newPhase == .active {
                // Clear badge when app becomes active
                Task {
                    await clearBadgeCount()
                }
            }
        }
    }
    
    /// Clear app badge count
    private func clearBadgeCount() async {
        do {
            try await UNUserNotificationCenter.current().setBadgeCount(0)
        } catch {
            print("❌ Failed to clear badge: \(error)")
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Subscription.self, Category.self, UserSettings.self, configurations: config)
    
    return ContentView()
        .modelContainer(container)
        .environmentObject(PaywallService.shared)
        .environmentObject(AppSettings())
}
