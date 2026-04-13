import SwiftUI
import Observation

@Observable
class EntryStore {
    var entries: [DailyEntry] = []

    private let saveKey = "crumbs_entries"

    init() {
        load()
    }

    // MARK: - Persistence

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: saveKey),
              let decoded = try? JSONDecoder().decode([DailyEntry].self, from: data) else {
            return
        }
        entries = decoded
    }

    private func save() {
        if let data = try? JSONEncoder().encode(entries) {
            UserDefaults.standard.set(data, forKey: saveKey)
        }
    }

    // MARK: - Entry management

    func addEntry(_ entry: DailyEntry) {
        let key = entry.dateKey
        entries.removeAll { $0.dateKey == key }
        entries.append(entry)
        save()
    }

    func entry(for date: Date) -> DailyEntry? {
        let key = DailyEntry.dateKey(for: date)
        return entries.first { $0.dateKey == key }
    }

    func hasEntry(for date: Date) -> Bool {
        entry(for: date) != nil
    }

    var todayEntry: DailyEntry? {
        entry(for: Date())
    }

    // MARK: - Streaks

    var currentStreak: Int {
        let calendar = Calendar.current
        let uniqueDays = Set(entries.map { calendar.startOfDay(for: $0.date) }).sorted(by: >)
        guard !uniqueDays.isEmpty else { return 0 }

        let today = calendar.startOfDay(for: Date())
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!

        guard uniqueDays[0] == today || uniqueDays[0] == yesterday else { return 0 }

        var streak = 1
        var current = uniqueDays[0]

        for date in uniqueDays.dropFirst() {
            let expected = calendar.date(byAdding: .day, value: -1, to: current)!
            if date == expected {
                streak += 1
                current = date
            } else if date == current {
                continue
            } else {
                break
            }
        }
        return streak
    }

    var longestStreak: Int {
        let calendar = Calendar.current
        let uniqueDays = Set(entries.map { calendar.startOfDay(for: $0.date) }).sorted()
        guard !uniqueDays.isEmpty else { return 0 }

        var longest = 1
        var current = 1

        for i in 1..<uniqueDays.count {
            let expected = calendar.date(byAdding: .day, value: 1, to: uniqueDays[i - 1])!
            if calendar.isDate(uniqueDays[i], inSameDayAs: expected) {
                current += 1
                longest = max(longest, current)
            } else {
                current = 1
            }
        }
        return longest
    }

    // MARK: - Monthly queries

    func entries(forMonth month: Int, year: Int) -> [DailyEntry] {
        let calendar = Calendar.current
        return entries.filter {
            let c = calendar.dateComponents([.month, .year], from: $0.date)
            return c.month == month && c.year == year
        }.sorted { $0.date < $1.date }
    }
}
