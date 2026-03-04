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
    
    static var appName: String {
        Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String ??
        Bundle.main.infoDictionary?["CFBundleName"] as? String ?? "Subora"
    }
}

// MARK: - App Icon Helper

import UIKit

extension AppConfig {
    /// 获取 App Icon 图片
    static var appIcon: UIImage? {
        // 方法1: 从 Assets 获取
        if let image = UIImage(named: "AppIcon") {
            return image
        }
        
        // 方法2: 从 Bundle 获取
        guard let iconsDictionary = Bundle.main.infoDictionary?["CFBundleIcons"] as? [String: Any],
              let primaryIconsDictionary = iconsDictionary["CFBundlePrimaryIcon"] as? [String: Any],
              let iconFiles = primaryIconsDictionary["CFBundleIconFiles"] as? [String],
              let lastIcon = iconFiles.last else {
            return nil
        }
        
        return UIImage(named: lastIcon)
    }
}
