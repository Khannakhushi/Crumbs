import SwiftUI

struct ProfileView: View {
    @Environment(ProfileStore.self) private var profileStore
    @Environment(EntryStore.self) private var entryStore
    @Environment(\.colorScheme) private var scheme
    @State private var showAvatarPicker = false

    var body: some View {
        @Bindable var store = profileStore

        ZStack {
            AmbientBackground()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 28) {
                    // Avatar + name header
                    avatarHeader

                    // Profile fields
                    fieldsCard

                    // Appearance
                    appearanceCard

                    // Stats
                    statsCard

                    Spacer(minLength: 60)
                }
                .padding(.horizontal, 20)
            }
        }
        .sheet(isPresented: $showAvatarPicker) {
            avatarPickerSheet
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(32)
        }
    }

    // MARK: - Avatar header

    private var avatarHeader: some View {
        VStack(spacing: 16) {
            Button { showAvatarPicker = true } label: {
                ZStack {
                    let av = profileStore.avatar
                    Circle()
                        .fill(
                            LinearGradient(colors: av.colors,
                                           startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                        .frame(width: 96, height: 96)

                    Image(systemName: av.symbol)
                        .font(.system(size: 40, weight: .semibold))
                        .foregroundStyle(.white)

                    // Edit badge
                    Circle()
                        .fill(Theme.cardBg)
                        .frame(width: 30, height: 30)
                        .overlay {
                            Image(systemName: "pencil")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(Theme.accent)
                        }
                        .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
                        .offset(x: 34, y: 34)
                }
            }

            Text(profileStore.displayName)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundStyle(Theme.textPrimary)

            if entryStore.entries.count > 0 {
                Text("\(entryStore.entries.count) crumbs dropped")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(Theme.textSecondary)
            }
        }
        .padding(.top, 24)
    }

    // MARK: - Fields

    private var fieldsCard: some View {
        @Bindable var store = profileStore

        return VStack(spacing: 0) {
            fieldRow(icon: "person.fill", iconColors: [Color(hex: "4FACFE"), Color(hex: "00F2FE")], label: "username") {
                TextField("your name", text: $store.profile.username)
                    .font(.system(size: 16, weight: .regular, design: .rounded))
                    .foregroundStyle(Theme.textPrimary)
                    .multilineTextAlignment(.trailing)
                    .onChange(of: store.profile.username) { _, _ in store.save() }
            }

            Divider().overlay(Theme.divider).padding(.leading, 60)

            fieldRow(icon: "envelope.fill", iconColors: [Color(hex: "FA709A"), Color(hex: "FEE140")], label: "email") {
                TextField("your@email.com", text: $store.profile.email)
                    .font(.system(size: 16, weight: .regular, design: .rounded))
                    .foregroundStyle(Theme.textPrimary)
                    .multilineTextAlignment(.trailing)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .onChange(of: store.profile.email) { _, _ in store.save() }
            }

            Divider().overlay(Theme.divider).padding(.leading, 60)

            fieldRow(icon: "gift.fill", iconColors: [Color(hex: "A18CD1"), Color(hex: "FBC2EB")], label: "birthday") {
                let binding = Binding<Date>(
                    get: { store.profile.birthday ?? Date() },
                    set: { store.profile.birthday = $0; store.save() }
                )
                DatePicker("", selection: binding, displayedComponents: .date)
                    .labelsHidden()
                    .tint(Theme.accent)
            }
        }
        .padding(.vertical, 6)
        .crumbsCard()
    }

    private func fieldRow<Content: View>(icon: String, iconColors: [Color], label: String, @ViewBuilder content: () -> Content) -> some View {
        HStack(spacing: 14) {
            GradientIcon(symbol: icon, colors: iconColors, size: 14, bgSize: 34)

            Text(label)
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundStyle(Theme.textPrimary)

            Spacer()

            content()
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 14)
    }

    // MARK: - Appearance

    private var appearanceCard: some View {
        @Bindable var store = profileStore

        return VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 10) {
                GradientIcon(symbol: "paintbrush.fill",
                             colors: [Color(hex: "E8735A"), Color(hex: "F5A623")],
                             size: 14, bgSize: 34)

                Text("APPEARANCE")
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundStyle(Theme.textSecondary)
                    .tracking(1.5)
            }

            HStack(spacing: 10) {
                ForEach(["system", "light", "dark"], id: \.self) { mode in
                    let isSelected = store.profile.appearance == mode
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            store.profile.appearance = mode
                            store.save()
                        }
                    } label: {
                        VStack(spacing: 8) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .fill(appearancePreviewBg(mode))
                                    .frame(height: 48)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                                            .stroke(isSelected ? Theme.accent : Theme.divider, lineWidth: isSelected ? 2 : 1)
                                    )

                                Image(systemName: appearanceIcon(mode))
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundStyle(appearanceIconColor(mode))
                            }

                            Text(mode)
                                .font(.system(size: 12, weight: isSelected ? .bold : .medium, design: .rounded))
                                .foregroundStyle(isSelected ? Theme.accent : Theme.textSecondary)
                        }
                    }
                    .buttonStyle(.plain)
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(18)
        .crumbsCard()
    }

    private func appearanceIcon(_ mode: String) -> String {
        switch mode {
        case "light": return "sun.max.fill"
        case "dark": return "moon.fill"
        default: return "circle.lefthalf.filled"
        }
    }

    private func appearancePreviewBg(_ mode: String) -> Color {
        switch mode {
        case "light": return Color(hex: "FFF8F2")
        case "dark": return Color(hex: "1A1715")
        default: return scheme == .dark ? Color(hex: "2A2520") : Color(hex: "F0EBE5")
        }
    }

    private func appearanceIconColor(_ mode: String) -> Color {
        switch mode {
        case "light": return Color(hex: "F5A623")
        case "dark": return Color(hex: "A18CD1")
        default: return Theme.textSecondary
        }
    }

    // MARK: - Stats

    private var statsCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 10) {
                GradientIcon(symbol: "chart.bar.fill",
                             colors: [Color(hex: "43E97B"), Color(hex: "38F9D7")],
                             size: 14, bgSize: 34)

                Text("YOUR JOURNEY")
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundStyle(Theme.textSecondary)
                    .tracking(1.5)
            }

            HStack(spacing: 0) {
                journeyStat("\(entryStore.entries.count)", "total\ncrumbs")
                journeyStat("\(entryStore.longestStreak)", "longest\nstreak")
                journeyStat("\(entryStore.currentStreak)", "current\nstreak")
            }
        }
        .padding(18)
        .crumbsCard()
    }

    private func journeyStat(_ value: String, _ label: String) -> some View {
        VStack(spacing: 6) {
            Text(value)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(Theme.accent)
            Text(label)
                .font(.system(size: 11, weight: .medium, design: .rounded))
                .foregroundStyle(Theme.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Avatar picker sheet

    private var avatarPickerSheet: some View {
        VStack(spacing: 20) {
            Text("pick your avatar")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundStyle(Theme.textPrimary)
                .padding(.top, 8)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 4), spacing: 16) {
                ForEach(Theme.avatars) { av in
                    let isSelected = profileStore.profile.avatarIndex == av.id
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            profileStore.profile.avatarIndex = av.id
                            profileStore.save()
                        }
                    } label: {
                        VStack(spacing: 6) {
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(colors: av.colors,
                                                       startPoint: .topLeading, endPoint: .bottomTrailing)
                                    )
                                    .frame(width: 64, height: 64)

                                Image(systemName: av.symbol)
                                    .font(.system(size: 26, weight: .semibold))
                                    .foregroundStyle(.white)

                                if isSelected {
                                    Circle()
                                        .stroke(Theme.textPrimary, lineWidth: 3)
                                        .frame(width: 70, height: 70)
                                }
                            }

                            Text(av.name)
                                .font(.system(size: 11, weight: .semibold, design: .rounded))
                                .foregroundStyle(isSelected ? Theme.accent : Theme.textSecondary)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 20)

            Spacer()
        }
        .padding(.top, 16)
        .background(Theme.bg)
    }
}
