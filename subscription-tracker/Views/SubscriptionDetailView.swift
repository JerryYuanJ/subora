//
//  SubscriptionDetailView.swift
//  subscription-tracker
//
//  Created by Kiro on 2026/2/24.
//

import SwiftUI
import SwiftData

/// Subscription detail view with view/edit modes
struct SubscriptionDetailView: View {
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var paywallService: PaywallService
    @StateObject private var viewModel: SubscriptionDetailViewModel
    @Query private var categories: [Category]
    
    @State private var isEditMode = false
    @State private var editedSubscription: Subscription
    @State private var showDeleteConfirmation = false
    @State private var showPaywall = false
    @State private var toast: Toast?
    
    init(subscription: Subscription, modelContext: ModelContext) {
        let subscriptionService = SubscriptionService(modelContext: modelContext)
        _viewModel = StateObject(wrappedValue: SubscriptionDetailViewModel(
            subscription: subscription,
            subscriptionService: subscriptionService
        ))
        _editedSubscription = State(initialValue: subscription)
    }
    
    var body: some View {
        Group {
            if isEditMode {
                editModeContent
            } else {
                ScrollView {
                    VStack(spacing: 24) {
                        viewModeContent
                    }
                    .padding()
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(isEditMode)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                if isEditMode {
                    Button(L10n.SubscriptionDetail.cancel) {
                        cancelEdit()
                    }
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                if isEditMode {
                    Button(L10n.SubscriptionDetail.save) {
                        Task {
                            await saveChanges()
                        }
                    }
                } else {
                    Button(L10n.SubscriptionDetail.edit) {
                        enterEditMode()
                    }
                }
            }
        }
        .task {
            viewModel.loadDetails()
        }
        .alert(L10n.SubscriptionDetail.deleteConfirmTitle, isPresented: $showDeleteConfirmation) {
            Button(L10n.SubscriptionDetail.cancel, role: .cancel) { }
            Button(L10n.Common.delete, role: .destructive) {
                Task {
                    await deleteSubscription()
                }
            }
        } message: {
            Text(L10n.SubscriptionDetail.deleteConfirmMessage)
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView()
                .environmentObject(paywallService)
        }
        .toast($toast)
    }
    
    // MARK: - View Mode Content
    
    private var viewModeContent: some View {
        VStack(spacing: 24) {
            // App icon (if available)
            if let iconURL = viewModel.subscription.iconURL, let url = URL(string: iconURL) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(width: 80, height: 80)
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 80, height: 80)
                            .cornerRadius(18)
                            .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                    case .failure:
                        Image(systemName: "app.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.secondary)
                            .frame(width: 80, height: 80)
                            .background(Color(.systemGray5))
                            .cornerRadius(18)
                    @unknown default:
                        EmptyView()
                    }
                }
                .padding(.top, 8)
            }
            
            // 基本信息卡片
            infoCard {
                VStack(alignment: .leading, spacing: 16) {
                    InfoRow(label: L10n.SubscriptionDetail.name, value: viewModel.subscription.name)
                    
                    if let description = viewModel.subscription.subscriptionDescription {
                        InfoRow(label: L10n.SubscriptionDetail.description, value: description)
                    }
                    
                    if let category = viewModel.subscription.category {
                        HStack {
                            Text(L10n.SubscriptionDetail.category)
                                .foregroundColor(.secondary)
                            Spacer()
                            CategoryBadge(category: category, isCompact: false)
                        }
                    }
                }
            }
            
            // 计费信息卡片
            infoCard {
                VStack(alignment: .leading, spacing: 16) {
                    InfoRow(
                        label: L10n.SubscriptionDetail.amount,
                        value: CurrencyFormatter.format(
                            amount: viewModel.subscription.amount,
                            currency: viewModel.subscription.currency
                        )
                    )
                    
                    InfoRow(
                        label: L10n.SubscriptionDetail.billingCycle,
                        value: formatBillingCycle()
                    )
                    
                    InfoRow(
                        label: L10n.SubscriptionDetail.firstPayment,
                        value: formatDate(viewModel.subscription.firstPaymentDate)
                    )
                    
                    InfoRow(
                        label: L10n.SubscriptionDetail.nextRenewal,
                        value: formatDate(viewModel.subscription.nextBillingDate)
                    )
                    
                    InfoRow(
                        label: L10n.SubscriptionDetail.daysUntil,
                        value: "\(viewModel.daysUntilRenewal) \(L10n.SubscriptionDetail.daysSuffix(viewModel.daysUntilRenewal))",
                        valueColor: viewModel.daysUntilRenewal <= 3 ? .red : nil
                    )
                }
            }
            
            // 统计信息卡片
            infoCard {
                VStack(alignment: .leading, spacing: 16) {
                    InfoRow(
                        label: L10n.SubscriptionDetail.paymentCount,
                        value: "\(viewModel.paymentCount) \(L10n.SubscriptionDetail.timesSuffix(viewModel.paymentCount))"
                    )
                    
                    InfoRow(
                        label: L10n.SubscriptionDetail.totalPaid,
                        value: CurrencyFormatter.format(
                            amount: viewModel.historicalTotal,
                            currency: viewModel.subscription.currency
                        )
                    )
                }
            }
            
            // 提醒设置卡片
            infoCard {
                VStack(alignment: .leading, spacing: 16) {
                    InfoRow(
                        label: L10n.SubscriptionDetail.notification,
                        value: viewModel.subscription.notify ? L10n.SubscriptionDetail.notificationEnabled : L10n.SubscriptionDetail.notificationDisabled
                    )
                    
                    if viewModel.subscription.notify {
                        InfoRow(
                            label: L10n.SubscriptionDetail.notificationTime,
                            value: L10n.SubscriptionDetail.notifyDaysBefore(viewModel.subscription.notifyDaysBefore)
                        )
                    }
                }
            }
            
            // 操作按钮
            HStack(spacing: 12) {
                Button {
                    Task {
                        await archiveSubscription()
                    }
                } label: {
                    Label(
                        viewModel.subscription.archived ? L10n.SubscriptionDetail.unarchive : L10n.SubscriptionDetail.archive,
                        systemImage: "archivebox"
                    )
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                
                Button {
                    showDeleteConfirmation = true
                } label: {
                    Label(L10n.Common.delete, systemImage: "trash")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
            }
        }
    }
    
    // MARK: - Edit Mode Content
    
    private var editModeContent: some View {
        Form {
            // 基本信息
            Section(L10n.SubscriptionDetail.sectionBasic) {
                TextField(L10n.SubscriptionDetail.name, text: $editedSubscription.name)
                TextField(L10n.Subscription.descriptionPlaceholder, text: Binding(
                    get: { editedSubscription.subscriptionDescription ?? "" },
                    set: { editedSubscription.subscriptionDescription = $0.isEmpty ? nil : $0 }
                ))
            }
            
            // 分类
            Section(L10n.Subscription.sectionCategory) {
                Picker(L10n.Subscription.categoryPicker, selection: $editedSubscription.category) {
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
            
            // 计费信息
            Section(L10n.SubscriptionDetail.sectionBilling) {
                DatePicker(
                    L10n.Subscription.firstPaymentDate,
                    selection: $editedSubscription.firstPaymentDate,
                    displayedComponents: .date
                )
                
                BillingCyclePicker(
                    cycle: $editedSubscription.billingCycle,
                    unit: $editedSubscription.billingCycleUnit
                )
                
                HStack {
                    Text(L10n.SubscriptionDetail.amount)
                    Spacer()
                    TextField("0.00", value: Binding(
                        get: { Double(truncating: editedSubscription.amount as NSNumber) },
                        set: { editedSubscription.amount = Decimal($0) }
                    ), format: .number)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 100)
                }
                
                CurrencyPicker(selectedCurrency: $editedSubscription.currency)
            }
            
            // 提醒设置
            Section(L10n.SubscriptionDetail.sectionNotification) {
                if paywallService.isProUser {
                    Toggle(L10n.SubscriptionDetail.enableNotification, isOn: $editedSubscription.notify)
                    
                    if editedSubscription.notify {
                        Stepper(value: $editedSubscription.notifyDaysBefore, in: 0...30) {
                            Text(L10n.SubscriptionDetail.notifyDaysBefore(editedSubscription.notifyDaysBefore))
                        }
                    }
                } else {
                    Button {
                        showPaywall = true
                    } label: {
                        HStack {
                            Text(L10n.SubscriptionDetail.enableNotification)
                            Spacer()
                            Image(systemName: "crown.fill")
                                .font(.caption)
                                .foregroundColor(.yellow)
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Helper Views
    
    private func infoCard<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            content()
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    // MARK: - Actions
    
    private func enterEditMode() {
        editedSubscription = viewModel.subscription
        isEditMode = true
    }
    
    private func cancelEdit() {
        isEditMode = false
    }
    
    private func saveChanges() async {
        do {
            // 更新原始订阅对象
            viewModel.subscription.name = editedSubscription.name
            viewModel.subscription.subscriptionDescription = editedSubscription.subscriptionDescription
            viewModel.subscription.category = editedSubscription.category
            viewModel.subscription.firstPaymentDate = editedSubscription.firstPaymentDate
            viewModel.subscription.billingCycle = editedSubscription.billingCycle
            viewModel.subscription.billingCycleUnit = editedSubscription.billingCycleUnit
            viewModel.subscription.amount = editedSubscription.amount
            viewModel.subscription.currency = editedSubscription.currency
            viewModel.subscription.notify = editedSubscription.notify
            viewModel.subscription.notifyDaysBefore = editedSubscription.notifyDaysBefore
            
            // 保存到数据库
            try modelContext.save()
            
            toast = .success(L10n.SubscriptionDetail.saveSuccess)
            isEditMode = false
            viewModel.loadDetails()
        } catch {
            toast = .error(L10n.SubscriptionDetail.saveFailed(error.localizedDescription))
        }
    }
    
    private func archiveSubscription() async {
        do {
            try await viewModel.archive()
            toast = .success(viewModel.subscription.archived ? L10n.SubscriptionDetail.archived : L10n.SubscriptionDetail.unarchived)
            
            // 延迟后返回
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            dismiss()
        } catch {
            toast = .error(L10n.SubscriptionDetail.operationFailed(error.localizedDescription))
        }
    }
    
    private func deleteSubscription() async {
        do {
            try await viewModel.delete()
            toast = .success(L10n.SubscriptionDetail.deleteSuccess)
            
            // 延迟后返回
            try? await Task.sleep(nanoseconds: 500_000_000)
            dismiss()
        } catch {
            toast = .error(L10n.SubscriptionDetail.saveFailed(error.localizedDescription))
        }
    }
    
    // MARK: - Helper Methods
    
    private func formatBillingCycle() -> String {
        L10n.BillingCycle.formatCycle(viewModel.subscription.billingCycle, viewModel.subscription.billingCycleUnit)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}

// MARK: - Info Row Component

private struct InfoRow: View {
    let label: String
    let value: String
    var valueColor: Color?
    
    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .foregroundColor(valueColor ?? .primary)
                .fontWeight(valueColor != nil ? .semibold : .regular)
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Subscription.self, Category.self, UserSettings.self, configurations: config)
    
    let category = Category(name: "娱乐", colorHex: "#FF5733")
    let subscription = Subscription(
        name: "Netflix",
        description: "流媒体视频服务",
        category: category,
        firstPaymentDate: Date(),
        billingCycle: 1,
        billingCycleUnit: .month,
        amount: 15.99,
        currency: "USD"
    )
    
    return NavigationStack {
        SubscriptionDetailView(subscription: subscription, modelContext: container.mainContext)
            .environmentObject(PaywallService.shared)
    }
}

