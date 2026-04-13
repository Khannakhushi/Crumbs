import SwiftUI
import Observation

@Observable
class ProfileStore {
    var profile: UserProfile

    private let key = "crumbs_profile"

    init() {
        if let data = UserDefaults.standard.data(forKey: key),
           let decoded = try? JSONDecoder().decode(UserProfile.self, from: data) {
            profile = decoded
        } else {
            profile = UserProfile()
        }
    }

    func save() {
        if let data = try? JSONEncoder().encode(profile) {
            UserDefaults.standard.set(data, forKey: key)
        }
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
}
