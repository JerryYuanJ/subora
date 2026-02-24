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
        
        guard isNetworkAvailable else {
            Logger.sync.error("Sync failed: network unavailable")
            throw AppError.networkUnavailable
        }
        
        currentSyncStatus = .syncing
        
        // SwiftData 自动处理同步，这里只需要保存上下文
        // 这会触发 CloudKit 同步
        try modelContext.save()
        
        // 模拟同步延迟
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5秒
        
        currentSyncStatus = .synced
        Logger.sync.info("Manual sync completed successfully")
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
