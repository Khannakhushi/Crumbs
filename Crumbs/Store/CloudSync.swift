import Foundation

/// Lightweight iCloud sync via NSUbiquitousKeyValueStore.
/// Silently no-ops if the iCloud key-value store entitlement is not enabled,
/// so the app keeps working with local UserDefaults only.
///
/// To turn cloud sync ON in Xcode:
///   Signing & Capabilities → + Capability → iCloud → check "Key-value storage"
enum CloudSync {
    static let store = NSUbiquitousKeyValueStore.default

    /// Push local data up to iCloud. Safe to call frequently.
    static func set(_ data: Data, forKey key: String) {
        store.set(data, forKey: key)
        store.synchronize()
    }

    /// Pull whatever iCloud has for `key`, or nil if nothing / not entitled.
    static func data(forKey key: String) -> Data? {
        store.data(forKey: key)
    }

    /// Subscribe to remote changes (other devices). Returns the observer token
    /// so the caller can keep it alive.
    @discardableResult
    static func observeChanges(_ handler: @escaping () -> Void) -> NSObjectProtocol {
        store.synchronize()
        return NotificationCenter.default.addObserver(
            forName: NSUbiquitousKeyValueStore.didChangeExternallyNotification,
            object: store,
            queue: .main
        ) { _ in handler() }
    }
}
