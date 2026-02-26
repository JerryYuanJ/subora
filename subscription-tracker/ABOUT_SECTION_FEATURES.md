# About Section 新功能

## 已添加的功能

### 1. 📧 Contact Us（联系我们）

- **图标**：蓝色信封 📧
- **功能**：使用 MessageUI 框架打开原生邮件编辑器
- **收件人**：j24.yuan@gmail.com（可在 AppConfig.swift 中配置）
- **预填内容**：
  - 主题：Subora Feedback
  - 正文包含：App 版本、Build 号、设备型号、iOS 版本
- **错误处理**：如果设备未配置邮件账户，会显示友好提示
- **文案**：
  - 英文：We'd love to hear from you
  - 中文：我们期待您的反馈
  - 日文：ご意見をお聞かせください

### 2. ⭐ Rate App（给应用评分）

- **图标**：黄色星星 ⭐
- **功能**：跳转到 App Store 评分页面
- **文案**：
  - 英文：Show some love ❤️
  - 中文：给我们点爱心 ❤️
  - 日文：応援してください ❤️
- **配置**：App Store ID 在 AppConfig.swift 中配置

### 3. 🚀 Share App（分享应用）

- **图标**：绿色分享图标 🚀
- **功能**：调用系统分享面板，可分享到：
  - 消息、邮件、社交媒体
  - 复制链接、AirDrop 等
- **分享内容**：
  - 英文：Check out Subora - the best way to manage your subscriptions! 🚀
  - 中文：推荐一个超好用的订阅管理应用 Subora！🚀
  - 日文：Subora - 最高のサブスクリプション管理アプリをチェック！🚀
- **文案**：
  - 英文：Spread the word
  - 中文：推荐给更多人
  - 日文：みんなに教える
- **配置**：App Store URL 在 AppConfig.swift 中配置

## 🎨 设计亮点

### 视觉设计

- 每个选项都有独特的彩色图标：
  - Contact Us：蓝色信封图标 📧
  - Rate App：黄色星星图标 ⭐
  - Share App：绿色分享图标 🚀
- 两行布局：主标题 + 副标题
- 右侧箭头指示可点击

### 文案特色

- **Contact Us**：温暖友好，强调双向沟通
- **Rate App**：轻松有趣，使用爱心 emoji
- **Share App**：积极正面，鼓励传播

## 🔧 技术实现

### 新增文件

#### 1. AppConfig.swift

集中管理应用配置：

```swift
enum AppConfig {
    // 支持邮箱（可修改）
    static let supportEmail = "j24.yuan@gmail.com"

    // App Store ID（发布前需要修改）
    static let appStoreID = "123456789"

    // 自动获取版本信息
    static var appVersion: String { ... }
    static var buildNumber: String { ... }
    static var fullVersion: String { ... }
}
```

#### 2. MailComposer.swift

使用 MessageUI 框架的邮件发送器：

```swift
struct MailComposer: UIViewControllerRepresentable {
    let recipients: [String]
    let subject: String
    let body: String

    // 自动处理邮件发送和关闭
    // 支持检查邮件是否可用
}
```

### Contact Us 实现

```swift
private func contactUs() {
    if MailComposer.canSendMail {
        // 显示邮件编辑器
        showMailComposer = true
    } else {
        // 显示友好提示
        showMailUnavailableAlert = true
    }
}
```

**优势**：

- ✅ 使用原生邮件编辑器，用户体验更好
- ✅ 自动包含设备信息，方便调试
- ✅ 优雅的错误处理
- ✅ 不需要跳转到其他应用

## ⚙️ 配置说明

### 修改支持邮箱

在 `AppConfig.swift` 中修改：

```swift
static let supportEmail = "your-email@example.com"
```

### 修改 App Store ID

在 `AppConfig.swift` 中修改：

```swift
static let appStoreID = "your-actual-app-id"
```

### 版本信息

版本号自动从 Info.plist 读取：

- `CFBundleShortVersionString` → App Version (如 1.0.0)
- `CFBundleVersion` → Build Number (如 1)

## ⚠️ 发布前检查清单

- [x] 在 `AppConfig.swift` 中设置支持邮箱为 j24.yuan@gmail.com
- [ ] 在 `AppConfig.swift` 中设置实际的 App Store ID
- [ ] 测试 Contact Us 功能（需要在设备上配置邮件账户）
- [ ] 测试 Rate App 功能（应用上架后）
- [ ] 测试 Share App 功能

## 📱 用户体验

### 优点

1. **原生体验**：Contact Us 使用系统原生邮件编辑器
2. **一键操作**：所有功能都是一键直达
3. **错误处理**：邮件不可用时显示友好提示
4. **信息完整**：自动包含版本和设备信息
5. **易于配置**：所有配置集中在 AppConfig.swift

### 注意事项

1. Contact Us 需要设备上配置了邮件账户
2. Rate App 需要应用已在 App Store 上架
3. Share App 在 iPad 上会显示为 popover

## 🌍 多语言支持

所有文案都已完整本地化：

- ✅ English
- ✅ 简体中文
- ✅ 日本語
