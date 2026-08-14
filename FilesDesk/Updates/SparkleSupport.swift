import Combine
import Foundation
import Sparkle
import SwiftUI

enum AppLinks {
    static let github = URL(string: "https://github.com/linux503/FilesDesk")!
    static let website = URL(string: "https://linux503.github.io/FilesDesk")!
    static let privacy = URL(string: "https://linux503.github.io/FilesDesk/privacy.html")!
    static let latestRelease = URL(string: "https://github.com/linux503/FilesDesk/releases/latest")!
}

@MainActor
final class UpdateViewModel: ObservableObject {
    @Published var canCheckForUpdates = false
    private var observation: NSKeyValueObservation?

    init(updater: SPUUpdater) {
        canCheckForUpdates = updater.canCheckForUpdates
        observation = updater.observe(\.canCheckForUpdates, options: [.initial, .new]) { [weak self] updater, _ in
            Task { @MainActor in
                self?.canCheckForUpdates = updater.canCheckForUpdates
            }
        }
    }
}

struct CheckForUpdatesView: View {
    @ObservedObject private var model: UpdateViewModel
    private let updater: SPUUpdater

    init(updater: SPUUpdater) {
        self.updater = updater
        self.model = UpdateViewModel(updater: updater)
    }

    var body: some View {
        Button("检查更新…") {
            updater.checkForUpdates()
        }
        .disabled(!model.canCheckForUpdates)
    }
}

private struct UpdaterKey: EnvironmentKey {
    static let defaultValue: SPUUpdater? = nil
}

extension EnvironmentValues {
    var updater: SPUUpdater? {
        get { self[UpdaterKey.self] }
        set { self[UpdaterKey.self] = newValue }
    }
}
