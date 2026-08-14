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
        return RenamePreset(name: "Photography", isBuiltIn: true, rules: [cleanup, remove, prefix])
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
        return RenamePreset(name: "Screenshots", isBuiltIn: true, rules: [removeShot, removeLegacy, cleanup, date])
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
        return RenamePreset(name: "E-commerce", isBuiltIn: true, rules: [cleanup, lower, prefix, number])
    }

    static func documents() -> RenamePreset {
        let cleanup = RenameRule.make(.cleanup)
        var title = RenameRule.make(.caseChange)
        title.parameters.caseStyle = .titleCase
        var date = RenameRule.make(.date)
        date.parameters.dateFormat = "yyyy-MM-dd"
        date.parameters.datePosition = .prefix
        date.parameters.dateSource = .modified
        return RenamePreset(name: "Documents", isBuiltIn: true, rules: [cleanup, title, date])
    }
}
