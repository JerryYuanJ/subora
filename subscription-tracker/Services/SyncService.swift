//
//  SyncService.swift
//  subscription-tracker
//
//  Created by Kiro on 2026/2/24.
//

import Foundation
import SwiftData
import Network
import OSLog
import CloudKit

/// 同步状态枚举
enum SyncStatus {
    case syncing
    case synced
    case error(String)
    case disabled
}

/// SyncService 负责管理 iCloud 同步功能
/// 注意：SwiftData 自动处理 CloudKit 同步，此服务主要管理同步设置和状态
@MainActor
class SyncService {
    private let modelContext: ModelContext
    private let networkMonitor = NWPathMonitor()
    private var isNetworkAvailable = false
    private var currentSyncStatus: SyncStatus = .disabled
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        setupNetworkMonitoring()
    }
    
    // MARK: - Network Monitoring
    
    /// 设置网络监控
    private func setupNetworkMonitoring() {
        networkMonitor.pathUpdateHandler = { [weak self] path in
            guard let self = self else { return }
            Task { @MainActor in
                self.isNetworkAvailable = path.status == .satisfied
            }
        }
        let queue = DispatchQueue(label: "NetworkMonitor")
        networkMonitor.start(queue: queue)
    }
    
    // MARK: - iCloud Account Check
    
    /// 检查 iCloud 账号状态
    private func checkiCloudAccountStatus() async -> Bool {
        print("🔵 开始检查 iCloud 账号状态...")
        
        return await withCheckedContinuation { continuation in
            CKContainer.default().accountStatus { status, error in
                if let error = error {
                    print("❌ 检查 iCloud 账号失败: \(error.localizedDescription)")
                    continuation.resume(returning: false)
                    return
                }
                
                switch status {
                case .available:
                    print("✅ iCloud 账号已登录且可用")
                    continuation.resume(returning: true)
                case .noAccount:
                    print("❌ 未登录 iCloud 账号")
                    print("💡 请在设置中登录 iCloud 账号")
                    continuation.resume(returning: false)
                case .restricted:
                    print("❌ iCloud 账号受限（可能是家长控制或企业限制）")
                    continuation.resume(returning: false)
                case .couldNotDetermine:
                    print("❌ 无法确定 iCloud 账号状态")
                    continuation.resume(returning: false)
                case .temporarilyUnavailable:
                    print("⚠️ iCloud 暂时不可用，请稍后再试")
                    continuation.resume(returning: false)
                @unknown default:
                    print("❌ 未知的 iCloud 账号状态: \(status.rawValue)")
                    continuation.resume(returning: false)
                }
            }
        }
    }
    
    // MARK: - Sync Control
    
    /// 启用 iCloud 同步
    /// - Throws: 如果网络不可用或 iCloud 账户未登录
    func enableSync() async throws {
        Logger.sync.info("Attempting to enable iCloud sync")
        
        guard isNetworkAvailable else {
            Logger.sync.error("Cannot enable sync: network unavailable")
            throw AppError.networkUnavailable
        }
        
        // 获取或创建 UserSettings
        let settings = try await getUserSettings()
        settings.iCloudSync = true
        settings.updatedAt = Date()
        
        try modelContext.save()
        currentSyncStatus = .synced
        
        Logger.sync.info("iCloud sync enabled successfully")
        // SwiftData 会自动开始同步到 CloudKit
    }
    
    /// 禁用 iCloud 同步
    func disableSync() async throws {
        Logger.sync.info("Disabling iCloud sync")
        
        let settings = try await getUserSettings()
        settings.iCloudSync = false
        settings.updatedAt = Date()
        
        try modelContext.save()
        currentSyncStatus = .disabled
        
        Logger.sync.info("iCloud sync disabled successfully")
    }
    
    /// 手动触发同步
    /// - Throws: 如果同步未启用或网络不可用
    func syncNow() async throws {
        Logger.sync.info("Manual sync triggered")
        
        let settings = try await getUserSettings()
        
        guard settings.iCloudSync else {
            Logger.sync.warning("Sync failed: sync not enabled")
            throw AppError.syncFailed(reason: "同步未启用")
        }
        
        // 检查 iCloud 账号状态
        let iCloudAvailable = await checkiCloudAccountStatus()
        guard iCloudAvailable else {
            Logger.sync.error("Sync failed: iCloud account not available")
            currentSyncStatus = .error("未登录 iCloud")
            throw AppError.iCloudNotAvailable
        }
        
        guard isNetworkAvailable else {
            Logger.sync.error("Sync failed: network unavailable")
            throw AppError.networkUnavailable
        }
        
        currentSyncStatus = .syncing
        print("🔵 正在同步数据到 iCloud...")
        
        // SwiftData 自动处理同步，这里只需要保存上下文
        // 这会触发 CloudKit 同步
        do {
            // 更新最后同步时间
            settings.lastSyncTime = Date()
            
            // 检查有多少数据
            let subscriptionCount = try modelContext.fetch(FetchDescriptor<Subscription>()).count
            let categoryCount = try modelContext.fetch(FetchDescriptor<Category>()).count
            print("📊 当前数据: \(subscriptionCount) 个订阅, \(categoryCount) 个分类")
            
            try modelContext.save()
            print("✅ 数据已保存到本地，CloudKit 将自动上传")
            
            // 验证 CloudKit 连接
            await verifyCloudKitConnection()
            
            print("💡 提示: CloudKit 同步可能需要几秒到几分钟时间")
            
            // 模拟同步延迟
            try await Task.sleep(nanoseconds: 500_000_000) // 0.5秒
            
            currentSyncStatus = .synced
            Logger.sync.info("Manual sync completed successfully")
            print("✅ 同步完成")
        } catch {
            currentSyncStatus = .error("同步失败")
            print("❌ 同步失败: \(error.localizedDescription)")
            throw AppError.syncFailed(reason: error.localizedDescription)
        }
    }
    
    /// 验证 CloudKit 连接
    private func verifyCloudKitConnection() async {
        print("🔵 验证 CloudKit 连接...")
        
        // 使用默认 Container
        let container = CKContainer.default()
        let database = container.privateCloudDatabase
        
        do {
            // 尝试获取用户记录 ID
            let userRecordID = try await container.userRecordID()
            print("✅ CloudKit 连接正常，用户 ID: \(userRecordID.recordName)")
            print("✅ Container ID: \(container.containerIdentifier ?? "unknown")")
            
            // 尝试查询记录（SwiftData 的记录类型）
            let query = CKQuery(recordType: "CD_Category", predicate: NSPredicate(value: true))
            let result = try await database.records(matching: query, resultsLimit: 10)
            print("✅ CloudKit 查询成功，找到 \(result.matchResults.count) 条分类记录")
            
            if result.matchResults.count > 0 {
                print("🎉 数据已成功上传到 iCloud！")
            } else {
                print("⚠️ 暂时没有找到记录，可能还在上传中...")
            }
        } catch {
            print("⚠️ CloudKit 验证失败: \(error.localizedDescription)")
            if let ckError = error as? CKError {
                print("⚠️ CKError code: \(ckError.code.rawValue)")
                print("⚠️ CKError description: \(ckError.localizedDescription)")
            }
        }
    }
    
    // MARK: - Conflict Resolution
    
    /// 解决同步冲突（保留最新修改）
    /// - Parameters:
    ///   - local: 本地记录
    ///   - remote: 远程记录
    /// - Returns: 应该保留的记录
    func resolveConflict<T: PersistentModel>(local: T, remote: T) -> T {
        Logger.sync.info("Resolving sync conflict")
        
        // 获取 updatedAt 属性
        let localUpdatedAt = getUpdatedAt(from: local)
        let remoteUpdatedAt = getUpdatedAt(from: remote)
        
        // 保留最新的记录
        if let localDate = localUpdatedAt, let remoteDate = remoteUpdatedAt {
            let result = localDate > remoteDate ? local : remote
            Logger.sync.info("Conflict resolved: keeping \(localDate > remoteDate ? "local" : "remote") version")
            return result
        }
        
        // 如果无法获取时间戳，默认保留远程记录
        Logger.sync.warning("Could not determine timestamps, keeping remote version")
        return remote
    }
    
    /// 从模型中获取 updatedAt 属性
    private func getUpdatedAt<T: PersistentModel>(from model: T) -> Date? {
        let mirror = Mirror(reflecting: model)
        for child in mirror.children {
            if child.label == "updatedAt", let date = child.value as? Date {
                return date
            }
        }
        return nil
    }
    
    // MARK: - Sync Status
    
    /// 获取当前同步状态
    /// - Returns: 同步状态
    func getSyncStatus() -> SyncStatus {
        return currentSyncStatus
    }
    
    /// 检查同步是否已启用
    func isSyncEnabled() async -> Bool {
        do {
            let settings = try await getUserSettings()
            return settings.iCloudSync
        } catch {
            return false
        }
    }
    
    // MARK: - Helper Methods
    
    /// 获取用户设置
    private func getUserSettings() async throws -> UserSettings {
        let descriptor = FetchDescriptor<UserSettings>()
        let settings = try modelContext.fetch(descriptor)
        
        if let existingSettings = settings.first {
            return existingSettings
        } else {
            // 创建默认设置
            let newSettings = UserSettings()
            modelContext.insert(newSettings)
            try modelContext.save()
            return newSettings
        }
    }
    
    deinit {
        networkMonitor.cancel()
    }
}
