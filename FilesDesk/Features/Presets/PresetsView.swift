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
                    "暂无预设",
                    systemImage: "square.stack",
                    description: Text("将当前规则保存为预设，方便下次复用。")
                )
            } else {
                List {
                    ForEach(presets) { preset in
                        HStack(alignment: .center, spacing: 12) {
                            Image(systemName: "square.stack.3d.up.fill")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(.white)
                                .frame(width: 32, height: 32)
                                .background(
                                    RoundedRectangle(cornerRadius: 9, style: .continuous)
                                        .fill(Color(red: 0.46, green: 0.32, blue: 0.96))
                                )
                            VStack(alignment: .leading, spacing: 3) {
                                HStack(spacing: 8) {
                                    Text(preset.name)
                                        .font(.headline)
                                    if preset.isBuiltIn {
                                        Text("内置")
                                            .font(.caption2.weight(.semibold))
                                            .foregroundStyle(Color(red: 0.46, green: 0.32, blue: 0.96))
                                            .padding(.horizontal, 6)
                                            .padding(.vertical, 2)
                                            .background(
                                                Capsule().fill(Color(red: 0.46, green: 0.32, blue: 0.96).opacity(0.12))
                                            )
                                    }
                                }
                                Text(ruleSummary(preset))
                                    .font(.callout)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(2)
                            }
                            Spacer()
                            Button("使用") {
                                model.applyPreset(preset)
                            }
                            .buttonStyle(.borderedProminent)
                            .controlSize(.small)
                        }
                        .padding(.vertical, 8)
                        .contextMenu {
                            Button("使用预设") {
                                model.applyPreset(preset)
                            }
                            Button("删除", role: .destructive) {
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
        .navigationTitle("预设")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("保存当前规则", systemImage: "plus") {
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
        if rules.isEmpty { return "空" }
        return rules.map(\.kind.title).joined(separator: " → ")
    }
}

private struct SavePresetSheet: View {
    @Binding var name: String
    var onSave: () -> Void
    var onCancel: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("保存预设")
                .font(.headline)
            TextField("名称", text: $name)
                .textFieldStyle(.roundedBorder)
            HStack {
                Spacer()
                Button("取消", action: onCancel)
                    .keyboardShortcut(.cancelAction)
                Button("保存", action: onSave)
                    .keyboardShortcut(.defaultAction)
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
        .padding(20)
        .frame(width: 360)
    }
}
