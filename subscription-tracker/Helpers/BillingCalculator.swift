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

        // 使用数学公式计算需要跳过的完整周期数，避免 O(n) 循环
        let skipCycles: Int
        switch unit {
        case .day:
            let daysBetween = calendar.dateComponents([.day], from: firstPaymentDay, to: today).day ?? 0
            skipCycles = max(0, daysBetween / cycle)
        case .week:
            let daysBetween = calendar.dateComponents([.day], from: firstPaymentDay, to: today).day ?? 0
            skipCycles = max(0, daysBetween / (cycle * 7))
        case .month:
            let monthsBetween = calendar.dateComponents([.month], from: firstPaymentDay, to: today).month ?? 0
            skipCycles = max(0, monthsBetween / cycle)
        case .year:
            let yearsBetween = calendar.dateComponents([.year], from: firstPaymentDay, to: today).year ?? 0
            skipCycles = max(0, yearsBetween / cycle)
        }

        // 跳到接近目标的位置，然后最多迭代 1-2 次
        var currentDate = addBillingCycle(to: firstPaymentDay, cycle: cycle * skipCycles, unit: unit, calendar: calendar)
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
            // 每 N 天付一次 -> 每月：金额 / 周期 * 30.44
            return amount / cycleDecimal * Decimal(30.44)
        case .week:
            // 每 N 周付一次 -> 每月：金额 / 周期 * 4.33
            return amount / cycleDecimal * Decimal(4.33)
        case .month:
            // 每 N 月付一次 -> 每月：金额 / 周期
            return amount / cycleDecimal
        case .year:
            // 每 N 年付一次 -> 每月：金额 / (周期 * 12)
            return amount / (cycleDecimal * 12)
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
    
    /// 添加月份，处理月末边界情况（保持原始日期）
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
        
        // 获取目标月份的最大天数
        var targetComponents = DateComponents()
        targetComponents.year = targetYear
        targetComponents.month = targetMonth
        targetComponents.day = 1
        
        guard let firstDayOfTargetMonth = calendar.date(from: targetComponents),
              let range = calendar.range(of: .day, in: .month, for: firstDayOfTargetMonth) else {
            return date
        }
        
        let maxDaysInTargetMonth = range.count
        
        // 如果原始日期大于目标月份的最大天数，使用目标月份的最后一天
        // 例如：1月31日 + 1个月 = 2月28日（或29日）
        let targetDay = min(day, maxDaysInTargetMonth)
        
        targetComponents.day = targetDay
        return calendar.date(from: targetComponents) ?? date
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
        
        // 获取目标年份该月的最大天数
        var targetComponents = DateComponents()
        targetComponents.year = targetYear
        targetComponents.month = month
        targetComponents.day = 1
        
        guard let firstDayOfTargetMonth = calendar.date(from: targetComponents),
              let range = calendar.range(of: .day, in: .month, for: firstDayOfTargetMonth) else {
            return date
        }
        
        let maxDaysInTargetMonth = range.count
        
        // 如果原始日期大于目标月份的最大天数，使用目标月份的最后一天
        // 例如：2024年2月29日 + 1年 = 2025年2月28日
        let targetDay = min(day, maxDaysInTargetMonth)
        
        targetComponents.day = targetDay
        return calendar.date(from: targetComponents) ?? date
    }
    
    /// 检查是否为闰年
    private static func isLeapYear(_ year: Int) -> Bool {
        // 能被 400 整除，或者能被 4 整除但不能被 100 整除
        return (year % 400 == 0) || (year % 4 == 0 && year % 100 != 0)
    }
}
