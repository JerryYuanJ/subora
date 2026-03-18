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
    @EnvironmentObject private var paywallService: PaywallService
    @StateObject private var viewModel: AddEditSubscriptionViewModel
    @Query private var categories: [Category]
    
    @State private var showPaywall = false
    @State private var showAddCategory = false
    @State private var toast: Toast?
    @State private var amountText: String = ""
    
    init(subscription: Subscription? = nil, template: AppTemplate? = nil, modelContext: ModelContext) {
        let subscriptionService = SubscriptionService(modelContext: modelContext)

        // Get default currency from user settings
        var defaultCurrency = "USD"
        let descriptor = FetchDescriptor<UserSettings>()
        if let userSettings = try? modelContext.fetch(descriptor).first {
            defaultCurrency = userSettings.defaultCurrency
        }

        _viewModel = StateObject(wrappedValue: AddEditSubscriptionViewModel(
            subscription: subscription,
            template: template,
            subscriptionService: subscriptionService,
            defaultCurrency: defaultCurrency
        ))

        // Initialize amount text
        if let subscription = subscription, subscription.amount > 0 {
            _amountText = State(initialValue: String(format: "%.2f", Double(truncating: subscription.amount as NSNumber)))
        }
    }
    
    var body: some View {
        NavigationStack {
            Form {
                // Trial toggle
                Section {
                    Toggle(L10n.Subscription.freeTrial, isOn: Binding(
                        get: { viewModel.subscription.isTrial },
                        set: { newValue in
                            viewModel.subscription.isTrial = newValue
                            if newValue {
                                if viewModel.subscription.trialExpiryDate == nil {
                                    viewModel.subscription.trialExpiryDate = Calendar.current.date(byAdding: .day, value: 7, to: Date())
                                }
                                // Disable notifications for trials (UI is hidden)
                                viewModel.subscription.notify = false
                            }
                        }
                    ))
                } footer: {
                    if viewModel.subscription.isTrial {
                        Text(L10n.Subscription.freeTrialHint)
                    }
                }

                // Basic info section
                Section(L10n.Subscription.sectionBasic) {
                    HStack(spacing: 8) {
                        TextField(L10n.Subscription.namePlaceholder, text: $viewModel.subscription.name)
                        if let iconURL = viewModel.subscription.iconURL,
                           let url = URL(string: iconURL) {
                            CachedAsyncImage(url: url) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 24, height: 24)
                                    .cornerRadius(5)
                            } placeholder: {
                                EmptyView()
                            }
                        }
                    }

                    if viewModel.subscription.isTrial {
                        DatePicker(
                            L10n.Subscription.trialExpiryDate,
                            selection: Binding(
                                get: { viewModel.subscription.trialExpiryDate ?? Date() },
                                set: { viewModel.subscription.trialExpiryDate = $0 }
                            ),
                            displayedComponents: .date
                        )
                    } else {
                        TextField(L10n.Subscription.descriptionPlaceholder, text: Binding(
                            get: { viewModel.subscription.subscriptionDescription ?? "" },
                            set: { viewModel.subscription.subscriptionDescription = $0.isEmpty ? nil : $0 }
                        ))
                    }

                    if let error = viewModel.validationErrors["name"] {
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
                
                if !viewModel.subscription.isTrial {
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

                        // Add new category button
                        Button {
                            showAddCategory = true
                        } label: {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                    .foregroundColor(.blue)
                                Text(L10n.Category.createNew)
                                    .foregroundColor(.blue)
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
                            TextField(L10n.Subscription.amountPlaceholder, text: $amountText)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                                .frame(width: 100)
                                .onChange(of: amountText) { _, newValue in
                                    if let value = Double(newValue) {
                                        viewModel.subscription.amount = Decimal(value)
                                    } else if newValue.isEmpty {
                                        viewModel.subscription.amount = 0
                                    }
                                }
                        }

                        CurrencyPicker(selectedCurrency: $viewModel.subscription.currency)

                        if let error = viewModel.validationErrors["amount"] {
                            Text(error)
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }

                    // Notification section
                    Section {
                        Toggle(L10n.Subscription.enableNotification, isOn: $viewModel.subscription.notify)

                        if viewModel.subscription.notify {
                            Stepper(value: $viewModel.subscription.notifyDaysBefore, in: 0...30) {
                                Text(L10n.Subscription.notifyDaysBefore(viewModel.subscription.notifyDaysBefore))
                            }

                            if !paywallService.isProUser {
                                Button {
                                    showPaywall = true
                                } label: {
                                    HStack {
                                        Text(L10n.Settings.notificationTime)
                                        Spacer()
                                        Text("09:00")
                                            .foregroundColor(.secondary)
                                        Image(systemName: "crown.fill")
                                            .font(.caption)
                                            .foregroundColor(.yellow)
                                    }
                                }
                            }
                        }
                    } header: {
                        Text(L10n.Subscription.sectionNotification)
                    } footer: {
                        if viewModel.subscription.notify && !paywallService.isProUser {
                            Text(L10n.Subscription.notificationTimeProHint)
                        }
                    }
                }

                // Private section
                Section {
                    Toggle(L10n.Subscription.markAsPrivate, isOn: $viewModel.subscription.isPrivate)
                } footer: {
                    Text(L10n.Subscription.privateHint)
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
                PaywallView(source: "subscription_limit")
                    .environmentObject(paywallService)
            }
            .sheet(isPresented: $showAddCategory) {
                AddEditCategoryView(modelContext: modelContext) { newCategory in
                    // 自动选择新创建的分类
                    viewModel.subscription.category = newCategory
                }
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
