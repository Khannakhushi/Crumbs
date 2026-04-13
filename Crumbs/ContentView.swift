import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    @Environment(ProfileStore.self) private var profile

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label("today", systemImage: selectedTab == 0 ? "sun.max.fill" : "sun.max")
                }
                .tag(0)

            CalendarView()
                .tabItem {
                    Label("trail", systemImage: selectedTab == 1 ? "heart.circle.fill" : "heart.circle")
                }
                .tag(1)

            RecapView()
                .tabItem {
                    Label("recap", systemImage: "sparkles")
                }
                .tag(2)

            ProfileView()
                .tabItem {
                    Label("you", systemImage: selectedTab == 3 ? "person.crop.circle.fill" : "person.crop.circle")
                }
                .tag(3)
        }
        .tint(Theme.accent)
    }
}
