import Foundation

enum FilenameParts: Sendable {
    static func split(_ filename: String) -> (stem: String, ext: String) {
        let name = filename as NSString
        let ext = name.pathExtension
        if filename.hasPrefix("."), filename.dropFirst().contains(".") == false {
            return (filename, "")
        }
        if ext.isEmpty {
            return (filename, "")
        }
        return (name.deletingPathExtension, ext)
    }

    static func join(stem: String, ext: String) -> String {
        ext.isEmpty ? stem : "\(stem).\(ext)"
    }
}

struct ApplyContext: Sendable {
    let index: Int
    let createdAt: Date
    let modifiedAt: Date
    let now: Date
}

enum RenameEngine: Sendable {
    static func proposedNames(
        for files: [FileSnapshot],
        rules: [RenameRule],
        now: Date = .now
    ) -> [UUID: String] {
        let enabled = rules.filter(\.isEnabled)
        var result: [UUID: String] = [:]
        result.reserveCapacity(files.count)

        for (index, file) in files.enumerated() {
            let context = ApplyContext(
                index: index,
                createdAt: file.createdAt,
                modifiedAt: file.modifiedAt,
                now: now
            )
            result[file.id] = apply(rules: enabled, to: file.originalName, context: context)
        }
        return result
    }

    static func apply(rules: [RenameRule], to filename: String, context: ApplyContext) -> String {
        let parts = FilenameParts.split(filename)
        var stem = parts.stem
        for rule in rules where rule.isEnabled {
            stem = apply(rule: rule, to: stem, context: context)
        }
        return FilenameParts.join(stem: stem, ext: parts.ext)
    }

    static func apply(rule: RenameRule, to stem: String, context: ApplyContext) -> String {
        switch rule.kind {
        case .replace:
            return replace(stem, parameters: rule.parameters)
        case .prefix:
            return prefix(stem, text: rule.parameters.affixText)
        case .suffix:
            return suffix(stem, text: rule.parameters.affixText)
        case .remove:
            var parameters = rule.parameters
            parameters.replacementText = ""
            return replace(stem, parameters: parameters)
        case .numbering:
            return numbering(stem, parameters: rule.parameters, index: context.index)
        case .caseChange:
            return changeCase(stem, style: rule.parameters.caseStyle)
        case .date:
            return insertDate(stem, parameters: rule.parameters, context: context)
        case .cleanup:
            return cleanup(stem, parameters: rule.parameters)
        case .regex:
            return regexReplace(stem, parameters: rule.parameters)
        }
    }

    static func regexIsValid(_ pattern: String) -> Bool {
        guard !pattern.isEmpty else { return true }
        return (try? NSRegularExpression(pattern: pattern)) != nil
    }

    private static func replace(_ stem: String, parameters: RuleParameters) -> String {
        let find = parameters.findText
        guard !find.isEmpty else { return stem }

        var options: String.CompareOptions = []
        if !parameters.matchCase {
            options.insert(.caseInsensitive)
        }

        if !parameters.replaceAll {
            guard let range = stem.range(of: find, options: options) else { return stem }
            var result = stem
            result.replaceSubrange(range, with: parameters.replacementText)
            return result
        }

        var result = stem
        var searchStart = result.startIndex
        while searchStart < result.endIndex,
              let range = result.range(of: find, options: options, range: searchStart..<result.endIndex) {
            result.replaceSubrange(range, with: parameters.replacementText)
            if parameters.replacementText.isEmpty {
                searchStart = range.lowerBound
            } else {
                searchStart = result.index(range.lowerBound, offsetBy: parameters.replacementText.count)
            }
        }
        return result
    }

    private static func prefix(_ stem: String, text: String) -> String {
        text + stem
    }

    private static func suffix(_ stem: String, text: String) -> String {
        stem + text
    }

    private static func numbering(_ stem: String, parameters: RuleParameters, index: Int) -> String {
        let start = max(0, parameters.numberingStart)
        let step = max(1, parameters.numberingStep)
        let digits = min(8, max(1, parameters.numberingDigits))
        let value = start + (index * step)
        let formatted = String(format: "%0\(digits)d", value)
        let separator = parameters.numberingSeparator

        switch parameters.numberingPosition {
        case .prefix:
            return stem.isEmpty ? formatted : "\(formatted)\(separator)\(stem)"
        case .suffix:
            return stem.isEmpty ? formatted : "\(stem)\(separator)\(formatted)"
        case .replace:
            return formatted
        }
    }

    private static func changeCase(_ stem: String, style: CaseStyle) -> String {
        switch style {
        case .lowercase:
            return stem.lowercased()
        case .uppercase:
            return stem.uppercased()
        case .titleCase:
            return stem.localizedCapitalized
        case .sentenceCase:
            let lower = stem.lowercased()
            guard let first = lower.first else { return lower }
            return String(first).uppercased() + lower.dropFirst()
        }
    }

    private static func insertDate(_ stem: String, parameters: RuleParameters, context: ApplyContext) -> String {
        let date: Date
        switch parameters.dateSource {
        case .current: date = context.now
        case .created: date = context.createdAt
        case .modified: date = context.modifiedAt
        }

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = .current
        formatter.dateFormat = parameters.dateFormat.isEmpty ? "yyyy-MM-dd" : parameters.dateFormat
        var stamp = formatter.string(from: date)
        stamp = stamp.replacingOccurrences(of: "/", with: "-")
        stamp = stamp.replacingOccurrences(of: ":", with: "-")
        guard !stamp.isEmpty else { return stem }

        let separator = parameters.dateSeparator
        switch parameters.datePosition {
        case .prefix:
            return stem.isEmpty ? stamp : "\(stamp)\(separator)\(stem)"
        case .suffix:
            return stem.isEmpty ? stamp : "\(stem)\(separator)\(stamp)"
        }
    }

    private static func cleanup(_ stem: String, parameters: RuleParameters) -> String {
        var result = stem

        if parameters.removeDiacritics {
            result = result.applyingTransform(.stripDiacritics, reverse: false) ?? result
        }

        if parameters.removeSpecialCharacters {
            result = result.unicodeScalars.map { scalar in
                CharacterSet.alphanumerics.contains(scalar)
                    || scalar == "-"
                    || scalar == "_"
                    || scalar == "."
                    || scalar == " "
                    ? String(scalar)
                    : ""
            }.joined()
        }

        if parameters.collapseWhitespace {
            let collapsed = result.split(whereSeparator: { $0.isWhitespace }).joined(separator: " ")
            result = collapsed
        }

        if parameters.trimWhitespace {
            result = result.trimmingCharacters(in: .whitespacesAndNewlines)
        }

        if parameters.spacesToUnderscores {
            result = result.replacingOccurrences(of: " ", with: "_")
        } else if parameters.spacesToHyphens {
            result = result.replacingOccurrences(of: " ", with: "-")
        }

        if parameters.spacesToUnderscores || parameters.spacesToHyphens {
            let token = parameters.spacesToUnderscores ? "_" : "-"
            while result.contains(token + token) {
                result = result.replacingOccurrences(of: token + token, with: token)
            }
            result = result.trimmingCharacters(in: CharacterSet(charactersIn: token))
        }

        return result
    }

    private static func regexReplace(_ stem: String, parameters: RuleParameters) -> String {
        let pattern = parameters.regexPattern
        guard !pattern.isEmpty else { return stem }

        var options: NSRegularExpression.Options = []
        if parameters.regexCaseInsensitive {
            options.insert(.caseInsensitive)
        }

        guard let regex = try? NSRegularExpression(pattern: pattern, options: options) else {
            return stem
        }

        let range = NSRange(stem.startIndex..<stem.endIndex, in: stem)
        return regex.stringByReplacingMatches(
            in: stem,
            options: [],
            range: range,
            withTemplate: parameters.regexTemplate
        )
    }
}
