//
//  SubscriptionService.swift
//  subscription-tracker
//
//  Created by Kiro on 2026/2/24.
//

import Foundation
import SwiftData
import OSLog
import WidgetKit

/// Service for managing subscription business logic and data operations
@MainActor
class SubscriptionService {
    
    // MARK: - Properties
    
    private let modelContext: ModelContext
    private let paywallService: PaywallService
    private let notificationService: NotificationService
    
    // MARK: - Initialization
    
    init(
        modelContext: ModelContext,
        paywallService: PaywallService? = nil,
        notificationService: NotificationService? = nil
    ) {
        self.modelContext = modelContext
        self.paywallService = paywallService ?? PaywallService.shared
        self.notificationService = notificationService ?? NotificationService.shared
    }
    
    // MARK: - Helper Methods
    
    /// Get default notification time from user settings
    private func getDefaultNotifyTime() -> Date {
        let descriptor = FetchDescriptor<UserSettings>()
        if let settings = try? modelContext.fetch(descriptor).first {
            return settings.defaultNotifyTime
        }
        return Calendar.current.date(from: DateComponents(hour: 9, minute: 0)) ?? Date()
    }
    
    // MARK: - CRUD Operations
    
    /// Create a new subscription with free user limit check
    /// - Parameter subscription: The subscription to create
    /// - Returns: True if created successfully
    /// - Throws: AppError if limit reached or save fails
    func createSubscription(_ subscription: Subscription) async throws -> Bool {
        Logger.data.info("Creating subscription: \(subscription.name)")

        // Check free user limits (count all active subscriptions including private)
        let activeCount = fetchActiveSubscriptions(includePrivate: true).count
        guard paywallService.canCreateSubscription(currentCount: activeCount) else {
            Logger.data.warning("Subscription creation blocked: limit reached (count: \(activeCount))")
            throw AppError.subscriptionLimitReached
        }
        
        // Insert subscription
        modelContext.insert(subscription)
        
        // Save context
        do {
            try modelContext.save()
            Logger.data.info("Successfully created subscription: \(subscription.id)")
        } catch {
            Logger.data.error("Failed to save subscription: \(error.localizedDescription)")
            throw AppError.dataSaveFailed(reason: error.localizedDescription)
        }
        
        // Schedule notification if enabled
        if subscription.notify {
            let notifyTime = getDefaultNotifyTime()
            try? await notificationService.scheduleNotification(for: subscription, notifyTime: notifyTime)
        }

        refreshWidgetData()

        return true
    }
    
    /// Update an existing subscription
    /// - Parameter subscription: The subscription to update
    /// - Throws: AppError if save fails
    func updateSubscription(_ subscription: Subscription) async throws {
        Logger.data.info("Updating subscription: \(subscription.id)")
        subscription.updatedAt = Date()
        
        // Save context
        do {
            try modelContext.save()
            Logger.data.info("Successfully updated subscription: \(subscription.id)")
        } catch {
            Logger.data.error("Failed to update subscription: \(error.localizedDescription)")
            throw AppError.dataSaveFailed(reason: error.localizedDescription)
        }
        
        // Update notification
        let notifyTime = getDefaultNotifyTime()
        try? await notificationService.updateNotification(for: subscription, notifyTime: notifyTime)

        refreshWidgetData()
    }
    
    /// Delete a subscription and cancel its notifications
    /// - Parameter subscription: The subscription to delete
    /// - Throws: AppError if delete fails
    func deleteSubscription(_ subscription: Subscription) async throws {
        Logger.data.info("Deleting subscription: \(subscription.id)")
        
        // Cancel notifications first
        await notificationService.cancelNotifications(for: subscription)
        
        // Delete from context
        modelContext.delete(subscription)
        
        // Save context
        do {
            try modelContext.save()
            Logger.data.info("Successfully deleted subscription: \(subscription.id)")
        } catch {
            Logger.data.error("Failed to delete subscription: \(error.localizedDescription)")
            throw AppError.dataSaveFailed(reason: error.localizedDescription)
        }

        refreshWidgetData()
    }
    
    // MARK: - Archive Operations
    
    /// Archive a subscription and cancel its notifications
    /// - Parameter subscription: The subscription to archive
    /// - Throws: AppError if save fails
    func archiveSubscription(_ subscription: Subscription) async throws {
        subscription.archived = true
        subscription.updatedAt = Date()
        
        // Cancel notifications
        await notificationService.cancelNotifications(for: subscription)

        // Save context
        do {
            try modelContext.save()
        } catch {
            throw AppError.dataSaveFailed(reason: error.localizedDescription)
        }

        refreshWidgetData()
    }
    
    /// Unarchive a subscription and reschedule notifications
    /// - Parameter subscription: The subscription to unarchive
    /// - Throws: AppError if save fails or limit reached
    func unarchiveSubscription(_ subscription: Subscription) async throws {
        // Check free user limits (count all active subscriptions including private)
        let activeCount = fetchActiveSubscriptions(includePrivate: true).count
        guard paywallService.canCreateSubscription(currentCount: activeCount) else {
            throw AppError.subscriptionLimitReached
        }
        
        subscription.archived = false
        subscription.updatedAt = Date()
        
        // Save context
        do {
            try modelContext.save()
        } catch {
            throw AppError.dataSaveFailed(reason: error.localizedDescription)
        }
        
        // Reschedule notification if enabled
        if subscription.notify {
            let notifyTime = getDefaultNotifyTime()
            try? await notificationService.scheduleNotification(for: subscription, notifyTime: notifyTime)
        }

        refreshWidgetData()
    }
    
    // MARK: - Query Operations
    
    /// Check if private subscriptions should be shown
    private func shouldShowPrivate() -> Bool {
        let descriptor = FetchDescriptor<UserSettings>()
        if let settings = try? modelContext.fetch(descriptor).first {
            return settings.showPrivateSubscriptions
        }
        return false
    }

    /// Fetch all active (non-archived) subscriptions
    /// - Parameter includePrivate: Override to include private subscriptions regardless of settings
    /// - Returns: Array of active subscriptions
    func fetchActiveSubscriptions(includePrivate: Bool? = nil) -> [Subscription] {
        let descriptor = FetchDescriptor<Subscription>(
            predicate: #Predicate { !$0.archived }
        )

        do {
            var subscriptions = try modelContext.fetch(descriptor)
            let showPrivate = includePrivate ?? shouldShowPrivate()
            if !showPrivate {
                subscriptions = subscriptions.filter { !$0.isPrivate }
            }
            // Sort by next relevant date (trial expiry for trials, next billing for regular)
            return subscriptions.sorted {
                let date0 = $0.isTrial ? ($0.trialExpiryDate ?? .distantFuture) : $0.nextBillingDate
                let date1 = $1.isTrial ? ($1.trialExpiryDate ?? .distantFuture) : $1.nextBillingDate
                return date0 < date1
            }
        } catch {
            print("Error fetching active subscriptions: \(error)")
            return []
        }
    }

    /// Fetch all archived subscriptions
    /// - Parameter includePrivate: Override to include private subscriptions regardless of settings
    /// - Returns: Array of archived subscriptions
    func fetchArchivedSubscriptions(includePrivate: Bool? = nil) -> [Subscription] {
        let descriptor = FetchDescriptor<Subscription>(
            predicate: #Predicate { $0.archived },
            sortBy: [SortDescriptor(\.updatedAt, order: .reverse)]
        )

        do {
            var subscriptions = try modelContext.fetch(descriptor)
            let showPrivate = includePrivate ?? shouldShowPrivate()
            if !showPrivate {
                subscriptions = subscriptions.filter { !$0.isPrivate }
            }
            return subscriptions
        } catch {
            print("Error fetching archived subscriptions: \(error)")
            return []
        }
    }
    
    /// Search subscriptions by name or description
    /// - Parameter query: Search query string
    /// - Returns: Array of matching subscriptions
    func searchSubscriptions(query: String) -> [Subscription] {
        guard !query.isEmpty else {
            return fetchActiveSubscriptions()
        }
        
        let lowercasedQuery = query.lowercased()
        let allSubscriptions = fetchActiveSubscriptions()
        
        return allSubscriptions.filter { subscription in
            subscription.name.lowercased().contains(lowercasedQuery) ||
            (subscription.subscriptionDescription?.lowercased().contains(lowercasedQuery) ?? false)
        }
    }
    
    /// Fetch subscriptions by category
    /// - Parameter category: The category to filter by
    /// - Returns: Array of subscriptions in the category
    func fetchSubscriptionsByCategory(_ category: Category) -> [Subscription] {
        // Fetch all active subscriptions and filter in memory
        let allSubscriptions = fetchActiveSubscriptions()
        return allSubscriptions.filter { $0.category?.id == category.id }
    }
    
    // MARK: - Statistics
    
    /// Calculate total monthly expense for a specific currency
    /// - Parameter currency: Currency code (e.g., "USD", "CNY")
    /// - Returns: Total monthly equivalent amount
    func calculateMonthlyTotal(currency: String) -> Decimal {
        let subscriptions = fetchActiveSubscriptions().filter { !$0.isTrial }

        return subscriptions
            .filter { $0.currency == currency }
            .map { $0.monthlyEquivalent }
            .reduce(0, +)
    }
    
    /// Calculate monthly expense trend for past months
    /// - Parameter months: Number of months to calculate (default 6)
    /// - Returns: Array of monthly expenses by currency
    func calculateMonthlyTrend(months: Int = 6) -> [MonthlyExpense] {
        let calendar = Calendar.current
        let now = Date()
        var result: [MonthlyExpense] = []
        
        // Get all active subscriptions (exclude trials)
        let subscriptions = fetchActiveSubscriptions().filter { !$0.isTrial }

        // Group by currency
        let currencies = Set(subscriptions.map { $0.currency })

        // Calculate for each month
        for monthOffset in (0..<months).reversed() {
            guard let monthDate = calendar.date(byAdding: .month, value: -monthOffset, to: now) else {
                continue
            }
            
            let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: monthDate))!
            let monthEnd = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: monthStart)!
            
            // Calculate for each currency
            for currency in currencies {
                var monthTotal: Decimal = 0
                
                for subscription in subscriptions where subscription.currency == currency {
                    // Check if subscription was active during this month
                    if subscription.firstPaymentDate <= monthEnd {
                        // Calculate billing dates in this month
                        let billingDates = BillingCalculator.calculateAllBillingDates(
                            from: subscription.firstPaymentDate,
                            cycle: subscription.billingCycle,
                            unit: subscription.billingCycleUnit,
                            until: monthEnd
                        )
                        
                        // Count payments in this month
                        let paymentsInMonth = billingDates.filter { date in
                            date >= monthStart && date <= monthEnd
                        }.count
                        
                        monthTotal += subscription.amount * Decimal(paymentsInMonth)
                    }
                }
                
                result.append(MonthlyExpense(
                    month: monthStart,
                    amount: monthTotal,
                    currency: currency
                ))
            }
        }
        
        return result
    }
    
    /// Fetch subscriptions with upcoming renewals
    /// - Parameter days: Number of days to look ahead (default 30)
    /// - Returns: Array of subscriptions renewing within the specified days
    func fetchUpcomingRenewals(days: Int = 30) -> [Subscription] {
        let calendar = Calendar.current
        let now = Date()
        guard let futureDate = calendar.date(byAdding: .day, value: days, to: now) else {
            return []
        }

        let subscriptions = fetchActiveSubscriptions()

        return subscriptions
            .filter { subscription in
                if subscription.isTrial {
                    guard let expiryDate = subscription.trialExpiryDate else { return false }
                    return expiryDate > now && expiryDate <= futureDate
                } else {
                    let nextBilling = subscription.nextBillingDate
                    return nextBilling > now && nextBilling <= futureDate
                }
            }
            .sorted {
                let date0 = $0.isTrial ? ($0.trialExpiryDate ?? .distantFuture) : $0.nextBillingDate
                let date1 = $1.isTrial ? ($1.trialExpiryDate ?? .distantFuture) : $1.nextBillingDate
                return date0 < date1
            }
    }
    
    /// Calculate historical expense for a subscription
    /// - Parameter subscription: The subscription to calculate for
    /// - Returns: Tuple of (total amount, payment count)
    func calculateHistoricalExpense(for subscription: Subscription) -> (total: Decimal, count: Int) {
        let billingDates = BillingCalculator.calculateAllBillingDates(
            from: subscription.firstPaymentDate,
            cycle: subscription.billingCycle,
            unit: subscription.billingCycleUnit,
            until: Date()
        )
        
        let count = billingDates.count
        let total = subscription.amount * Decimal(count)

        return (total, count)
    }

    // MARK: - Widget Data

    /// Refresh widget data from current subscriptions and write to shared UserDefaults
    func refreshWidgetData() {
        // Exclude trial and private subscriptions from widget data
        let subscriptions = fetchActiveSubscriptions(includePrivate: false).filter { !$0.isTrial }

        let items = subscriptions.map { sub in
            WidgetSubscriptionItem(
                id: sub.id,
                name: sub.name,
                amount: sub.amount,
                currency: sub.currency,
                nextBillingDate: sub.nextBillingDate,
                billingCycle: sub.billingCycle,
                billingCycleUnitRaw: sub.billingCycleUnitRawValue,
                categoryName: sub.category?.name,
                categoryColorHex: sub.category?.colorHex,
                iconURL: sub.iconURL
            )
        }

        // Calculate monthly totals by currency
        let currencies = Set(subscriptions.map { $0.currency })
        var totals: [String: Decimal] = [:]
        for currency in currencies {
            totals[currency] = subscriptions
                .filter { $0.currency == currency }
                .map { $0.monthlyEquivalent }
                .reduce(0, +)
        }

        // Read theme settings from UserSettings
        let themeColor: String
        let darkMode: Bool?
        let settingsDescriptor = FetchDescriptor<UserSettings>()
        if let settings = try? modelContext.fetch(settingsDescriptor).first {
            themeColor = settings.themeColor
            darkMode = settings.darkMode
        } else {
            themeColor = "#007AFF"
            darkMode = nil
        }

        let widgetData = WidgetData(
            subscriptions: items,
            monthlyTotalsByCurrency: totals,
            isProUser: paywallService.isProUser,
            themeColorHex: themeColor,
            darkMode: darkMode,
            lastUpdated: Date()
        )

        WidgetDataStore.save(widgetData)
        WidgetCenter.shared.reloadAllTimelines()
    }
}

// MARK: - Supporting Types

/// Monthly expense data for trend calculations
struct MonthlyExpense: Identifiable {
    let id = UUID()
    let month: Date
    let amount: Decimal
    let currency: String
}

/// Application error types
enum AppError: LocalizedError {
    case dataNotFound
    case dataSaveFailed(reason: String)
    case dataLoadFailed(reason: String)
    case invalidData(field: String)
    case subscriptionLimitReached
    case categoryLimitReached
    case notificationPermissionDenied
    case notificationScheduleFailed
    case syncFailed(reason: String)
    case networkUnavailable
    case iCloudNotAvailable
    case purchaseFailed(reason: String)
    case purchaseCancelled
    case restoreFailed
    
    var errorDescription: String? {
        switch self {
        case .dataNotFound:
            return L10n.Error.dataNotFound
        case .dataSaveFailed(let reason):
            return L10n.Error.dataSaveFailed(reason)
        case .dataLoadFailed(let reason):
            return L10n.Error.dataLoadFailed(reason)
        case .invalidData(let field):
            return L10n.Error.invalidData(field)
        case .subscriptionLimitReached:
            return L10n.Error.subscriptionLimit
        case .categoryLimitReached:
            return L10n.Error.categoryLimit
        case .notificationPermissionDenied:
            return L10n.Error.notificationPermission
        case .notificationScheduleFailed:
            return L10n.Error.notificationSchedule
        case .syncFailed(let reason):
            return L10n.Error.syncFailed(reason)
        case .networkUnavailable:
            return L10n.Error.networkUnavailable
        case .iCloudNotAvailable:
            return L10n.Error.iCloudUnavailable
        case .purchaseFailed(let reason):
            return L10n.Error.purchaseFailed(reason)
        case .purchaseCancelled:
            return L10n.Error.purchaseCancelled
        case .restoreFailed:
            return L10n.Error.restoreFailed
        }
    }
}
