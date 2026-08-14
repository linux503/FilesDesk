import Foundation

@MainActor
final class SecurityScopeStore {
    static let shared = SecurityScopeStore()

    private var retained: [String: URL] = [:]

    func retain(_ url: URL) {
        let key = (url.path as NSString).standardizingPath
        guard retained[key] == nil else { return }
        if url.startAccessingSecurityScopedResource() {
            retained[key] = url
        }
    }

    func retain(bookmark: Data?) {
        guard let bookmark, let url = FileService.resolveBookmark(bookmark) else { return }
        retain(url)
    }

    func release(_ url: URL) {
        let key = (url.path as NSString).standardizingPath
        guard let stored = retained.removeValue(forKey: key) else { return }
        stored.stopAccessingSecurityScopedResource()
    }

    func releaseAll() {
        for url in retained.values {
            url.stopAccessingSecurityScopedResource()
        }
        retained.removeAll()
    }
}
