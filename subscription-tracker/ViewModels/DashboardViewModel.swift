//
//  DashboardViewModel.swift
//  subscription-tracker
//
//  Created by Kiro on 2026/2/24.
//

import Foundation
import SwiftUI
import Combine

/// ViewModel for Dashboard view, managing monthly expenses, trend data, and upcoming renewals
@MainActor
class DashboardViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    /// Monthly expenses grouped by currency (e.g., ["USD": 156.97, "CNY": 89.00])
    @Published var monthlyExpenses: [String: Decimal] = [:]
    
    /// Trend data for past 6 months
    @Published var trendData: [MonthlyExpense] = []
    
    /// Subscriptions renewing in next 30 days
    @Published var upcomingRenewals: [Subscription] = []
    
    /// Loading state indicator
    @Published var isLoading = false
    
    // MARK: - Computed Properties
    
    /// Count of active subscriptions
    var activeSubscriptionsCount: Int {
        subscriptionService.fetchActiveSubscriptions().count
    }
    
    /// Count of subscriptions added this month
    var newThisMonth: Int {
        let subscriptions = subscriptionService.fetchActiveSubscriptions()
        let calendar = Calendar.current
        let now = Date()
        
        return subscriptions.filter { subscription in
            calendar.isDate(subscription.createdAt, equalTo: now, toGranularity: .month)
        }.count
    }
    
    /// Average subscription cost (in primary currency)
    var averageSubscriptionCost: String {
        let subscriptions = subscriptionService.fetchActiveSubscriptions().filter { !$0.isTrial }
        guard !subscriptions.isEmpty else { return "$0" }
        
        // Use the first currency found
        guard let primaryCurrency = subscriptions.first?.currency else { return "$0" }
        
        // Calculate average for subscriptions in primary currency
        let sameCurrencySubscriptions = subscriptions.filter { $0.currency == primaryCurrency }
        guard !sameCurrencySubscriptions.isEmpty else { return "$0" }
        
        let total = sameCurrencySubscriptions.reduce(Decimal(0)) { sum, subscription in
            sum + BillingCalculator.convertToMonthlyAmount(
                amount: subscription.amount,
                cycle: subscription.billingCycle,
                unit: subscription.billingCycleUnit
            )
        }
        
        let average = total / Decimal(sameCurrencySubscriptions.count)
        return CurrencyFormatter.format(amount: average, currency: primaryCurrency)
    }
    
    // MARK: - Dependencies
    
    private let subscriptionService: SubscriptionService
    
    // MARK: - Initialization
    
    init(subscriptionService: SubscriptionService) {
        self.subscriptionService = subscriptionService
    }
    
    // MARK: - Data Loading
    
    /// Load all dashboard data (monthly expenses, trend data, upcoming renewals)
    func loadData() async {
        isLoading = true
        defer { isLoading = false }
        
        // Load monthly expenses grouped by currency
        monthlyExpenses = calculateMonthlyExpensesByCurrency()
        
        // Load 6-month trend data
        trendData = subscriptionService.calculateMonthlyTrend(months: 6)
        
        // Load subscriptions renewing in next 30 days
        upcomingRenewals = subscriptionService.fetchUpcomingRenewals(days: 30)
    }
    
    // MARK: - Private Helpers
    
    /// Calculate monthly expenses grouped by currency
    /// - Returns: Dictionary mapping currency codes to total monthly amounts
    private func calculateMonthlyExpensesByCurrency() -> [String: Decimal] {
        let subscriptions = subscriptionService.fetchActiveSubscriptions().filter { !$0.isTrial }
        
        // Get all unique currencies
        let currencies = Set(subscriptions.map { $0.currency })
        
        // Calculate total for each currency
        var result: [String: Decimal] = [:]
        for currency in currencies {
            let total = subscriptionService.calculateMonthlyTotal(currency: currency)
            result[currency] = total
        }
        
        return result
    }
}
