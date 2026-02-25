//
//  PaywallView.swift
//  subscription-tracker
//
//  Created by Kiro on 2026/2/24.
//

import SwiftUI

/// Paywall view for upgrading to Pro version
struct PaywallView: View {
    
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var paywallService: PaywallService
    
    @State private var isPurchasing = false
    @State private var toast: Toast?
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 12) {
                        Image(systemName: "crown.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.yellow)
                        
                        Text(L10n.Paywall.title)
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text(L10n.Paywall.subtitle)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 32)
                    
                    // Features list
                    VStack(alignment: .leading, spacing: 16) {
                        FeatureRow(
                            icon: "infinity",
                            title: L10n.Paywall.featureUnlimitedSubscriptions,
                            description: L10n.Paywall.featureUnlimitedSubscriptionsDesc
                        )
                        
                        FeatureRow(
                            icon: "folder.fill",
                            title: L10n.Paywall.featureUnlimitedCategories,
                            description: L10n.Paywall.featureUnlimitedCategoriesDesc
                        )
                        
                        FeatureRow(
                            icon: "bell.fill",
                            title: L10n.Paywall.featureSmartNotifications,
                            description: L10n.Paywall.featureSmartNotificationsDesc
                        )
                        
                        FeatureRow(
                            icon: "icloud.fill",
                            title: L10n.Paywall.featureiCloudSync,
                            description: L10n.Paywall.featureiCloudSyncDesc
                        )
                        
                        FeatureRow(
                            icon: "chart.bar.fill",
                            title: L10n.Paywall.featureAdvancedStats,
                            description: L10n.Paywall.featureAdvancedStatsDesc
                        )
                    }
                    .padding(.horizontal)
                    
                    // Purchase button
                    VStack(spacing: 12) {
                        Button {
                            Task {
                                await purchasePro()
                            }
                        } label: {
                            HStack {
                                if isPurchasing {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                } else {
                                    Text(L10n.Paywall.buttonPurchase)
                                        .fontWeight(.semibold)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                        .disabled(isPurchasing)
                        
                        Button {
                            Task {
                                await restorePurchases()
                            }
                        } label: {
                            Text(L10n.Paywall.buttonRestore)
                                .font(.subheadline)
                                .foregroundColor(.blue)
                        }
                        .disabled(isPurchasing)
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                }
                .padding(.bottom, 32)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(L10n.Paywall.buttonClose) {
                        dismiss()
                    }
                }
            }
            .toast($toast)
        }
    }
    
    // MARK: - Actions
    
    private func purchasePro() async {
        isPurchasing = true
        defer { isPurchasing = false }
        
        do {
            _ = try await paywallService.purchaseProVersion()
            toast = .success(L10n.Toast.purchaseSuccess)
            
            // Dismiss after a short delay
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            dismiss()
        } catch {
            toast = .error(L10n.Toast.purchaseFailed(error.localizedDescription))
        }
    }
    
    private func restorePurchases() async {
        isPurchasing = true
        defer { isPurchasing = false }
        
        do {
            _ = try await paywallService.restorePurchases()
            toast = .success(L10n.Toast.restoreSuccess)
            
            // Dismiss after a short delay
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            dismiss()
        } catch {
            toast = .error(L10n.Toast.restoreFailed(error.localizedDescription))
        }
    }
}

// MARK: - Feature Row Component

private struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 32)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }
}

#Preview {
    PaywallView()
        .environmentObject(PaywallService.shared)
}
