//
//  Category.swift
//  subscription-tracker
//
//  Created by Kiro on 2026/2/24.
//

import Foundation
import SwiftUI
import SwiftData

@Model
final class Category {
    var id: UUID = UUID()
    var name: String = ""
    var categoryDescription: String?
    var colorHex: String = "#007AFF"
    var createdAt: Date = Date()
    
    @Relationship(deleteRule: .nullify, inverse: \Subscription.category)
    var subscriptions: [Subscription]?
    
    init(
        id: UUID = UUID(),
        name: String,
        description: String? = nil,
        colorHex: String = "#007AFF"
    ) {
        self.id = id
        self.name = name
        self.categoryDescription = description
        self.colorHex = colorHex
        self.createdAt = Date()
    }
    
    var color: Color {
        Color(hex: colorHex)
    }
}
