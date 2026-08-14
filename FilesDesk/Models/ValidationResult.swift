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
    case nestedConflict
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
    var firstErrorMessage: String?

    static let empty = ValidationReport(
        fileResults: [:],
        globalIssues: [],
        changeCount: 0,
        errorCount: 0,
        warningCount: 0,
        firstErrorMessage: nil
    )

    var canRename: Bool {
        errorCount == 0 && changeCount > 0 && globalIssues.allSatisfy { $0.severity != .error }
    }

    var statusTitle: String {
        if errorCount > 0 {
            let count = errorCount == 1 ? "1 个错误" : "\(errorCount) 个错误"
            if let firstErrorMessage, !firstErrorMessage.isEmpty {
                return "\(count) · \(firstErrorMessage)"
            }
            return count
        }
        if changeCount == 0 {
            return filesAreUnchanged ? "未更改" : "请添加文件"
        }
        if warningCount > 0 {
            return "就绪 · \(warningCount == 1 ? "1 个警告" : "\(warningCount) 个警告")"
        }
        return "就绪"
    }

    private var filesAreUnchanged: Bool {
        !fileResults.isEmpty && changeCount == 0
    }
}
