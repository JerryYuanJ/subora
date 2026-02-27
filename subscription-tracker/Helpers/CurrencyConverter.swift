//
//  CurrencyConverter.swift
//  subscription-tracker
//
//  Created by Kiro on 2026/2/27.
//

import Foundation

/// Currency converter with hardcoded exchange rates
/// All rates are relative to USD as base currency
struct CurrencyConverter {
    
    // MARK: - Exchange Rates (relative to USD)
    
    /// Exchange rates updated as of 2026-02
    /// Note: These are approximate rates for estimation purposes
    private static let exchangeRates: [String: Decimal] = [
        "USD": 1.0,
        "CNY": 7.2,      // 1 USD = 7.2 CNY
        "EUR": 0.92,     // 1 USD = 0.92 EUR
        "GBP": 0.79,     // 1 USD = 0.79 GBP
        "JPY": 149.0,    // 1 USD = 149 JPY
        "HKD": 7.8,      // 1 USD = 7.8 HKD
        "TWD": 31.5      // 1 USD = 31.5 TWD
    ]
    
    // MARK: - Public Methods
    
    /// Convert amount from one currency to another
    /// - Parameters:
    ///   - amount: Amount to convert
    ///   - fromCurrency: Source currency code
    ///   - toCurrency: Target currency code
    /// - Returns: Converted amount in target currency
    static func convert(amount: Decimal, from fromCurrency: String, to toCurrency: String) -> Decimal {
        // If same currency, no conversion needed
        guard fromCurrency != toCurrency else { return amount }
        
        // Get exchange rates
        guard let fromRate = exchangeRates[fromCurrency],
              let toRate = exchangeRates[toCurrency] else {
            // If currency not found, return original amount
            return amount
        }
        
        // Convert to USD first, then to target currency
        // Formula: amount / fromRate * toRate
        let amountInUSD = amount / fromRate
        let convertedAmount = amountInUSD * toRate
        
        return convertedAmount
    }
    
    /// Check if a currency is supported
    /// - Parameter currency: Currency code to check
    /// - Returns: True if currency is supported
    static func isSupported(_ currency: String) -> Bool {
        return exchangeRates.keys.contains(currency)
    }
    
    /// Get all supported currencies
    /// - Returns: Array of supported currency codes
    static var supportedCurrencies: [String] {
        return Array(exchangeRates.keys).sorted()
    }
}
