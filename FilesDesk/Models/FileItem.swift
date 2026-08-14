import Foundation

enum FileItemStatus: String, Sendable, Equatable {
    case previewing
    case ready
    case unchanged
    case warning
    case error
    case renamed
}

@MainActor
@Observable
final class FileItem: Identifiable {
    let id: UUID
    var originalURL: URL
    var originalName: String
    var proposedName: String
    var directoryURL: URL
    var fileSize: Int64
    var typeIdentifier: String
    var typeName: String
    var createdAt: Date
    var modifiedAt: Date
    var bookmark: Data?
    var parentBookmark: Data?
    var directoryWritable: Bool
    var status: FileItemStatus
    var statusMessage: String
    var hasSecurityAccess: Bool
    var isDirectory: Bool

    init(
        id: UUID = UUID(),
        originalURL: URL,
        originalName: String,
        proposedName: String,
        directoryURL: URL,
        fileSize: Int64,
        typeIdentifier: String,
        typeName: String,
        createdAt: Date,
        modifiedAt: Date,
        bookmark: Data?,
        parentBookmark: Data?,
        directoryWritable: Bool,
        status: FileItemStatus = .previewing,
        statusMessage: String = "",
        hasSecurityAccess: Bool,
        isDirectory: Bool = false
    ) {
        self.id = id
        self.originalURL = originalURL
        self.originalName = originalName
        self.proposedName = proposedName
        self.directoryURL = directoryURL
        self.fileSize = fileSize
        self.typeIdentifier = typeIdentifier
        self.typeName = typeName
        self.createdAt = createdAt
        self.modifiedAt = modifiedAt
        self.bookmark = bookmark
        self.parentBookmark = parentBookmark
        self.directoryWritable = directoryWritable
        self.status = status
        self.statusMessage = statusMessage
        self.hasSecurityAccess = hasSecurityAccess
        self.isDirectory = isDirectory
    }

    var proposedURL: URL {
        directoryURL.appendingPathComponent(proposedName)
    }

    var snapshot: FileSnapshot {
        FileSnapshot(
            id: id,
            originalName: originalName,
            proposedName: proposedName,
            directoryPath: directoryURL.path,
            originalPath: originalURL.path,
            fileSize: fileSize,
            typeIdentifier: typeIdentifier,
            createdAt: createdAt,
            modifiedAt: modifiedAt,
            directoryWritable: directoryWritable || parentBookmark != nil || bookmark != nil,
            hasSecurityAccess: hasSecurityAccess,
            isDirectory: isDirectory
        )
    }
}

struct FileSnapshot: Sendable, Equatable {
    let id: UUID
    let originalName: String
    let proposedName: String
    let directoryPath: String
    let originalPath: String
    let fileSize: Int64
    let typeIdentifier: String
    let createdAt: Date
    let modifiedAt: Date
    let directoryWritable: Bool
    let hasSecurityAccess: Bool
    var isDirectory: Bool = false

    var originalURL: URL { URL(fileURLWithPath: originalPath) }
    var directoryURL: URL { URL(fileURLWithPath: directoryPath) }
    var proposedURL: URL { directoryURL.appendingPathComponent(proposedName) }
}

struct ImportedFile: Sendable {
    let url: URL
    let name: String
    let directoryURL: URL
    let fileSize: Int64
    let typeIdentifier: String
    let typeName: String
    let createdAt: Date
    let modifiedAt: Date
    let bookmark: Data?
    let parentBookmark: Data?
    let directoryWritable: Bool
    let hasSecurityAccess: Bool
    let isDirectory: Bool
}
