# iCloud CloudKit 配置指南

## 问题说明

当你看到错误 "Invalid bundle ID for container" (CKError code: 10) 时，这意味着 CloudKit 容器配置有问题。

## 解决方案

### 方案 1: 在 Apple Developer 网站配置 CloudKit（推荐用于发布）

1. 访问 [Apple Developer](https://developer.apple.com/account/)
2. 进入 "Certificates, Identifiers & Profiles"
3. 选择 "Identifiers"
4. 找到你的 App ID: `com.app.sub.tracker`
5. 编辑 App ID，确保启用了 "iCloud" capability
6. 在 iCloud 设置中，确保 CloudKit 容器 `iCloud.com.app.sub.tracker` 已创建并关联

### 方案 2: 使用 Xcode 自动配置（最简单）

1. 在 Xcode 中打开项目
2. 选择项目 target "subscription-tracker"
3. 进入 "Signing & Capabilities" 标签
4. 确保选择了正确的开发团队: `DR9B4SVZCG`
5. 点击 "+ Capability" 按钮
6. 添加 "iCloud" capability（如果还没有）
7. 在 iCloud 设置中：
   - 勾选 "CloudKit"
   - 确保容器列表中有 `iCloud.com.app.sub.tracker`
   - 如果没有，点击 "+" 创建新容器
8. Xcode 会自动在 Apple Developer 账号中创建和配置容器

### 方案 3: 修改为使用默认容器（开发测试用）

如果你只是想快速测试，可以让 Xcode 自动生成默认容器：

1. 在 Xcode 的 "Signing & Capabilities" 中
2. 移除现有的 iCloud 容器
3. 点击 "+" 添加新容器，使用默认名称
4. Xcode 会自动配置

## 当前配置

- Bundle ID: `com.app.sub.tracker`
- CloudKit Container: `iCloud.com.app.sub.tracker`
- Development Team: `DR9B4SVZCG`

## 验证配置

配置完成后，重新运行应用并点击"同步 iCloud"。你应该看到：

```
✅ CloudKit 连接正常，用户 ID: _xxxxx
✅ Container ID: iCloud.com.app.sub.tracker
```

而不是错误信息。

## 重要提示

1. **SwiftData 自动同步**: 即使看到 CloudKit 验证错误，SwiftData 仍然会在后台自动同步数据。这个错误主要影响手动验证功能。

2. **开发 vs 生产**:
   - 开发环境使用 `aps-environment: development`
   - 发布到 App Store 前需要切换到 `production`

3. **测试同步**:
   - 在多个设备上登录同一个 iCloud 账号
   - 在一个设备上添加数据
   - 等待几分钟后在另一个设备上查看

4. **调试技巧**:
   - 在 Xcode 中查看 Console 日志
   - 使用 CloudKit Dashboard 查看数据: https://icloud.developer.apple.com/dashboard/
