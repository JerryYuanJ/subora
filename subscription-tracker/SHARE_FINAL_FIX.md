# 分享功能最终修复

## 修复的问题

### 1. ❌ 图标太小

**原因**：使用了 `iconProvider`，iOS 会将其显示为小图标

**解决方案**：

- 改用 `imageProvider` 而不是 `iconProvider`
- 将图标缩放到 300x300 像素
- `imageProvider` 会显示为大图，而 `iconProvider` 只显示为小图标

### 2. ❌ 显示 "apps.apple.com"

**原因**：在 metadata 中设置了 `url` 和 `originalURL`，iOS 会自动显示域名

**解决方案**：

- 从 metadata 中移除 URL 设置
- URL 仍然会在实际分享时通过 `itemForActivityType` 方法提供
- 这样预览中就不会显示域名了

## 关键代码改动

```swift
func activityViewControllerLinkMetadata(_ activityViewController: UIActivityViewController) -> LPLinkMetadata? {
    let metadata = LPLinkMetadata()

    // 只设置标题
    metadata.title = message

    // ❌ 不再设置 URL（避免显示域名）
    // metadata.originalURL = url
    // metadata.url = url

    // 设置大尺寸图标
    if let icon = icon {
        let targetSize = CGSize(width: 300, height: 300)
        let scaledIcon = resizeImage(image: icon, targetSize: targetSize)

        // ✅ 使用 imageProvider（大图）而不是 iconProvider（小图标）
        metadata.imageProvider = NSItemProvider(object: scaledIcon)
    }

    return metadata
}
```

## 现在的效果

分享预览应该显示：

- 🖼️ **大图标**：300x300 像素的 App Icon
- 📝 **文案**：
  - 🇨🇳 "快来用 Subora 来管理你的订阅吧！"
  - 🇺🇸 "Manage your subscriptions with Subora!"
  - 🇯🇵 "Subora でサブスクリプションを管理しよう！"
- ✅ **没有域名显示**

## 实际分享时的内容

虽然预览中不显示 URL，但实际分享时会包含：

### iMessage / 消息

```
快来用 Subora 来管理你的订阅吧！

https://apps.apple.com/app/id123456789
```

### 邮件

```
快来用 Subora 来管理你的订阅吧！

https://apps.apple.com/app/id123456789
```

### 复制

```
快来用 Subora 来管理你的订阅吧！
https://apps.apple.com/app/id123456789
```

### 其他平台

只显示文案，链接会自动附加

## 技术细节

### iconProvider vs imageProvider

| 属性            | 显示效果             | 适用场景             |
| --------------- | -------------------- | -------------------- |
| `iconProvider`  | 小图标（约 40x40）   | 网站 favicon         |
| `imageProvider` | 大图（可自定义大小） | 文章封面、App 宣传图 |

### 为什么不在 metadata 中设置 URL？

1. **设置 URL** → iOS 会显示域名（apps.apple.com）
2. **不设置 URL** → 只显示标题和图片
3. **URL 仍然会分享** → 通过 `itemForActivityType` 方法提供

### 图片缩放

```swift
private func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
    // 保持宽高比
    // 使用 UIGraphicsImageRenderer 进行高质量缩放
    // 返回 300x300 的图片
}
```

## 需要做的

**删除并重新安装应用**

1. 删除应用
2. 在 Xcode 中运行（Command + R）
3. 测试分享功能

## 预期结果

✅ 大图标（不再是小图标）
✅ 只显示文案（不显示 apps.apple.com）
✅ 实际分享时仍然包含链接
✅ 支持所有分享平台

## 对比

### 之前

```
[小图标] Manage your subscriptions with S...
         apps.apple.com
```

### 现在

```
[大图标] 快来用 Subora 来管理你的订阅吧！
```

干净、简洁、专业！🎉
