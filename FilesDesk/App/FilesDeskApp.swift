import SwiftData
import SwiftUI
import Sparkle

struct FilesDeskApp: App {
    private let container: ModelContainer
    private let updaterController: SPUStandardUpdaterController
    @State private var model: AppModel

    init() {
        let schema = Schema([HistoryBatch.self, HistoryItem.self, RenamePreset.self])
        let configuration = ModelConfiguration("FilesDesk", schema: schema)
        do {
            let container = try ModelContainer(for: schema, configurations: configuration)
            self.container = container
            _model = State(initialValue: AppModel(container: container))
        } catch {
            fatalError("Failed to create FilesDesk data store: \(error)")
        }
        let testing = ProcessInfo.processInfo.arguments.contains { $0.contains("xctest") }
        updaterController = SPUStandardUpdaterController(
            startingUpdater: !testing,
            updaterDelegate: nil,
            userDriverDelegate: nil
        )
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(model)
                .environment(\.updater, updaterController.updater)
                .frame(minWidth: 960, minHeight: 600)
                .onAppear {
                    model.seedPresetsIfNeeded()
                }
        }
        .modelContainer(container)
        .defaultSize(width: 1220, height: 780)
        .windowResizability(.contentMinSize)
        .windowToolbarStyle(.unified)
        .commands {
            CommandGroup(after: .appInfo) {
                CheckForUpdatesView(updater: updaterController.updater)
            }
            FilesDeskCommands()
        }

        Settings {
            SettingsView()
                .environment(model)
                .environment(\.updater, updaterController.updater)
        }
    }
}
