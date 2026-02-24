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
                // Appearance section
                appearanceSection
                
                // Default settings section
                defaultSettingsSection
                
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
        }
    }
    
    // MARK: - View Components
    
    private var appearanceSection: some View {
        Section(L10n.Settings.sectionAppearance) {
            // Dark mode picker
            Picker(L10n.Settings.darkMode, selection: darkModeSelection) {
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
    
    private var defaultSettingsSection: some View {
        Section(L10n.Settings.sectionDefaults) {
            // Default currency picker
            Picker(L10n.Settings.defaultCurrency, selection: defaultCurrency) {
                ForEach(CurrencyFormatter.supportedCurrencies, id: \.self) { currency in
                    Text(currency).tag(currency)
                }
            }
            
            // Default notification time picker
            DatePicker(
                L10n.Settings.notificationTime,
                selection: defaultNotifyTime,
                displayedComponents: .hourAndMinute
            )
        }
    }
    
    private var dataSection: some View {
        Section(L10n.Settings.sectionData) {
            // iCloud sync toggle
            Toggle(L10n.Settings.iCloudSync, isOn: iCloudSync)
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
            } else {
                Button {
                    Task {
                        try? await paywallService.purchaseProVersion()
                    }
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
                        try? await paywallService.restorePurchases()
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
