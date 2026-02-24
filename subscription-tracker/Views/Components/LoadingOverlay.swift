import SwiftUI

/// 加载遮罩组件
/// 显示加载指示器和提示文本
struct LoadingOverlay: View {
    let message: String
    
    init(message: String = "加载中...") {
        self.message = message
    }
    
    var body: some View {
        ZStack {
            // 半透明背景
            Color.black.opacity(0.3)
                .ignoresSafeArea()
            
            // 加载内容
            VStack(spacing: 16) {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .primary))
                    .scaleEffect(1.2)
                
                Text(message)
                    .font(.subheadline)
                    .foregroundColor(.primary)
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
                    .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
            )
        }
    }
}

// MARK: - View Extension

extension View {
    /// 显示加载遮罩的便捷方法
    /// - Parameters:
    ///   - isLoading: 是否显示加载状态
    ///   - message: 加载提示文本
    func loadingOverlay(isLoading: Bool, message: String = "加载中...") -> some View {
        ZStack {
            self
            
            if isLoading {
                LoadingOverlay(message: message)
            }
        }
    }
}

#Preview {
    VStack {
        Text("主要内容")
            .font(.title)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color(.systemGroupedBackground))
    .loadingOverlay(isLoading: true, message: "正在保存...")
}
