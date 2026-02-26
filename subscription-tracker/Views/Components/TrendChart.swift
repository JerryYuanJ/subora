//
//  TrendChart.swift
//  subscription-tracker
//
//  Created by Kiro on 2026/2/24.
//

import SwiftUI
import Charts

/// Trend chart component displaying monthly expense trends over the past 6 months
/// Supports multiple currencies with separate lines for each currency
struct TrendChart: View {
    
    // MARK: - Properties
    
    /// Trend data for past 6 months
    let trendData: [MonthlyExpense]
    
    // MARK: - Computed Properties
    
    /// Group trend data by currency
    private var dataGroupedByCurrency: [String: [MonthlyExpense]] {
        Dictionary(grouping: trendData, by: { $0.currency })
    }
    
    /// All unique currencies in the data
    private var currencies: [String] {
        Array(Set(trendData.map { $0.currency })).sorted()
    }
    
    /// Maximum amount across all data points for Y-axis scaling
    private var maxAmount: Decimal {
        trendData.map { $0.amount }.max() ?? 0
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if trendData.isEmpty {
                emptyStateView
            } else {
                chartView
                legendView
            }
        }
    }
    
    // MARK: - Chart View
    
    private var chartView: some View {
        Chart {
            ForEach(currencies, id: \.self) { currency in
                if let currencyData = dataGroupedByCurrency[currency] {
                    ForEach(currencyData) { expense in
                        LineMark(
                            x: .value("月份", expense.month, unit: .month),
                            y: .value("金额", Double(truncating: expense.amount as NSNumber))
                        )
                        .foregroundStyle(by: .value("货币", currency))
                        .symbol(by: .value("货币", currency))
                        .interpolationMethod(.catmullRom)
                        
                        PointMark(
                            x: .value("月份", expense.month, unit: .month),
                            y: .value("金额", Double(truncating: expense.amount as NSNumber))
                        )
                        .foregroundStyle(by: .value("货币", currency))
                    }
                }
            }
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: .month)) { value in
                if let date = value.as(Date.self) {
                    AxisValueLabel {
                        Text(monthLabel(for: date))
                            .font(.caption)
                    }
                    AxisGridLine()
                }
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading) { value in
                AxisValueLabel {
                    if let amount = value.as(Double.self) {
                        Text(formatAmount(amount))
                            .font(.caption)
                    }
                }
                AxisGridLine()
            }
        }
        .chartLegend(.hidden)
        .frame(height: 200)
    }
    
    // MARK: - Legend View
    
    private var legendView: some View {
        HStack(spacing: 16) {
            ForEach(currencies, id: \.self) { currency in
                HStack(spacing: 4) {
                    Circle()
                        .fill(colorForCurrency(currency))
                        .frame(width: 8, height: 8)
                    Text(currency)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
    
    // MARK: - Empty State View
    
    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            Text(L10n.Dashboard.noTrendData)
                .font(.headline)
                .foregroundColor(.secondary)
            Text(L10n.Dashboard.noTrendHint)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(height: 200)
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - Helper Methods
    
    /// Format month label for X-axis
    /// - Parameter date: The date to format
    /// - Returns: Formatted month string (e.g., "1月", "2月")
    private func monthLabel(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M月"
        return formatter.string(from: date)
    }
    
    /// Format amount for Y-axis
    /// - Parameter amount: The amount to format
    /// - Returns: Formatted amount string
    private func formatAmount(_ amount: Double) -> String {
        if amount >= 1000 {
            return String(format: "%.1fk", amount / 1000)
        } else {
            return String(format: "%.0f", amount)
        }
    }
    
    /// Get color for currency
    /// - Parameter currency: Currency code
    /// - Returns: Color for the currency line
    private func colorForCurrency(_ currency: String) -> Color {
        // Assign consistent colors to currencies
        let colorMap: [String: Color] = [
            "USD": .blue,
            "CNY": .red,
            "EUR": .green,
            "GBP": .purple,
            "JPY": .orange,
            "HKD": .pink,
            "TWD": .cyan
        ]
        return colorMap[currency] ?? .gray
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 20) {
        // Preview with data
        TrendChart(trendData: [
            MonthlyExpense(month: Calendar.current.date(byAdding: .month, value: -5, to: Date())!, amount: 120.50, currency: "USD"),
            MonthlyExpense(month: Calendar.current.date(byAdding: .month, value: -4, to: Date())!, amount: 135.75, currency: "USD"),
            MonthlyExpense(month: Calendar.current.date(byAdding: .month, value: -3, to: Date())!, amount: 142.30, currency: "USD"),
            MonthlyExpense(month: Calendar.current.date(byAdding: .month, value: -2, to: Date())!, amount: 128.90, currency: "USD"),
            MonthlyExpense(month: Calendar.current.date(byAdding: .month, value: -1, to: Date())!, amount: 156.20, currency: "USD"),
            MonthlyExpense(month: Date(), amount: 165.50, currency: "USD"),
            
            MonthlyExpense(month: Calendar.current.date(byAdding: .month, value: -5, to: Date())!, amount: 89.00, currency: "CNY"),
            MonthlyExpense(month: Calendar.current.date(byAdding: .month, value: -4, to: Date())!, amount: 95.50, currency: "CNY"),
            MonthlyExpense(month: Calendar.current.date(byAdding: .month, value: -3, to: Date())!, amount: 102.00, currency: "CNY"),
            MonthlyExpense(month: Calendar.current.date(byAdding: .month, value: -2, to: Date())!, amount: 89.00, currency: "CNY"),
            MonthlyExpense(month: Calendar.current.date(byAdding: .month, value: -1, to: Date())!, amount: 110.50, currency: "CNY"),
            MonthlyExpense(month: Date(), amount: 125.00, currency: "CNY")
        ])
        .padding()
        
        // Preview with empty state
        TrendChart(trendData: [])
            .padding()
    }
}
