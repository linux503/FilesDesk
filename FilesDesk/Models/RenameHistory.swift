import Foundation
import SwiftData

@Model
final class HistoryBatch {
    var id: UUID
    var timestamp: Date
    var fileCount: Int
    var wasUndone: Bool
    @Relationship(deleteRule: .cascade, inverse: \HistoryItem.batch)
    var items: [HistoryItem]

    init(
        id: UUID = UUID(),
        timestamp: Date = .now,
        fileCount: Int,
        wasUndone: Bool = false,
        items: [HistoryItem] = []
    ) {
        self.id = id
        self.timestamp = timestamp
        self.fileCount = fileCount
        self.wasUndone = wasUndone
        self.items = items
    }
}

@Model
final class HistoryItem {
    var originalName: String
    var newName: String
    var originalPath: String
    var newPath: String
    var originalBookmark: Data?
    var newBookmark: Data?
    var batch: HistoryBatch?

    init(
        originalName: String,
        newName: String,
        originalPath: String,
        newPath: String,
        originalBookmark: Data? = nil,
        newBookmark: Data? = nil
    ) {
        self.originalName = originalName
        self.newName = newName
        self.originalPath = originalPath
        self.newPath = newPath
        self.originalBookmark = originalBookmark
        self.newBookmark = newBookmark
    }
}

struct RenameOutcome: Sendable {
    let timestamp: Date
    let entries: [RenameOutcomeEntry]
}

struct RenameOutcomeEntry: Sendable {
    let fileID: UUID
    let originalName: String
    let newName: String
    let originalPath: String
    let newPath: String
    let originalBookmark: Data?
    let newBookmark: Data?
}

struct RenamePlanItem: Sendable {
    let fileID: UUID
    let from: URL
    let to: URL
    let originalName: String
    let newName: String
    let originalBookmark: Data?
}
