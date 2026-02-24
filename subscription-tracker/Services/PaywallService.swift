//
//  PaywallService.swift
//  subscription-tracker
//
//  Created by Kiro on 2026/2/24.
//

import Foundation
import SwiftUI
import Combine

/// Service for managing free/Pro user limits and StoreKit purchases
class PaywallService: ObservableObject {
    
    // MARK: - Singleton
    
    static let shared = PaywallService()
    
    // MARK: - Published Properties
    
    @Published var isProUser: Bool = false
    
    // MARK: - Constants
    
    private let freeSubscriptionLimit = 3
    private let freeCategoryLimit = 3
    
    private init() {
        // Load Pro status from UserDefaults
        self.isProUser = UserDefaults.standard.bool(forKey: "isProUser")
    }
    
    // MARK: - Limit Checks
    
    /// Check if user can create a new subscription
    /// - Parameter currentCount: Current number of active subscriptions
    /// - Returns: True if user can create subscription, false otherwise
    func canCreateSubscription(currentCount: Int) -> Bool {
        if isProUser {
            return true
        }
        return currentCount < freeSubscriptionLimit
    }
    
    /// Check if user can create a new category
    /// - Parameter currentCount: Current number of categories
    /// - Returns: True if user can create category, false otherwise
    func canCreateCategory(currentCount: Int) -> Bool {
        if isProUser {
            return true
        }
        return currentCount < freeCategoryLimit
    }
    
    // MARK: - Purchase Management
    
    /// Purchase Pro version (placeholder for StoreKit integration)
    /// - Returns: True if purchase succeeded, false otherwise
    @MainActor
    func purchaseProVersion() async throws -> Bool {
        // TODO: Implement StoreKit purchase flow
        // For now, just simulate success
        isProUser = true
        UserDefaults.standard.set(true, forKey: "isProUser")
        return true
    }
    
    /// Restore previous purchases (placeholder for StoreKit integration)
    /// - Returns: True if restore succeeded, false otherwise
    @MainActor
    func restorePurchases() async throws -> Bool {
        // TODO: Implement StoreKit restore flow
        return false
    }
    
    /// Check purchase status from StoreKit (placeholder)
    func checkPurchaseStatus() async {
        // TODO: Implement StoreKit status check
    }
}
