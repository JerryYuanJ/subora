//
//  BillingCyclePicker.swift
//  subscription-tracker
//
//  Created by Kiro on 2026/2/24.
//

import SwiftUI

/// 计费周期选择器组件
/// 允许用户选择周期数值和单位（日/周/月/年）
struct BillingCyclePicker: View {
    @Binding var cycle: Int
    @Binding var unit: BillingCycleUnit
    
    var body: some View {
        HStack(spacing: 12) {
            // 周期数值选择器
            Stepper(value: $cycle, in: 1...99) {
                HStack {
                    Text("每")
                    Text("\(cycle)")
                        .font(.headline)
                        .foregroundColor(.primary)
                }
            }
            
            // 单位选择器
            Picker("单位", selection: $unit) {
                ForEach(BillingCycleUnit.allCases, id: \.self) { unit in
                    Text(unit.displayName).tag(unit)
                }
            }
            .pickerStyle(.menu)
            .frame(maxWidth: 100)
        }
    }
}

#Preview {
    @Previewable @State var cycle = 1
    @Previewable @State var unit = BillingCycleUnit.month
    
    Form {
        Section("计费周期") {
            BillingCyclePicker(cycle: $cycle, unit: $unit)
        }
    }
}
