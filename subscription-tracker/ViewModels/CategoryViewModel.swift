//
//  CategoryViewModel.swift
//  subscription-tracker
//
//  Created by Kiro on 2026/2/24.
//

import Foundation
import SwiftUI
import Combine

/// ViewModel for category management, handling CRUD operations and category list
@MainActor
class CategoryViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    /// List of all categories
    @Published var categories: [Category] = []
    
    /// Loading state indicator
    @Published var isLoading = false
    
    /// Error message for display
    @Published var errorMessage: String?
    
    // MARK: - Dependencies
    
    private let categoryService: CategoryService
    
    // MARK: - Initialization
    
    init(categoryService: CategoryService) {
        self.categoryService = categoryService
    }
    
    // MARK: - Data Loading
    
    /// Load all categories
    func loadCategories() {
        isLoading = true
        defer { isLoading = false }
        
        categories = categoryService.fetchAllCategories()
    }
    
    // MARK: - CRUD Operations
    
    /// Create a new category
    /// - Parameter category: The category to create
    /// - Returns: True if creation succeeded, false if limit reached
    /// - Throws: AppError if creation fails
    @discardableResult
    func create(_ category: Category) async throws -> Bool {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let success = try await categoryService.createCategory(category)
            if success {
                // Reload categories after successful creation
                loadCategories()
            }
            return success
        } catch let error as AppError {
            errorMessage = error.errorDescription
            throw error
        } catch {
            errorMessage = L10n.VMError.createCategoryFailed
            throw error
        }
    }
    
    /// Update an existing category
    /// - Parameter category: The category to update
    /// - Throws: AppError if update fails
    func update(_ category: Category) async throws {
        isLoading = true
        defer { isLoading = false }
        
        do {
            try await categoryService.updateCategory(category)
            // Reload categories after successful update
            loadCategories()
        } catch {
            errorMessage = L10n.VMError.updateCategoryFailed
            throw error
        }
    }
    
    /// Delete a category
    /// - Parameter category: The category to delete
    /// - Throws: AppError if deletion fails
    func delete(_ category: Category) async throws {
        isLoading = true
        defer { isLoading = false }
        
        do {
            try await categoryService.deleteCategory(category)
            // Reload categories after successful deletion
            loadCategories()
        } catch {
            errorMessage = L10n.VMError.deleteCategoryFailed
            throw error
        }
    }
    
    // MARK: - Helper Methods
    
    /// Clear error message
    func clearError() {
        errorMessage = nil
    }
}
