//
//  SettingsView.swift
//  subscription-tracker
//
//  Created by Kiro on 2026/2/24.
//

import SwiftUI
import SwiftData
import StoreKit
import WidgetKit

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
    @State private var showMailComposer = false
    @State private var showMailUnavailableAlert = false
    @State private var toast: Toast?
    @State private var showWidgetPreview = false
    
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
            .safeAreaInset(edge: .bottom) {
                // Version info at bottom center
                Text(L10n.Settings.appVersion("1.0.0"))
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(Color(UIColor.systemGroupedBackground))
            }
            .task {
                await viewModel.loadSettings()
            }
            .overlay {
                if viewModel.isLoading {
                    LoadingOverlay(message: L10n.Loading.default)
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
            .sheet(isPresented: $showWidgetPreview) {
                WidgetPreviewSheet()
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
        .sheet(isPresented: $showMailComposer) {
            MailComposer(
                recipients: [AppConfig.supportEmail],
                subject: L10n.Settings.feedbackSubject,
                body: """
                
                
                ---
                App Version: \(AppConfig.fullVersion)
                Device: \(UIDevice.current.model)
                iOS: \(UIDevice.current.systemVersion)
                """
            )
        }
        .alert(L10n.Settings.mailUnavailable, isPresented: $showMailUnavailableAlert) {
            Button(L10n.Common.ok, role: .cancel) { }
        } message: {
            Text(L10n.Settings.mailUnavailableMessage)
        }
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
            
            // Clear image cache button
            Button {
                ImageCache.shared.clearCache()
                toast = Toast(message: L10n.Settings.clearImageCacheSuccess, type: .success)
            } label: {
                HStack {
                    Text(L10n.Settings.clearImageCache)
                    Spacer()
                    Image(systemName: "photo")
                        .foregroundColor(.secondary)
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
            return L10n.Time.justNow
        } else if interval < 3600 {
            let minutes = Int(interval / 60)
            return L10n.Time.minutesAgo(minutes)
        } else if interval < 86400 {
            let hours = Int(interval / 3600)
            return L10n.Time.hoursAgo(hours)
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "MM-dd HH:mm"
            return formatter.string(from: date)
        }
    }
    
    private func manualSync() async {
        do {
            try await viewModel.manualSync()
            toast = .success(L10n.Toast.syncSuccess)
        } catch {
            toast = .error(L10n.Toast.syncFailed(error.localizedDescription))
        }
    }
    
    // MARK: - Actions
    
    private func clearAllData() async {
        do {
            // Cancel all pending notifications
            await NotificationService.shared.cancelAllNotifications()

            // Fetch all subscriptions
            let subscriptionDescriptor = FetchDescriptor<Subscription>()
            let subscriptions = try modelContext.fetch(subscriptionDescriptor)

            // Delete all subscriptions
            for subscription in subscriptions {
                modelContext.delete(subscription)
            }

            // Fetch all categories
            let categoryDescriptor = FetchDescriptor<Category>()
            let categories = try modelContext.fetch(categoryDescriptor)

            // Delete all categories
            for category in categories {
                modelContext.delete(category)
            }

            try modelContext.save()

            // Clear widget data
            WidgetDataStore.save(.empty)
            WidgetKit.WidgetCenter.shared.reloadAllTimelines()

            // Re-seed default categories
            let defaults: [(name: String, color: String)] = [
                (L10n.Category.defaultEntertainment, "#FF2D55"),
                (L10n.Category.defaultEducation, "#5856D6"),
                (L10n.Category.defaultTools, "#007AFF"),
                (L10n.Category.defaultAITool, "#AF52DE"),
            ]
            for item in defaults {
                let category = Category(name: item.name, colorHex: item.color)
                modelContext.insert(category)
            }
            try? modelContext.save()

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

                // Widget promotion (Pro users only)
                Button {
                    showWidgetPreview = true
                } label: {
                    HStack {
                        Image(systemName: "square.grid.2x2.fill")
                            .foregroundColor(.blue)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(L10n.Settings.widget)
                            Text(L10n.Settings.widgetSubtitle)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.secondary)
                            .font(.caption)
                    }
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
                    Text(L10n.Settings.devToggleProStatus)
                    Spacer()
                    Text(paywallService.isProUser ? L10n.Settings.devProStatusOn : L10n.Settings.devProStatusOff)
                        .foregroundColor(.secondary)
                }
            }
            #endif
        }
    }
    
    private var aboutSection: some View {
        Section(L10n.Settings.sectionAbout) {
            // Contact Us
            Button {
                contactUs()
            } label: {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(L10n.Settings.contactUs)
                            .foregroundColor(.primary)
                        Text(L10n.Settings.contactUsSubtitle)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // Rate App
            Button {
                rateApp()
            } label: {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(L10n.Settings.rateApp)
                            .foregroundColor(.primary)
                        Text(L10n.Settings.rateAppSubtitle)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // Share App
            Button {
                shareApp()
            } label: {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(L10n.Settings.shareApp)
                            .foregroundColor(.primary)
                        Text(L10n.Settings.shareAppSubtitle)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
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
            toast = .error(L10n.NotificationContent.permissionDenied)
            return
        }
        
        // Create two test notifications with realistic content
        let testData: [(name: String, days: Int, amount: String, delay: TimeInterval)] = [
            ("Claude Code", 3, "$20.00", 3),
            ("Apple Music", 7, "$10.99", 5)
        ]

        do {
            for item in testData {
                let content = UNMutableNotificationContent()
                content.title = L10n.NotificationContent.title
                content.body = L10n.NotificationContent.body(item.name, item.days, item.amount)
                content.sound = .default

                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: item.delay, repeats: false)
                let request = UNNotificationRequest(
                    identifier: "test-notification-\(UUID().uuidString)",
                    content: content,
                    trigger: trigger
                )

                print("🔵 添加通知到通知中心...")
                try await UNUserNotificationCenter.current().add(request)
                print("✅ 测试通知已添加：\(item.name)")
            }
            toast = .success(L10n.NotificationContent.testSent)
        } catch {
            print("❌ 发送测试通知失败: \(error.localizedDescription)")
            toast = .error(L10n.NotificationContent.testFailed(error.localizedDescription))
        }
    }
    
    // MARK: - About Actions
    
    private func contactUs() {
        if MailComposer.canSendMail {
            showMailComposer = true
        } else {
            showMailUnavailableAlert = true
        }
    }
    
    private func rateApp() {
        guard let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene else { return }
        SKStoreReviewController.requestReview(in: scene)
    }
    
    private func shareApp() {
        let message = L10n.Settings.shareMessage
        guard let appURL = URL(string: AppConfig.appStoreURL) else { return }
        
        // 使用自定义的 Activity Item Source 来更好地控制分享内容
        let shareItem = AppShareActivityItemSource(
            message: message,
            url: appURL,
            icon: AppConfig.appIcon
        )
        
        let activityViewController = UIActivityViewController(
            activityItems: [shareItem],
            applicationActivities: nil
        )
        
        // 排除一些不需要的分享选项（可选）
        activityViewController.excludedActivityTypes = [
            .addToReadingList,
            .assignToContact,
            .openInIBooks,
            .markupAsPDF
        ]
        
        // 获取当前的 window scene
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first,
           let rootViewController = window.rootViewController {
            
            // iPad 需要设置 popover
            if let popover = activityViewController.popoverPresentationController {
                popover.sourceView = rootViewController.view
                popover.sourceRect = CGRect(x: rootViewController.view.bounds.midX,
                                           y: rootViewController.view.bounds.midY,
                                           width: 0, height: 0)
                popover.permittedArrowDirections = []
            }
            
            rootViewController.present(activityViewController, animated: true)
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
        .environmentObject(NotificationManager())
}
