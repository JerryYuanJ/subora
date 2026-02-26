# 分享功能更新

## ✅ 已完成的改进

### 分享内容优化

**现在分享时包含：**

1. **App Icon（应用图标）**
   - 自动从 Assets 或 Bundle 中获取
   - 在分享预览中显示应用图标
   - 让分享内容更专业、更有辨识度

2. **优化的文案**
   - 🇺🇸 英文：Manage your subscriptions with Subora!
   - 🇨🇳 中文：快来用 Subora 来管理你的订阅吧！
   - 🇯🇵 日文：Subora でサブスクリプションを管理しよう！

3. **App Store 链接**
   - 自动包含应用下载链接
   - 方便用户直接下载

## 技术实现

### AppConfig 扩展

添加了获取 App Icon 的功能：

```swift
extension AppConfig {
    /// 获取 App Icon 图片
    static var appIcon: UIImage? {
        // 方法1: 从 Assets 获取
        if let image = UIImage(named: "AppIcon") {
            return image
        }

        // 方法2: 从 Bundle 获取
        guard let iconsDictionary = Bundle.main.infoDictionary?["CFBundleIcons"] as? [String: Any],
              let primaryIconsDictionary = iconsDictionary["CFBundlePrimaryIcon"] as? [String: Any],
              let iconFiles = primaryIconsDictionary["CFBundleIconFiles"] as? [String],
              let lastIcon = iconFiles.last else {
            return nil
        }

        return UIImage(named: lastIcon)
    }
}
```

### 分享功能更新

```swift
private func shareApp() {
    let message = L10n.Settings.shareMessage
    guard let appURL = URL(string: AppConfig.appStoreURL) else { return }

    // 准备分享内容
    var activityItems: [Any] = [message, appURL]

    // 添加 App Icon（如果可用）
    if let appIcon = AppConfig.appIcon {
        activityItems.insert(appIcon, at: 0)
    }

    let activityViewController = UIActivityViewController(
        activityItems: activityItems,
        applicationActivities: nil
    )

    // ... 展示分享面板
}
```

## 分享效果

### 在不同平台的显示

1. **消息/iMessage**
   - 显示 App Icon
   - 显示文案
   - 显示链接预览

2. **社交媒体（微信、微博等）**
   - App Icon 作为分享图片
   - 文案作为分享文本
   - 链接可点击

3. **邮件**
   - App Icon 作为附件或内嵌图片
   - 文案作为邮件正文
   - 链接可点击

4. **复制**
   - 复制文案和链接
   - 方便用户粘贴到任何地方

## 本地化文案对比

### 之前

- 🇺🇸 Check out Subora - the best way to manage your subscriptions! 🚀
- 🇨🇳 推荐一个超好用的订阅管理应用 Subora！🚀
- 🇯🇵 Subora - 最高のサブスクリプション管理アプリをチェック！🚀

### 现在（更简洁、更友好）

- 🇺🇸 Manage your subscriptions with Subora!
- 🇨🇳 快来用 Subora 来管理你的订阅吧！
- 🇯🇵 Subora でサブスクリプションを管理しよう！

## 优势

1. **视觉吸引力**：App Icon 让分享内容更专业
2. **品牌识别**：用户一眼就能认出是 Subora
3. **简洁文案**：去掉了过度营销的语气，更自然
4. **国际化**：所有文案都已本地化
5. **灵活性**：自动适配不同的分享平台

## 测试建议

分享到以下平台测试效果：

- [ ] iMessage
- [ ] 微信
- [ ] 邮件
- [ ] 备忘录
- [ ] AirDrop
- [ ] 复制链接
