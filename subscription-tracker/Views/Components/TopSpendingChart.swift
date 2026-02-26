//
//  TopSpendingChart.swift
//  subscription-tracker
//
//  Created by Kiro on 2026/2/26.
//

import SwiftUI
import Charts

/// Bar chart showing top spending subscriptions
struct TopSpendingChart: View {
    let data: [TopSpendingItem]
    
    var body: some View {
        if data.isEmpty {
            emptyState
        } else {
            Chart {
                ForEach(Array(data.enumerated()), id: \.element.id) { index, item in
                    BarMark(
                        x: .value("Amount", NSDecimalNumber(decimal: item.monthlyAmount).doubleValue),
                        y: .value("Subscription", item.subscription.name)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [
                                Color(hex: "#FF375F"),
                                Color(hex: "#FF6B88")
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(6)
                }
            }
            .chartXAxis {
                AxisMarks(position: .bottom) { value in
                    AxisValueLabel {
                        if let doubleValue = value.as(Double.self) {
                            Text(formatAmount(Decimal(doubleValue)))
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading) { value in
                    AxisValueLabel {
                        if let stringValue = value.as(String.self) {
                            Text(stringValue)
                                .font(.caption)
                                .foregroundColor(.primary)
                                .lineLimit(1)
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
                    .fill(Color(hex: "#FF375F").opacity(0.15))
                    .frame(width: 64, height: 64)
                
                Image(systemName: "chart.bar.fill")
                    .font(.system(size: 28))
                    .foregroundColor(Color(hex: "#FF375F"))
            }
            
            Text(L10n.Insights.noData)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 200)
    }
    
    private func formatAmount(_ amount: Decimal) -> String {
        // Use the first item's currency
        guard let firstItem = data.first else { return "$0" }
        return CurrencyFormatter.format(amount: amount, currency: firstItem.subscription.currency)
    }
}
