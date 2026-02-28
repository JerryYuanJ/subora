# iCloud CloudKit 配置指南

## 问题说明

当你看到错误 "Invalid bundle ID for container" (CKError code: 10) 时，说明 CloudKit 容器配置有问题。

## 最简单的解决方案（推荐）

### 使用 Xcode 自动配置

1. 在 Xcode 中打开项目 `subscription-tracker.xcodeproj`

2. 在左侧项目导航器中，点击最顶部的项目名称

3. 选择 target "subscription-tracker"

4. 点击顶部的 "Signing & Capabilities" 标签

5. 确保已选择开发团队 `DR9B4SVZCG`

6. 检查 iCloud 配置：
   - 如果看到 "iCloud" capability，展开它
   - 确保勾选了 "CloudKit"
   - 查看容器列表，应该有 `iCloud.com.app.sub.tracker`

7. 如果没有 iCloud capability：
   - 点击 "+ Capability" 按钮
   - 搜索并添加 "iCloud"
   - 勾选 "CloudKit"
   - 点击容器列表下方的 "+" 按钮
   - 输入容器名称: `iCloud.com.app.sub.tracker`
   - 或者让 Xcode 自动生成默认容器名称

8. Xcode 会自动在你的 Apple Developer 账号中创建和配置这个容器

9. 重新运行应用，测试同步功能

## 其他解决方案

### 方案 A: 在 Apple Developer 网站手动配置

1. 访问 https://developer.apple.com/account/
2. 登录你的开发者账号
3. 进入 "Certificates, Identifiers & Profiles"
4. 点击左侧的 "Identifiers"
5. 找到 App ID: `com.app.sub.tracker`（如果没有，需要创建）
6. 点击编辑
7. 确保启用了 "iCloud" capability
8. 在 iCloud 设置中，添加或确认容器 `iCloud.com.app.sub.tracker`
9. 保存更改

### 方案 B: 使用默认容器（仅用于测试）

如果你只是想快速测试功能，可以：

1. 在 Xcode 的 "Signing & Capabilities" 中
2. 移除现有的 iCloud 容器配置
3. 让 Xcode 自动生成一个默认容器
4. 这样可以快速开始测试，但容器名称会不同

## 验证配置是否成功

配置完成后，重新运行应用并点击"同步 iCloud"按钮。

### 成功的日志应该是：

```
🔵 iCloud 同步状态: 已启用
✅ iCloud 账号已登录且可用
✅ 数据已保存到本地，CloudKit 将自动上传
✅ CloudKit 连接正常，用户 ID: _xxxxx
✅ Container ID: iCloud.com.app.sub.tracker
✅ 同步完成
```

### 如果还是看到错误：

```
⚠️ CloudKit 验证失败: Invalid bundle ID for container
```

可能的原因：

1. 容器还没有在 Apple Developer 账号中创建
2. 需要等待几分钟让配置生效
3. 需要重新登录 Xcode 的开发者账号

## 重要说明

### 1. SwiftData 自动同步

即使看到 CloudKit 验证错误，SwiftData 仍然会尝试在后台自动同步数据。验证错误主要影响手动检查功能，不一定影响实际的数据同步。

### 2. 测试同步功能

要真正测试 iCloud 同步是否工作：

1. 在设备 A 上添加一些订阅数据
2. 确保设备 A 已登录 iCloud 并开启了同步
3. 等待 2-5 分钟（CloudKit 同步需要时间）
4. 在设备 B 上（登录同一个 iCloud 账号）打开应用
5. 应该能看到设备 A 上添加的数据

### 3. 查看 CloudKit 数据

你可以在 CloudKit Dashboard 中查看实际上传的数据：

- 访问: https://icloud.developer.apple.com/dashboard/
- 选择你的容器: `iCloud.com.app.sub.tracker`
- 查看 "Data" 部分的记录

### 4. 开发环境 vs 生产环境

- 当前配置使用的是开发环境 (`aps-environment: development`)
- 发布到 App Store 时，Xcode 会自动切换到生产环境
- 开发和生产环境的数据是分开的

## 常见问题

### Q: 为什么同步需要这么长时间？

A: CloudKit 不是实时同步的，通常需要几秒到几分钟。这是正常的。

### Q: 如何知道数据已经同步成功？

A: 最可靠的方法是在另一个设备上查看数据是否出现。

### Q: 可以强制立即同步吗？

A: SwiftData 的 CloudKit 同步是自动的，无法强制立即同步。保存数据后，系统会在合适的时机上传。

### Q: 同步会消耗很多流量吗？

A: 不会。订阅数据很小，通常只有几 KB。

## 当前应用配置

- **应用名称**: Subora
- **Bundle ID**: `com.app.sub.tracker`
- **CloudKit 容器**: `iCloud.com.app.sub.tracker`
- **开发团队**: `DR9B4SVZCG`
- **最低系统版本**: iOS 26.2

## 需要帮助？

如果按照上述步骤操作后仍然有问题，请检查：

1. ✅ 是否已登录 Apple Developer 账号（在 Xcode 的 Preferences > Accounts 中）
2. ✅ 设备是否已登录 iCloud 账号
3. ✅ 是否有网络连接
4. ✅ 是否有有效的开发者证书

如果所有检查都通过但仍有问题，可能需要：

- 清理 Xcode 构建缓存 (Product > Clean Build Folder)
- 重启 Xcode
- 重新登录 Apple Developer 账号
