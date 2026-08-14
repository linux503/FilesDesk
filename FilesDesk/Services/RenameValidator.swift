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
                        message: "“\(rule.kind.title)”中的正则表达式无效"
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

        var nestedConflicts = Set<UUID>()
        for folder in files where folder.isDirectory {
            let folderProposed = proposedNames[folder.id] ?? folder.originalName
            guard folderProposed != folder.originalName else { continue }
            let normalizedPrefix = (folder.originalPath as NSString).standardizingPath + "/"
            for child in files where child.id != folder.id {
                // Nested folders are renamed deepest-first. Only a changing file
                // inside a changing folder is unsafe.
                guard !child.isDirectory else { continue }
                let childPath = (child.originalPath as NSString).standardizingPath
                guard childPath.hasPrefix(normalizedPrefix) else { continue }
                let childProposed = proposedNames[child.id] ?? child.originalName
                guard childProposed != child.originalName else { continue }
                nestedConflicts.insert(folder.id)
                nestedConflicts.insert(child.id)
            }
        }

        var fileResults: [UUID: FileValidation] = [:]
        var changeCount = 0
        var errorCount = 0
        var warningCount = 0
        var firstErrorMessage = globalIssues.first(where: { $0.severity == .error })?.message

        let fileManager = FileManager.default

        for file in files {
            let proposed = proposedNames[file.id] ?? file.originalName
            var issues: [ValidationIssue] = []
            let changed = proposed != file.originalName
            if changed {
                changeCount += 1
            }

            if !changed {
                issues.append(
                    ValidationIssue(
                        fileID: file.id,
                        severity: .warning,
                        kind: .unchanged,
                        message: "文件名未更改"
                    )
                )
            } else {
                let trimmed = proposed.trimmingCharacters(in: .whitespacesAndNewlines)
                let stem = file.isDirectory ? trimmed : FilenameParts.split(proposed).stem
                    .trimmingCharacters(in: .whitespacesAndNewlines)

                if trimmed.isEmpty || stem.isEmpty {
                    issues.append(
                        ValidationIssue(
                            fileID: file.id,
                            severity: .error,
                            kind: .emptyName,
                            message: "文件名为空"
                        )
                    )
                }

                if nestedConflicts.contains(file.id) {
                    issues.append(
                        ValidationIssue(
                            fileID: file.id,
                            severity: .error,
                            kind: .nestedConflict,
                            message: "不能同时重命名文件夹和其中的文件，请把范围改成「文件夹」"
                        )
                    )
                }

                if proposed == "." || proposed == ".." {
                    issues.append(
                        ValidationIssue(
                            fileID: file.id,
                            severity: .error,
                            kind: .invalidName,
                            message: "非法文件名"
                        )
                    )
                }

                if let invalid = invalidCharacters(in: proposed) {
                    issues.append(
                        ValidationIssue(
                            fileID: file.id,
                            severity: .error,
                            kind: .invalidName,
                            message: "包含非法字符“\(invalid)”"
                        )
                    )
                }

                if proposed.lengthOfBytes(using: .utf8) > maxComponentByteCount {
                    issues.append(
                        ValidationIssue(
                            fileID: file.id,
                            severity: .error,
                            kind: .invalidName,
                            message: "文件名过长"
                        )
                    )
                }

                if !file.directoryWritable || !file.hasSecurityAccess {
                    issues.append(
                        ValidationIssue(
                            fileID: file.id,
                            severity: .error,
                            kind: .permission,
                            message: "没有权限重命名此项目"
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
                            message: "此文件夹中存在重名"
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
                                message: "已存在同名项目"
                            )
                        )
                    }
                }
            }

            if proposed.hasPrefix("."), changed {
                issues.append(
                    ValidationIssue(
                        fileID: file.id,
                        severity: .warning,
                        kind: .invalidName,
                        message: "将会变成隐藏文件"
                    )
                )
            }

            let hasError = issues.contains { $0.severity == .error }
            let hasWarning = issues.contains { $0.severity == .warning }
            if hasError { errorCount += 1 }
            if hasWarning { warningCount += 1 }
            if hasError, firstErrorMessage == nil {
                firstErrorMessage = issues.first(where: { $0.severity == .error })?.message
            }

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
                message: issues.first?.message ?? "就绪",
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
            warningCount: warningCount,
            firstErrorMessage: firstErrorMessage
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
                return "控制字符"
            }
        }
        return nil
    }
}
