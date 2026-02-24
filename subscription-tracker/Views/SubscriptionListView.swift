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
                // Subscription list
                subscriptionList
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Menu {
                        Button {
                            viewModel.selectedCategory = nil
                            viewModel.applyFilters()
                        } label: {
                            HStack {
                                Text(L10n.Subscriptions.filterAll)
                                if viewModel.selectedCategory == nil {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                        
                        ForEach(categories) { category in
                            Button {
                                viewModel.selectedCategory = category
                                viewModel.applyFilters()
                            } label: {
                                HStack {
                                    Text(category.name)
                                    if viewModel.selectedCategory?.id == category.id {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Text(viewModel.selectedCategory?.name ?? L10n.Subscriptions.filterAll)
                                .font(.headline)
                            Image(systemName: "chevron.down")
                                .font(.caption)
                        }
                    }
                }
                
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
