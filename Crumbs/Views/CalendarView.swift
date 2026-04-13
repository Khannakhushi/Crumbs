import SwiftUI

struct CalendarView: View {
    @Environment(EntryStore.self) private var store
    @Environment(\.colorScheme) private var scheme
    @State private var selectedMonth = Calendar.current.component(.month, from: Date())
    @State private var selectedYear = Calendar.current.component(.year, from: Date())
    @State private var selectedEntry: DailyEntry?

    private let cal = Calendar.current
    private let dayLabels = ["S", "M", "T", "W", "T", "F", "S"]

    private var monthTitle: String {
        let f = DateFormatter(); f.dateFormat = "MMMM yyyy"
        var c = DateComponents(); c.month = selectedMonth; c.year = selectedYear; c.day = 1
        return f.string(from: cal.date(from: c)!).lowercased()
    }

    private var daysInMonth: Int {
        var c = DateComponents(); c.month = selectedMonth; c.year = selectedYear; c.day = 1
        return cal.range(of: .day, in: .month, for: cal.date(from: c)!)!.count
    }

    private var firstWeekday: Int {
        var c = DateComponents(); c.month = selectedMonth; c.year = selectedYear; c.day = 1
        return cal.component(.weekday, from: cal.date(from: c)!) - 1
    }

    private func dateFor(day: Int) -> Date {
        var c = DateComponents(); c.month = selectedMonth; c.year = selectedYear; c.day = day
        return cal.date(from: c)!
    }

    private var isCurrentMonth: Bool {
        selectedMonth == cal.component(.month, from: Date()) &&
        selectedYear == cal.component(.year, from: Date())
    }

    private var monthEntryCount: Int {
        store.entries(forMonth: selectedMonth, year: selectedYear).count
    }

    var body: some View {
        ZStack {
            AmbientBackground()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    header
                    statsRow
                    monthNav
                    calendarGrid
                    Spacer(minLength: 60)
                }
                .padding(.horizontal, 20)
            }
        }
        .sheet(item: $selectedEntry) { entry in
            entrySheet(entry)
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(32)
        }
    }

    // MARK: - Header

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 12) {
                GradientIcon(symbol: "heart.circle.fill",
                             colors: [Color(hex: "FA709A"), Color(hex: "FEE140")],
                             size: 16, bgSize: 38)

                Text("YOUR TRAIL")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(Theme.textSecondary)
                    .tracking(1.5)
            }

            Text("every heart is a day\nyou showed up")
                .font(.system(size: 30, weight: .bold, design: .rounded))
                .foregroundStyle(Theme.textPrimary)
                .lineSpacing(2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 16)
    }

    // MARK: - Stats

    private var statsRow: some View {
        HStack(spacing: 12) {
            statPill(icon: "flame.fill", colors: [Color(hex: "FF6B6B"), Color(hex: "F5A623")],
                     value: store.currentStreak, label: "current")
            statPill(icon: "star.fill", colors: [Color(hex: "F5A623"), Color(hex: "F5D020")],
                     value: store.longestStreak, label: "longest")
            statPill(icon: "heart.fill", colors: [Color(hex: "FA709A"), Color(hex: "FEE140")],
                     value: monthEntryCount, label: "month")
        }
    }

    private func statPill(icon: String, colors: [Color], value: Int, label: String) -> some View {
        VStack(spacing: 8) {
            GradientIcon(symbol: icon, colors: colors, size: 14, bgSize: 34)

            Text("\(value)")
                .font(.system(size: 26, weight: .bold, design: .rounded))
                .foregroundStyle(Theme.textPrimary)

            Text(label)
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundStyle(Theme.textSecondary)
                .textCase(.uppercase)
                .tracking(0.5)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 18)
        .crumbsCard(cornerRadius: 20)
    }

    // MARK: - Month nav

    private var monthNav: some View {
        HStack {
            Button { withAnimation(.easeInOut(duration: 0.2)) { prevMonth() } } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(Theme.accent)
                    .padding(10)
                    .background(Circle().fill(Theme.accentSoft))
            }
            Spacer()
            Text(monthTitle)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(Theme.textPrimary)
            Spacer()
            Button { withAnimation(.easeInOut(duration: 0.2)) { nextMonth() } } label: {
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(isCurrentMonth ? Theme.heartEmpty : Theme.accent)
                    .padding(10)
                    .background(Circle().fill(isCurrentMonth ? Theme.inputBg : Theme.accentSoft))
            }
            .disabled(isCurrentMonth)
        }
    }

    // MARK: - Grid

    private var calendarGrid: some View {
        VStack(spacing: 6) {
            HStack(spacing: 0) {
                ForEach(dayLabels, id: \.self) { d in
                    Text(d)
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundStyle(Theme.textSecondary)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.bottom, 8)

            let totalCells = firstWeekday + daysInMonth
            let rows = (totalCells + 6) / 7

            ForEach(0..<rows, id: \.self) { row in
                HStack(spacing: 0) {
                    ForEach(0..<7, id: \.self) { col in
                        let day = row * 7 + col - firstWeekday + 1
                        if day >= 1 && day <= daysInMonth {
                            dayCell(day)
                        } else {
                            Color.clear.frame(maxWidth: .infinity).aspectRatio(1, contentMode: .fit)
                        }
                    }
                }
            }
        }
        .padding(20)
        .crumbsCard()
    }

    private func dayCell(_ day: Int) -> some View {
        let date = dateFor(day: day)
        let filled = store.hasEntry(for: date)
        let today = cal.isDateInToday(date)
        let future = date > Date()

        return Button {
            if let e = store.entry(for: date) { selectedEntry = e }
        } label: {
            ZStack {
                if today {
                    Circle().fill(Theme.accentSoft).padding(2)
                }
                if filled {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(Theme.heartFill)
                } else {
                    Text("\(day)")
                        .font(.system(size: 14, weight: today ? .bold : .medium, design: .rounded))
                        .foregroundStyle(today ? Theme.accent : future ? Theme.heartEmpty : Theme.textSecondary)
                }
            }
            .frame(maxWidth: .infinity)
            .aspectRatio(1, contentMode: .fit)
        }
        .disabled(!filled)
        .buttonStyle(.plain)
    }

    // MARK: - Entry sheet

    private func entrySheet(_ entry: DailyEntry) -> some View {
        let f = DateFormatter(); f.dateFormat = "EEEE, MMMM d"

        return ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text(f.string(from: entry.date).lowercased())
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundStyle(Theme.textPrimary)
                    .padding(.top, 8)

                HStack(spacing: 14) {
                    if let artURL = entry.artworkURL, let url = URL(string: artURL) {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .success(let img): img.resizable().aspectRatio(contentMode: .fill)
                            default: RoundedRectangle(cornerRadius: 14, style: .continuous).fill(Theme.cardBgElevated)
                            }
                        }
                        .frame(width: 72, height: 72)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 6) {
                            Image(systemName: "music.note")
                                .font(.system(size: 9, weight: .bold))
                                .foregroundStyle(Theme.accent)
                            Text("MOOD SONG")
                                .font(.system(size: 10, weight: .bold, design: .rounded))
                                .foregroundStyle(Theme.accent)
                                .tracking(1.2)
                        }
                        Text(entry.songTitle)
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundStyle(Theme.textPrimary)
                        Text(entry.songArtist)
                            .font(.system(size: 15, weight: .regular, design: .rounded))
                            .foregroundStyle(Theme.textSecondary)
                    }
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(RoundedRectangle(cornerRadius: 20, style: .continuous).fill(Theme.cardBgElevated))

                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 6) {
                        Image(systemName: "heart.fill")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundStyle(Theme.accent)
                        Text("SMALL WIN")
                            .font(.system(size: 10, weight: .bold, design: .rounded))
                            .foregroundStyle(Theme.accent)
                            .tracking(1.2)
                    }
                    Text(entry.win)
                        .font(.system(size: 17, weight: .regular, design: .rounded))
                        .foregroundStyle(Theme.textPrimary)
                        .lineSpacing(5)
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(RoundedRectangle(cornerRadius: 20, style: .continuous).fill(Theme.cardBgElevated))
            }
            .padding(24)
        }
        .background(Theme.bg)
    }

    private func prevMonth() {
        if selectedMonth == 1 { selectedMonth = 12; selectedYear -= 1 } else { selectedMonth -= 1 }
    }

    private func nextMonth() {
        guard !isCurrentMonth else { return }
        if selectedMonth == 12 { selectedMonth = 1; selectedYear += 1 } else { selectedMonth += 1 }
    }
}
