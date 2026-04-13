import Foundation

struct DailyEntry: Codable, Identifiable {
    var id: UUID = UUID()
    var date: Date
    var win: String
    var songTitle: String
    var songArtist: String
    var artworkURL: String?
    var albumName: String?

    var dateKey: String {
        Self.keyFormatter.string(from: date)
    }

    private static let keyFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()

    static func dateKey(for date: Date) -> String {
        keyFormatter.string(from: date)
    }
}
