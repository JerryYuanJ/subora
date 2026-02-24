//
//  Color+Hex.swift
//  subscription-tracker
//
//  Created by Kiro on 2026/2/24.
//

import SwiftUI

extension Color {
    /// 从十六进制字符串创建 Color
    /// - Parameter hex: 十六进制颜色字符串，格式如 "#RRGGBB" 或 "RRGGBB"
    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        guard hexSanitized.count == 6 else {
            return nil
        }
        
        var rgb: UInt64 = 0
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else {
            return nil
        }
        
        let red = Double((rgb & 0xFF0000) >> 16) / 255.0
        let green = Double((rgb & 0x00FF00) >> 8) / 255.0
        let blue = Double(rgb & 0x0000FF) / 255.0
        
        self.init(red: red, green: green, blue: blue)
    }
    
    /// 将 Color 转换为十六进制字符串
    /// - Returns: 十六进制颜色字符串，格式如 "#RRGGBB"
    func toHex() -> String? {
        guard let components = UIColor(self).cgColor.components,
              components.count >= 3 else {
            return nil
        }
        
        let red = Int(components[0] * 255.0)
        let green = Int(components[1] * 255.0)
        let blue = Int(components[2] * 255.0)
        
        return String(format: "#%02X%02X%02X", red, green, blue)
    }
}
