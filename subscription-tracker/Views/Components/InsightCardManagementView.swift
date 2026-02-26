//
//  InsightCardManagementView.swift
//  subscription-tracker
//
//  Created by Kiro on 2026/2/26.
//

import SwiftUI

/// Drawer view for managing visible insight cards
struct InsightCardManagementView: View {
    @ObservedObject var viewModel: InsightsViewModel
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var paywallService: PaywallService
    @State private var showPaywall = false
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(InsightCardType.allCases) { cardType in
                    Button {
                        handleCardTap(cardType)
                    } label: {
                        HStack(spacing: 16) {
                            // Icon
                            ZStack {
                                Circle()
                                    .fill(cardType.color.opacity(0.15))
                                    .frame(width: 44, height: 44)
                                
                                Image(systemName: cardType.icon)
                                    .font(.system(size: 18))
                                    .foregroundColor(cardType.color)
                            }
                            
                            // Title
                            Text(cardType.title)
                                .font(.body)
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            // Pro badge or checkmark
                            if cardType.requiresPro && !paywallService.isProUser {
                                Image(systemName: "crown.fill")
                                    .font(.system(size: 16))
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [Color(hex: "#fbbf24"), Color(hex: "#f59e0b")],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                            } else if viewModel.isCardVisible(cardType) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 24))
                                    .foregroundColor(cardType.color)
                            } else {
                                Image(systemName: "circle")
                                    .font(.system(size: 24))
                                    .foregroundColor(.gray.opacity(0.3))
                            }
                        }
                        .padding(.vertical, 8)
                    }
                    .buttonStyle(.plain)
                }
            }
            .navigationTitle(L10n.Insights.manageCards)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(L10n.Common.done) {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showPaywall) {
                PaywallView()
                    .environmentObject(paywallService)
            }
        }
    }
    
    private func handleCardTap(_ cardType: InsightCardType) {
        // Check if card requires Pro and user is not Pro
        if cardType.requiresPro && !paywallService.isProUser {
            showPaywall = true
        } else {
            viewModel.toggleCard(cardType)
        }
    }
}
