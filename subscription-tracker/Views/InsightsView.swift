//
//  InsightsView.swift
//  subscription-tracker
//
//  Created by Kiro on 2026/2/26.
//

import SwiftUI
import SwiftData
import Charts

/// Insights view displaying beautiful analytics and statistics with customizable cards
struct InsightsView: View {
    
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel: InsightsViewModel
    @EnvironmentObject private var paywallService: PaywallService
    @State private var showCardManagement = false
    @Query private var userSettings: [UserSettings]
    @State private var showCurrencyNotice = true
    
    private let currencyNoticeKey = "insights_currency_notice_dismissed"
    
    init(modelContext: ModelContext) {
        let subscriptionService = SubscriptionService(modelContext: modelContext)
        
        // Get default currency from user settings
        var defaultCurrency = "USD"
        let descriptor = FetchDescriptor<UserSettings>()
        if let userSettings = try? modelContext.fetch(descriptor).first {
            defaultCurrency = userSettings.defaultCurrency
        }
        
        let viewModel = InsightsViewModel(
            subscriptionService: subscriptionService,
            defaultCurrency: defaultCurrency
        )
        _viewModel = StateObject(wrappedValue: viewModel)
        
        // Load currency notice preference
        _showCurrencyNotice = State(initialValue: !UserDefaults.standard.bool(forKey: "insights_currency_notice_dismissed"))
    }
    
    // MARK: - Computed Properties
    
    private var hasMultipleCurrencies: Bool {
        let subscriptions = viewModel.getFilteredSubscriptions()
        let currencies = Set(subscriptions.map { $0.currency })
        return currencies.count > 1
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                if sortedVisibleCards.isEmpty {
                    // Empty state when no cards are selected
                    emptyStateView
                } else {
                    VStack(spacing: 0) {
                        // Currency conversion notice
                        if showCurrencyNotice && hasMultipleCurrencies {
                            currencyNoticeBanner
                        }
                        
                        ScrollView {
                            VStack(spacing: 20) {
                                // Render visible cards
                                ForEach(sortedVisibleCards, id: \.self) { cardType in
                                    cardView(for: cardType)
                                }
                            }
                            .padding()
                            .padding(.top, -8)
                        }
                    }
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Menu {
                        ForEach(InsightsFilterType.allCases, id: \.self) { filterType in
                            Button {
                                viewModel.filterType = filterType
                            } label: {
                                HStack {
                                    Text(filterType.title)
                                    if viewModel.filterType == filterType {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Text(viewModel.filterType.title)
                                .font(.headline)
                            Image(systemName: "chevron.down")
                                .font(.caption)
                        }
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showCardManagement = true
                    } label: {
                        Image(systemName: "slider.horizontal.3")
                    }
                }
            }
            .sheet(isPresented: $showCardManagement) {
                InsightCardManagementView(viewModel: viewModel)
                    .environmentObject(paywallService)
            }
            .task {
                await viewModel.loadData()
            }
            .refreshable {
                await viewModel.loadData()
            }
            .onChange(of: paywallService.isProUser) { _, isProUser in
                if isProUser {
                    // Reload visible cards when user becomes Pro
                    viewModel.loadVisibleCards()
                }
            }
            .onChange(of: userSettings.first?.defaultCurrency) { _, newCurrency in
                if let currency = newCurrency {
                    viewModel.defaultCurrency = currency
                }
            }
            .overlay {
                if viewModel.isLoading {
                    LoadingOverlay(message: L10n.Loading.default)
                }
            }
        }
    }
    
    // MARK: - Currency Notice Banner
    
    private var currencyNoticeBanner: some View {
        HStack(spacing: 8) {
            Image(systemName: "info.circle.fill")
                .foregroundColor(Color(hex: "#FF9F0A"))
                .font(.system(size: 14))
            
            Text(L10n.Insights.currencyNoticeShort)
                .font(.caption)
                .foregroundColor(.primary)
            
            Button {
                withAnimation {
                    showCurrencyNotice = false
                    UserDefaults.standard.set(true, forKey: currencyNoticeKey)
                }
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.secondary)
                    .font(.system(size: 16))
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(hex: "#FF9F0A").opacity(0.15))
        .clipShape(Capsule())
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, 4)
    }
    
    // MARK: - Empty State
    
    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(Color(hex: "#4C8DFF").opacity(0.15))
                    .frame(width: 120, height: 120)
                
                Image(systemName: "chart.bar.doc.horizontal")
                    .font(.system(size: 56))
                    .foregroundColor(Color(hex: "#4C8DFF"))
            }
            
            VStack(spacing: 12) {
                Text(L10n.Insights.noCardsSelected)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text(L10n.Insights.noCardsHint)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            
            Button {
                showCardManagement = true
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "slider.horizontal.3")
                    Text(L10n.Insights.manageCards)
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 14)
                .background(Color(hex: "#4C8DFF"))
                .clipShape(Capsule())
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Card Sorting
    
    private var sortedVisibleCards: [InsightCardType] {
        // Sort cards in a logical order
        let order: [InsightCardType] = [
            .monthlyExpenses,
            .yearlyExpenses,
            .recentTrend,
            .allTimeTrend,
            .topSpending,
            .categoryBreakdown,
            .upcomingRenewals
        ]
        
        var filtered = order.filter { cardType in
            // Only show cards that are visible
            guard viewModel.isCardVisible(cardType) else { return false }
            
            // If card requires Pro and user is not Pro, don't show it
            if cardType.requiresPro && !paywallService.isProUser {
                return false
            }
            
            return true
        }
        
        // If both monthly and yearly are visible, remove monthly from the list
        // as it will be rendered together with yearly
        if viewModel.isCardVisible(.monthlyExpenses) && viewModel.isCardVisible(.yearlyExpenses) {
            filtered.removeAll { $0 == .monthlyExpenses }
        }
        
        return filtered
    }
    
    // MARK: - Card Factory
    
    @ViewBuilder
    private func cardView(for cardType: InsightCardType) -> some View {
        switch cardType {
        case .monthlyExpenses:
            expenseCard(
                title: cardType.title,
                expenses: viewModel.monthlyExpenses,
                color: cardType.color,
                icon: cardType.icon,
                isYearly: false
            )
            
        case .yearlyExpenses:
            if viewModel.isCardVisible(.monthlyExpenses) {
                // Show side by side with monthly
                HStack(spacing: 12) {
                    compactExpenseCard(
                        title: L10n.Insights.monthlyExpenses,
                        expenses: viewModel.monthlyExpenses,
                        color: InsightCardType.monthlyExpenses.color,
                        icon: InsightCardType.monthlyExpenses.icon,
                        isYearly: false
                    )
                    
                    compactExpenseCard(
                        title: cardType.title,
                        expenses: viewModel.yearlyExpenses,
                        color: cardType.color,
                        icon: cardType.icon,
                        isYearly: true
                    )
                }
            } else {
                expenseCard(
                    title: cardType.title,
                    expenses: viewModel.yearlyExpenses,
                    color: cardType.color,
                    icon: cardType.icon,
                    isYearly: true
                )
            }
            
        case .recentTrend:
            trendCard(
                title: cardType.title,
                trendData: viewModel.recentTrendData,
                color: cardType.color
            )
            
        case .allTimeTrend:
            trendCard(
                title: cardType.title,
                trendData: viewModel.allTimeTrendData,
                color: cardType.color
            )
            
        case .topSpending:
            topSpendingCard()
            
        case .categoryBreakdown:
            categoryBreakdownCard()
            
        case .upcomingRenewals:
            upcomingRenewalsCard()
        }
    }
    
    // MARK: - Expense Cards
    
    private func expenseCard(title: String, expenses: [String: Decimal], color: Color, icon: String, isYearly: Bool) -> some View {
        HStack(spacing: 0) {
            Rectangle()
                .fill(color)
                .frame(width: 4)
            
            VStack(spacing: 16) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(title)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                        
                        if let firstCurrency = expenses.keys.sorted().first,
                           let amount = expenses[firstCurrency] {
                            Text(CurrencyFormatter.format(amount: amount, currency: firstCurrency))
                                .font(.system(size: 36, weight: .bold, design: .rounded))
                                .foregroundColor(.primary)
                        } else {
                            Text(L10n.Insights.noAmount)
                                .font(.system(size: 36, weight: .bold, design: .rounded))
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    ZStack {
                        Circle()
                            .fill(color.opacity(0.15))
                            .frame(width: 56, height: 56)
                        
                        Image(systemName: icon)
                            .font(.system(size: 24))
                            .foregroundColor(color)
                    }
                }
                
                if expenses.count > 1 {
                    Divider()
                        .padding(.vertical, 4)
                    
                    VStack(spacing: 10) {
                        ForEach(Array(expenses.keys.sorted().dropFirst()), id: \.self) { currency in
                            if let amount = expenses[currency] {
                                HStack {
                                    Text(currency)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    Spacer()
                                    Text(CurrencyFormatter.format(amount: amount, currency: currency))
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.primary)
                                }
                            }
                        }
                    }
                }
            }
            .padding(24)
        }
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 4)
    }
    
    private func compactExpenseCard(title: String, expenses: [String: Decimal], color: Color, icon: String, isYearly: Bool) -> some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(color)
                .frame(height: 4)
            
            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.15))
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: icon)
                        .font(.system(size: 20))
                        .foregroundColor(color)
                }
                
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                
                if let firstCurrency = expenses.keys.sorted().first,
                   let amount = expenses[firstCurrency] {
                    Text(CurrencyFormatter.format(amount: amount, currency: firstCurrency))
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                } else {
                    Text(L10n.Insights.noAmount)
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.secondary)
                }
            }
            .padding(16)
        }
        .frame(maxWidth: .infinity)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 4)
    }
    
    // MARK: - Trend Card
    
    private func trendCard(title: String, trendData: [MonthlyExpense], color: Color) -> some View {
        HStack(spacing: 0) {
            Rectangle()
                .fill(color)
                .frame(width: 4)
            
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text(title)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Spacer()
                }
                
                if trendData.isEmpty {
                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(color.opacity(0.15))
                                .frame(width: 80, height: 80)
                            
                            Image(systemName: "chart.line.uptrend.xyaxis")
                                .font(.system(size: 36))
                                .foregroundColor(color)
                        }
                        
                        VStack(spacing: 6) {
                            Text(L10n.Insights.noData)
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.primary)
                            Text(L10n.Insights.noDataHint)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .frame(height: 200)
                    .frame(maxWidth: .infinity)
                } else {
                    TrendChart(trendData: trendData)
                        .frame(height: 220)
                        .padding(.top, 8)
                }
            }
            .padding(24)
        }
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 4)
    }
    
    // MARK: - Top Spending Card
    
    private func topSpendingCard() -> some View {
        let cardType = InsightCardType.topSpending
        
        return HStack(spacing: 0) {
            Rectangle()
                .fill(cardType.color)
                .frame(width: 4)
            
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text(cardType.title)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Spacer()
                }
                
                TopSpendingChart(data: viewModel.topSpendingData)
                    .frame(height: 220)
            }
            .padding(24)
        }
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 4)
    }
    
    // MARK: - Category Breakdown Card
    
    private func categoryBreakdownCard() -> some View {
        let cardType = InsightCardType.categoryBreakdown
        
        return HStack(spacing: 0) {
            Rectangle()
                .fill(cardType.color)
                .frame(width: 4)
            
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text(cardType.title)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Spacer()
                }
                
                CategoryBreakdownChart(data: viewModel.categoryBreakdown)
            }
            .padding(24)
        }
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 4)
    }
    
    // MARK: - Upcoming Renewals Card
    
    private func upcomingRenewalsCard() -> some View {
        let cardType = InsightCardType.upcomingRenewals
        
        return HStack(spacing: 0) {
            Rectangle()
                .fill(cardType.color)
                .frame(width: 4)
            
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text(cardType.title)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    if !viewModel.upcomingRenewals.isEmpty {
                        Text("\(viewModel.upcomingRenewals.count)")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(cardType.color)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(
                                Capsule()
                                    .fill(cardType.color.opacity(0.15))
                            )
                    }
                }
                
                if viewModel.upcomingRenewals.isEmpty {
                    VStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(cardType.color.opacity(0.15))
                                .frame(width: 64, height: 64)
                            
                            Image(systemName: "calendar.badge.checkmark")
                                .font(.system(size: 28))
                                .foregroundColor(cardType.color)
                        }
                        
                        Text(L10n.Dashboard.noUpcoming)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                } else {
                    VStack(spacing: 10) {
                        ForEach(viewModel.upcomingRenewals.prefix(5)) { subscription in
                            NavigationLink(destination: SubscriptionDetailView(subscription: subscription, modelContext: modelContext)) {
                                UpcomingRenewalRow(subscription: subscription)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            .padding(24)
        }
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 4)
    }
}

// MARK: - Upcoming Renewal Row Component

struct UpcomingRenewalRow: View {
    let subscription: Subscription
    
    var daysUntilRenewal: Int {
        Calendar.current.dateComponents([.day], from: Date(), to: subscription.nextBillingDate).day ?? 0
    }
    
    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(subscription.category?.color ?? .gray.opacity(0.5))
                .frame(width: 10, height: 10)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(subscription.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                Text(CurrencyFormatter.format(amount: subscription.amount, currency: subscription.currency))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                let dayText = daysUntilRenewal == 1 ? L10n.Insights.daysSuffixSingular : L10n.Insights.daysSuffix
                Text("\(daysUntilRenewal) \(dayText)")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(Color(hex: "#FF9F0A"))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(Color(hex: "#FF9F0A").opacity(0.15))
                    )
                
                Text(formatDate(subscription.nextBillingDate))
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.tertiarySystemGroupedBackground))
        )
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Subscription.self, Category.self, UserSettings.self, configurations: config)
    
    return InsightsView(modelContext: container.mainContext)
}
