import SwiftUI

struct StatusBadge: View {
    let status: FileItemStatus
    let message: String

    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(color)
                .frame(width: 7, height: 7)
            Text(title)
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .help(message)
        }
    }

    private var title: String {
        switch status {
        case .previewing: "预览"
        case .ready: "就绪"
        case .unchanged: "未更改"
        case .warning: "警告"
        case .error: message.isEmpty ? "错误" : message
        case .renamed: "已重命名"
        }
    }

    private var color: Color {
        switch status {
        case .previewing: .secondary
        case .ready: .green
        case .unchanged: .secondary
        case .warning: .orange
        case .error: .red
        case .renamed: .blue
        }
    }
}
