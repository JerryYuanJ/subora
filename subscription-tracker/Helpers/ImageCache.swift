//
//  ImageCache.swift
//  subscription-tracker
//
//  图片缓存管理
//

import SwiftUI

/// 图片缓存管理器
class ImageCache {
    static let shared = ImageCache()
    
    private let cache = NSCache<NSString, UIImage>()
    private let fileManager = FileManager.default
    private let cacheDirectory: URL
    
    private init() {
        // 创建缓存目录
        let paths = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)
        cacheDirectory = paths[0].appendingPathComponent("ImageCache")
        
        // 确保目录存在
        try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
        
        // 配置内存缓存
        cache.countLimit = 100 // 最多缓存 100 张图片
        cache.totalCostLimit = 50 * 1024 * 1024 // 50MB
    }
    
    /// 获取缓存的图片
    func getImage(for url: String) -> UIImage? {
        let key = url as NSString
        
        // 1. 先从内存缓存获取
        if let image = cache.object(forKey: key) {
            return image
        }
        
        // 2. 从磁盘缓存获取
        if let image = loadFromDisk(url: url) {
            cache.setObject(image, forKey: key)
            return image
        }
        
        return nil
    }
    
    /// 保存图片到缓存
    func setImage(_ image: UIImage, for url: String) {
        let key = url as NSString
        
        // 保存到内存
        cache.setObject(image, forKey: key)
        
        // 保存到磁盘
        saveToDisk(image: image, url: url)
    }
    
    /// 从磁盘加载图片
    private func loadFromDisk(url: String) -> UIImage? {
        let filename = url.md5
        let fileURL = cacheDirectory.appendingPathComponent(filename)
        
        guard let data = try? Data(contentsOf: fileURL),
              let image = UIImage(data: data) else {
            return nil
        }
        
        return image
    }
    
    /// 保存图片到磁盘
    private func saveToDisk(image: UIImage, url: String) {
        let filename = url.md5
        let fileURL = cacheDirectory.appendingPathComponent(filename)
        
        guard let data = image.pngData() else { return }
        try? data.write(to: fileURL)
    }
    
    /// 清除所有缓存
    func clearCache() {
        cache.removeAllObjects()
        try? fileManager.removeItem(at: cacheDirectory)
        try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
    }
}

// MARK: - String Extension for MD5

extension String {
    var md5: String {
        guard let data = self.data(using: .utf8) else { return self }
        let hash = data.withUnsafeBytes { (bytes: UnsafeRawBufferPointer) -> [UInt8] in
            var hash = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
            CC_MD5(bytes.baseAddress, CC_LONG(data.count), &hash)
            return hash
        }
        return hash.map { String(format: "%02x", $0) }.joined()
    }
}

import CommonCrypto
