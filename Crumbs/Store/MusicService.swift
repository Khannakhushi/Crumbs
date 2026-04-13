import Foundation
import AVFoundation
import Observation

struct MusicTrack: Identifiable, Decodable {
    let id: Int
    let trackName: String
    let artistName: String
    let collectionName: String?
    let artworkUrl100: String?
    let previewUrl: String?

    var artworkLarge: String? {
        artworkUrl100?.replacingOccurrences(of: "100x100", with: "600x600")
    }

    var artworkMedium: String? {
        artworkUrl100?.replacingOccurrences(of: "100x100", with: "300x300")
    }

    enum CodingKeys: String, CodingKey {
        case trackName, artistName, collectionName, artworkUrl100, previewUrl
        case id = "trackId"
    }
}

private struct SearchResponse: Decodable {
    let results: [MusicTrack]
}

// MARK: - Top songs RSS response

private struct TopSongsResponse: Decodable {
    let feed: Feed
    struct Feed: Decodable {
        let results: [TopSong]
    }
    struct TopSong: Decodable {
        let id: String
        let name: String
        let artistName: String
        let artworkUrl100: String?
        let url: String?
    }
}

@Observable
class MusicService {
    var results: [MusicTrack] = []
    var trendingSongs: [MusicTrack] = []
    var isSearching = false
    var isLoadingTrending = false
    var playingTrackId: Int?

    private var searchTask: Task<Void, Never>?
    private var player: AVPlayer?

    func fetchTrending() {
        guard trendingSongs.isEmpty, !isLoadingTrending else { return }
        isLoadingTrending = true

        Task {
            guard let url = URL(string: "https://rss.applemarketingtools.com/api/v2/us/music/most-played/10/songs.json") else {
                await MainActor.run { isLoadingTrending = false }
                return
            }

            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                let decoded = try JSONDecoder().decode(TopSongsResponse.self, from: data)
                let tracks = decoded.feed.results.enumerated().map { i, song in
                    MusicTrack(
                        id: Int(song.id) ?? (900000 + i),
                        trackName: song.name,
                        artistName: song.artistName,
                        collectionName: nil,
                        artworkUrl100: song.artworkUrl100,
                        previewUrl: nil
                    )
                }
                await MainActor.run {
                    trendingSongs = tracks
                    isLoadingTrending = false
                }
            } catch {
                await MainActor.run { isLoadingTrending = false }
            }
        }
    }

    func search(_ query: String) {
        searchTask?.cancel()

        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            results = []
            isSearching = false
            return
        }

        isSearching = true

        searchTask = Task {
            try? await Task.sleep(for: .milliseconds(350))
            guard !Task.isCancelled else { return }

            guard let encoded = trimmed.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
                  let url = URL(string: "https://itunes.apple.com/search?term=\(encoded)&media=music&limit=25") else {
                await MainActor.run { isSearching = false }
                return
            }

            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                let decoded = try JSONDecoder().decode(SearchResponse.self, from: data)
                guard !Task.isCancelled else { return }
                await MainActor.run {
                    results = decoded.results
                    isSearching = false
                }
            } catch {
                guard !Task.isCancelled else { return }
                await MainActor.run { isSearching = false }
            }
        }
    }

    // MARK: - Audio preview

    func togglePreview(for track: MusicTrack) {
        if playingTrackId == track.id {
            stopPreview()
            return
        }

        stopPreview()

        guard let urlStr = track.previewUrl, let url = URL(string: urlStr) else { return }

        let item = AVPlayerItem(url: url)
        player = AVPlayer(playerItem: item)
        player?.play()
        playingTrackId = track.id

        // Auto-stop when preview ends
        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: item,
            queue: .main
        ) { [weak self] _ in
            self?.stopPreview()
        }
    }

    func stopPreview() {
        player?.pause()
        player = nil
        playingTrackId = nil
    }
}
