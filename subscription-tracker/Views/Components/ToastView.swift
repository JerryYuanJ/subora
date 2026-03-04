import SwiftUI

/// Toast 提示组件
/// 支持 success/error/info 类型
struct ToastView: View {
    let message: String
    let type: ToastType
    
    enum ToastType: Equatable {
        case success
        case error
        case info
        
        var icon: String {
            switch self {
            case .success: return "checkmark.circle.fill"
            case .error: return "xmark.circle.fill"
            case .info: return "info.circle.fill"
            }
        }
        
        var color: Color {
            switch self {
            case .success: return .green
            case .error: return .red
            case .info: return .blue
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: type.icon)
                .font(.system(size: 44))
                .foregroundColor(type.color)
            
            Text(message)
                .font(.subheadline)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.black.opacity(0.75))
        )
        .frame(minWidth: 150, maxWidth: 250)
    }
}

// MARK: - Toast Modifier

struct ToastModifier: ViewModifier {
    @Binding var toast: Toast?
    
    func body(content: Content) -> some View {
        content
            .overlay(alignment: .center) {
                if let toast = toast {
                    ToastView(message: toast.message, type: toast.type)
                        .transition(.scale.combined(with: .opacity))
                        .zIndex(999)
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + toast.duration) {
                                withAnimation {
                                    self.toast = nil
                                }
                            }
                        }
                }
            }
            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: toast)
    }
}

// MARK: - Toast Model

struct Toast: Equatable {
    let message: String
    let type: ToastView.ToastType
    let duration: TimeInterval

    static func == (lhs: Toast, rhs: Toast) -> Bool {
        lhs.message == rhs.message && lhs.type == rhs.type
    }

    init(message: String, type: ToastView.ToastType, duration: TimeInterval = 3.0) {
        self.message = message
        self.type = type
        self.duration = duration
    }
    
    static func success(_ message: String, duration: TimeInterval = 3.0) -> Toast {
        Toast(message: message, type: .success, duration: duration)
    }
    
    static func error(_ message: String, duration: TimeInterval = 3.0) -> Toast {
        Toast(message: message, type: .error, duration: duration)
    }
    
    static func info(_ message: String, duration: TimeInterval = 3.0) -> Toast {
        Toast(message: message, type: .info, duration: duration)
    }
}

// MARK: - View Extension

extension View {
    /// 显示 Toast 提示的便捷方法
    /// - Parameter toast: Toast 绑定
    func toast(_ toast: Binding<Toast?>) -> some View {
        modifier(ToastModifier(toast: toast))
    }
}

#Preview {
    struct ToastPreview: View {
        @State private var toast: Toast?
        
        var body: some View {
            VStack(spacing: 20) {
                Button("Show Success") {
                    toast = .success("Operation completed successfully")
                }
                
                Button("Show Error") {
                    toast = .error("Operation failed, please try again")
                }
                
                Button("Show Info") {
                    toast = .info("This is an info message")
                }
            }
            .toast($toast)
        }
    }
    
    return ToastPreview()
}
