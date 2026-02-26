//
//  PaywallService.swift
//  subscription-tracker
//
//  Created by Kiro on 2026/2/24.
//

import Foundation
import SwiftUI
import Combine
import StoreKit

/// Subscription plan type
enum SubscriptionPlan: String, CaseIterable {
    case monthly = "premium_monthly"
    case yearly = "premium_yearly"
    
    var displayName: String {
        switch self {
        case .monthly:
            return L10n.Paywall.planMonthly
        case .yearly:
            return L10n.Paywall.planYearly
        }
    }
    
    var duration: String {
        switch self {
        case .monthly:
            return L10n.Paywall.planMonthlyDuration
        case .yearly:
            return L10n.Paywall.planYearlyDuration
        }
    }
}

/// Service for managing free/Pro user limits and StoreKit purchases
class PaywallService: ObservableObject {
    
    // MARK: - Singleton
    
    static let shared = PaywallService()
    
    // MARK: - Published Properties
    
    @Published var isProUser: Bool = false
    @Published var availableProducts: [Product] = []
    @Published var isLoadingProducts: Bool = false
    
    // MARK: - Constants
    
    private let freeSubscriptionLimit = 5
    private let freeCategoryLimit = 5
    
    private let productIDs: [String] = [
        SubscriptionPlan.monthly.rawValue,
        SubscriptionPlan.yearly.rawValue
    ]
    
    private init() {
        // Load Pro status from UserDefaults
        self.isProUser = UserDefaults.standard.bool(forKey: "isProUser")
        
        // Start listening for transaction updates
        Task {
            await observeTransactionUpdates()
        }
    }
    
    // MARK: - Limit Checks
    
    /// Check if user can create a new subscription
    /// - Parameter currentCount: Current number of active subscriptions
    /// - Returns: True if user can create subscription, false otherwise
    func canCreateSubscription(currentCount: Int) -> Bool {
        #if DEBUG
        return true  // 开发模式下无限制
        #else
        if isProUser {
            return true
        }
        return currentCount < freeSubscriptionLimit
        #endif
    }
    
    /// Check if user can create a new category
    /// - Parameter currentCount: Current number of categories
    /// - Returns: True if user can create category, false otherwise
    func canCreateCategory(currentCount: Int) -> Bool {
        #if DEBUG
        return true  // 开发模式下无限制
        #else
        if isProUser {
            return true
        }
        return currentCount < freeCategoryLimit
        #endif
    }
    
    // MARK: - Product Loading
    
    /// Load available products from App Store
    @MainActor
    func loadProducts() async {
        isLoadingProducts = true
        defer { isLoadingProducts = false }
        
        #if DEBUG
        // In development, if products can't be loaded, use mock data
        do {
            let products = try await Product.products(for: productIDs)
            if products.isEmpty {
                print("⚠️ No products loaded from App Store, using mock data for development")
                // Products will remain empty, UI will handle this
            } else {
                availableProducts = products.sorted { product1, product2 in
                    if let plan1 = SubscriptionPlan(rawValue: product1.id),
                       let plan2 = SubscriptionPlan(rawValue: product2.id) {
                        return plan1 == .monthly && plan2 == .yearly
                    }
                    return false
                }
                print("✅ Loaded \(products.count) products from App Store")
            }
        } catch {
            print("⚠️ Failed to load products: \(error.localizedDescription)")
            print("💡 This is expected in development before configuring App Store Connect")
            // Products will remain empty
        }
        #else
        // In production, load products normally
        do {
            let products = try await Product.products(for: productIDs)
            availableProducts = products.sorted { product1, product2 in
                if let plan1 = SubscriptionPlan(rawValue: product1.id),
                   let plan2 = SubscriptionPlan(rawValue: product2.id) {
                    return plan1 == .monthly && plan2 == .yearly
                }
                return false
            }
        } catch {
            print("❌ Failed to load products: \(error)")
            availableProducts = []
        }
        #endif
    }
    
    // MARK: - Purchase Management
    
    /// Purchase a specific product
    /// - Parameter product: The product to purchase
    /// - Returns: True if purchase succeeded, false otherwise
    @MainActor
    func purchase(_ product: Product) async throws -> Bool {
        let result = try await product.purchase()
        
        switch result {
        case .success(let verification):
            // Verify the transaction
            let transaction = try checkVerified(verification)
            
            // Update Pro status
            await updateProStatus()
            
            // Finish the transaction
            await transaction.finish()
            
            return true
            
        case .userCancelled:
            return false
            
        case .pending:
            return false
            
        @unknown default:
            return false
        }
    }
    
    /// Restore previous purchases
    /// - Returns: True if restore succeeded, false otherwise
    @MainActor
    func restorePurchases() async throws -> Bool {
        try await AppStore.sync()
        await updateProStatus()
        return isProUser
    }
    
    /// Check and update Pro status based on active subscriptions
    @MainActor
    func updateProStatus() async {
        var hasActiveSubscription = false
        
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result {
                if productIDs.contains(transaction.productID) {
                    hasActiveSubscription = true
                    break
                }
            }
        }
        
        isProUser = hasActiveSubscription
        UserDefaults.standard.set(hasActiveSubscription, forKey: "isProUser")
    }
    
    // MARK: - Transaction Observation
    
    /// Observe transaction updates
    private func observeTransactionUpdates() async {
        for await result in Transaction.updates {
            if case .verified(let transaction) = result {
                await transaction.finish()
                await updateProStatus()
            }
        }
    }
    
    // MARK: - Verification
    
    /// Verify a transaction
    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.failedVerification
        case .verified(let safe):
            return safe
        }
    }
}

// MARK: - Store Errors

enum StoreError: Error {
    case failedVerification
}
