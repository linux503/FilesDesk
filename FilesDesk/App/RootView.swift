import SwiftUI

struct RootView: View {
    @Environment(AppModel.self) private var model

    var body: some View {
        @Bindable var model = model

        NavigationSplitView {
            List(selection: $model.sidebar) {
                Section {
                    ForEach(SidebarItem.allCases) { item in
                        Label(item.title, systemImage: item.systemImage)
                            .tag(item)
                    }
                }
            }
            .listStyle(.sidebar)
            .navigationSplitViewColumnWidth(min: 168, ideal: 196, max: 240)
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
            "Couldn’t complete the action",
            isPresented: Binding(
                get: { model.errorMessage != nil },
                set: { if !$0 { model.errorMessage = nil } }
            )
        ) {
            Button("OK", role: .cancel) { model.errorMessage = nil }
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
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("FilesDesk will never overwrite an existing file. This can be undone from History.")
        }
        .overlay {
            if model.isRenaming {
                ZStack {
                    Color.black.opacity(0.18)
                    VStack(spacing: 12) {
                        ProgressView(value: model.renameProgress)
                            .progressViewStyle(.linear)
                            .frame(width: 220)
                        Text("Renaming files…")
                            .font(.headline)
                    }
                    .padding(24)
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
                .ignoresSafeArea()
            }
        }
    }
}
