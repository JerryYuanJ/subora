# Notification Testing Guide

## Quick Test Steps

### 1. Test Permission Request (First Launch)

1. Delete app from simulator/device (to reset permissions)
2. Install and launch app
3. **Expected**: System permission dialog appears automatically
4. Grant permission
5. **Expected**: Permission granted, no errors

### 2. Test Notification Scheduling

1. Go to Settings → Toggle Pro status ON (Debug mode)
2. Create a new subscription:
   - Name: "Test Subscription"
   - Amount: $9.99
   - Billing cycle: 1 Month
   - First payment date: Today
   - Enable notifications: ON
   - Notify days before: 3
3. Save subscription
4. **Expected**: No errors, subscription created

### 3. Verify Notification is Scheduled

Add this debug code to check pending notifications:

```swift
// In SettingsView or any view
Button("Check Pending Notifications") {
    Task {
        let pending = await NotificationService.shared.getPendingNotifications()
        print("📱 Pending notifications: \(pending.count)")
        for request in pending {
            print("  - ID: \(request.identifier)")
            if let trigger = request.trigger as? UNCalendarNotificationTrigger {
                print("    Date: \(trigger.nextTriggerDate() ?? Date())")
            }
            print("    Title: \(request.content.title)")
            print("    Body: \(request.content.body)")
        }
    }
}
```

### 4. Test Immediate Notification (Quick Test)

Modify `NotificationService.swift` temporarily:

```swift
// In scheduleNotification method, replace the trigger with:
let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
```

This will trigger notification in 5 seconds instead of days later.

**Steps:**

1. Create a subscription with notifications enabled
2. Wait 5 seconds
3. **Expected**: Notification appears on lock screen/banner

**Remember to revert this change after testing!**

### 5. Test Permission Denied Flow

1. Go to iOS Settings → Your App → Notifications
2. Turn OFF "Allow Notifications"
3. Go back to app → Settings
4. **Expected**: Red bell with slash icon (🔕) shown
5. Tap on "Notification Time"
6. **Expected**: Alert appears with "Go to Settings" button
7. Tap "Go to Settings"
8. **Expected**: iOS Settings app opens

### 6. Test Non-Pro User Flow

1. Go to Settings → Toggle Pro status OFF (Debug mode)
2. Create a new subscription
3. Try to enable notifications
4. **Expected**: Crown icon (👑) shown, tapping shows Paywall

### 7. Test Notification Time Change

1. Ensure you're Pro user with permission granted
2. Create 2-3 subscriptions with notifications enabled
3. Go to Settings → Change "Notification Time" from 9:00 AM to 10:00 AM
4. Check pending notifications (use debug code from step 3)
5. **Expected**: All notifications rescheduled to new time

### 8. Test Subscription Lifecycle

**Create:**

1. Create subscription with notifications ON
2. Check pending notifications
3. **Expected**: 1 notification scheduled

**Update:**

1. Edit subscription, change "Notify days before" from 3 to 7
2. Save
3. Check pending notifications
4. **Expected**: Notification updated with new date

**Archive:**

1. Archive the subscription
2. Check pending notifications
3. **Expected**: Notification cancelled (count decreased)

**Unarchive:**

1. Unarchive the subscription
2. Check pending notifications
3. **Expected**: Notification rescheduled

**Delete:**

1. Delete the subscription
2. Check pending notifications
3. **Expected**: Notification cancelled

### 9. Test Internationalization

**English:**

1. Change device language to English
2. Create subscription with notifications
3. Trigger immediate notification (5 second test)
4. **Expected**: "Subscription Renewal Reminder" title

**Chinese:**

1. Change device language to Chinese (Simplified)
2. Create subscription with notifications
3. Trigger immediate notification
4. **Expected**: "订阅续费提醒" title

**Japanese:**

1. Change device language to Japanese
2. Create subscription with notifications
3. Trigger immediate notification
4. **Expected**: "サブスクリプション更新リマインダー" title

### 10. Test Edge Cases

**Past Date:**

1. Create subscription with:
   - First payment date: 2 months ago
   - Billing cycle: 1 month
   - Notify days before: 3
2. **Expected**: No notification scheduled (date is in past)

**Same Day:**

1. Create subscription with:
   - First payment date: Today
   - Billing cycle: 1 month
   - Notify days before: 30
2. **Expected**: Notification scheduled for today (or skipped if past)

**Multiple Subscriptions:**

1. Create 5 subscriptions with different notify days (1, 3, 5, 7, 14)
2. Check pending notifications
3. **Expected**: 5 notifications scheduled at different times

## Debug Commands

### Check Authorization Status

```swift
Task {
    let status = await NotificationService.shared.checkAuthorizationStatus()
    print("Authorization: \(status)")
}
```

### Request Permission Manually

```swift
Task {
    let granted = await NotificationService.shared.requestAuthorization()
    print("Permission granted: \(granted)")
}
```

### Cancel All Notifications

```swift
Task {
    await NotificationService.shared.cancelAllNotifications()
    print("All notifications cancelled")
}
```

### Get Pending Count

```swift
Task {
    let pending = await NotificationService.shared.getPendingNotifications()
    print("Pending: \(pending.count)")
}
```

## Common Issues & Solutions

### Issue: Notifications not appearing

**Solutions:**

1. Check permission status (must be .authorized)
2. Check notification date is in future
3. Check Do Not Disturb is off
4. Check notification settings in iOS Settings
5. Try immediate notification test (5 seconds)

### Issue: Permission dialog not showing

**Solutions:**

1. Delete app and reinstall
2. Reset simulator: Device → Erase All Content and Settings
3. Check if permission was already denied

### Issue: Notifications cancelled unexpectedly

**Solutions:**

1. Check if subscription was archived/deleted
2. Check if notification date passed
3. Verify subscription.notify is true

### Issue: Wrong notification time

**Solutions:**

1. Check UserSettings.defaultNotifyTime
2. Verify timezone is correct
3. Check date calculation logic

### Issue: Localization not working

**Solutions:**

1. Check device language setting
2. Verify Localizable.strings files exist
3. Check L10n.NotificationContent is used (not L10n.Notification)

## Success Criteria

✅ Permission requested on first launch
✅ Permission status shown correctly in Settings
✅ Pro users can enable notifications
✅ Non-Pro users see paywall
✅ Notifications scheduled when subscription created
✅ Notifications updated when subscription modified
✅ Notifications cancelled when subscription deleted/archived
✅ Notifications rescheduled when subscription unarchived
✅ Changing notification time reschedules all notifications
✅ Notification content is localized
✅ Notification appears at correct time
✅ No crashes or errors

## Performance Checklist

- [ ] No memory leaks when scheduling notifications
- [ ] No lag when creating multiple subscriptions
- [ ] Settings page loads quickly
- [ ] Notification time change completes in < 2 seconds
- [ ] App doesn't crash when permission denied

## Accessibility Checklist

- [ ] VoiceOver reads notification permission status
- [ ] VoiceOver reads "Go to Settings" button
- [ ] Color blind users can distinguish permission states
- [ ] Large text mode works correctly

## Final Verification

Before releasing:

1. Test on real device (not just simulator)
2. Test with actual future dates (not 5 second test)
3. Wait for real notification to arrive
4. Test notification tap (opens app)
5. Test with multiple subscriptions
6. Test all three languages
7. Test permission denied flow
8. Test Pro/Non-Pro flows
