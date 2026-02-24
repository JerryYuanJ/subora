//
//  Subscription.swift
//  subscription-tracker
//
//  Created by Kiro on 2026/2/24.
//

import Foundation
import SwiftData

@Model
final class Subscription {
    @Attribute(.unique) var id: UUID
    var name: String
    var subscriptionDescription: String?
    var category: Category?
    var firstPaymentDate: Date
    var billingCycle: Int
    var billingCycleUnit: BillingCycleUnit
    var amount: Decimal
    var currency: String
    var notify: Bool
    var notifyDaysBefore: Int
    var lastNotifiedDate: Date?
    var archived: Bool
    var createdAt: Date
    var updatedAt: Date
    
    init(
        id: UUID = UUID(),
        name: String,
        description: String? = nil,
        category: Category? = nil,
        firstPaymentDate: Date,
        billingCycle: Int,
        billingCycleUnit: BillingCycleUnit,
        amount: Decimal,
        currency: String,
        notify: Bool = true,
        notifyDaysBefore: Int = 3,
        archived: Bool = false
    ) {
        self.id = id
        self.name = name
        self.subscriptionDescription = description
        self.category = category
        self.firstPaymentDate = firstPaymentDate
        self.billingCycle = billingCycle
        self.billingCycleUnit = billingCycleUnit
        self.amount = amount
        self.currency = currency
        self.notify = notify
        self.notifyDaysBefore = notifyDaysBefore
        self.archived = archived
        self.createdAt = Date()
        self.updatedAt = Date()
    }
    
    // MARK: - Computed Properties
    
    /// 计算下次续费日期
    var nextBillingDate: Date {
        BillingCalculator.calculateNextBillingDate(
            from: firstPaymentDate,
            cycle: billingCycle,
            unit: billingCycleUnit
        )
    }
    
    /// 计算月度等效金额
    var monthlyEquivalent: Decimal {
        BillingCalculator.convertToMonthlyAmount(
            amount: amount,
            cycle: billingCycle,
            unit: billingCycleUnit
        )
    }
}
