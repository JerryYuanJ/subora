//
//  AddEditSubscriptionView.swift
//  subscription-tracker
//
//  Created by Kiro on 2026/2/24.
//

import SwiftUI
import SwiftData

/// View for adding or editing a subscription
struct AddEditSubscriptionView: View {
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: AddEditSubscriptionViewModel
    @Query private var categories: [Category]
    
    @State private var showPaywall = false
    @State private var toast: Toast?
    
    init(subscription: Subscription? = nil, modelContext: ModelContext) {
        let subscriptionService = SubscriptionService(modelContext: modelContext)
        _viewModel = StateObject(wrappedValue: AddEditSubscriptionViewModel(
            subscription: subscription,
            subscriptionService: subscriptionService
        ))
    }
    
    var body: some View {
        NavigationStack {
            Form {
                // Basic info section
                Section(L10n.Subscription.sectionBasic) {
                    TextField(L10n.Subscription.namePlaceholder, text: $viewModel.subscription.name)
                    TextField(L10n.Subscription.descriptionPlaceholder, text: Binding(
                        get: { viewModel.subscription.subscriptionDescription ?? "" },
                        set: { viewModel.subscription.subscriptionDescription = $0.isEmpty ? nil : $0 }
                    ))
                    
                    if let error = viewModel.validationErrors["name"] {
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
                
                // Category section
                Section(L10n.Subscription.sectionCategory) {
                    Picker(L10n.Subscription.categoryPicker, selection: $viewModel.subscription.category) {
                        Text(L10n.Subscription.noCategory).tag(nil as Category?)
                        ForEach(categories) { category in
                            HStack {
                                Circle()
                                    .fill(category.color)
                                    .frame(width: 12, height: 12)
                                Text(category.name)
                            }
                            .tag(category as Category?)
                        }
                    }
                }
                
                // Billing info section
                Section(L10n.Subscription.sectionBilling) {
                    DatePicker(
                        L10n.Subscription.firstPaymentDate,
                        selection: $viewModel.subscription.firstPaymentDate,
                        displayedComponents: .date
                    )
                    
                    BillingCyclePicker(
                        cycle: $viewModel.subscription.billingCycle,
                        unit: $viewModel.subscription.billingCycleUnit
                    )
                    
                    HStack {
                        Text(L10n.Subscription.amount)
                        Spacer()
                        TextField(L10n.Subscription.amountPlaceholder, value: Binding(
                            get: { Double(truncating: viewModel.subscription.amount as NSNumber) },
                            set: { viewModel.subscription.amount = Decimal($0) }
                        ), format: .number)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 100)
                    }
                    
                    CurrencyPicker(selectedCurrency: $viewModel.subscription.currency)
                    
                    if let error = viewModel.validationErrors["amount"] {
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
                
                // Notification section
                Section(L10n.Subscription.sectionNotification) {
                    Toggle(L10n.Subscription.enableNotification, isOn: $viewModel.subscription.notify)
                    
                    if viewModel.subscription.notify {
                        Stepper(value: $viewModel.subscription.notifyDaysBefore, in: 1...30) {
                            Text(L10n.Subscription.notifyDaysBefore(viewModel.subscription.notifyDaysBefore))
                        }
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(L10n.Subscription.buttonCancel) {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button(L10n.Subscription.buttonSave) {
                        Task {
                            await saveSubscription()
                        }
                    }
                    .disabled(viewModel.isSaving)
                }
            }
            .overlay {
                if viewModel.isSaving {
                    LoadingOverlay(message: L10n.Loading.saving)
                }
            }
            .sheet(isPresented: $showPaywall) {
                PaywallView()
            }
            .toast($toast)
        }
    }
    
    // MARK: - Actions
    
    private func saveSubscription() async {
        do {
            try await viewModel.save()
            toast = .success(L10n.Toast.saveSuccess)
            
            // Dismiss after a short delay
            try? await Task.sleep(nanoseconds: 500_000_000)
            dismiss()
        } catch AppError.subscriptionLimitReached {
            showPaywall = true
        } catch {
            toast = .error(error.localizedDescription)
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Subscription.self, Category.self, UserSettings.self, configurations: config)
    
    return AddEditSubscriptionView(modelContext: container.mainContext)
        .environmentObject(PaywallService.shared)
}
