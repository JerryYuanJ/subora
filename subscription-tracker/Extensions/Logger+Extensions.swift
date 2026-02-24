//
//  Logger+Extensions.swift
//  subscription-tracker
//
//  Created for Subscription Tracker App
//  Provides OSLog logging subsystems for different app components
//

import OSLog

extension Logger {
    /// Subsystem identifier for the app
    private static let subsystem = "com.example.subscriptiontracker"
    
    /// General app-level logging (UI, navigation, lifecycle)
    static let app = Logger(subsystem: subsystem, category: "app")
    
    /// Data operations logging (SwiftData CRUD, persistence)
    static let data = Logger(subsystem: subsystem, category: "data")
    
    /// iCloud sync operations logging
    static let sync = Logger(subsystem: subsystem, category: "sync")
    
    /// Notification system logging (scheduling, permissions, delivery)
    static let notification = Logger(subsystem: subsystem, category: "notification")
}
