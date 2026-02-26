//
//  CategoryBreakdownChart.swift
//  subscription-tracker
//
//  Created by Kiro on 2026/2/26.
//

import SwiftUI
import Charts

/// Pie chart showing category breakdown
struct CategoryBreakdownChart: View {
    let data: [CategoryExpense]
    
    private var totalAmount: Decimal {
        data.reduce(Decimal(0)) { $0 + $1.amount }
    }
    
    var body: some View {
        if data.isEmpty {
            emptyState
        } else {
            VStack(spacing: 16) {
                // Pie chart
                Chart(data) { item in
                    SectorMark(
                        angle: .value("Amount", NSDecimalNumber(decimal: item.amount).doubleValue),
                        innerRadius: .ratio(0.5),
                        angularInset: 2
                    )
                    .foregroundStyle(item.category?.color ?? .gray)
                }
                .frame(height: 200)
                
                // Legend
                VStack(spacing: 10) {
                    ForEach(data.prefix(5)) { item in
                        HStack(spacing: 12) {
                            Circle()
                                .fill(item.category?.color ?? .gray)
                                .frame(width: 12, height: 12)
                            
                            Text(item.category?.name ?? L10n.Subscription.noCategory)
                                .font(.subheadline)
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            VStack(alignment: .trailing, spacing: 2) {
                                Text(formatPercentage(item.amount))
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.primary)
                                
                                Text(L10n.Insights.subscriptionsCount(item.count))
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
            }
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color(hex: "#AF52DE").opacity(0.15))
                    .frame(width: 64, height: 64)
                
                Image(systemName: "chart.pie.fill")
                    .font(.system(size: 28))
                    .foregroundColor(Color(hex: "#AF52DE"))
            }
            
            Text(L10n.Insights.noData)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 200)
    }
    
    private func formatPercentage(_ amount: Decimal) -> String {
        guard totalAmount > 0 else { return "0%" }
        let percentage = (amount / totalAmount) * 100
        return String(format: "%.1f%%", NSDecimalNumber(decimal: percentage).doubleValue)
    }
}
