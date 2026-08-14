import Foundation

enum RuleKind: String, Codable, CaseIterable, Sendable, Identifiable {
    case replace
    case prefix
    case suffix
    case remove
    case numbering
    case caseChange
    case date
    case cleanup
    case regex

    var id: String { rawValue }

    var title: String {
        switch self {
        case .replace: "Replace Text"
        case .prefix: "Prefix"
        case .suffix: "Suffix"
        case .remove: "Remove Text"
        case .numbering: "Numbering"
        case .caseChange: "Case"
        case .date: "Date"
        case .cleanup: "Cleanup"
        case .regex: "Regex"
        }
    }

    var subtitle: String {
        switch self {
        case .replace: "Find and replace in the name"
        case .prefix: "Insert text at the start"
        case .suffix: "Insert text before the extension"
        case .remove: "Delete matching text"
        case .numbering: "Add sequential numbers"
        case .caseChange: "Change letter case"
        case .date: "Insert a date"
        case .cleanup: "Trim and tidy the name"
        case .regex: "Match with a regular expression"
        }
    }

    var systemImage: String {
        switch self {
        case .replace: "text.redaction"
        case .prefix: "arrow.left.to.line"
        case .suffix: "arrow.right.to.line"
        case .remove: "minus.circle"
        case .numbering: "number"
        case .caseChange: "textformat"
        case .date: "calendar"
        case .cleanup: "eraser"
        case .regex: "chevron.left.forwardslash.chevron.right"
        }
    }
}

enum NumberingPosition: String, Codable, CaseIterable, Sendable, Identifiable {
    case prefix
    case suffix
    case replace

    var id: String { rawValue }

    var title: String {
        switch self {
        case .prefix: "Before name"
        case .suffix: "After name"
        case .replace: "Replace name"
        }
    }
}

enum CaseStyle: String, Codable, CaseIterable, Sendable, Identifiable {
    case lowercase
    case uppercase
    case titleCase
    case sentenceCase

    var id: String { rawValue }

    var title: String {
        switch self {
        case .lowercase: "lowercase"
        case .uppercase: "UPPERCASE"
        case .titleCase: "Title Case"
        case .sentenceCase: "Sentence case"
        }
    }
}

enum DateSource: String, Codable, CaseIterable, Sendable, Identifiable {
    case current
    case created
    case modified

    var id: String { rawValue }

    var title: String {
        switch self {
        case .current: "Current date"
        case .created: "Date created"
        case .modified: "Date modified"
        }
    }
}

enum AffixPosition: String, Codable, CaseIterable, Sendable, Identifiable {
    case prefix
    case suffix

    var id: String { rawValue }

    var title: String {
        switch self {
        case .prefix: "Before name"
        case .suffix: "After name"
        }
    }
}

struct RuleParameters: Codable, Hashable, Sendable {
    var findText: String = ""
    var replacementText: String = ""
    var matchCase: Bool = false
    var replaceAll: Bool = true

    var affixText: String = ""

    var numberingStart: Int = 1
    var numberingStep: Int = 1
    var numberingDigits: Int = 3
    var numberingPosition: NumberingPosition = .prefix
    var numberingSeparator: String = "_"

    var caseStyle: CaseStyle = .lowercase

    var dateSource: DateSource = .current
    var dateFormat: String = "yyyy-MM-dd"
    var datePosition: AffixPosition = .prefix
    var dateSeparator: String = "_"

    var trimWhitespace: Bool = true
    var collapseWhitespace: Bool = true
    var spacesToUnderscores: Bool = false
    var spacesToHyphens: Bool = false
    var removeSpecialCharacters: Bool = false
    var removeDiacritics: Bool = false

    var regexPattern: String = ""
    var regexTemplate: String = ""
    var regexCaseInsensitive: Bool = false
}

struct RenameRule: Identifiable, Codable, Hashable, Sendable {
    var id: UUID
    var isEnabled: Bool
    var kind: RuleKind
    var parameters: RuleParameters

    init(
        id: UUID = UUID(),
        isEnabled: Bool = true,
        kind: RuleKind,
        parameters: RuleParameters = RuleParameters()
    ) {
        self.id = id
        self.isEnabled = isEnabled
        self.kind = kind
        self.parameters = parameters
    }

    static func make(_ kind: RuleKind) -> RenameRule {
        var parameters = RuleParameters()
        switch kind {
        case .prefix:
            parameters.affixText = ""
        case .suffix:
            parameters.affixText = ""
        case .numbering:
            parameters.numberingStart = 1
            parameters.numberingStep = 1
            parameters.numberingDigits = 3
            parameters.numberingPosition = .prefix
            parameters.numberingSeparator = "_"
        case .date:
            parameters.dateFormat = "yyyy-MM-dd"
            parameters.datePosition = .prefix
            parameters.dateSeparator = "_"
        case .cleanup:
            parameters.trimWhitespace = true
            parameters.collapseWhitespace = true
        default:
            break
        }
        return RenameRule(kind: kind, parameters: parameters)
    }

    var summary: String {
        let p = parameters
        switch kind {
        case .replace:
            if p.findText.isEmpty { return "Find text to replace" }
            return "“\(p.findText)” → “\(p.replacementText)”"
        case .prefix:
            return p.affixText.isEmpty ? "Add a prefix" : "Start with “\(p.affixText)”"
        case .suffix:
            return p.affixText.isEmpty ? "Add a suffix" : "End with “\(p.affixText)”"
        case .remove:
            return p.findText.isEmpty ? "Text to remove" : "Remove “\(p.findText)”"
        case .numbering:
            let sample = String(format: "%0\(max(1, p.numberingDigits))d", p.numberingStart)
            return "\(p.numberingPosition.title) · \(sample)"
        case .caseChange:
            return p.caseStyle.title
        case .date:
            return "\(p.datePosition.title) · \(p.dateFormat)"
        case .cleanup:
            var parts: [String] = []
            if p.trimWhitespace { parts.append("Trim") }
            if p.collapseWhitespace { parts.append("Collapse spaces") }
            if p.spacesToUnderscores { parts.append("Spaces → _") }
            if p.spacesToHyphens { parts.append("Spaces → -") }
            if p.removeSpecialCharacters { parts.append("Strip symbols") }
            if p.removeDiacritics { parts.append("Strip accents") }
            return parts.isEmpty ? "No cleanup options" : parts.joined(separator: " · ")
        case .regex:
            return p.regexPattern.isEmpty ? "Pattern" : p.regexPattern
        }
    }
}
