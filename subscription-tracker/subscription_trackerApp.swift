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
    
    @StateObject private var appSettings = AppSettings()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(PaywallService.shared)
                .environmentObject(appSettings)
                .preferredColorScheme(appSettings.colorScheme)
        }
        .modelContainer(for: [Subscription.self, Category.self, UserSettings.self]) { result in
            switch result {
            case .success(_):
                // 配置 CloudKit 同步（可选）
                // 注意：实际的 iCloud 同步开关由 UserSettings.iCloudSync 控制
                // SwiftData 会自动处理 CloudKit 集成
                print("SwiftData ModelContainer initialized successfully")
            case .failure(let error):
                print("Failed to initialize ModelContainer: \(error.localizedDescription)")
            }
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
