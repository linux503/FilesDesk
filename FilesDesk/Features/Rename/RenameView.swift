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
        .navigationTitle("Rename")
    }
}

private struct RenameToolbar: ToolbarContent {
    @Environment(AppModel.self) private var model

    var body: some ToolbarContent {
        ToolbarItemGroup(placement: .primaryAction) {
            Button("Add Files", systemImage: "doc.badge.plus") {
                model.addFiles()
            }
            Button("Add Folder", systemImage: "folder.badge.plus") {
                model.addFolder()
            }
        }
        ToolbarItemGroup(placement: .automatic) {
            Button("Quick Look", systemImage: "eye") {
                model.quickLookSelected()
            }
            .disabled(model.files.isEmpty)
            Button("Remove", systemImage: "minus") {
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
                 ? "1 file renamed successfully"
                 : "\(completion.fileCount) files renamed successfully")
            Spacer()
            Button("Undo") {
                Task { await model.undoLastCompletion() }
            }
            .buttonStyle(.bordered)
            Button {
                model.lastCompletion = nil
            } label: {
                Image(systemName: "xmark")
            }
            .buttonStyle(.borderless)
            .help("Dismiss")
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
                 ? "Restored 1 file from an interrupted rename."
                 : "Restored \(model.recoveredCount) files from an interrupted rename.")
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
