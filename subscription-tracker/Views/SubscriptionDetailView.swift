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
    @State private var editSnapshot: SubscriptionSnapshot?
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
            PaywallView(source: "subscription_detail")
                .environmentObject(paywallService)
        }
        .toast($toast)
    }
    
    // MARK: - View Mode Content
    
    private var viewModeContent: some View {
        VStack(spacing: 24) {
            // Trial expired banner
            if viewModel.subscription.isTrial && viewModel.subscription.isTrialExpired {
                VStack(spacing: 12) {
                    Text(L10n.Subscription.trialExpiredBanner)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .multilineTextAlignment(.center)

                    HStack(spacing: 12) {
                        Button {
                            convertTrialToSubscription()
                        } label: {
                            Text(L10n.Subscription.convertToSubscription)
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }

                        Button {
                            Task { await deleteSubscription() }
                        } label: {
                            Text(L10n.Common.delete)
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .background(Color.red)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.red.opacity(0.1))
                )
            }

            // App icon (if available)
            if let iconURL = viewModel.subscription.iconURL, let url = URL(string: iconURL) {
                CachedAsyncImage(url: url) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 80, height: 80)
                        .cornerRadius(18)
                        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                } placeholder: {
                    ProgressView()
                        .frame(width: 80, height: 80)
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
            
            if viewModel.subscription.isTrial {
                // 试用信息卡片
                infoCard {
                    VStack(alignment: .leading, spacing: 16) {
                        if let expiryDate = viewModel.subscription.trialExpiryDate {
                            InfoRow(
                                label: L10n.Subscription.trialExpiryDate,
                                value: formatDate(expiryDate)
                            )
                        }

                        if let days = viewModel.subscription.trialDaysRemaining {
                            InfoRow(
                                label: L10n.SubscriptionDetail.daysUntil,
                                value: viewModel.subscription.isTrialExpired
                                    ? L10n.Subscription.trialExpired
                                    : "\(days) \(L10n.SubscriptionDetail.daysSuffix(days))",
                                valueColor: viewModel.subscription.isTrialExpired || days <= 3 ? .red : nil
                            )
                        }
                    }
                }
            } else {
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
            // 试用开关
            Section {
                Toggle(L10n.Subscription.freeTrial, isOn: Binding(
                    get: { editedSubscription.isTrial },
                    set: { newValue in
                        editedSubscription.isTrial = newValue
                        if newValue {
                            if editedSubscription.trialExpiryDate == nil {
                                editedSubscription.trialExpiryDate = Calendar.current.date(byAdding: .day, value: 7, to: Date())
                            }
                            editedSubscription.notify = false
                        }
                    }
                ))
            } footer: {
                if editedSubscription.isTrial {
                    Text(L10n.Subscription.freeTrialHint)
                }
            }

            // 基本信息
            Section(L10n.SubscriptionDetail.sectionBasic) {
                TextField(L10n.SubscriptionDetail.name, text: $editedSubscription.name)

                if editedSubscription.isTrial {
                    DatePicker(
                        L10n.Subscription.trialExpiryDate,
                        selection: Binding(
                            get: { editedSubscription.trialExpiryDate ?? Date() },
                            set: { editedSubscription.trialExpiryDate = $0 }
                        ),
                        displayedComponents: .date
                    )
                } else {
                    TextField(L10n.Subscription.descriptionPlaceholder, text: Binding(
                        get: { editedSubscription.subscriptionDescription ?? "" },
                        set: { editedSubscription.subscriptionDescription = $0.isEmpty ? nil : $0 }
                    ))
                }
            }

            if !editedSubscription.isTrial {
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
                Section {
                    Toggle(L10n.SubscriptionDetail.enableNotification, isOn: $editedSubscription.notify)

                    if editedSubscription.notify {
                        Stepper(value: $editedSubscription.notifyDaysBefore, in: 0...30) {
                            Text(L10n.SubscriptionDetail.notifyDaysBefore(editedSubscription.notifyDaysBefore))
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
                    Text(L10n.SubscriptionDetail.sectionNotification)
                } footer: {
                    if editedSubscription.notify && !paywallService.isProUser {
                        Text(L10n.Subscription.notificationTimeProHint)
                    }
                }
            }

            // Private section
            Section {
                Toggle(L10n.Subscription.markAsPrivate, isOn: $editedSubscription.isPrivate)
            } footer: {
                Text(L10n.Subscription.privateHint)
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
    
    private func convertTrialToSubscription() {
        viewModel.subscription.isTrial = false
        viewModel.subscription.trialExpiryDate = nil
        enterEditMode()
    }

    private func enterEditMode() {
        editSnapshot = SubscriptionSnapshot(from: viewModel.subscription)
        editedSubscription = viewModel.subscription
        isEditMode = true
    }

    private func cancelEdit() {
        // Restore original values from snapshot
        if let snapshot = editSnapshot {
            snapshot.restore(to: viewModel.subscription)
        }
        editSnapshot = nil
        isEditMode = false
    }

    private func saveChanges() async {
        do {
            try await viewModel.subscriptionService.updateSubscription(viewModel.subscription)
            editSnapshot = nil
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

// MARK: - Subscription Snapshot (for edit cancel rollback)

/// Value-type snapshot of subscription fields to support cancel/rollback during editing
private struct SubscriptionSnapshot {
    let name: String
    let subscriptionDescription: String?
    let categoryId: UUID?
    let category: Category?
    let firstPaymentDate: Date
    let billingCycle: Int
    let billingCycleUnitRawValue: String
    let amount: Decimal
    let currency: String
    let notify: Bool
    let notifyDaysBefore: Int
    let isTrial: Bool
    let trialExpiryDate: Date?
    let isPrivate: Bool

    init(from sub: Subscription) {
        self.name = sub.name
        self.subscriptionDescription = sub.subscriptionDescription
        self.categoryId = sub.category?.id
        self.category = sub.category
        self.firstPaymentDate = sub.firstPaymentDate
        self.billingCycle = sub.billingCycle
        self.billingCycleUnitRawValue = sub.billingCycleUnitRawValue
        self.amount = sub.amount
        self.currency = sub.currency
        self.notify = sub.notify
        self.notifyDaysBefore = sub.notifyDaysBefore
        self.isTrial = sub.isTrial
        self.trialExpiryDate = sub.trialExpiryDate
        self.isPrivate = sub.isPrivate
    }

    func restore(to sub: Subscription) {
        sub.name = name
        sub.subscriptionDescription = subscriptionDescription
        sub.category = category
        sub.firstPaymentDate = firstPaymentDate
        sub.billingCycle = billingCycle
        sub.billingCycleUnitRawValue = billingCycleUnitRawValue
        sub.amount = amount
        sub.currency = currency
        sub.notify = notify
        sub.notifyDaysBefore = notifyDaysBefore
        sub.isTrial = isTrial
        sub.trialExpiryDate = trialExpiryDate
        sub.isPrivate = isPrivate
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

