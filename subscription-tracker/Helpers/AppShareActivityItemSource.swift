//
//  AppShareActivityItemSource.swift
//  subscription-tracker
//
//  Custom activity item source for app sharing
//

import UIKit
import LinkPresentation

/// 自定义分享内容，用于在分享时显示 App Icon 和自定义文案
class AppShareActivityItemSource: NSObject, UIActivityItemSource {
    
    let message: String
    let url: URL
    let icon: UIImage?
    
    init(message: String, url: URL, icon: UIImage?) {
        self.message = message
        self.url = url
        self.icon = icon
        super.init()
    }
    
    // MARK: - UIActivityItemSource
    
    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return message
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        // 对于不同的分享类型，返回不同的内容
        if activityType == .message || activityType == .mail {
            // 消息和邮件：返回文案 + 链接
            return "\(message)\n\n\(url.absoluteString)"
        } else if activityType == .copyToPasteboard {
            // 复制：返回文案 + 链接
            return "\(message)\n\(url.absoluteString)"
        } else {
            // 其他：只返回文案（链接会通过 metadata 提供）
            return message
        }
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, subjectForActivityType activityType: UIActivity.ActivityType?) -> String {
        return message
    }
    
    // MARK: - Link Presentation (iOS 13+)
    
    func activityViewControllerLinkMetadata(_ activityViewController: UIActivityViewController) -> LPLinkMetadata? {
        let metadata = LPLinkMetadata()
        
        // 设置标题为我们的文案
        metadata.title = message
        
        // 不设置 URL，这样就不会显示 apps.apple.com
        // URL 会在实际分享时通过 itemForActivityType 提供
        
        // 设置大尺寸图标
        if let icon = icon {
            // 创建更大的图标（建议 300x300 或更大）
            let targetSize = CGSize(width: 300, height: 300)
            let scaledIcon = resizeImage(image: icon, targetSize: targetSize)
            
            // 使用 imageProvider 而不是 iconProvider，这样图标会更大
            metadata.imageProvider = NSItemProvider(object: scaledIcon)
        }
        
        return metadata
    }
    
    // MARK: - Helper Methods
    
    /// 调整图片大小
    private func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        // 使用较小的比例以保持宽高比
        let scaleFactor = min(widthRatio, heightRatio)
        
        let scaledSize = CGSize(width: size.width * scaleFactor, height: size.height * scaleFactor)
        
        let renderer = UIGraphicsImageRenderer(size: scaledSize)
        let scaledImage = renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: scaledSize))
        }
        
        return scaledImage
    }
}
