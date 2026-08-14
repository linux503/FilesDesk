import SwiftData
import SwiftUI

struct PresetsView: View {
    @Environment(AppModel.self) private var model
    @Query(sort: \RenamePreset.createdAt) private var presets: [RenamePreset]
    @State private var newName = ""
    @State private var showSaveSheet = false

    var body: some View {
        VStack(spacing: 0) {
            if presets.isEmpty {
                ContentUnavailableView(
                    "No Presets",
                    systemImage: "square.stack",
                    description: Text("Save the current rules as a preset to reuse them later.")
                )
            } else {
                List {
                    ForEach(presets) { preset in
                        HStack(alignment: .firstTextBaseline, spacing: 12) {
                            Image(systemName: "square.stack")
                                .foregroundStyle(.secondary)
                                .frame(width: 20)
                            VStack(alignment: .leading, spacing: 3) {
                                HStack(spacing: 8) {
                                    Text(preset.name)
                                        .font(.headline)
                                    if preset.isBuiltIn {
                                        Text("Built-in")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                                Text(ruleSummary(preset))
                                    .font(.callout)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(2)
                            }
                            Spacer()
                            Button("Use") {
                                model.applyPreset(preset)
                            }
                            .buttonStyle(.bordered)
                        }
                        .padding(.vertical, 6)
                        .contextMenu {
                            Button("Use Preset") {
                                model.applyPreset(preset)
                            }
                            Button("Delete", role: .destructive) {
                                model.deletePreset(preset)
                            }
                        }
                    }
                    .onDelete { indexSet in
                        for index in indexSet {
                            model.deletePreset(presets[index])
                        }
                    }
                }
            }
        }
        .navigationTitle("Presets")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Save Current Rules", systemImage: "plus") {
                    showSaveSheet = true
                }
                .disabled(model.rules.isEmpty)
            }
        }
        .sheet(isPresented: $showSaveSheet) {
            SavePresetSheet(name: $newName) {
                model.saveCurrentRulesAsPreset(name: newName)
                newName = ""
                showSaveSheet = false
            } onCancel: {
                newName = ""
                showSaveSheet = false
            }
        }
        .focusedSceneValue(\.appModel, model)
    }

    private func ruleSummary(_ preset: RenamePreset) -> String {
        let rules = preset.decodedRules()
        if rules.isEmpty { return "Empty" }
        return rules.map(\.kind.title).joined(separator: " → ")
    }
}

private struct SavePresetSheet: View {
    @Binding var name: String
    var onSave: () -> Void
    var onCancel: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Save Preset")
                .font(.headline)
            TextField("Name", text: $name)
                .textFieldStyle(.roundedBorder)
            HStack {
                Spacer()
                Button("Cancel", action: onCancel)
                    .keyboardShortcut(.cancelAction)
                Button("Save", action: onSave)
                    .keyboardShortcut(.defaultAction)
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
        .padding(20)
        .frame(width: 360)
    }
}
