//
//  InsightsViewModel.swift
//  subscription-tracker
//
//  Created by Kiro on 2026/2/26.
//

import Foundation
import SwiftUI
import Combine

/// Filter type for Insights view
enum InsightsFilterType: String, CaseIterable {
    case active = "active"
    case archived = "archived"
    case all = "all"
    
    var title: String {
        switch self {
        case .active: return L10n.Subscriptions.filterActive
        case .archived: return L10n.Subscriptions.filterArchived
        case .all: return L10n.Subscriptions.filterAll
        }
    }
}

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
    
    @Published var filterType: InsightsFilterType = .active {
        didSet {
            Task {
                await loadData()
            }
        }
    }
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
    @Published var defaultCurrency: String = "USD" {
        didSet {
            Task {
                await loadData()
            }
        }
    }
    
    // MARK: - Initialization
    
    init(subscriptionService: SubscriptionService, defaultCurrency: String = "USD") {
        self.subscriptionService = subscriptionService
        self.defaultCurrency = defaultCurrency
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
            let subscriptions = fetchFilteredSubscriptions()
            print("📊 InsightsViewModel: Fetched \(subscriptions.count) subscriptions with filter: \(filterType.rawValue)")
            
            // Monthly expenses
            monthlyExpenses = calculateMonthlyExpensesByCurrency(subscriptions: subscriptions)
            
            // Yearly expenses
            yearlyExpenses = calculateYearlyExpensesByCurrency(subscriptions: subscriptions)
            
            // Recent trend (6 months)
            recentTrendData = calculateMonthlyTrend(subscriptions: subscriptions, months: 6)
            
            // All-time trend
            allTimeTrendData = calculateAllTimeTrend(subscriptions: subscriptions)
            
            // Top 5 spending
            topSpendingData = calculateTopSpending(subscriptions: subscriptions, limit: 5)
            
            // Upcoming renewals
            upcomingRenewals = calculateUpcomingRenewals(subscriptions: subscriptions, days: 30)
            
            // Category breakdown
            categoryBreakdown = calculateCategoryBreakdown(subscriptions: subscriptions)
            
            print("✅ InsightsViewModel: Data loaded successfully")
        } catch {
            print("❌ Error loading insights data: \(error)")
        }
        
        isLoading = false
        print("✅ InsightsViewModel: loadData completed, isLoading = false")
    }
    
    // MARK: - Private Helpers
    
    private func fetchFilteredSubscriptions() -> [Subscription] {
        switch filterType {
        case .active:
            return subscriptionService.fetchActiveSubscriptions()
        case .archived:
            return subscriptionService.fetchArchivedSubscriptions()
        case .all:
            return subscriptionService.fetchActiveSubscriptions() + subscriptionService.fetchArchivedSubscriptions()
        }
    }
    
    // MARK: - Public Helpers
    
    /// Get filtered subscriptions (exposed for view)
    func getFilteredSubscriptions() -> [Subscription] {
        return fetchFilteredSubscriptions()
    }
    
    // MARK: - Private Calculations
    
    private func calculateMonthlyExpensesByCurrency(subscriptions: [Subscription]) -> [String: Decimal] {
        // Convert all to default currency
        var total = Decimal(0)
        
        for subscription in subscriptions {
            let monthlyAmount = subscription.monthlyEquivalent
            let convertedAmount = CurrencyConverter.convert(
                amount: monthlyAmount,
                from: subscription.currency,
                to: defaultCurrency
            )
            total += convertedAmount
        }
        
        return [defaultCurrency: total]
    }
    
    private func calculateYearlyExpensesByCurrency(subscriptions: [Subscription]) -> [String: Decimal] {
        // Convert all to default currency
        var total = Decimal(0)
        
        for subscription in subscriptions {
            let monthlyAmount = subscription.monthlyEquivalent
            let convertedAmount = CurrencyConverter.convert(
                amount: monthlyAmount,
                from: subscription.currency,
                to: defaultCurrency
            )
            total += convertedAmount
        }
        
        return [defaultCurrency: total * 12]
    }
    
    private func calculateMonthlyTrend(subscriptions: [Subscription], months: Int) -> [MonthlyExpense] {
        guard !subscriptions.isEmpty else { return [] }
        
        let calendar = Calendar.current
        let now = Date()
        var result: [MonthlyExpense] = []
        
        for i in (0..<months).reversed() {
            guard let monthDate = calendar.date(byAdding: .month, value: -i, to: now),
                  let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: monthDate)),
                  let endOfMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth) else {
                continue
            }
            
            // Calculate total for this month, convert all to default currency
            var monthTotal = Decimal(0)
            
            for subscription in subscriptions {
                // Check if subscription was active during this month
                let subscriptionStart = subscription.firstPaymentDate
                // For archived subscriptions, use updatedAt as end date; for active ones, use current date
                let subscriptionEnd = subscription.archived ? subscription.updatedAt : now
                
                // If subscription overlaps with this month
                if subscriptionStart <= endOfMonth && subscriptionEnd >= startOfMonth {
                    let monthlyAmount = subscription.monthlyEquivalent
                    let convertedAmount = CurrencyConverter.convert(
                        amount: monthlyAmount,
                        from: subscription.currency,
                        to: defaultCurrency
                    )
                    monthTotal += convertedAmount
                }
            }
            
            result.append(MonthlyExpense(month: monthDate, amount: monthTotal, currency: defaultCurrency))
        }
        
        return result
    }
    
    private func calculateAllTimeTrend(subscriptions: [Subscription]) -> [MonthlyExpense] {
        guard !subscriptions.isEmpty else { return [] }
        
        // Find earliest subscription date
        let earliestDate = subscriptions.map { $0.firstPaymentDate }.min() ?? Date()
        let calendar = Calendar.current
        let now = Date()
        
        // Calculate number of months from earliest to now
        let components = calendar.dateComponents([.month], from: earliestDate, to: now)
        let monthCount = max((components.month ?? 0) + 1, 1)
        
        return calculateMonthlyTrend(subscriptions: subscriptions, months: monthCount)
    }
    
    private func calculateTopSpending(subscriptions: [Subscription], limit: Int) -> [TopSpendingItem] {
        // Calculate monthly equivalent and convert to default currency
        var spendingMap: [String: (subscription: Subscription, amount: Decimal)] = [:]
        
        for subscription in subscriptions {
            let monthlyAmount = subscription.monthlyEquivalent
            let convertedAmount = CurrencyConverter.convert(
                amount: monthlyAmount,
                from: subscription.currency,
                to: defaultCurrency
            )
            spendingMap[subscription.id.uuidString] = (subscription, convertedAmount)
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
    
    private func calculateUpcomingRenewals(subscriptions: [Subscription], days: Int) -> [Subscription] {
        let calendar = Calendar.current
        let now = Date()
        guard let futureDate = calendar.date(byAdding: .day, value: days, to: now) else {
            return []
        }
        
        // Only show upcoming renewals for active subscriptions
        let activeSubscriptions = subscriptions.filter { !$0.archived }
        
        return activeSubscriptions
            .filter { subscription in
                let nextBilling = subscription.nextBillingDate
                return nextBilling >= now && nextBilling <= futureDate
            }
            .sorted { $0.nextBillingDate < $1.nextBillingDate }
    }
    
    private func calculateCategoryBreakdown(subscriptions: [Subscription]) -> [CategoryExpense] {
        // Group by category and convert to default currency
        var categoryMap: [String: (category: Category?, amount: Decimal, count: Int)] = [:]
        
        for subscription in subscriptions {
            let key = subscription.category?.id.uuidString ?? "uncategorized"
            let monthlyAmount = subscription.monthlyEquivalent
            let convertedAmount = CurrencyConverter.convert(
                amount: monthlyAmount,
                from: subscription.currency,
                to: defaultCurrency
            )
            
            if var existing = categoryMap[key] {
                existing.amount += convertedAmount
                existing.count += 1
                categoryMap[key] = existing
            } else {
                categoryMap[key] = (subscription.category, convertedAmount, 1)
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
