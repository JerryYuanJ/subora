# Provisioning Profile 完整指南

## 什么是 Provisioning Profile？

Provisioning Profile 是一个证书文件，告诉苹果服务器：

- 这个 app 是谁开发的
- 这个 app 有权限使用哪些功能（iCloud、CloudKit 等）
- 这个 app 可以在哪些设备上运行

## 在 Xcode 中查看

### 方法 1: 在项目设置中查看

1. 打开 Xcode
2. 选择项目（左侧最顶部的蓝色图标）
3. 选择 Target（subscription-tracker）
4. 点击 **Signing & Capabilities** 标签
5. 查看：

```
Team: [你的 Apple ID 或团队]
Signing Certificate: Apple Development
Provisioning Profile: [自动管理 或 具体的 profile 名称]
```

### 方法 2: 查看详细信息

在 Signing & Capabilities 页面：

- 如果勾选了 **"Automatically manage signing"**
  - Xcode 会自动生成和管理 profile
  - 你会看到 "Xcode Managed Profile"
- 如果没有勾选（手动管理）
  - 需要从下拉菜单选择 profile
  - 或者从 Apple Developer 网站下载

## 解决你的问题

### 错误原因

`Invalid bundle ID for container` 说明：

- Provisioning Profile 中的 App ID 配置
- 与 CloudKit Container 的关联
- 有问题或不匹配

### 解决步骤

#### 步骤 1: 重新生成 Provisioning Profile

在 Xcode 中：

1. 选择 Target → Signing & Capabilities
2. **取消勾选** "Automatically manage signing"
3. 等待 2 秒
4. **重新勾选** "Automatically manage signing"
5. Xcode 会显示 "Provisioning profile ... doesn't include the ... entitlement"
6. 点击 **"Try Again"** 或等待自动完成
7. 看到 ✅ 表示成功

#### 步骤 2: 清理并重新构建

```bash
# 在 Xcode 中
1. Product → Clean Build Folder (⇧⌘K)
2. 关闭 Xcode
3. 删除 DerivedData:
   rm -rf ~/Library/Developer/Xcode/DerivedData
4. 重新打开 Xcode
5. 重新运行
```

#### 步骤 3: 如果还是失败，检查 Apple Developer 网站

1. 访问 https://developer.apple.com/account
2. 登录你的 Apple ID
3. 进入 **Certificates, Identifiers & Profiles**
4. 点击 **Identifiers**
5. 找到 `com.app.sub.tracker`
6. 点击进入，检查：
   - ✅ iCloud 是否勾选
   - ✅ CloudKit 是否勾选
   - ✅ Containers 中是否有 `iCloud.com.app.sub.tracker`
7. 如果有任何修改，点击 **Save**

#### 步骤 4: 删除旧的 Provisioning Profiles

```bash
# 在终端执行
rm -rf ~/Library/MobileDevice/Provisioning\ Profiles/*
```

然后回到 Xcode，重复步骤 1。

## 最简单的解决方案

如果上面的步骤太复杂，试试这个：

### 方案 A: 使用个人 Team

如果你用的是个人 Apple ID（免费账号）：

1. 在 Xcode 中，Signing & Capabilities
2. Team 选择你的个人 Apple ID
3. Bundle ID 改成唯一的，比如：
   ```
   com.yourname.subscription-tracker
   ```
4. Xcode 会自动创建 App ID 和 Container
5. 重新运行

### 方案 B: 创建新的 App ID

1. 在 Apple Developer 网站
2. Identifiers → 点击 **+** 创建新的
3. 选择 **App IDs**
4. Description: Subscription Tracker
5. Bundle ID: `com.app.sub.tracker`
6. 勾选 **iCloud**
7. 配置 CloudKit，选择或创建 container
8. 保存

### 方案 C: 使用不同的 Container

如果 `iCloud.com.app.sub.tracker` 有问题，创建新的：

1. 在 Xcode 的 Signing & Capabilities
2. iCloud → Containers
3. 取消勾选 `iCloud.com.app.sub.tracker`
4. 点击 **+** 创建新 container
5. 输入: `iCloud.com.app.sub.tracker.new`
6. 保存

然后代码不需要改（因为用的是 `.automatic`）。

## 调试技巧

### 查看当前使用的 Container

在 app 启动时，控制台会显示：

```
📦 使用 Container: iCloud.com.app.sub.tracker
```

### 查看 Provisioning Profile 详情

在终端执行：

```bash
# 查看所有 profiles
ls -la ~/Library/MobileDevice/Provisioning\ Profiles/

# 查看某个 profile 的内容
security cms -D -i ~/Library/MobileDevice/Provisioning\ Profiles/xxxxx.mobileprovision
```

### 验证 App ID 配置

在终端执行：

```bash
# 查看 entitlements
codesign -d --entitlements :- /path/to/your.app
```

## 常见问题

### Q: 为什么会出现 "Invalid bundle ID for container"？

A: 可能的原因：

1. App ID 在 Apple Developer 网站上没有关联这个 container
2. Provisioning Profile 是旧的，没有包含 iCloud capability
3. Bundle ID 拼写错误
4. 使用了错误的 Team

### Q: 免费 Apple ID 可以用 CloudKit 吗？

A: 可以！但有限制：

- 只能在自己的设备上测试
- 不能发布到 App Store
- Container 名称必须是 `iCloud.` + Bundle ID

### Q: 如何确认 Provisioning Profile 是最新的？

A: 在 Xcode 中：

1. Signing & Capabilities
2. 看到 "Provisioning Profile" 下面的日期
3. 如果是今天或最近几天，就是最新的

### Q: 可以手动下载 Provisioning Profile 吗？

A: 可以，但不推荐：

1. 在 Apple Developer 网站
2. Profiles → 找到对应的 profile
3. 下载 `.mobileprovision` 文件
4. 双击安装
5. 在 Xcode 中选择这个 profile

## 推荐做法

对于你的情况，我建议：

1. **使用 Xcode 自动管理**（最简单）
   - 勾选 "Automatically manage signing"
   - 让 Xcode 处理所有配置

2. **使用 `.automatic` 模式**（已经改了）
   - 代码中用 `cloudKitDatabase: .automatic`
   - Xcode 会自动选择正确的 container

3. **如果还是失败，改 Bundle ID**
   - 改成完全不同的，比如 `com.yourname.subtracker`
   - 让 Xcode 重新创建所有配置

## 下一步

试试这个最简单的方法：

1. 在 Xcode 中，取消勾选 "Automatically manage signing"
2. 重新勾选
3. Clean Build Folder
4. 重新运行

如果还是失败，告诉我你看到的具体错误信息。
