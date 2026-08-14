import Foundation

enum ValidationSeverity: String, Sendable, Equatable {
    case warning
    case error
}

enum ValidationKind: String, Sendable, Equatable {
    case duplicateName
    case fileExists
    case emptyName
    case invalidName
    case permission
    case unchanged
    case invalidRule
}

struct ValidationIssue: Sendable, Equatable, Identifiable {
    let id: UUID
    let fileID: UUID?
    let severity: ValidationSeverity
    let kind: ValidationKind
    let message: String

    init(
        id: UUID = UUID(),
        fileID: UUID? = nil,
        severity: ValidationSeverity,
        kind: ValidationKind,
        message: String
    ) {
        self.id = id
        self.fileID = fileID
        self.severity = severity
        self.kind = kind
        self.message = message
    }
}

struct FileValidation: Sendable, Equatable {
    var status: FileItemStatus
    var message: String
    var issues: [ValidationIssue]
}

struct ValidationReport: Sendable, Equatable {
    var fileResults: [UUID: FileValidation]
    var globalIssues: [ValidationIssue]
    var changeCount: Int
    var errorCount: Int
    var warningCount: Int

    static let empty = ValidationReport(
        fileResults: [:],
        globalIssues: [],
        changeCount: 0,
        errorCount: 0,
        warningCount: 0
    )

    var canRename: Bool {
        errorCount == 0 && changeCount > 0 && globalIssues.allSatisfy { $0.severity != .error }
    }

    var statusTitle: String {
        if errorCount > 0 {
            return errorCount == 1 ? "1 Error" : "\(errorCount) Errors"
        }
        if changeCount == 0 {
            return filesAreUnchanged ? "Unchanged" : "Add files"
        }
        if warningCount > 0 {
            return "Ready · \(warningCount == 1 ? "1 Warning" : "\(warningCount) Warnings")"
        }
        return "Ready"
    }

    private var filesAreUnchanged: Bool {
        !fileResults.isEmpty && changeCount == 0
    }
}
