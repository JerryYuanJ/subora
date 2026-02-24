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
                VStack(spacing: 20) {
                    // Total spending card
                    totalSpendingCard
                    
                    // Trend chart
                    trendChartCard
                    
                    // Upcoming renewals
                    upcomingRenewalsCard
                }
                .padding()
                .padding(.top, -8)
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showAddSubscription = true
                    } label: {
                        Image(systemName: "plus")
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
        HStack(spacing: 0) {
            // Left accent bar
            Rectangle()
                .fill(Color(hex: "#4C8DFF"))
                .frame(width: 4)
            
            VStack(spacing: 16) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(L10n.Dashboard.monthlyExpenses)
                            .font(.subheadline)
                            .fontWeight(.medium)
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
                    
                    ZStack {
                        Circle()
                            .fill(Color(hex: "#4C8DFF").opacity(0.15))
                            .frame(width: 56, height: 56)
                        
                        Image(systemName: "chart.line.uptrend.xyaxis")
                            .font(.system(size: 24))
                            .foregroundColor(Color(hex: "#4C8DFF"))
                    }
                }
                
                // Additional currencies
                if viewModel.monthlyExpenses.count > 1 {
                    Divider()
                        .padding(.vertical, 4)
                    
                    VStack(spacing: 10) {
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
                                        .foregroundColor(.primary)
                                }
                            }
                        }
                    }
                }
            }
            .padding(24)
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 4)
    }
    
    // MARK: - Trend Chart Card
    
    private var trendChartCard: some View {
        HStack(spacing: 0) {
            // Left accent bar
            Rectangle()
                .fill(Color(hex: "#34C759"))
                .frame(width: 4)
            
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text(L10n.Dashboard.trend)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Spacer()
                }
                
                if viewModel.trendData.isEmpty {
                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(Color(hex: "#34C759").opacity(0.15))
                                .frame(width: 80, height: 80)
                            
                            Image(systemName: "chart.line.uptrend.xyaxis")
                                .font(.system(size: 36))
                                .foregroundColor(Color(hex: "#34C759"))
                        }
                        
                        VStack(spacing: 6) {
                            Text(L10n.Dashboard.noTrendData)
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.primary)
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
                        .frame(height: 220)
                        .padding(.top, 8)
                }
            }
            .padding(24)
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 4)
    }
    
    // MARK: - Upcoming Renewals Card
    
    private var upcomingRenewalsCard: some View {
        HStack(spacing: 0) {
            // Left accent bar
            Rectangle()
                .fill(Color(hex: "#FF9F0A"))
                .frame(width: 4)
            
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text(L10n.Dashboard.upcomingRenewals)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    if !viewModel.upcomingRenewals.isEmpty {
                        Text("\(viewModel.upcomingRenewals.count)")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(Color(hex: "#FF9F0A"))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(
                                Capsule()
                                    .fill(Color(hex: "#FF9F0A").opacity(0.15))
                            )
                    }
                }
                
                if viewModel.upcomingRenewals.isEmpty {
                    VStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(Color(hex: "#FF9F0A").opacity(0.15))
                                .frame(width: 64, height: 64)
                            
                            Image(systemName: "calendar.badge.checkmark")
                                .font(.system(size: 28))
                                .foregroundColor(Color(hex: "#FF9F0A"))
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
        .background(Color.white)
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
            // Category color indicator
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
                Text("\(daysUntilRenewal)\(L10n.Insights.daysSuffix)")
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
                .fill(Color(hex: "#F5F5F7"))
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
