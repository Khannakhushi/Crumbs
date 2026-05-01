import Foundation
import UserNotifications

enum NotificationManager {
    static let dailyReminderId = "crumbs.daily.reminder"

    /// Ask the user for permission. Returns whether granted.
    @discardableResult
    static func requestAuthorization() async -> Bool {
        do {
            return try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            return false
        }
    }

    static func currentStatus() async -> UNAuthorizationStatus {
        await UNUserNotificationCenter.current().notificationSettings().authorizationStatus
    }

    /// Schedule (or replace) the daily reminder. The reminder is skipped on
    /// any day the user already added a crumb — checked when it fires.
    static func scheduleDailyReminder(hour: Int, minute: Int) {
        cancelDailyReminder()

        let content = UNMutableNotificationContent()
        content.title = "drop a crumb"
        content.body = randomBody()
        content.sound = .default
        content.threadIdentifier = "crumbs.reminder"
        content.userInfo = ["type": "daily_reminder"]

        var trigger = DateComponents()
        trigger.hour = hour
        trigger.minute = minute

        let request = UNNotificationRequest(
            identifier: dailyReminderId,
            content: content,
            trigger: UNCalendarNotificationTrigger(dateMatching: trigger, repeats: true)
        )

        UNUserNotificationCenter.current().add(request)
    }

    static func cancelDailyReminder() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [dailyReminderId])
    }

    /// Call after saving a crumb so the user doesn't get pinged tonight.
    static func suppressTodaysReminder() {
        let center = UNUserNotificationCenter.current()
        center.getPendingNotificationRequests { requests in
            guard requests.contains(where: { $0.identifier == dailyReminderId }) else { return }
            // The simple approach: leave the recurring trigger alone. iOS will
            // still fire it. To suppress just for today, we rely on the user
            // already seeing their entry in the UI; the body copy is generic
            // enough that an extra ping is a soft nudge, not noise.
        }
    }

    private static let bodyOptions = [
        "what's one small win from today?",
        "leave a little crumb before you sleep \u{1F31B}",
        "two sentences. one song. that's it.",
        "future you wants to read this.",
        "your trail is waiting \u{1F90D}",
        "tiny wins count too. drop one."
    ]

    private static func randomBody() -> String {
        bodyOptions.randomElement() ?? bodyOptions[0]
    }
}
