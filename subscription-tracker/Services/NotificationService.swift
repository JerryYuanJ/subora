//
//  NotificationService.swift
//  subscription-tracker
//
//  Created by Kiro on 2026/2/24.
//

import Foundation
import UserNotifications
import OSLog

/// Service for managing local notifications for subscription reminders
/// Handles notification permissions, scheduling, updating, and cancellation
class NotificationService {
    
    // MARK: - Singleton
    
    static let shared = NotificationService()
    
    private let notificationCenter = UNUserNotificationCenter.current()
    
    private init() {}
    
    // MARK: - Authorization
    
    /// Request notification authorization from the user
    /// - Returns: True if authorization was granted, false otherwise
    func requestAuthorization() async -> Bool {
        Logger.notification.info("Requesting notification authorization")
        do {
            let granted = try await notificationCenter.requestAuthorization(
                options: [.alert, .sound, .badge]
            )
            if granted {
                Logger.notification.info("Notification authorization granted")
            } else {
                Logger.notification.warning("Notification authorization denied by user")
            }
            return granted
        } catch {
            Logger.notification.error("Error requesting notification authorization: \(error.localizedDescription)")
            return false
        }
    }
    
    /// Check the current notification authorization status
    /// - Returns: The current authorization status
    func checkAuthorizationStatus() async -> UNAuthorizationStatus {
        let settings = await notificationCenter.notificationSettings()
        return settings.authorizationStatus
    }
    
    // MARK: - Scheduling
    
    /// Schedule a notification for a subscription
    /// - Parameters:
    ///   - subscription: The subscription to schedule notification for
    ///   - notifyTime: The time of day to send the notification (defaults to 9:00 AM)
    /// - Throws: Error if scheduling fails
    func scheduleNotification(
        for subscription: Subscription,
        notifyTime: Date = Calendar.current.date(from: DateComponents(hour: 9, minute: 0)) ?? Date()
    ) async throws {
        // Only schedule if notifications are enabled for this subscription
        guard subscription.notify else { return }
        
        Logger.notification.info("Scheduling notification for subscription: \(subscription.id)")
        
        // Check authorization status
        let status = await checkAuthorizationStatus()
        guard status == .authorized else {
            Logger.notification.warning("Cannot schedule notification: authorization not granted")
            throw NotificationError.authorizationDenied
        }
        
        // Calculate notification date
        let nextBillingDate = subscription.nextBillingDate
        let notificationDate = Calendar.current.date(
            byAdding: .day,
            value: -subscription.notifyDaysBefore,
            to: nextBillingDate
        ) ?? nextBillingDate
        
        // Extract time components from notifyTime
        let timeComponents = Calendar.current.dateComponents([.hour, .minute], from: notifyTime)
        
        // Combine notification date with notify time
        var dateComponents = Calendar.current.dateComponents(
            [.year, .month, .day],
            from: notificationDate
        )
        dateComponents.hour = timeComponents.hour
        dateComponents.minute = timeComponents.minute
        
        // Create notification content
        let content = UNMutableNotificationContent()
        content.title = "订阅即将续费"
        content.body = "\(subscription.name) 将在 \(subscription.notifyDaysBefore) 天后续费，金额为 \(formatAmount(subscription.amount, currency: subscription.currency))"
        content.sound = .default
        content.badge = 1
        
        // Add subscription ID to userInfo for handling notification taps
        content.userInfo = [
            "subscriptionId": subscription.id.uuidString,
            "subscriptionName": subscription.name
        ]
        
        // Create trigger
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: dateComponents,
            repeats: false
        )
        
        // Create request with subscription ID as identifier
        let request = UNNotificationRequest(
            identifier: subscription.id.uuidString,
            content: content,
            trigger: trigger
        )
        
        // Schedule notification
        try await notificationCenter.add(request)
        Logger.notification.info("Successfully scheduled notification for subscription: \(subscription.id)")
    }
    
    /// Update notification for a subscription
    /// This cancels the existing notification and schedules a new one
    /// - Parameters:
    ///   - subscription: The subscription to update notification for
    ///   - notifyTime: The time of day to send the notification
    /// - Throws: Error if updating fails
    func updateNotification(
        for subscription: Subscription,
        notifyTime: Date = Calendar.current.date(from: DateComponents(hour: 9, minute: 0)) ?? Date()
    ) async throws {
        // Cancel existing notification
        await cancelNotifications(for: subscription)
        
        // Schedule new notification if enabled
        if subscription.notify {
            try await scheduleNotification(for: subscription, notifyTime: notifyTime)
        }
    }
    
    // MARK: - Cancellation
    
    /// Cancel all notifications for a specific subscription
    /// - Parameter subscription: The subscription to cancel notifications for
    func cancelNotifications(for subscription: Subscription) async {
        Logger.notification.info("Cancelling notifications for subscription: \(subscription.id)")
        notificationCenter.removePendingNotificationRequests(
            withIdentifiers: [subscription.id.uuidString]
        )
    }
    
    /// Cancel all pending notifications
    func cancelAllNotifications() async {
        notificationCenter.removeAllPendingNotificationRequests()
    }
    
    // MARK: - Helper Methods
    
    /// Format amount with currency symbol
    private func formatAmount(_ amount: Decimal, currency: String) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currency
        
        let nsDecimalNumber = NSDecimalNumber(decimal: amount)
        return formatter.string(from: nsDecimalNumber) ?? "\(amount) \(currency)"
    }
    
    /// Get all pending notification requests (for debugging/testing)
    func getPendingNotifications() async -> [UNNotificationRequest] {
        return await notificationCenter.pendingNotificationRequests()
    }
}

// MARK: - Error Types

enum NotificationError: LocalizedError {
    case authorizationDenied
    case schedulingFailed(String)
    
    var errorDescription: String? {
        switch self {
        case .authorizationDenied:
            return "通知权限未授予，请在设置中开启通知权限"
        case .schedulingFailed(let reason):
            return "通知调度失败: \(reason)"
        }
    }
}
