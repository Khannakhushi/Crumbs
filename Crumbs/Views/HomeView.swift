import SwiftUI

struct HomeView: View {
    @Environment(EntryStore.self) private var store
    @Environment(ProfileStore.self) private var profileStore
    @Environment(\.colorScheme) private var scheme
    @State private var winText = ""
    @State private var selectedTrack: MusicTrack?
    @State private var showSaved = false
    @State private var showSongSearch = false
    @State private var editing = false

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        let name = profileStore.displayName
        switch hour {
        case 5..<12:  return "good morning, \(name)"
        case 12..<17: return "good afternoon, \(name)"
        case 17..<21: return "good evening, \(name)"
        default:      return "hey, \(name)"
        }
    }

    private var greetingIcon: (String, [Color]) {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12:  return ("sparkles", [Color(hex: "FFD700"), Color(hex: "FF6B6B")])
        case 12..<17: return ("sun.max.fill", [Color(hex: "F5A623"), Color(hex: "F5D020")])
        case 17..<21: return ("moon.stars.fill", [Color(hex: "A18CD1"), Color(hex: "FBC2EB")])
        default:      return ("moon.fill", [Color(hex: "7B68EE"), Color(hex: "4FACFE")])
        }
    }

    private var dateString: String {
        let f = DateFormatter()
        f.dateFormat = "EEEE, MMMM d"
        return f.string(from: Date()).lowercased()
    }

    private var canSave: Bool {
        !winText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && selectedTrack != nil
    }

    var body: some View {
        ZStack {
            AmbientBackground()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 28) {
                    header
                    if store.currentStreak > 0 { streakCard }
                    if let entry = store.todayEntry, !editing {
                        todayCard(entry)
                    } else {
                        inputCard
                    }
                    Spacer(minLength: 60)
                }
                .padding(.horizontal, 20)
            }

            if showSaved {
                savedOverlay
                    .transition(.scale(scale: 0.8).combined(with: .opacity))
                    .zIndex(10)
            }
        }
        .sheet(isPresented: $showSongSearch) {
            SongSearchView { track in
                selectedTrack = track
            }
            .presentationDetents([.large])
            .presentationCornerRadius(32)
        }
    }

    // MARK: - Header

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 12) {
                let (icon, colors) = greetingIcon
                GradientIcon(symbol: icon, colors: colors, size: 16, bgSize: 38)

                Text(dateString)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(Theme.textSecondary)
                    .textCase(.uppercase)
                    .tracking(1)
            }

            Text(greeting)
                .font(.system(size: 30, weight: .bold, design: .rounded))
                .foregroundStyle(Theme.textPrimary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 16)
    }

    // MARK: - Streak

    private var streakCard: some View {
        HStack(spacing: 16) {
            GradientIcon(symbol: "flame.fill",
                         colors: [Color(hex: "FF6B6B"), Color(hex: "F5A623")],
                         size: 22, bgSize: 52)

            VStack(alignment: .leading, spacing: 6) {
                Text("\(store.currentStreak) day streak")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(Theme.textPrimary)

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule().fill(Theme.heartEmpty).frame(height: 6)
                        Capsule().fill(Theme.warmGradient)
                            .frame(width: min(geo.size.width, geo.size.width * CGFloat(store.currentStreak) / max(CGFloat(store.longestStreak), 1)), height: 6)
                    }
                }
                .frame(height: 6)

                Text("longest: \(store.longestStreak) days")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(Theme.textSecondary)
            }
        }
        .padding(18)
        .crumbsCard()
    }

    // MARK: - Today's entry

    private func todayCard(_ entry: DailyEntry) -> some View {
        VStack(spacing: 0) {
            // Album art hero
            if let artURL = entry.artworkURL, let url = URL(string: artURL) {
                ZStack(alignment: .bottomLeading) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let img):
                            img.resizable().aspectRatio(contentMode: .fill)
                        default:
                            Rectangle().fill(Theme.cardBgElevated)
                        }
                    }
                    .frame(height: 220)
                    .clipped()
                    .overlay {
                        LinearGradient(
                            colors: [.clear, .clear, .black.opacity(0.75)],
                            startPoint: .top, endPoint: .bottom
                        )
                    }

                    HStack(alignment: .bottom) {
                        VStack(alignment: .leading, spacing: 3) {
                            Text(entry.songTitle)
                                .font(.system(size: 22, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)
                            Text(entry.songArtist)
                                .font(.system(size: 15, weight: .medium, design: .rounded))
                                .foregroundStyle(.white.opacity(0.8))
                        }

                        Spacer()

                        Image(systemName: "music.note")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(.white.opacity(0.6))
                            .padding(10)
                            .background(Circle().fill(.white.opacity(0.15)))
                    }
                    .padding(22)
                }
            } else {
                // Fallback gradient header
                ZStack(alignment: .bottomLeading) {
                    Rectangle()
                        .fill(Theme.warmGradient)
                        .frame(height: 130)

                    HStack(spacing: 12) {
                        Image(systemName: "music.note")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(.white)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(entry.songTitle)
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)
                            Text(entry.songArtist)
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundStyle(.white.opacity(0.8))
                        }
                    }
                    .padding(22)
                }
            }

            // Win
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    HStack(spacing: 8) {
                        Image(systemName: "heart.fill")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(Theme.accent)
                        Text("TODAY'S CRUMB")
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundStyle(Theme.accent)
                            .tracking(1.5)
                    }

                    Spacer()

                    Button {
                        winText = entry.win
                        selectedTrack = nil
                        editing = true
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "pencil")
                                .font(.system(size: 11, weight: .bold))
                            Text("edit")
                                .font(.system(size: 13, weight: .semibold, design: .rounded))
                        }
                        .foregroundStyle(Theme.textSecondary)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 7)
                        .background(Capsule().fill(Theme.inputBg))
                    }
                }

                Text(entry.win)
                    .font(.system(size: 17, weight: .regular, design: .rounded))
                    .foregroundStyle(Theme.textPrimary)
                    .lineSpacing(5)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(22)
        }
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .crumbsCard()
    }

    // MARK: - Input card

    private var inputCard: some View {
        VStack(alignment: .leading, spacing: 24) {
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: editing ? "pencil" : "plus")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(Theme.accent)
                    Text(editing ? "EDIT YOUR CRUMB" : "DROP A CRUMB")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundStyle(Theme.accent)
                        .tracking(1.5)
                }

                Spacer()

                if !editing {
                    GradientIcon(symbol: "pencil.line",
                                 colors: [Color(hex: "A18CD1"), Color(hex: "FBC2EB")],
                                 size: 12, bgSize: 30)
                }
            }

            // Win input
            VStack(alignment: .leading, spacing: 10) {
                Text("what's your small win today?")
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(Theme.textPrimary)

                TextField("i finally finished that book...", text: $winText, axis: .vertical)
                    .lineLimit(3...6)
                    .font(.system(size: 16, weight: .regular, design: .rounded))
                    .foregroundStyle(Theme.textPrimary)
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(Theme.inputBg)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .stroke(Theme.divider, lineWidth: 1)
                            )
                    )
            }

            // Song picker
            VStack(alignment: .leading, spacing: 10) {
                Text("pick your mood song")
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(Theme.textPrimary)

                if let track = selectedTrack {
                    selectedSongRow(track)
                } else {
                    searchButton
                }
            }

            // Save
            Button(action: saveEntry) {
                HStack(spacing: 8) {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 14, weight: .semibold))
                    Text(editing ? "update crumb" : "save crumb")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(canSave
                              ? AnyShapeStyle(Theme.warmGradient)
                              : AnyShapeStyle(Theme.heartEmpty))
                )
            }
            .disabled(!canSave)
            .animation(.easeInOut(duration: 0.2), value: canSave)

            if editing {
                Button {
                    editing = false
                    clearInputs()
                } label: {
                    Text("cancel")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundStyle(Theme.textSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                }
            }
        }
        .padding(22)
        .crumbsCard()
    }

    // MARK: - Song UI

    private func selectedSongRow(_ track: MusicTrack) -> some View {
        HStack(spacing: 14) {
            if let url = track.artworkMedium, let imgURL = URL(string: url) {
                AsyncImage(url: imgURL) { phase in
                    switch phase {
                    case .success(let img): img.resizable().aspectRatio(contentMode: .fill)
                    default: RoundedRectangle(cornerRadius: 12, style: .continuous).fill(Theme.inputBg)
                    }
                }
                .frame(width: 56, height: 56)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(track.trackName)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundStyle(Theme.textPrimary).lineLimit(1)
                Text(track.artistName)
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundStyle(Theme.textSecondary).lineLimit(1)
            }

            Spacer()

            Button { showSongSearch = true } label: {
                Image(systemName: "arrow.triangle.2.circlepath")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Theme.accent)
                    .padding(10)
                    .background(Circle().fill(Theme.accentSoft))
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Theme.inputBg)
                .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(Theme.divider, lineWidth: 1))
        )
    }

    private var searchButton: some View {
        Button { showSongSearch = true } label: {
            HStack(spacing: 12) {
                GradientIcon(symbol: "music.note",
                             colors: [Color(hex: "E8735A"), Color(hex: "F5A623")],
                             size: 16, bgSize: 44)

                VStack(alignment: .leading, spacing: 2) {
                    Text("search for a song")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundStyle(Theme.textPrimary)
                    Text("find what matches your mood")
                        .font(.system(size: 13, weight: .regular, design: .rounded))
                        .foregroundStyle(Theme.textSecondary)
                }

                Spacer()

                Image(systemName: "magnifyingglass")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(Theme.textSecondary)
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Theme.inputBg)
                    .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(Theme.divider, lineWidth: 1))
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Saved overlay

    private var savedOverlay: some View {
        VStack(spacing: 16) {
            GradientIcon(symbol: "heart.fill",
                         colors: [Color(hex: "FF6B6B"), Color(hex: "F5A623")],
                         size: 32, bgSize: 76)

            Text("crumb saved!")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundStyle(Theme.textPrimary)

            Text("you showed up today")
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundStyle(Theme.textSecondary)
        }
        .padding(40)
        .background(
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.15), radius: 30, y: 10)
        )
    }

    // MARK: - Actions

    private func saveEntry() {
        guard let track = selectedTrack else { return }
        let entry = DailyEntry(
            date: Date(),
            win: winText.trimmingCharacters(in: .whitespacesAndNewlines),
            songTitle: track.trackName,
            songArtist: track.artistName,
            artworkURL: track.artworkLarge,
            albumName: track.collectionName
        )
        store.addEntry(entry)
        clearInputs()
        editing = false
        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) { showSaved = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
            withAnimation(.easeOut(duration: 0.3)) { showSaved = false }
        }
    }

    private func clearInputs() { winText = ""; selectedTrack = nil }
}
