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
    
    // 创建不使用 CloudKit 的 ModelContainer
    let sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Subscription.self,
            Category.self,
            UserSettings.self,
        ])
        
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            cloudKitDatabase: .none  // 禁用 CloudKit
        )

        do {
            let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
            print("✅ SwiftData ModelContainer initialized successfully (CloudKit disabled)")
            return container
        } catch {
            fatalError("❌ Could not create ModelContainer: \(error)")
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
                    Task {
                        await notificationManager.requestPermissionIfNeeded()
                    }
                }
        }
        .modelContainer(sharedModelContainer)
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
