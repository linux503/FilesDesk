import Foundation

enum RenameExecutorError: LocalizedError, Sendable {
    case blocked(String)
    case io(String)
    case rollbackFailed(String)

    var errorDescription: String? {
        switch self {
        case .blocked(let message), .io(let message), .rollbackFailed(let message):
            return message
        }
    }
}

enum RenameExecutor: Sendable {
    static func execute(
        plan: [RenamePlanItem],
        progress: (@Sendable (Int, Int) -> Void)? = nil
    ) throws -> RenameOutcome {
        guard !plan.isEmpty else {
            throw RenameExecutorError.blocked("Nothing to rename.")
        }

        let fileManager = FileManager.default
        for item in plan {
            if fileManager.fileExists(atPath: item.to.path), !isSameItem(item.from, item.to) {
                throw RenameExecutorError.blocked("A file named “\(item.newName)” already exists. Rename was cancelled.")
            }
            if item.to.lastPathComponent.isEmpty {
                throw RenameExecutorError.blocked("Empty filename. Rename was cancelled.")
            }
        }

        var temps: [(item: RenamePlanItem, temp: URL)] = []
        temps.reserveCapacity(plan.count)

        for item in plan {
            let extValue = (item.from.lastPathComponent as NSString).pathExtension
            let ext = extValue.isEmpty ? "" : ".\(extValue)"
            let temp = item.from.deletingLastPathComponent()
                .appendingPathComponent(".filesdesk-temp-\(UUID().uuidString)\(ext)")
            temps.append((item, temp))
        }

        var journal = RenameJournal(
            startedAt: .now,
            phase: 0,
            entries: temps.map {
                JournalPlanEntry(original: $0.item.from.path, temp: $0.temp.path, final: $0.item.to.path)
            }
        )
        try RenameJournalStore.write(journal)

        var performed: [JournalMove] = []

        func rollback() -> String? {
            var failures: [String] = []
            for move in performed.reversed() {
                let from = URL(fileURLWithPath: move.to)
                let to = URL(fileURLWithPath: move.from)
                if fileManager.fileExists(atPath: from.path), !fileManager.fileExists(atPath: to.path) {
                    do {
                        try fileManager.moveItem(at: from, to: to)
                    } catch {
                        failures.append(to.lastPathComponent)
                    }
                }
            }
            return failures.isEmpty ? nil : "Could not restore: \(failures.joined(separator: ", "))"
        }

        do {
            let total = plan.count * 2
            var done = 0

            for (item, temp) in temps {
                try fileManager.moveItem(at: item.from, to: temp)
                performed.append(JournalMove(from: item.from.path, to: temp.path))
                done += 1
                progress?(done, total)
            }

            journal.phase = 1
            try RenameJournalStore.write(journal)

            var entries: [RenameOutcomeEntry] = []
            entries.reserveCapacity(plan.count)

            for (item, temp) in temps {
                if fileManager.fileExists(atPath: item.to.path) {
                    throw RenameExecutorError.blocked("A file named “\(item.newName)” already exists. Rename was cancelled.")
                }
                try fileManager.moveItem(at: temp, to: item.to)
                performed.append(JournalMove(from: temp.path, to: item.to.path))

                let newBookmark = try? item.to.bookmarkData(
                    options: .withSecurityScope,
                    includingResourceValuesForKeys: nil,
                    relativeTo: nil
                )
                entries.append(
                    RenameOutcomeEntry(
                        fileID: item.fileID,
                        originalName: item.originalName,
                        newName: item.newName,
                        originalPath: item.from.path,
                        newPath: item.to.path,
                        originalBookmark: item.originalBookmark,
                        newBookmark: newBookmark
                    )
                )
                done += 1
                progress?(done, total)
            }

            journal.phase = 2
            try RenameJournalStore.write(journal)
            RenameJournalStore.clear()
            return RenameOutcome(timestamp: .now, entries: entries)
        } catch {
            let rollbackMessage = rollback()
            if rollbackMessage == nil {
                RenameJournalStore.clear()
            }
            if let rollbackMessage {
                throw RenameExecutorError.rollbackFailed(
                    "Rename failed and some files could not be restored. \(rollbackMessage)"
                )
            }
            if let renameError = error as? RenameExecutorError {
                throw renameError
            }
            throw RenameExecutorError.io(error.localizedDescription)
        }
    }

    static func undo(entries: [RenameOutcomeEntry], progress: (@Sendable (Int, Int) -> Void)? = nil) throws -> RenameOutcome {
        let reversed = entries.map { entry in
            RenamePlanItem(
                fileID: entry.fileID,
                from: URL(fileURLWithPath: entry.newPath),
                to: URL(fileURLWithPath: entry.originalPath),
                originalName: entry.newName,
                newName: entry.originalName,
                originalBookmark: entry.newBookmark
            )
        }
        return try execute(plan: reversed, progress: progress)
    }

    private static func isSameItem(_ a: URL, _ b: URL) -> Bool {
        let aPath = (a.path as NSString).standardizingPath
        let bPath = (b.path as NSString).standardizingPath
        return aPath.compare(bPath, options: [.caseInsensitive]) == .orderedSame
    }
}
