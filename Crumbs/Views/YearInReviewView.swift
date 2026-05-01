import SwiftUI

struct YearInReviewView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(EntryStore.self) private var store
    @Environment(ProfileStore.self) private var profileStore

    let year: Int

    @State private var pageIndex: Int = 0

    private var yearEntries: [DailyEntry] {
        store.entries(forYear: year)
    }

    private var topArtist: (name: String, count: Int)? {
        let counts = Dictionary(grouping: yearEntries, by: { $0.songArtist })
            .mapValues { $0.count }
        guard let top = counts.max(by: { $0.value < $1.value }) else { return nil }
        return (top.key, top.value)
    }

    private var topSong: DailyEntry? {
        let counts = Dictionary(grouping: yearEntries, by: { "\($0.songTitle)|\($0.songArtist)" })
            .mapValues { $0.count }
        guard let top = counts.max(by: { $0.value < $1.value }) else { return nil }
        return yearEntries.first { "\($0.songTitle)|\($0.songArtist)" == top.key }
    }

    private var bestStreak: Int {
        store.longestStreak
    }

    private var totalCharacters: Int {
        yearEntries.reduce(0) { $0 + $1.win.count }
    }

    private var pages: [YearPage] {
        var p: [YearPage] = []
        p.append(.cover(year: year, name: profileStore.displayName))
        p.append(.bigStat(
            value: "\(yearEntries.count)",
            label: "crumbs dropped",
            sub: "out of \(daysInYear) days",
            colors: [Color(hex: "FF6B6B"), Color(hex: "F5A623")]
        ))
        p.append(.bigStat(
            value: "\(bestStreak)",
            label: "longest streak",
            sub: bestStreak >= 7 ? "you really showed up" : "every day counts",
            colors: [Color(hex: "F5A623"), Color(hex: "F5D020")]
        ))
        if let artist = topArtist {
            p.append(.topArtist(name: artist.name, count: artist.count))
        }
        if let song = topSong {
            p.append(.topSong(entry: song))
        }
        p.append(.bigStat(
            value: "\(totalCharacters)",
            label: "characters written",
            sub: "every word a tiny win",
            colors: [Color(hex: "43E97B"), Color(hex: "38F9D7")]
        ))
        p.append(.outro(year: year, count: yearEntries.count))
        return p
    }

    private var daysInYear: Int {
        let cal = Calendar.current
        var c = DateComponents(); c.year = year; c.month = 1; c.day = 1
        let start = cal.date(from: c)!
        return cal.range(of: .day, in: .year, for: start)?.count ?? 365
    }

    private var shareText: String {
        var t = "my \(year) in crumbs ✨\n\n"
        t += "\(yearEntries.count) crumbs dropped\n"
        t += "\(bestStreak) day longest streak\n"
        if let artist = topArtist { t += "top artist: \(artist.name)\n" }
        if let song = topSong { t += "top song: \(song.songTitle) — \(song.songArtist)\n" }
        t += "\nmade with crumbs"
        return t
    }

    var body: some View {
        NavigationStack {
            ZStack {
                pages[pageIndex].background

                VStack(spacing: 0) {
                    // Page progress
                    HStack(spacing: 4) {
                        ForEach(0..<pages.count, id: \.self) { i in
                            Capsule()
                                .fill(.white.opacity(i <= pageIndex ? 0.95 : 0.25))
                                .frame(height: 3)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 12)

                    Spacer()

                    pageContent
                        .padding(.horizontal, 32)
                        .transition(.opacity.combined(with: .scale(scale: 0.95)))
                        .id(pageIndex)

                    Spacer()

                    // Tap zones (no buttons; tap left/right to navigate)
                    HStack(spacing: 12) {
                        if pageIndex == pages.count - 1 {
                            ShareLink(item: shareText) {
                                HStack(spacing: 8) {
                                    Image(systemName: "square.and.arrow.up")
                                        .font(.system(size: 14, weight: .bold))
                                    Text("share")
                                        .font(.system(size: 15, weight: .bold, design: .rounded))
                                }
                                .foregroundStyle(.white)
                                .padding(.horizontal, 22)
                                .padding(.vertical, 14)
                                .background(Capsule().fill(.white.opacity(0.25)))
                            }
                            Button {
                                Haptics.tap()
                                dismiss()
                            } label: {
                                Text("done")
                                    .font(.system(size: 15, weight: .bold, design: .rounded))
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 22)
                                    .padding(.vertical, 14)
                                    .background(Capsule().fill(.white.opacity(0.18)))
                            }
                        }
                    }
                    .padding(.bottom, 28)
                }
            }
            .contentShape(Rectangle())
            .onTapGesture { location in
                handleTap(at: location)
            }
            .gesture(
                DragGesture(minimumDistance: 30)
                    .onEnded { value in
                        if value.translation.width < -50 { advance() }
                        else if value.translation.width > 50 { retreat() }
                    }
            )
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        Haptics.tap()
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(.white)
                            .padding(8)
                            .background(Circle().fill(.white.opacity(0.2)))
                    }
                }
            }
            .toolbarBackground(.hidden, for: .navigationBar)
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    @ViewBuilder
    private var pageContent: some View {
        switch pages[pageIndex] {
        case .cover(let y, let name):
            VStack(spacing: 18) {
                Text("✨")
                    .font(.system(size: 64))
                Text("your \(String(y))")
                    .font(.system(size: 32, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.9))
                Text("in crumbs")
                    .font(.system(size: 56, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                Text(name)
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.85))
                    .padding(.top, 8)
                Text("tap anywhere to begin")
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.6))
                    .padding(.top, 24)
            }

        case .bigStat(let value, let label, let sub, _):
            VStack(spacing: 14) {
                Text(value)
                    .font(.system(size: 110, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
                Text(label)
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                Text(sub)
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
            }

        case .topArtist(let name, let count):
            VStack(spacing: 14) {
                Text("YOUR TOP ARTIST")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.85))
                    .tracking(2)
                Text(name)
                    .font(.system(size: 44, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.5)
                Text("\(count) crumb\(count == 1 ? "" : "s") this year")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.85))
            }

        case .topSong(let entry):
            VStack(spacing: 18) {
                Text("YOUR TOP SONG")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.85))
                    .tracking(2)

                if let art = entry.artworkURL, let url = URL(string: art) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let img): img.resizable().aspectRatio(contentMode: .fill)
                        default: RoundedRectangle(cornerRadius: 18, style: .continuous).fill(.white.opacity(0.15))
                        }
                    }
                    .frame(width: 200, height: 200)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .shadow(color: .black.opacity(0.25), radius: 20, y: 10)
                }

                VStack(spacing: 6) {
                    Text(entry.songTitle)
                        .font(.system(size: 26, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                    Text(entry.songArtist)
                        .font(.system(size: 17, weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.85))
                }
            }

        case .outro(let y, let count):
            VStack(spacing: 16) {
                Text("🌱")
                    .font(.system(size: 60))
                Text("\(count) days you showed up\nin \(String(y))")
                    .font(.system(size: 30, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .lineSpacing(2)
                Text("here's to next year ✨")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.85))
                    .padding(.top, 8)
            }
        }
    }

    private func advance() {
        guard pageIndex < pages.count - 1 else { return }
        Haptics.tap()
        withAnimation(.easeInOut(duration: 0.35)) { pageIndex += 1 }
    }

    private func retreat() {
        guard pageIndex > 0 else { return }
        Haptics.tap()
        withAnimation(.easeInOut(duration: 0.35)) { pageIndex -= 1 }
    }

    private func handleTap(at location: CGPoint) {
        let screenWidth = UIScreen.main.bounds.width
        if location.x < screenWidth / 3 {
            retreat()
        } else {
            advance()
        }
    }
}

// MARK: - Page model

enum YearPage {
    case cover(year: Int, name: String)
    case bigStat(value: String, label: String, sub: String, colors: [Color])
    case topArtist(name: String, count: Int)
    case topSong(entry: DailyEntry)
    case outro(year: Int, count: Int)

    var background: some View {
        let colors: [Color] = {
            switch self {
            case .cover:
                return [Color(hex: "C94B8C"), Color(hex: "E8735A"), Color(hex: "F5A623")]
            case .bigStat(_, _, _, let cs):
                return cs.count >= 2 ? cs : [Color(hex: "E8735A"), Color(hex: "F5A623")]
            case .topArtist:
                return [Color(hex: "7B68EE"), Color(hex: "E040FB")]
            case .topSong:
                return [Color(hex: "4FACFE"), Color(hex: "00F2FE"), Color(hex: "7B68EE")]
            case .outro:
                return [Color(hex: "43E97B"), Color(hex: "38F9D7")]
            }
        }()
        return LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing)
            .ignoresSafeArea()
    }
}
