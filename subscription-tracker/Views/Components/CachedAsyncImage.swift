//
//  CachedAsyncImage.swift
//  subscription-tracker
//
//  带缓存的异步图片加载组件
//

import SwiftUI

/// 带缓存的异步图片视图
struct CachedAsyncImage<Content: View, Placeholder: View>: View {
    let url: URL?
    let content: (Image) -> Content
    let placeholder: () -> Placeholder
    
    @State private var image: UIImage?
    @State private var isLoading = false
    
    init(
        url: URL?,
        @ViewBuilder content: @escaping (Image) -> Content,
        @ViewBuilder placeholder: @escaping () -> Placeholder
    ) {
        self.url = url
        self.content = content
        self.placeholder = placeholder
    }
    
    var body: some View {
        Group {
            if let image = image {
                content(Image(uiImage: image))
            } else {
                placeholder()
                    .task {
                        await loadImage()
                    }
            }
        }
    }
    
    private func loadImage() async {
        guard let url = url, !isLoading else { return }
        
        let urlString = url.absoluteString
        
        // 先检查缓存
        if let cachedImage = ImageCache.shared.getImage(for: urlString) {
            self.image = cachedImage
            return
        }
        
        // 从网络加载
        isLoading = true
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let downloadedImage = UIImage(data: data) {
                ImageCache.shared.setImage(downloadedImage, for: urlString)
                self.image = downloadedImage
            }
        } catch {
            // 加载失败，保持 placeholder
        }
        isLoading = false
    }
}

// MARK: - Convenience Initializer

extension CachedAsyncImage where Content == Image, Placeholder == ProgressView<EmptyView, EmptyView> {
    init(url: URL?) {
        self.init(
            url: url,
            content: { $0.resizable() },
            placeholder: { ProgressView() }
        )
    }
}
