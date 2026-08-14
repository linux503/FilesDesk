import Foundation

struct SmartSuggestion: Identifiable, Equatable, Sendable {
    let id: String
    let title: String
    let reason: String
    let systemImage: String
    let rules: [RenameRule]
    let replaceExisting: Bool
}

enum SmartSuggestionEngine: Sendable {
    static func suggest(
        names: [String],
        isDirectory: [Bool],
        parentNames: [String],
        currentRules: [RenameRule],
        now: Date = .now
    ) -> [SmartSuggestion] {
        guard !names.isEmpty else { return [] }

        var suggestions: [SmartSuggestion] = []
        let enabled = currentRules.filter(\.isEnabled)
        let hasPrefix = enabled.contains { $0.kind == .prefix && !$0.parameters.affixText.isEmpty }
        let hasRemoveIMG = enabled.contains {
            $0.kind == .remove && $0.parameters.findText.uppercased().contains("IMG")
        }
        let hasScreenshotCleanup = enabled.contains {
            $0.kind == .remove && $0.parameters.findText.localizedCaseInsensitiveContains("screenshot")
        }
        let hasDatePrefix = enabled.contains {
            $0.kind == .date && $0.parameters.datePosition == .prefix
        }

        let cameraRatio = matchingRatio(in: names, patterns: [
            "^IMG[_-]", "^DSC[_N]?", "^DCIM", "^PXL_", "^PHOTO[_-]"
        ])
        if cameraRatio >= 0.35, !hasRemoveIMG {
            var remove = RenameRule.make(.remove)
            remove.parameters.findText = "IMG_"
            var prefix = RenameRule.make(.prefix)
            prefix.parameters.affixText = "Photo_"
            suggestions.append(
                SmartSuggestion(
                    id: "photography",
                    title: "套用摄影规则",
                    reason: "检测到相机文件名，可去掉 IMG_ 并统一前缀",
                    systemImage: "camera.fill",
                    rules: [RenameRule.make(.cleanup), remove, prefix],
                    replaceExisting: true
                )
            )
        }

        let shotRatio = matchingRatio(in: names, patterns: [
            "Screenshot", "Screen Shot", "截屏", "CleanShot"
        ])
        if shotRatio >= 0.3, !hasScreenshotCleanup {
            var removeShot = RenameRule.make(.remove)
            removeShot.parameters.findText = "Screenshot "
            var removeLegacy = RenameRule.make(.remove)
            removeLegacy.parameters.findText = "Screen Shot "
            var date = RenameRule.make(.date)
            date.parameters.dateFormat = "yyyy-MM-dd"
            date.parameters.datePosition = .prefix
            date.parameters.dateSource = .created
            var cleanup = RenameRule.make(.cleanup)
            cleanup.parameters.spacesToUnderscores = true
            suggestions.append(
                SmartSuggestion(
                    id: "screenshots",
                    title: "整理截图名称",
                    reason: "检测到截图文件，可清理默认前缀并加上日期",
                    systemImage: "camera.viewfinder",
                    rules: [removeShot, removeLegacy, cleanup, date],
                    replaceExisting: true
                )
            )
        }

        let copyRatio = matchingRatio(in: names, patterns: [#" \(\d+\)$"#, " copy$", " 副本$"])
        let hasCopyRegex = enabled.contains {
            $0.kind == .regex && $0.parameters.regexPattern.contains("(\\d+)")
        }
        if copyRatio >= 0.4, !hasCopyRegex {
            var regex = RenameRule.make(.regex)
            regex.parameters.regexPattern = #" \(\d+\)$"#
            regex.parameters.regexTemplate = ""
            suggestions.append(
                SmartSuggestion(
                    id: "finder-copies",
                    title: "去掉拷贝编号",
                    reason: "很多名称带有“(16)”这类拷贝序号",
                    systemImage: "scissors",
                    rules: [regex],
                    replaceExisting: false
                )
            )
        }

        if let parent = sharedParentPrefix(parentNames), !hasPrefix {
            var prefix = RenameRule.make(.prefix)
            prefix.parameters.affixText = parent.hasSuffix("-") ? parent : parent + "-"
            suggestions.append(
                SmartSuggestion(
                    id: "parent-prefix",
                    title: "用所在文件夹做前缀",
                    reason: "多数项目都在“\(parent)”里，可自动加上前缀",
                    systemImage: "folder.badge.plus",
                    rules: [prefix],
                    replaceExisting: false
                )
            )
        }

        if !hasPrefix, !hasDatePrefix, names.count >= 2, suggestions.count < 2 {
            var prefix = RenameRule.make(.prefix)
            prefix.parameters.affixText = datePrefix(now: now)
            suggestions.append(
                SmartSuggestion(
                    id: "today-prefix",
                    title: "加上今天的日期",
                    reason: "适合按批次归档，例如 \(prefix.parameters.affixText)",
                    systemImage: "calendar.badge.plus",
                    rules: [prefix],
                    replaceExisting: false
                )
            )
        }

        return Array(suggestions.prefix(2))
    }

    private static func matchingRatio(in names: [String], patterns: [String]) -> Double {
        guard !names.isEmpty else { return 0 }
        let matchCount = names.filter { name in
            patterns.contains { pattern in
                name.range(of: pattern, options: [.regularExpression, .caseInsensitive]) != nil
            }
        }.count
        return Double(matchCount) / Double(names.count)
    }

    private static func sharedParentPrefix(_ parents: [String]) -> String? {
        let filtered = parents.filter { !$0.isEmpty && $0 != "/" }
        guard filtered.count >= 2 else { return nil }
        let counts = Dictionary(filtered.map { ($0, 1) }, uniquingKeysWith: +)
        guard let best = counts.max(by: { $0.value < $1.value }) else { return nil }
        let ratio = Double(best.value) / Double(filtered.count)
        guard ratio >= 0.6, best.key.count <= 40 else { return nil }
        return best.key
    }

    private static func datePrefix(now: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-M-d-"
        return formatter.string(from: now)
    }
}
