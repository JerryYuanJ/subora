# Insights 页面改进

## 概述

对 Insights 页面进行了全面升级，添加了可管理的卡片系统、多种新的数据可视化图表，并集成了付费墙功能。

## 主要改进

### 1. 卡片管理系统

- 右上角的 `+` 按钮改为管理图标（`slider.horizontal.3`）
- 点击后弹出 Drawer，显示所有可用的卡片类型
- 用户可以自由选择显示/隐藏各种卡片
- 卡片显示状态保存在 UserDefaults 中，重启应用后保持

### 2. 付费墙集成

- **免费卡片**（默认显示）：
  - Monthly Expenses（月度支出）
  - Yearly Expenses（年度支出）
  - Recent Spending Trends（近期支出趋势）

- **Pro 专属卡片**（需要付费）：
  - All-Time Spending Trends（全部支出趋势）
  - Top 5 Subscriptions（消费前5名）
  - Upcoming Renewals（即将续费）
  - Category Breakdown（分类占比）

- Pro 专属卡片在管理界面显示金色皇冠图标
- 点击 Pro 卡片会拉起付费墙
- 升级到 Pro 后自动显示已选择的付费卡片

### 3. 空状态优化

- 当用户未选择任何卡片时，显示友好的空状态页面
- 包含引导图标、提示文本和快捷操作按钮

## 技术实现

### 卡片类型枚举

```swift
enum InsightCardType {
    case monthlyExpenses      // 月度支出 (免费)
    case yearlyExpenses       // 年度支出 (免费)
    case recentTrend          // 近期趋势 (免费)
    case allTimeTrend         // 全部趋势 (Pro)
    case topSpending          // 消费前5 (Pro)
    case upcomingRenewals     // 即将续费 (Pro)
    case categoryBreakdown    // 分类占比 (Pro)

    var requiresPro: Bool {
        // 判断是否需要 Pro 订阅
    }
}
```

### 付费墙逻辑

#### 卡片访问控制

1. 免费用户只能看到3个免费卡片
2. Pro 卡片在管理界面显示皇冠图标
3. 点击 Pro 卡片触发付费墙
4. 升级后自动解锁所有 Pro 卡片

#### 状态同步

- 使用 `@EnvironmentObject` 注入 `PaywallService`
- 监听 `isPro` 状态变化
- Pro 状态改变时重新加载卡片配置

## 默认显示卡片

首次使用时，默认显示以下免费卡片：

- Monthly Expenses（月度支出）
- Yearly Expenses（年度支出）
- Recent Spending Trends（近期趋势）

## 颜色方案

- Monthly Expenses: 蓝色 (#4C8DFF)
- Yearly Expenses: 紫色 (#5E5CE6)
- Recent Trend: 绿色 (#34C759)
- All-Time Trend: 亮绿色 (#30D158) - Pro
- Top Spending: 红色 (#FF375F) - Pro
- Upcoming Renewals: 橙色 (#FF9F0A) - Pro
- Category Breakdown: 紫红色 (#AF52DE) - Pro

## 注意事项

1. 所有新文件需要添加到 Xcode 项目中
2. 确保 Swift Charts 框架可用（iOS 16+）
3. PaywallService 必须在 App 层级注入
4. 卡片管理状态存储在 UserDefaults 中
5. Pro 状态变化会自动触发卡片重新加载
