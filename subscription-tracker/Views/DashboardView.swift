//
//  DashboardView.swift
//  subscription-tracker
//
//  Created by Kiro on 2026/2/24.
//

import SwiftUI
import SwiftData

/// Dashboard view displaying monthly expenses, trend chart, and upcoming renewals
struct DashboardView: View {
    
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
                    // Monthly expenses section
                    monthlyExpensesSection
                    
                    // Trend chart section
                    trendChartSection
                    
                    // Upcoming renewals section
                    upcomingRenewalsSection
                }
                .padding()
                .padding(.top, -8)
            }
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
                    // Refresh data when sheet is dismissed
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
    
    // MARK: - View Components
    
    private var monthlyExpensesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(L10n.Dashboard.monthlyExpenses)
                .font(.headline)
            
            if viewModel.monthlyExpenses.isEmpty {
                Text(L10n.Dashboard.noSubscriptions)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                VStack(spacing: 8) {
                    ForEach(Array(viewModel.monthlyExpenses.keys.sorted()), id: \.self) { currency in
                        if let amount = viewModel.monthlyExpenses[currency] {
                            HStack {
                                Text(currency)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text(CurrencyFormatter.format(amount: amount, currency: currency))
                                    .font(.title2)
                                    .fontWeight(.semibold)
                            }
                        }
                    }
                }
                .padding()
                .background(Color(.secondarySystemGroupedBackground))
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
            }
        }
    }
    
    private var trendChartSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(L10n.Dashboard.trend)
                .font(.headline)
            
            if viewModel.trendData.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary)
                    Text(L10n.Dashboard.noTrendData)
                        .font(.headline)
                        .foregroundColor(.secondary)
                    Text(L10n.Dashboard.noTrendHint)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(height: 200)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(.secondarySystemGroupedBackground))
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
            } else {
                TrendChart(trendData: viewModel.trendData)
                    .padding()
                    .background(Color(.secondarySystemGroupedBackground))
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
            }
        }
    }
    
    private var upcomingRenewalsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(L10n.Dashboard.upcomingRenewals)
                .font(.headline)
            
            if viewModel.upcomingRenewals.isEmpty {
                Text(L10n.Dashboard.noUpcoming)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                VStack(spacing: 8) {
                    ForEach(viewModel.upcomingRenewals) { subscription in
                        ZStack {
                            NavigationLink(destination: SubscriptionDetailView(subscription: subscription, modelContext: modelContext)) {
                                EmptyView()
                            }
                            .opacity(0)
                            
                            SubscriptionCard(
                                subscription: subscription,
                                onEdit: {},
                                onArchive: {},
                                onDelete: {}
                            )
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Subscription.self, Category.self, UserSettings.self, configurations: config)
    
    return DashboardView(modelContext: container.mainContext)
}
