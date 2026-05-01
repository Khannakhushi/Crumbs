import SwiftUI

@main
struct CrumbsApp: App {
    @State private var store = EntryStore()
    @State private var profile = ProfileStore()

    var body: some Scene {
        WindowGroup {
            LaunchView {
                RootView()
                    .environment(store)
                    .environment(profile)
                    .preferredColorScheme(profile.colorScheme)
            }
        }
    }
}

struct RootView: View {
    @Environment(ProfileStore.self) private var profile

    var body: some View {
        ZStack {
            if profile.profile.hasCompletedOnboarding {
                ContentView()
                    .transition(.opacity)
            } else {
                OnboardingView()
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.4), value: profile.profile.hasCompletedOnboarding)
    }
}
