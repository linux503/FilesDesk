import SwiftUI

struct RenameStatusBar: View {
    @Environment(AppModel.self) private var model

    var body: some View {
        HStack(spacing: 12) {
            Text(fileCountLabel)
                .foregroundStyle(.secondary)

            Circle()
                .fill(statusColor)
                .frame(width: 7, height: 7)

            Text(statusLabel)
                .foregroundStyle(statusColor == .red ? Color.red : .secondary)

            if let global = model.validation.globalIssues.first {
                Text("· \(global.message)")
                    .foregroundStyle(.red)
                    .lineLimit(1)
            }

            Spacer()

            Button(model.renameButtonTitle) {
                model.requestRename()
            }
            .keyboardShortcut(.defaultAction)
            .disabled(!model.canRename)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(.bar)
    }

    private var fileCountLabel: String {
        let count = model.files.count
        if count == 1 { return "1 File" }
        return "\(count) Files"
    }

    private var statusLabel: String {
        if model.isPreviewing { return "Updating preview" }
        if model.files.isEmpty { return "Drop files to begin" }
        return model.validation.statusTitle
    }

    private var statusColor: Color {
        if model.files.isEmpty { return .secondary }
        if model.validation.errorCount > 0 { return .red }
        if model.validation.canRename { return .green }
        return .secondary
    }
}
