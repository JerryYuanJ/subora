# Insights 页面快速参考

## 🎨 配色方案

### 统计卡片渐变色

```swift
// 活跃订阅 - 紫蓝渐变
[Color(hex: "#667eea"), Color(hex: "#764ba2")]

// 即将续费 - 粉红渐变
[Color(hex: "#f093fb"), Color(hex: "#f5576c")]

// 本月新增 - 蓝青渐变
[Color(hex: "#4facfe"), Color(hex: "#00f2fe")]

// 平均费用 - 绿青渐变
[Color(hex: "#43e97b"), Color(hex: "#38f9d7")]
```

### 紧急程度渐变色

```swift
// 3天内 - 粉红渐变
[Color(hex: "#f093fb"), Color(hex: "#f5576c")]

// 7天内 - 橙黄渐变
[Color(hex: "#ffecd2"), Color(hex: "#fcb69f")]

// 其他 - 蓝青渐变
[Color(hex: "#4facfe"), Color(hex: "#00f2fe")]
```

## 📐 设计规范

### 卡片样式

```swift
.padding(20)
.background(
    RoundedRectangle(cornerRadius: 16)
        .fill(Color(.systemBackground))
        .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 4)
)
```

### 统计卡片

- 高度：130pt
- 圆角：16pt
- 内边距：16pt
- 图标圆形背景：44x44pt

### 间距

- 卡片间距：20pt
- 统计卡片间距：12pt
- 内部元素间距：12-16pt

## 🔧 关键组件

### StatCard

```swift
StatCard(
    title: "标题",
    value: "数值",
    icon: "图标名称",
    gradientColors: [Color(hex: "#起始色"), Color(hex: "#结束色")]
)
```

### UpcomingRenewalRow

- 自动根据天数显示不同渐变色
- 显示分类颜色指示器
- 显示金额和日期

## ✨ 视觉特点

1. **渐变色图标背景** - 所有图标都有渐变色圆形背景
2. **渐变色文字** - 重要数值使用渐变色
3. **柔和阴影** - 统一的阴影效果
4. **圆润设计** - 16pt 圆角
5. **清晰层次** - 优化的间距和字体大小

## 🎯 改进要点

- ✅ 图表标题不再被遮挡
- ✅ 高级渐变色配色
- ✅ 统一的添加按钮
- ✅ 导航标题显示
- ✅ 优化的卡片设计

## 📱 页面结构

```
NavigationStack
└── ScrollView
    └── VStack (spacing: 20)
        ├── statisticsGrid (2x2 网格)
        ├── totalSpendingCard
        ├── trendChartCard
        └── upcomingRenewalsCard
```

## 🎨 使用渐变色的技巧

### 图标背景

```swift
ZStack {
    Circle()
        .fill(
            LinearGradient(
                colors: gradientColors.map { $0.opacity(0.15) },
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .frame(width: 44, height: 44)

    Image(systemName: icon)
        .foregroundStyle(
            LinearGradient(
                colors: gradientColors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
}
```

### 文字渐变

```swift
Text(value)
    .foregroundStyle(
        LinearGradient(
            colors: [Color(hex: "#667eea"), Color(hex: "#764ba2")],
            startPoint: .leading,
            endPoint: .trailing
        )
    )
```

## 🔍 调试提示

如果颜色显示不正确：

1. 检查 Color+Hex 扩展是否正确导入
2. 确认十六进制颜色值格式正确
3. 验证渐变方向设置

## 📚 相关文件

- `Views/InsightsView.swift` - 主视图
- `Extensions/Color+Hex.swift` - 颜色扩展
- `ViewModels/DashboardViewModel.swift` - 数据逻辑
