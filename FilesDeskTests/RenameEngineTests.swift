import Foundation
import Testing
@testable import FilesDesk

struct RenameEngineTests {
    @Test func removeThenPrefixMatchesTheProductExample() {
        let remove = {
            var rule = RenameRule.make(.remove)
            rule.parameters.findText = "IMG_"
            return rule
        }()
        let prefix = {
            var rule = RenameRule.make(.prefix)
            rule.parameters.affixText = "Taipei_"
            return rule
        }()
        let context = ApplyContext(index: 0, createdAt: .now, modifiedAt: .now, now: .now)
        let result = RenameEngine.apply(rules: [remove, prefix], to: "IMG_001.jpg", context: context)
        #expect(result == "Taipei_001.jpg")
    }

    @Test func numberingPadsAndPrefixes() {
        var rule = RenameRule.make(.numbering)
        rule.parameters.numberingStart = 1
        rule.parameters.numberingDigits = 3
        rule.parameters.numberingPosition = .prefix
        rule.parameters.numberingSeparator = "_"
        let context = ApplyContext(index: 4, createdAt: .now, modifiedAt: .now, now: .now)
        let result = RenameEngine.apply(rules: [rule], to: "photo.jpg", context: context)
        #expect(result == "005_photo.jpg")
    }

    @Test func disabledRulesAreSkipped() {
        var prefix = RenameRule.make(.prefix)
        prefix.parameters.affixText = "NEW_"
        prefix.isEnabled = false
        let context = ApplyContext(index: 0, createdAt: .now, modifiedAt: .now, now: .now)
        let result = RenameEngine.apply(rules: [prefix], to: "file.txt", context: context)
        #expect(result == "file.txt")
    }

    @Test func regexReplacement() {
        var rule = RenameRule.make(.regex)
        rule.parameters.regexPattern = #"IMG_(\d+)"#
        rule.parameters.regexTemplate = "Shot_$1"
        let context = ApplyContext(index: 0, createdAt: .now, modifiedAt: .now, now: .now)
        let result = RenameEngine.apply(rules: [rule], to: "IMG_042.png", context: context)
        #expect(result == "Shot_042.png")
    }

    @Test func cleanupCollapsesSpaces() {
        var rule = RenameRule.make(.cleanup)
        rule.parameters.trimWhitespace = true
        rule.parameters.collapseWhitespace = true
        rule.parameters.spacesToUnderscores = true
        let context = ApplyContext(index: 0, createdAt: .now, modifiedAt: .now, now: .now)
        let result = RenameEngine.apply(rules: [rule], to: "  my   file.txt", context: context)
        #expect(result == "my_file.txt")
    }

    @Test func engineDoesNotTouchExtensionsByDefault() {
        var rule = RenameRule.make(.caseChange)
        rule.parameters.caseStyle = .uppercase
        let context = ApplyContext(index: 0, createdAt: .now, modifiedAt: .now, now: .now)
        let result = RenameEngine.apply(rules: [rule], to: "notes.pdf", context: context)
        #expect(result == "NOTES.pdf")
    }
}

struct RenameValidatorTests {
    @Test func emptyNameIsAnError() {
        let file = FileSnapshot(
            id: UUID(),
            originalName: "a.txt",
            proposedName: " ",
            directoryPath: "/tmp",
            originalPath: "/tmp/a.txt",
            fileSize: 1,
            typeIdentifier: "public.text",
            createdAt: .now,
            modifiedAt: .now,
            directoryWritable: true,
            hasSecurityAccess: true
        )
        let names = [file.id: ""]
        let report = RenameValidator.validate(files: [file], proposedNames: names, rules: [])
        #expect(report.canRename == false)
        #expect(report.errorCount >= 1)
    }

    @Test func duplicateNamesBlockRename() {
        let first = FileSnapshot(
            id: UUID(),
            originalName: "one.txt",
            proposedName: "same.txt",
            directoryPath: "/tmp/desk",
            originalPath: "/tmp/desk/one.txt",
            fileSize: 1,
            typeIdentifier: "public.text",
            createdAt: .now,
            modifiedAt: .now,
            directoryWritable: true,
            hasSecurityAccess: true
        )
        let second = FileSnapshot(
            id: UUID(),
            originalName: "two.txt",
            proposedName: "same.txt",
            directoryPath: "/tmp/desk",
            originalPath: "/tmp/desk/two.txt",
            fileSize: 1,
            typeIdentifier: "public.text",
            createdAt: .now,
            modifiedAt: .now,
            directoryWritable: true,
            hasSecurityAccess: true
        )
        let names = [first.id: "same.txt", second.id: "same.txt"]
        let report = RenameValidator.validate(files: [first, second], proposedNames: names, rules: [])
        #expect(report.canRename == false)
        #expect(report.errorCount >= 2)
    }
}
