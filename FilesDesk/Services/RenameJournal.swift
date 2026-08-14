import Foundation

struct JournalPlanEntry: Codable, Sendable {
    var original: String
    var temp: String
    var final: String
}

struct JournalMove: Codable, Sendable {
    var from: String
    var to: String
}

struct RenameJournal: Codable, Sendable {
    var startedAt: Date
    var phase: Int
    var entries: [JournalPlanEntry]
    var moves: [JournalMove] = []
}

enum RenameJournalStore: Sendable {
    static var url: URL {
        let root = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? URL(fileURLWithPath: NSTemporaryDirectory())
        let directory = root.appendingPathComponent("FilesDesk", isDirectory: true)
        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        return directory.appendingPathComponent("rename-journal.json")
    }

    static func write(_ journal: RenameJournal) throws {
        let data = try JSONEncoder().encode(journal)
        try data.write(to: url, options: [.atomic])
    }

    static func load() -> RenameJournal? {
        guard let data = try? Data(contentsOf: url) else { return nil }
        return try? JSONDecoder().decode(RenameJournal.self, from: data)
    }

    static func clear() {
        try? FileManager.default.removeItem(at: url)
    }

    @discardableResult
    static func recoverIfNeeded() -> Int {
        guard let journal = load() else { return 0 }
        if journal.phase >= 2 {
            clear()
            return 0
        }

        let fileManager = FileManager.default
        var restored = 0

        for entry in journal.entries.reversed() {
            let original = URL(fileURLWithPath: entry.original)
            let temp = URL(fileURLWithPath: entry.temp)
            let final = URL(fileURLWithPath: entry.final)

            if fileManager.fileExists(atPath: original.path) {
                if fileManager.fileExists(atPath: temp.path) {
                    try? fileManager.removeItem(at: temp)
                }
                continue
            }

            if fileManager.fileExists(atPath: temp.path) {
                do {
                    try fileManager.moveItem(at: temp, to: original)
                    restored += 1
                    continue
                } catch {
                    continue
                }
            }

            if fileManager.fileExists(atPath: final.path) {
                do {
                    try fileManager.moveItem(at: final, to: original)
                    restored += 1
                } catch {
                    continue
                }
            }
        }

        clear()
        return restored
    }
}
