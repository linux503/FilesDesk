import Sparkle
import SwiftUI

struct SettingsView: View {
    @Environment(AppModel.self) private var model
    @Environment(\.updater) private var updater

    var body: some View {
        @Bindable var model = model

        Form {
            Section("Rename") {
                Toggle("Confirm before renaming", isOn: $model.confirmBeforeRename)
                    .onChange(of: model.confirmBeforeRename) {
                        model.persistSettings()
                    }
            }

            Section("Adding Files") {
                Toggle("Include hidden files", isOn: $model.includeHiddenFiles)
                    .onChange(of: model.includeHiddenFiles) {
                        model.persistSettings()
                    }
                Toggle("Include files in subfolders", isOn: $model.includeSubfolders)
                    .onChange(of: model.includeSubfolders) {
                        model.persistSettings()
                    }
            }

            Section("Updates") {
                if let updater {
                    Toggle("Check for updates automatically", isOn: autoCheckBinding(updater))
                    CheckForUpdatesView(updater: updater)
                }
                LabeledContent("Current version", value: appVersion)
            }

            Section("Safety") {
                LabeledContent("Overwrite existing files", value: "Never")
                LabeledContent("Preview writes to disk", value: "Never")
                LabeledContent("Rename without validation", value: "Never")
            }

            Section("About") {
                LabeledContent("FilesDesk", value: "Smart File Renamer for Mac")
                LabeledContent("Version", value: appVersion)
                Text("Simple, native, safe, and fast. FilesDesk never overwrites a file that already exists.")
                    .foregroundStyle(.secondary)
                Link("Website", destination: AppLinks.website)
                Link("GitHub", destination: AppLinks.github)
                Link("Privacy", destination: AppLinks.privacy)
            }
        }
        .formStyle(.grouped)
        .frame(maxWidth: 720)
        .navigationTitle("Settings")
        .focusedSceneValue(\.appModel, model)
        .padding()
    }

    private var appVersion: String {
        let short = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0.0"
        let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "1"
        return "\(short) (\(build))"
    }

    private func autoCheckBinding(_ updater: SPUUpdater) -> Binding<Bool> {
        Binding(
            get: { updater.automaticallyChecksForUpdates },
            set: { updater.automaticallyChecksForUpdates = $0 }
        )
    }
}
