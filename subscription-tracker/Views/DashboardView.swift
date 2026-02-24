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
                    LoadingOverlay(message: "加载中...")
                }
            }
        }
    }
    
    // MARK: - View Components
    
    private var monthlyExpensesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("本月支出")
                .font(.headline)
            
            if viewModel.monthlyExpenses.isEmpty {
                Text("暂无订阅")
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
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(radius: 2)
            }
        }
    }
    
    private var trendChartSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("支出趋势")
                .font(.headline)
            
            if viewModel.trendData.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary)
                    Text("暂无趋势数据")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    Text("添加订阅后即可查看支出趋势")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(height: 200)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(radius: 2)
            } else {
                TrendChart(trendData: viewModel.trendData)
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .shadow(radius: 2)
            }
        }
    }
    
    private var upcomingRenewalsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("即将到期 (30天内)")
                .font(.headline)
            
            if viewModel.upcomingRenewals.isEmpty {
                Text("暂无即将到期的订阅")
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
