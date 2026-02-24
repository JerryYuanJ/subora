# 语言切换功能实现说明

## 实现方案

采用 iOS 标准的语言切换方式：应用语言跟随系统设置，点击设置中的"语言"选项会跳转到系统设置页面。

## 实现细节

### 1. 设置页面更新

在 `SettingsView.swift` 中，语言选项改为一个按钮，点击后跳转到系统设置：

```swift
Button {
    if let url = URL(string: UIApplication.openSettingsURLString) {
        UIApplication.shared.open(url)
    }
} label: {
    HStack {
        Text(L10n.Settings.language)
        Spacer()
        Text(currentLanguageDisplayName())
            .foregroundColor(.secondary)
        Image(systemName: "arrow.up.forward.square")
            .foregroundColor(.secondary)
            .font(.caption)
    }
}
```

### 2. 显示当前语言

添加了 `currentLanguageDisplayName()` 方法来显示当前系统语言：

```swift
private func currentLanguageDisplayName() -> String {
    let languageCode = Locale.current.language.languageCode?.identifier ?? "en"
    switch languageCode {
    case "zh":
        return L10n.Settings.languageZh
    case "ja":
        return L10n.Settings.languageJa
    default:
        return L10n.Settings.languageEn
    }
}
```

### 3. 本地化字符串

所有本地化字符串通过 `L10n` 枚举访问，使用标准的 `NSLocalizedString`：

```swift
enum L10n {
    enum Tab {
        static let settings = NSLocalizedString("tab.settings", comment: "Settings tab title")
    }
}
```

## 用户体验流程

1. 用户打开应用，进入"设置"页面
2. 点击"语言"选项
3. 自动跳转到 iOS 系统设置
4. 用户在系统设置中更改语言
5. 返回应用，语言自动更新

## 优势

✅ **符合 iOS 标准** - 使用系统标准的语言切换方式
✅ **简单可靠** - 不需要复杂的动态语言切换逻辑
✅ **系统一致性** - 确保所有系统组件使用相同语言
✅ **无需重启** - 从系统设置返回后自动生效

## 支持的语言

- 简体中文 (zh-Hans)
- English (en)
- 日本語 (ja)

## 本地化文件位置

- `Resources/en.lproj/Localizable.strings` - 英文
- `Resources/zh-Hans.lproj/Localizable.strings` - 简体中文
- `Resources/ja.lproj/Localizable.strings` - 日本语

## 添加新语言

1. 在 Xcode 中添加新的本地化文件
2. 翻译所有字符串
3. 更新 `currentLanguageDisplayName()` 方法添加新语言的显示名称

## 注意事项

- 应用语言完全跟随系统设置
- 不需要在应用内保存语言偏好
- 所有文本使用 `L10n` 枚举访问，不直接使用 `NSLocalizedString`
