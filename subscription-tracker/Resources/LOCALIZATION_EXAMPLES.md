# 本地化使用示例 / Localization Usage Examples

## 基本用法 / Basic Usage

### 简单文本 / Simple Text

```swift
// ❌ 硬编码文本 (不推荐)
Text("Dashboard")

// ✅ 使用本地化 (推荐)
Text(L10n.Dashboard.title)
```

### 导航标题 / Navigation Title

```swift
// ❌ 硬编码
.navigationTitle("设置")

// ✅ 本地化
.navigationTitle(L10n.Settings.title)
```

### 按钮文本 / Button Text

```swift
// ❌ 硬编码
Button("保存") { }

// ✅ 本地化
Button(L10n.Subscription.buttonSave) { }
```

## 格式化字符串 / Formatted Strings

### 带数字的字符串 / Strings with Numbers

```swift
// 显示 "提前 3 天提醒" / "Notify 3 days before"
Text(L10n.Subscription.notifyDaysBefore(3))
```

### 带错误信息的字符串 / Strings with Error Messages

```swift
let errorMessage = "Network timeout"
toast = .error(L10n.Toast.purchaseFailed(errorMessage))
// 中文: "购买失败：Network timeout"
// English: "Purchase failed: Network timeout"
```

## 完整视图示例 / Complete View Examples

### Dashboard 视图

```swift
struct DashboardView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // 月度支出部分
                    VStack(alignment: .leading, spacing: 12) {
                        Text(L10n.Dashboard.monthlyExpenses)
                            .font(.headline)

                        if subscriptions.isEmpty {
                            Text(L10n.Dashboard.noSubscriptions)
                                .foregroundColor(.secondary)
                        }
                    }

                    // 趋势图部分
                    VStack(alignment: .leading, spacing: 12) {
                        Text(L10n.Dashboard.trend)
                            .font(.headline)

                        if trendData.isEmpty {
                            Text(L10n.Dashboard.noTrendData)
                                .font(.headline)
                            Text(L10n.Dashboard.noTrendHint)
                                .font(.caption)
                        }
                    }
                }
            }
            .navigationTitle(L10n.Dashboard.title)
        }
    }
}
```

### 表单视图

```swift
struct AddSubscriptionView: View {
    var body: some View {
        Form {
            Section(L10n.Subscription.sectionBasic) {
                TextField(L10n.Subscription.namePlaceholder, text: $name)
                TextField(L10n.Subscription.descriptionPlaceholder, text: $description)
            }

            Section(L10n.Subscription.sectionBilling) {
                DatePicker(
                    L10n.Subscription.firstPaymentDate,
                    selection: $date
                )

                HStack {
                    Text(L10n.Subscription.amount)
                    Spacer()
                    TextField(
                        L10n.Subscription.amountPlaceholder,
                        value: $amount,
                        format: .number
                    )
                }
            }
        }
        .navigationTitle(L10n.Subscription.addTitle)
    }
}
```

### Toast 消息

```swift
// 成功消息
toast = .success(L10n.Toast.saveSuccess)

// 错误消息
toast = .error(L10n.Toast.purchaseFailed(error.localizedDescription))

// 恢复成功
toast = .success(L10n.Toast.restoreSuccess)
```

### 加载提示

```swift
// 默认加载
LoadingOverlay(message: L10n.Loading.default)

// 保存中
LoadingOverlay(message: L10n.Loading.saving)
```

## TabView 示例

```swift
TabView {
    DashboardView()
        .tabItem {
            Label(L10n.Tab.dashboard, systemImage: "chart.bar.fill")
        }

    SubscriptionListView()
        .tabItem {
            Label(L10n.Tab.subscriptions, systemImage: "list.bullet.rectangle")
        }

    SettingsView()
        .tabItem {
            Label(L10n.Tab.settings, systemImage: "gearshape.fill")
        }
}
```

## Picker 示例

```swift
// 深色模式选择器
Picker(L10n.Settings.darkMode, selection: $darkMode) {
    Text(L10n.Settings.darkModeSystem).tag(DarkModeOption.system)
    Text(L10n.Settings.darkModeLight).tag(DarkModeOption.light)
    Text(L10n.Settings.darkModeDark).tag(DarkModeOption.dark)
}

// 计费周期单位选择器
Picker(L10n.BillingCycle.unit, selection: $unit) {
    Text(L10n.BillingCycle.day).tag(BillingCycleUnit.day)
    Text(L10n.BillingCycle.week).tag(BillingCycleUnit.week)
    Text(L10n.BillingCycle.month).tag(BillingCycleUnit.month)
    Text(L10n.BillingCycle.year).tag(BillingCycleUnit.year)
}
```

## 错误处理示例

```swift
do {
    try await viewModel.save()
    toast = .success(L10n.Toast.saveSuccess)
} catch AppError.subscriptionLimitReached {
    // 错误已经本地化
    toast = .error(error.localizedDescription)
} catch {
    toast = .error(error.localizedDescription)
}
```

## 验证错误示例

```swift
func validate() -> Bool {
    validationErrors.removeAll()

    if name.isEmpty {
        validationErrors["name"] = L10n.Validation.nameEmpty
        return false
    }

    if amount <= 0 {
        validationErrors["amount"] = L10n.Validation.amountInvalid
        return false
    }

    return true
}
```

## 最佳实践 / Best Practices

### ✅ 推荐做法

1. **始终使用 L10n 辅助类**

   ```swift
   Text(L10n.Dashboard.title)
   ```

2. **为格式化字符串创建函数**

   ```swift
   static func notifyDaysBefore(_ days: Int) -> String {
       String(format: NSLocalizedString("subscription.notify_days_before", comment: ""), days)
   }
   ```

3. **保持键名有意义且结构化**
   ```
   "dashboard.monthly_expenses" ✅
   "text1" ❌
   ```

### ❌ 避免的做法

1. **不要硬编码文本**

   ```swift
   Text("Dashboard") // ❌
   ```

2. **不要在多处重复相同的文本**

   ```swift
   // ❌ 在多个地方写 "保存"
   Button("保存") { }
   Button("保存") { }

   // ✅ 使用统一的本地化键
   Button(L10n.Subscription.buttonSave) { }
   Button(L10n.Subscription.buttonSave) { }
   ```

3. **不要拼接本地化字符串**

   ```swift
   // ❌ 不要这样做
   Text(L10n.BillingCycle.every + " 3 " + L10n.BillingCycle.day)

   // ✅ 使用格式化字符串
   Text(L10n.BillingCycle.everyNUnits(3, .day))
   ```

## 测试清单 / Testing Checklist

在发布前，确保测试以下内容：

- [ ] 所有界面在中文下显示正确
- [ ] 所有界面在英文下显示正确
- [ ] 所有界面在日文下显示正确
- [ ] 格式化字符串正确显示数字和变量
- [ ] 错误消息正确本地化
- [ ] Toast 消息正确本地化
- [ ] 表单验证错误正确本地化
- [ ] 长文本不会导致布局问题
- [ ] 所有按钮文本完整显示
- [ ] Tab 标签正确显示
