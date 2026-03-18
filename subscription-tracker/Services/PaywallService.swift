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
import WidgetKit

/// Lifetime product identifier
let lifetimeProductID = "com.subora.lifetime.pro"

/// Service for managing free/Pro user limits and StoreKit purchases
class PaywallService: ObservableObject {
    
    // MARK: - Singleton
    
    static let shared = PaywallService()
    
    // MARK: - Published Properties
    
    @Published var isProUser: Bool = false {
        didSet {
            print("📝 isProUser didSet triggered: oldValue=\(oldValue), newValue=\(isProUser)")
            guard oldValue != isProUser else {
                print("⚠️ isProUser value unchanged, skipping update")
                return
            }
            print("💾 Saving Pro status to UserDefaults and Widget...")
            UserDefaults.standard.set(isProUser, forKey: "isProUser")
            WidgetDataStore.saveProStatus(isProUser)
            // Also patch the WidgetData JSON so widget reads correct Pro status
            let current = WidgetDataStore.load()
            let updated = WidgetData(
                subscriptions: current.subscriptions,
                monthlyTotalsByCurrency: current.monthlyTotalsByCurrency,
                isProUser: isProUser,
                themeColorHex: current.themeColorHex,
                darkMode: current.darkMode,
                lastUpdated: Date()
            )
            WidgetDataStore.save(updated)
            WidgetCenter.shared.reloadAllTimelines()
            print("✅ Pro status saved successfully")
        }
    }
    @Published var availableProducts: [Product] = []
    @Published var isLoadingProducts: Bool = false

    // MARK: - Constants

    private let freeSubscriptionLimit = 5
    private let freeCategoryLimit = 5

    private let productIDs: [String] = [
        lifetimeProductID
    ]

    private init() {
        // Load cached Pro status for immediate UI display
        let savedProStatus = UserDefaults.standard.bool(forKey: "isProUser")
        self.isProUser = savedProStatus
        // Sync to widget on init (didSet won't fire during init)
        WidgetDataStore.saveProStatus(savedProStatus)

        // Verify actual entitlement status on launch (handles expired subscriptions)
        Task {
            await updateProStatus()
        }

        // Listen for future transaction updates
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
        
        do {
            let products = try await Product.products(for: productIDs)
            availableProducts = Array(products)
            print("✅ Loaded \(products.count) products from App Store Connect")
        } catch {
            print("❌ Failed to load products: \(error.localizedDescription)")
            availableProducts = []
        }
    }
    
    // MARK: - Purchase Management
    
    /// Purchase a specific product
    /// - Parameter product: The product to purchase
    /// - Returns: True if purchase succeeded, false otherwise
    @MainActor
    func purchase(_ product: Product) async throws -> Bool {
        print("🛒 Starting purchase for: \(product.id)")
        let result = try await product.purchase()
        
        switch result {
        case .success(let verification):
            print("✅ Purchase successful, verifying transaction...")
            // Verify the transaction
            let transaction = try checkVerified(verification)
            print("✅ Transaction verified: \(transaction.productID)")
            
            // Finish the transaction first
            await transaction.finish()
            print("✅ Transaction finished")
            
            // Update Pro status from entitlements
            await updateProStatus()
            
            // IMPORTANT: In sandbox environment, Transaction.currentEntitlements may not
            // immediately reflect the new purchase. If updateProStatus didn't find the
            // subscription but we just verified it, manually set Pro status.
            if !isProUser && productIDs.contains(transaction.productID) {
                print("⚠️ Entitlements not updated yet, manually setting Pro status")
                isProUser = true
            }
            
            return true
            
        case .userCancelled:
            print("❌ Purchase cancelled by user")
            return false
            
        case .pending:
            print("⏳ Purchase pending")
            return false
            
        @unknown default:
            print("❓ Unknown purchase result")
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
    
    /// Check and update Pro status based on lifetime purchase
    @MainActor
    func updateProStatus() async {
        print("🔍 Checking Pro status...")
        var hasPurchase = false

        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result {
                print("✅ Found verified transaction: \(transaction.productID)")
                if productIDs.contains(transaction.productID) {
                    hasPurchase = true
                    print("✅ Lifetime purchase found: \(transaction.productID)")
                    break
                }
            }
        }

        print("🔍 Pro status result: \(hasPurchase)")
        isProUser = hasPurchase
        print("🔍 isProUser updated to: \(isProUser)")
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
