import UIKit

/// Stores crumb photos as JPEGs in the app's Documents directory.
/// We keep filenames in DailyEntry, not the bytes themselves, so the entry
/// stays small enough for iCloud key-value sync.
enum PhotoStorage {
    private static let folderName = "CrumbPhotos"

    private static var folderURL: URL {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let folder = docs.appendingPathComponent(folderName, isDirectory: true)
        if !FileManager.default.fileExists(atPath: folder.path) {
            try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        }
        return folder
    }

    /// Save a UIImage as a JPEG and return the filename to store on DailyEntry.
    static func save(_ image: UIImage, for entryId: UUID) -> String? {
        let filename = "\(entryId.uuidString).jpg"
        let url = folderURL.appendingPathComponent(filename)
        // Downscale to keep things lightweight.
        let resized = image.resizedForStorage(maxDimension: 1600)
        guard let data = resized.jpegData(compressionQuality: 0.82) else { return nil }
        do {
            try data.write(to: url, options: .atomic)
            return filename
        } catch {
            return nil
        }
    }

    static func load(_ filename: String) -> UIImage? {
        let url = folderURL.appendingPathComponent(filename)
        guard let data = try? Data(contentsOf: url) else { return nil }
        return UIImage(data: data)
    }

    static func delete(_ filename: String) {
        let url = folderURL.appendingPathComponent(filename)
        try? FileManager.default.removeItem(at: url)
    }
}

private extension UIImage {
    func resizedForStorage(maxDimension: CGFloat) -> UIImage {
        let maxSide = max(size.width, size.height)
        guard maxSide > maxDimension else { return self }
        let scale = maxDimension / maxSide
        let newSize = CGSize(width: size.width * scale, height: size.height * scale)
        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
}
