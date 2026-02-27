//
//  LocalizationHelper.swift
//  subscription-tracker
//
//  Created by Kiro on 2026/2/24.
//

import Foundation

/// Helper for accessing localized strings
enum L10n {
    
    // MARK: - Tab Bar
    enum Tab {
        static let dashboard = NSLocalizedString("tab.dashboard", comment: "Dashboard tab title")
        static let subscriptions = NSLocalizedString("tab.subscriptions", comment: "Subscriptions tab title")
        static let categories = NSLocalizedString("tab.categories", comment: "Categories tab title")
        static let settings = NSLocalizedString("tab.settings", comment: "Settings tab title")
        static let insights = NSLocalizedString("tab.insights", comment: "Insights tab title")
    }
    
    // MARK: - Common
    enum Common {
        static let cancel = NSLocalizedString("common.cancel", comment: "Cancel button")
        static let save = NSLocalizedString("common.save", comment: "Save button")
        static let delete = NSLocalizedString("common.delete", comment: "Delete button")
        static let edit = NSLocalizedString("common.edit", comment: "Edit button")
        static let done = NSLocalizedString("common.done", comment: "Done button")
        static let close = NSLocalizedString("common.close", comment: "Close button")
    }
    
    // MARK: - Category
    enum Category {
        static let addTitle = NSLocalizedString("category.add_title", comment: "Add category title")
        static let editTitle = NSLocalizedString("category.edit_title", comment: "Edit category title")
        static let sectionBasic = NSLocalizedString("category.section_basic", comment: "Basic info section")
        static let sectionColor = NSLocalizedString("category.section_color", comment: "Color section")
        static let namePlaceholder = NSLocalizedString("category.name_placeholder", comment: "Name placeholder")
        static let descriptionPlaceholder = NSLocalizedString("category.description_placeholder", comment: "Description placeholder")
        static let createNew = NSLocalizedString("category.create_new", comment: "Create new category button")
        static let empty = NSLocalizedString("category.empty", comment: "Empty categories message")
        static let emptyHint = NSLocalizedString("category.empty_hint", comment: "Empty categories hint")
        static func subscriptionCount(_ count: Int) -> String {
            String(format: NSLocalizedString("category.subscription_count", comment: "Subscription count"), count)
        }
        static let deleteConfirmTitle = NSLocalizedString("category.delete_confirm_title", comment: "Delete confirmation title")
        static let deleteConfirmMessage = NSLocalizedString("category.delete_confirm_message", comment: "Delete confirmation message")
        static let saveSuccess = NSLocalizedString("category.save_success", comment: "Save success message")
        static let createSuccess = NSLocalizedString("category.create_success", comment: "Create success message")
        static func saveFailed(_ error: String) -> String {
            String(format: NSLocalizedString("category.save_failed", comment: "Save failed message"), error)
        }
        static let deleteSuccess = NSLocalizedString("category.delete_success", comment: "Delete success message")
        static func deleteFailed(_ error: String) -> String {
            String(format: NSLocalizedString("category.delete_failed", comment: "Delete failed message"), error)
        }
    }
    
    // MARK: - Dashboard
    enum Dashboard {
        static let title = NSLocalizedString("dashboard.title", comment: "Dashboard title")
        static let monthlyExpenses = NSLocalizedString("dashboard.monthly_expenses", comment: "Monthly expenses section title")
        static let noSubscriptions = NSLocalizedString("dashboard.no_subscriptions", comment: "No subscriptions message")
        static let trend = NSLocalizedString("dashboard.trend", comment: "Trend section title")
        static let noTrendData = NSLocalizedString("dashboard.no_trend_data", comment: "No trend data message")
        static let noTrendHint = NSLocalizedString("dashboard.no_trend_hint", comment: "No trend hint message")
        static let upcomingRenewals = NSLocalizedString("dashboard.upcoming_renewals", comment: "Upcoming renewals section title")
        static let noUpcoming = NSLocalizedString("dashboard.no_upcoming", comment: "No upcoming renewals message")
    }
    
    // MARK: - Subscription List
    enum Subscriptions {
        static let title = NSLocalizedString("subscriptions.title", comment: "Subscriptions title")
        static let searchPlaceholder = NSLocalizedString("subscriptions.search_placeholder", comment: "Search placeholder")
        static let filterAll = NSLocalizedString("subscriptions.filter_all", comment: "All filter button")
        static let filterActive = NSLocalizedString("subscriptions.filter_active", comment: "Active filter button")
        static let filterArchived = NSLocalizedString("subscriptions.filter_archived", comment: "Archived filter button")
        static let empty = NSLocalizedString("subscriptions.empty", comment: "Empty subscriptions message")
        static let today = NSLocalizedString("subscriptions.today", comment: "Today")
        static func nextRenewal(_ date: String) -> String {
            String(format: NSLocalizedString("subscriptions.next_renewal", comment: "Next renewal"), date)
        }
    }
    
    // MARK: - Subscription Detail
    enum SubscriptionDetail {
        static let category = NSLocalizedString("subscription_detail.category", comment: "Category label")
        static let amount = NSLocalizedString("subscription_detail.amount", comment: "Amount label")
        static let billingCycle = NSLocalizedString("subscription_detail.billing_cycle", comment: "Billing cycle label")
        static let firstPayment = NSLocalizedString("subscription_detail.first_payment", comment: "First payment label")
        static let nextRenewal = NSLocalizedString("subscription_detail.next_renewal", comment: "Next renewal label")
        static let daysUntil = NSLocalizedString("subscription_detail.days_until", comment: "Days until label")
        static let paymentCount = NSLocalizedString("subscription_detail.payment_count", comment: "Payment count label")
        static let totalPaid = NSLocalizedString("subscription_detail.total_paid", comment: "Total paid label")
        static let notification = NSLocalizedString("subscription_detail.notification", comment: "Notification label")
        static let notificationEnabled = NSLocalizedString("subscription_detail.notification_enabled", comment: "Enabled")
        static let notificationDisabled = NSLocalizedString("subscription_detail.notification_disabled", comment: "Disabled")
        static let notificationTime = NSLocalizedString("subscription_detail.notification_time", comment: "Notification time")
        static let archive = NSLocalizedString("subscription_detail.archive", comment: "Archive button")
        static let unarchive = NSLocalizedString("subscription_detail.unarchive", comment: "Unarchive button")
        static let delete = NSLocalizedString("subscription_detail.delete", comment: "Delete button")
        static let deleteConfirmTitle = NSLocalizedString("subscription_detail.delete_confirm_title", comment: "Delete confirm title")
        static let deleteConfirmMessage = NSLocalizedString("subscription_detail.delete_confirm_message", comment: "Delete confirm message")
        static let archived = NSLocalizedString("subscription_detail.archived", comment: "Archived message")
        static let unarchived = NSLocalizedString("subscription_detail.unarchived", comment: "Unarchived message")
        static let deleteSuccess = NSLocalizedString("subscription_detail.delete_success", comment: "Delete success")
        static let saveSuccess = NSLocalizedString("subscription_detail.save_success", comment: "Save success")
        static func operationFailed(_ error: String) -> String {
            String(format: NSLocalizedString("subscription_detail.operation_failed", comment: "Operation failed"), error)
        }
        static func saveFailed(_ error: String) -> String {
            String(format: NSLocalizedString("subscription_detail.save_failed", comment: "Save failed"), error)
        }
        static let sectionBasic = NSLocalizedString("subscription_detail.section_basic", comment: "Basic section")
        static let sectionBilling = NSLocalizedString("subscription_detail.section_billing", comment: "Billing section")
        static let sectionStats = NSLocalizedString("subscription_detail.section_stats", comment: "Stats section")
        static let sectionNotification = NSLocalizedString("subscription_detail.section_notification", comment: "Notification section")
        static let name = NSLocalizedString("subscription_detail.name", comment: "Name label")
        static let description = NSLocalizedString("subscription_detail.description", comment: "Description label")
        static func daysSuffix(_ count: Int) -> String {
            count == 1 ? NSLocalizedString("days.singular", comment: "day") : NSLocalizedString("days.plural", comment: "days")
        }
        static func timesSuffix(_ count: Int) -> String {
            count == 1 ? NSLocalizedString("times.singular", comment: "time") : NSLocalizedString("times.plural", comment: "times")
        }
        static let edit = NSLocalizedString("subscription_detail.edit", comment: "Edit button")
        static let cancel = NSLocalizedString("subscription_detail.cancel", comment: "Cancel button")
        static let save = NSLocalizedString("subscription_detail.save", comment: "Save button")
        static let enableNotification = NSLocalizedString("subscription_detail.enable_notification", comment: "Enable notification")
        static func notifyDaysBefore(_ days: Int) -> String {
            if days == 0 {
                return NSLocalizedString("subscription.notify_days_before_zero", comment: "Notify on renewal day")
            } else if days == 1 {
                return NSLocalizedString("subscription.notify_days_before_singular", comment: "Notify 1 day before")
            } else {
                return String(format: NSLocalizedString("subscription_detail.notify_days_before", comment: "Notify days before"), days)
            }
        }
    }
    
    // MARK: - Insights
    enum Insights {
        static let activeSubscriptions = NSLocalizedString("insights.active_subscriptions", comment: "Active subscriptions")
        static let upcomingRenewalsCount = NSLocalizedString("insights.upcoming_renewals_count", comment: "Upcoming renewals count")
        static let newThisMonth = NSLocalizedString("insights.new_this_month", comment: "New this month")
        static let averageCost = NSLocalizedString("insights.average_cost", comment: "Average cost")
        static let daysSuffix = NSLocalizedString("days.plural", comment: "Days suffix")
        static let daysSuffixSingular = NSLocalizedString("days.singular", comment: "Day suffix")
        static let manageCards = NSLocalizedString("insights.manage_cards", comment: "Manage cards")
        static let monthlyExpenses = NSLocalizedString("insights.monthly_expenses", comment: "Monthly expenses")
        static let yearlyExpenses = NSLocalizedString("insights.yearly_expenses", comment: "Yearly expenses")
        static let recentTrend = NSLocalizedString("insights.recent_trend", comment: "Recent trend")
        static let allTimeTrend = NSLocalizedString("insights.all_time_trend", comment: "All time trend")
        static let topSpending = NSLocalizedString("insights.top_spending", comment: "Top spending")
        static let upcomingRenewals = NSLocalizedString("insights.upcoming_renewals", comment: "Upcoming renewals")
        static let categoryBreakdown = NSLocalizedString("insights.category_breakdown", comment: "Category breakdown")
        static let noData = NSLocalizedString("insights.no_data", comment: "No data")
        static let noDataHint = NSLocalizedString("insights.no_data_hint", comment: "No data hint")
        static let noCardsSelected = NSLocalizedString("insights.no_cards_selected", comment: "No cards selected")
        static let noCardsHint = NSLocalizedString("insights.no_cards_hint", comment: "No cards hint")
        static func subscriptionsCount(_ count: Int) -> String {
            String(format: NSLocalizedString("insights.subscriptions_count", comment: "Subscriptions count"), count)
        }
        static let currencyNotice = NSLocalizedString("insights.currency_notice", comment: "Currency conversion notice")
        static let currencyNoticeShort = NSLocalizedString("insights.currency_notice_short", comment: "Currency conversion notice short")
        static let noAmount = NSLocalizedString("insights.no_amount", comment: "No amount placeholder")
    }
    
    // MARK: - Add/Edit Subscription
    enum Subscription {
        static let addTitle = NSLocalizedString("subscription.add_title", comment: "Add subscription title")
        static let editTitle = NSLocalizedString("subscription.edit_title", comment: "Edit subscription title")
        static let sectionBasic = NSLocalizedString("subscription.section_basic", comment: "Basic info section")
        static let namePlaceholder = NSLocalizedString("subscription.name_placeholder", comment: "Name placeholder")
        static let descriptionPlaceholder = NSLocalizedString("subscription.description_placeholder", comment: "Description placeholder")
        static let sectionCategory = NSLocalizedString("subscription.section_category", comment: "Category section")
        static let categoryPicker = NSLocalizedString("subscription.category_picker", comment: "Category picker label")
        static let noCategory = NSLocalizedString("subscription.no_category", comment: "No category option")
        static let sectionBilling = NSLocalizedString("subscription.section_billing", comment: "Billing section")
        static let firstPaymentDate = NSLocalizedString("subscription.first_payment_date", comment: "First payment date label")
        static let amount = NSLocalizedString("subscription.amount", comment: "Amount label")
        static let amountPlaceholder = NSLocalizedString("subscription.amount_placeholder", comment: "Amount placeholder")
        static let currency = NSLocalizedString("subscription.currency", comment: "Currency label")
        static let sectionNotification = NSLocalizedString("subscription.section_notification", comment: "Notification section")
        static let enableNotification = NSLocalizedString("subscription.enable_notification", comment: "Enable notification toggle")
        static func notifyDaysBefore(_ days: Int) -> String {
            if days == 0 {
                return NSLocalizedString("subscription.notify_days_before_zero", comment: "Notify on renewal day")
            } else if days == 1 {
                return NSLocalizedString("subscription.notify_days_before_singular", comment: "Notify 1 day before")
            } else {
                return String(format: NSLocalizedString("subscription.notify_days_before", comment: "Notify days before"), days)
            }
        }
        static let buttonCancel = NSLocalizedString("subscription.button_cancel", comment: "Cancel button")
        static let buttonSave = NSLocalizedString("subscription.button_save", comment: "Save button")
    }
    
    // MARK: - Billing Cycle
    enum BillingCycle {
        static let every = NSLocalizedString("billing_cycle.every", comment: "Every prefix")
        static let unit = NSLocalizedString("billing_cycle.unit", comment: "Unit label")
        static let day = NSLocalizedString("billing_cycle.day", comment: "Day unit")
        static let week = NSLocalizedString("billing_cycle.week", comment: "Week unit")
        static let month = NSLocalizedString("billing_cycle.month", comment: "Month unit")
        static let year = NSLocalizedString("billing_cycle.year", comment: "Year unit")
        
        // Display formats
        static let recurring = NSLocalizedString("billing_cycle.recurring", comment: "Recurring")
        static let daily = NSLocalizedString("billing_cycle.daily", comment: "Daily")
        static let weekly = NSLocalizedString("billing_cycle.weekly", comment: "Weekly")
        static let monthly = NSLocalizedString("billing_cycle.monthly", comment: "Monthly")
        static let yearly = NSLocalizedString("billing_cycle.yearly", comment: "Yearly")
        
        static func formatCycle(_ cycle: Int, _ unit: BillingCycleUnit) -> String {
            if cycle == 1 {
                switch unit {
                case .day: return daily
                case .week: return weekly
                case .month: return monthly
                case .year: return yearly
                }
            } else {
                switch unit {
                case .day:
                    return String(format: NSLocalizedString("billing_cycle.every_x_days", comment: "Every X days"), cycle)
                case .week:
                    return String(format: NSLocalizedString("billing_cycle.every_x_weeks", comment: "Every X weeks"), cycle)
                case .month:
                    return String(format: NSLocalizedString("billing_cycle.every_x_months", comment: "Every X months"), cycle)
                case .year:
                    return String(format: NSLocalizedString("billing_cycle.every_x_years", comment: "Every X years"), cycle)
                }
            }
        }
    }
    
    // MARK: - Paywall
    enum Paywall {
        static let title = NSLocalizedString("paywall.title", comment: "Paywall title")
        static let subtitle = NSLocalizedString("paywall.subtitle", comment: "Paywall subtitle")
        static let planMonthly = NSLocalizedString("paywall.plan_monthly", comment: "Monthly plan")
        static let planYearly = NSLocalizedString("paywall.plan_yearly", comment: "Yearly plan")
        static let planMonthlyDuration = NSLocalizedString("paywall.plan_monthly_duration", comment: "Monthly duration")
        static let planYearlyDuration = NSLocalizedString("paywall.plan_yearly_duration", comment: "Yearly duration")
        static let planYearlySavings = NSLocalizedString("paywall.plan_yearly_savings", comment: "Yearly savings")
        static let planMonthlyShort = NSLocalizedString("paywall.plan_monthly_short", comment: "Monthly short")
        static let featureUnlimitedSubscriptions = NSLocalizedString("paywall.feature_unlimited_subscriptions", comment: "Unlimited subscriptions feature")
        static let featureUnlimitedSubscriptionsDesc = NSLocalizedString("paywall.feature_unlimited_subscriptions_desc", comment: "Unlimited subscriptions description")
        static let featureUnlimitedCategories = NSLocalizedString("paywall.feature_unlimited_categories", comment: "Unlimited categories feature")
        static let featureUnlimitedCategoriesDesc = NSLocalizedString("paywall.feature_unlimited_categories_desc", comment: "Unlimited categories description")
        static let featureiCloudSync = NSLocalizedString("paywall.feature_icloud_sync", comment: "iCloud sync feature")
        static let featureiCloudSyncDesc = NSLocalizedString("paywall.feature_icloud_sync_desc", comment: "iCloud sync description")
        static let featureSmartNotifications = NSLocalizedString("paywall.feature_smart_notifications", comment: "Smart notifications feature")
        static let featureSmartNotificationsDesc = NSLocalizedString("paywall.feature_smart_notifications_desc", comment: "Smart notifications description")
        static let featureAdvancedStats = NSLocalizedString("paywall.feature_advanced_stats", comment: "Advanced stats feature")
        static let featureAdvancedStatsDesc = NSLocalizedString("paywall.feature_advanced_stats_desc", comment: "Advanced stats description")
        static let featureThemeCustomization = NSLocalizedString("paywall.feature_theme_customization", comment: "Theme customization feature")
        static let featureThemeCustomizationDesc = NSLocalizedString("paywall.feature_theme_customization_desc", comment: "Theme customization description")
        static let buttonPurchase = NSLocalizedString("paywall.button_purchase", comment: "Purchase button")
        static let buttonSelectPlan = NSLocalizedString("paywall.button_select_plan", comment: "Select plan button")
        static let buttonRestore = NSLocalizedString("paywall.button_restore", comment: "Restore button")
        static let buttonClose = NSLocalizedString("paywall.button_close", comment: "Close button")
        static let errorNoActivePurchase = NSLocalizedString("paywall.error_no_active_purchase", comment: "No active purchase error")
    }
    
    // MARK: - Settings
    enum Settings {
        static let title = NSLocalizedString("settings.title", comment: "Settings title")
        static let sectionSettings = NSLocalizedString("settings.section_settings", comment: "Settings section")
        static let theme = NSLocalizedString("settings.theme", comment: "Theme label")
        static let sectionAppearance = NSLocalizedString("settings.section_appearance", comment: "Appearance section")
        static let darkMode = NSLocalizedString("settings.dark_mode", comment: "Dark mode label")
        static let darkModeSystem = NSLocalizedString("settings.dark_mode_system", comment: "System dark mode option")
        static let darkModeLight = NSLocalizedString("settings.dark_mode_light", comment: "Light mode option")
        static let darkModeDark = NSLocalizedString("settings.dark_mode_dark", comment: "Dark mode option")
        static let language = NSLocalizedString("settings.language", comment: "Language label")
        static let languageZh = NSLocalizedString("settings.language_zh", comment: "Chinese language")
        static let languageEn = NSLocalizedString("settings.language_en", comment: "English language")
        static let languageJa = NSLocalizedString("settings.language_ja", comment: "Japanese language")
        static let themeColor = NSLocalizedString("settings.theme_color", comment: "Theme color label")
        static let sectionDefaults = NSLocalizedString("settings.section_defaults", comment: "Defaults section")
        static let defaultCurrency = NSLocalizedString("settings.default_currency", comment: "Default currency label")
        static let notificationTime = NSLocalizedString("settings.notification_time", comment: "Notification time label")
        static let sectionData = NSLocalizedString("settings.section_data", comment: "Data section")
        static let iCloudSync = NSLocalizedString("settings.icloud_sync", comment: "iCloud sync label")
        static let syncStatus = NSLocalizedString("settings.sync_status", comment: "Sync status label")
        static let manualSync = NSLocalizedString("settings.manual_sync", comment: "Manual sync button")
        static let syncSyncing = NSLocalizedString("settings.sync_syncing", comment: "Syncing status")
        static let syncSynced = NSLocalizedString("settings.sync_synced", comment: "Synced status")
        static let syncError = NSLocalizedString("settings.sync_error", comment: "Sync error status")
        static let syncDisabled = NSLocalizedString("settings.sync_disabled", comment: "Sync disabled status")
        static let clearData = NSLocalizedString("settings.clear_data", comment: "Clear data button")
        static let clearDataConfirmTitle = NSLocalizedString("settings.clear_data_confirm_title", comment: "Clear data confirm title")
        static let clearDataConfirmMessage = NSLocalizedString("settings.clear_data_confirm_message", comment: "Clear data confirm message")
        static let clearDataSuccess = NSLocalizedString("settings.clear_data_success", comment: "Clear data success message")
        static func clearDataFailed(_ error: String) -> String {
            String(format: NSLocalizedString("settings.clear_data_failed", comment: "Clear data failed"), error)
        }
        static let categoryManagement = NSLocalizedString("settings.category_management", comment: "Category management label")
        static let sectionPro = NSLocalizedString("settings.section_pro", comment: "Pro section")
        static let proPurchased = NSLocalizedString("settings.pro_purchased", comment: "Pro purchased message")
        static let upgradeToPro = NSLocalizedString("settings.upgrade_to_pro", comment: "Upgrade to pro button")
        static let restorePurchases = NSLocalizedString("settings.restore_purchases", comment: "Restore purchases button")
        static let sectionAbout = NSLocalizedString("settings.section_about", comment: "About section")
        static let version = NSLocalizedString("settings.version", comment: "Version label")
        static let contactUs = NSLocalizedString("settings.contact_us", comment: "Contact us button")
        static let contactUsSubtitle = NSLocalizedString("settings.contact_us_subtitle", comment: "Contact us subtitle")
        static let rateApp = NSLocalizedString("settings.rate_app", comment: "Rate app button")
        static let rateAppSubtitle = NSLocalizedString("settings.rate_app_subtitle", comment: "Rate app subtitle")
        static let shareApp = NSLocalizedString("settings.share_app", comment: "Share app button")
        static let shareAppSubtitle = NSLocalizedString("settings.share_app_subtitle", comment: "Share app subtitle")
        static let shareMessage = NSLocalizedString("settings.share_message", comment: "Share message")
        static func appVersion(_ version: String) -> String {
            String(format: NSLocalizedString("settings.app_version", comment: "App version"), version)
        }
    }
    
    // MARK: - Color Picker
    enum ColorPicker {
        static let title = NSLocalizedString("color_picker.title", comment: "Color picker title")
        static let custom = NSLocalizedString("color_picker.custom", comment: "Custom color")
        static let customColor = NSLocalizedString("color_picker.custom_color", comment: "Custom color title")
        static let selectColor = NSLocalizedString("color_picker.select_color", comment: "Select color")
    }
    
    enum Color {
        static let red = NSLocalizedString("color.red", comment: "Red color")
        static let orange = NSLocalizedString("color.orange", comment: "Orange color")
        static let yellow = NSLocalizedString("color.yellow", comment: "Yellow color")
        static let green = NSLocalizedString("color.green", comment: "Green color")
        static let blue = NSLocalizedString("color.blue", comment: "Blue color")
        static let purple = NSLocalizedString("color.purple", comment: "Purple color")
        static let pinkPurple = NSLocalizedString("color.pink_purple", comment: "Pink purple color")
        static let pink = NSLocalizedString("color.pink", comment: "Pink color")
        static let brown = NSLocalizedString("color.brown", comment: "Brown color")
        static let gray = NSLocalizedString("color.gray", comment: "Gray color")
        static let cyan = NSLocalizedString("color.cyan", comment: "Cyan color")
        static let skyBlue = NSLocalizedString("color.sky_blue", comment: "Sky blue color")
        static let coral = NSLocalizedString("color.coral", comment: "Coral color")
        static let teal = NSLocalizedString("color.teal", comment: "Teal color")
    }
    
    // MARK: - Loading & Toast
    enum Loading {
        static let `default` = NSLocalizedString("loading.default", comment: "Default loading message")
        static let saving = NSLocalizedString("loading.saving", comment: "Saving loading message")
    }
    
    enum Toast {
        static let saveSuccess = NSLocalizedString("toast.save_success", comment: "Save success message")
        static let purchaseSuccess = NSLocalizedString("toast.purchase_success", comment: "Purchase success message")
        static let restoreSuccess = NSLocalizedString("toast.restore_success", comment: "Restore success message")
        static func purchaseFailed(_ error: String) -> String {
            String(format: NSLocalizedString("toast.purchase_failed", comment: "Purchase failed message"), error)
        }
        static func restoreFailed(_ error: String) -> String {
            String(format: NSLocalizedString("toast.restore_failed", comment: "Restore failed message"), error)
        }
    }
    
    // MARK: - Validation Errors
    enum Validation {
        static let nameEmpty = NSLocalizedString("validation.name_empty", comment: "Name empty error")
        static let nameTooLong = NSLocalizedString("validation.name_too_long", comment: "Name too long error")
        static let amountInvalid = NSLocalizedString("validation.amount_invalid", comment: "Amount invalid error")
        static let billingCycleInvalid = NSLocalizedString("validation.billing_cycle_invalid", comment: "Billing cycle invalid error")
        static let firstPaymentFuture = NSLocalizedString("validation.first_payment_future", comment: "First payment future error")
        static let currencyUnsupported = NSLocalizedString("validation.currency_unsupported", comment: "Currency unsupported error")
        static let notifyDaysInvalid = NSLocalizedString("validation.notify_days_invalid", comment: "Notify days invalid error")
    }
    
    // MARK: - App Errors
    enum Error {
        static let dataNotFound = NSLocalizedString("error.data_not_found", comment: "Data not found error")
        static func dataSaveFailed(_ reason: String) -> String {
            String(format: NSLocalizedString("error.data_save_failed", comment: "Data save failed error"), reason)
        }
        static func dataLoadFailed(_ reason: String) -> String {
            String(format: NSLocalizedString("error.data_load_failed", comment: "Data load failed error"), reason)
        }
        static func invalidData(_ field: String) -> String {
            String(format: NSLocalizedString("error.invalid_data", comment: "Invalid data error"), field)
        }
        static let subscriptionLimit = NSLocalizedString("error.subscription_limit", comment: "Subscription limit error")
        static let categoryLimit = NSLocalizedString("error.category_limit", comment: "Category limit error")
        static let notificationPermission = NSLocalizedString("error.notification_permission", comment: "Notification permission error")
        static let notificationSchedule = NSLocalizedString("error.notification_schedule", comment: "Notification schedule error")
        static func syncFailed(_ reason: String) -> String {
            String(format: NSLocalizedString("error.sync_failed", comment: "Sync failed error"), reason)
        }
        static let networkUnavailable = NSLocalizedString("error.network_unavailable", comment: "Network unavailable error")
        static let iCloudUnavailable = NSLocalizedString("error.icloud_unavailable", comment: "iCloud unavailable error")
        static func purchaseFailed(_ reason: String) -> String {
            String(format: NSLocalizedString("error.purchase_failed", comment: "Purchase failed error"), reason)
        }
        static let purchaseCancelled = NSLocalizedString("error.purchase_cancelled", comment: "Purchase cancelled error")
        static let restoreFailed = NSLocalizedString("error.restore_failed", comment: "Restore failed error")
    }
    
    // MARK: - Notifications (Push Notifications)
    enum NotificationContent {
        static let title = NSLocalizedString("notification.title", comment: "Notification title")
        static func body(_ name: String, _ days: Int, _ amount: String) -> String {
            String(format: NSLocalizedString("notification.body", comment: "Notification body"), name, days, amount)
        }
        static let permissionRequired = NSLocalizedString("notification.permission_required", comment: "Permission required")
        static let permissionMessage = NSLocalizedString("notification.permission_message", comment: "Permission message")
        static let goToSettings = NSLocalizedString("notification.go_to_settings", comment: "Go to settings")
        static let testNotification = NSLocalizedString("notification.test_notification", comment: "Test notification")
        static let testSent = NSLocalizedString("notification.test_sent", comment: "Test sent")
        static let scheduledSuccess = NSLocalizedString("notification.scheduled_success", comment: "Scheduled success")
        static let cancelledSuccess = NSLocalizedString("notification.cancelled_success", comment: "Cancelled success")
    }
}
