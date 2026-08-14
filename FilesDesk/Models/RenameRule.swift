import Foundation

enum RuleKind: String, Codable, CaseIterable, Sendable, Identifiable {
    case replace
    case prefix
    case suffix
    case remove
    case removeLeading
    case numbering
    case caseChange
    case date
    case cleanup
    case regex

    var id: String { rawValue }

    var title: String {
        switch self {
        case .replace: "替换"
        case .prefix: "前缀"
        case .suffix: "后缀"
        case .remove: "删除"
        case .removeLeading: "删除前几位"
        case .numbering: "编号"
        case .caseChange: "大小写"
        case .date: "日期"
        case .cleanup: "清理"
        case .regex: "正则"
        }
    }

    var subtitle: String {
        switch self {
        case .replace: "查找并替换文件名中的文本"
        case .prefix: "在文件名前插入"
        case .suffix: "在扩展名前插入"
        case .remove: "删除匹配的文本"
        case .removeLeading: "从文件名开头去掉指定个数的字符"
        case .numbering: "添加顺序编号"
        case .caseChange: "更改字母大小写"
        case .date: "插入日期"
        case .cleanup: "整理空格与符号"
        case .regex: "使用正则表达式匹配"
        }
    }

    var systemImage: String {
        switch self {
        case .replace: "text.redaction"
        case .prefix: "arrow.left.to.line"
        case .suffix: "arrow.right.to.line"
        case .remove: "minus.circle"
        case .removeLeading: "delete.backward"
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
        case .prefix: "文件名前"
        case .suffix: "文件名后"
        case .replace: "替换文件名"
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
        case .lowercase: "小写"
        case .uppercase: "大写"
        case .titleCase: "标题格式"
        case .sentenceCase: "句首大写"
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
        case .current: "当前日期"
        case .created: "创建日期"
        case .modified: "修改日期"
        }
    }
}

enum AffixPosition: String, Codable, CaseIterable, Sendable, Identifiable {
    case prefix
    case suffix

    var id: String { rawValue }

    var title: String {
        switch self {
        case .prefix: "文件名前"
        case .suffix: "文件名后"
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

    /// Characters to drop from the start. Optional so old saved rules still decode.
    var leadingCount: Int? = 1

    var leadingCountValue: Int {
        get { max(0, leadingCount ?? 1) }
        set { leadingCount = max(0, newValue) }
    }
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
        case .removeLeading:
            parameters.leadingCount = 1
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
            if p.findText.isEmpty { return "输入要替换的文本" }
            return "“\(p.findText)” → “\(p.replacementText)”"
        case .prefix:
            return p.affixText.isEmpty ? "添加前缀" : "以“\(p.affixText)”开头"
        case .suffix:
            return p.affixText.isEmpty ? "添加后缀" : "以“\(p.affixText)”结尾"
        case .remove:
            return p.findText.isEmpty ? "输入要删除的文本" : "删除“\(p.findText)”"
        case .removeLeading:
            return "删除前 \(p.leadingCountValue) 位"
        case .numbering:
            let sample = String(format: "%0\(max(1, p.numberingDigits))d", p.numberingStart)
            return "\(p.numberingPosition.title) · \(sample)"
        case .caseChange:
            return p.caseStyle.title
        case .date:
            return "\(p.datePosition.title) · \(p.dateFormat)"
        case .cleanup:
            var parts: [String] = []
            if p.trimWhitespace { parts.append("去空格") }
            if p.collapseWhitespace { parts.append("合并空格") }
            if p.spacesToUnderscores { parts.append("空格 → _") }
            if p.spacesToHyphens { parts.append("空格 → -") }
            if p.removeSpecialCharacters { parts.append("去掉符号") }
            if p.removeDiacritics { parts.append("去掉重音") }
            return parts.isEmpty ? "未选择清理选项" : parts.joined(separator: " · ")
        case .regex:
            return p.regexPattern.isEmpty ? "正则模式" : p.regexPattern
        }
    }
}
