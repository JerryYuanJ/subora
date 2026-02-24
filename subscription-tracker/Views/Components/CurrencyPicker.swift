//
//  CurrencyPicker.swift
//  subscription-tracker
//
//  Created by Kiro on 2026/2/24.
//

import SwiftUI

/// 货币选择器组件
/// 提供下拉选择支持的货币
struct CurrencyPicker: View {
    @Binding var selectedCurrency: String
    
    var body: some View {
        Picker("货币", selection: $selectedCurrency) {
            ForEach(CurrencyFormatter.supportedCurrencies, id: \.self) { currency in
                HStack {
                    Text(CurrencyFormatter.symbol(for: currency))
                    Text(currency)
                }
                .tag(currency)
            }
        }
        .pickerStyle(.menu)
    }
}

#Preview {
    @Previewable @State var currency = "USD"
    
    Form {
        CurrencyPicker(selectedCurrency: $currency)
    }
}
