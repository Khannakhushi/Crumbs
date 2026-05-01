import Foundation

enum ExportService {
    /// Build a Markdown document for all entries, newest first.
    static func markdown(for entries: [DailyEntry], displayName: String) -> String {
        let sorted = entries.sorted { $0.date > $1.date }
        let df = DateFormatter()
        df.dateFormat = "EEEE, MMMM d, yyyy"

        var out = "# \(displayName)'s crumbs\n\n"
        out += "_\(sorted.count) days · exported \(Self.todayString())_\n\n"
        out += "---\n\n"

        var lastMonth = ""
        for e in sorted {
            let monthHeader = monthString(e.date)
            if monthHeader != lastMonth {
                out += "## \(monthHeader)\n\n"
                lastMonth = monthHeader
            }
            out += "### \(df.string(from: e.date))\n\n"
            out += "\(e.win)\n\n"
            out += "🎵 _\(e.songTitle) — \(e.songArtist)_\n\n"
            out += "---\n\n"
        }
        return out
    }

    /// Write the markdown to a temp file and return its URL for ShareLink.
    static func writeMarkdownFile(_ contents: String) -> URL? {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("crumbs-\(Self.todayString()).md")
        do {
            try contents.write(to: url, atomically: true, encoding: .utf8)
            return url
        } catch {
            return nil
        }
    }

    private static func monthString(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "MMMM yyyy"
        return f.string(from: date)
    }

    private static func todayString() -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: Date())
    }
}
