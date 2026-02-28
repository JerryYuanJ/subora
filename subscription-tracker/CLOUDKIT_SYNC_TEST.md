# CloudKit 同步测试指南

## 当前状态

你的配置是正确的：

- ✅ CloudKit 容器已创建: `iCloud.com.app.sub.tracker`
- ✅ SwiftData 配置了 CloudKit: `cloudKitDatabase: .automatic`
- ✅ Dashboard 可以访问

## 为什么 Dashboard 只显示 "Users"？

这是**正常的**！原因：

1. **SwiftData 记录类型是动态生成的** - 只有当你创建数据后，记录类型才会出现
2. **记录类型名称不同** - SwiftData 使用 `CD_` 前缀，例如：
   - `CD_Subscription` (订阅)
   - `CD_Category` (分类)
   - `CD_UserSettings` (用户设置)

## 如何验证同步真的工作？

### 方法 1: 在 Dashboard 中查看记录类型（推荐）

1. 在应用中添加一些测试数据：
   - 创建 2-3 个订阅
   - 创建 1-2 个分类
   - 开启 iCloud 同步

2. 等待 3-5 分钟（CloudKit 同步需要时间）

3. 回到 CloudKit Dashboard:
   - 点击左侧 "Schema" > "Record Types"
   - 你应该能看到：
     - `CD_Subscription`
     - `CD_Category`
     - `CD_UserSettings`

4. 然后回到 "Data" > "Records":
   - 在 "RECORD TYPE" 下拉菜单中选择 `CD_Subscription`
   - 点击 "Query Records"
   - 你应该能看到你创建的订阅数据

### 方法 2: 多设备测试（最可靠）

这是验证同步是否工作的最可靠方法：

1. **设备 A（当前设备）**:
   - 确保已登录 iCloud
   - 在应用中创建一个订阅，例如：
     - 名称: "Netflix 测试"
     - 价格: 99
     - 周期: 每月

2. **等待 2-5 分钟**

3. **设备 B（另一台设备或模拟器）**:
   - 登录**同一个 iCloud 账号**
   - 安装并打开应用
   - 等待几秒钟
   - 检查是否能看到 "Netflix 测试" 订阅

4. **如果能看到** = 同步工作正常！✅
5. **如果看不到** = 需要进一步调试 ❌

### 方法 3: 查看应用日志

在 Xcode 中运行应用，查看 Console 输出：

```
✅ SwiftData ModelContainer initialized (CloudKit: automatic)
🔵 iCloud 同步状态: 已启用
✅ iCloud 账号已登录且可用
✅ 数据已保存到本地，CloudKit 将自动上传
✅ CloudKit 连接正常
```

如果看到这些日志，说明配置正确。

## 常见问题

### Q: 为什么我点了同步但 Dashboard 还是看不到数据？

A: 可能的原因：

1. **还没有创建数据** - 先在应用中添加订阅
2. **同步还在进行中** - 等待 3-5 分钟
3. **查看了错误的记录类型** - 确保选择 `CD_Subscription` 而不是 `Subscription`

### Q: "同步成功" 是什么意思？

A: 应用显示的 "同步成功" 意味着：

- ✅ 数据已保存到本地 SwiftData 存储
- ✅ CloudKit 同步已触发
- ✅ 系统会在后台自动上传数据

但**不代表数据已经立即上传完成**。实际上传可能需要几分钟。

### Q: 如何强制立即同步？

A: 无法强制立即同步。CloudKit 由系统管理，会在合适的时机（有网络、有电量等）自动同步。

### Q: 同步失败了怎么办？

A: 检查：

1. 是否登录了 iCloud 账号（设置 > Apple ID）
2. 是否有网络连接
3. iCloud Drive 是否已开启
4. 应用是否有 iCloud 权限

## 调试步骤

如果怀疑同步不工作，按以下步骤调试：

### 1. 检查 iCloud 账号状态

在设备上：

- 打开 "设置" > 点击顶部的 Apple ID
- 确保已登录
- 进入 "iCloud"
- 确保 "iCloud Drive" 已开启

### 2. 检查应用日志

在 Xcode Console 中查找：

- ✅ 表示成功
- ⚠️ 表示警告（可能不影响功能）
- ❌ 表示错误（需要修复）

### 3. 清理并重新测试

如果怀疑有问题：

1. 删除应用
2. 在 Xcode 中 Clean Build Folder (Shift+Cmd+K)
3. 重新安装应用
4. 创建新的测试数据
5. 等待 5 分钟
6. 检查 Dashboard

### 4. 查看 CloudKit 日志

在 Dashboard 中：

- 点击左侧 "Monitor" > "Logs"
- 查看是否有错误信息
- 特别注意 "Private Database" 的日志

## 预期的 Dashboard 视图

同步成功后，你应该在 Dashboard 中看到：

### Schema > Record Types:

```
- CD_Category
- CD_Subscription
- CD_UserSettings
- Users (系统默认)
```

### Data > Records:

选择 `CD_Subscription` 后，应该能看到类似：

```
Record Name: ABC123-DEF456-...
Fields:
  - name: "Netflix"
  - price: 99.0
  - billingCycle: "monthly"
  - ...
```

## 下一步

1. **在应用中创建测试数据**
2. **等待 5 分钟**
3. **刷新 Dashboard 页面**
4. **在 Schema > Record Types 中查看是否出现了 CD\_\* 类型**
5. **在 Data > Records 中查询这些记录**

如果按照上述步骤操作后仍然看不到数据，可能需要检查：

- Apple Developer 账号的 CloudKit 权限
- 应用的 Bundle ID 和容器 ID 是否完全匹配
- 是否使用了正确的开发环境（Development vs Production）
