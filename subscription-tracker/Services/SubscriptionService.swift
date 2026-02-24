//
//  SubscriptionService.swift
//  subscription-tracker
//
//  Created by Kiro on 2026/2/24.
//

import Foundation
import SwiftData
import OSLog

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
        paywallService: PaywallService = .shared,
        notificationService: NotificationService = .shared
    ) {
        self.modelContext = modelContext
        self.paywallService = paywallService
        self.notificationService = notificationService
    }
    
    // MARK: - CRUD Operations
    
    /// Create a new subscription with free user limit check
    /// - Parameter subscription: The subscription to create
    /// - Returns: True if created successfully
    /// - Throws: AppError if limit reached or save fails
    func createSubscription(_ subscription: Subscription) async throws -> Bool {
        Logger.data.info("Creating subscription: \(subscription.name)")
        
        // Check free user limits
        let activeCount = fetchActiveSubscriptions().count
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
            try? await notificationService.scheduleNotification(for: subscription)
        }
        
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
        try? await notificationService.updateNotification(for: subscription)
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
    }
    
    /// Unarchive a subscription and reschedule notifications
    /// - Parameter subscription: The subscription to unarchive
    /// - Throws: AppError if save fails or limit reached
    func unarchiveSubscription(_ subscription: Subscription) async throws {
        // Check free user limits
        let activeCount = fetchActiveSubscriptions().count
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
            try? await notificationService.scheduleNotification(for: subscription)
        }
    }
    
    // MARK: - Query Operations
    
    /// Fetch all active (non-archived) subscriptions
    /// - Returns: Array of active subscriptions
    func fetchActiveSubscriptions() -> [Subscription] {
        let descriptor = FetchDescriptor<Subscription>(
            predicate: #Predicate { !$0.archived },
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        
        do {
            let subscriptions = try modelContext.fetch(descriptor)
            // Sort by next billing date in memory
            return subscriptions.sorted { $0.nextBillingDate < $1.nextBillingDate }
        } catch {
            print("Error fetching active subscriptions: \(error)")
            return []
        }
    }
    
    /// Fetch all archived subscriptions
    /// - Returns: Array of archived subscriptions
    func fetchArchivedSubscriptions() -> [Subscription] {
        let descriptor = FetchDescriptor<Subscription>(
            predicate: #Predicate { $0.archived },
            sortBy: [SortDescriptor(\.updatedAt, order: .reverse)]
        )
        
        do {
            return try modelContext.fetch(descriptor)
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
        let subscriptions = fetchActiveSubscriptions()
        
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
        
        // Get all active subscriptions
        let subscriptions = fetchActiveSubscriptions()
        
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
        
        return subscriptions.filter { subscription in
            let nextBilling = subscription.nextBillingDate
            return nextBilling > now && nextBilling <= futureDate
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
