//
//  SubscriptionDetailViewModel.swift
//  subscription-tracker
//
//  Created by Kiro on 2026/2/24.
//

import Foundation
import SwiftUI
import Combine

/// ViewModel for subscription detail view, managing subscription details, historical expenses, and operations
@MainActor
class SubscriptionDetailViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    /// The subscription being displayed
    @Published var subscription: Subscription
    
    /// Total historical expense for this subscription
    @Published var historicalTotal: Decimal = 0
    
    /// Number of payments made so far
    @Published var paymentCount: Int = 0
    
    /// Days until next renewal
    @Published var daysUntilRenewal: Int = 0
    
    // MARK: - Dependencies
    
    let subscriptionService: SubscriptionService
    
    // MARK: - Initialization
    
    init(subscription: Subscription, subscriptionService: SubscriptionService) {
        self.subscription = subscription
        self.subscriptionService = subscriptionService
    }
    
    // MARK: - Data Loading
    
    /// Load subscription details including historical expense and days until renewal
    func loadDetails() {
        if subscription.isTrial {
            // Trials have no payment history or billing cycle
            historicalTotal = 0
            paymentCount = 0
            daysUntilRenewal = subscription.trialDaysRemaining ?? 0
        } else {
            // Calculate historical expense
            let (total, count) = subscriptionService.calculateHistoricalExpense(for: subscription)
            historicalTotal = total
            paymentCount = count

            // Calculate days until renewal
            daysUntilRenewal = Calendar.current.dateComponents(
                [.day],
                from: Date(),
                to: subscription.nextBillingDate
            ).day ?? 0
        }
    }
    
    // MARK: - Operations
    
    /// Archive the subscription
    /// - Throws: AppError if archive operation fails
    func archive() async throws {
        try await subscriptionService.archiveSubscription(subscription)
    }
    
    /// Delete the subscription
    /// - Throws: AppError if delete operation fails
    func delete() async throws {
        // Track analytics before deletion
        AnalyticsService.shared.trackSubscriptionDeleted(name: subscription.name)
        
        try await subscriptionService.deleteSubscription(subscription)
    }
}
