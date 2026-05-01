import SwiftUI
import Observation

@Observable
class EntryStore {
    var entries: [DailyEntry] = []

    private let saveKey = "crumbs_entries"
    private var cloudObserver: NSObjectProtocol?

    init() {
        load()
        cloudObserver = CloudSync.observeChanges { [weak self] in
            self?.pullFromCloud()
        }
    }

    deinit {
        if let cloudObserver { NotificationCenter.default.removeObserver(cloudObserver) }
    }

    // MARK: - Persistence

    private func load() {
        if let data = CloudSync.data(forKey: saveKey),
           let decoded = try? JSONDecoder().decode([DailyEntry].self, from: data) {
            entries = decoded
            // Mirror to local for offline.
            UserDefaults.standard.set(data, forKey: saveKey)
            return
        }
        if let data = UserDefaults.standard.data(forKey: saveKey),
           let decoded = try? JSONDecoder().decode([DailyEntry].self, from: data) {
            entries = decoded
        }
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(entries) else { return }
        UserDefaults.standard.set(data, forKey: saveKey)
        CloudSync.set(data, forKey: saveKey)
    }

    private func pullFromCloud() {
        guard let data = CloudSync.data(forKey: saveKey),
              let decoded = try? JSONDecoder().decode([DailyEntry].self, from: data) else {
            return
        }
        // Merge: keep newest per day key.
        var byKey: [String: DailyEntry] = [:]
        for e in entries { byKey[e.dateKey] = e }
        for e in decoded { byKey[e.dateKey] = e }
        entries = Array(byKey.values).sorted { $0.date < $1.date }
        if let merged = try? JSONEncoder().encode(entries) {
            UserDefaults.standard.set(merged, forKey: saveKey)
        }
    }

    // MARK: - Entry management

    func addEntry(_ entry: DailyEntry) {
        let key = entry.dateKey
        // Clean up old photo if this day already had a different one.
        if let existing = entries.first(where: { $0.dateKey == key }),
           let oldPhoto = existing.photoFilename, oldPhoto != entry.photoFilename {
            PhotoStorage.delete(oldPhoto)
        }
        entries.removeAll { $0.dateKey == key }
        entries.append(entry)
        save()
    }

    func deleteEntry(_ entry: DailyEntry) {
        if let photo = entry.photoFilename { PhotoStorage.delete(photo) }
        entries.removeAll { $0.id == entry.id }
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

    func entries(forYear year: Int) -> [DailyEntry] {
        let calendar = Calendar.current
        return entries.filter {
            calendar.component(.year, from: $0.date) == year
        }.sorted { $0.date < $1.date }
    }

    // MARK: - "On this day" memories

    /// Entries from previous years on the same month/day as today.
    func memories(for date: Date = Date()) -> [DailyEntry] {
        let calendar = Calendar.current
        let m = calendar.component(.month, from: date)
        let d = calendar.component(.day, from: date)
        let yearNow = calendar.component(.year, from: date)
        return entries.filter {
            let c = calendar.dateComponents([.month, .day, .year], from: $0.date)
            return c.month == m && c.day == d && (c.year ?? yearNow) < yearNow
        }.sorted { $0.date > $1.date }
    }

    // MARK: - Search

    func search(_ query: String) -> [DailyEntry] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !trimmed.isEmpty else { return [] }
        return entries.filter {
            $0.win.lowercased().contains(trimmed) ||
            $0.songTitle.lowercased().contains(trimmed) ||
            $0.songArtist.lowercased().contains(trimmed)
        }.sorted { $0.date > $1.date }
    }
}
