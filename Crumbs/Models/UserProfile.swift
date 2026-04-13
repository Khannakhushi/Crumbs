import Foundation

struct UserProfile: Codable {
    var username: String = ""
    var email: String = ""
    var birthday: Date?
    var avatarIndex: Int = 0
    var appearance: String = "system"  // "system", "light", "dark"
}
