# 分享图标显示修复

## 问题

之前分享时显示的是 Safari 图标（指南针），而不是 App 的图标。

## 原因

iOS 的分享预览会自动从 URL 获取网站的 favicon，导致显示了 apps.apple.com 的图标（Safari）。

## 解决方案

### 1. 创建自定义 Activity Item Source

创建了 `AppShareActivityItemSource.swift`，实现了 `UIActivityItemSource` 协议：

```swift
class AppShareActivityItemSource: NSObject, UIActivityItemSource {
    let message: String
    let url: URL
    let icon: UIImage?

    // 实现 Link Presentation 元数据
    func activityViewControllerLinkMetadata(_ activityViewController: UIActivityViewController) -> LPLinkMetadata? {
        let metadata = LPLinkMetadata()
        metadata.title = AppConfig.appName
        metadata.originalURL = url
        metadata.url = url

        // 设置自定义图标
        if let icon = icon {
            metadata.iconProvider = NSItemProvider(object: icon)
            metadata.imageProvider = NSItemProvider(object: icon)
        }

        return metadata
    }
}
```

### 2. 使用 Link Presentation 框架

- 使用 `LPLinkMetadata` 来自定义分享预览
- 设置 `iconProvider` 和 `imageProvider` 来显示 App Icon
- 覆盖默认的 URL 预览行为

### 3. 更新分享方法

```swift
private func shareApp() {
    let message = L10n.Settings.shareMessage
    guard let appURL = URL(string: AppConfig.appStoreURL) else { return }

    // 使用自定义的 Activity Item Source
    let shareItem = AppShareActivityItemSource(
        message: message,
        url: appURL,
        icon: AppConfig.appIcon
    )

    let activityViewController = UIActivityViewController(
        activityItems: [shareItem],
        applicationActivities: nil
    )

    // ...
}
```

## 效果

现在分享时会显示：

- ✅ **App Icon**（你的应用图标）而不是 Safari 图标
- ✅ **App 名称**（Subora）
- ✅ **自定义文案**（根据语言显示）
- ✅ **App Store 链接**

## 测试步骤

1. **删除旧版本应用**（重要！）
   - 长按应用图标 → 删除 App
   - 这样可以清除缓存

2. **重新安装**
   - 在 Xcode 中运行应用
   - 或者重新构建并安装

3. **测试分享**
   - 进入 Settings → About
   - 点击 "Share with Friends"
   - 查看分享预览

4. **验证不同平台**
   - iMessage：应该显示 App Icon
   - 邮件：应该显示 App Icon
   - 备忘录：应该显示 App Icon
   - 其他社交应用

## 为什么需要删除重装？

iOS 会缓存分享预览的元数据。如果不删除旧版本：

- 系统可能继续使用旧的缓存
- 分享预览可能不会立即更新
- 需要等待系统清除缓存（时间不确定）

删除并重新安装可以：

- ✅ 清除所有缓存
- ✅ 立即看到新的分享效果
- ✅ 确保使用最新的代码

## 技术细节

### Link Presentation 框架

- iOS 13+ 引入
- 用于自定义链接预览
- 支持设置标题、图标、图片等
- 被 Messages、Mail 等系统应用使用

### UIActivityItemSource 协议

- 提供动态分享内容
- 可以根据不同的分享目标返回不同内容
- 支持 Link Presentation 元数据

### NSItemProvider

- 用于提供图片等资源
- 支持延迟加载
- 系统会在需要时才加载图片

## 注意事项

1. **App Icon 必须存在**
   - 确保 Assets.xcassets 中有 AppIcon
   - 或者 Info.plist 中正确配置了图标

2. **图标大小**
   - 系统会自动调整图标大小
   - 不需要手动缩放

3. **缓存问题**
   - 首次分享后，系统可能会缓存预览
   - 如果修改了图标，可能需要重启设备或清除缓存

## 相关文件

- `AppShareActivityItemSource.swift` - 自定义分享内容
- `AppConfig.swift` - App 配置（包含获取图标的方法）
- `SettingsView.swift` - 分享功能实现
