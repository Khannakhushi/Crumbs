import SwiftUI

struct SongSearchView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var scheme
    @State private var music = MusicService()
    @State private var query = ""
    @FocusState private var focused: Bool

    var onSelect: (MusicTrack) -> Void

    var body: some View {
        NavigationStack {
            ZStack {
                AmbientBackground()

                VStack(spacing: 0) {
                    searchBar
                    resultsList
                }
            }
            .navigationTitle("pick your mood song")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("cancel") {
                        music.stopPreview()
                        dismiss()
                    }
                    .foregroundStyle(Theme.textSecondary)
                }
            }
            .toolbarBackground(Theme.bg.opacity(0.8), for: .navigationBar)
        }
        .onAppear {
            focused = true
            music.fetchTrending()
        }
        .onDisappear { music.stopPreview() }
    }

    // MARK: - Search bar

    private var searchBar: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(Theme.textSecondary)

            TextField("search songs, artists...", text: $query)
                .font(.system(size: 17, weight: .regular, design: .rounded))
                .foregroundStyle(Theme.textPrimary)
                .focused($focused)
                .autocorrectionDisabled()
                .onChange(of: query) { _, new in
                    music.search(new)
                }

            if !query.isEmpty {
                Button {
                    query = ""
                    music.results = []
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(Theme.textSecondary)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Theme.cardBg)
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Theme.divider, lineWidth: 1)
                )
        )
        .padding(.horizontal, 20)
        .padding(.top, 8)
        .padding(.bottom, 12)
    }

    // MARK: - Results

    private var resultsList: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: 2) {
                if music.isSearching {
                    loadingState
                } else if query.isEmpty {
                    emptyPrompt
                } else if music.results.isEmpty {
                    noResults
                } else {
                    ForEach(music.results) { track in
                        trackRow(track)
                    }
                }
            }
            .padding(.horizontal, 20)
        }
    }

    // MARK: - Track row

    private func trackRow(_ track: MusicTrack) -> some View {
        let isPlaying = music.playingTrackId == track.id

        return HStack(spacing: 14) {
            // Album art with play overlay
            ZStack {
                if let url = track.artworkMedium, let imgURL = URL(string: url) {
                    AsyncImage(url: imgURL) { phase in
                        switch phase {
                        case .success(let image):
                            image.resizable().aspectRatio(contentMode: .fill)
                        case .failure:
                            artPlaceholder
                        default:
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(Theme.cardBgElevated)
                                .overlay { ProgressView().tint(Theme.textSecondary).scaleEffect(0.6) }
                        }
                    }
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                } else {
                    artPlaceholder
                }

                // Play/pause overlay
                if track.previewUrl != nil {
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            music.togglePreview(for: track)
                        }
                    } label: {
                        Circle()
                            .fill(.black.opacity(isPlaying ? 0.5 : 0.3))
                            .frame(width: 32, height: 32)
                            .overlay {
                                Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundStyle(.white)
                                    .offset(x: isPlaying ? 0 : 1)
                            }
                    }
                }
            }
            .frame(width: 60, height: 60)

            // Info
            VStack(alignment: .leading, spacing: 3) {
                Text(track.trackName)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundStyle(isPlaying ? Theme.accent : Theme.textPrimary)
                    .lineLimit(1)

                Text(track.artistName)
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundStyle(Theme.textSecondary)
                    .lineLimit(1)

                if let album = track.collectionName {
                    Text(album)
                        .font(.system(size: 12, weight: .regular, design: .rounded))
                        .foregroundStyle(Theme.textSecondary.opacity(0.6))
                        .lineLimit(1)
                }
            }

            Spacer()

            // Add button
            Button {
                music.stopPreview()
                onSelect(track)
            } label: {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(Theme.accent)
            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 4)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(isPlaying ? Theme.accentSoft : .clear)
        )
    }

    private var artPlaceholder: some View {
        RoundedRectangle(cornerRadius: 12, style: .continuous)
            .fill(Theme.cardBgElevated)
            .frame(width: 60, height: 60)
            .overlay {
                Image(systemName: "music.note")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundStyle(Theme.textSecondary)
            }
    }

    // MARK: - States

    private var loadingState: some View {
        VStack(spacing: 16) {
            ProgressView().tint(Theme.accent).padding(.top, 40)
            Text("searching...")
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundStyle(Theme.textSecondary)
        }
    }

    private var emptyPrompt: some View {
        VStack(alignment: .leading, spacing: 16) {
            if music.isLoadingTrending {
                VStack(spacing: 14) {
                    ProgressView().tint(Theme.accent).padding(.top, 40)
                    Text("loading top songs...")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundStyle(Theme.textSecondary)
                }
                .frame(maxWidth: .infinity)
            } else if !music.trendingSongs.isEmpty {
                HStack(spacing: 10) {
                    GradientIcon(symbol: "chart.line.uptrend.xyaxis",
                                 colors: [Color(hex: "FA709A"), Color(hex: "FEE140")],
                                 size: 14, bgSize: 34)

                    Text("TOP SONGS RIGHT NOW")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundStyle(Theme.textSecondary)
                        .tracking(1.5)
                }
                .padding(.top, 8)

                ForEach(Array(music.trendingSongs.enumerated()), id: \.element.id) { i, track in
                    trendingRow(track, rank: i + 1)
                }
            } else {
                VStack(spacing: 16) {
                    GradientIcon(symbol: "music.note.list",
                                 colors: [Color(hex: "A18CD1"), Color(hex: "FBC2EB")],
                                 size: 28, bgSize: 64)
                        .padding(.top, 60)

                    Text("what's the vibe today?")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundStyle(Theme.textPrimary)

                    Text("search for a song that matches your mood")
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .foregroundStyle(Theme.textSecondary)
                }
                .frame(maxWidth: .infinity)
            }
        }
    }

    private func trendingRow(_ track: MusicTrack, rank: Int) -> some View {
        Button {
            music.stopPreview()
            onSelect(track)
        } label: {
            HStack(spacing: 14) {
                Text("\(rank)")
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundStyle(rank <= 3 ? Theme.accent : Theme.textSecondary)
                    .frame(width: 24)

                if let url = track.artworkMedium, let imgURL = URL(string: url) {
                    AsyncImage(url: imgURL) { phase in
                        switch phase {
                        case .success(let img):
                            img.resizable().aspectRatio(contentMode: .fill)
                        default:
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(Theme.cardBgElevated)
                        }
                    }
                    .frame(width: 52, height: 52)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                } else {
                    let colors = Theme.artGradients[rank % Theme.artGradients.count]
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 52, height: 52)
                        .overlay {
                            Image(systemName: "music.note")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundStyle(.white.opacity(0.9))
                        }
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(track.trackName)
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundStyle(Theme.textPrimary)
                        .lineLimit(1)

                    Text(track.artistName)
                        .font(.system(size: 13, weight: .regular, design: .rounded))
                        .foregroundStyle(Theme.textSecondary)
                        .lineLimit(1)
                }

                Spacer()

                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 24))
                    .foregroundStyle(Theme.accent)
            }
            .padding(.vertical, 8)
        }
        .buttonStyle(.plain)
    }

    private var noResults: some View {
        VStack(spacing: 14) {
            GradientIcon(symbol: "questionmark.circle",
                         colors: [Color(hex: "FFD700"), Color(hex: "FF6B6B")],
                         size: 24, bgSize: 56)
                .padding(.top, 60)

            Text("no songs found")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(Theme.textPrimary)

            Text("try a different search")
                .font(.system(size: 14, weight: .regular, design: .rounded))
                .foregroundStyle(Theme.textSecondary)
        }
    }
}
