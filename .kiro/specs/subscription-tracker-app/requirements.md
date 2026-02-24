# Requirements Document

## Introduction

Subscription Tracker 是一个 iOS 应用，帮助用户管理和追踪各类订阅服务（如流媒体、软件、会员等）。应用提供订阅管理、支出统计、到期提醒、数据同步等功能，并通过免费/Pro 版本区分功能限制。

## Glossary

- **App**: Subscription Tracker iOS 应用
- **User**: 使用应用的 iOS 设备用户
- **Subscription**: 用户创建的订阅记录，包含名称、金额、周期等信息
- **Category**: 订阅分类，用于组织和归类订阅
- **Dashboard**: 应用主页面，显示总支出、趋势图和即将到期订阅
- **Billing_Cycle**: 订阅的计费周期（如每月、每年）
- **Notification_System**: 本地通知系统，用于提醒订阅续费
- **SwiftData_Store**: 基于 SwiftData 的本地数据存储
- **iCloud_Sync**: 可选的 iCloud 数据同步功能
- **Free_User**: 未购买 Pro 版本的用户，受功能限制
- **Pro_User**: 已购买 Pro 版本的用户，无功能限制
- **Paywall**: 付费墙界面，当用户超出免费额度时显示
- **Archived_Subscription**: 已归档的订阅，不计入活跃订阅统计

## Requirements

### Requirement 1: 订阅数据管理

**User Story:** 作为用户，我希望能够创建、编辑、删除和归档订阅记录，以便管理我的所有订阅服务。

#### Acceptance Criteria

1. WHEN User 点击添加订阅按钮, THE App SHALL 显示订阅添加表单
2. WHEN User 提交有效的订阅信息, THE SwiftData_Store SHALL 保存订阅记录
3. WHEN User 选择编辑订阅, THE App SHALL 显示预填充当前数据的编辑表单
4. WHEN User 保存编辑后的订阅, THE SwiftData_Store SHALL 更新订阅记录
5. WHEN User 删除订阅, THE SwiftData_Store SHALL 永久删除该订阅记录
6. WHEN User 归档订阅, THE SwiftData_Store SHALL 标记订阅为已归档状态
7. WHEN User 取消归档订阅, THE SwiftData_Store SHALL 恢复订阅为活跃状态
8. THE Subscription SHALL 包含以下字段：id, name, description, category, firstPaymentDate, billingCycle, billingCycleUnit, amount, currency, notify, notifyDaysBefore, lastNotifiedDate, archived

### Requirement 2: 分类管理

**User Story:** 作为用户，我希望能够创建和管理订阅分类，以便更好地组织我的订阅。

#### Acceptance Criteria

1. WHEN User 创建新分类, THE SwiftData_Store SHALL 保存分类记录
2. WHEN User 编辑分类, THE SwiftData_Store SHALL 更新分类信息
3. WHEN User 删除分类, THE App SHALL 将该分类下的所有订阅移至未分类状态
4. THE Category SHALL 包含以下字段：id, name, description, colorHex, createdAt
5. WHEN User 为分类选择颜色, THE App SHALL 保存颜色的十六进制值

### Requirement 3: 免费用户功能限制

**User Story:** 作为产品管理者，我希望限制免费用户的功能，以便推动用户升级到 Pro 版本。

#### Acceptance Criteria

1. WHILE User 是 Free_User, THE App SHALL 限制最多创建 3 个活跃 Subscription
2. WHILE User 是 Free_User, THE App SHALL 限制最多创建 3 个 Category
3. WHEN Free_User 尝试创建第 4 个 Subscription, THE App SHALL 显示 Paywall
4. WHEN Free_User 尝试创建第 4 个 Category, THE App SHALL 显示 Paywall
5. WHEN User 删除或归档 Subscription, THE App SHALL 释放该名额
6. WHEN User 删除 Category, THE App SHALL 释放该名额
7. WHILE User 是 Pro_User, THE App SHALL 允许创建无限数量的 Subscription 和 Category

### Requirement 4: Dashboard 数据展示

**User Story:** 作为用户，我希望在主页面看到订阅支出统计和趋势，以便了解我的订阅开销情况。

#### Acceptance Criteria

1. THE Dashboard SHALL 显示当前月度总支出金额
2. THE Dashboard SHALL 显示过去 6 个月的月度支出趋势折线图
3. THE Dashboard SHALL 显示未来 30 天内即将到期的订阅列表
4. WHEN User 的订阅数据发生变化, THE Dashboard SHALL 实时更新显示内容
5. WHEN 计算月度支出时, THE App SHALL 根据 Billing_Cycle 将所有订阅金额换算为月度等效金额
6. WHEN 显示金额时, THE App SHALL 使用用户设置的默认货币格式化显示

### Requirement 5: 订阅列表和搜索

**User Story:** 作为用户，我希望能够查看所有订阅并进行搜索，以便快速找到特定订阅。

#### Acceptance Criteria

1. THE App SHALL 显示所有活跃 Subscription 的列表
2. WHEN User 输入搜索关键词, THE App SHALL 过滤显示匹配名称或描述的订阅
3. WHEN User 选择分类筛选, THE App SHALL 仅显示该分类下的订阅
4. WHEN User 在列表项上左滑, THE App SHALL 显示编辑、删除、归档操作按钮
5. THE App SHALL 按下次续费日期排序显示订阅列表

### Requirement 6: 本地通知提醒

**User Story:** 作为用户，我希望在订阅即将到期时收到通知，以便及时处理续费或取消。

#### Acceptance Criteria

1. WHEN User 启用订阅的通知功能, THE Notification_System SHALL 安排本地通知
2. WHEN 订阅续费日期前 n 天到达, THE Notification_System SHALL 发送通知提醒
3. WHEN User 修改订阅的续费日期, THE Notification_System SHALL 更新通知时间
4. WHEN User 删除或归档订阅, THE Notification_System SHALL 取消该订阅的所有通知
5. IF 用户未授予通知权限, THEN THE App SHALL 显示提示引导用户开启权限
6. WHEN 发送通知后, THE SwiftData_Store SHALL 更新 lastNotifiedDate 字段
7. THE Notification_System SHALL 在用户设置的默认时间发送通知

### Requirement 7: 用户设置管理

**User Story:** 作为用户，我希望能够自定义应用设置，以便根据个人偏好使用应用。

#### Acceptance Criteria

1. THE App SHALL 支持深色模式和浅色模式切换
2. THE App SHALL 允许用户选择主题颜色
3. THE App SHALL 允许用户设置默认货币
4. THE App SHALL 允许用户设置默认通知时间
5. THE App SHALL 允许用户开启或关闭 iCloud_Sync
6. WHEN User 修改设置, THE SwiftData_Store SHALL 保存用户设置
7. THE UserSettings SHALL 包含以下字段：darkMode, themeColor, defaultCurrency, defaultNotifyTime, iCloudSync

### Requirement 8: iCloud 数据同步

**User Story:** 作为用户，我希望能够在多个设备间同步订阅数据，以便在不同设备上访问相同的信息。

#### Acceptance Criteria

1. WHERE iCloud_Sync 已启用, THE App SHALL 将数据同步到 iCloud
2. WHERE iCloud_Sync 已启用, WHEN 其他设备修改数据, THE App SHALL 自动拉取更新
3. IF 发生数据冲突, THEN THE App SHALL 保留最新修改时间的记录
4. WHEN User 关闭 iCloud_Sync, THE App SHALL 仅使用本地数据
5. WHERE iCloud_Sync 已启用, THE App SHALL 在网络可用时自动同步数据

### Requirement 9: 计费周期计算

**User Story:** 作为用户，我希望应用能够准确计算订阅的续费日期，包括处理月末和闰年等特殊情况。

#### Acceptance Criteria

1. WHEN 计算下次续费日期, THE App SHALL 根据 firstPaymentDate 和 Billing_Cycle 计算
2. WHEN 首次付款日期是月末（如 1 月 31 日）且下个月天数较少, THE App SHALL 使用该月的最后一天作为续费日期
3. WHEN 计算涉及 2 月 29 日的闰年日期, THE App SHALL 在非闰年使用 2 月 28 日
4. WHEN Billing_Cycle 是年度且首次付款日期是 2 月 29 日, THE App SHALL 在非闰年使用 2 月 28 日
5. THE App SHALL 支持以下 billingCycleUnit：日、周、月、年

### Requirement 10: Paywall 界面

**User Story:** 作为产品管理者，我希望在用户超出免费额度时展示付费墙，以便引导用户购买 Pro 版本。

#### Acceptance Criteria

1. WHEN Free_User 超出订阅或分类限制, THE App SHALL 显示 Paywall 界面
2. THE Paywall SHALL 展示 Pro 版本的功能特性
3. THE Paywall SHALL 提供购买 Pro 版本的按钮
4. WHEN User 点击购买按钮, THE App SHALL 启动 StoreKit 购买流程
5. WHEN 购买成功, THE App SHALL 更新用户为 Pro_User 状态
6. THE Paywall SHALL 提供关闭按钮返回上一页面

### Requirement 11: 订阅详情展示

**User Story:** 作为用户，我希望能够查看订阅的详细信息，以便了解订阅的完整情况。

#### Acceptance Criteria

1. WHEN User 点击订阅列表项, THE App SHALL 显示订阅详情页面
2. THE App SHALL 显示订阅的所有字段信息
3. THE App SHALL 显示下次续费日期
4. THE App SHALL 显示该订阅的历史支出总额
5. THE App SHALL 提供编辑和删除订阅的操作按钮

### Requirement 12: 数据持久化

**User Story:** 作为用户，我希望我的订阅数据能够持久保存，以便下次打开应用时数据仍然存在。

#### Acceptance Criteria

1. WHEN App 启动, THE SwiftData_Store SHALL 加载所有保存的数据
2. WHEN User 修改数据, THE SwiftData_Store SHALL 立即持久化更改
3. IF 数据保存失败, THEN THE App SHALL 显示错误提示
4. THE SwiftData_Store SHALL 使用 SwiftData 框架进行数据持久化
5. THE SwiftData_Store SHALL 支持数据模型的版本迁移

### Requirement 13: 货币和金额处理

**User Story:** 作为用户，我希望能够使用不同货币记录订阅，以便准确反映实际支付金额。

#### Acceptance Criteria

1. THE App SHALL 支持多种货币（USD, CNY, EUR, GBP, JPY 等）
2. WHEN User 创建订阅, THE App SHALL 允许选择货币类型
3. WHEN 显示金额, THE App SHALL 使用正确的货币符号和格式
4. WHEN 计算总支出, THE App SHALL 分别统计不同货币的金额
5. THE Dashboard SHALL 按货币分组显示总支出

### Requirement 14: UI 交互和导航

**User Story:** 作为用户，我希望应用界面简洁易用，以便快速完成操作。

#### Acceptance Criteria

1. THE App SHALL 使用 SwiftUI 构建用户界面
2. THE App SHALL 使用圆角卡片风格展示订阅和分类
3. THE App SHALL 支持深色模式和浅色模式的自动适配
4. WHEN User 执行操作, THE App SHALL 提供视觉反馈（如加载指示器）
5. THE App SHALL 使用清晰的导航结构（TabView 或 NavigationStack）
6. WHEN 数据加载或保存时, THE App SHALL 显示适当的加载状态

### Requirement 15: 错误处理和用户反馈

**User Story:** 作为用户，我希望在操作失败时能够收到清晰的错误提示，以便了解问题并采取行动。

#### Acceptance Criteria

1. IF 数据保存失败, THEN THE App SHALL 显示错误提示信息
2. IF 网络同步失败, THEN THE App SHALL 显示同步错误提示
3. IF 购买流程失败, THEN THE App SHALL 显示购买失败原因
4. WHEN User 执行删除操作, THE App SHALL 显示确认对话框
5. WHEN 操作成功完成, THE App SHALL 提供成功反馈（如 Toast 提示）
