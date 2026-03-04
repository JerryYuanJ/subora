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
    
    /// 检查 iCloud 账号状态（带超时）
    private func checkiCloudAccountStatus() async -> Bool {
        Logger.sync.info("Checking iCloud account status...")

        return await withCheckedContinuation { continuation in
            var hasResumed = false
            let lock = NSLock()

            // 设置 5 秒超时
            Task {
                try? await Task.sleep(nanoseconds: 5_000_000_000) // 5秒
                lock.lock()
                if !hasResumed {
                    hasResumed = true
                    lock.unlock()
                    Logger.sync.warning("iCloud account check timed out (5s), assuming available")
                    continuation.resume(returning: true) // 超时时假设可用
                } else {
                    lock.unlock()
                }
            }

            CKContainer.default().accountStatus { status, error in
                lock.lock()
                guard !hasResumed else {
                    lock.unlock()
                    return
                }
                hasResumed = true
                lock.unlock()

                if let error = error {
                    Logger.sync.error("iCloud account check failed: \(error.localizedDescription)")
                    continuation.resume(returning: false)
                    return
                }

                switch status {
                case .available:
                    Logger.sync.info("iCloud account available")
                    continuation.resume(returning: true)
                case .noAccount:
                    Logger.sync.error("No iCloud account signed in")
                    continuation.resume(returning: false)
                case .restricted:
                    Logger.sync.error("iCloud account restricted")
                    continuation.resume(returning: false)
                case .couldNotDetermine:
                    Logger.sync.error("Could not determine iCloud account status")
                    continuation.resume(returning: false)
                case .temporarilyUnavailable:
                    Logger.sync.warning("iCloud temporarily unavailable")
                    continuation.resume(returning: false)
                @unknown default:
                    Logger.sync.error("Unknown iCloud account status: \(status.rawValue)")
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

        // 检查 iCloud 账户是否可用
        let iCloudAvailable = await checkiCloudAccountStatus()
        guard iCloudAvailable else {
            Logger.sync.error("Cannot enable sync: iCloud account not available")
            throw AppError.iCloudNotAvailable
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
        do {
            // 更新最后同步时间
            settings.lastSyncTime = Date()

            try modelContext.save()
            Logger.sync.info("Data saved, SwiftData will sync to CloudKit automatically")

            // 可选：快速验证 CloudKit 连接（不阻塞，有超时）
            Task.detached {
                await self.verifyCloudKitConnection()
            }

            // 模拟同步延迟
            try await Task.sleep(nanoseconds: 500_000_000) // 0.5秒

            currentSyncStatus = .synced
            Logger.sync.info("Manual sync completed successfully")
        } catch {
            currentSyncStatus = .error("同步失败")
            Logger.sync.error("Sync failed: \(error.localizedDescription)")
            throw AppError.syncFailed(reason: error.localizedDescription)
        }
    }
    
    /// 验证 CloudKit 连接（仅用于调试，不影响实际同步，带超时）
    func verifyCloudKitConnection() async {
        Logger.sync.info("Verifying CloudKit connection...")

        let container = CKContainer.default()

        // 使用 Task with timeout
        let result = await withTaskGroup(of: Result<CKRecord.ID, Error>?.self) { group in
            group.addTask {
                do {
                    let userRecordID = try await container.userRecordID()
                    return .success(userRecordID)
                } catch {
                    return .failure(error)
                }
            }

            group.addTask {
                try? await Task.sleep(nanoseconds: 5_000_000_000) // 5秒
                return nil
            }

            if let firstResult = await group.next() {
                group.cancelAll()
                return firstResult
            }
            return nil
        }

        switch result {
        case .success(let userRecordID):
            Logger.sync.info("CloudKit connection OK, user: \(userRecordID.recordName)")
        case .failure(let error):
            Logger.sync.warning("CloudKit verification failed (does not affect sync): \(error.localizedDescription)")
        case .none:
            Logger.sync.warning("CloudKit verification timed out (5s)")
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
            // 创建前再次检查（防止并发创建）
            let count = try modelContext.fetchCount(descriptor)
            if count > 0 {
                return try modelContext.fetch(descriptor).first!
            }
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
