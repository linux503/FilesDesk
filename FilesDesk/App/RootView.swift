import SwiftUI

struct RootView: View {
    @Environment(AppModel.self) private var model

    var body: some View {
        @Bindable var model = model

        NavigationSplitView {
            SidebarView()
                .navigationSplitViewColumnWidth(min: 228, ideal: 248, max: 300)
                .navigationTitle("FilesDesk")
        } detail: {
            switch model.sidebar {
            case .rename:
                RenameView()
            case .presets:
                PresetsView()
            case .history:
                HistoryView()
            case .settings:
                SettingsView()
            }
        }
        .navigationSplitViewStyle(.balanced)
        .focusedSceneValue(\.appModel, model)
        .alert(
            "无法完成操作",
            isPresented: Binding(
                get: { model.errorMessage != nil },
                set: { if !$0 { model.errorMessage = nil } }
            )
        ) {
            Button("确定", role: .cancel) { model.errorMessage = nil }
        } message: {
            Text(model.errorMessage ?? "")
        }
        .confirmationDialog(
            model.renameButtonTitle,
            isPresented: $model.showRenameConfirmation,
            titleVisibility: .visible
        ) {
            Button(model.renameButtonTitle) {
                Task { await model.performRename() }
            }
            Button("取消", role: .cancel) {}
        } message: {
            Text("FilesDesk 绝不会覆盖已有文件。可稍后在历史中撤销。")
        }
        .overlay {
            if model.isRenaming {
                ZStack {
                    Color.black.opacity(0.22)
                    VStack(spacing: 14) {
                        Image(systemName: "wand.and.stars")
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundStyle(.tint)
                        Text("正在重命名…")
                            .font(.headline)
                        ProgressView(value: model.renameProgress)
                            .progressViewStyle(.linear)
                            .frame(width: 220)
                    }
                    .padding(28)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .overlay {
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .strokeBorder(Color.white.opacity(0.12), lineWidth: 1)
                    }
                    .shadow(color: .black.opacity(0.18), radius: 24, y: 10)
                }
                .ignoresSafeArea()
            }
        }
    }
}
