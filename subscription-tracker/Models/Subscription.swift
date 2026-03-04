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
    var id: UUID = UUID()
    var name: String = ""
    var subscriptionDescription: String?
    var iconURL: String?  // App icon URL
    var category: Category?
    var firstPaymentDate: Date = Date()
    var billingCycle: Int = 1
    var billingCycleUnitRawValue: String = "month"  // 存储原始值
    var amount: Decimal = 0
    var currency: String = "USD"
    var notify: Bool = true
    var notifyDaysBefore: Int = 1
    var lastNotifiedDate: Date?
    var archived: Bool = false
    var createdAt: Date = Date()
    var updatedAt: Date = Date()
    
    // 计算属性来访问枚举
    var billingCycleUnit: BillingCycleUnit {
        get { BillingCycleUnit(rawValue: billingCycleUnitRawValue) ?? .month }
        set { billingCycleUnitRawValue = newValue.rawValue }
    }
    
    init(
        id: UUID = UUID(),
        name: String,
        description: String? = nil,
        iconURL: String? = nil,
        category: Category? = nil,
        firstPaymentDate: Date,
        billingCycle: Int,
        billingCycleUnit: BillingCycleUnit,
        amount: Decimal,
        currency: String,
        notify: Bool = true,
        notifyDaysBefore: Int = 1,
        archived: Bool = false
    ) {
        self.id = id
        self.name = name
        self.subscriptionDescription = description
        self.iconURL = iconURL
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
    
    // 提供一个无参数的初始化器供 SwiftData 使用
    init() {
        self.id = UUID()
        self.name = ""
        self.firstPaymentDate = Date()
        self.billingCycle = 1
        self.billingCycleUnit = .month
        self.amount = 0
        self.currency = "USD"
        self.notify = true
        self.notifyDaysBefore = 1
        self.archived = false
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
