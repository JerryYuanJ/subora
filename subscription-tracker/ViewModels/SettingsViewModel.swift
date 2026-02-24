//
//  SettingsViewModel.swift
//  subscription-tracker
//
//  Created by Kiro on 2026/2/24.
//

import Foundation
import SwiftUI
import SwiftData
import OSLog
import Combine

/// ViewModel for Settings view, managing user settings and preferences
@MainActor
class SettingsViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    /// Current user settings
    @Published var userSettings: UserSettings?
    
    /// Loading state indicator
    @Published var isLoading = false
    
    /// Error message for display
    @Published var errorMessage: String?
    
    // MARK: - Dependencies
    
    private let modelContext: ModelContext
    private let syncService: SyncService
    
    // MARK: - Initialization
    
    init(modelContext: ModelContext, syncService: SyncService) {
        self.modelContext = modelContext
        self.syncService = syncService
    }
    
    // MARK: - Data Loading
    
    /// Load user settings from database
    func loadSettings() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let descriptor = FetchDescriptor<UserSettings>()
            let settings = try modelContext.fetch(descriptor)
            
            if let existingSettings = settings.first {
                userSettings = existingSettings
                Logger.app.info("User settings loaded successfully")
            } else {
                // Create default settings if none exist
                let newSettings = UserSettings()
                modelContext.insert(newSettings)
                try modelContext.save()
                userSettings = newSettings
                Logger.app.info("Created default user settings")
            }
        } catch {
            errorMessage = "加载设置失败"
            Logger.app.error("Failed to load settings: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Settings Update Methods
    
    /// Update dark mode setting
    /// - Parameter darkMode: Dark mode preference (nil = follow system, true = dark, false = light)
    func updateDarkMode(_ darkMode: Bool?) async throws {
        guard let settings = userSettings else {
            throw AppError.dataNotFound
        }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            settings.darkMode = darkMode
            settings.updatedAt = Date()
            try modelContext.save()
            Logger.app.info("Dark mode updated to: \(String(describing: darkMode))")
        } catch {
            errorMessage = "更新深色模式失败"
            Logger.app.error("Failed to update dark mode: \(error.localizedDescription)")
            throw AppError.dataSaveFailed(reason: error.localizedDescription)
        }
    }
    
    /// Update theme color
    /// - Parameter colorHex: Theme color in hex format (e.g., "#007AFF")
    func updateThemeColor(_ colorHex: String) async throws {
        guard let settings = userSettings else {
            throw AppError.dataNotFound
        }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            settings.themeColor = colorHex
            settings.updatedAt = Date()
            try modelContext.save()
            Logger.app.info("Theme color updated to: \(colorHex)")
        } catch {
            errorMessage = "更新主题颜色失败"
            Logger.app.error("Failed to update theme color: \(error.localizedDescription)")
            throw AppError.dataSaveFailed(reason: error.localizedDescription)
        }
    }
    
    /// Update default currency
    /// - Parameter currency: Currency code (e.g., "USD", "CNY")
    func updateDefaultCurrency(_ currency: String) async throws {
        guard let settings = userSettings else {
            throw AppError.dataNotFound
        }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            settings.defaultCurrency = currency
            settings.updatedAt = Date()
            try modelContext.save()
            Logger.app.info("Default currency updated to: \(currency)")
        } catch {
            errorMessage = "更新默认货币失败"
            Logger.app.error("Failed to update default currency: \(error.localizedDescription)")
            throw AppError.dataSaveFailed(reason: error.localizedDescription)
        }
    }
    
    /// Update default notification time
    /// - Parameter time: Notification time (only hour and minute are used)
    func updateDefaultNotifyTime(_ time: Date) async throws {
        guard let settings = userSettings else {
            throw AppError.dataNotFound
        }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            settings.defaultNotifyTime = time
            settings.updatedAt = Date()
            try modelContext.save()
            Logger.app.info("Default notify time updated")
        } catch {
            errorMessage = "更新默认通知时间失败"
            Logger.app.error("Failed to update default notify time: \(error.localizedDescription)")
            throw AppError.dataSaveFailed(reason: error.localizedDescription)
        }
    }
    
    /// Toggle iCloud sync on/off
    /// - Parameter enabled: Whether to enable iCloud sync
    func toggleiCloudSync(_ enabled: Bool) async throws {
        guard let settings = userSettings else {
            throw AppError.dataNotFound
        }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            if enabled {
                try await syncService.enableSync()
            } else {
                try await syncService.disableSync()
            }
            
            // Update local settings object
            settings.iCloudSync = enabled
            settings.updatedAt = Date()
            
            Logger.app.info("iCloud sync toggled to: \(enabled)")
        } catch let error as AppError {
            errorMessage = error.errorDescription
            Logger.app.error("Failed to toggle iCloud sync: \(error.localizedDescription)")
            throw error
        } catch {
            errorMessage = "切换 iCloud 同步失败"
            Logger.app.error("Failed to toggle iCloud sync: \(error.localizedDescription)")
            throw AppError.syncFailed(reason: error.localizedDescription)
        }
    }
    
    /// Save all settings at once
    func saveSettings() async throws {
        guard userSettings != nil else {
            throw AppError.dataNotFound
        }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            userSettings?.updatedAt = Date()
            try modelContext.save()
            Logger.app.info("Settings saved successfully")
        } catch {
            errorMessage = "保存设置失败"
            Logger.app.error("Failed to save settings: \(error.localizedDescription)")
            throw AppError.dataSaveFailed(reason: error.localizedDescription)
        }
    }
    
    // MARK: - Helper Methods
    
    /// Clear error message
    func clearError() {
        errorMessage = nil
    }
    
    /// Get current sync status
    func getSyncStatus() -> SyncStatus {
        return syncService.getSyncStatus()
    }
}
