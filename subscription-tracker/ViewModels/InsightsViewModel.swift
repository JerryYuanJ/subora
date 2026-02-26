//
//  InsightsViewModel.swift
//  subscription-tracker
//
//  Created by Kiro on 2026/2/26.
//

import Foundation
import SwiftUI
import Combine

/// Card types available in Insights view
enum InsightCardType: String, CaseIterable, Identifiable {
    case monthlyExpenses = "monthly_expenses"
    case yearlyExpenses = "yearly_expenses"
    case recentTrend = "recent_trend"
    case allTimeTrend = "all_time_trend"
    case topSpending = "top_spending"
    case upcomingRenewals = "upcoming_renewals"
    case categoryBreakdown = "category_breakdown"
    
    var id: String { rawValue }
    
    var title: String {
        switch self {
        case .monthlyExpenses: return L10n.Insights.monthlyExpenses
        case .yearlyExpenses: return L10n.Insights.yearlyExpenses
        case .recentTrend: return L10n.Insights.recentTrend
        case .allTimeTrend: return L10n.Insights.allTimeTrend
        case .topSpending: return L10n.Insights.topSpending
        case .upcomingRenewals: return L10n.Insights.upcomingRenewals
        case .categoryBreakdown: return L10n.Insights.categoryBreakdown
        }
    }
    
    var icon: String {
        switch self {
        case .monthlyExpenses: return "calendar"
        case .yearlyExpenses: return "calendar.badge.clock"
        case .recentTrend: return "chart.line.uptrend.xyaxis"
        case .allTimeTrend: return "chart.xyaxis.line"
        case .topSpending: return "chart.bar.fill"
        case .upcomingRenewals: return "calendar.badge.exclamationmark"
        case .categoryBreakdown: return "chart.pie.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .monthlyExpenses: return Color(hex: "#4C8DFF")
        case .yearlyExpenses: return Color(hex: "#5E5CE6")
        case .recentTrend: return Color(hex: "#34C759")
        case .allTimeTrend: return Color(hex: "#30D158")
        case .topSpending: return Color(hex: "#FF375F")
        case .upcomingRenewals: return Color(hex: "#FF9F0A")
        case .categoryBreakdown: return Color(hex: "#AF52DE")
        }
    }
    
    /// Check if this card requires Pro subscription
    var requiresPro: Bool {
        switch self {
        case .monthlyExpenses, .yearlyExpenses, .recentTrend:
            return false
        case .allTimeTrend, .topSpending, .upcomingRenewals, .categoryBreakdown:
            return true
        }
    }
}

/// ViewModel for Insights view managing card visibility and data
@MainActor
class InsightsViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var visibleCards: Set<InsightCardType> = []
    @Published var monthlyExpenses: [String: Decimal] = [:]
    @Published var yearlyExpenses: [String: Decimal] = [:]
    @Published var recentTrendData: [MonthlyExpense] = []
    @Published var allTimeTrendData: [MonthlyExpense] = []
    @Published var topSpendingData: [TopSpendingItem] = []
    @Published var upcomingRenewals: [Subscription] = []
    @Published var categoryBreakdown: [CategoryExpense] = []
    @Published var isLoading = false
    
    // MARK: - Dependencies
    
    private let subscriptionService: SubscriptionService
    private let userDefaultsKey = "insights_visible_cards"
    
    // MARK: - Initialization
    
    init(subscriptionService: SubscriptionService) {
        self.subscriptionService = subscriptionService
        loadVisibleCards()
    }
    
    // MARK: - Card Visibility Management
    
    func loadVisibleCards() {
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey),
           let decoded = try? JSONDecoder().decode(Set<String>.self, from: data) {
            visibleCards = Set(decoded.compactMap { InsightCardType(rawValue: $0) })
        } else {
            // Default visible cards (free cards only)
            visibleCards = [.monthlyExpenses, .yearlyExpenses, .recentTrend]
        }
    }
    
    func saveVisibleCards() {
        let encoded = try? JSONEncoder().encode(visibleCards.map { $0.rawValue })
        UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
    }
    
    func toggleCard(_ cardType: InsightCardType) {
        if visibleCards.contains(cardType) {
            visibleCards.remove(cardType)
        } else {
            visibleCards.insert(cardType)
        }
        saveVisibleCards()
    }
    
    func isCardVisible(_ cardType: InsightCardType) -> Bool {
        visibleCards.contains(cardType)
    }
    
    // MARK: - Data Loading
    
    func loadData() async {
        print("🔄 InsightsViewModel: Starting loadData, isLoading = true")
        isLoading = true
        
        do {
            let subscriptions = subscriptionService.fetchActiveSubscriptions()
            print("📊 InsightsViewModel: Fetched \(subscriptions.count) subscriptions")
            
            // Monthly expenses
            monthlyExpenses = calculateMonthlyExpensesByCurrency()
            
            // Yearly expenses
            yearlyExpenses = calculateYearlyExpensesByCurrency()
            
            // Recent trend (6 months)
            recentTrendData = subscriptionService.calculateMonthlyTrend(months: 6)
            
            // All-time trend
            allTimeTrendData = calculateAllTimeTrend()
            
            // Top 5 spending
            topSpendingData = calculateTopSpending(limit: 5)
            
            // Upcoming renewals
            upcomingRenewals = subscriptionService.fetchUpcomingRenewals(days: 30)
            
            // Category breakdown
            categoryBreakdown = calculateCategoryBreakdown()
            
            print("✅ InsightsViewModel: Data loaded successfully")
        } catch {
            print("❌ Error loading insights data: \(error)")
        }
        
        isLoading = false
        print("✅ InsightsViewModel: loadData completed, isLoading = false")
    }
    
    // MARK: - Private Calculations
    
    private func calculateMonthlyExpensesByCurrency() -> [String: Decimal] {
        let subscriptions = subscriptionService.fetchActiveSubscriptions()
        let currencies = Set(subscriptions.map { $0.currency })
        
        var result: [String: Decimal] = [:]
        for currency in currencies {
            let total = subscriptionService.calculateMonthlyTotal(currency: currency)
            result[currency] = total
        }
        
        return result
    }
    
    private func calculateYearlyExpensesByCurrency() -> [String: Decimal] {
        let subscriptions = subscriptionService.fetchActiveSubscriptions()
        let currencies = Set(subscriptions.map { $0.currency })
        
        var result: [String: Decimal] = [:]
        for currency in currencies {
            let monthlyTotal = subscriptionService.calculateMonthlyTotal(currency: currency)
            result[currency] = monthlyTotal * 12
        }
        
        return result
    }
    
    private func calculateAllTimeTrend() -> [MonthlyExpense] {
        let subscriptions = subscriptionService.fetchActiveSubscriptions()
        guard !subscriptions.isEmpty else { return [] }
        
        // Find earliest subscription date
        let earliestDate = subscriptions.map { $0.firstPaymentDate }.min() ?? Date()
        let calendar = Calendar.current
        let now = Date()
        
        // Calculate number of months from earliest to now
        let components = calendar.dateComponents([.month], from: earliestDate, to: now)
        let monthCount = max((components.month ?? 0) + 1, 1)
        
        return subscriptionService.calculateMonthlyTrend(months: monthCount)
    }
    
    private func calculateTopSpending(limit: Int) -> [TopSpendingItem] {
        let subscriptions = subscriptionService.fetchActiveSubscriptions()
        
        // Group by subscription and calculate monthly equivalent
        var spendingMap: [String: (subscription: Subscription, amount: Decimal)] = [:]
        
        for subscription in subscriptions {
            let monthlyAmount = subscription.monthlyEquivalent
            spendingMap[subscription.id.uuidString] = (subscription, monthlyAmount)
        }
        
        // Sort by amount and take top N
        let sorted = spendingMap.values
            .sorted { $0.amount > $1.amount }
            .prefix(limit)
        
        return sorted.map { item in
            TopSpendingItem(
                subscription: item.subscription,
                monthlyAmount: item.amount
            )
        }
    }
    
    private func calculateCategoryBreakdown() -> [CategoryExpense] {
        let subscriptions = subscriptionService.fetchActiveSubscriptions()
        
        // Group by category
        var categoryMap: [String: (category: Category?, amount: Decimal, count: Int)] = [:]
        
        for subscription in subscriptions {
            let key = subscription.category?.id.uuidString ?? "uncategorized"
            let monthlyAmount = subscription.monthlyEquivalent
            
            if var existing = categoryMap[key] {
                existing.amount += monthlyAmount
                existing.count += 1
                categoryMap[key] = existing
            } else {
                categoryMap[key] = (subscription.category, monthlyAmount, 1)
            }
        }
        
        // Convert to array and sort by amount
        return categoryMap.values
            .map { CategoryExpense(category: $0.category, amount: $0.amount, count: $0.count) }
            .sorted { $0.amount > $1.amount }
    }
}

// MARK: - Supporting Types

struct TopSpendingItem: Identifiable {
    let id = UUID()
    let subscription: Subscription
    let monthlyAmount: Decimal
}

struct CategoryExpense: Identifiable {
    let id = UUID()
    let category: Category?
    let amount: Decimal
    let count: Int
}
