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
                // 如果存在多条记录，清理多余的
                if settings.count > 1 {
                    for extra in settings.dropFirst() {
                        modelContext.delete(extra)
                    }
                    try? modelContext.save()
                    Logger.app.warning("Cleaned up \(settings.count - 1) duplicate UserSettings")
                }
                userSettings = existingSettings
                Logger.app.info("User settings loaded successfully")
            } else {
                // 创建前再次检查（防止并发创建）
                let count = try modelContext.fetchCount(descriptor)
                guard count == 0 else {
                    userSettings = try modelContext.fetch(descriptor).first
                    return
                }
                let newSettings = UserSettings()
                modelContext.insert(newSettings)
                try modelContext.save()
                userSettings = newSettings
                Logger.app.info("Created default user settings")
            }
        } catch {
            errorMessage = L10n.VMError.loadSettingsFailed
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
            // Refresh widget to apply dark mode
            let service = SubscriptionService(modelContext: modelContext)
            service.refreshWidgetData()
            Logger.app.info("Dark mode updated to: \(String(describing: darkMode))")
        } catch {
            errorMessage = L10n.VMError.updateDarkModeFailed
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
            // Refresh widget to apply new theme color
            let service = SubscriptionService(modelContext: modelContext)
            service.refreshWidgetData()
            Logger.app.info("Theme color updated to: \(colorHex)")
        } catch {
            errorMessage = L10n.VMError.updateThemeColorFailed
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
            errorMessage = L10n.VMError.updateCurrencyFailed
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
            errorMessage = L10n.VMError.updateNotifyTimeFailed
            Logger.app.error("Failed to update default notify time: \(error.localizedDescription)")
            throw AppError.dataSaveFailed(reason: error.localizedDescription)
        }
    }
    
    /// Update show private subscriptions setting
    func updateShowPrivateSubscriptions(_ show: Bool) async throws {
        guard let settings = userSettings else {
            throw AppError.dataNotFound
        }

        do {
            settings.showPrivateSubscriptions = show
            settings.updatedAt = Date()
            try modelContext.save()
            Logger.app.info("Show private subscriptions updated to: \(show)")
        } catch {
            Logger.app.error("Failed to update show private subscriptions: \(error.localizedDescription)")
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
            errorMessage = L10n.VMError.toggleSyncFailed
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
            errorMessage = L10n.VMError.saveSettingsFailed
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
    
    /// Manually trigger sync
    func manualSync() async throws {
        isLoading = true
        defer { isLoading = false }
        
        do {
            try await syncService.syncNow()
            Logger.app.info("Manual sync completed successfully")
        } catch let error as AppError {
            errorMessage = error.errorDescription
            Logger.app.error("Manual sync failed: \(error.localizedDescription)")
            throw error
        } catch {
            errorMessage = L10n.VMError.manualSyncFailed
            Logger.app.error("Manual sync failed: \(error.localizedDescription)")
            throw AppError.syncFailed(reason: error.localizedDescription)
        }
    }
}
