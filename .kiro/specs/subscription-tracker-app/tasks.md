# Implementation Plan: Subscription Tracker iOS App

## Overview

本实现计划将 Subscription Tracker 应用分解为可执行的开发任务。应用采用 SwiftUI + SwiftData 技术栈，MVVM 架构模式。实现顺序遵循从底层到上层的原则：数据模型 → Service 层 → ViewModel 层 → View 层，确保每一步都有坚实的基础。

技术栈：SwiftUI (iOS 17+), SwiftData, UserNotifications, CloudKit, StoreKit 2

## Tasks

- [x] 1. 项目初始化和核心数据模型
  - 创建 Xcode 项目，配置 iOS 17+ 目标
  - 定义 SwiftData 模型：Subscription, Category, UserSettings
  - 配置 SwiftData ModelContainer 和 CloudKit 集成
  - 实现 BillingCycleUnit 枚举和辅助扩展
  - 创建 Color 扩展用于十六进制颜色转换
  - _Requirements: 1.8, 2.4, 7.7, 12.4_

- [ ] 2. 计费周期计算核心算法
  - [x] 2.1 实现 BillingCalculator 结构体
    - 实现 calculateNextBillingDate 方法（处理日/周/月/年周期）
    - 实现月末日期调整逻辑（1/31 → 2/28）
    - 实现闰年检测和处理（2/29 在非闰年使用 2/28）
    - 实现 calculateAllBillingDates 方法（计算历史续费日期）
    - 实现 convertToMonthlyAmount 方法（转换为月度等效金额）
    - _Requirements: 9.1, 9.2, 9.3, 9.4, 9.5_

- [x] 3. Checkpoint - 验证核心算法
  - 确保 BillingCalculator 所有方法正确处理边界情况，如有问题请询问用户

- [ ] 4. Service 层实现 - 通知服务
  - [x] 4.1 实现 NotificationService 类
    - 实现通知权限请求（requestAuthorization）
    - 实现通知调度（scheduleNotification）
    - 实现通知更新（updateNotification）
    - 实现通知取消（cancelNotifications, cancelAllNotifications）
    - 实现权限状态检查（checkAuthorizationStatus）
    - _Requirements: 6.1, 6.2, 6.3, 6.4, 6.5, 6.7_

- [ ] 5. Service 层实现 - 订阅服务
  - [x] 5.1 实现 SubscriptionService 类
    - 实现创建订阅（createSubscription，包含免费用户限制检查）
    - 实现更新订阅（updateSubscription，同步更新通知）
    - 实现删除订阅（deleteSubscription，取消通知）
    - 实现归档/取消归档（archiveSubscription, unarchiveSubscription）
    - 实现查询方法（fetchActiveSubscriptions, fetchArchivedSubscriptions, searchSubscriptions, fetchSubscriptionsByCategory）
    - 实现统计计算（calculateMonthlyTotal, calculateMonthlyTrend, fetchUpcomingRenewals）
    - 实现历史支出计算（calculateHistoricalExpense）
    - _Requirements: 1.2, 1.4, 1.5, 1.6, 1.7, 3.5, 4.1, 4.2, 4.3, 4.5, 5.1, 5.2, 5.3, 5.5, 11.4_

- [ ] 6. Service 层实现 - 分类和辅助服务
  - [x] 6.1 实现 CategoryService 类
    - 实现创建分类（createCategory，包含免费用户限制检查）
    - 实现更新分类（updateCategory）
    - 实现删除分类（deleteCategory，解除订阅关联）
    - 实现查询方法（fetchAllCategories）
    - _Requirements: 2.1, 2.2, 2.3, 3.6_

  - [x] 6.2 实现 CurrencyFormatter 结构体
    - 实现货币格式化（format 方法）
    - 实现货币符号获取（symbol 方法）
    - 定义支持的货币列表常量
    - _Requirements: 4.6, 13.1, 13.3_

  - [x] 6.3 实现 PaywallService 类
    - 实现限制检查（canCreateSubscription, canCreateCategory）
    - 实现 StoreKit 2 购买流程（purchaseProVersion）
    - 实现恢复购买（restorePurchases）
    - 实现购买状态检查（checkPurchaseStatus）
    - 管理 isProUser 状态
    - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.7, 10.4, 10.5_

- [ ] 7. Service 层实现 - iCloud 同步
  - [x] 7.1 实现 SyncService 类
    - 实现同步开关（enableSync, disableSync）
    - 实现手动同步（syncNow）
    - 实现冲突解决（resolveConflict，保留最新 updatedAt）
    - 实现同步状态查询（getSyncStatus）
    - _Requirements: 8.1, 8.2, 8.3, 8.4, 8.5_

- [x] 8. Checkpoint - 验证 Service 层
  - 确保所有 Service 类正确集成 SwiftData 和外部框架，如有问题请询问用户

- [ ] 9. 错误处理和日志系统
  - [x] 9.1 定义 AppError 枚举
    - 定义所有错误类型（数据错误、限制错误、通知错误、同步错误、购买错误）
    - 实现 LocalizedError 协议，提供中文错误描述
    - _Requirements: 15.1, 15.2, 15.3_

  - [x] 9.2 配置 OSLog 日志系统
    - 创建 Logger 扩展，定义不同子系统（app, data, sync, notification）
    - 在关键操作中添加日志记录
    - _Requirements: 15.1, 15.2_

- [ ] 10. ViewModel 层实现 - Dashboard
  - [x] 10.1 实现 DashboardViewModel 类
    - 定义 @Published 属性（monthlyExpenses, trendData, upcomingRenewals, isLoading）
    - 实现 loadData 方法（加载月度支出、趋势数据、即将到期订阅）
    - 实现按货币分组的支出统计
    - 实现 MonthlyExpense 数据结构
    - _Requirements: 4.1, 4.2, 4.3, 4.4, 4.5, 13.5_

- [ ] 11. ViewModel 层实现 - 订阅管理
  - [x] 11.1 实现 SubscriptionListViewModel 类
    - 定义 @Published 属性（subscriptions, filteredSubscriptions, searchQuery, selectedCategory, showArchived）
    - 实现 loadSubscriptions 方法
    - 实现 applyFilters 方法（搜索、分类筛选、排序）
    - _Requirements: 5.1, 5.2, 5.3, 5.5_

  - [x] 11.2 实现 AddEditSubscriptionViewModel 类
    - 定义 @Published 属性（subscription, validationErrors, isSaving）
    - 实现表单验证（validate 方法）
    - 实现保存逻辑（save 方法，包含免费用户限制检查）
    - 区分创建和编辑模式
    - _Requirements: 1.1, 1.2, 1.3, 1.4, 3.3_

  - [x] 11.3 实现 SubscriptionDetailViewModel 类
    - 定义 @Published 属性（subscription, historicalTotal, paymentCount, daysUntilRenewal）
    - 实现 loadDetails 方法（计算历史支出和续费天数）
    - 实现归档和删除操作
    - _Requirements: 11.1, 11.2, 11.3, 11.4, 11.5_

- [ ] 12. ViewModel 层实现 - 分类和设置
  - [x] 12.1 实现 CategoryViewModel 类
    - 定义 @Published 属性（categories, isLoading）
    - 实现 CRUD 操作（create, update, delete）
    - 实现分类列表加载
    - _Requirements: 2.1, 2.2, 2.3, 3.4_

  - [x] 12.2 实现 SettingsViewModel 类
    - 定义 @Published 属性（userSettings, isLoading）
    - 实现设置加载和保存
    - 实现 iCloud 同步开关切换
    - 实现主题和货币设置更新
    - _Requirements: 7.1, 7.2, 7.3, 7.4, 7.5, 7.6_

- [x] 13. Checkpoint - 验证 ViewModel 层
  - 确保所有 ViewModel 正确调用 Service 层并管理状态，如有问题请询问用户

- [ ] 14. 可复用 UI 组件
  - [x] 14.1 实现基础 UI 组件
    - 实现 SubscriptionCard 组件（显示订阅卡片，支持左滑操作）
    - 实现 CategoryBadge 组件（显示分类标签和颜色）
    - 实现 LoadingOverlay 组件（加载遮罩）
    - 实现 ToastView 组件（Toast 提示，支持 success/error/info 类型）
    - _Requirements: 14.1, 14.2, 14.4, 14.6, 15.5_

  - [x] 14.2 实现表单输入组件
    - 实现 CurrencyPicker 组件（货币选择器）
    - 实现 BillingCyclePicker 组件（计费周期选择器）
    - 实现颜色选择器组件（用于分类颜色选择）
    - _Requirements: 2.5, 13.2_

  - [x] 14.3 实现 TrendChart 组件
    - 使用 Swift Charts 实现折线图
    - 显示过去 6 个月的支出趋势
    - 支持多货币分别显示
    - _Requirements: 4.2_

- [ ] 15. View 层实现 - Dashboard
  - [x] 15.1 实现 DashboardView
    - 创建主页布局（月度支出卡片、趋势图、即将到期列表）
    - 集成 DashboardViewModel
    - 实现按货币分组的支出显示
    - 集成 TrendChart 组件
    - 实现即将到期订阅列表（使用 SubscriptionCard）
    - 添加导航栏右侧的添加按钮
    - _Requirements: 4.1, 4.2, 4.3, 4.4, 4.6, 14.5_

- [ ] 16. View 层实现 - 订阅列表和详情
  - [x] 16.1 实现 SubscriptionListView
    - 创建订阅列表布局
    - 集成 SubscriptionListViewModel
    - 实现搜索栏
    - 实现分类筛选按钮组
    - 实现订阅卡片列表（使用 SubscriptionCard）
    - 实现左滑操作（编辑、归档、删除）
    - 实现删除确认对话框
    - _Requirements: 5.1, 5.2, 5.3, 5.4, 14.5, 15.4_

  - [x] 16.2 实现 AddEditSubscriptionView
    - 创建表单布局（名称、描述、分类、日期、周期、金额、通知）
    - 集成 AddEditSubscriptionViewModel
    - 实现表单验证和错误显示
    - 集成 CurrencyPicker 和 BillingCyclePicker
    - 实现日期选择器
    - 实现分类选择（导航到分类列表）
    - 实现保存和取消操作
    - 处理免费用户限制（显示 Paywall）
    - _Requirements: 1.1, 1.2, 1.3, 3.3, 14.1_

  - [x] 16.3 实现 SubscriptionDetailView
    - 创建详情页布局
    - 集成 SubscriptionDetailViewModel
    - 显示所有订阅字段
    - 显示下次续费日期和倒计时
    - 显示历史支出总额
    - 实现编辑、归档、删除按钮
    - 实现删除确认对话框
    - _Requirements: 11.1, 11.2, 11.3, 11.4, 11.5, 15.4_

- [ ] 17. View 层实现 - 分类管理
  - [x] 17.1 实现 CategoryManagementView
    - 创建分类列表布局
    - 集成 CategoryViewModel
    - 显示分类卡片（名称、颜色、描述、订阅数量）
    - 实现添加分类按钮
    - 实现左滑删除操作
    - 实现删除确认对话框
    - 处理免费用户限制（显示 Paywall）
    - _Requirements: 2.1, 2.2, 2.3, 3.4, 15.4_

  - [x] 17.2 实现 AddEditCategoryView
    - 创建分类表单布局（名称、描述、颜色）
    - 集成 CategoryViewModel
    - 实现颜色选择器
    - 实现表单验证
    - 实现保存和取消操作
    - _Requirements: 2.1, 2.2, 2.5_

- [ ] 18. View 层实现 - 设置和 Paywall
  - [x] 18.1 实现 SettingsView
    - 创建设置页面布局（外观、默认设置、数据、Pro 版本、关于）
    - 集成 SettingsViewModel
    - 实现深色模式切换（跟随系统/浅色/深色）
    - 实现主题颜色选择
    - 实现默认货币选择
    - 实现默认通知时间选择
    - 实现 iCloud 同步开关
    - 实现分类管理入口
    - 实现升级到 Pro 和恢复购买按钮
    - _Requirements: 7.1, 7.2, 7.3, 7.4, 7.5, 14.3_

  - [x] 18.2 实现 PaywallView
    - 创建付费墙布局
    - 显示 Pro 版本功能列表
    - 集成 PaywallService
    - 实现购买按钮（调用 StoreKit）
    - 实现恢复购买按钮
    - 实现关闭按钮
    - 处理购买成功/失败/取消状态
    - _Requirements: 10.1, 10.2, 10.3, 10.4, 10.5, 10.6, 15.3_

- [x] 19. Checkpoint - 验证 View 层
  - 确保所有页面正确渲染并与 ViewModel 交互，如有问题请询问用户

- [ ] 20. 主应用结构和导航
  - [x] 20.1 实现 App 入口和 TabView
    - 创建 SubscriptionTrackerApp 主结构
    - 配置 SwiftData ModelContainer（包含 CloudKit 配置）
    - 注入环境对象（PaywallService, NotificationService）
    - 实现 ContentView 和 TabView（Dashboard, Subscriptions, Settings）
    - 配置 Tab 图标和标题
    - _Requirements: 12.4, 14.5_

  - [x] 20.2 实现导航和深度链接
    - 配置 NavigationStack
    - 实现页面间导航（列表 → 详情 → 编辑）
    - 实现 Modal 展示（AddEdit, Paywall）
    - 实现深度链接支持（URL Scheme）
    - _Requirements: 14.5_

- [ ] 21. 数据初始化和迁移
  - [x] 21.1 实现首次启动逻辑
    - 检查是否首次启动
    - 创建默认 UserSettings 记录
    - 请求通知权限
    - 显示欢迎引导（可选）
    - _Requirements: 6.5, 12.1_

  - [x] 21.2 配置 SwiftData 迁移
    - 定义 SchemaMigrationPlan（为未来版本预留）
    - 处理数据模型版本升级
    - _Requirements: 12.5_

- [ ] 22. 通知系统集成
  - [x] 22.1 实现通知调度逻辑
    - 在创建/更新订阅时自动调度通知
    - 在删除/归档订阅时取消通知
    - 实现通知内容和触发时间计算
    - 更新 lastNotifiedDate 字段
    - _Requirements: 6.1, 6.2, 6.3, 6.4, 6.6, 6.7_

  - [x] 22.2 实现通知权限引导
    - 检测通知权限状态
    - 显示权限请求对话框
    - 提供跳转到系统设置的引导
    - _Requirements: 6.5_

- [ ] 23. iCloud 同步集成
  - [x] 23.1 配置 CloudKit 容器
    - 在 Xcode 中启用 iCloud 能力
    - 配置 CloudKit 容器标识符
    - 配置 SwiftData 的 CloudKit 同步
    - _Requirements: 8.1_

  - [x] 23.2 实现同步状态监控
    - 监听网络状态变化
    - 显示同步状态指示器
    - 处理同步错误和冲突
    - _Requirements: 8.2, 8.3, 8.5, 15.2_

- [ ] 24. StoreKit 内购集成
  - [x] 24.1 配置 App Store Connect
    - 创建内购产品（Pro 版本）
    - 配置产品 ID 和价格
    - 创建 StoreKit Configuration 文件（用于测试）
    - _Requirements: 10.4_

  - [x] 24.2 实现购买流程
    - 加载产品信息
    - 处理购买事务
    - 验证购买收据
    - 更新用户 Pro 状态
    - 处理购买错误和取消
    - _Requirements: 10.4, 10.5, 15.3_

  - [x] 24.3 实现恢复购买
    - 实现恢复购买逻辑
    - 验证历史购买记录
    - 更新用户状态
    - _Requirements: 10.4_

- [x] 25. Checkpoint - 验证核心功能集成
  - 测试完整的用户流程（创建订阅 → 查看统计 → 接收通知 → 购买 Pro），如有问题请询问用户

- [ ] 26. 错误处理和用户反馈完善
  - [x] 26.1 实现全局错误处理
    - 在所有 Service 和 ViewModel 中添加 try-catch
    - 将错误转换为 AppError
    - 显示 Toast 提示
    - 记录错误日志
    - _Requirements: 15.1, 15.2, 15.3, 15.5_

  - [x] 26.2 实现加载状态管理
    - 在异步操作中显示 LoadingOverlay
    - 实现下拉刷新
    - 处理空状态（无订阅、无分类）
    - _Requirements: 14.6_

- [ ] 27. UI 优化和深色模式适配
  - [x] 27.1 实现深色模式支持
    - 确保所有颜色支持深色模式
    - 测试深色模式下的 UI 显示
    - 实现主题颜色应用
    - _Requirements: 7.1, 14.3_

  - [x] 27.2 实现 UI 动画和过渡
    - 添加页面切换动画
    - 添加列表项动画
    - 添加 Toast 出现/消失动画
    - 优化左滑操作动画
    - _Requirements: 14.4_

- [ ] 28. 数据验证和边界情况处理
  - [x] 28.1 实现输入验证
    - 验证订阅名称长度和格式
    - 验证金额范围（> 0）
    - 验证计费周期（> 0）
    - 验证日期有效性
    - 验证分类颜色格式
    - _Requirements: 1.2, 1.4, 2.1, 2.5_

  - [x] 28.2 处理边界情况
    - 处理空列表状态
    - 处理网络不可用
    - 处理 iCloud 账户未登录
    - 处理数据保存失败
    - _Requirements: 12.3, 15.1, 15.2_

- [ ] 29. 性能优化
  - [x] 29.1 优化数据查询
    - 使用 SwiftData 的 @Query 宏优化查询
    - 实现分页加载（如果订阅数量很大）
    - 优化搜索和筛选性能
    - _Requirements: 5.1, 5.2, 5.3_

  - [x] 29.2 优化 UI 渲染
    - 使用 LazyVStack 优化列表渲染
    - 避免不必要的 View 重绘
    - 优化图表渲染性能
    - _Requirements: 14.1_

- [ ] 30. 最终集成和测试
  - [x] 30.1 端到端测试
    - 测试完整的订阅管理流程
    - 测试免费/Pro 限制
    - 测试通知调度和接收
    - 测试 iCloud 同步（多设备）
    - 测试内购流程
    - _Requirements: 所有需求_

  - [x] 30.2 边界情况测试
    - 测试月末和闰年日期计算
    - 测试多货币统计
    - 测试数据冲突解决
    - 测试网络异常处理
    - _Requirements: 9.2, 9.3, 9.4, 13.4, 13.5, 8.3_

- [x] 31. Final Checkpoint - 完整功能验证
  - 确保所有功能正常工作，所有需求得到满足，如有问题请询问用户

## Notes

- 任务按照从底层到上层的顺序组织：数据模型 → Service → ViewModel → View
- 每个 Checkpoint 任务用于验证阶段性成果，确保增量开发的稳定性
- 所有任务都引用了对应的需求编号，确保需求覆盖的可追溯性
- 用户明确要求不包含单元测试，因此所有测试相关的子任务都已移除
- 实现过程中应该参考设计文档中的 30 个正确性属性，确保实现符合设计规范
- 关键算法（BillingCalculator）需要特别注意边界情况的处理
- 免费/Pro 限制检查应该在多个层面实施（Service 层和 ViewModel 层）
- 所有异步操作都应该有适当的错误处理和用户反馈
