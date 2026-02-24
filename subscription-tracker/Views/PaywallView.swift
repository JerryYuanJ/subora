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
                        
                        Text("升级到 Pro 版本")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text("解锁所有功能，无限制管理订阅")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 32)
                    
                    // Features list
                    VStack(alignment: .leading, spacing: 16) {
                        FeatureRow(
                            icon: "infinity",
                            title: "无限订阅",
                            description: "创建无限数量的订阅记录"
                        )
                        
                        FeatureRow(
                            icon: "folder.fill",
                            title: "无限分类",
                            description: "创建无限数量的自定义分类"
                        )
                        
                        FeatureRow(
                            icon: "icloud.fill",
                            title: "iCloud 同步",
                            description: "在所有设备间同步数据"
                        )
                        
                        FeatureRow(
                            icon: "bell.fill",
                            title: "智能提醒",
                            description: "自定义续费提醒通知"
                        )
                        
                        FeatureRow(
                            icon: "chart.line.uptrend.xyaxis",
                            title: "高级统计",
                            description: "查看详细的支出趋势和分析"
                        )
                        
                        FeatureRow(
                            icon: "paintbrush.fill",
                            title: "主题定制",
                            description: "自定义应用主题颜色"
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
                                    Text("购买 Pro 版本")
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
                            Text("恢复购买")
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
                    Button("关闭") {
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
            try await paywallService.purchaseProVersion()
            toast = .success("购买成功！")
            
            // Dismiss after a short delay
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            dismiss()
        } catch {
            toast = .error("购买失败：\(error.localizedDescription)")
        }
    }
    
    private func restorePurchases() async {
        isPurchasing = true
        defer { isPurchasing = false }
        
        do {
            try await paywallService.restorePurchases()
            toast = .success("恢复成功！")
            
            // Dismiss after a short delay
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            dismiss()
        } catch {
            toast = .error("恢复失败：\(error.localizedDescription)")
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
