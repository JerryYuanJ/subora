//
//  ColorPicker.swift
//  subscription-tracker
//
//  Created by Kiro on 2026/2/24.
//

import SwiftUI

/// 颜色选择器组件
/// 用于分类颜色选择，提供预设颜色选项和自定义颜色
struct ColorPickerView: View {
    @Binding var selectedColorHex: String
    @State private var showCustomColorPicker = false
    
    // 预设颜色列表
    private let presetColors: [(hex: String, name: String)] = [
        ("#FF3B30", L10n.Color.red),
        ("#FF9500", L10n.Color.orange),
        ("#FFCC00", L10n.Color.yellow),
        ("#34C759", L10n.Color.green),
        ("#007AFF", L10n.Color.blue),
        ("#5856D6", L10n.Color.purple),
        ("#AF52DE", L10n.Color.pinkPurple),
        ("#FF2D55", L10n.Color.pink),
        ("#A2845E", L10n.Color.brown),
        ("#8E8E93", L10n.Color.gray),
        ("#00C7BE", L10n.Color.cyan),
        ("#32ADE6", L10n.Color.skyBlue)
    ]
    
    private var isCustomColor: Bool {
        !presetColors.contains(where: { $0.hex.uppercased() == selectedColorHex.uppercased() })
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(L10n.ColorPicker.title)
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
                
                // Custom color button
                Button {
                    showCustomColorPicker = true
                } label: {
                    CustomColorButton(
                        isSelected: isCustomColor,
                        currentColor: Color(hex: selectedColorHex)
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .background(
            ColorPickerPresenter(
                isPresented: $showCustomColorPicker,
                selectedColorHex: $selectedColorHex
            )
        )
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

/// 自定义颜色按钮
private struct CustomColorButton: View {
    let isSelected: Bool
    let currentColor: Color
    
    var body: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [.red, .orange, .yellow, .green, .blue, .purple, .pink],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 50, height: 50)
            
            if isSelected {
                Circle()
                    .fill(currentColor)
                    .frame(width: 40, height: 40)
                
                Circle()
                    .strokeBorder(Color.primary, lineWidth: 3)
                    .frame(width: 50, height: 50)
            }
            
            Image(systemName: "eyedropper.halffull")
                .foregroundColor(.white)
                .font(.system(size: 20, weight: .bold))
                .shadow(color: .black.opacity(0.3), radius: 2)
        }
        .accessibilityLabel(L10n.ColorPicker.custom)
    }
}

/// UIColorPickerViewController 包装器
struct ColorPickerPresenter: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    @Binding var selectedColorHex: String
    
    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        if isPresented && context.coordinator.colorPicker == nil {
            let colorPicker = UIColorPickerViewController()
            colorPicker.selectedColor = UIColor(Color(hex: selectedColorHex))
            colorPicker.delegate = context.coordinator
            colorPicker.supportsAlpha = false
            
            context.coordinator.colorPicker = colorPicker
            
            DispatchQueue.main.async {
                uiViewController.present(colorPicker, animated: true)
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(isPresented: $isPresented, selectedColorHex: $selectedColorHex)
    }
    
    class Coordinator: NSObject, UIColorPickerViewControllerDelegate {
        @Binding var isPresented: Bool
        @Binding var selectedColorHex: String
        var colorPicker: UIColorPickerViewController?
        
        init(isPresented: Binding<Bool>, selectedColorHex: Binding<String>) {
            _isPresented = isPresented
            _selectedColorHex = selectedColorHex
        }
        
        func colorPickerViewControllerDidFinish(_ viewController: UIColorPickerViewController) {
            if let hex = Color(uiColor: viewController.selectedColor).toHex() {
                selectedColorHex = hex
            }
            isPresented = false
            colorPicker = nil
        }
        
        func colorPickerViewController(_ viewController: UIColorPickerViewController, didSelect color: UIColor, continuously: Bool) {
            if !continuously {
                if let hex = Color(uiColor: color).toHex() {
                    selectedColorHex = hex
                }
            }
        }
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
