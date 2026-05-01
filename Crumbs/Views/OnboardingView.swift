import SwiftUI

struct OnboardingView: View {
    @Environment(ProfileStore.self) private var profileStore
    @State private var step: Int = 0
    @State private var name: String = ""
    @State private var avatarIndex: Int = 0
    @State private var birthday: Date = Date()
    @State private var includeBirthday: Bool = false
    @State private var reminderDate: Date = Self.defaultReminderDate()
    @State private var reminderEnabled: Bool = true
    @FocusState private var nameFocused: Bool

    private static let totalSteps = 5  // welcome, name, avatar, reminder, done

    var body: some View {
        ZStack {
            AmbientBackground()

            VStack(spacing: 0) {
                progressBar

                Group {
                    switch step {
                    case 0: welcomeStep
                    case 1: nameStep
                    case 2: avatarStep
                    case 3: reminderStep
                    default: finishStep
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))

                bottomBar
            }
        }
    }

    // MARK: - Progress

    private var progressBar: some View {
        HStack(spacing: 6) {
            ForEach(0..<Self.totalSteps, id: \.self) { i in
                Capsule()
                    .fill(i <= step ? Theme.accent : Theme.heartEmpty)
                    .frame(height: 4)
                    .animation(.easeInOut(duration: 0.25), value: step)
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 12)
    }

    // MARK: - Step 0: welcome

    @State private var welcomeAppear: Bool = false

    private var welcomeStep: some View {
        VStack(spacing: 32) {
            Spacer()

            // Logo and wordmark match the LaunchView's exactly (size +
            // position), so the launch-to-welcome crossfade looks like one
            // continuous logo. They appear immediately at full opacity.
            CrumbsLogo(size: 150, isAnimating: false)

            VStack(spacing: 18) {
                CrumbsWordmark(fontSize: 52)

                // Tagline fades in shortly after the screen appears
                Text("\u{2014} and it all began with\none small win")
                    .font(.system(size: 18, weight: .regular))
                    .foregroundStyle(Theme.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(5)
                    .tracking(-0.2)
                    .opacity(welcomeAppear ? 1 : 0)
                    .offset(y: welcomeAppear ? 0 : 8)
            }

            Spacer()
            Spacer()
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.6).delay(0.4)) {
                welcomeAppear = true
            }
        }
    }

    // MARK: - Step 1: name + birthday

    private var nameStep: some View {
        VStack(spacing: 24) {
            Spacer().frame(height: 12)

            stepHeader(
                eyebrow: "STEP 1 OF 4",
                title: "what should we call you?",
                subtitle: "you can change this anytime"
            )

            VStack(spacing: 14) {
                TextField("your name", text: $name)
                    .focused($nameFocused)
                    .font(.system(size: 22, weight: .semibold, design: .rounded))
                    .foregroundStyle(Theme.textPrimary)
                    .multilineTextAlignment(.center)
                    .padding(.vertical, 22)
                    .padding(.horizontal, 18)
                    .background(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(Theme.inputBg)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20, style: .continuous)
                                    .stroke(Theme.divider, lineWidth: 1)
                            )
                    )
                    .submitLabel(.next)
                    .onSubmit { advance() }

                // Optional birthday
                VStack(alignment: .leading, spacing: 12) {
                    Toggle(isOn: $includeBirthday.animation(.easeInOut(duration: 0.2))) {
                        HStack(spacing: 12) {
                            GradientIcon(
                                symbol: "gift.fill",
                                colors: [Color(hex: "A18CD1"), Color(hex: "FBC2EB")],
                                size: 13, bgSize: 32
                            )
                            VStack(alignment: .leading, spacing: 1) {
                                Text("add your birthday")
                                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                                    .foregroundStyle(Theme.textPrimary)
                                Text("optional little touch")
                                    .font(.system(size: 12, weight: .medium, design: .rounded))
                                    .foregroundStyle(Theme.textSecondary)
                            }
                        }
                    }
                    .tint(Theme.accent)

                    if includeBirthday {
                        DatePicker("", selection: $birthday, displayedComponents: .date)
                            .labelsHidden()
                            .datePickerStyle(.wheel)
                            .frame(maxHeight: 140)
                            .tint(Theme.accent)
                    }
                }
                .padding(16)
                .crumbsCard(cornerRadius: 18)
            }
            .padding(.horizontal, 24)

            Spacer()
        }
        .onAppear { nameFocused = true }
    }

    // MARK: - Step 2: avatar

    private var avatarStep: some View {
        VStack(spacing: 24) {
            Spacer().frame(height: 12)

            stepHeader(
                eyebrow: "STEP 2 OF 4",
                title: "pick your avatar",
                subtitle: "this is you on your trail"
            )

            // Big preview
            let av = Theme.avatars[max(0, min(avatarIndex, Theme.avatars.count - 1))]
            ZStack {
                Circle()
                    .fill(LinearGradient(colors: av.colors,
                                         startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 110, height: 110)
                    .shadow(color: av.colors.first!.opacity(0.4), radius: 24, y: 8)
                Image(systemName: av.symbol)
                    .font(.system(size: 46, weight: .semibold))
                    .foregroundStyle(.white)
            }

            Text(av.name)
                .font(.system(size: 17, weight: .bold, design: .rounded))
                .foregroundStyle(Theme.accent)

            // Grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 14), count: 4), spacing: 14) {
                ForEach(Theme.avatars) { a in
                    Button {
                        Haptics.selection()
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            avatarIndex = a.id
                        }
                    } label: {
                        ZStack {
                            Circle()
                                .fill(LinearGradient(colors: a.colors,
                                                     startPoint: .topLeading, endPoint: .bottomTrailing))
                                .frame(width: 56, height: 56)
                            Image(systemName: a.symbol)
                                .font(.system(size: 22, weight: .semibold))
                                .foregroundStyle(.white)
                            if a.id == avatarIndex {
                                Circle()
                                    .stroke(Theme.textPrimary, lineWidth: 3)
                                    .frame(width: 64, height: 64)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 28)

            Spacer()
        }
    }

    // MARK: - Step 3: reminder

    private var reminderStep: some View {
        VStack(spacing: 24) {
            Spacer().frame(height: 12)

            stepHeader(
                eyebrow: "STEP 3 OF 4",
                title: "when should we nudge you?",
                subtitle: "we'll send a tiny reminder once a day"
            )

            VStack(spacing: 16) {
                Toggle(isOn: $reminderEnabled.animation(.easeInOut(duration: 0.2))) {
                    HStack(spacing: 12) {
                        GradientIcon(
                            symbol: "bell.fill",
                            colors: [Color(hex: "FA709A"), Color(hex: "FEE140")],
                            size: 14, bgSize: 36
                        )
                        VStack(alignment: .leading, spacing: 1) {
                            Text("daily reminder")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundStyle(Theme.textPrimary)
                            Text(reminderEnabled ? "we'll ping you gently" : "no reminders, no pressure")
                                .font(.system(size: 12, weight: .medium, design: .rounded))
                                .foregroundStyle(Theme.textSecondary)
                        }
                    }
                }
                .tint(Theme.accent)

                if reminderEnabled {
                    DatePicker("", selection: $reminderDate, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                        .datePickerStyle(.wheel)
                        .frame(maxHeight: 160)
                        .tint(Theme.accent)
                }
            }
            .padding(20)
            .crumbsCard()
            .padding(.horizontal, 24)

            Spacer()
        }
    }

    // MARK: - Step 4: finish

    @State private var finishAppear: Bool = false

    private var finishStep: some View {
        VStack(spacing: 28) {
            Spacer()

            CrumbsLogo(size: 130, isAnimating: true)
                .scaleEffect(finishAppear ? 1 : 0.6)
                .opacity(finishAppear ? 1 : 0)

            VStack(spacing: 12) {
                Text(name.isEmpty ? "you're all set" : "you're all set, \(name.lowercased())")
                    .font(.system(size: 30, weight: .black, design: .rounded))
                    .foregroundStyle(Theme.textPrimary)
                    .multilineTextAlignment(.center)
                    .tracking(-0.5)
                    .opacity(finishAppear ? 1 : 0)
                    .offset(y: finishAppear ? 0 : 12)

                Text("ready to drop your first crumb?")
                    .font(.system(size: 16, weight: .regular, design: .rounded))
                    .foregroundStyle(Theme.textSecondary)
                    .multilineTextAlignment(.center)
                    .opacity(finishAppear ? 1 : 0)
                    .offset(y: finishAppear ? 0 : 12)
            }
            .padding(.horizontal, 24)

            Spacer()
        }
        .onAppear {
            finishAppear = false
            withAnimation(.spring(response: 0.7, dampingFraction: 0.8).delay(0.1)) {
                finishAppear = true
            }
        }
    }

    // MARK: - Header helper

    private func stepHeader(eyebrow: String, title: String, subtitle: String) -> some View {
        VStack(spacing: 8) {
            Text(eyebrow)
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundStyle(Theme.accent)
                .tracking(1.5)

            Text(title)
                .font(.system(size: 26, weight: .bold, design: .rounded))
                .foregroundStyle(Theme.textPrimary)
                .multilineTextAlignment(.center)

            Text(subtitle)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundStyle(Theme.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 24)
    }

    // MARK: - Bottom bar

    private var bottomBar: some View {
        HStack {
            if step > 0 {
                Button {
                    Haptics.tap()
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                        step -= 1
                    }
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(Theme.textSecondary.opacity(0.7))
                        .frame(width: 48, height: 48)
                }
            }

            Spacer()

            Button(action: handlePrimary) {
                HStack(spacing: 8) {
                    Text(primaryLabel)
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                    Image(systemName: "arrow.right")
                        .font(.system(size: 13, weight: .bold))
                }
                .foregroundStyle(canAdvance ? Theme.accent : Theme.heartEmpty)
                .padding(.horizontal, 22)
                .padding(.vertical, 14)
                .background(
                    Capsule()
                        .stroke(canAdvance ? Theme.accent : Theme.heartEmpty,
                                lineWidth: 1.2)
                )
                .shadow(color: canAdvance ? Theme.accent.opacity(0.4) : .clear,
                        radius: 14)
            }
            .disabled(!canAdvance)
            .animation(.easeInOut(duration: 0.2), value: canAdvance)
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 28)
        .padding(.top, 8)
    }

    private var primaryLabel: String {
        switch step {
        case 0: return "let's go"
        case Self.totalSteps - 1: return "drop my first crumb"
        default: return "continue"
        }
    }

    private var canAdvance: Bool {
        if step == 1 {
            return !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
        return true
    }

    // MARK: - Flow

    private func advance() {
        guard canAdvance else { return }
        Haptics.tap()
        if step == Self.totalSteps - 1 {
            finish()
        } else {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                step += 1
            }
        }
    }

    private func handlePrimary() {
        if step == 2 || step == 3 {
            // Persist as we go so the avatar/reminder updates feel committed.
            persistDraft()
        }
        if step == 3 && reminderEnabled {
            Task {
                await NotificationManager.requestAuthorization()
                advance()
            }
            return
        }
        advance()
    }

    private func persistDraft() {
        profileStore.profile.username = name.trimmingCharacters(in: .whitespacesAndNewlines)
        profileStore.profile.avatarIndex = avatarIndex
        if includeBirthday { profileStore.profile.birthday = birthday }
        profileStore.save()
    }

    private func finish() {
        Haptics.success()
        profileStore.profile.username = name.trimmingCharacters(in: .whitespacesAndNewlines)
        profileStore.profile.avatarIndex = avatarIndex
        if includeBirthday { profileStore.profile.birthday = birthday }
        profileStore.profile.reminderEnabled = reminderEnabled
        let comps = Calendar.current.dateComponents([.hour, .minute], from: reminderDate)
        profileStore.profile.reminderHour = comps.hour ?? 20
        profileStore.profile.reminderMinute = comps.minute ?? 0
        profileStore.profile.hasCompletedOnboarding = true
        profileStore.saveAndReschedule()
    }

    private static func defaultReminderDate() -> Date {
        var c = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        c.hour = 20
        c.minute = 0
        return Calendar.current.date(from: c) ?? Date()
    }
}
