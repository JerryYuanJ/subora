//
//  AppDelegate.swift
//  subscription-tracker
//
//  Created by Kiro on 2026/2/25.
//

import UIKit
import UserNotifications
import PostHog

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    private var currentLanguage: String?
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        // Initialize PostHog
        setupPostHog()
        
        // Set notification center delegate
        UNUserNotificationCenter.current().delegate = self
        
        // Clear badge count on app launch
        clearBadgeCount()
        
        // Store current language
        currentLanguage = Locale.current.language.languageCode?.identifier
        
        // Listen for app becoming active to detect language changes
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(applicationDidBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
        
        return true
    }
    
    // MARK: - PostHog Setup
    
    private func setupPostHog() {
        let POSTHOG_API_KEY = "phc_TcI9ELRnksM2AIxym0bidO8o9Lz0cR1e2QAr3GpN3G"
        let POSTHOG_HOST = "https://us.i.posthog.com"
        
        let config = PostHogConfig(apiKey: POSTHOG_API_KEY, host: POSTHOG_HOST)
        PostHogSDK.shared.setup(config)
        
        print("✅ PostHog initialized successfully")
    }
    
    @objc private func applicationDidBecomeActive() {
        // Clear badge count when app becomes active
        clearBadgeCount()
        
        // Check if language has changed
        let newLanguage = Locale.current.language.languageCode?.identifier
        if let current = currentLanguage, let new = newLanguage, current != new {
            // Language changed, show alert to restart app
            DispatchQueue.main.async {
                self.showLanguageChangeAlert()
            }
            currentLanguage = newLanguage
        }
    }
    
    /// Clear app badge count
    private func clearBadgeCount() {
        UNUserNotificationCenter.current().setBadgeCount(0) { _ in }
    }
    
    private func showLanguageChangeAlert() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let rootViewController = window.rootViewController else {
            return
        }
        
        let alert = UIAlertController(
            title: "语言已更改 / Language Changed",
            message: "请重启应用以应用新语言设置\nPlease restart the app to apply the new language",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "确定 / OK", style: .default))
        
        rootViewController.present(alert, animated: true)
    }
    
    // MARK: - UNUserNotificationCenterDelegate
    
    /// Handle notification when app is in foreground
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        // Show notification even when app is in foreground
        completionHandler([.banner, .sound, .badge])
    }
    
    /// Handle notification tap
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        
        // Extract subscription ID from notification
        if let subscriptionIdString = userInfo["subscriptionId"] as? String,
           let subscriptionId = UUID(uuidString: subscriptionIdString) {
            
            // Post notification to navigate to subscription detail
            NotificationCenter.default.post(
                name: NSNotification.Name("navigateToSubscription"),
                object: nil,
                userInfo: ["subscriptionId": subscriptionId]
            )
        }
        
        completionHandler()
    }
}
