import SwiftUI
import Observation

@Observable
class ProfileStore {
    var profile: UserProfile

    private let key = "crumbs_profile"
    private var cloudObserver: NSObjectProtocol?

    init() {
        if let data = CloudSync.data(forKey: key),
           let decoded = try? JSONDecoder().decode(UserProfile.self, from: data) {
            profile = decoded
            UserDefaults.standard.set(data, forKey: key)
        } else if let data = UserDefaults.standard.data(forKey: key),
                  let decoded = try? JSONDecoder().decode(UserProfile.self, from: data) {
            profile = decoded
        } else {
            profile = UserProfile()
        }

        // One-time migration: when the app's default flipped from "system" to
        // "dark", carry existing users over to dark too (one time only, then
        // their explicit choices are respected).
        let migrationKey = "crumbs_dark_default_migration"
        if !UserDefaults.standard.bool(forKey: migrationKey) {
            if profile.appearance == "system" {
                profile.appearance = "dark"
                save()
            }
            UserDefaults.standard.set(true, forKey: migrationKey)
        }

        cloudObserver = CloudSync.observeChanges { [weak self] in
            self?.pullFromCloud()
        }
    }

    deinit {
        if let cloudObserver { NotificationCenter.default.removeObserver(cloudObserver) }
    }

    func save() {
        guard let data = try? JSONEncoder().encode(profile) else { return }
        UserDefaults.standard.set(data, forKey: key)
        CloudSync.set(data, forKey: key)
    }

    /// Save and re-schedule the daily reminder if enabled.
    func saveAndReschedule() {
        save()
        if profile.reminderEnabled {
            NotificationManager.scheduleDailyReminder(
                hour: profile.reminderHour,
                minute: profile.reminderMinute
            )
        } else {
            NotificationManager.cancelDailyReminder()
        }
    }

    private func pullFromCloud() {
        guard let data = CloudSync.data(forKey: key),
              let decoded = try? JSONDecoder().decode(UserProfile.self, from: data) else {
            return
        }
        profile = decoded
        UserDefaults.standard.set(data, forKey: key)
    }

    var avatar: AvatarDef {
        let idx = max(0, min(profile.avatarIndex, Theme.avatars.count - 1))
        return Theme.avatars[idx]
    }

    var displayName: String {
        profile.username.isEmpty ? "crumb dropper" : profile.username
    }

    var colorScheme: ColorScheme? {
        switch profile.appearance {
        case "light": return .light
        case "dark": return .dark
        default: return nil
        }
    }

    /// Convenience for the reminder time picker — Date with today's hour/minute.
    var reminderDate: Date {
        get {
            var c = Calendar.current.dateComponents([.year, .month, .day], from: Date())
            c.hour = profile.reminderHour
            c.minute = profile.reminderMinute
            return Calendar.current.date(from: c) ?? Date()
        }
        set {
            let c = Calendar.current.dateComponents([.hour, .minute], from: newValue)
            profile.reminderHour = c.hour ?? 20
            profile.reminderMinute = c.minute ?? 0
        }
    }
}
