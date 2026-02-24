# 语言切换 - 快速开始

## 用户操作

1. 打开应用
2. 点击底部"设置"标签
3. 点击"语言"选项（会看到当前语言和 ↗ 图标）
4. 自动跳转到 iOS 系统设置
5. 在系统设置中更改语言
6. 返回应用，语言已更新

## 当前实现

✅ 跳转到系统设置
✅ 显示当前语言
✅ 符合 iOS 标准
✅ 无需重启应用

## 支持的语言

- 简体中文 (zh-Hans)
- English (en)
- 日本語 (ja)

## 代码位置

- 设置页面：`Views/SettingsView.swift`
- 本地化字符串：`Helpers/LocalizationHelper.swift`
- 本地化文件：`Resources/[语言].lproj/Localizable.strings`

## 界面展示

```
外观
├─ 深色模式        系统
└─ 语言           简体中文 ↗
```

点击"语言"行会跳转到系统设置。

## 技术实现

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
        Image(systemName: "arrow.up.forward.square")
    }
}
```

## 完成 ✅

语言切换功能已实现，采用 iOS 标准方式，简单可靠。
