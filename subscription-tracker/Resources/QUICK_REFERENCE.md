# 多语言快速参考 / Localization Quick Reference

## 常用代码片段 / Common Code Snippets

### 基本文本 / Basic Text

```swift
Text(L10n.Dashboard.title)
```

### 导航标题 / Navigation Title

```swift
.navigationTitle(L10n.Settings.title)
```

### 按钮 / Button

```swift
Button(L10n.Subscription.buttonSave) { }
```

### TextField 占位符 / TextField Placeholder

```swift
TextField(L10n.Subscription.namePlaceholder, text: $name)
```

### Section 标题 / Section Header

```swift
Section(L10n.Subscription.sectionBasic) { }
```

### 格式化字符串 / Formatted String

```swift
Text(L10n.Subscription.notifyDaysBefore(3))
```

### Toast 消息 / Toast Message

```swift
toast = .success(L10n.Toast.saveSuccess)
toast = .error(L10n.Toast.purchaseFailed(error.localizedDescription))
```

### 加载提示 / Loading Message

```swift
LoadingOverlay(message: L10n.Loading.saving)
```

### 错误处理 / Error Handling

```swift
catch {
    // AppError 已自动本地化
    toast = .error(error.localizedDescription)
}
```

## 所有可用的本地化键 / All Available Localization Keys

### Tab (3)

- `L10n.Tab.dashboard`
- `L10n.Tab.subscriptions`
- `L10n.Tab.settings`

### Dashboard (8)

- `L10n.Dashboard.title`
- `L10n.Dashboard.monthlyExpenses`
- `L10n.Dashboard.noSubscriptions`
- `L10n.Dashboard.trend`
- `L10n.Dashboard.noTrendData`
- `L10n.Dashboard.noTrendHint`
- `L10n.Dashboard.upcomingRenewals`
- `L10n.Dashboard.noUpcoming`

### Subscriptions (4)

- `L10n.Subscriptions.title`
- `L10n.Subscriptions.searchPlaceholder`
- `L10n.Subscriptions.filterAll`
- `L10n.Subscriptions.empty`

### Subscription Form (15)

- `L10n.Subscription.addTitle`
- `L10n.Subscription.editTitle`
- `L10n.Subscription.sectionBasic`
- `L10n.Subscription.namePlaceholder`
- `L10n.Subscription.descriptionPlaceholder`
- `L10n.Subscription.sectionCategory`
- `L10n.Subscription.categoryPicker`
- `L10n.Subscription.noCategory`
- `L10n.Subscription.sectionBilling`
- `L10n.Subscription.firstPaymentDate`
- `L10n.Subscription.amount`
- `L10n.Subscription.amountPlaceholder`
- `L10n.Subscription.sectionNotification`
- `L10n.Subscription.enableNotification`
- `L10n.Subscription.notifyDaysBefore(days)` ⚡ 函数
- `L10n.Subscription.buttonCancel`
- `L10n.Subscription.buttonSave`

### Billing Cycle (6)

- `L10n.BillingCycle.every`
- `L10n.BillingCycle.unit`
- `L10n.BillingCycle.day`
- `L10n.BillingCycle.week`
- `L10n.BillingCycle.month`
- `L10n.BillingCycle.year`

### Paywall (15)

- `L10n.Paywall.title`
- `L10n.Paywall.subtitle`
- `L10n.Paywall.featureUnlimitedSubscriptions`
- `L10n.Paywall.featureUnlimitedSubscriptionsDesc`
- `L10n.Paywall.featureUnlimitedCategories`
- `L10n.Paywall.featureUnlimitedCategoriesDesc`
- `L10n.Paywall.featureiCloudSync`
- `L10n.Paywall.featureiCloudSyncDesc`
- `L10n.Paywall.featureSmartNotifications`
- `L10n.Paywall.featureSmartNotificationsDesc`
- `L10n.Paywall.featureAdvancedStats`
- `L10n.Paywall.featureAdvancedStatsDesc`
- `L10n.Paywall.featureThemeCustomization`
- `L10n.Paywall.featureThemeCustomizationDesc`
- `L10n.Paywall.buttonPurchase`
- `L10n.Paywall.buttonRestore`
- `L10n.Paywall.buttonClose`

### Settings (18)

- `L10n.Settings.title`
- `L10n.Settings.sectionAppearance`
- `L10n.Settings.darkMode`
- `L10n.Settings.darkModeSystem`
- `L10n.Settings.darkModeLight`
- `L10n.Settings.darkModeDark`
- `L10n.Settings.themeColor`
- `L10n.Settings.sectionDefaults`
- `L10n.Settings.defaultCurrency`
- `L10n.Settings.notificationTime`
- `L10n.Settings.sectionData`
- `L10n.Settings.iCloudSync`
- `L10n.Settings.categoryManagement`
- `L10n.Settings.sectionPro`
- `L10n.Settings.proPurchased`
- `L10n.Settings.upgradeToPro`
- `L10n.Settings.restorePurchases`
- `L10n.Settings.sectionAbout`
- `L10n.Settings.version`

### Colors (13)

- `L10n.ColorPicker.title`
- `L10n.Color.red`
- `L10n.Color.orange`
- `L10n.Color.yellow`
- `L10n.Color.green`
- `L10n.Color.blue`
- `L10n.Color.purple`
- `L10n.Color.pinkPurple`
- `L10n.Color.pink`
- `L10n.Color.brown`
- `L10n.Color.gray`
- `L10n.Color.cyan`
- `L10n.Color.skyBlue`

### Loading & Toast (7)

- `L10n.Loading.default`
- `L10n.Loading.saving`
- `L10n.Toast.saveSuccess`
- `L10n.Toast.purchaseSuccess`
- `L10n.Toast.restoreSuccess`
- `L10n.Toast.purchaseFailed(error)` ⚡ 函数
- `L10n.Toast.restoreFailed(error)` ⚡ 函数

### Validation (7)

- `L10n.Validation.nameEmpty`
- `L10n.Validation.nameTooLong`
- `L10n.Validation.amountInvalid`
- `L10n.Validation.billingCycleInvalid`
- `L10n.Validation.firstPaymentFuture`
- `L10n.Validation.currencyUnsupported`
- `L10n.Validation.notifyDaysInvalid`

### Errors (15)

- `L10n.Error.dataNotFound`
- `L10n.Error.dataSaveFailed(reason)` ⚡ 函数
- `L10n.Error.dataLoadFailed(reason)` ⚡ 函数
- `L10n.Error.invalidData(field)` ⚡ 函数
- `L10n.Error.subscriptionLimit`
- `L10n.Error.categoryLimit`
- `L10n.Error.notificationPermission`
- `L10n.Error.notificationSchedule`
- `L10n.Error.syncFailed(reason)` ⚡ 函数
- `L10n.Error.networkUnavailable`
- `L10n.Error.iCloudUnavailable`
- `L10n.Error.purchaseFailed(reason)` ⚡ 函数
- `L10n.Error.purchaseCancelled`
- `L10n.Error.restoreFailed`

⚡ = 需要参数的函数

## 查找替换模式 / Find & Replace Patterns

### 模式 1: 简单文本

```
查找: Text("Dashboard")
替换: Text(L10n.Dashboard.title)
```

### 模式 2: 导航标题

```
查找: .navigationTitle("设置")
替换: .navigationTitle(L10n.Settings.title)
```

### 模式 3: Section 标题

```
查找: Section("基本信息")
替换: Section(L10n.Subscription.sectionBasic)
```

### 模式 4: TextField 占位符

```
查找: TextField("订阅名称", text: $name)
替换: TextField(L10n.Subscription.namePlaceholder, text: $name)
```

### 模式 5: 按钮文本

```
查找: Button("保存")
替换: Button(L10n.Subscription.buttonSave)
```

## 测试命令 / Testing Commands

### 在不同语言下运行

```bash
# 中文
xcodebuild -project subscription-tracker.xcodeproj \
  -scheme subscription-tracker \
  -destination 'platform=iOS Simulator,name=iPhone 17' \
  -AppleLanguages '(zh-Hans)' \
  test

# 英文
xcodebuild -project subscription-tracker.xcodeproj \
  -scheme subscription-tracker \
  -destination 'platform=iOS Simulator,name=iPhone 17' \
  -AppleLanguages '(en)' \
  test

# 日文
xcodebuild -project subscription-tracker.xcodeproj \
  -scheme subscription-tracker \
  -destination 'platform=iOS Simulator,name=iPhone 17' \
  -AppleLanguages '(ja)' \
  test
```

## 常见问题 / FAQ

### Q: 如何添加新的本地化字符串？

A:

1. 在所有 `Localizable.strings` 文件中添加键值对
2. 在 `LocalizationHelper.swift` 中添加访问器
3. 在代码中使用 `L10n.xxx.xxx`

### Q: 如何测试不同语言？

A:
在 Xcode 中: Product > Scheme > Edit Scheme > Run > Options > App Language

### Q: 字符串太长导致布局问题怎么办？

A:
使用 `.lineLimit()` 和 `.minimumScaleFactor()` 修饰符

### Q: 如何处理复数形式？

A:
使用 `.stringsdict` 文件（需要额外配置）

### Q: 如何添加新语言？

A:

1. 复制 `en.lproj` 文件夹
2. 重命名为新语言代码
3. 翻译所有字符串
4. 在 Xcode 项目设置中添加语言

## 相关文档 / Related Documentation

- 📖 [LOCALIZATION_README.md](LOCALIZATION_README.md) - 完整指南
- 💡 [LOCALIZATION_EXAMPLES.md](LOCALIZATION_EXAMPLES.md) - 代码示例
- 📋 [LOCALIZATION_SUMMARY.md](LOCALIZATION_SUMMARY.md) - 实现总结
