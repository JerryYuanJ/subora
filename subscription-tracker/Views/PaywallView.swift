//
//  PaywallView.swift
//  subscription-tracker
//
//  Created by Kiro on 2026/2/24.
//

import SwiftUI
import StoreKit

struct PaywallView: View {
    
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var paywallService: PaywallService
    
    @State private var selectedProduct: Product?
    @State private var isPurchasing = false
    @State private var toast: Toast?
    
    /// Source of paywall trigger for analytics
    let source: String
    
    init(source: String = "unknown") {
        self.source = source
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Premium gradient background
                LinearGradient(
                    colors: [
                        Color(hex: "#0a0e27"),
                        Color(hex: "#1a1f3a"),
                        Color(hex: "#2d1b4e")
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                // Subtle animated particles effect
                GeometryReader { geometry in
                    ForEach(0..<3) { i in
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [
                                        Color(hex: "#fbbf24").opacity(0.12),
                                        Color.clear
                                    ],
                                    center: .center,
                                    startRadius: 0,
                                    endRadius: 100
                                )
                            )
                            .frame(width: 200, height: 200)
                            .offset(
                                x: geometry.size.width * (i == 0 ? 0.2 : i == 1 ? 0.7 : 0.5),
                                y: geometry.size.height * (i == 0 ? 0.3 : i == 1 ? 0.6 : 0.1)
                            )
                            .blur(radius: 60)
                    }
                }
                .ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        // Header with close button
                        HStack {
                            Spacer()
                            Button {
                                dismiss()
                            } label: {
                                Image(systemName: "xmark")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.white.opacity(0.6))
                                    .frame(width: 32, height: 32)
                                    .background(Color.white.opacity(0.08))
                                    .clipShape(Circle())
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 8)
                        
                        // Content
                        VStack(spacing: 20) {
                            // Crown icon and title
                            VStack(spacing: 10) {
                                ZStack {
                                    // Outer glow
                                    Circle()
                                        .fill(
                                            RadialGradient(
                                                colors: [
                                                    Color(hex: "#fbbf24").opacity(0.3),
                                                    Color(hex: "#f59e0b").opacity(0.1),
                                                    Color.clear
                                                ],
                                                center: .center,
                                                startRadius: 0,
                                                endRadius: 50
                                            )
                                        )
                                        .frame(width: 100, height: 100)
                                    
                                    // Inner circle
                                    Circle()
                                        .fill(
                                            LinearGradient(
                                                colors: [
                                                    Color(hex: "#fbbf24").opacity(0.2),
                                                    Color(hex: "#f59e0b").opacity(0.15)
                                                ],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .frame(width: 70, height: 70)
                                    
                                    Image(systemName: "crown.fill")
                                        .font(.system(size: 36))
                                        .foregroundStyle(
                                            LinearGradient(
                                                colors: [
                                                    Color(hex: "#fbbf24"),
                                                    Color(hex: "#f59e0b")
                                                ],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .shadow(color: Color(hex: "#fbbf24").opacity(0.5), radius: 10)
                                }
                                
                                Text(L10n.Paywall.title)
                                    .font(.system(size: 26, weight: .bold))
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [.white, Color.white.opacity(0.9)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                
                                Text(L10n.Paywall.subtitle)
                                    .font(.system(size: 14))
                                    .foregroundColor(.white.opacity(0.6))
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 32)
                            }
                            .padding(.top, 4)
                            
                            // Subscription Plans
                            if paywallService.isLoadingProducts {
                                ProgressView()
                                    .tint(.white)
                                    .padding()
                            } else if !paywallService.availableProducts.isEmpty {
                                VStack(spacing: 10) {
                                    ForEach(paywallService.availableProducts, id: \.id) { product in
                                        PremiumSubscriptionPlanCard(
                                            product: product,
                                            isSelected: selectedProduct?.id == product.id
                                        ) {
                                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                                selectedProduct = product
                                            }
                                        }
                                    }
                                }
                                .padding(.horizontal, 20)
                            } else {
                                // No products available
                                VStack(spacing: 12) {
                                    Image(systemName: "exclamationmark.triangle")
                                        .font(.system(size: 32))
                                        .foregroundColor(Color(hex: "#fbbf24"))
                                    
                                    Text(L10n.Paywall.productsNotAvailable)
                                        .font(.headline)
                                        .foregroundColor(.white)
                                    
                                    #if DEBUG
                                    Text(L10n.Paywall.storekitConfigError)
                                        .font(.caption)
                                        .foregroundColor(.white.opacity(0.6))
                                    #endif
                                }
                                .padding()
                            }
                            
                            // Features - Full version with descriptions
                            VStack(spacing: 12) {
                                PremiumFeatureRow(
                                    icon: "infinity",
                                    title: L10n.Paywall.featureUnlimitedSubscriptions,
                                    description: L10n.Paywall.featureUnlimitedSubscriptionsDesc
                                )
                                
                                PremiumFeatureRow(
                                    icon: "folder.fill",
                                    title: L10n.Paywall.featureUnlimitedCategories,
                                    description: L10n.Paywall.featureUnlimitedCategoriesDesc
                                )
                                
                                PremiumFeatureRow(
                                    icon: "bell.fill",
                                    title: L10n.Paywall.featureSmartNotifications,
                                    description: L10n.Paywall.featureSmartNotificationsDesc
                                )
                                
                                PremiumFeatureRow(
                                    icon: "icloud.fill",
                                    title: L10n.Paywall.featureiCloudSync,
                                    description: L10n.Paywall.featureiCloudSyncDesc
                                )
                                
                                PremiumFeatureRow(
                                    icon: "chart.bar.fill",
                                    title: L10n.Paywall.featureAdvancedStats,
                                    description: L10n.Paywall.featureAdvancedStatsDesc
                                )
                            }
                            .padding(.horizontal, 24)
                            .padding(.top, 4)
                            
                            // Purchase button
                            VStack(spacing: 10) {
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
                                            Text(selectedProduct != nil ? L10n.Paywall.buttonPurchase : L10n.Paywall.buttonSelectPlan)
                                                .font(.system(size: 17, weight: .semibold))
                                        }
                                    }
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 52)
                                    .background(
                                        Group {
                                            if selectedProduct != nil {
                                                LinearGradient(
                                                    colors: [
                                                        Color(hex: "#fbbf24"),
                                                        Color(hex: "#f59e0b"),
                                                        Color(hex: "#d97706")
                                                    ],
                                                    startPoint: .leading,
                                                    endPoint: .trailing
                                                )
                                            } else {
                                                LinearGradient(
                                                    colors: [Color.white.opacity(0.15), Color.white.opacity(0.1)],
                                                    startPoint: .leading,
                                                    endPoint: .trailing
                                                )
                                            }
                                        }
                                    )
                                    .foregroundColor(.white)
                                    .cornerRadius(16)
                                    .shadow(
                                        color: selectedProduct != nil ? Color(hex: "#fbbf24").opacity(0.6) : .clear,
                                        radius: 20,
                                        y: 10
                                    )
                                }
                                .disabled(isPurchasing || selectedProduct == nil)
                                .scaleEffect(selectedProduct != nil ? 1.0 : 0.98)
                                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: selectedProduct != nil)
                                
                                Button {
                                    Task {
                                        await restorePurchases()
                                    }
                                } label: {
                                    Text(L10n.Paywall.buttonRestore)
                                        .font(.system(size: 13))
                                        .foregroundColor(.white.opacity(0.5))
                                }
                                .disabled(isPurchasing)
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 8)
                            .padding(.bottom, 20)
                        }
                    }
                }
            }
            .toast($toast)
            .task {
                await paywallService.loadProducts()
                // Auto-select yearly plan if available
                if let yearlyProduct = paywallService.availableProducts.first(where: { $0.id == SubscriptionPlan.yearly.rawValue }) {
                    selectedProduct = yearlyProduct
                } else {
                    selectedProduct = paywallService.availableProducts.first
                }
            }
            .onAppear {
                // Track paywall view with source
                AnalyticsService.shared.trackPaywallViewed(source: source)
            }
        }
    }
    
    // MARK: - Actions
    
    private func purchasePro() async {
        guard let product = selectedProduct else { return }
        
        // Track purchase started
        AnalyticsService.shared.trackPurchaseStarted(productId: product.id)
        
        isPurchasing = true
        defer { isPurchasing = false }
        
        do {
            let success = try await paywallService.purchase(product)
            if success {
                // Track purchase completed
                AnalyticsService.shared.trackPurchaseCompleted(
                    productId: product.id,
                    price: Double(truncating: product.price as NSNumber),
                    currency: product.priceFormatStyle.currencyCode ?? "USD"
                )
                
                toast = .success(L10n.Toast.purchaseSuccess)
                
                // Dismiss after a short delay
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                dismiss()
            }
        } catch {
            // Track purchase failed
            AnalyticsService.shared.trackPurchaseFailed(
                productId: product.id,
                error: error.localizedDescription
            )
            
            toast = .error(L10n.Toast.purchaseFailed(error.localizedDescription))
        }
    }
    
    private func restorePurchases() async {
        isPurchasing = true
        defer { isPurchasing = false }
        
        do {
            let success = try await paywallService.restorePurchases()
            if success {
                // Track restore success
                AnalyticsService.shared.trackPurchaseRestored()
                
                toast = .success(L10n.Toast.restoreSuccess)
                
                // Dismiss after a short delay
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                dismiss()
            } else {
                toast = .error(L10n.Toast.restoreFailed(L10n.Paywall.errorNoActivePurchase))
            }
        } catch {
            toast = .error(L10n.Toast.restoreFailed(error.localizedDescription))
        }
    }
}

// MARK: - Premium Subscription Plan Card

private struct PremiumSubscriptionPlanCard: View {
    let product: Product
    let isSelected: Bool
    let onSelect: () -> Void
    
    private var plan: SubscriptionPlan? {
        SubscriptionPlan(rawValue: product.id)
    }
    
    private var savingsText: String? {
        guard plan == .yearly else { return nil }
        return L10n.Paywall.planYearlySavings
    }
    
    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 14) {
                // Radio button
                ZStack {
                    Circle()
                        .strokeBorder(
                            isSelected ?
                            LinearGradient(
                                colors: [Color(hex: "#fbbf24"), Color(hex: "#f59e0b")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ) :
                            LinearGradient(
                                colors: [Color.white.opacity(0.3), Color.white.opacity(0.2)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2
                        )
                        .frame(width: 22, height: 22)
                    
                    if isSelected {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color(hex: "#fbbf24"), Color(hex: "#f59e0b")],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 12, height: 12)
                            .shadow(color: Color(hex: "#fbbf24").opacity(0.6), radius: 4)
                    }
                }
                
                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 8) {
                        Text(plan?.displayName ?? product.displayName)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                        
                        if let savingsText = savingsText {
                            Text(savingsText)
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(
                                    Capsule()
                                        .fill(
                                            LinearGradient(
                                                colors: [Color(hex: "#10b981"), Color(hex: "#059669")],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                )
                                .shadow(color: Color(hex: "#10b981").opacity(0.4), radius: 4)
                        }
                    }
                    
                    // 只显示 duration，不显示 monthly price
                    Text(plan?.duration ?? "")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.5))
                }
                
                Spacer()
                
                Text(product.displayPrice)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.white, Color.white.opacity(0.9)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(
                        isSelected ?
                        LinearGradient(
                            colors: [
                                Color(hex: "#fbbf24").opacity(0.15),
                                Color(hex: "#f59e0b").opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ) :
                        LinearGradient(
                            colors: [Color.white.opacity(0.08), Color.white.opacity(0.04)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .strokeBorder(
                                isSelected ?
                                LinearGradient(
                                    colors: [Color(hex: "#fbbf24"), Color(hex: "#f59e0b")],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ) :
                                LinearGradient(
                                    colors: [Color.white.opacity(0.15), Color.white.opacity(0.08)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: isSelected ? 1.5 : 1
                            )
                    )
            )
            .shadow(
                color: isSelected ? Color(hex: "#fbbf24").opacity(0.4) : .clear,
                radius: 16,
                y: 8
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func calculateMonthlyPrice() -> String? {
        guard let price = Decimal(string: product.price.description) else { return nil }
        let monthlyPrice = price / 12
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = product.priceFormatStyle.locale
        return formatter.string(from: monthlyPrice as NSDecimalNumber).map { "\($0)/\(L10n.Paywall.planMonthlyShort)" }
    }
}

// MARK: - Premium Feature Row

private struct PremiumFeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(hex: "#fbbf24").opacity(0.2),
                                Color(hex: "#f59e0b").opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 36, height: 36)
                
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color(hex: "#fbbf24"), Color(hex: "#f59e0b")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                
                Text(description)
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.6))
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer(minLength: 0)
        }
    }
}

#Preview {
    PaywallView()
        .environmentObject(PaywallService.shared)
}
