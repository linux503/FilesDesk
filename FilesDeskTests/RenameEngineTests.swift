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

    @Test func removeLeadingDropsPrefixCharacters() {
        var rule = RenameRule.make(.removeLeading)
        rule.parameters.leadingCountValue = 4
        let context = ApplyContext(index: 0, createdAt: .now, modifiedAt: .now, now: .now)
        let result = RenameEngine.apply(rules: [rule], to: "4000-AA-1 (16)", context: context, isDirectory: true)
        #expect(result == "-AA-1 (16)")
    }

    @Test func removeLeadingKeepsExtensionOnFiles() {
        var rule = RenameRule.make(.removeLeading)
        rule.parameters.leadingCountValue = 4
        let context = ApplyContext(index: 0, createdAt: .now, modifiedAt: .now, now: .now)
        let result = RenameEngine.apply(rules: [rule], to: "IMG_001.jpg", context: context)
        #expect(result == "001.jpg")
    }

    @Test func removeLeadingThenNumberFolders() {
        var drop = RenameRule.make(.removeLeading)
        drop.parameters.leadingCountValue = 4
        var number = RenameRule.make(.numbering)
        number.parameters.numberingStart = 4001
        number.parameters.numberingDigits = 4
        number.parameters.numberingSeparator = ""
        number.parameters.numberingPosition = .prefix
        let context = ApplyContext(index: 0, createdAt: .now, modifiedAt: .now, now: .now)
        let result = RenameEngine.apply(
            rules: [drop, number],
            to: "4000-AA-1 (16)",
            context: context,
            isDirectory: true
        )
        #expect(result == "4001-AA-1 (16)")
    }

    @Test func oldSavedRulesDecodeWithoutLeadingCount() throws {
        let json = """
        [{"id":"00000000-0000-0000-0000-000000000001","isEnabled":true,"kind":"remove","parameters":{"findText":"IMG_","replacementText":"","matchCase":false,"replaceAll":true,"affixText":"","numberingStart":1,"numberingStep":1,"numberingDigits":3,"numberingPosition":"prefix","numberingSeparator":"_","caseStyle":"lowercase","dateSource":"current","dateFormat":"yyyy-MM-dd","datePosition":"prefix","dateSeparator":"_","trimWhitespace":true,"collapseWhitespace":true,"spacesToUnderscores":false,"spacesToHyphens":false,"removeSpecialCharacters":false,"removeDiacritics":false,"regexPattern":"","regexTemplate":"","regexCaseInsensitive":false}}]
        """
        let rules = try JSONDecoder().decode([RenameRule].self, from: Data(json.utf8))
        #expect(rules.count == 1)
        #expect(rules[0].kind == .remove)
        #expect(rules[0].parameters.findText == "IMG_")
        #expect(rules[0].parameters.leadingCountValue == 1)
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

    @Test func folderNameKeepsWholeNameIncludingDots() {
        var rule = RenameRule.make(.caseChange)
        rule.parameters.caseStyle = .uppercase
        let context = ApplyContext(index: 0, createdAt: .now, modifiedAt: .now, now: .now)
        let result = RenameEngine.apply(
            rules: [rule],
            to: "Trip.2024",
            context: context,
            isDirectory: true
        )
        #expect(result == "TRIP.2024")
    }

    @Test func numberingCountsOnlyFoldersInFolderScope() {
        var remove = RenameRule.make(.remove)
        remove.parameters.findText = "4000"
        var number = RenameRule.make(.numbering)
        number.parameters.numberingStart = 4001
        number.parameters.numberingDigits = 4
        number.parameters.numberingSeparator = ""
        number.parameters.numberingPosition = .prefix

        func folder(_ name: String, path: String) -> FileSnapshot {
            FileSnapshot(
                id: UUID(),
                originalName: name,
                proposedName: name,
                directoryPath: "/tmp",
                originalPath: path,
                fileSize: 0,
                typeIdentifier: "public.folder",
                createdAt: .now,
                modifiedAt: .now,
                directoryWritable: true,
                hasSecurityAccess: true,
                isDirectory: true
            )
        }
        let first = folder("4000-AA-8-14-1 (16)", path: "/tmp/4000-AA-8-14-1 (16)")
        let file = FileSnapshot(
            id: UUID(),
            originalName: "1.jpg",
            proposedName: "1.jpg",
            directoryPath: "/tmp/4000-AA-8-14-1 (16)",
            originalPath: "/tmp/4000-AA-8-14-1 (16)/1.jpg",
            fileSize: 1,
            typeIdentifier: "public.jpeg",
            createdAt: .now,
            modifiedAt: .now,
            directoryWritable: true,
            hasSecurityAccess: true
        )
        let second = folder("4000-AA-8-14-1 (219)", path: "/tmp/4000-AA-8-14-1 (219)")
        let names = RenameEngine.proposedNames(
            for: [first, file, second],
            rules: [remove, number],
            scope: .folders
        )
        #expect(names[first.id] == "4001-AA-8-14-1 (16)")
        #expect(names[file.id] == "1.jpg")
        #expect(names[second.id] == "4002-AA-8-14-1 (219)")
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

    @Test func nestedFoldersCanRenameTogether() {
        let root = "/tmp/filesdesk-\(UUID().uuidString)"
        let parent = FileSnapshot(
            id: UUID(),
            originalName: "1",
            proposedName: "1",
            directoryPath: root,
            originalPath: "\(root)/1",
            fileSize: 0,
            typeIdentifier: "public.folder",
            createdAt: .now,
            modifiedAt: .now,
            directoryWritable: true,
            hasSecurityAccess: true,
            isDirectory: true
        )
        let child = FileSnapshot(
            id: UUID(),
            originalName: "1 (16)",
            proposedName: "1 (16)",
            directoryPath: "\(root)/1",
            originalPath: "\(root)/1/1 (16)",
            fileSize: 0,
            typeIdentifier: "public.folder",
            createdAt: .now,
            modifiedAt: .now,
            directoryWritable: true,
            hasSecurityAccess: true,
            isDirectory: true
        )
        let names = [
            parent.id: "4000-AA-8-14-1",
            child.id: "4000-AA-8-14-1 (16)"
        ]
        let report = RenameValidator.validate(files: [parent, child], proposedNames: names, rules: [])
        #expect(report.canRename == true)
        #expect(report.errorCount == 0)
        #expect(report.changeCount == 2)
    }

    @Test func folderAndContainedFileCannotRenameTogether() {
        let root = "/tmp/filesdesk-\(UUID().uuidString)"
        let folder = FileSnapshot(
            id: UUID(),
            originalName: "Album",
            proposedName: "Album",
            directoryPath: root,
            originalPath: "\(root)/Album",
            fileSize: 0,
            typeIdentifier: "public.folder",
            createdAt: .now,
            modifiedAt: .now,
            directoryWritable: true,
            hasSecurityAccess: true,
            isDirectory: true
        )
        let file = FileSnapshot(
            id: UUID(),
            originalName: "photo.jpg",
            proposedName: "photo.jpg",
            directoryPath: "\(root)/Album",
            originalPath: "\(root)/Album/photo.jpg",
            fileSize: 1,
            typeIdentifier: "public.jpeg",
            createdAt: .now,
            modifiedAt: .now,
            directoryWritable: true,
            hasSecurityAccess: true,
            isDirectory: false
        )
        let names = [
            folder.id: "4000-Album",
            file.id: "4000-photo.jpg"
        ]
        let report = RenameValidator.validate(files: [folder, file], proposedNames: names, rules: [])
        #expect(report.canRename == false)
        #expect(report.errorCount >= 2)
        #expect(report.firstErrorMessage?.contains("文件夹") == true)
    }

    @Test func unchangedItemsDoNotBlockOnPermission() {
        let root = "/tmp/filesdesk-\(UUID().uuidString)"
        let folder = FileSnapshot(
            id: UUID(),
            originalName: "Keep",
            proposedName: "Keep",
            directoryPath: root,
            originalPath: "\(root)/Keep",
            fileSize: 0,
            typeIdentifier: "public.folder",
            createdAt: .now,
            modifiedAt: .now,
            directoryWritable: false,
            hasSecurityAccess: false,
            isDirectory: true
        )
        let changing = FileSnapshot(
            id: UUID(),
            originalName: "a.txt",
            proposedName: "a.txt",
            directoryPath: root,
            originalPath: "\(root)/a.txt",
            fileSize: 1,
            typeIdentifier: "public.text",
            createdAt: .now,
            modifiedAt: .now,
            directoryWritable: true,
            hasSecurityAccess: true
        )
        let names = [folder.id: "Keep", changing.id: "b.txt"]
        let report = RenameValidator.validate(files: [folder, changing], proposedNames: names, rules: [])
        #expect(report.canRename == true)
        #expect(report.errorCount == 0)
    }
}

struct SmartSuggestionTests {
    @Test func detectsCameraPhotos() {
        let suggestions = SmartSuggestionEngine.suggest(
            names: ["IMG_001.jpg", "IMG_002.jpg", "DSC_003.jpg"],
            isDirectory: [false, false, false],
            parentNames: ["DCIM", "DCIM", "DCIM"],
            currentRules: []
        )
        #expect(suggestions.contains { $0.id == "photography" })
    }

    @Test func detectsFinderCopyNumbers() {
        let suggestions = SmartSuggestionEngine.suggest(
            names: ["1 (16)", "1 (219)", "1 (213)", "1 (15)"],
            isDirectory: [true, true, true, true],
            parentNames: ["Work", "Work", "Work", "Work"],
            currentRules: []
        )
        #expect(suggestions.contains { $0.id == "finder-copies" })
        #expect(suggestions.contains { $0.id == "parent-prefix" })
    }

    @Test func skipsPrefixWhenAlreadySet() {
        var prefix = RenameRule.make(.prefix)
        prefix.parameters.affixText = "4000-AA-"
        let suggestions = SmartSuggestionEngine.suggest(
            names: ["a.txt", "b.txt"],
            isDirectory: [false, false],
            parentNames: ["Inbox", "Inbox"],
            currentRules: [prefix]
        )
        #expect(!suggestions.contains { $0.id == "parent-prefix" })
        #expect(!suggestions.contains { $0.id == "today-prefix" })
    }
}
