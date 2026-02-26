# App Store Connect 配置指南

## 订阅产品配置

### 产品 ID 列表

应用使用以下两个订阅产品 ID：

1. **月度订阅**: `premium_monthly`
2. **年度订阅**: `premium_yearly`

### 在 App Store Connect 中配置步骤

#### 1. 创建订阅组

1. 登录 [App Store Connect](https://appstoreconnect.apple.com)
2. 选择你的应用
3. 进入 "功能" → "App 内购买项目"
4. 点击 "+" 创建新的订阅组
5. 输入订阅组名称（例如：Premium Subscription）
6. 输入订阅组参考名称

#### 2. 创建月度订阅产品

1. 在订阅组中点击 "+" 创建新订阅
2. 填写以下信息：
   - **产品 ID**: `premium_monthly`
   - **参考名称**: Premium Monthly Subscription
   - **订阅持续时间**: 1 个月
3. 定价：
   - 选择价格等级或自定义价格
   - 建议价格：$4.99/月 或根据市场调整

4. 本地化信息（三种语言）：

   **英文 (en)**
   - 显示名称: Premium Monthly
   - 描述: Unlock all premium features with monthly billing

   **简体中文 (zh-Hans)**
   - 显示名称: 高级月度订阅
   - 描述: 按月计费，解锁所有高级功能

   **日文 (ja)**
   - 显示名称: プレミアム月額プラン
   - 描述: 月額課金ですべてのプレミアム機能を利用

#### 3. 创建年度订阅产品

1. 在同一订阅组中点击 "+" 创建新订阅
2. 填写以下信息：
   - **产品 ID**: `premium_yearly`
   - **参考名称**: Premium Yearly Subscription
   - **订阅持续时间**: 1 年
3. 定价：
   - 建议价格：$47.99/年（相当于 $3.99/月，节省 20%）
   - 或根据月度价格计算年度优惠价

4. 本地化信息（三种语言）：

   **英文 (en)**
   - 显示名称: Premium Yearly
   - 描述: Best value! Unlock all premium features with annual billing and save 20%

   **简体中文 (zh-Hans)**
   - 显示名称: 高级年度订阅
   - 描述: 最超值！按年计费，解锁所有高级功能，节省 20%

   **日文 (ja)**
   - 显示名称: プレミアム年額プラン
   - 描述: 最もお得！年額課金ですべてのプレミアム機能を利用、20%お得

#### 4. 配置订阅功能

为两个订阅产品配置以下功能：

- ✅ 无限订阅记录
- ✅ 无限自定义分类
- ✅ 智能续费提醒
- ✅ iCloud 数据同步
- ✅ 高级图表分析

#### 5. 设置免费试用（可选）

如果要提供免费试用：

1. 在订阅产品设置中启用 "免费试用"
2. 设置试用期长度（建议 7 天）
3. 确保在应用中正确处理试用期逻辑

### 测试配置

#### 本地开发测试（使用 StoreKit Configuration 文件）

1. 在 Xcode 中打开项目
2. 选择 Product → Scheme → Edit Scheme
3. 在 Run → Options 中找到 "StoreKit Configuration"
4. 选择 `Configuration.storekit` 文件
5. 运行应用，现在可以测试订阅功能了

使用 StoreKit Configuration 文件的优势：

- 无需 App Store Connect 配置即可测试
- 可以快速测试订阅、恢复购买等功能
- 支持模拟不同的订阅状态
- 交易不会产生实际费用

#### 沙盒测试（真实 App Store 环境）

1. 在 App Store Connect 中创建沙盒测试账号
2. 在设备上登录沙盒账号
3. 运行应用并测试购买流程
4. 验证以下功能：
   - 产品列表正确加载
   - 价格显示正确
   - 购买流程顺畅
   - 恢复购买功能正常
   - Pro 功能正确解锁

### 应用内实现说明

#### PaywallService.swift

- 自动加载两个订阅产品
- 处理购买和恢复购买逻辑
- 验证交易并更新 Pro 状态
- 监听交易更新

#### PaywallView.swift

- 显示两个订阅计划卡片
- 年度计划显示 "节省 20%" 标签
- 年度计划显示月均价格
- 默认选中年度计划（更优惠）
- 支持切换选择不同计划

### 价格建议

根据市场调研，建议定价策略：

| 市场 | 月度价格 | 年度价格 | 年度月均 | 节省 |
| ---- | -------- | -------- | -------- | ---- |
| 美国 | $4.99    | $47.99   | $3.99    | 20%  |
| 中国 | ¥18      | ¥168     | ¥14      | 22%  |
| 日本 | ¥600     | ¥5,800   | ¥483     | 19%  |

### 注意事项

1. **产品 ID 不可更改**：一旦在 App Store Connect 中创建，产品 ID 无法修改
2. **审核要求**：确保应用正确实现 StoreKit 2，包括恢复购买功能
3. **隐私政策**：需要提供订阅服务的隐私政策和服务条款链接
4. **自动续订说明**：在购买界面清楚说明自动续订条款
5. **取消订阅**：提供清晰的取消订阅说明

### 后续步骤

1. ✅ 创建 StoreKit Configuration 文件用于本地测试
2. ✅ 在本地使用 Configuration.storekit 测试订阅功能
3. ⬜ 在 App Store Connect 中创建订阅产品
4. ⬜ 配置产品本地化信息
5. ⬜ 设置价格和可用地区
6. ⬜ 使用沙盒账号测试
7. ⬜ 提交应用审核
8. ⬜ 监控订阅转化率和收入

### 开发环境说明

#### 当前状态

- ✅ 代码已完成，支持月度和年度订阅
- ✅ StoreKit Configuration 文件已创建
- ✅ 开发模式下显示友好的错误提示
- ⬜ 需要在 Xcode 中配置 StoreKit Configuration

#### 如何在 Xcode 中启用 StoreKit Configuration

1. 打开 Xcode
2. 选择菜单：Product → Scheme → Edit Scheme...
3. 在左侧选择 "Run"
4. 切换到 "Options" 标签
5. 找到 "StoreKit Configuration" 选项
6. 点击下拉菜单，选择 "Configuration.storekit"
7. 点击 "Close" 保存

现在运行应用，paywall 将显示两个订阅计划，你可以测试购买流程。

#### CloudKit 警告说明

日志中的 CloudKit 警告是正常的：

```
Unable to initialize without an iCloud account (CKAccountStatusNoAccount)
```

这是因为：

- 模拟器默认没有登录 iCloud 账号
- 在真机上登录 iCloud 后这些警告会消失
- 不影响应用的其他功能

### 相关文档

- [StoreKit 2 官方文档](https://developer.apple.com/documentation/storekit)
- [App Store Connect 帮助](https://help.apple.com/app-store-connect/)
- [订阅最佳实践](https://developer.apple.com/app-store/subscriptions/)
