# Swift 并发快速参考

## 常见模式

### 1. ObservableObject 单例

```swift
@MainActor
class MyService: ObservableObject {
    nonisolated(unsafe) static let shared = MyService()

    @Published var someProperty: String = ""

    private init() {}
}
```

### 2. 非 ObservableObject 单例

```swift
@MainActor
class MyService {
    nonisolated(unsafe) static let shared = MyService()

    private init() {}

    func doSomething() async {
        // 实现
    }
}
```

### 3. ViewModel

```swift
@MainActor
class MyViewModel: ObservableObject {
    @Published var data: [Item] = []

    func loadData() async {
        // 自动在主线程执行
    }
}
```

### 4. 调用主线程 API

```swift
Button("Open Settings") {
    Task { @MainActor in
        if let url = URL(string: UIApplication.openSettingsURLString) {
            await UIApplication.shared.open(url)
        }
    }
}
```

### 5. 后台任务

```swift
func processData() async {
    // 在后台线程执行
    let result = await Task.detached {
        // 耗时操作
        return processedData
    }.value

    // 回到主线程更新 UI
    await MainActor.run {
        self.data = result
    }
}
```

## 关键字说明

| 关键字                | 用途                 | 示例                                    |
| --------------------- | -------------------- | --------------------------------------- |
| `@MainActor`          | 标记必须在主线程执行 | `@MainActor class MyViewModel`          |
| `nonisolated(unsafe)` | 允许从任何线程访问   | `nonisolated(unsafe) static let shared` |
| `async`               | 标记异步函数         | `func loadData() async`                 |
| `await`               | 等待异步操作完成     | `await service.fetchData()`             |
| `Task`                | 创建异步任务         | `Task { await doWork() }`               |

## 何时使用 @MainActor

✅ **应该使用：**

- ObservableObject 类
- ViewModel 类
- 直接操作 UI 的类
- 包含 @Published 属性的类

❌ **不需要使用：**

- 纯数据模型（struct）
- 不涉及 UI 的工具类
- 后台处理服务

## 常见错误

### 错误 1: 忘记标记 @MainActor

```swift
// ❌ 错误
class MyViewModel: ObservableObject {
    @Published var data: [Item] = []
}

// ✅ 正确
@MainActor
class MyViewModel: ObservableObject {
    @Published var data: [Item] = []
}
```

### 错误 2: 单例访问警告

```swift
// ❌ 错误
@MainActor
class MyService: ObservableObject {
    static let shared = MyService()
}

// ✅ 正确
@MainActor
class MyService: ObservableObject {
    nonisolated(unsafe) static let shared = MyService()
}
```

### 错误 3: 忘记使用 await

```swift
// ❌ 错误
func loadData() {
    service.fetchData()  // 编译错误
}

// ✅ 正确
func loadData() async {
    await service.fetchData()
}
```

## 项目中的应用

### Services

- `PaywallService`: `@MainActor` + `nonisolated(unsafe) static let shared`
- `NotificationService`: `@MainActor` + `nonisolated(unsafe) static let shared`
- `CategoryService`: `@MainActor`
- `SubscriptionService`: `@MainActor`
- `SyncService`: `@MainActor`

### ViewModels

所有 ViewModel 都标记为 `@MainActor`：

- `AddEditSubscriptionViewModel`
- `CategoryViewModel`
- `DashboardViewModel`
- `SettingsViewModel`
- `SubscriptionDetailViewModel`
- `SubscriptionListViewModel`

### App

- `AppSettings`: `@MainActor`

## 调试技巧

1. **查看警告信息**

   ```
   Main actor-isolated property 'xxx' can not be referenced from a nonisolated context
   ```

   → 添加 `@MainActor` 或使用 `Task { @MainActor in }`

2. **编译器建议**
   - Xcode 会提供修复建议
   - 通常是添加 `await` 或 `@MainActor`

3. **运行时检查**
   ```swift
   dispatchPrecondition(condition: .onQueue(.main))
   ```

## 参考资源

- [Swift Concurrency](https://docs.swift.org/swift-book/LanguageGuide/Concurrency.html)
- [MainActor Documentation](https://developer.apple.com/documentation/swift/mainactor)
- [Swift Evolution: SE-0316](https://github.com/apple/swift-evolution/blob/main/proposals/0316-global-actors.md)
