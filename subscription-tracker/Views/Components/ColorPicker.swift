//
//  ColorPicker.swift
//  subscription-tracker
//
//  Created by Kiro on 2026/2/24.
//

import SwiftUI

/// 颜色选择器组件
/// 用于分类颜色选择，提供预设颜色选项
struct ColorPickerView: View {
    @Binding var selectedColorHex: String
    
    // 预设颜色列表
    private let presetColors: [(hex: String, name: String)] = [
        ("#FF3B30", "红色"),
        ("#FF9500", "橙色"),
        ("#FFCC00", "黄色"),
        ("#34C759", "绿色"),
        ("#007AFF", "蓝色"),
        ("#5856D6", "紫色"),
        ("#AF52DE", "粉紫"),
        ("#FF2D55", "粉红"),
        ("#A2845E", "棕色"),
        ("#8E8E93", "灰色"),
        ("#00C7BE", "青色"),
        ("#32ADE6", "天蓝")
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("选择颜色")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            LazyVGrid(columns: [
                GridItem(.adaptive(minimum: 50), spacing: 12)
            ], spacing: 12) {
                ForEach(presetColors, id: \.hex) { colorItem in
                    ColorButton(
                        colorHex: colorItem.hex,
                        colorName: colorItem.name,
                        isSelected: selectedColorHex == colorItem.hex
                    ) {
                        selectedColorHex = colorItem.hex
                    }
                }
            }
        }
    }
}

/// 颜色按钮
private struct ColorButton: View {
    let colorHex: String
    let colorName: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(Color(hex: colorHex))
                    .frame(width: 50, height: 50)
                
                if isSelected {
                    Circle()
                        .strokeBorder(Color.primary, lineWidth: 3)
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: "checkmark")
                        .foregroundColor(.white)
                        .font(.system(size: 20, weight: .bold))
                        .shadow(color: .black.opacity(0.3), radius: 2)
                }
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(colorName)
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
    }
}

#Preview {
    @Previewable @State var selectedColor = "#007AFF"
    
    Form {
        Section {
            ColorPickerView(selectedColorHex: $selectedColor)
        }
    }
}
