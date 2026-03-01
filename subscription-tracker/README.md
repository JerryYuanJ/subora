# Subora - 订阅管理应用

一个功能完整的 iOS 订阅管理应用，支持多语言、iCloud 同步、通知提醒等功能。

## 项目架构

### 技术栈

- **框架**: SwiftUI + SwiftData
- **最低版本**: iOS 17.0+
- **语言**: Swift 6.0
- **同步**: CloudKit (iCloud)
- **本地化**: 支持中文、英文、日文

### 架构模式

```
MVVM (Model-View-ViewModel)
├── Models          # 数据模型 (SwiftData)
├── Views           # UI 视图
├── ViewModels      # 业务逻辑
├── Services        # 服务层
└── Helpers         # 工具类
```

## 核心功能

### 1. 订阅管理

- ✅ 添加/编辑/删除订阅
- ✅ 支持自定义账单周期（日/周/月/年）
- ✅ 多货币支持（USD, CNY, EUR, GBP, JPY, HKD, TWD）
- ✅ 分类管理
- ✅ 订阅归档
- ✅ 应用模板（100+ 预设应用）

### 2. 数据分析

- ✅ 月度/年度支出统计
- ✅ 分类支出占比
- ✅ 支出趋势图表
- ✅ 最高支出排行

### 3. 通知提醒

- ✅ 续费提醒（可自定义提前天数）
- ✅ 本地通知
- ✅ 应用角标显示

### 4. iCloud 同步

- ✅ 多设备数据同步
- ✅ 自动冲突解决
- ✅ 离线支持
- ✅ Container: `iCloud.com.subora.app`

### 5. 多语言支持

- ✅ 中文（简体）
- ✅ 英文
- ✅ 日文
- ✅ 动态语言切换

### 6. 其他功能

- ✅ 深色模式支持
- ✅ 分享订阅信息
- ✅ 数据导出
- ✅ Pro 版本（付费墙）

## 项目结构

```
subscription-tracker/
├── Models/
│   ├── Subscription.swift          # 订阅模型
│   ├── Category.swift               # 分类模型
│   ├── UserSettings.swift           # 用户设置
│   ├── BillingCycleUnit.swift       # 账单周期枚举
│   └── AppTemplate.swift            # 应用模板
│
├── Views/
│   ├── SubscriptionListView.swift   # 订阅列表
│   ├── AddEditSubscriptionView.swift # 添加/编辑订阅
│   ├── SubscriptionDetailView.swift # 订阅详情
│   ├── InsightsView.swift           # 数据分析
│   ├── CategoryManagementView.swift # 分类管理
│   ├── SettingsView.swift           # 设置
│   ├── PaywallView.swift            # 付费墙
│   ├── AppSelectionView.swift       # 应用选择
│   └── Components/                  # 可复用组件
│       ├── SubscriptionCard.swift
│       ├── CategoryBadge.swift
│       ├── TrendChart.swift
│       └── ...
│
├── ViewModels/
│   ├── SubscriptionListViewModel.swift
│   ├── AddEditSubscriptionViewModel.swift
│   ├── SubscriptionDetailViewModel.swift
│   ├── InsightsViewModel.swift
│   ├── CategoryViewModel.swift
│   └── SettingsViewModel.swift
│
├── Services/
│   ├── SubscriptionService.swift    # 订阅业务逻辑
│   ├── CategoryService.swift        # 分类业务逻辑
│   ├── NotificationService.swift    # 通知服务
│   ├── SyncService.swift            # iCloud 同步
│   └── PaywallService.swift         # 付费墙服务
│
├── Helpers/
│   ├── BillingCalculator.swift      # 账单计算
│   ├── CurrencyFormatter.swift      # 货币格式化
│   ├── CurrencyConverter.swift      # 货币转换
│   ├── LocalizationHelper.swift     # 本地化工具
│   └── AppConfig.swift              # 应用配置
│
├── Extensions/
│   ├── Color+Hex.swift              # 颜色扩展
│   └── Logger+Extensions.swift      # 日志扩展
│
└── Resources/
    ├── en.lproj/Localizable.strings # 英文
    ├── zh-Hans.lproj/Localizable.strings # 中文
    └── ja.lproj/Localizable.strings # 日文
```

## 数据模型

### Subscription (订阅)

```swift
- id: UUID
- name: String                    // 订阅名称
- subscriptionDescription: String? // 描述
- iconURL: String?                // 应用图标 URL
- category: Category?             // 分类
- firstPaymentDate: Date          // 首次付款日期
- billingCycle: Int               // 账单周期数值
- billingCycleUnit: BillingCycleUnit // 周期单位
- amount: Decimal                 // 金额
- currency: String                // 货币
- notify: Bool                    // 是否提醒
- notifyDaysBefore: Int           // 提前提醒天数
- archived: Bool                  // 是否归档
- createdAt: Date
- updatedAt: Date
```

### Category (分类)

```swift
- id: UUID
- name: String                    // 分类名称
- categoryDescription: String?    // 描述
- colorHex: String                // 颜色
- subscriptions: [Subscription]?  // 关联订阅
- createdAt: Date
```

### UserSettings (用户设置)

```swift
- id: UUID
- darkMode: Bool?                 // 深色模式
- defaultCurrency: String         // 默认货币
- iCloudSync: Bool                // iCloud 同步
- isProUser: Bool                 // Pro 用户
- language: String?               // 语言
- lastSyncTime: Date?             // 最后同步时间
```

## iCloud 配置

### CloudKit Container

- **Container ID**: `iCloud.com.subora.app`
- **Database**: Private
- **Record Types**:
  - `CD_Subscription` - 订阅数据
  - `CD_Category` - 分类数据
  - `CD_UserSettings` - 用户设置

### Entitlements

```xml
<key>com.apple.developer.icloud-container-identifiers</key>
<array>
    <string>iCloud.com.subora.app</string>
</array>
<key>com.apple.developer.icloud-services</key>
<array>
    <string>CloudKit</string>
</array>
```

## 本地化

### 支持的语言

- 中文（简体）: `zh-Hans`
- 英文: `en`
- 日文: `ja`

### 使用方式

```swift
// 在代码中使用
Text(L10n.Tab.subscriptions)
Text(L10n.Subscription.addTitle)

// 自动跟随系统语言
// 或在设置中手动切换
```

## 通知系统

### 功能

- 订阅续费提醒
- 可自定义提前天数（1-30天）
- 本地通知（不需要服务器）
- 应用角标显示即将到期数量

### 权限

首次使用时会请求通知权限，用户可在设置中管理。

## 付费墙

### 免费版限制

- 最多 3 个订阅
- 无 iCloud 同步

### Pro 版功能

- 无限订阅
- iCloud 多设备同步
- 高级数据分析

## 开发指南

### 环境要求

- Xcode 15.0+
- iOS 17.0+
- macOS 14.0+ (开发机)

### 构建步骤

1. 克隆项目
2. 打开 `subscription-tracker.xcodeproj`
3. 配置 Team 和 Bundle ID
4. 配置 iCloud Container
5. 运行项目

### iCloud 配置步骤

1. 在 Xcode 中选择 Target → Signing & Capabilities
2. 添加 iCloud capability
3. 勾选 CloudKit
4. 选择或创建 container: `iCloud.com.subora.app`
5. 确保 "Automatically manage signing" 已勾选

### 测试

- 单元测试: `Tests/` 目录
- UI 测试: 手动测试
- iCloud 同步: 需要两台设备或模拟器

## 常见问题

### Q: iCloud 同步不工作？

A:

1. 确保设备已登录 iCloud
2. 检查 Signing & Capabilities 配置
3. 确认 container 已正确关联
4. 等待 1-2 分钟让数据同步

### Q: 如何添加新语言？

A:

1. 在 `Resources/` 下创建新的 `.lproj` 目录
2. 复制 `Localizable.strings` 并翻译
3. 在 Xcode 中添加语言支持

### Q: 如何自定义应用模板？

A: 编辑 `Models/AppTemplate.swift` 中的 `all` 数组

## 版本历史

### v1.0.0 (当前)

- ✅ 基础订阅管理
- ✅ 数据分析
- ✅ iCloud 同步
- ✅ 多语言支持
- ✅ 通知提醒
- ✅ 付费墙

## 许可证

[添加你的许可证信息]

## 联系方式

- 开发者: Jerry Yuan
- 支持邮箱: [添加邮箱]
