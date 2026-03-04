# Subora - 订阅管理应用

<div align="center">

一个功能完整、设计精美的 iOS 订阅管理应用，帮助你轻松追踪和管理所有订阅服务。

[English](#english) | [中文](#中文) | [日本語](#日本語)

</div>

---

## 中文

### 📱 应用简介

Subora 是一款专为 iOS 设计的订阅管理应用，采用现代化的 SwiftUI 架构，支持 iCloud 同步、多语言、通知提醒等功能。无论是 Netflix、Spotify，还是各种 AI 工具订阅，Subora 都能帮你一目了然地管理所有订阅支出。

### ✨ 核心功能

#### 📊 订阅管理

- ✅ 添加/编辑/删除订阅
- ✅ 支持自定义账单周期（日/周/月/年）
- ✅ 多货币支持（USD, CNY, EUR, GBP, JPY, HKD, TWD 等）
- ✅ 分类管理（娱乐、教育、工具、AI 工具等）
- ✅ 订阅归档功能
- ✅ 100+ 预设应用模板（快速添加常见订阅）
- ✅ 自定义应用图标和颜色

#### 📈 数据分析与洞察

- ✅ 月度/年度支出统计
- ✅ 分类支出占比饼图
- ✅ 支出趋势图表（近期和全时段）
- ✅ 最高支出排行榜
- ✅ 即将到期订阅提醒（30天内）
- ✅ 可自定义显示的数据卡片
- ✅ 多货币自动转换（统一显示）
- ✅ 历史支出计算

#### 🔔 智能通知

- ✅ 订阅续费提醒（可自定义提前天数 1-30 天）
- ✅ 本地通知（无需服务器）
- ✅ 应用角标显示即将到期数量
- ✅ 自定义通知时间
- ✅ 自动重新调度通知

#### ☁️ iCloud 同步

- ✅ 多设备数据自动同步
- ✅ CloudKit 集成
- ✅ 自动冲突解决
- ✅ 离线支持
- ✅ 实时数据更新

#### 🌍 多语言支持

- ✅ 中文（简体）
- ✅ 英文
- ✅ 日文
- ✅ 动态语言切换
- ✅ 完整本地化支持

#### 🎨 用户体验

- ✅ 深色模式支持
- ✅ 自定义主题颜色
- ✅ 精美的 UI 设计
- ✅ 流畅的动画效果
- ✅ 分享订阅信息
- ✅ 数据导出功能

#### 📱 Widget 小组件

- ✅ 主屏幕小组件支持
- ✅ 多种尺寸（小、中、大）
- ✅ 实时显示订阅信息
- ✅ 显示月度总支出
- ✅ 即将到期订阅提醒
- ✅ 跟随系统主题

#### 💎 Pro 版本

- ✅ 无限订阅（免费版限制 5 个）
- ✅ iCloud 多设备同步
- ✅ 高级数据分析卡片
- ✅ 全时段趋势分析
- ✅ 分类支出占比
- ✅ 即将到期订阅列表

### 🏗️ 技术架构

#### 技术栈

- **框架**: SwiftUI + SwiftData
- **最低版本**: iOS 17.0+
- **语言**: Swift 6.0
- **同步**: CloudKit (iCloud)
- **内购**: StoreKit 2
- **通知**: UserNotifications
- **小组件**: WidgetKit

#### 架构模式

```
MVVM (Model-View-ViewModel)
├── Models          # 数据模型 (SwiftData)
├── Views           # UI 视图层
├── ViewModels      # 业务逻辑层
├── Services        # 服务层
├── Helpers         # 工具类
└── Extensions      # 扩展
```

### 📁 项目结构

```
subscription-tracker/
├── Models/                          # 数据模型
│   ├── Subscription.swift           # 订阅模型
│   ├── Category.swift               # 分类模型
│   ├── UserSettings.swift           # 用户设置
│   ├── BillingCycleUnit.swift       # 账单周期枚举
│   └── AppTemplate.swift            # 应用模板
│
├── Views/                           # 视图层
│   ├── SubscriptionListView.swift   # 订阅列表
│   ├── AddEditSubscriptionView.swift # 添加/编辑订阅
│   ├── SubscriptionDetailView.swift # 订阅详情
│   ├── InsightsView.swift           # 数据洞察
│   ├── CategoryManagementView.swift # 分类管理
│   ├── SettingsView.swift           # 设置
│   ├── PaywallView.swift            # 付费墙
│   ├── AppSelectionView.swift       # 应用选择
│   └── Components/                  # 可复用组件
│       ├── SubscriptionCard.swift   # 订阅卡片
│       ├── CategoryBadge.swift      # 分类徽章
│       ├── TrendChart.swift         # 趋势图表
│       ├── TopSpendingChart.swift   # 最高支出图表
│       ├── CategoryBreakdownChart.swift # 分类占比图表
│       ├── BillingCyclePicker.swift # 账单周期选择器
│       ├── CurrencyPicker.swift     # 货币选择器
│       ├── ColorPicker.swift        # 颜色选择器
│       ├── CachedAsyncImage.swift   # 缓存图片
│       ├── ToastView.swift          # 提示消息
│       ├── LoadingOverlay.swift     # 加载遮罩
│       ├── WidgetPreviewSheet.swift # Widget 预览
│       └── InsightCardManagementView.swift # 数据卡片管理
│
├── ViewModels/                      # 视图模型
│   ├── SubscriptionListViewModel.swift
│   ├── AddEditSubscriptionViewModel.swift
│   ├── SubscriptionDetailViewModel.swift
│   ├── InsightsViewModel.swift
│   ├── CategoryViewModel.swift
│   ├── DashboardViewModel.swift
│   └── SettingsViewModel.swift
│
├── Services/                        # 服务层
│   ├── SubscriptionService.swift    # 订阅业务逻辑
│   ├── CategoryService.swift        # 分类业务逻辑
│   ├── NotificationService.swift    # 通知服务
│   ├── SyncService.swift            # iCloud 同步
│   └── PaywallService.swift         # 付费墙服务
│
├── Helpers/                         # 工具类
│   ├── BillingCalculator.swift      # 账单计算
│   ├── CurrencyFormatter.swift      # 货币格式化
│   ├── CurrencyConverter.swift      # 货币转换
│   ├── LocalizationHelper.swift     # 本地化工具
│   ├── AppConfig.swift              # 应用配置
│   ├── ImageCache.swift             # 图片缓存
│   ├── MailComposer.swift           # 邮件编辑器
│   ├── AppDelegate.swift            # 应用代理
│   └── AppShareActivityItemSource.swift # 分享功能
│
├── Extensions/                      # 扩展
│   ├── Color+Hex.swift              # 颜色扩展
│   └── Logger+Extensions.swift      # 日志扩展
│
├── Shared/                          # 共享代码
│   └── WidgetSharedData.swift       # Widget 数据共享
│
└── Resources/                       # 资源文件
    ├── en.lproj/Localizable.strings # 英文
    ├── zh-Hans.lproj/Localizable.strings # 中文
    └── ja.lproj/Localizable.strings # 日文

SuboraWidget/                        # Widget 扩展
├── SuboraWidget.swift               # Widget 主文件
├── SuboraWidgetBundle.swift         # Widget Bundle
├── SuboraWidgetView.swift           # Widget 视图
├── WidgetSharedData.swift           # 数据共享
└── Assets.xcassets/                 # Widget 资源
```

### 💾 数据模型

#### Subscription (订阅)

```swift
- id: UUID                           // 唯一标识
- name: String                       // 订阅名称
- subscriptionDescription: String?   // 描述
- iconURL: String?                   // 应用图标 URL
- category: Category?                // 分类
- firstPaymentDate: Date             // 首次付款日期
- billingCycle: Int                  // 账单周期数值
- billingCycleUnit: BillingCycleUnit // 周期单位（日/周/月/年）
- amount: Decimal                    // 金额
- currency: String                   // 货币代码
- notify: Bool                       // 是否提醒
- notifyDaysBefore: Int              // 提前提醒天数
- lastNotifiedDate: Date?            // 最后通知日期
- archived: Bool                     // 是否归档
- createdAt: Date                    // 创建时间
- updatedAt: Date                    // 更新时间

// 计算属性
- nextBillingDate: Date              // 下次续费日期
- monthlyEquivalent: Decimal         // 月度等效金额
```

#### Category (分类)

```swift
- id: UUID                           // 唯一标识
- name: String                       // 分类名称
- categoryDescription: String?       // 描述
- colorHex: String                   // 颜色（十六进制）
- subscriptions: [Subscription]?     // 关联订阅
- createdAt: Date                    // 创建时间

// 计算属性
- color: Color                       // SwiftUI 颜色对象
```

#### UserSettings (用户设置)

```swift
- id: UUID                           // 唯一标识
- darkMode: Bool?                    // 深色模式（nil 表示跟随系统）
- themeColor: String                 // 主题颜色
- defaultCurrency: String            // 默认货币
- defaultNotifyTime: Date            // 默认通知时间
- iCloudSync: Bool                   // iCloud 同步开关
- isProUser: Bool                    // Pro 用户状态
- language: String?                  // 语言设置
- lastSyncTime: Date?                // 最后同步时间
- updatedAt: Date                    // 更新时间
```

### ☁️ iCloud 配置

#### CloudKit Container

- **Container ID**: `iCloud.com.subora.app`
- **Database**: Private Database
- **Record Types**:
  - `CD_Subscription` - 订阅数据
  - `CD_Category` - 分类数据
  - `CD_UserSettings` - 用户设置

#### Entitlements

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

### 🔔 通知系统

#### 功能特性

- 订阅续费提醒
- 可自定义提前天数（1-30天）
- 本地通知（不需要服务器）
- 应用角标显示即将到期数量
- 自动重新调度通知
- 支持自定义通知时间

#### 权限管理

首次使用时会请求通知权限，用户可在设置中随时管理通知偏好。

### 💰 付费墙系统

#### 免费版限制

- 最多 5 个活跃订阅
- 最多 5 个分类
- 基础数据分析（月度、年度、近期趋势）
- 无 iCloud 同步

#### Pro 版功能

- ✅ 无限订阅
- ✅ 无限分类
- ✅ iCloud 多设备同步
- ✅ 高级数据分析
  - 全时段趋势分析
  - 最高支出排行
  - 分类支出占比
  - 即将到期订阅列表
- ✅ 优先技术支持

#### 订阅计划

- 月度订阅：`premium_monthly`
- 年度订阅：`premium_yearly`（更优惠）

### 🚀 开发指南

#### 环境要求

- Xcode 15.0+
- iOS 17.0+
- macOS 14.0+ (开发机)
- Apple Developer Account（用于 iCloud 和 StoreKit）

#### 构建步骤

1. **克隆项目**

   ```bash
   git clone <repository-url>
   cd subscription-tracker
   ```

2. **打开项目**

   ```bash
   open subscription-tracker.xcodeproj
   ```

3. **配置 Team 和 Bundle ID**
   - 在 Xcode 中选择项目
   - 选择 Target → Signing & Capabilities
   - 选择你的 Team
   - 修改 Bundle Identifier（如需要）

4. **配置 iCloud**
   - 添加 iCloud capability
   - 勾选 CloudKit
   - 选择或创建 container: `iCloud.com.subora.app`
   - 确保 "Automatically manage signing" 已勾选

5. **配置 StoreKit**
   - 在 App Store Connect 中创建应用
   - 配置内购产品：
     - `premium_monthly` - 月度订阅
     - `premium_yearly` - 年度订阅
   - 使用 `Configuration.storekit` 进行本地测试

6. **运行项目**
   - 选择目标设备或模拟器
   - 点击 Run (⌘R)

#### 开发模式

在 DEBUG 模式下，应用会自动解除订阅和分类数量限制，方便开发测试。

### 🧪 测试

#### 单元测试

```bash
# 运行单元测试
⌘U in Xcode
```

#### iCloud 同步测试

1. 在两台设备上登录同一 iCloud 账号
2. 在设备 A 上添加订阅
3. 等待 1-2 分钟
4. 在设备 B 上查看是否同步

#### StoreKit 测试

1. 使用 `Configuration.storekit` 文件
2. 在 Xcode 中选择 Product → Scheme → Edit Scheme
3. 在 Run → Options 中选择 StoreKit Configuration
4. 运行应用进行内购测试

### 🌐 本地化

#### 支持的语言

- 中文（简体）: `zh-Hans`
- 英文: `en`
- 日文: `ja`

#### 添加新语言

1. **创建语言目录**

   ```bash
   mkdir -p subscription-tracker/Resources/[language-code].lproj
   ```

2. **复制并翻译字符串文件**

   ```bash
   cp subscription-tracker/Resources/en.lproj/Localizable.strings \
      subscription-tracker/Resources/[language-code].lproj/
   ```

3. **在 Xcode 中添加语言支持**
   - 选择项目 → Info → Localizations
   - 点击 + 添加新语言

4. **验证本地化**
   ```bash
   cd subscription-tracker/Resources
   ./validate_localization.sh
   ```

#### 使用本地化字符串

```swift
// 在代码中使用
Text(L10n.Tab.subscriptions)
Text(L10n.Subscription.addTitle)
Text(L10n.Error.dataSaveFailed("reason"))
```

### 📊 数据分析功能

#### 可用的数据卡片

1. **月度支出** - 显示当月总支出
2. **年度支出** - 显示年度总支出
3. **近期趋势** - 最近 6 个月的支出趋势
4. **全时段趋势** (Pro) - 从第一笔订阅开始的完整趋势
5. **最高支出** (Pro) - Top 5 支出最高的订阅
6. **分类占比** (Pro) - 按分类显示支出占比
7. **即将到期** (Pro) - 30 天内即将续费的订阅

#### 货币转换

- 所有数据分析都会自动转换为用户设置的默认货币
- 使用实时汇率进行转换
- 支持多种主流货币

### 🎨 自定义

#### 主题颜色

用户可以在设置中自定义应用的主题颜色，包括：

- 预设颜色方案
- 自定义十六进制颜色
- 深色/浅色模式切换

#### 分类颜色

每个分类都可以设置独特的颜色，帮助快速识别不同类型的订阅。

### 📱 Widget 小组件

#### 支持的尺寸

- **小尺寸**: 显示月度总支出和订阅数量
- **中尺寸**: 显示最近 3 个即将到期的订阅
- **大尺寸**: 显示最近 6 个即将到期的订阅和详细信息

#### 数据更新

- Widget 每 2 小时自动刷新一次
- 应用内数据变更时立即更新
- 支持深色模式自动切换

### 🔧 常见问题

#### Q: iCloud 同步不工作？

A:

1. 确保设备已登录 iCloud
2. 检查 Signing & Capabilities 配置
3. 确认 container 已正确关联
4. 在设置中开启 iCloud 同步
5. 等待 1-2 分钟让数据同步

#### Q: 通知不显示？

A:

1. 检查通知权限是否已授予
2. 确认订阅已开启通知
3. 检查通知时间设置
4. 重启应用重新调度通知

#### Q: 如何添加新的应用模板？

A: 编辑 `Models/AppTemplate.swift` 中的 `all` 数组，添加新的应用信息。

#### Q: 如何测试内购功能？

A: 使用项目中的 `Configuration.storekit` 文件进行本地测试，或在 App Store Connect 中配置沙盒测试账号。

#### Q: 数据存储在哪里？

A:

- 本地数据：使用 SwiftData 存储在设备上
- iCloud 数据：通过 CloudKit 同步到 iCloud Private Database
- Widget 数据：存储在 App Group 共享容器中

### 🛠️ 技术亮点

1. **现代化架构**
   - 使用 SwiftUI 和 SwiftData 构建
   - MVVM 架构模式
   - 响应式编程（Combine）

2. **性能优化**
   - 图片缓存机制
   - 懒加载和分页
   - 高效的数据查询

3. **用户体验**
   - 流畅的动画效果
   - 直观的交互设计
   - 完善的错误处理

4. **代码质量**
   - 清晰的代码结构
   - 详细的注释
   - 类型安全

### 📄 许可证

[添加你的许可证信息]

### 👨‍💻 开发者

- **开发者**: Jerry Yuan
- **支持邮箱**: [添加邮箱]
- **项目创建**: 2026年2月

### 🙏 致谢

感谢所有为这个项目做出贡献的开发者和用户。

---

## English

### 📱 App Overview

Subora is a beautifully designed iOS subscription management app built with modern SwiftUI architecture. It helps you effortlessly track and manage all your subscription services with features like iCloud sync, multi-language support, and smart notifications.

### ✨ Key Features

- 📊 Comprehensive subscription management
- 📈 Advanced data analytics and insights
- 🔔 Smart renewal notifications
- ☁️ iCloud sync across devices
- 🌍 Multi-language support (English, Chinese, Japanese)
- 🎨 Beautiful UI with dark mode
- 📱 Home screen widgets
- 💎 Pro version with unlimited subscriptions

### 🚀 Tech Stack

- SwiftUI + SwiftData
- iOS 17.0+
- Swift 6.0
- CloudKit for iCloud sync
- StoreKit 2 for in-app purchases
- WidgetKit for home screen widgets

### 📦 Installation

1. Clone the repository
2. Open `subscription-tracker.xcodeproj` in Xcode
3. Configure your Team and Bundle ID
4. Set up iCloud container
5. Run the project

For detailed setup instructions, see the Chinese section above.

---

## 日本語

### 📱 アプリ概要

Suboraは、モダンなSwiftUIアーキテクチャで構築された美しいデザインのiOSサブスクリプション管理アプリです。iCloud同期、多言語サポート、スマート通知などの機能で、すべてのサブスクリプションサービスを簡単に追跡・管理できます。

### ✨ 主な機能

- 📊 包括的なサブスクリプション管理
- 📈 高度なデータ分析とインサイト
- 🔔 スマートな更新通知
- ☁️ デバイス間のiCloud同期
- 🌍 多言語サポート（英語、中国語、日本語）
- 🎨 ダークモード対応の美しいUI
- 📱 ホーム画面ウィジェット
- 💎 無制限サブスクリプションのProバージョン

### 🚀 技術スタック

- SwiftUI + SwiftData
- iOS 17.0以上
- Swift 6.0
- iCloud同期用CloudKit
- アプリ内課金用StoreKit 2
- ホーム画面ウィジェット用WidgetKit

### 📦 インストール

1. リポジトリをクローン
2. Xcodeで`subscription-tracker.xcodeproj`を開く
3. TeamとBundle IDを設定
4. iCloudコンテナを設定
5. プロジェクトを実行

詳細なセットアップ手順については、上記の中国語セクションを参照してください。

---

<div align="center">

Made with ❤️ by Jerry Yuan

</div>
