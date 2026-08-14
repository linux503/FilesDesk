import Foundation

enum RenameValidator: Sendable {
    private static let maxComponentByteCount = 255

    static func validate(
        files: [FileSnapshot],
        proposedNames: [UUID: String],
        rules: [RenameRule]
    ) -> ValidationReport {
        var globalIssues: [ValidationIssue] = []
        for rule in rules where rule.isEnabled && rule.kind == .regex {
            let pattern = rule.parameters.regexPattern
            if !pattern.isEmpty, !RenameEngine.regexIsValid(pattern) {
                globalIssues.append(
                    ValidationIssue(
                        severity: .error,
                        kind: .invalidRule,
                        message: "Invalid regular expression in “\(rule.kind.title)”"
                    )
                )
            }
        }

        var occupancy: [String: [UUID]] = [:]
        occupancy.reserveCapacity(files.count)

        for file in files {
            let proposed = proposedNames[file.id] ?? file.originalName
            occupancy[collisionKey(directory: file.directoryPath, name: proposed), default: []].append(file.id)
        }

        var originalsByKey: [String: UUID] = [:]
        originalsByKey.reserveCapacity(files.count)
        for file in files {
            originalsByKey[collisionKey(directory: file.directoryPath, name: file.originalName)] = file.id
        }

        var fileResults: [UUID: FileValidation] = [:]
        var changeCount = 0
        var errorCount = 0
        var warningCount = 0

        let fileManager = FileManager.default

        for file in files {
            let proposed = proposedNames[file.id] ?? file.originalName
            var issues: [ValidationIssue] = []

            let trimmed = proposed.trimmingCharacters(in: .whitespacesAndNewlines)
            let parts = FilenameParts.split(proposed)

            if trimmed.isEmpty || parts.stem.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                issues.append(
                    ValidationIssue(
                        fileID: file.id,
                        severity: .error,
                        kind: .emptyName,
                        message: "Empty filename"
                    )
                )
            }

            if proposed == "." || proposed == ".." {
                issues.append(
                    ValidationIssue(
                        fileID: file.id,
                        severity: .error,
                        kind: .invalidName,
                        message: "Illegal filename"
                    )
                )
            }

            if let invalid = invalidCharacters(in: proposed) {
                issues.append(
                    ValidationIssue(
                        fileID: file.id,
                        severity: .error,
                        kind: .invalidName,
                        message: "Illegal character “\(invalid)”"
                    )
                )
            }

            if proposed.lengthOfBytes(using: .utf8) > maxComponentByteCount {
                issues.append(
                    ValidationIssue(
                        fileID: file.id,
                        severity: .error,
                        kind: .invalidName,
                        message: "Name is too long"
                    )
                )
            }

            if !file.directoryWritable || !file.hasSecurityAccess {
                issues.append(
                    ValidationIssue(
                        fileID: file.id,
                        severity: .error,
                        kind: .permission,
                        message: "No permission to rename this file"
                    )
                )
            }

            let key = collisionKey(directory: file.directoryPath, name: proposed)
            if let ids = occupancy[key], ids.count > 1 {
                issues.append(
                    ValidationIssue(
                        fileID: file.id,
                        severity: .error,
                        kind: .duplicateName,
                        message: "Duplicate name in this folder"
                    )
                )
            }

            let destURL = URL(fileURLWithPath: file.directoryPath).appendingPathComponent(proposed)
            let sourceURL = URL(fileURLWithPath: file.originalPath)
            if fileManager.fileExists(atPath: destURL.path), !isSameItem(sourceURL, destURL) {
                let destKey = collisionKey(directory: file.directoryPath, name: proposed)
                let vacatingID = originalsByKey[destKey]
                let willVacate: Bool
                if let vacatingID, vacatingID != file.id,
                   let occupier = files.first(where: { $0.id == vacatingID }) {
                    let occupierProposed = proposedNames[occupier.id] ?? occupier.originalName
                    willVacate = occupierProposed.compare(occupier.originalName, options: .caseInsensitive) != .orderedSame
                        || occupierProposed != occupier.originalName
                } else {
                    willVacate = false
                }

                if !willVacate {
                    issues.append(
                        ValidationIssue(
                            fileID: file.id,
                            severity: .error,
                            kind: .fileExists,
                            message: "A file with this name already exists"
                        )
                    )
                }
            }

            let changed = proposed != file.originalName
            if changed {
                changeCount += 1
            } else if issues.isEmpty {
                issues.append(
                    ValidationIssue(
                        fileID: file.id,
                        severity: .warning,
                        kind: .unchanged,
                        message: "Name is unchanged"
                    )
                )
            }

            if proposed.hasPrefix("."), changed {
                issues.append(
                    ValidationIssue(
                        fileID: file.id,
                        severity: .warning,
                        kind: .invalidName,
                        message: "Will become a hidden file"
                    )
                )
            }

            let hasError = issues.contains { $0.severity == .error }
            let hasWarning = issues.contains { $0.severity == .warning }
            if hasError { errorCount += 1 }
            if hasWarning { warningCount += 1 }

            let status: FileItemStatus
            if hasError {
                status = .error
            } else if !changed {
                status = .unchanged
            } else if hasWarning {
                status = .warning
            } else {
                status = .ready
            }

            fileResults[file.id] = FileValidation(
                status: status,
                message: issues.first?.message ?? "Ready",
                issues: issues
            )
        }

        if !globalIssues.isEmpty {
            errorCount += globalIssues.filter { $0.severity == .error }.count
            warningCount += globalIssues.filter { $0.severity == .warning }.count
        }

        return ValidationReport(
            fileResults: fileResults,
            globalIssues: globalIssues,
            changeCount: changeCount,
            errorCount: errorCount,
            warningCount: warningCount
        )
    }

    private static func collisionKey(directory: String, name: String) -> String {
        let dir = (directory as NSString).standardizingPath.lowercased()
        return dir + "/" + name.lowercased()
    }

    private static func isSameItem(_ a: URL, _ b: URL) -> Bool {
        let aPath = (a.path as NSString).standardizingPath
        let bPath = (b.path as NSString).standardizingPath
        if aPath.compare(bPath, options: [.caseInsensitive]) == .orderedSame {
            return true
        }
        guard
            let aID = try? a.resourceValues(forKeys: [.fileResourceIdentifierKey]).fileResourceIdentifier,
            let bID = try? b.resourceValues(forKeys: [.fileResourceIdentifierKey]).fileResourceIdentifier
        else {
            return false
        }
        return aID.isEqual(bID)
    }

    private static func invalidCharacters(in name: String) -> String? {
        for scalar in name.unicodeScalars {
            if scalar == "/" || scalar == ":" || scalar == "\0" {
                return String(scalar)
            }
            if CharacterSet.controlCharacters.contains(scalar) {
                return "control"
            }
        }
        return nil
    }
}
