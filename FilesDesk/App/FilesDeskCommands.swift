import SwiftUI

struct FilesDeskCommands: Commands {
    @FocusedValue(\.appModel) private var model: AppModel?

    var body: some Commands {
        CommandGroup(after: .newItem) {
            Button("添加文件…") {
                model?.addFiles()
            }
            .keyboardShortcut("o", modifiers: [.command])

            Button("添加文件夹…") {
                model?.addFolder()
            }
            .keyboardShortcut("o", modifiers: [.command, .shift])

            Divider()

            Button("全选文件") {
                model?.selectAllVisible()
            }
            .keyboardShortcut("a", modifiers: [.command, .shift])

            Button("从列表移除") {
                model?.removeSelected()
            }

            Button("清空文件列表") {
                model?.clearFiles()
            }
        }

        CommandMenu("重命名") {
            Button(model?.renameButtonTitle ?? "重命名") {
                model?.requestRename()
            }
            .keyboardShortcut("r", modifiers: [.command, .shift])
            .disabled(!(model?.canRename ?? false))

            Button("撤销上次重命名") {
                Task { await model?.undoLastCompletion() }
            }
            .keyboardShortcut("z", modifiers: [.command, .option])
            .disabled(model?.lastCompletion == nil)

            Divider()

            Button("快速查看") {
                model?.quickLookSelected()
            }
            .keyboardShortcut("y", modifiers: [.command])

            Button("在 Finder 中显示") {
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
