//
//  SettingsView.swift
//  subscription-tracker
//
//  Created by Kiro on 2026/2/24.
//

import SwiftUI
import SwiftData

/// Settings view for app configuration and preferences
struct SettingsView: View {
    
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel: SettingsViewModel
    @EnvironmentObject private var paywallService: PaywallService
    @EnvironmentObject private var appSettings: AppSettings
    @EnvironmentObject private var notificationManager: NotificationManager
    @State private var showClearDataConfirmation = false
    @State private var showPaywall = false
    @State private var showNotificationPermissionAlert = false
    @State private var toast: Toast?
    
    // Computed properties for bindings
    var darkModeSelection: Binding<DarkModeOption> {
        Binding(
            get: {
                if let darkMode = viewModel.userSettings?.darkMode {
                    return darkMode ? .dark : .light
                }
                return .system
            },
            set: { newValue in
                Task {
                    switch newValue {
                    case .system:
                        try? await viewModel.updateDarkMode(nil)
                        appSettings.updateColorScheme(nil)
                    case .light:
                        try? await viewModel.updateDarkMode(false)
                        appSettings.updateColorScheme(false)
                    case .dark:
                        try? await viewModel.updateDarkMode(true)
                        appSettings.updateColorScheme(true)
                    }
                }
            }
        )
    }
    
    var themeColor: String {
        viewModel.userSettings?.themeColor ?? "#007AFF"
    }
    
    var defaultCurrency: Binding<String> {
        Binding(
            get: { viewModel.userSettings?.defaultCurrency ?? "USD" },
            set: { newValue in
                Task {
                    try? await viewModel.updateDefaultCurrency(newValue)
                }
            }
        )
    }
    
    var defaultNotifyTime: Binding<Date> {
        Binding(
            get: { viewModel.userSettings?.defaultNotifyTime ?? Date() },
            set: { newValue in
                Task {
                    try? await viewModel.updateDefaultNotifyTime(newValue)
                    // Reschedule all notifications with new time
                    await rescheduleAllNotifications(newTime: newValue)
                }
            }
        )
    }
    
    var iCloudSync: Binding<Bool> {
        Binding(
            get: { viewModel.userSettings?.iCloudSync ?? false },
            set: { newValue in
                Task {
                    try? await viewModel.toggleiCloudSync(newValue)
                }
            }
        )
    }
    
    init(modelContext: ModelContext) {
        let syncService = SyncService(modelContext: modelContext)
        _viewModel = StateObject(wrappedValue: SettingsViewModel(modelContext: modelContext, syncService: syncService))
    }
    
    var body: some View {
        NavigationStack {
            Form {
                // Settings section (merged appearance + defaults)
                settingsSection
                
                // Data section
                dataSection
                
                // Pro version section
                proVersionSection
                
                // About section
                aboutSection
            }
            .task {
                await viewModel.loadSettings()
            }
            .overlay {
                if viewModel.isLoading {
                    LoadingOverlay(message: "加载中...")
                }
            }
            .alert(L10n.Settings.clearDataConfirmTitle, isPresented: $showClearDataConfirmation) {
                Button(L10n.Common.cancel, role: .cancel) { }
                Button(L10n.Settings.clearData, role: .destructive) {
                    Task {
                        await clearAllData()
                    }
                }
            } message: {
                Text(L10n.Settings.clearDataConfirmMessage)
            }
            .sheet(isPresented: $showPaywall) {
                PaywallView()
                    .environmentObject(paywallService)
            }
            .alert(L10n.NotificationContent.permissionRequired, isPresented: $showNotificationPermissionAlert) {
                Button(L10n.Common.cancel, role: .cancel) { }
                Button(L10n.NotificationContent.goToSettings) {
                    notificationManager.openSettings()
                }
            } message: {
                Text(L10n.NotificationContent.permissionMessage)
            }
        }
        .toast($toast)
    }
    
    // MARK: - View Components
    
    private var settingsSection: some View {
        Section(L10n.Settings.sectionSettings) {
            // Theme (Dark mode picker)
            Picker(L10n.Settings.theme, selection: darkModeSelection) {
                Text(L10n.Settings.darkModeSystem).tag(DarkModeOption.system)
                Text(L10n.Settings.darkModeLight).tag(DarkModeOption.light)
                Text(L10n.Settings.darkModeDark).tag(DarkModeOption.dark)
            }
            
            // Language - opens system settings
            Button {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    Task { @MainActor in
                        UIApplication.shared.open(url)
                    }
                }
            } label: {
                HStack {
                    Text(L10n.Settings.language)
                    Spacer()
                    Text(currentLanguageDisplayName())
                        .foregroundColor(.secondary)
                    Image(systemName: "arrow.up.forward.square")
                        .foregroundColor(.secondary)
                        .font(.caption)
                }
            }
            
            // Default notification time picker with Pro badge
            if paywallService.isProUser && notificationManager.authorizationStatus == .authorized {
                // Pro user with permission - show date picker
                DatePicker(
                    L10n.Settings.notificationTime,
                    selection: defaultNotifyTime,
                    displayedComponents: .hourAndMinute
                )
            } else {
                // Non-Pro or no permission - show button
                Button {
                    if !paywallService.isProUser {
                        showPaywall = true
                    } else if notificationManager.authorizationStatus != .authorized {
                        showNotificationPermissionAlert = true
                    }
                } label: {
                    HStack {
                        Text(L10n.Settings.notificationTime)
                        Spacer()
                        if !paywallService.isProUser {
                            Image(systemName: "crown.fill")
                                .font(.caption)
                                .foregroundColor(.yellow)
                        } else if notificationManager.authorizationStatus == .denied {
                            Image(systemName: "bell.slash.fill")
                                .font(.caption)
                                .foregroundColor(.red)
                        } else if notificationManager.authorizationStatus == .notDetermined {
                            Image(systemName: "bell.badge.fill")
                                .font(.caption)
                                .foregroundColor(.orange)
                        }
                    }
                }
            }
            
            // Default currency picker
            Picker(L10n.Settings.defaultCurrency, selection: defaultCurrency) {
                ForEach(CurrencyFormatter.supportedCurrencies, id: \.self) { currency in
                    Text("\(currency) (\(CurrencyFormatter.symbol(for: currency)))").tag(currency)
                }
            }
        }
    }
    
    // Get current language display name
    private func currentLanguageDisplayName() -> String {
        let languageCode = Locale.current.language.languageCode?.identifier ?? "en"
        switch languageCode {
        case "zh":
            return L10n.Settings.languageZh
        case "ja":
            return L10n.Settings.languageJa
        default:
            return L10n.Settings.languageEn
        }
    }
    
    private var dataSection: some View {
        Section(L10n.Settings.sectionData) {
            // iCloud sync toggle with Pro badge
            if paywallService.isProUser {
                Toggle(L10n.Settings.iCloudSync, isOn: iCloudSync)
                
                // Sync status indicator
                if viewModel.userSettings?.iCloudSync == true {
                    HStack {
                        Text(L10n.Settings.syncStatus)
                        Spacer()
                        syncStatusView
                    }
                    
                    // Manual sync button
                    Button {
                        Task {
                            await manualSync()
                        }
                    } label: {
                        HStack {
                            Image(systemName: "arrow.triangle.2.circlepath")
                            Text(L10n.Settings.manualSync)
                            Spacer()
                            if viewModel.isLoading {
                                ProgressView()
                            }
                        }
                    }
                    .disabled(viewModel.isLoading)
                }
            } else {
                Button {
                    showPaywall = true
                } label: {
                    HStack {
                        Text(L10n.Settings.iCloudSync)
                        Spacer()
                        Image(systemName: "crown.fill")
                            .font(.caption)
                            .foregroundColor(.yellow)
                    }
                }
            }
            
            // Clear all data button
            Button(role: .destructive) {
                showClearDataConfirmation = true
            } label: {
                HStack {
                    Text(L10n.Settings.clearData)
                    Spacer()
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
            }
        }
    }
    
    private var syncStatusView: some View {
        Group {
            switch viewModel.getSyncStatus() {
            case .syncing:
                HStack(spacing: 4) {
                    ProgressView()
                        .scaleEffect(0.8)
                    Text(L10n.Settings.syncSyncing)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            case .synced:
                VStack(alignment: .trailing, spacing: 2) {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.icloud.fill")
                            .foregroundColor(.green)
                        Text(L10n.Settings.syncSynced)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    if let lastSyncTime = viewModel.userSettings?.lastSyncTime {
                        Text(formatSyncTime(lastSyncTime))
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            case .error(let message):
                HStack(spacing: 4) {
                    Image(systemName: "exclamationmark.icloud.fill")
                        .foregroundColor(.red)
                    Text(L10n.Settings.syncError)
                        .font(.caption)
                        .foregroundColor(.red)
                }
            case .disabled:
                HStack(spacing: 4) {
                    Image(systemName: "icloud.slash.fill")
                        .foregroundColor(.gray)
                    Text(L10n.Settings.syncDisabled)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
    
    private func formatSyncTime(_ date: Date) -> String {
        let now = Date()
        let interval = now.timeIntervalSince(date)
        
        if interval < 60 {
            return "刚刚"
        } else if interval < 3600 {
            let minutes = Int(interval / 60)
            return "\(minutes)分钟前"
        } else if interval < 86400 {
            let hours = Int(interval / 3600)
            return "\(hours)小时前"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "MM-dd HH:mm"
            return formatter.string(from: date)
        }
    }
    
    private func manualSync() async {
        do {
            try await viewModel.manualSync()
            toast = .success("同步成功")
        } catch {
            toast = .error("同步失败: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Actions
    
    private func clearAllData() async {
        do {
            // Fetch all subscriptions with all properties loaded
            var subscriptionDescriptor = FetchDescriptor<Subscription>()
            subscriptionDescriptor.propertiesToFetch = [\.name, \.amount, \.currency, \.billingCycle, \.billingCycleUnit]
            let subscriptions = try modelContext.fetch(subscriptionDescriptor)
            
            // Delete all subscriptions
            for subscription in subscriptions {
                modelContext.delete(subscription)
            }
            
            // Fetch all categories with all properties loaded
            var categoryDescriptor = FetchDescriptor<Category>()
            categoryDescriptor.propertiesToFetch = [\.name, \.colorHex]
            let categories = try modelContext.fetch(categoryDescriptor)
            
            // Delete all categories
            for category in categories {
                modelContext.delete(category)
            }
            
            try modelContext.save()
            toast = .success(L10n.Settings.clearDataSuccess)
        } catch {
            toast = .error(L10n.Settings.clearDataFailed(error.localizedDescription))
        }
    }
    
    private var proVersionSection: some View {
        Section(L10n.Settings.sectionPro) {
            if paywallService.isProUser {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text(L10n.Settings.proPurchased)
                }
                
                // Test notification button (Pro users only)
                if notificationManager.authorizationStatus == .authorized {
                    Button {
                        Task {
                            await sendTestNotification()
                        }
                    } label: {
                        HStack {
                            Image(systemName: "bell.badge.fill")
                                .foregroundColor(.blue)
                            Text(L10n.NotificationContent.testNotification)
                        }
                    }
                }
            } else {
                Button {
                    showPaywall = true
                } label: {
                    HStack {
                        Text(L10n.Settings.upgradeToPro)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.secondary)
                    }
                }
                
                Button {
                    Task {
                        do {
                            let success = try await paywallService.restorePurchases()
                            if success {
                                toast = .success(L10n.Toast.restoreSuccess)
                            } else {
                                toast = .error(L10n.Toast.restoreFailed(L10n.Paywall.errorNoActivePurchase))
                            }
                        } catch {
                            toast = .error(L10n.Toast.restoreFailed(error.localizedDescription))
                        }
                    }
                } label: {
                    HStack {
                        Text(L10n.Settings.restorePurchases)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            #if DEBUG
            // Development test button to toggle Pro status
            Button {
                paywallService.isProUser.toggle()
            } label: {
                HStack {
                    Image(systemName: "hammer.fill")
                        .foregroundColor(.orange)
                    Text("Toggle Pro Status (Dev Only)")
                    Spacer()
                    Text(paywallService.isProUser ? "ON" : "OFF")
                        .foregroundColor(.secondary)
                }
            }
            #endif
        }
    }
    
    private var aboutSection: some View {
        Section(L10n.Settings.sectionAbout) {
            HStack {
                Text(L10n.Settings.version)
                Spacer()
                Text("1.0.0")
                    .foregroundColor(.secondary)
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func rescheduleAllNotifications(newTime: Date) async {
        let subscriptionService = SubscriptionService(modelContext: modelContext)
        let subscriptions = subscriptionService.fetchActiveSubscriptions()
        
        await NotificationService.shared.rescheduleAllNotifications(
            for: subscriptions,
            notifyTime: newTime
        )
    }
    
    private func sendTestNotification() async {
        print("🔵 开始发送测试通知...")
        
        // 检查权限
        await notificationManager.checkAuthorizationStatus()
        let status = notificationManager.authorizationStatus
        print("🔵 通知权限状态: \(status.rawValue)")
        
        guard status == .authorized else {
            print("❌ 通知权限未授权")
            toast = .error("通知权限未授权，请在设置中开启")
            return
        }
        
        // Create a test notification that fires in 5 seconds
        let content = UNMutableNotificationContent()
        content.title = L10n.NotificationContent.title
        content.body = "This is a test notification. Your notifications are working!"
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let request = UNNotificationRequest(
            identifier: "test-notification-\(UUID().uuidString)",
            content: content,
            trigger: trigger
        )
        
        do {
            print("🔵 添加通知到通知中心...")
            try await UNUserNotificationCenter.current().add(request)
            print("✅ 测试通知已添加，将在 5 秒后显示")
            toast = .success(L10n.NotificationContent.testSent)
        } catch {
            print("❌ 发送测试通知失败: \(error.localizedDescription)")
            toast = .error("Failed to send test notification: \(error.localizedDescription)")
        }
    }
}

// MARK: - Dark Mode Option

enum DarkModeOption {
    case system
    case light
    case dark
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Subscription.self, Category.self, UserSettings.self, configurations: config)
    
    return SettingsView(modelContext: container.mainContext)
        .environmentObject(PaywallService.shared)
        .environmentObject(AppSettings())
}
