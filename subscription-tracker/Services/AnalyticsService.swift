//
//  AnalyticsService.swift
//  subscription-tracker
//
//  PostHog analytics service wrapper
//

import Foundation
import PostHog

/// Analytics service for tracking user events
class AnalyticsService {
    
    static let shared = AnalyticsService()
    
    private init() {}
    
    // MARK: - User Properties
    
    /// Identify user with properties
    func identify(userId: String, properties: [String: Any] = [:]) {
        PostHogSDK.shared.identify(userId, userProperties: properties)
    }
    
    /// Set user properties
    func setUserProperties(_ properties: [String: Any]) {
        PostHogSDK.shared.identify(PostHogSDK.shared.getDistinctId(), userProperties: properties)
    }
    
    // MARK: - Event Tracking
    
    /// Track a custom event
    func track(_ event: String, properties: [String: Any] = [:]) {
        PostHogSDK.shared.capture(event, properties: properties)
    }
    
    // MARK: - Subscription Events
    
    func trackSubscriptionAdded(name: String, amount: Double, currency: String, billingCycle: String) {
        track("subscription_added", properties: [
            "subscription_name": name,
            "amount": amount,
            "currency": currency,
            "billing_cycle": billingCycle
        ])
    }
    
    func trackSubscriptionEdited(name: String) {
        track("subscription_edited", properties: [
            "subscription_name": name
        ])
    }
    
    func trackSubscriptionDeleted(name: String) {
        track("subscription_deleted", properties: [
            "subscription_name": name
        ])
    }
    
    func trackSubscriptionArchived(name: String) {
        track("subscription_archived", properties: [
            "subscription_name": name
        ])
    }
    
    func trackSubscriptionUnarchived(name: String) {
        track("subscription_unarchived", properties: [
            "subscription_name": name
        ])
    }
    
    // MARK: - Category Events
    
    func trackCategoryCreated(name: String) {
        track("category_created", properties: [
            "category_name": name
        ])
    }
    
    func trackCategoryDeleted(name: String) {
        track("category_deleted", properties: [
            "category_name": name
        ])
    }
    
    // MARK: - Navigation Events
    
    func trackScreenView(_ screenName: String) {
        track("screen_view", properties: [
            "screen_name": screenName
        ])
    }
    
    // MARK: - Feature Usage
    
    func trackNotificationEnabled(subscriptionName: String) {
        track("notification_enabled", properties: [
            "subscription_name": subscriptionName
        ])
    }
    
    func trackNotificationDisabled(subscriptionName: String) {
        track("notification_disabled", properties: [
            "subscription_name": subscriptionName
        ])
    }
    
    func trackWidgetAdded(size: String) {
        track("widget_added", properties: [
            "widget_size": size
        ])
    }
    
    func trackInsightCardToggled(cardType: String, visible: Bool) {
        track("insight_card_toggled", properties: [
            "card_type": cardType,
            "visible": visible
        ])
    }
    
    func trackFilterChanged(filterType: String) {
        track("filter_changed", properties: [
            "filter_type": filterType
        ])
    }
    
    func trackCurrencyChanged(currency: String) {
        track("currency_changed", properties: [
            "currency": currency
        ])
    }
    
    func trackThemeChanged(isDarkMode: Bool?) {
        let mode = isDarkMode == nil ? "system" : (isDarkMode! ? "dark" : "light")
        track("theme_changed", properties: [
            "theme_mode": mode
        ])
    }
    
    func trackLanguageChanged(language: String) {
        track("language_changed", properties: [
            "language": language
        ])
    }
    
    // MARK: - Paywall Events
    
    func trackPaywallViewed(source: String) {
        track("paywall_viewed", properties: [
            "source": source
        ])
    }
    
    func trackPurchaseStarted(productId: String) {
        track("purchase_started", properties: [
            "product_id": productId
        ])
    }
    
    func trackPurchaseCompleted(productId: String, price: Double, currency: String) {
        track("purchase_completed", properties: [
            "product_id": productId,
            "price": price,
            "currency": currency
        ])
    }
    
    func trackPurchaseFailed(productId: String, error: String) {
        track("purchase_failed", properties: [
            "product_id": productId,
            "error": error
        ])
    }
    
    func trackPurchaseRestored() {
        track("purchase_restored")
    }
    
    // MARK: - iCloud Sync Events
    
    func trackSyncEnabled() {
        track("icloud_sync_enabled")
    }
    
    func trackSyncDisabled() {
        track("icloud_sync_disabled")
    }
    
    func trackSyncCompleted(itemCount: Int) {
        track("icloud_sync_completed", properties: [
            "item_count": itemCount
        ])
    }
    
    func trackSyncFailed(error: String) {
        track("icloud_sync_failed", properties: [
            "error": error
        ])
    }
    
    // MARK: - Error Tracking
    
    func trackError(error: String, context: String) {
        track("error_occurred", properties: [
            "error": error,
            "context": context
        ])
    }
}
