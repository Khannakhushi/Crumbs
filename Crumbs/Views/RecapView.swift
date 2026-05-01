import SwiftUI

struct RecapView: View {
    @Environment(EntryStore.self) private var store
    @Environment(\.colorScheme) private var scheme
    @State private var selectedMonth = Calendar.current.component(.month, from: Date())
    @State private var selectedYear = Calendar.current.component(.year, from: Date())
    @State private var showingYearInReview = false

    private let cal = Calendar.current

    private var monthName: String {
        let f = DateFormatter(); f.dateFormat = "MMMM"
        var c = DateComponents(); c.month = selectedMonth; c.year = selectedYear; c.day = 1
        return f.string(from: cal.date(from: c)!).lowercased()
    }

    private var monthEntries: [DailyEntry] {
        store.entries(forMonth: selectedMonth, year: selectedYear)
    }

    private var daysInMonth: Int {
        var c = DateComponents(); c.month = selectedMonth; c.year = selectedYear; c.day = 1
        return cal.range(of: .day, in: .month, for: cal.date(from: c)!)!.count
    }

    private var shareText: String {
        var t = "my \(monthName) recap\n\n"
        t += "\(monthEntries.count) crumbs dropped\n"
        t += "longest streak: \(store.longestStreak) days\n\n"
        let df = DateFormatter(); df.dateFormat = "MMM d"
        for e in monthEntries { t += "- \(df.string(from: e.date)): \(e.win)\n" }
        t += "\nmy mood mix:\n"
        for (i, e) in monthEntries.enumerated() { t += "\(i + 1). \(e.songTitle) \u{2013} \(e.songArtist)\n" }
        t += "\nmade with crumbs"
        return t
    }

    var body: some View {
        ZStack {
            AmbientBackground()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    header
                    yearInReviewCTA
                    monthPicker

                    if monthEntries.isEmpty {
                        emptyState
                    } else {
                        overviewCard
                        winsTimeline
                        moodMix
                        shareButton
                    }

                    Spacer(minLength: 60)
                }
                .padding(.horizontal, 20)
            }
        }
        .fullScreenCover(isPresented: $showingYearInReview) {
            YearInReviewView(year: selectedYear)
        }
    }

    // MARK: - Year in Review CTA

    private var yearInReviewCTA: some View {
        Button {
            Haptics.tap()
            showingYearInReview = true
        } label: {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(LinearGradient(
                            colors: [Color(hex: "C94B8C"), Color(hex: "F5A623")],
                            startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 48, height: 48)
                    Image(systemName: "sparkles")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(.white)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text("your \(String(selectedYear)) in crumbs")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundStyle(Theme.textPrimary)
                    Text("the wrapped-up version")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(Theme.textSecondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(Theme.textSecondary)
            }
            .padding(16)
            .crumbsCard(cornerRadius: 20)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Header

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 12) {
                GradientIcon(symbol: "sparkles",
                             colors: [Color(hex: "FFD700"), Color(hex: "FF6B6B")],
                             size: 16, bgSize: 38)

                Text("RECAP")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(Theme.textSecondary)
                    .tracking(1.5)
            }

            Text("\(monthName) in review")
                .font(.system(size: 30, weight: .bold, design: .rounded))
                .foregroundStyle(Theme.textPrimary)

            Text("look how far you've come")
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundStyle(Theme.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 16)
    }

    // MARK: - Month picker

    private var monthPicker: some View {
        HStack {
            Button { withAnimation { prevMonth() } } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(Theme.accent)
                    .padding(10)
                    .background(Circle().fill(Theme.accentSoft))
            }
            Spacer()
            Text("\(monthName) \(String(selectedYear))")
                .font(.system(size: 17, weight: .bold, design: .rounded))
                .foregroundStyle(Theme.textPrimary)
            Spacer()
            Button { withAnimation { nextMonth() } } label: {
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(Theme.accent)
                    .padding(10)
                    .background(Circle().fill(Theme.accentSoft))
            }
        }
    }

    // MARK: - Overview

    private var overviewCard: some View {
        VStack(spacing: 20) {
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text("\(monthEntries.count)")
                    .font(.system(size: 56, weight: .bold, design: .rounded))
                    .foregroundStyle(Theme.accent)
                Text("/ \(daysInMonth)")
                    .font(.system(size: 24, weight: .medium, design: .rounded))
                    .foregroundStyle(Theme.textSecondary)
            }

            Text("days you showed up")
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundStyle(Theme.textSecondary)

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Theme.heartEmpty).frame(height: 8)
                    Capsule().fill(Theme.warmGradient)
                        .frame(width: geo.size.width * CGFloat(monthEntries.count) / CGFloat(max(daysInMonth, 1)), height: 8)
                }
            }
            .frame(height: 8)

            Divider().overlay(Theme.divider)

            HStack(spacing: 0) {
                overviewStat(icon: "star.fill", colors: [Color(hex: "F5A623"), Color(hex: "F5D020")],
                             value: "\(store.longestStreak)", label: "best streak")
                overviewStat(icon: "music.note", colors: [Color(hex: "7B68EE"), Color(hex: "E040FB")],
                             value: "\(monthEntries.count)", label: "songs")
                overviewStat(icon: "character.cursor.ibeam", colors: [Color(hex: "43E97B"), Color(hex: "38F9D7")],
                             value: "\(monthEntries.reduce(0) { $0 + $1.win.count })", label: "characters")
            }
        }
        .padding(24)
        .crumbsCard()
    }

    private func overviewStat(icon: String, colors: [Color], value: String, label: String) -> some View {
        VStack(spacing: 6) {
            GradientIcon(symbol: icon, colors: colors, size: 12, bgSize: 28)
            Text(value)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(Theme.textPrimary)
            Text(label)
                .font(.system(size: 10, weight: .bold, design: .rounded))
                .foregroundStyle(Theme.textSecondary)
                .textCase(.uppercase)
                .tracking(0.3)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Wins timeline

    private var winsTimeline: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 8) {
                Image(systemName: "heart.fill")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(Theme.accent)
                Text("YOUR WINS")
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundStyle(Theme.accent)
                    .tracking(1.5)
            }
            .padding(.bottom, 20)

            ForEach(Array(monthEntries.enumerated()), id: \.element.id) { index, entry in
                HStack(alignment: .top, spacing: 16) {
                    VStack(spacing: 0) {
                        Circle().fill(Theme.accent).frame(width: 10, height: 10).padding(.top, 5)
                        if index < monthEntries.count - 1 {
                            Rectangle().fill(Theme.divider).frame(width: 2)
                        }
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        let df = DateFormatter()
                        let _ = df.dateFormat = "MMM d"
                        Text(df.string(from: entry.date).lowercased())
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .foregroundStyle(Theme.textSecondary)
                            .textCase(.uppercase).tracking(0.8)

                        Text(entry.win)
                            .font(.system(size: 15, weight: .regular, design: .rounded))
                            .foregroundStyle(Theme.textPrimary)
                            .lineSpacing(4)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(.bottom, 24)
                }
            }
        }
        .padding(22)
        .crumbsCard()
    }

    // MARK: - Mood mix

    private var moodMix: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 8) {
                        Image(systemName: "music.note.list")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(Theme.accent)
                        Text("YOUR MOOD MIX")
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundStyle(Theme.accent)
                            .tracking(1.5)
                    }
                    Text("\(monthEntries.count) songs")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(Theme.textSecondary)
                }
                Spacer()
                GradientIcon(symbol: "music.note.list",
                             colors: [Color(hex: "7B68EE"), Color(hex: "E040FB")],
                             size: 14, bgSize: 34)
            }

            ForEach(Array(monthEntries.enumerated()), id: \.element.id) { i, entry in
                HStack(spacing: 14) {
                    Text(String(format: "%02d", i + 1))
                        .font(.system(size: 13, weight: .bold, design: .monospaced))
                        .foregroundStyle(Theme.textSecondary)
                        .frame(width: 24)

                    if let artURL = entry.artworkURL, let url = URL(string: artURL) {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .success(let img): img.resizable().aspectRatio(contentMode: .fill)
                            default: gradientArt(for: i)
                            }
                        }
                        .frame(width: 48, height: 48)
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    } else {
                        gradientArt(for: i)
                    }

                    VStack(alignment: .leading, spacing: 3) {
                        Text(entry.songTitle)
                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                            .foregroundStyle(Theme.textPrimary).lineLimit(1)
                        Text(entry.songArtist)
                            .font(.system(size: 13, weight: .regular, design: .rounded))
                            .foregroundStyle(Theme.textSecondary).lineLimit(1)
                    }
                    Spacer()
                }
                .padding(.vertical, 4)

                if i < monthEntries.count - 1 {
                    Divider().overlay(Theme.divider.opacity(0.5)).padding(.leading, 86)
                }
            }
        }
        .padding(22)
        .crumbsCard()
    }

    private func gradientArt(for index: Int) -> some View {
        let colors = Theme.artGradients[index % Theme.artGradients.count]
        return RoundedRectangle(cornerRadius: 10, style: .continuous)
            .fill(LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing))
            .frame(width: 48, height: 48)
            .overlay {
                Image(systemName: "music.note")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(.white.opacity(0.9))
            }
    }

    // MARK: - Share

    private var shareButton: some View {
        ShareLink(item: shareText) {
            HStack(spacing: 10) {
                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: 15, weight: .semibold))
                Text("share your recap")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Theme.warmGradient)
            )
        }
    }

    // MARK: - Empty

    private var emptyState: some View {
        VStack(spacing: 20) {
            GradientIcon(symbol: "leaf.fill",
                         colors: [Color(hex: "43E97B"), Color(hex: "38F9D7")],
                         size: 28, bgSize: 72)

            Text("no crumbs yet")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundStyle(Theme.textPrimary)

            Text("start dropping crumbs to see\nyour journey unfold here")
                .font(.system(size: 15, weight: .regular, design: .rounded))
                .foregroundStyle(Theme.textSecondary)
                .multilineTextAlignment(.center).lineSpacing(4)
        }
        .padding(48)
        .frame(maxWidth: .infinity)
        .crumbsCard()
    }

    private func prevMonth() {
        if selectedMonth == 1 { selectedMonth = 12; selectedYear -= 1 } else { selectedMonth -= 1 }
    }

    private func nextMonth() {
        if selectedMonth == 12 { selectedMonth = 1; selectedYear += 1 } else { selectedMonth += 1 }
    }
}
