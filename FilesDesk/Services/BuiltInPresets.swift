import Foundation

enum BuiltInPresets {
    static func all() -> [RenamePreset] {
        [
            photography(),
            screenshots(),
            ecommerce(),
            documents(),
            videos(),
            wechat(),
            finderCopies(),
            todayPrefix(),
            sequential(),
            spacesToUnderscores(),
            kebabCase(),
            lowercase()
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
        var removeZH = RenameRule.make(.remove)
        removeZH.parameters.findText = "截屏"
        var date = RenameRule.make(.date)
        date.parameters.dateFormat = "yyyy-MM-dd"
        date.parameters.datePosition = .prefix
        date.parameters.dateSource = .created
        var cleanup = RenameRule.make(.cleanup)
        cleanup.parameters.spacesToUnderscores = true
        return RenamePreset(name: "截图", isBuiltIn: true, rules: [removeShot, removeLegacy, removeZH, cleanup, date])
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

    static func videos() -> RenamePreset {
        var removeVID = RenameRule.make(.remove)
        removeVID.parameters.findText = "VID_"
        var removeMVI = RenameRule.make(.remove)
        removeMVI.parameters.findText = "MVI_"
        var removeMOV = RenameRule.make(.remove)
        removeMOV.parameters.findText = "MOV_"
        var prefix = RenameRule.make(.prefix)
        prefix.parameters.affixText = "Video_"
        var number = RenameRule.make(.numbering)
        number.parameters.numberingPosition = .suffix
        number.parameters.numberingSeparator = "_"
        number.parameters.numberingDigits = 3
        return RenamePreset(name: "视频", isBuiltIn: true, rules: [removeVID, removeMVI, removeMOV, prefix, number])
    }

    static func wechat() -> RenamePreset {
        var removeExport = RenameRule.make(.remove)
        removeExport.parameters.findText = "mmexport"
        var removeWX = RenameRule.make(.remove)
        removeWX.parameters.findText = "微信图片_"
        var date = RenameRule.make(.date)
        date.parameters.dateFormat = "yyyy-MM-dd"
        date.parameters.datePosition = .prefix
        date.parameters.dateSource = .created
        var prefix = RenameRule.make(.prefix)
        prefix.parameters.affixText = "WeChat_"
        return RenamePreset(name: "微信图片", isBuiltIn: true, rules: [removeExport, removeWX, date, prefix])
    }

    static func finderCopies() -> RenamePreset {
        var regexParen = RenameRule.make(.regex)
        regexParen.parameters.regexPattern = #" \(\d+\)$"#
        regexParen.parameters.regexTemplate = ""
        var removeCopy = RenameRule.make(.remove)
        removeCopy.parameters.findText = " copy"
        var removeZH = RenameRule.make(.remove)
        removeZH.parameters.findText = " 副本"
        return RenamePreset(name: "去掉拷贝编号", isBuiltIn: true, rules: [regexParen, removeCopy, removeZH])
    }

    static func todayPrefix() -> RenamePreset {
        var date = RenameRule.make(.date)
        date.parameters.dateFormat = "yyyy-M-d"
        date.parameters.datePosition = .prefix
        date.parameters.dateSource = .current
        date.parameters.dateSeparator = "-"
        return RenamePreset(name: "今天日期前缀", isBuiltIn: true, rules: [date])
    }

    static func sequential() -> RenamePreset {
        var number = RenameRule.make(.numbering)
        number.parameters.numberingStart = 1
        number.parameters.numberingDigits = 3
        number.parameters.numberingPosition = .replace
        number.parameters.numberingSeparator = ""
        return RenamePreset(name: "顺序编号", isBuiltIn: true, rules: [number])
    }

    static func spacesToUnderscores() -> RenamePreset {
        var cleanup = RenameRule.make(.cleanup)
        cleanup.parameters.trimWhitespace = true
        cleanup.parameters.collapseWhitespace = true
        cleanup.parameters.spacesToUnderscores = true
        return RenamePreset(name: "空格改下划线", isBuiltIn: true, rules: [cleanup])
    }

    static func kebabCase() -> RenamePreset {
        var cleanup = RenameRule.make(.cleanup)
        cleanup.parameters.trimWhitespace = true
        cleanup.parameters.collapseWhitespace = true
        cleanup.parameters.spacesToHyphens = true
        cleanup.parameters.removeSpecialCharacters = true
        var lower = RenameRule.make(.caseChange)
        lower.parameters.caseStyle = .lowercase
        return RenamePreset(name: "连字符小写", isBuiltIn: true, rules: [cleanup, lower])
    }

    static func lowercase() -> RenamePreset {
        var lower = RenameRule.make(.caseChange)
        lower.parameters.caseStyle = .lowercase
        return RenamePreset(name: "全部小写", isBuiltIn: true, rules: [lower])
    }

    static func localizeBuiltInNames(_ presets: [RenamePreset]) {
        let names = [
            "Photography": "摄影",
            "Screenshots": "截图",
            "E-commerce": "电商",
            "Documents": "文档",
            "Videos": "视频",
            "WeChat Photos": "微信图片",
            "Remove Copy Numbers": "去掉拷贝编号",
            "Today Prefix": "今天日期前缀",
            "Sequential": "顺序编号",
            "Spaces to Underscores": "空格改下划线",
            "Kebab Case": "连字符小写",
            "Lowercase": "全部小写"
        ]
        for preset in presets where preset.isBuiltIn {
            if let zh = names[preset.name] {
                preset.name = zh
            }
        }
    }
}
