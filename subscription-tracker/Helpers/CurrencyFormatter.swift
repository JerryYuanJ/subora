//
//  CurrencyFormatter.swift
//  subscription-tracker
//
//  Created by Kiro on 2024-01-15.
//

import Foundation

/// 货币格式化工具
/// 提供货币格式化和符号获取功能，支持多种国际货币
struct CurrencyFormatter {
    
    // MARK: - Supported Currencies
    
    /// 支持的货币列表
    static let supportedCurrencies = ["USD", "CNY", "EUR", "GBP", "JPY", "HKD", "TWD"]
    
    // MARK: - Public Methods
    
    /// 格式化金额为货币字符串
    /// - Parameters:
    ///   - amount: 金额（Decimal 类型）
    ///   - currency: 货币代码（如 "USD", "CNY"）
    /// - Returns: 格式化后的货币字符串（如 "$15.99", "¥89.00"）
    static func format(amount: Decimal, currency: String) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currency
        formatter.locale = localeForCurrency(currency)
        
        // 将 Decimal 转换为 NSDecimalNumber 以便 NumberFormatter 使用
        let nsDecimalNumber = NSDecimalNumber(decimal: amount)
        
        return formatter.string(from: nsDecimalNumber) ?? "\(symbol(for: currency))\(amount)"
    }
    
    /// 获取货币符号
    /// - Parameter currency: 货币代码（如 "USD", "CNY"）
    /// - Returns: 货币符号（如 "$", "¥"）
    static func symbol(for currency: String) -> String {
        let locale = localeForCurrency(currency)
        return locale.currencySymbol ?? currency
    }
    
    // MARK: - Private Methods
    
    /// 根据货币代码获取合适的 Locale
    /// - Parameter currency: 货币代码
    /// - Returns: 对应的 Locale
    private static func localeForCurrency(_ currency: String) -> Locale {
        switch currency {
        case "USD":
            return Locale(identifier: "en_US")
        case "CNY":
            return Locale(identifier: "zh_CN")
        case "EUR":
            return Locale(identifier: "en_EU")
        case "GBP":
            return Locale(identifier: "en_GB")
        case "JPY":
            return Locale(identifier: "ja_JP")
        case "HKD":
            return Locale(identifier: "zh_HK")
        case "TWD":
            return Locale(identifier: "zh_TW")
        default:
            return Locale.current
        }
    }
}
