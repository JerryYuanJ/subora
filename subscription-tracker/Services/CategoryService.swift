//
//  CategoryService.swift
//  subscription-tracker
//
//  Created by Kiro on 2026/2/24.
//

import Foundation
import SwiftData

/// Service for managing category operations with free user limit checks
@MainActor
class CategoryService {
    
    // MARK: - Properties
    
    private let modelContext: ModelContext
    private let paywallService: PaywallService
    
    // MARK: - Initialization
    
    init(modelContext: ModelContext, paywallService: PaywallService? = nil) {
        self.modelContext = modelContext
        self.paywallService = paywallService ?? PaywallService.shared
    }
    
    // MARK: - Create
    
    /// Create a new category with free user limit check
    /// - Parameter category: The category to create
    /// - Returns: True if creation succeeded, false if limit reached
    /// - Throws: AppError if creation fails
    func createCategory(_ category: Category) async throws -> Bool {
        // Check free user limit
        let currentCount = fetchAllCategories().count
        guard paywallService.canCreateCategory(currentCount: currentCount) else {
            throw AppError.categoryLimitReached
        }
        
        // Insert category
        modelContext.insert(category)
        
        // Save context
        try modelContext.save()
        
        return true
    }
    
    // MARK: - Update
    
    /// Update an existing category
    /// - Parameter category: The category to update
    /// - Throws: AppError if update fails
    func updateCategory(_ category: Category) async throws {
        // SwiftData automatically tracks changes, just save
        try modelContext.save()
    }
    
    // MARK: - Delete
    
    /// Delete a category and set category to nil for all associated subscriptions
    /// - Parameter category: The category to delete
    /// - Throws: AppError if deletion fails
    func deleteCategory(_ category: Category) async throws {
        // SwiftData's deleteRule: .nullify automatically handles setting
        // category to nil for associated subscriptions
        modelContext.delete(category)
        
        // Save context
        try modelContext.save()
    }
    
    // MARK: - Query
    
    /// Fetch all categories
    /// - Returns: Array of all categories
    func fetchAllCategories() -> [Category] {
        let descriptor = FetchDescriptor<Category>(
            sortBy: [SortDescriptor(\.createdAt, order: .forward)]
        )
        
        do {
            return try modelContext.fetch(descriptor)
        } catch {
            print("Failed to fetch categories: \(error)")
            return []
        }
    }
}
