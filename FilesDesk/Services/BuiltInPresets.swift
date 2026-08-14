import Foundation

enum BuiltInPresets {
    static func all() -> [RenamePreset] {
        [
            photography(),
            screenshots(),
            ecommerce(),
            documents()
        ]
    }

    static func photography() -> RenamePreset {
        var remove = RenameRule.make(.remove)
        remove.parameters.findText = "IMG_"
        var prefix = RenameRule.make(.prefix)
        prefix.parameters.affixText = "Photo_"
        let cleanup = RenameRule.make(.cleanup)
        return RenamePreset(name: "摄影", isBuiltIn: true, rules: [cleanup, remove, prefix])
    }

    static func screenshots() -> RenamePreset {
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
        return RenamePreset(name: "截图", isBuiltIn: true, rules: [removeShot, removeLegacy, cleanup, date])
    }

    static func ecommerce() -> RenamePreset {
        var cleanup = RenameRule.make(.cleanup)
        cleanup.parameters.spacesToHyphens = true
        cleanup.parameters.removeSpecialCharacters = true
        cleanup.parameters.removeDiacritics = true
        var lower = RenameRule.make(.caseChange)
        lower.parameters.caseStyle = .lowercase
        var prefix = RenameRule.make(.prefix)
        prefix.parameters.affixText = "sku-"
        var number = RenameRule.make(.numbering)
        number.parameters.numberingPosition = .suffix
        number.parameters.numberingSeparator = "-"
        return RenamePreset(name: "电商", isBuiltIn: true, rules: [cleanup, lower, prefix, number])
    }

    static func documents() -> RenamePreset {
        let cleanup = RenameRule.make(.cleanup)
        var title = RenameRule.make(.caseChange)
        title.parameters.caseStyle = .titleCase
        var date = RenameRule.make(.date)
        date.parameters.dateFormat = "yyyy-MM-dd"
        date.parameters.datePosition = .prefix
        date.parameters.dateSource = .modified
        return RenamePreset(name: "文档", isBuiltIn: true, rules: [cleanup, title, date])
    }

    static func localizeBuiltInNames(_ presets: [RenamePreset]) {
        let names = [
            "Photography": "摄影",
            "Screenshots": "截图",
            "E-commerce": "电商",
            "Documents": "文档"
        ]
        for preset in presets where preset.isBuiltIn {
            if let zh = names[preset.name] {
                preset.name = zh
            }
        }
    }
}
