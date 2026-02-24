//
//  InsightsView.swift
//  subscription-tracker
//
//  Created by Kiro on 2026/2/24.
//

import SwiftUI
import SwiftData
import Charts

/// Insights view displaying beautiful analytics and statistics
struct InsightsView: View {
    
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel: DashboardViewModel
    @State private var showAddSubscription = false
    
    init(modelContext: ModelContext) {
        let subscriptionService = SubscriptionService(modelContext: modelContext)
        _viewModel = StateObject(wrappedValue: DashboardViewModel(subscriptionService: subscriptionService))
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Total spending card
                    totalSpendingCard
                    
                    // Statistics grid
                    statisticsGrid
                    
                    // Trend chart
                    trendChartCard
                    
                    // Upcoming renewals
                    upcomingRenewalsCard
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showAddSubscription = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                    }
                }
            }
            .sheet(isPresented: $showAddSubscription) {
                AddEditSubscriptionView(modelContext: modelContext)
            }
            .task {
                await viewModel.loadData()
            }
            .onChange(of: showAddSubscription) { _, isPresented in
                if !isPresented {
                    Task {
                        await viewModel.loadData()
                    }
                }
            }
            .overlay {
                if viewModel.isLoading {
                    LoadingOverlay(message: L10n.Loading.default)
                }
            }
        }
    }
    
    // MARK: - Total Spending Card
    
    private var totalSpendingCard: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(L10n.Dashboard.monthlyExpenses)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    if let firstCurrency = viewModel.monthlyExpenses.keys.sorted().first,
                       let amount = viewModel.monthlyExpenses[firstCurrency] {
                        Text(CurrencyFormatter.format(amount: amount, currency: firstCurrency))
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                    } else {
                        Text("$0.00")
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                Image(systemName: "chart.line.uptrend.xyaxis.circle.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            
            // Additional currencies
            if viewModel.monthlyExpenses.count > 1 {
                Divider()
                
                VStack(spacing: 8) {
                    ForEach(Array(viewModel.monthlyExpenses.keys.sorted().dropFirst()), id: \.self) { currency in
                        if let amount = viewModel.monthlyExpenses[currency] {
                            HStack {
                                Text(currency)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text(CurrencyFormatter.format(amount: amount, currency: currency))
                                    .font(.headline)
                                    .fontWeight(.semibold)
                            }
                        }
                    }
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
        )
    }
    
    // MARK: - Statistics Grid
    
    private var statisticsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
            StatCard(
                title: L10n.Insights.activeSubscriptions,
                value: "\(viewModel.activeSubscriptionsCount)",
                icon: "checkmark.circle.fill",
                color: .green
            )
            
            StatCard(
                title: L10n.Insights.upcomingRenewalsCount,
                value: "\(viewModel.upcomingRenewals.count)",
                icon: "clock.fill",
                color: .orange
            )
            
            StatCard(
                title: L10n.Insights.newThisMonth,
                value: "\(viewModel.newThisMonth)",
                icon: "plus.circle.fill",
                color: .blue
            )
            
            StatCard(
                title: L10n.Insights.averageCost,
                value: viewModel.averageSubscriptionCost,
                icon: "chart.bar.fill",
                color: .purple
            )
        }
    }
    
    // MARK: - Trend Chart Card
    
    private var trendChartCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(L10n.Dashboard.trend)
                .font(.title3)
                .fontWeight(.bold)
            
            if viewModel.trendData.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.system(size: 50))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.blue.opacity(0.6), .purple.opacity(0.6)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    VStack(spacing: 8) {
                        Text(L10n.Dashboard.noTrendData)
                            .font(.headline)
                            .foregroundColor(.secondary)
                        Text(L10n.Dashboard.noTrendHint)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                }
                .frame(height: 200)
                .frame(maxWidth: .infinity)
            } else {
                TrendChart(trendData: viewModel.trendData)
                    .frame(height: 200)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
        )
    }
    
    // MARK: - Upcoming Renewals Card
    
    private var upcomingRenewalsCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text(L10n.Dashboard.upcomingRenewals)
                    .font(.title3)
                    .fontWeight(.bold)
                
                Spacer()
                
                if !viewModel.upcomingRenewals.isEmpty {
                    Text("\(viewModel.upcomingRenewals.count)")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(Color.orange)
                        )
                }
            }
            
            if viewModel.upcomingRenewals.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "calendar.badge.checkmark")
                        .font(.system(size: 40))
                        .foregroundColor(.green.opacity(0.6))
                    Text(L10n.Dashboard.noUpcoming)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
            } else {
                VStack(spacing: 12) {
                    ForEach(viewModel.upcomingRenewals.prefix(5)) { subscription in
                        NavigationLink(destination: SubscriptionDetailView(subscription: subscription, modelContext: modelContext)) {
                            UpcomingRenewalRow(subscription: subscription)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
        )
    }
}

// MARK: - Stat Card Component

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(value)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
        )
    }
}

// MARK: - Upcoming Renewal Row Component

struct UpcomingRenewalRow: View {
    let subscription: Subscription
    
    var daysUntilRenewal: Int {
        Calendar.current.dateComponents([.day], from: Date(), to: subscription.nextBillingDate).day ?? 0
    }
    
    var urgencyColor: Color {
        if daysUntilRenewal <= 3 {
            return .red
        } else if daysUntilRenewal <= 7 {
            return .orange
        } else {
            return .blue
        }
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Category color indicator
            Circle()
                .fill(subscription.category?.color ?? Color.gray)
                .frame(width: 12, height: 12)
            
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
                Text("\(daysUntilRenewal)\(L10n.Insights.daysSuffix)")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(urgencyColor)
                    )
                
                Text(formatDate(subscription.nextBillingDate))
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemBackground))
        )
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd"
        return formatter.string(from: date)
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Subscription.self, Category.self, UserSettings.self, configurations: config)
    
    return InsightsView(modelContext: container.mainContext)
}
