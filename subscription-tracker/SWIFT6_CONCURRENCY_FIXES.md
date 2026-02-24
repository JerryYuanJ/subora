# Swift 6 并发警告修复（最终版本）

## 问题描述

项目中出现了多个 Swift 6 并发相关的警告和错误：

1. `Main actor-isolated static property 'shared' can not be referenced from a nonisolated context`
2. `Call to main actor-isolated initializer 'init()' in a synchronous nonisolated(unsafe) context`
3. `Result of call to 'purchaseProVersion()' is unused`

## 根本原因

1. 使用 `nonisolated(unsafe)` 标记单例时，不能调用 `@MainActor` 隔离的初始化器
2. 在默认参数中使用 `.shared` 会导致并发问题
3. 某些异步函数的返回值未被使用

## 最终解决方案

### 方案说明

**不使用 `@MainActor` 标记服务类**，而是在需要主线程执行的方法上单独标记 `@MainActor`。这样可以：

- 避免初始化器的并发问题
- 允许单例在任何上下文中访问
- 保持需要主线程执行的方法的线程安全

### 1. PaywallService.swift

**修复后：**

```swift
class PaywallService: ObservableObject {
    static let shared = PaywallService()

    @Published var isProUser: Bool = false

    private init() {
        self.isProUser = UserDefaults.standard.bool(forKey: "isProUser")
    }

    @MainActor
    func purchaseProVersion() async throws -> Bool {
        isProUser = true
        UserDefaults.standard.set(true, forKey: "isProUser")
        return true
    }

    @MainActor
    func restorePurchases() async throws -> Bool {
        return false
    }
}
```

**关键点：**

- 移除类级别的 `@MainActor`
- 在需要主线程的方法上单独标记 `@MainActor`
- 单例可以在任何上下文中访问

### 2. NotificationService.swift

**修复后：**

```swift
class NotificationService {
    static let shared = NotificationService()

    private init() {}

    // 所有方法都是异步的，不需要 @MainActor
}
```

**关键点：**

- 移除类级别的 `@MainActor`
- NotificationService 的方法都是异步的，不需要主线程隔离

### 3. AppSettings

**修复后：**

```swift
class AppSettings: ObservableObject {
    @Published var colorScheme: ColorScheme? = nil

    init() {
        loadColorScheme()
    }
}
```

**关键点：**

- 移除 `@MainActor`，因为 `ObservableObject` 的 `@Published` 属性会自动在主线程更新

### 4. CategoryService.swift

**修复前：**

```swift
init(modelContext: ModelContext, paywallService: PaywallService = .shared) {
    self.modelContext = modelContext
    self.paywallService = paywallService
}
```

**修复后：**

```swift
init(modelContext: ModelContext, paywallService: PaywallService? = nil) {
    self.modelContext = modelContext
    self.paywallService = paywallService ?? PaywallService.shared
}
```

**关键点：**

- 使用可选参数 + nil 合并运算符
- 避免在默认参数中直接访问 `.shared`

### 5. SubscriptionService.swift

**修复后：**

```swift
init(
    modelContext: ModelContext,
    paywallService: PaywallService? = nil,
    notificationService: NotificationService? = nil
) {
    self.modelContext = modelContext
    self.paywallService = paywallService ?? PaywallService.shared
    self.notificationService = notificationService ?? NotificationService.shared
}
```

### 6. AddEditSubscriptionViewModel.swift

**修复后：**

```swift
init(
    subscription: Subscription? = nil,
    subscriptionService: SubscriptionService,
    paywallService: PaywallService? = nil
) {
    self.isEditMode = subscription != nil
    self.subscriptionService = subscriptionService
    self.paywallService = paywallService ?? PaywallService.shared
    // ...
}
```

### 7. SyncService.swift

**修复前：**

```swift
networkMonitor.pathUpdateHandler = { [weak self] path in
    Task { @MainActor in
        self?.isNetworkAvailable = path.status == .satisfied
    }
}
```

**修复后：**

```swift
networkMonitor.pathUpdateHandler = { [weak self] path in
    guard let self = self else { return }
    Task { @MainActor in
        self.isNetworkAvailable = path.status == .satisfied
    }
}
```

**关键点：**

- 使用 `guard let self` 避免可选链在 Task 中的问题

### 8. PaywallView.swift

**修复后：**

```swift
private func purchasePro() async {
    do {
        _ = try await paywallService.purchaseProVersion()
        toast = .success("购买成功！")
    } catch {
        toast = .error("购买失败：\(error.localizedDescription)")
    }
}

private func restorePurchases() async {
    do {
        _ = try await paywallService.restorePurchases()
        toast = .success("恢复成功！")
    } catch {
        toast = .error("恢复失败：\(error.localizedDescription)")
    }
}
```

**关键点：**

- 使用 `_` 显式忽略返回值

### 9. SettingsView.swift

**修复后：**

```swift
Button {
    if let url = URL(string: UIApplication.openSettingsURLString) {
        Task { @MainActor in
            UIApplication.shared.open(url)
        }
    }
}
```

**关键点：**

- 在 Task 内部调用 UIApplication API
- 不需要 await，因为 open 方法不是异步的

## 关键概念

### 何时使用 @MainActor

**类级别：**

- ✅ ViewModel 类（需要更新 UI）
- ❌ Service 类（除非所有方法都需要主线程）

**方法级别：**

- ✅ 需要更新 @Published 属性的方法
- ✅ 需要调用 UIKit/AppKit API 的方法
- ❌ 纯数据处理方法

### 单例模式最佳实践

```swift
// ✅ 推荐：不标记类，按需标记方法
class MyService: ObservableObject {
    static let shared = MyService()

    @MainActor
    func updateUI() {
        // 需要主线程的操作
    }

    func processData() {
        // 不需要主线程的操作
    }
}

// ❌ 避免：标记整个类
@MainActor
class MyService: ObservableObject {
    nonisolated(unsafe) static let shared = MyService()  // 会导致问题
}
```

### 默认参数最佳实践

```swift
// ✅ 推荐：使用可选参数 + nil 合并
init(service: MyService? = nil) {
    self.service = service ?? MyService.shared
}

// ❌ 避免：直接使用 .shared
init(service: MyService = .shared) {
    self.service = service
}
```

## 已修复的文件

✅ `Services/PaywallService.swift`
✅ `Services/NotificationService.swift`
✅ `Services/CategoryService.swift`
✅ `Services/SubscriptionService.swift`
✅ `Services/SyncService.swift`
✅ `ViewModels/AddEditSubscriptionViewModel.swift`
✅ `Views/PaywallView.swift`
✅ `Views/SettingsView.swift`
✅ `subscription_trackerApp.swift`

## 验证

所有文件已通过诊断检查，无编译错误和警告：

- ✅ 所有 Services
- ✅ 所有 ViewModels
- ✅ 所有 Views
- ✅ App 文件

## 最佳实践总结

1. **不要在类级别过度使用 @MainActor**
   - 只在真正需要的方法上标记
   - 保持灵活性

2. **单例使用简单的 static let**
   - 不需要 nonisolated(unsafe)
   - 避免并发问题

3. **默认参数使用可选类型**
   - 使用 `Type? = nil` 而不是 `Type = .shared`
   - 在初始化器内部使用 nil 合并运算符

4. **显式处理返回值**
   - 使用 `_` 忽略不需要的返回值
   - 避免编译器警告

5. **Task 中使用 @MainActor**
   - 需要主线程的操作包装在 `Task { @MainActor in }`
   - 保持代码清晰

## 结论

通过采用更灵活的并发策略，项目现在完全兼容 Swift 6，没有任何编译错误或警告。这种方法比过度使用 `@MainActor` 更加实用和可维护。
