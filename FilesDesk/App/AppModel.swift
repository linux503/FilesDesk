import AppKit
import Foundation
import Observation
import SwiftData

struct RenameCompletion: Equatable, Sendable {
    var fileCount: Int
    var timestamp: Date
    var batchID: UUID
}

@MainActor
@Observable
final class AppModel {
    var sidebar: SidebarItem = .rename
    var files: [FileItem] = []
    var rules: [RenameRule] = []
    var selection: Set<UUID> = []
    var searchText: String = ""
    var isDropTargeted = false
    var isImporting = false
    var isRenaming = false
    var isPreviewing = false
    var renameProgress: Double?
    var validation: ValidationReport = .empty
    var lastCompletion: RenameCompletion?
    var recoveredCount = 0
    var errorMessage: String?
    var confirmBeforeRename = true
    var includeHiddenFiles = false
    var includeSubfolders = true
    var showRenameConfirmation = false

    private var previewTask: Task<Void, Never>?
    private var previewGeneration: UInt64 = 0
    private let container: ModelContainer
    private let rulesDefaultsKey = "filesdesk.rules"
    private let confirmDefaultsKey = "filesdesk.confirmBeforeRename"
    private let hiddenDefaultsKey = "filesdesk.includeHiddenFiles"
    private let subfoldersDefaultsKey = "filesdesk.includeSubfolders"

    init(container: ModelContainer) {
        self.container = container
        confirmBeforeRename = UserDefaults.standard.object(forKey: confirmDefaultsKey) as? Bool ?? true
        includeHiddenFiles = UserDefaults.standard.bool(forKey: hiddenDefaultsKey)
        includeSubfolders = UserDefaults.standard.object(forKey: subfoldersDefaultsKey) as? Bool ?? true
        if let data = UserDefaults.standard.data(forKey: rulesDefaultsKey),
           let saved = try? JSONDecoder().decode([RenameRule].self, from: data) {
            rules = saved
        }
        recoveredCount = RenameJournalStore.recoverIfNeeded()
    }

    var modelContext: ModelContext {
        container.mainContext
    }

    var filteredFiles: [FileItem] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return files }
        return files.filter {
            $0.originalName.localizedCaseInsensitiveContains(query)
                || $0.proposedName.localizedCaseInsensitiveContains(query)
        }
    }

    var selectedFiles: [FileItem] {
        files.filter { selection.contains($0.id) }
    }

    var canRename: Bool {
        !isImporting && !isRenaming && !isPreviewing && validation.canRename
    }

    var renameButtonTitle: String {
        let count = validation.changeCount
        if count == 0 { return "Rename" }
        return count == 1 ? "Rename 1 File" : "Rename \(count) Files"
    }

    func persistSettings() {
        UserDefaults.standard.set(confirmBeforeRename, forKey: confirmDefaultsKey)
        UserDefaults.standard.set(includeHiddenFiles, forKey: hiddenDefaultsKey)
        UserDefaults.standard.set(includeSubfolders, forKey: subfoldersDefaultsKey)
        if let data = try? JSONEncoder().encode(rules) {
            UserDefaults.standard.set(data, forKey: rulesDefaultsKey)
        }
    }

    func seedPresetsIfNeeded() {
        let context = modelContext
        let descriptor = FetchDescriptor<RenamePreset>()
        let existing = (try? context.fetch(descriptor)) ?? []
        let seededKey = "filesdesk.didSeedPresets"
        if existing.isEmpty, !UserDefaults.standard.bool(forKey: seededKey) {
            for preset in BuiltInPresets.all() {
                context.insert(preset)
            }
            try? context.save()
        }
        UserDefaults.standard.set(true, forKey: seededKey)
    }

    func addFiles() {
        presentOpenPanel(folders: false)
    }

    func addFolder() {
        presentOpenPanel(folders: true)
    }

    func importDroppedURLs(_ urls: [URL]) {
        Task { await importURLs(urls) }
    }

    func importURLs(_ urls: [URL]) async {
        guard !urls.isEmpty else { return }
        isImporting = true
        errorMessage = nil
        defer { isImporting = false }

        for url in urls {
            SecurityScopeStore.shared.retain(url)
        }

        do {
            let imported = try await Task.detached(priority: .userInitiated) { [includeHiddenFiles, includeSubfolders] in
                try await FileService.collect(
                    from: urls,
                    includeHidden: includeHiddenFiles,
                    includeSubfolders: includeSubfolders
                )
            }.value

            let existing = Set(files.map { ($0.originalURL.path as NSString).standardizingPath })
            var additions: [FileItem] = []
            additions.reserveCapacity(imported.count)

            for item in imported {
                let path = (item.url.path as NSString).standardizingPath
                if existing.contains(path) { continue }
                SecurityScopeStore.shared.retain(item.url)
                if let parent = item.parentBookmark {
                    SecurityScopeStore.shared.retain(bookmark: parent)
                }
                additions.append(
                    FileItem(
                        originalURL: item.url,
                        originalName: item.name,
                        proposedName: item.name,
                        directoryURL: item.directoryURL,
                        fileSize: item.fileSize,
                        typeIdentifier: item.typeIdentifier,
                        typeName: item.typeName,
                        createdAt: item.createdAt,
                        modifiedAt: item.modifiedAt,
                        bookmark: item.bookmark,
                        parentBookmark: item.parentBookmark,
                        directoryWritable: item.directoryWritable,
                        hasSecurityAccess: item.hasSecurityAccess
                    )
                )
            }

            files.append(contentsOf: additions)
            schedulePreview()
        } catch is CancellationError {
            return
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func removeSelected() {
        guard !selection.isEmpty else { return }
        files.removeAll { selection.contains($0.id) }
        selection.removeAll()
        schedulePreview()
    }

    func remove(ids: Set<UUID>) {
        files.removeAll { ids.contains($0.id) }
        selection.subtract(ids)
        schedulePreview()
    }

    func clearFiles() {
        files.removeAll()
        selection.removeAll()
        lastCompletion = nil
        validation = .empty
        schedulePreview()
    }

    func selectAllVisible() {
        selection = Set(filteredFiles.map(\.id))
    }

    func deselectAll() {
        selection.removeAll()
    }

    func revealSelected() {
        let urls = selectedFiles.map(\.originalURL)
        guard !urls.isEmpty else { return }
        NSWorkspace.shared.activateFileViewerSelecting(urls)
    }

    func reveal(url: URL) {
        NSWorkspace.shared.activateFileViewerSelecting([url])
    }

    func quickLookSelected() {
        let visible = filteredFiles
        let selected = selectedFiles
        let urls = (selected.isEmpty ? visible : selected).map(\.originalURL)
        guard !urls.isEmpty else { return }
        QuickLookCoordinator.shared.show(urls: urls, selected: selected.first?.originalURL ?? urls.first)
    }

    func addRule(_ kind: RuleKind) {
        rules.append(.make(kind))
        persistSettings()
        schedulePreview()
    }

    func deleteRule(id: UUID) {
        rules.removeAll { $0.id == id }
        persistSettings()
        schedulePreview()
    }

    func moveRules(from offsets: IndexSet, to offset: Int) {
        rules.move(fromOffsets: offsets, toOffset: offset)
        persistSettings()
        schedulePreview()
    }

    func moveRule(id: UUID, by offset: Int) {
        guard let index = rules.firstIndex(where: { $0.id == id }) else { return }
        let destination = index + offset
        guard rules.indices.contains(destination) else { return }
        rules.swapAt(index, destination)
        persistSettings()
        schedulePreview()
    }

    func toggleRule(id: UUID) {
        guard let index = rules.firstIndex(where: { $0.id == id }) else { return }
        rules[index].isEnabled.toggle()
        persistSettings()
        schedulePreview()
    }

    func updateRules() {
        persistSettings()
        schedulePreview()
    }

    func applyPreset(_ preset: RenamePreset) {
        rules = preset.decodedRules().map { rule in
            var copy = rule
            copy.id = UUID()
            return copy
        }
        persistSettings()
        sidebar = .rename
        schedulePreview()
    }

    func saveCurrentRulesAsPreset(name: String) {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, !rules.isEmpty else { return }
        let preset = RenamePreset(name: trimmed, isBuiltIn: false, rules: rules)
        modelContext.insert(preset)
        try? modelContext.save()
    }

    func deletePreset(_ preset: RenamePreset) {
        modelContext.delete(preset)
        try? modelContext.save()
    }

    func requestRename() {
        guard canRename else { return }
        if confirmBeforeRename {
            showRenameConfirmation = true
        } else {
            Task { await performRename() }
        }
    }

    func performRename() async {
        guard canRename else { return }
        isRenaming = true
        renameProgress = 0
        errorMessage = nil
        lastCompletion = nil
        defer {
            isRenaming = false
            renameProgress = nil
        }

        let snapshots = files.map(\.snapshot)
        let proposed = Dictionary(uniqueKeysWithValues: files.map { ($0.id, $0.proposedName) })
        let currentRules = rules

        let report = await Task.detached(priority: .userInitiated) {
            RenameValidator.validate(files: snapshots, proposedNames: proposed, rules: currentRules)
        }.value

        validation = report
        applyValidation(report)
        guard report.canRename else {
            errorMessage = "Rename was blocked because of validation errors."
            return
        }

        let lookup = Dictionary(uniqueKeysWithValues: files.map { ($0.id, $0) })
        let plan: [RenamePlanItem] = snapshots.compactMap { snapshot in
            guard let result = report.fileResults[snapshot.id] else { return nil }
            guard result.status == .ready || result.status == .warning else { return nil }
            let name = proposed[snapshot.id] ?? snapshot.originalName
            guard name != snapshot.originalName else { return nil }
            guard let item = lookup[snapshot.id] else { return nil }
            return RenamePlanItem(
                fileID: snapshot.id,
                from: item.originalURL,
                to: item.directoryURL.appendingPathComponent(name),
                originalName: snapshot.originalName,
                newName: name,
                originalBookmark: item.bookmark
            )
        }

        guard !plan.isEmpty else { return }

        do {
            let outcome = try await Task.detached(priority: .userInitiated) {
                try RenameExecutor.execute(plan: plan) { done, total in
                    Task { @MainActor in
                        self.renameProgress = Double(done) / Double(max(total, 1))
                    }
                }
            }.value

            let batch = HistoryBatch(timestamp: outcome.timestamp, fileCount: outcome.entries.count)
            modelContext.insert(batch)
            for entry in outcome.entries {
                let historyItem = HistoryItem(
                    originalName: entry.originalName,
                    newName: entry.newName,
                    originalPath: entry.originalPath,
                    newPath: entry.newPath,
                    originalBookmark: entry.originalBookmark,
                    newBookmark: entry.newBookmark
                )
                historyItem.batch = batch
                modelContext.insert(historyItem)
                if let file = lookup[entry.fileID] {
                    let newURL = URL(fileURLWithPath: entry.newPath)
                    file.originalURL = newURL
                    file.originalName = entry.newName
                    file.proposedName = entry.newName
                    file.bookmark = entry.newBookmark
                    file.status = .renamed
                    file.statusMessage = "Renamed"
                    SecurityScopeStore.shared.retain(newURL)
                }
            }
            try? modelContext.save()

            lastCompletion = RenameCompletion(
                fileCount: outcome.entries.count,
                timestamp: outcome.timestamp,
                batchID: batch.id
            )
            schedulePreview()
        } catch {
            errorMessage = error.localizedDescription
            schedulePreview()
        }
    }

    func undoLastCompletion() async {
        guard let completion = lastCompletion else { return }
        await undo(batchID: completion.batchID)
        lastCompletion = nil
    }

    func undo(batchID: UUID) async {
        let descriptor = FetchDescriptor<HistoryBatch>(predicate: #Predicate { $0.id == batchID })
        guard let batch = try? modelContext.fetch(descriptor).first, !batch.wasUndone else { return }

        isRenaming = true
        renameProgress = 0
        errorMessage = nil
        defer {
            isRenaming = false
            renameProgress = nil
        }

        for item in batch.items {
            if let data = item.newBookmark {
                SecurityScopeStore.shared.retain(bookmark: data)
            }
            SecurityScopeStore.shared.retain(URL(fileURLWithPath: item.newPath).deletingLastPathComponent())
        }

        let entries = batch.items.map {
            RenameOutcomeEntry(
                fileID: UUID(),
                originalName: $0.originalName,
                newName: $0.newName,
                originalPath: $0.originalPath,
                newPath: $0.newPath,
                originalBookmark: $0.originalBookmark,
                newBookmark: $0.newBookmark
            )
        }

        do {
            let outcome = try await Task.detached(priority: .userInitiated) {
                try RenameExecutor.undo(entries: entries) { done, total in
                    Task { @MainActor in
                        self.renameProgress = Double(done) / Double(max(total, 1))
                    }
                }
            }.value

            batch.wasUndone = true
            try? modelContext.save()

            let restoredByNewPath = Dictionary(uniqueKeysWithValues: outcome.entries.map { ($0.originalPath, $0) })
            for file in files {
                if let restored = restoredByNewPath[file.originalURL.path] {
                    let url = URL(fileURLWithPath: restored.newPath)
                    file.originalURL = url
                    file.originalName = restored.newName
                    file.proposedName = restored.newName
                    file.bookmark = restored.newBookmark
                    file.status = .ready
                    file.statusMessage = "Restored"
                }
            }
            schedulePreview()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func schedulePreview() {
        previewTask?.cancel()
        previewGeneration += 1
        let generation = previewGeneration
        let snapshots = files.map(\.snapshot)
        let currentRules = rules

        guard !snapshots.isEmpty else {
            validation = .empty
            isPreviewing = false
            return
        }

        isPreviewing = true
        previewTask = Task { [weak self] in
            guard let self else { return }
            do {
                try await Task.sleep(for: .milliseconds(120))
                try Task.checkCancellation()

                let names = await Task.detached(priority: .userInitiated) {
                    RenameEngine.proposedNames(for: snapshots, rules: currentRules)
                }.value
                try Task.checkCancellation()

                let report = await Task.detached(priority: .userInitiated) {
                    RenameValidator.validate(files: snapshots, proposedNames: names, rules: currentRules)
                }.value
                try Task.checkCancellation()

                guard generation == self.previewGeneration else { return }
                self.applyProposedNames(names)
                self.applyValidation(report)
                self.validation = report
                self.isPreviewing = false
            } catch {
                if generation == self.previewGeneration {
                    self.isPreviewing = false
                }
            }
        }
    }

    private func applyProposedNames(_ names: [UUID: String]) {
        for file in files {
            if let name = names[file.id] {
                file.proposedName = name
            }
        }
    }

    private func applyValidation(_ report: ValidationReport) {
        for file in files {
            if let result = report.fileResults[file.id] {
                file.status = result.status
                file.statusMessage = result.message
            }
        }
    }

    private func presentOpenPanel(folders: Bool) {
        let panel = NSOpenPanel()
        panel.canChooseFiles = !folders
        panel.canChooseDirectories = folders
        panel.allowsMultipleSelection = true
        panel.canCreateDirectories = false
        panel.treatsFilePackagesAsDirectories = false
        panel.prompt = "Add"
        panel.message = folders ? "Choose folders to add" : "Choose files to add"
        panel.begin { [weak self] response in
            guard response == .OK else { return }
            Task { @MainActor in
                await self?.importURLs(panel.urls)
            }
        }
    }
}
