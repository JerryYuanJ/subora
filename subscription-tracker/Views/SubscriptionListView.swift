//
//  SubscriptionListView.swift
//  subscription-tracker
//
//  Created by Kiro on 2026/2/24.
//

import SwiftUI
import SwiftData

/// Subscription list view with search and filtering capabilities
struct SubscriptionListView: View {
    
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel: SubscriptionListViewModel
    @Query private var categories: [Category]
    @State private var showAddSubscription = false
    
    init(modelContext: ModelContext) {
        let subscriptionService = SubscriptionService(modelContext: modelContext)
        _viewModel = StateObject(wrappedValue: SubscriptionListViewModel(subscriptionService: subscriptionService))
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search bar
                searchBar
                
                // Category filters
                categoryFilters
                
                // Subscription list
                subscriptionList
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
                viewModel.loadSubscriptions()
            }
            .onChange(of: showAddSubscription) { _, isPresented in
                if !isPresented {
                    // Refresh data when sheet is dismissed
                    viewModel.loadSubscriptions()
                }
            }
        }
    }
    
    // MARK: - View Components
    
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
            TextField(L10n.Subscriptions.searchPlaceholder, text: $viewModel.searchQuery)
                .textFieldStyle(.plain)
                .onChange(of: viewModel.searchQuery) { _, _ in
                    viewModel.applyFilters()
                }
            
            if !viewModel.searchQuery.isEmpty {
                Button {
                    viewModel.searchQuery = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
        .padding(.horizontal)
        .padding(.top)
    }
    
    private var categoryFilters: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                // All button
                Button {
                    viewModel.selectedCategory = nil
                    viewModel.applyFilters()
                } label: {
                    Text(L10n.Subscriptions.filterAll)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(viewModel.selectedCategory == nil ? Color.blue : Color(.systemGray5))
                        .foregroundColor(viewModel.selectedCategory == nil ? .white : .primary)
                        .cornerRadius(20)
                }
                
                // Category buttons
                ForEach(categories) { category in
                    Button {
                        viewModel.selectedCategory = category
                        viewModel.applyFilters()
                    } label: {
                        CategoryBadge(category: category)
                            .opacity(viewModel.selectedCategory?.id == category.id ? 1.0 : 0.6)
                    }
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 8)
    }
    
    private var subscriptionList: some View {
        Group {
            if viewModel.filteredSubscriptions.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "tray")
                        .font(.system(size: 60))
                        .foregroundColor(.secondary)
                    Text(L10n.Subscriptions.empty)
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(viewModel.filteredSubscriptions) { subscription in
                        ZStack {
                            NavigationLink(destination: SubscriptionDetailView(subscription: subscription, modelContext: modelContext)) {
                                EmptyView()
                            }
                            .opacity(0)
                            
                            SubscriptionCard(
                                subscription: subscription,
                                onEdit: {
                                    // Edit handled in detail view
                                },
                                onArchive: {
                                    Task {
                                        await archiveSubscription(subscription)
                                    }
                                },
                                onDelete: {
                                    Task {
                                        await deleteSubscription(subscription)
                                    }
                                }
                            )
                        }
                        .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                        .listRowSeparator(.hidden)
                    }
                }
                .listStyle(.plain)
            }
        }
    }
    
    // MARK: - Actions
    
    private func archiveSubscription(_ subscription: Subscription) async {
        do {
            let subscriptionService = SubscriptionService(modelContext: modelContext)
            try await subscriptionService.archiveSubscription(subscription)
            viewModel.loadSubscriptions()
        } catch {
            print("Archive failed: \(error)")
        }
    }
    
    private func deleteSubscription(_ subscription: Subscription) async {
        do {
            let subscriptionService = SubscriptionService(modelContext: modelContext)
            try await subscriptionService.deleteSubscription(subscription)
            viewModel.loadSubscriptions()
        } catch {
            print("Delete failed: \(error)")
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Subscription.self, Category.self, UserSettings.self, configurations: config)
    
    return SubscriptionListView(modelContext: container.mainContext)
}
