# 多语言支持 / Localization Support

## 概述 / Overview

本应用支持以下语言：

- 简体中文 (zh-Hans)
- English (en)
- 日本語 (ja)

## 文件结构 / File Structure

```
subscription-tracker/
├── Resources/
│   ├── zh-Hans.lproj/
│   │   └── Localizable.strings  # 简体中文
│   ├── en.lproj/
│   │   └── Localizable.strings  # 英文
│   └── ja.lproj/
│       └── Localizable.strings  # 日文
└── Helpers/
    └── LocalizationHelper.swift  # 本地化辅助类
```

## 使用方法 / Usage

### 方法 1: 使用 LocalizationHelper (推荐)

```swift
import SwiftUI

struct MyView: View {
    var body: some View {
        VStack {
            Text(L10n.Dashboard.title)
            Text(L10n.Dashboard.monthlyExpenses)
            Text(L10n.Subscription.notifyDaysBefore(3))
        }
    }
}
```

### 方法 2: 直接使用 NSLocalizedString

```swift
Text(NSLocalizedString("dashboard.title", comment: "Dashboard title"))
```

## 添加新的本地化字符串 / Adding New Localized Strings

### 步骤 1: 在所有 Localizable.strings 文件中添加键值对

**zh-Hans.lproj/Localizable.strings:**

```
"my.new.key" = "我的新文本";
```

**en.lproj/Localizable.strings:**

```
"my.new.key" = "My New Text";
```

**ja.lproj/Localizable.strings:**

```
"my.new.key" = "私の新しいテキスト";
```

### 步骤 2: 在 LocalizationHelper.swift 中添加访问器

```swift
enum L10n {
    enum MySection {
        static let newKey = NSLocalizedString("my.new.key", comment: "My new text")
    }
}
```

### 步骤 3: 在代码中使用

```swift
Text(L10n.MySection.newKey)
```

## 字符串格式化 / String Formatting

对于包含动态内容的字符串，使用格式化占位符：

**Localizable.strings:**

```
"subscription.notify_days_before" = "提前 %d 天提醒";
```

**LocalizationHelper.swift:**

```swift
static func notifyDaysBefore(_ days: Int) -> String {
    String(format: NSLocalizedString("subscription.notify_days_before", comment: ""), days)
}
```

**使用:**

```swift
Text(L10n.Subscription.notifyDaysBefore(3))
// 输出: "提前 3 天提醒"
```

## 测试不同语言 / Testing Different Languages

### 在 Xcode 中测试:

1. 选择 Product > Scheme > Edit Scheme...
2. 选择 Run > Options
3. 在 App Language 下拉菜单中选择语言
4. 运行应用

### 在模拟器中测试:

1. 打开 Settings app
2. 进入 General > Language & Region
3. 添加或选择语言
4. 重启应用

## 本地化覆盖范围 / Localization Coverage

### 已本地化的内容:

- ✅ Tab Bar 标签
- ✅ Dashboard 界面
- ✅ 订阅列表界面
- ✅ 添加/编辑订阅表单
- ✅ 付费墙界面
- ✅ 设置界面
- ✅ 颜色选择器
- ✅ 加载提示
- ✅ Toast 消息
- ✅ 验证错误消息
- ✅ 应用错误消息
- ✅ 计费周期单位

### 待本地化的内容:

- ⏳ 订阅详情界面
- ⏳ 分类管理界面
- ⏳ 通知内容
- ⏳ 帮助文档

## 注意事项 / Notes

1. **保持一致性**: 确保所有语言文件中的键名完全一致
2. **注释**: 为每个本地化字符串添加有意义的注释
3. **格式化**: 使用 %@ (字符串), %d (整数), %f (浮点数) 作为占位符
4. **测试**: 在添加新字符串后，测试所有支持的语言
5. **文化适应**: 考虑不同文化的表达习惯，不要直接翻译

## 贡献 / Contributing

如果您想添加新的语言支持或改进现有翻译：

1. 复制 `en.lproj` 文件夹
2. 重命名为目标语言代码 (例如: `fr.lproj` for French)
3. 翻译 `Localizable.strings` 中的所有字符串
4. 在 Xcode 项目设置中添加新语言
5. 测试并提交 Pull Request
