# CloudKit 错误 10 (Permission Failure) 排查

## 当前状态

✅ Bundle ID: `com.app.sub.tracker`
✅ Container: `iCloud.com.app.sub.tracker` (已在 Xcode 中选择)
✅ Entitlements: 已配置
❌ 错误: Permission Failure (错误代码 10)

## 错误原因

错误 10 通常是因为：

1. Provisioning Profile 没有包含 iCloud capability
2. Xcode 的签名配置没有同步
3. 设备/模拟器的 provisioning 过期

## 解决步骤

### 步骤 1: 清理 Xcode 缓存

```bash
# 关闭 Xcode
# 删除 DerivedData
rm -rf ~/Library/Developer/Xcode/DerivedData

# 删除旧的 provisioning profiles
rm -rf ~/Library/MobileDevice/Provisioning\ Profiles/*
```

### 步骤 2: 在 Xcode 中重新配置签名

1. 打开项目
2. 选择 Target → Signing & Capabilities
3. 如果是 **Automatically manage signing**:
   - 取消勾选
   - 重新勾选
   - 等待 Xcode 重新生成 profile
4. 如果是 **Manual signing**:
   - 在 Apple Developer 网站重新生成 Provisioning Profile
   - 下载并双击安装

### 步骤 3: 验证 Capabilities

在 Signing & Capabilities 中确认：

- ✅ iCloud (勾选)
- ✅ CloudKit (勾选)
- ✅ Containers: `iCloud.com.app.sub.tracker` (已选择)

### 步骤 4: 检查 Team 配置

确保：

1. 选择了正确的 Team
2. Team 有权限访问这个 container
3. 如果是个人账号，确认 container 是在这个账号下创建的

### 步骤 5: 清理并重新构建

在 Xcode 中：

```
1. Product → Clean Build Folder (⇧⌘K)
2. 删除 app（从设备/模拟器）
3. 重启 Xcode
4. 重新运行
```

### 步骤 6: 检查设备 iCloud 登录

在设备/模拟器上：

1. 设置 → [你的名字]
2. 确认已登录 iCloud
3. 确认 iCloud Drive 已开启

## 如果还是失败

### 方案 A: 使用 Xcode 自动生成的 container

这是最简单的方案，让 Xcode 自动管理：

1. 在 Xcode 中，Signing & Capabilities → iCloud
2. 点击 "+" 添加新 container
3. 让 Xcode 自动生成（通常是 `iCloud.com.yourteam.appname`）
4. 更新代码使用这个新 container

修改 `subscription_trackerApp.swift`:

```swift
// 使用 automatic 让 Xcode 自动选择
let modelConfiguration = ModelConfiguration(
    schema: schema,
    isStoredInMemoryOnly: false,
    cloudKitDatabase: .automatic  // 改成 automatic
)
```

### 方案 B: 创建新的 container

如果 `iCloud.com.app.sub.tracker` 有问题，创建新的：

1. 在 Apple Developer 网站
2. Identifiers → 你的 App ID
3. 删除旧的 container 关联
4. 创建新的 container: `iCloud.com.app.sub.tracker.v2`
5. 在 Xcode 中选择新 container
6. 更新代码

### 方案 C: 检查是否是 Development vs Production 问题

1. 确认你在 Debug 模式运行
2. 确认 entitlements 中是 `development`:
   ```xml
   <key>aps-environment</key>
   <string>development</string>
   ```
3. 在 CloudKit Dashboard 中查看 Development 环境

## 调试命令

在 app 启动时查看日志：

```
========== CloudKit 配置验证 ==========
📦 Default Container ID: iCloud.com.app.sub.tracker
📦 Custom Container ID: iCloud.com.app.sub.tracker

🧪 测试直接写入 CloudKit...
```

如果看到：

- ✅ `CloudKit 写入成功` - 配置正确
- ❌ `错误代码: 10` - 继续排查
- ❌ `错误代码: 9` - iCloud 未登录
- ❌ `错误代码: 3` - 网络问题

## 最简单的验证方法

创建一个全新的测试项目：

1. File → New → Project
2. 选择 iOS App
3. 勾选 CloudKit
4. 运行看是否能正常工作

如果测试项目可以，说明是当前项目的配置问题。
如果测试项目也不行，说明是账号或环境问题。

## 常见原因总结

| 错误                    | 原因                               | 解决方案                  |
| ----------------------- | ---------------------------------- | ------------------------- |
| Permission Failure (10) | Provisioning Profile 不包含 iCloud | 重新生成 profile          |
| Permission Failure (10) | Container 未关联到 App ID          | 在 Developer 网站配置     |
| Permission Failure (10) | Team 不匹配                        | 检查 Xcode 中的 Team 选择 |
| Not Authenticated (9)   | 未登录 iCloud                      | 在设备上登录              |
| Network Unavailable (3) | 网络问题                           | 检查网络连接              |

## 推荐做法

如果你只是想快速测试 CloudKit 同步功能，最简单的方法是：

```swift
// 使用 automatic
cloudKitDatabase: .automatic
```

然后在 Xcode 的 Signing & Capabilities 中让 Xcode 自动管理 container。这样可以避免所有手动配置的问题。
