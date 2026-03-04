//
//  SubscriptionListViewModel.swift
//  subscription-tracker
//
//  Created by Kiro on 2026/2/24.
//

import Foundation
import SwiftUI
import SwiftData
import Combine

/// ViewModel for managing subscription list display, search, and filtering
@MainActor
class SubscriptionListViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    /// All subscriptions (active or archived based on showArchived)
    @Published var subscriptions: [Subscription] = []
    
    /// Filtered subscriptions after applying search and category filters
    @Published var filteredSubscriptions: [Subscription] = []
    
    /// Current search query
    @Published var searchQuery = "" {
        didSet {
            applyFilters()
        }
    }
    
    /// Selected category for filtering (nil means show all)
    @Published var selectedCategory: Category? {
        didSet {
            applyFilters()
        }
    }
    
    /// Whether to show archived subscriptions
    @Published var showArchived = false {
        didSet {
            loadSubscriptions()
        }
    }
    
    // MARK: - Dependencies
    
    let subscriptionService: SubscriptionService
    
    // MARK: - Initialization
    
    init(subscriptionService: SubscriptionService) {
        self.subscriptionService = subscriptionService
    }
    
    // MARK: - Public Methods
    
    /// Load subscriptions based on archived status
    func loadSubscriptions() {
        if showArchived {
            subscriptions = subscriptionService.fetchArchivedSubscriptions()
        } else {
            subscriptions = subscriptionService.fetchActiveSubscriptions()
        }
        applyFilters()
    }
    
    /// Apply search and category filters, then sort by next billing date
    func applyFilters() {
        var result = subscriptions
        
        // Apply search filter
        if !searchQuery.isEmpty {
            let lowercasedQuery = searchQuery.lowercased()
            result = result.filter { subscription in
                subscription.name.lowercased().contains(lowercasedQuery) ||
                (subscription.subscriptionDescription?.lowercased().contains(lowercasedQuery) ?? false)
            }
        }
        
        // Apply category filter
        if let category = selectedCategory {
            result = result.filter { $0.category?.id == category.id }
        }
        
        // Sort by next billing date (ascending)
        result.sort { $0.nextBillingDate < $1.nextBillingDate }
        
        filteredSubscriptions = result
    }
}
