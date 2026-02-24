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
                Section("基本信息") {
                    TextField("订阅名称", text: $viewModel.subscription.name)
                    TextField("描述（可选）", text: Binding(
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
                Section("分类") {
                    Picker("选择分类", selection: $viewModel.subscription.category) {
                        Text("无分类").tag(nil as Category?)
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
                Section("计费信息") {
                    DatePicker(
                        "首次付款日期",
                        selection: $viewModel.subscription.firstPaymentDate,
                        displayedComponents: .date
                    )
                    
                    BillingCyclePicker(
                        cycle: $viewModel.subscription.billingCycle,
                        unit: $viewModel.subscription.billingCycleUnit
                    )
                    
                    HStack {
                        Text("金额")
                        Spacer()
                        TextField("0.00", value: Binding(
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
                Section("提醒设置") {
                    Toggle("启用提醒", isOn: $viewModel.subscription.notify)
                    
                    if viewModel.subscription.notify {
                        Stepper(value: $viewModel.subscription.notifyDaysBefore, in: 1...30) {
                            Text("提前 \(viewModel.subscription.notifyDaysBefore) 天提醒")
                        }
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        Task {
                            await saveSubscription()
                        }
                    }
                    .disabled(viewModel.isSaving)
                }
            }
            .overlay {
                if viewModel.isSaving {
                    LoadingOverlay(message: "保存中...")
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
            toast = .success("保存成功")
            
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
