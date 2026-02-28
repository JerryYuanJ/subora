# CloudKit 同步调试指南

## 当前问题分析

### 日志显示

```
📊 当前数据: 0 个订阅, 1 个分类
```

### 问题

1. **没有订阅数据** - 只有 1 个分类，没有订阅
2. **CloudKit Console 显示 PUBLIC 数据库** - 但 SwiftData 使用的是 PRIVATE 数据库

## 解决步骤

### 步骤 1: 创建测试数据

在应用中创建一些测试订阅：

1. 打开应用
2. 点击 "+" 添加订阅
3. 创建 2-3 个测试订阅，例如：
   - Netflix - ¥99/月
   - Spotify - ¥10/月
   - iCloud+ - ¥6/月

### 步骤 2: 触发同步

1. 进入设置页面
2. 确保 "iCloud 同步" 开关是开启的
3. 点击 "手动同步" 按钮
4. 查看日志，应该显示：
   ```
   📊 当前数据: 3 个订阅, X 个分类
   ```

### 步骤 3: 在 CloudKit Dashboard 中查看

**重要：切换到 Private Database**

1. 打开 CloudKit Dashboard
2. 选择容器: `iCloud.com.app.sub.tracker`
3. 选择环境: **Development** (开发环境)
4. **关键步骤：** 在顶部切换数据库
   - 点击 "Private Database" 下拉菜单
   - 选择 **"Private Database"** (不是 Public)
5. 点击左侧 "Data" > "Records"
6. 等待 3-5 分钟后刷新页面

### 步骤 4: 查看记录类型

在 Private Database 中：

1. 点击左侧 "Schema" > "Record Types"
2. 应该能看到：
   - `CD_Subscription`
   - `CD_Category`
   - `CD_UserSettings`
   - `CDMR_*` (SwiftData 的元数据记录)

3. 回到 "Data" > "Records"
4. 在 "RECORD TYPE" 下拉菜单中选择 `CD_Subscription`
5. 点击 "Query Records"
6. 应该能看到你创建的订阅数据

## 为什么看不到数据？

### 原因 1: 数据库选择错误

**最常见的问题！**

CloudKit Dashboard 默认显示的是 **Public Database**，但 SwiftData 使用的是 **Private Database**。

```
Public Database  ← 你在这里看（错误）
Private Database ← 数据在这里（正确）
Shared Database
```

### 原因 2: 没有数据

如果应用中没有创建订阅，就不会有数据上传。

### 原因 3: 同步延迟

CloudKit 同步不是实时的，可能需要：

- 最快：几秒钟
- 通常：2-5 分钟
- 最慢：10-15 分钟（网络差时）

### 原因 4: 环境选择错误

确保选择了正确的环境：

- **Development** - 开发环境（Xcode 运行时使用）
- **Production** - 生产环境（App Store 版本使用）

从 Xcode 运行的应用使用 Development 环境。

## 验证同步是否真的工作

### 方法 1: 查看 CloudKit Console Logs

1. 在 Dashboard 中点击左侧 "Monitor" > "Logs"
2. 选择 **Private Database**
3. 查看最近的操作日志
4. 应该能看到：
   - `RecordSave` - 保存记录
   - `RecordFetch` - 获取记录
   - `ZoneFetch` - 获取区域

### 方法 2: 多设备测试（最可靠）

这是验证同步的最可靠方法：

1. **设备 A**:
   - 创建一个订阅: "测试订阅 - ¥99/月"
   - 点击手动同步
   - 等待看到 "✅ 同步完成"

2. **等待 3-5 分钟**

3. **设备 B** (或模拟器):
   - 登录同一个 iCloud 账号
   - 安装并打开应用
   - 等待几秒钟
   - 查看是否能看到 "测试订阅"

4. **如果能看到** = 同步工作！✅
5. **如果看不到** = 继续调试 ❌

## 调试检查清单

### ✅ 基础配置

- [ ] 已登录 iCloud 账号（设置 > Apple ID）
- [ ] 网络连接正常
- [ ] 应用中有数据（至少 1-2 个订阅）
- [ ] iCloud 同步开关已开启

### ✅ CloudKit Dashboard

- [ ] 选择了正确的容器: `iCloud.com.app.sub.tracker`
- [ ] 选择了 **Development** 环境
- [ ] 切换到了 **Private Database**（不是 Public）
- [ ] 等待了至少 5 分钟

### ✅ Xcode 配置

- [ ] Bundle ID: `com.app.sub.tracker`
- [ ] Team: Jerry Yuan (DR9B4SVZCG)
- [ ] iCloud capability 已启用
- [ ] CloudKit 已勾选
- [ ] 容器: `iCloud.com.app.sub.tracker` 已添加

## 常见错误

### 错误 1: "Query records to get started"

**原因：** 没有选择记录类型或没有数据

**解决：**

1. 确保在 Private Database 中
2. 在 "RECORD TYPE" 下拉菜单中选择 `CD_Subscription`
3. 点击 "Query Records"

### 错误 2: 只看到 "Users" 记录类型

**原因：** 还没有创建数据或同步还没完成

**解决：**

1. 在应用中创建订阅
2. 等待 5 分钟
3. 刷新 Dashboard 页面
4. 检查 Schema > Record Types

### 错误 3: "Invalid bundle ID for container"

**原因：** 容器配置问题

**解决：**

1. 在 Xcode 中点击容器旁边的刷新按钮
2. Clean Build Folder (Shift+Cmd+K)
3. 重新运行应用

## 预期结果

### 成功的 Dashboard 视图

**Schema > Record Types:**

```
✅ CD_Category
✅ CD_Subscription
✅ CD_UserSettings
✅ CDMR_* (多个元数据记录)
✅ Users
```

**Data > Records (选择 CD_Subscription):**

```
Record: ABC123-DEF456-...
Fields:
  ├─ name: "Netflix"
  ├─ amount: 99.0
  ├─ currency: "CNY"
  ├─ billingCycle: 1
  ├─ billingCycleUnit: "monthly"
  ├─ startDate: 2026-02-28T...
  └─ ... (其他字段)
```

### 成功的应用日志

```
✅ SwiftData ModelContainer initialized (CloudKit: automatic)
🔵 iCloud 同步状态: 已启用
✅ iCloud 账号已登录且可用
📊 当前数据: 3 个订阅, 2 个分类  ← 有数据
✅ 数据已保存到本地，CloudKit 将自动上传
✅ CloudKit 连接正常
   用户 ID: _xxxxx
   容器 ID: iCloud.com.app.sub.tracker
✅ 同步完成
```

## 下一步

1. **创建测试数据** - 在应用中添加 2-3 个订阅
2. **触发同步** - 点击手动同步按钮
3. **等待 5 分钟** - 喝杯咖啡 ☕️
4. **检查 Dashboard** - 切换到 Private Database 查看
5. **多设备测试** - 在另一台设备上验证

## 如果还是不行

如果按照上述步骤操作后仍然看不到数据：

1. **检查 Xcode Console** - 查看是否有错误日志
2. **查看 CloudKit Logs** - Dashboard > Monitor > Logs
3. **尝试重新登录 iCloud** - 设置 > Apple ID > 退出登录 > 重新登录
4. **清理并重建** - Xcode > Product > Clean Build Folder
5. **删除应用重新安装** - 完全清理后重新测试

## 技术说明

### SwiftData + CloudKit 的工作原理

```
应用层
  ├─ @Query 自动更新 UI
  └─ modelContext.save() 保存数据
      ↓
SwiftData 层
  ├─ 本地 SQLite 存储
  └─ 自动同步到 CloudKit
      ↓
CloudKit 层
  ├─ Private Database (用户私有数据)
  ├─ 自动冲突解决
  └─ 推送到其他设备
      ↓
其他设备
  ├─ 自动下载更新
  └─ SwiftData 自动更新本地数据
      ↓
  UI 自动刷新
```

### 数据流向

```
设备 A 添加订阅
  → modelContext.save()
  → SwiftData 保存到本地
  → SwiftData 标记需要上传
  → 系统在合适时机上传到 CloudKit
  → CloudKit 存储在 Private Database
  → CloudKit 推送通知到设备 B
  → 设备 B 的 SwiftData 自动下载
  → 设备 B 的 UI 自动更新
```

整个过程是自动的，开发者只需要调用 `modelContext.save()`。
