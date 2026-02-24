import SwiftUI

/// 分类标签组件
/// 显示分类名称和颜色
struct CategoryBadge: View {
    let category: Category
    var isCompact: Bool = true
    
    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(category.color)
                .frame(width: 8, height: 8)
            
            if !isCompact {
                Text(category.name)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, isCompact ? 6 : 8)
        .padding(.vertical, isCompact ? 4 : 6)
        .background(category.color.opacity(0.1))
        .cornerRadius(8)
    }
}

#Preview {
    VStack(spacing: 16) {
        // Compact mode
        CategoryBadge(
            category: Category(name: "娱乐", colorHex: "#FF5733"),
            isCompact: true
        )
        
        // Full mode
        CategoryBadge(
            category: Category(name: "娱乐", colorHex: "#FF5733"),
            isCompact: false
        )
        
        // Different colors
        HStack {
            CategoryBadge(
                category: Category(name: "工具", colorHex: "#007AFF"),
                isCompact: false
            )
            
            CategoryBadge(
                category: Category(name: "学习", colorHex: "#34C759"),
                isCompact: false
            )
            
            CategoryBadge(
                category: Category(name: "健康", colorHex: "#FF9500"),
                isCompact: false
            )
        }
    }
    .padding()
}
