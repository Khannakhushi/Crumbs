import SwiftUI

@main
struct CrumbsApp: App {
    @State private var store = EntryStore()
    @State private var profile = ProfileStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(store)
                .environment(profile)
                .preferredColorScheme(profile.colorScheme)
        }
    }
}
