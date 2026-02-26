//
//  AppConfig.swift
//  subscription-tracker
//
//  App configuration constants
//

import Foundation

enum AppConfig {
    // MARK: - Contact
    static let supportEmail = "j24.yuan@gmail.com"
    
    // MARK: - App Store
    // 注意：发布前需要替换为实际的 App Store ID
    static let appStoreID = "123456789"
    static var appStoreURL: String {
        "https://apps.apple.com/app/id\(appStoreID)"
    }
    static var appStoreReviewURL: String {
        "https://apps.apple.com/app/id\(appStoreID)?action=write-review"
    }
    
    // MARK: - App Info
    static var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }
    
    static var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }
    
    static var fullVersion: String {
        "\(appVersion) (\(buildNumber))"
    }
}
