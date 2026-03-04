//
//  AddEditSubscriptionViewModel.swift
//  subscription-tracker
//
//  Created by Kiro on 2026/2/24.
//

import Foundation
import SwiftUI
import SwiftData
import Combine

/// ViewModel for adding or editing subscriptions with validation and save logic
@MainActor
class AddEditSubscriptionViewModel: ObservableObject {

    // MARK: - Published Properties

    /// The subscription being created or edited
    @Published var subscription: Subscription

    /// Validation errors keyed by field name
    @Published var validationErrors: [String: String] = [:]

    /// Saving state indicator
    @Published var isSaving = false

    // MARK: - Properties

    /// Whether this is edit mode (true) or create mode (false)
    let isEditMode: Bool

    // MARK: - Dependencies

    private let subscriptionService: SubscriptionService
    private let paywallService: PaywallService

    // MARK: - Initialization

    /// Initialize ViewModel for creating or editing a subscription
    /// - Parameters:
    ///   - subscription: Existing subscription for edit mode, nil for create mode
    ///   - template: App template to pre-fill name/icon (create mode only)
    ///   - subscriptionService: Service for subscription operations
    ///   - paywallService: Service for checking free user limits
    ///   - defaultCurrency: Default currency from user settings
    init(
        subscription: Subscription? = nil,
        template: AppTemplate? = nil,
        subscriptionService: SubscriptionService,
        paywallService: PaywallService? = nil,
        defaultCurrency: String = "USD"
    ) {
        self.isEditMode = subscription != nil
        self.subscriptionService = subscriptionService
        self.paywallService = paywallService ?? PaywallService.shared

        // Use existing subscription or create new one with defaults
        if let existingSubscription = subscription {
            self.subscription = existingSubscription
        } else {
            // Create new subscription with default values, pre-fill from template if provided
            self.subscription = Subscription(
                name: template?.name ?? "",
                description: nil,
                category: nil,
                firstPaymentDate: Date(),
                billingCycle: 1,
                billingCycleUnit: .month,
                amount: 0,
                currency: defaultCurrency,
                notify: true,
                notifyDaysBefore: 1,
                archived: false
            )
            if let iconURL = template?.iconURL {
                self.subscription.iconURL = iconURL
            }
        }
    }

    // MARK: - Validation

    /// Validate subscription form data
    /// - Returns: True if all validation passes, false otherwise
    func validate() -> Bool {
        validationErrors.removeAll()

        // Validate name
        if subscription.name.trimmingCharacters(in: .whitespaces).isEmpty {
            validationErrors["name"] = L10n.Validation.nameEmpty
        } else if subscription.name.count > 50 {
            validationErrors["name"] = L10n.Validation.nameTooLong
        }

        // Validate amount
        if subscription.amount <= 0 {
            validationErrors["amount"] = L10n.Validation.amountInvalid
        }

        // Validate billing cycle
        if subscription.billingCycle <= 0 {
            validationErrors["billingCycle"] = L10n.Validation.billingCycleInvalid
        }

        // Validate first payment date (should not be in future for new subscriptions)
        if !isEditMode && subscription.firstPaymentDate > Date() {
            validationErrors["firstPaymentDate"] = L10n.Validation.firstPaymentFuture
        }

        // Validate currency
        let supportedCurrencies = ["USD", "CNY", "EUR", "GBP", "JPY", "HKD", "TWD"]
        if !supportedCurrencies.contains(subscription.currency) {
            validationErrors["currency"] = L10n.Validation.currencyUnsupported
        }

        // Validate notify days before
        if subscription.notify && subscription.notifyDaysBefore <= 0 {
            validationErrors["notifyDaysBefore"] = L10n.Validation.notifyDaysInvalid
        }

        return validationErrors.isEmpty
    }

    // MARK: - Save Logic

    /// Save the subscription (create or update)
    /// - Throws: AppError if validation fails, limit reached, or save fails
    func save() async throws {
        // Validate first
        guard validate() else {
            throw AppError.invalidData(field: validationErrors.keys.first ?? "unknown")
        }

        isSaving = true
        defer { isSaving = false }

        if isEditMode {
            // Update existing subscription
            try await subscriptionService.updateSubscription(subscription)
        } else {
            // Create new subscription with free user limit check
            let activeCount = subscriptionService.fetchActiveSubscriptions().count
            guard paywallService.canCreateSubscription(currentCount: activeCount) else {
                throw AppError.subscriptionLimitReached
            }

            _ = try await subscriptionService.createSubscription(subscription)
        }
    }
}
