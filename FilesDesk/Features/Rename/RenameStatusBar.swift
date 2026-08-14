import SwiftUI

struct RenameStatusBar: View {
    @Environment(AppModel.self) private var model

    var body: some View {
        HStack(spacing: 12) {
            Text(fileCountLabel)
                .font(.callout.weight(.medium))
                .foregroundStyle(.secondary)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Color.primary.opacity(0.06), in: Capsule())

            Picker("范围", selection: Binding(
                get: { model.renameScope },
                set: {
                    model.renameScope = $0
                    model.persistSettings()
                    model.schedulePreview()
                }
            )) {
                ForEach(RenameScope.allCases) { scope in
                    Text(scope.title).tag(scope)
                }
            }
            .pickerStyle(.segmented)
            .frame(maxWidth: 220)
            .help("选择要重命名的对象")

            HStack(spacing: 6) {
                Circle()
                    .fill(statusColor)
                    .frame(width: 7, height: 7)
                Text(statusLabel)
                    .lineLimit(1)
            }
            .foregroundStyle(statusColor == .red ? Color.red : .secondary)
            .help(statusLabel)

            Spacer()

            Button(model.renameButtonTitle) {
                model.requestRename()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .keyboardShortcut(.defaultAction)
            .disabled(!model.canRename)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(.bar)
    }

    private var fileCountLabel: String {
        let count = model.files.count
        if count == 1 { return "1 个项目" }
        return "\(count) 个项目"
    }

    private var statusLabel: String {
        if model.isPreviewing { return "正在更新预览" }
        if model.files.isEmpty { return "拖入文件或文件夹开始" }
        return model.validation.statusTitle
    }

    private var statusColor: Color {
        if model.files.isEmpty { return .secondary }
        if model.validation.errorCount > 0 { return .red }
        if model.validation.canRename { return .green }
        return .secondary
    }
}
