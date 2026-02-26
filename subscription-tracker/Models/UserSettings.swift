//
//  UserSettings.swift
//  subscription-tracker
//
//  Created by Kiro on 2026/2/24.
//

import Foundation
import SwiftData

@Model
final class UserSettings {
    var id: UUID = UUID()
    var darkMode: Bool?
    var themeColor: String = "#007AFF"
    var defaultCurrency: String = "USD"
    var defaultNotifyTime: Date = Calendar.current.date(from: DateComponents(hour: 9, minute: 0)) ?? Date()
    var iCloudSync: Bool = false
    var isProUser: Bool = false
    var language: String?
    var updatedAt: Date = Date()
    var lastSyncTime: Date?  // 最后同步时间
    
    init(
        id: UUID = UUID(),
        darkMode: Bool? = nil,
        themeColor: String = "#007AFF",
        defaultCurrency: String = "USD",
        defaultNotifyTime: Date = Calendar.current.date(from: DateComponents(hour: 9, minute: 0)) ?? Date(),
        iCloudSync: Bool = false,
        isProUser: Bool = false,
        language: String? = nil
    ) {
        self.id = id
        self.darkMode = darkMode
        self.themeColor = themeColor
        self.defaultCurrency = defaultCurrency
        self.defaultNotifyTime = defaultNotifyTime
        self.iCloudSync = iCloudSync
        self.isProUser = isProUser
        self.language = language
        self.updatedAt = Date()
        self.lastSyncTime = nil
    }
}
