//
//  CategoryManagementView.swift
//  subscription-tracker
//
//  Created by Kiro on 2026/2/24.
//

import SwiftUI
import SwiftData

/// Category management view with CRUD operations
struct CategoryManagementView: View {
    
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel: CategoryViewModel
    @Query private var categories: [Category]
    
    @State private var showAddCategory = false
    @State private var editingCategory: Category?
    @State private var showDeleteConfirmation = false
    @State private var categoryToDelete: Category?
    @State private var toast: Toast?
    
    init(modelContext: ModelContext) {
        let categoryService = CategoryService(modelContext: modelContext)
        _viewModel = StateObject(wrappedValue: CategoryViewModel(categoryService: categoryService))
    }
    
    var body: some View {
        NavigationStack {
            List {
                if categories.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "folder")
                            .font(.system(size: 60))
                            .foregroundColor(.secondary)
                        Text(L10n.Category.empty)
                            .font(.headline)
                            .foregroundColor(.secondary)
                        Text(L10n.Category.emptyHint)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .listRowBackground(Color.clear)
                } else {
                    ForEach(categories) { category in
                        CategoryRow(category: category)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                editingCategory = category
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button(role: .destructive) {
                                    categoryToDelete = category
                                    showDeleteConfirmation = true
                                } label: {
                                    Label(L10n.Common.delete, systemImage: "trash")
                                }
                            }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .padding(.top, -20)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showAddCategory = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAddCategory) {
                AddEditCategoryView(modelContext: modelContext)
            }
            .sheet(item: $editingCategory) { category in
                AddEditCategoryView(category: category, modelContext: modelContext)
            }
            .alert(L10n.Category.deleteConfirmTitle, isPresented: $showDeleteConfirmation) {
                Button(L10n.Common.cancel, role: .cancel) { }
                Button(L10n.Common.delete, role: .destructive) {
                    if let category = categoryToDelete {
                        Task {
                            await deleteCategory(category)
                        }
                    }
                }
            } message: {
                Text(L10n.Category.deleteConfirmMessage)
            }
        }
        .toast($toast)
    }
    
    // MARK: - Actions
    
    private func deleteCategory(_ category: Category) async {
        do {
            try await viewModel.delete(category)
            toast = .success(L10n.Category.deleteSuccess)
        } catch {
            toast = .error(L10n.Category.deleteFailed(error.localizedDescription))
        }
    }
}

// MARK: - Category Row

private struct CategoryRow: View {
    let category: Category
    @Query private var subscriptions: [Subscription]
    
    var subscriptionCount: Int {
        subscriptions.filter { $0.category?.id == category.id }.count
    }
    
    var body: some View {
        HStack(spacing: 16) {
            HStack(spacing: 12) {
                // Color indicator - vertical bar
                Rectangle()
                    .fill(category.color)
                    .frame(width: 4, height: 44)
                    .cornerRadius(2)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(category.name)
                        .font(.headline)
                    
                    if let description = category.categoryDescription {
                        Text(description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                    
                    Text(L10n.Category.subscriptionCount(subscriptionCount))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Add/Edit Category View

struct AddEditCategoryView: View {
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: CategoryViewModel
    
    @State private var name: String
    @State private var description: String
    @State private var selectedColorHex: String
    @State private var showPaywall = false
    @State private var toast: Toast?
    
    let isEditMode: Bool
    let category: Category?
    
    init(category: Category? = nil, modelContext: ModelContext) {
        self.category = category
        self.isEditMode = category != nil
        
        let categoryService = CategoryService(modelContext: modelContext)
        _viewModel = StateObject(wrappedValue: CategoryViewModel(categoryService: categoryService))
        
        _name = State(initialValue: category?.name ?? "")
        _description = State(initialValue: category?.categoryDescription ?? "")
        _selectedColorHex = State(initialValue: category?.colorHex ?? "#007AFF")
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section(L10n.Category.sectionBasic) {
                    TextField(L10n.Category.namePlaceholder, text: $name)
                    TextField(L10n.Category.descriptionPlaceholder, text: $description)
                }
                
                Section(L10n.Category.sectionColor) {
                    ColorPickerView(selectedColorHex: $selectedColorHex)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(L10n.Common.cancel) {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button(L10n.Common.save) {
                        Task {
                            await saveCategory()
                        }
                    }
                    .disabled(name.isEmpty)
                }
            }
            .sheet(isPresented: $showPaywall) {
                PaywallView()
            }
        }
        .toast($toast)
    }
    
    private func saveCategory() async {
        do {
            if isEditMode, let category = category {
                // Update existing category
                category.name = name
                category.categoryDescription = description.isEmpty ? nil : description
                category.colorHex = selectedColorHex
                
                try await viewModel.update(category)
                toast = .success(L10n.Category.saveSuccess)
            } else {
                // Create new category
                let newCategory = Category(
                    name: name,
                    description: description.isEmpty ? nil : description,
                    colorHex: selectedColorHex
                )
                
                let success = try await viewModel.create(newCategory)
                if success {
                    toast = .success(L10n.Category.createSuccess)
                } else {
                    showPaywall = true
                    return
                }
            }
            
            try? await Task.sleep(nanoseconds: 500_000_000)
            dismiss()
        } catch AppError.categoryLimitReached {
            showPaywall = true
        } catch {
            toast = .error(L10n.Category.saveFailed(error.localizedDescription))
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Subscription.self, Category.self, UserSettings.self, configurations: config)
    
    return CategoryManagementView(modelContext: container.mainContext)
}

