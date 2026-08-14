import SwiftUI

struct FilesDeskCommands: Commands {
    @FocusedValue(\.appModel) private var model: AppModel?

    var body: some Commands {
        CommandGroup(after: .newItem) {
            Button("Add Files…") {
                model?.addFiles()
            }
            .keyboardShortcut("o", modifiers: [.command])

            Button("Add Folder…") {
                model?.addFolder()
            }
            .keyboardShortcut("o", modifiers: [.command, .shift])

            Divider()

            Button("Select All Files") {
                model?.selectAllVisible()
            }
            .keyboardShortcut("a", modifiers: [.command, .shift])

            Button("Remove from List") {
                model?.removeSelected()
            }

            Button("Clear File List") {
                model?.clearFiles()
            }
        }

        CommandMenu("Rename") {
            Button(model?.renameButtonTitle ?? "Rename") {
                model?.requestRename()
            }
            .keyboardShortcut("r", modifiers: [.command, .shift])
            .disabled(!(model?.canRename ?? false))

            Button("Undo Last Rename") {
                Task { await model?.undoLastCompletion() }
            }
            .keyboardShortcut("z", modifiers: [.command, .option])
            .disabled(model?.lastCompletion == nil)

            Divider()

            Button("Quick Look") {
                model?.quickLookSelected()
            }
            .keyboardShortcut("y", modifiers: [.command])

            Button("Reveal in Finder") {
                model?.revealSelected()
            }
            .keyboardShortcut("r", modifiers: [.command, .control])
        }
    }
}

private struct AppModelKey: FocusedValueKey {
    typealias Value = AppModel
}

extension FocusedValues {
    var appModel: AppModel? {
        get { self[AppModelKey.self] }
        set { self[AppModelKey.self] = newValue }
    }
}
