# iCloud 同步调试指南

## 问题：显示同步成功但 iCloud 上看不到数据

### 已修复的配置问题

1. **添加了 ubiquity-container-identifiers**
   - 在 `subscription-tracker.entitlements` 中添加了必需的配置
   - SwiftData 的 `.automatic` 或 `.private()` 模式都需要这个配置

2. **明确指定 Container Identifier**
   - 从 `.automatic` 改为 `.private("iCloud.com.app.sub.tracker")`
   - 这样可以确保使用正确的 container

### 验证步骤

#### 1. 检查 Xcode 配置

在 Xcode 中：

1. 选择项目 → Target → Signing & Capabilities
2. 确认有 **iCloud** capability
3. 确认勾选了：
   - ☑️ CloudKit
   - ☑️ CloudKit container: `iCloud.com.app.sub.tracker`

#### 2. 检查 iCloud 账号

在设备上：

1. 设置 → [你的名字] → iCloud
2. 确认已登录 iCloud
3. 确认 iCloud Drive 已开启

#### 3. 清理并重新构建

```bash
# 在 Xcode 中
1. Product → Clean Build Folder (Shift + Cmd + K)
2. 删除 app（从模拟器/设备上）
3. 重新运行
```

#### 4. 验证数据同步

运行 app 后，在控制台查看日志：

```
✅ SwiftData ModelContainer initialized
📦 CloudKit Container: iCloud.com.app.sub.tracker
🔐 Database: Private
```

添加一些订阅数据后，查看同步日志：

```
📊 当前数据: X 个订阅, Y 个分类
✅ 数据已保存到本地，CloudKit 将自动上传
✅ CloudKit 连接正常
```

#### 5. 在 CloudKit Dashboard 中验证

1. 访问 [CloudKit Dashboard](https://icloud.developer.apple.com/dashboard)
2. 选择你的 container: `iCloud.com.app.sub.tracker`
3. 选择 **Private Database**
4. 查看 Record Types：
   - `CD_Subscription` - 订阅数据
   - `CD_Category` - 分类数据
   - `CD_UserSettings` - 用户设置
   - `CDMR` - SwiftData 元数据

**注意：** 新创建的 container 可能需要几分钟才能在 Dashboard 中显示数据。

#### 6. 测试多设备同步

1. 在设备 A 上添加订阅
2. 等待 30 秒 - 2 分钟
3. 在设备 B（登录同一 iCloud 账号）上打开 app
4. 数据应该自动出现

### 常见问题

#### Q: 为什么之前显示"同步成功"但没有数据？

A: 因为缺少 `ubiquity-container-identifiers` 配置，SwiftData 无法正确同步到 iCloud，但本地保存成功了，所以显示"同步成功"。

#### Q: 数据多久会同步到 iCloud？

A: 通常是几秒到几分钟。CloudKit 会批量上传数据以节省电量和流量。

#### Q: 如何强制立即同步？

A: SwiftData 会自动管理同步时机。你可以：

1. 在设置中点击"立即同步"
2. 或者等待系统自动同步

#### Q: 如何确认数据真的在 iCloud 上？

A: 三种方法：

1. 在另一台设备上登录同一 iCloud 账号并打开 app
2. 在 CloudKit Dashboard 中查看记录
3. 删除 app 重新安装，数据应该自动恢复

### 如果还是不工作

1. **检查 Bundle ID**
   - 确保 Bundle ID 与 container identifier 匹配
   - Container: `iCloud.com.app.sub.tracker`
   - Bundle ID 应该是: `com.app.sub.tracker`

2. **重新生成 Provisioning Profile**
   - 在 Apple Developer 网站上
   - 确保 profile 包含 iCloud capability

3. **检查网络**
   - 确保设备有网络连接
   - 尝试在 Wi-Fi 环境下测试

4. **查看系统日志**
   ```bash
   # 在 Mac 上使用 Console.app
   # 过滤: process:subscription-tracker AND cloudkit
   ```

### 调试命令

在 app 的设置页面，点击"立即同步"，查看控制台输出：

```
🔵 正在同步数据到 iCloud...
📍 使用容器: iCloud.com.app.sub.tracker
📍 数据库类型: Private Database
📊 当前数据: X 个订阅, Y 个分类
✅ 数据已保存到本地，CloudKit 将自动上传
🔵 验证 CloudKit 连接...
✅ CloudKit 连接正常
   用户 ID: _xxxxx
   容器 ID: iCloud.com.app.sub.tracker
✅ 同步完成
```

如果看到错误，根据错误代码查找解决方案。
