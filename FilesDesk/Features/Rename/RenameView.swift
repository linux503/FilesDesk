import SwiftUI

struct RenameView: View {
    @Environment(AppModel.self) private var model

    var body: some View {
        VStack(spacing: 0) {
            HSplitView {
                FileTableView()
                    .frame(minWidth: 420)

                RulesPane()
                    .frame(minWidth: 280, idealWidth: 320, maxWidth: 420)
            }

            Divider()
            RenameStatusBar()
        }
        .toolbar { RenameToolbar() }
        .safeAreaInset(edge: .top, spacing: 0) {
            if let completion = model.lastCompletion {
                CompletionBanner(completion: completion)
            } else if model.recoveredCount > 0 {
                RecoveryBanner()
            }
        }
        .focusedSceneValue(\.appModel, model)
        .navigationTitle("重命名")
    }
}

private struct RenameToolbar: ToolbarContent {
    @Environment(AppModel.self) private var model

    var body: some ToolbarContent {
        ToolbarItemGroup(placement: .primaryAction) {
            Button("添加文件", systemImage: "doc.badge.plus") {
                model.addFiles()
            }
            Button("添加文件夹", systemImage: "folder.badge.plus") {
                model.addFolder()
            }
        }
        ToolbarItemGroup(placement: .automatic) {
            Button("快速查看", systemImage: "eye") {
                model.quickLookSelected()
            }
            .disabled(model.files.isEmpty)
            Button("移除", systemImage: "minus") {
                model.removeSelected()
            }
            .disabled(model.selection.isEmpty)
        }
    }
}

struct CompletionBanner: View {
    @Environment(AppModel.self) private var model
    let completion: RenameCompletion

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(.green)
            Text(completion.fileCount == 1
                 ? "已成功重命名 1 个文件"
                 : "已成功重命名 \(completion.fileCount) 个文件")
            Spacer()
            Button("撤销") {
                Task { await model.undoLastCompletion() }
            }
            .buttonStyle(.bordered)
            Button {
                model.lastCompletion = nil
            } label: {
                Image(systemName: "xmark")
            }
            .buttonStyle(.borderless)
            .help("关闭")
        }
        .font(.callout)
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(.bar)
        .overlay(alignment: .bottom) { Divider() }
    }
}

private struct RecoveryBanner: View {
    @Environment(AppModel.self) private var model

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "arrow.uturn.backward.circle.fill")
                .foregroundStyle(.orange)
            Text(model.recoveredCount == 1
                 ? "已从中断的重命名中恢复 1 个文件。"
                 : "已从中断的重命名中恢复 \(model.recoveredCount) 个文件。")
            Spacer()
            Button {
                model.recoveredCount = 0
            } label: {
                Image(systemName: "xmark")
            }
            .buttonStyle(.borderless)
        }
        .font(.callout)
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(.bar)
        .overlay(alignment: .bottom) { Divider() }
    }
}
