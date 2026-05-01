import Foundation

struct DailyEntry: Codable, Identifiable {
    var id: UUID = UUID()
    var date: Date
    var win: String
    var songTitle: String
    var songArtist: String
    var artworkURL: String?
    var albumName: String?

    // Optional photo stored on disk; this is just the file name (e.g. "<id>.jpg")
    var photoFilename: String?

    // Optional mood tag (e.g. "calm", "hyped", "soft")
    var mood: String?

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
