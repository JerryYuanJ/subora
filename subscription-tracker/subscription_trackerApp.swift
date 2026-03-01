//
//  subscription_trackerApp.swift
//  subscription-tracker
//
//  Created by Jerry　 on 2026/2/24.
//

import SwiftUI
import SwiftData
import Combine

@main
struct subscription_trackerApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var appSettings = AppSettings()
    @StateObject private var notificationManager = NotificationManager()
    
    // 创建支持 CloudKit 的 ModelContainer
    let sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Subscription.self,
            Category.self,
            UserSettings.self,
        ])
        
        // 使用 automatic 让 Xcode 自动管理 CloudKit 容器
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            cloudKitDatabase: .automatic
        )

        do {
            let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
            print("✅ SwiftData ModelContainer initialized (CloudKit: automatic)")
            print("💡 Xcode 会自动管理 CloudKit 容器")
            return container
        } catch {
            print("❌ ModelContainer error: \(error)")
            // 如果 CloudKit 初始化失败，使用本地存储
            let localConfig = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: false,
                cloudKitDatabase: .none
            )
            do {
                let localContainer = try ModelContainer(for: schema, configurations: [localConfig])
                print("⚠️ Fallback to local storage (CloudKit unavailable)")
                return localContainer
            } catch {
                fatalError("❌ Could not create ModelContainer: \(error)")
            }
        }
    }()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(PaywallService.shared)
                .environmentObject(appSettings)
                .environmentObject(notificationManager)
                .preferredColorScheme(appSettings.colorScheme)
                .onAppear {
                    seedDefaultCategoriesIfNeeded()
                    Task {
                        await notificationManager.requestPermissionIfNeeded()
                        // Clear badge count when app appears
                        await clearBadgeCount()
                    }
                }
        }
        .modelContainer(sharedModelContainer)
    }
    
    /// Seed default categories on first launch
    private func seedDefaultCategoriesIfNeeded() {
        let context = sharedModelContainer.mainContext
        let descriptor = FetchDescriptor<Category>()
        let existingCount = (try? context.fetchCount(descriptor)) ?? 0

        guard existingCount == 0 else { return }

        let defaults: [(name: String, color: String)] = [
            ("娱乐", "#FF2D55"),
            ("教育", "#5856D6"),
            ("工具", "#007AFF"),
            ("AI Tool", "#AF52DE"),
        ]

        for item in defaults {
            let category = Category(name: item.name, colorHex: item.color)
            context.insert(category)
        }
        try? context.save()
    }

    /// Clear app badge count
    private func clearBadgeCount() async {
        do {
            try await UNUserNotificationCenter.current().setBadgeCount(0)
            print("✅ Badge count cleared")
        } catch {
            print("❌ Failed to clear badge count: \(error)")
        }
    }
}

// MARK: - App Settings

class AppSettings: ObservableObject {
    @Published var colorScheme: ColorScheme? = nil
    
    init() {
        loadColorScheme()
    }
    
    func loadColorScheme() {
        if let darkMode = UserDefaults.standard.value(forKey: "darkMode") as? Bool {
            colorScheme = darkMode ? .dark : .light
        } else {
            colorScheme = nil // Follow system
        }
    }
    
    func updateColorScheme(_ darkMode: Bool?) {
        if let darkMode = darkMode {
            UserDefaults.standard.set(darkMode, forKey: "darkMode")
            colorScheme = darkMode ? .dark : .light
        } else {
            UserDefaults.standard.removeObject(forKey: "darkMode")
            colorScheme = nil
        }
    }
}


// MARK: - Notification Manager

@MainActor
class NotificationManager: ObservableObject {
    @Published var authorizationStatus: UNAuthorizationStatus = .notDetermined
    
    private let notificationService = NotificationService.shared
    
    init() {
        Task {
            await checkAuthorizationStatus()
        }
    }
    
    func checkAuthorizationStatus() async {
        authorizationStatus = await notificationService.checkAuthorizationStatus()
    }
    
    func requestPermissionIfNeeded() async {
        let status = await notificationService.checkAuthorizationStatus()
        authorizationStatus = status
        
        // Only request if not determined yet
        if status == .notDetermined {
            let granted = await notificationService.requestAuthorization()
            if granted {
                authorizationStatus = .authorized
            } else {
                authorizationStatus = .denied
            }
        }
    }
    
    func requestPermission() async -> Bool {
        let granted = await notificationService.requestAuthorization()
        await checkAuthorizationStatus()
        return granted
    }
    
    func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
}
