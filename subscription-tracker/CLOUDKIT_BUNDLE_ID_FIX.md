# CloudKit Bundle ID 问题修复

## 问题原因

错误信息：`Invalid bundle ID for container`

**根本原因：**

- 你的 Bundle ID: `com.app.sub.tracker`
- 你的 Container ID: `iCloud.com.app.sub.tracker`
- CloudKit 要求 Container 必须在 Apple Developer 中与 Bundle ID 关联

## 已修复内容

### 1. 更新了 entitlements 文件

使用动态变量 `$(CFBundleIdentifier)` 自动匹配 Bundle ID：

```xml
<key>com.apple.developer.icloud-container-identifiers</key>
<array>
    <string>iCloud.$(CFBundleIdentifier)</string>
</array>
```

这样会自动变成：`iCloud.com.app.sub.tracker`

### 2. 保持代码中的 container identifier 一致

```swift
let containerIdentifier = "iCloud.com.app.sub.tracker"
```

## 重要：在 Apple Developer 中配置

### 步骤 1: 访问 Apple Developer

1. 登录 [Apple Developer](https://developer.apple.com/account)
2. 进入 **Certificates, Identifiers & Profiles**

### 步骤 2: 配置 App ID

1. 选择 **Identifiers**
2. 找到你的 App ID: `com.app.sub.tracker`
3. 点击编辑
4. 确保勾选了 **iCloud** capability
5. 点击 **Edit** 配置 iCloud
6. 选择 **CloudKit**
7. 在 Containers 列表中：
   - 如果有 `iCloud.com.app.sub.tracker`，选中它
   - 如果没有，点击 **+** 创建新的 container：
     - Container ID: `iCloud.com.app.sub.tracker`
     - Description: Subscription Tracker Data
8. 保存

### 步骤 3: 重新生成 Provisioning Profile

1. 删除旧的 Provisioning Profile
2. 在 Xcode 中：
   - 选择项目 → Target → Signing & Capabilities
   - 点击 **Download Manual Profiles** 或让 Xcode 自动管理
3. 或者在 Developer 网站手动创建新的 Profile

### 步骤 4: 在 Xcode 中验证

1. 打开项目
2. 选择 Target → Signing & Capabilities
3. 确认看到：
   - ✅ iCloud
   - ✅ CloudKit
   - ✅ Container: iCloud.com.app.sub.tracker

### 步骤 5: 清理并重新构建

```bash
# 在 Xcode 中
1. Product → Clean Build Folder (⇧⌘K)
2. 删除 app（从设备/模拟器）
3. 重新运行
```

## 验证配置

运行 app 后，在 CloudKit 测试中运行"测试 3: 直接写入"：

### 成功的输出：

```
✅ 写入成功!
   Record ID: xxxxx
   Record Type: TestRecord
```

### 如果还是失败：

检查错误代码：

- **错误 10** (Permission Failure) - Bundle ID 配置问题
  - 确认 Developer 网站上的配置
  - 确认 container 已关联到 App ID
  - 重新生成 Provisioning Profile

- **错误 9** (Not Authenticated) - 未登录 iCloud
  - 在设备上登录 iCloud

- **错误 3** (Network Unavailable) - 网络问题
  - 检查网络连接

## 为什么使用 $(CFBundleIdentifier)

使用动态变量的好处：

1. 自动匹配 Bundle ID
2. 如果将来改 Bundle ID，不需要手动更新 entitlements
3. 避免硬编码错误

## 替代方案：使用默认 container

如果不想手动配置，可以使用 Xcode 自动生成的 container：

```swift
// 在 App 中
cloudKitDatabase: .automatic
```

但这样的缺点是：

- Container ID 由 Xcode 自动生成
- 不同开发者可能生成不同的 container
- 不利于团队协作

## 下一步

1. ✅ 代码已更新
2. ⏳ 在 Apple Developer 中配置 App ID 和 Container
3. ⏳ 重新生成 Provisioning Profile
4. ⏳ 清理并重新构建
5. ⏳ 运行测试验证

完成这些步骤后，CloudKit 同步应该就能正常工作了！
