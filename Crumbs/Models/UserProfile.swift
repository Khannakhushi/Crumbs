import Foundation

struct UserProfile: Codable {
    var username: String = ""
    var email: String = ""
    var birthday: Date?
    var avatarIndex: Int = 0
    var appearance: String = "dark"  // "system", "light", "dark"

    // Onboarding
    var hasCompletedOnboarding: Bool = false

    // Daily reminder
    var reminderEnabled: Bool = false
    var reminderHour: Int = 20      // 8pm default
    var reminderMinute: Int = 0
}
