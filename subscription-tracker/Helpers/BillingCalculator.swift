//
//  BillingCalculator.swift
//  subscription-tracker
//
//  Created by Kiro on 2026/2/24.
//

import Foundation

/// 计费周期计算器，处理订阅续费日期计算和月度金额转换
struct BillingCalculator {
    
    /// 计算下次续费日期
    /// - Parameters:
    ///   - firstPaymentDate: 首次付款日期
    ///   - cycle: 计费周期数值（如 1, 3, 6, 12）
    ///   - unit: 计费周期单位（日、周、月、年）
    /// - Returns: 下次续费日期
    static func calculateNextBillingDate(
        from firstPaymentDate: Date,
        cycle: Int,
        unit: BillingCycleUnit
    ) -> Date {
        let calendar = Calendar.current
        let now = Date()
        
        // 获取今天的开始时间（忽略时分秒）
        let today = calendar.startOfDay(for: now)
        let firstPaymentDay = calendar.startOfDay(for: firstPaymentDate)
        
        // 如果首次付款日期在今天或未来，直接返回
        if firstPaymentDay >= today {
            return firstPaymentDate
        }
        
        var currentDate = firstPaymentDay
        
        // 循环计算直到找到今天或未来的日期
        while currentDate < today {
            currentDate = addBillingCycle(to: currentDate, cycle: cycle, unit: unit, calendar: calendar)
        }
        
        return currentDate
    }
    
    /// 计算从首次付款到指定日期的所有续费日期
    /// - Parameters:
    ///   - firstPaymentDate: 首次付款日期
    ///   - cycle: 计费周期数值
    ///   - unit: 计费周期单位
    ///   - endDate: 结束日期
    /// - Returns: 所有续费日期数组
    static func calculateAllBillingDates(
        from firstPaymentDate: Date,
        cycle: Int,
        unit: BillingCycleUnit,
        until endDate: Date
    ) -> [Date] {
        let calendar = Calendar.current
        var dates: [Date] = [firstPaymentDate]
        var currentDate = firstPaymentDate
        
        while currentDate < endDate {
            currentDate = addBillingCycle(to: currentDate, cycle: cycle, unit: unit, calendar: calendar)
            if currentDate <= endDate {
                dates.append(currentDate)
            }
        }
        
        return dates
    }
    
    /// 将订阅金额转换为月度等效金额
    /// - Parameters:
    ///   - amount: 订阅金额
    ///   - cycle: 计费周期数值
    ///   - unit: 计费周期单位
    /// - Returns: 月度等效金额
    static func convertToMonthlyAmount(
        amount: Decimal,
        cycle: Int,
        unit: BillingCycleUnit
    ) -> Decimal {
        let cycleDecimal = Decimal(cycle)
        
        switch unit {
        case .day:
            // 每日 -> 每月：金额 * 周期 * 30.44 (平均每月天数)
            return amount * cycleDecimal * Decimal(30.44)
        case .week:
            // 每周 -> 每月：金额 * 周期 * 4.33 (平均每月周数)
            return amount * cycleDecimal * Decimal(4.33)
        case .month:
            // 每月 -> 每月：金额 * 周期
            return amount * cycleDecimal
        case .year:
            // 每年 -> 每月：金额 * 周期 / 12
            return (amount * cycleDecimal) / 12
        }
    }
    
    // MARK: - Public Helpers
    
    /// 添加一个计费周期到指定日期
    public static func addBillingCycle(
        to date: Date,
        cycle: Int,
        unit: BillingCycleUnit
    ) -> Date {
        let calendar = Calendar.current
        switch unit {
        case .day:
            return calendar.date(byAdding: .day, value: cycle, to: date) ?? date
        case .week:
            return calendar.date(byAdding: .weekOfYear, value: cycle, to: date) ?? date
        case .month:
            return addMonths(to: date, months: cycle, calendar: calendar)
        case .year:
            return addYears(to: date, years: cycle, calendar: calendar)
        }
    }
    
    // MARK: - Private Helpers
    
    /// 添加一个计费周期到指定日期
    private static func addBillingCycle(
        to date: Date,
        cycle: Int,
        unit: BillingCycleUnit,
        calendar: Calendar
    ) -> Date {
        switch unit {
        case .day:
            return calendar.date(byAdding: .day, value: cycle, to: date) ?? date
        case .week:
            return calendar.date(byAdding: .weekOfYear, value: cycle, to: date) ?? date
        case .month:
            return addMonths(to: date, months: cycle, calendar: calendar)
        case .year:
            return addYears(to: date, years: cycle, calendar: calendar)
        }
    }
    
    /// 添加月份，处理月末边界情况
    private static func addMonths(to date: Date, months: Int, calendar: Calendar) -> Date {
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        guard let year = components.year,
              let month = components.month,
              let day = components.day else {
            return date
        }
        
        // 计算目标年月
        var targetMonth = month + months
        var targetYear = year
        
        while targetMonth > 12 {
            targetMonth -= 12
            targetYear += 1
        }
        
        while targetMonth < 1 {
            targetMonth += 12
            targetYear -= 1
        }
        
        // 处理月末日期
        return adjustForMonthEnd(date: date, targetMonth: targetMonth, targetYear: targetYear, originalDay: day, calendar: calendar)
    }
    
    /// 添加年份，处理闰年边界情况
    private static func addYears(to date: Date, years: Int, calendar: Calendar) -> Date {
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        guard let year = components.year,
              let month = components.month,
              let day = components.day else {
            return date
        }
        
        let targetYear = year + years
        
        // 处理 2 月 29 日的闰年情况
        if month == 2 && day == 29 && !isLeapYear(targetYear) {
            // 非闰年使用 2 月 28 日
            var newComponents = DateComponents()
            newComponents.year = targetYear
            newComponents.month = 2
            newComponents.day = 28
            return calendar.date(from: newComponents) ?? date
        }
        
        return adjustForMonthEnd(date: date, targetMonth: month, targetYear: targetYear, originalDay: day, calendar: calendar)
    }
    
    /// 处理月末日期调整
    private static func adjustForMonthEnd(
        date: Date,
        targetMonth: Int,
        targetYear: Int,
        originalDay: Int,
        calendar: Calendar
    ) -> Date {
        // 获取目标月份的天数
        var components = DateComponents()
        components.year = targetYear
        components.month = targetMonth
        components.day = 1
        
        guard let firstDayOfMonth = calendar.date(from: components),
              let range = calendar.range(of: .day, in: .month, for: firstDayOfMonth) else {
            return date
        }
        
        let daysInMonth = range.count
        
        // 如果原日期超出目标月份的天数，使用该月最后一天
        let targetDay = min(originalDay, daysInMonth)
        
        components.day = targetDay
        return calendar.date(from: components) ?? date
    }
    
    /// 检查是否为闰年
    private static func isLeapYear(_ year: Int) -> Bool {
        // 能被 400 整除，或者能被 4 整除但不能被 100 整除
        return (year % 400 == 0) || (year % 4 == 0 && year % 100 != 0)
    }
}
