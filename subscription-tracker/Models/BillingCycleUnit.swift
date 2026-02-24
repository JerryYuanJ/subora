//
//  BillingCycleUnit.swift
//  subscription-tracker
//
//  Created by Kiro on 2026/2/24.
//

import Foundation

enum BillingCycleUnit: String, Codable, CaseIterable {
    case day = "day"
    case week = "week"
    case month = "month"
    case year = "year"
    
    var displayName: String {
        switch self {
        case .day:
            return L10n.BillingCycle.day
        case .week:
            return L10n.BillingCycle.week
        case .month:
            return L10n.BillingCycle.month
        case .year:
            return L10n.BillingCycle.year
        }
    }
}
