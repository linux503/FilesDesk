import SwiftData
import SwiftUI

struct HistoryView: View {
    @Environment(AppModel.self) private var model
    @Query(sort: \HistoryBatch.timestamp, order: .reverse) private var batches: [HistoryBatch]
    @State private var selection: HistoryBatch.ID?

    var body: some View {
        Group {
            if batches.isEmpty {
                ContentUnavailableView(
                    "暂无历史",
                    systemImage: "clock",
                    description: Text("完成的重命名会出现在这里，并可随时撤销。")
                )
            } else {
                List(selection: $selection) {
                    ForEach(batches) { batch in
                        DisclosureGroup {
                            ForEach(batch.items, id: \.originalPath) { item in
                                HStack(spacing: 8) {
                                    Text(item.originalName)
                                        .font(.system(.body, design: .monospaced))
                                        .foregroundStyle(.secondary)
                                        .lineLimit(1)
                                    Image(systemName: "arrow.right")
                                        .font(.caption)
                                        .foregroundStyle(.tertiary)
                                    Text(item.newName)
                                        .font(.system(.body, design: .monospaced))
                                        .lineLimit(1)
                                    Spacer()
                                    Button("显示") {
                                        let path = batch.wasUndone ? item.originalPath : item.newPath
                                        model.reveal(url: URL(fileURLWithPath: path))
                                    }
                                    .buttonStyle(.borderless)
                                }
                            }
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: batch.wasUndone ? "arrow.uturn.backward.circle.fill" : "checkmark.circle.fill")
                                    .foregroundStyle(batch.wasUndone ? .secondary : Color.orange)
                                    .font(.title3)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(batch.timestamp.formatted(date: .abbreviated, time: .shortened))
                                    Text(batch.wasUndone
                                         ? "已撤销 · \(fileCount(batch.fileCount))"
                                         : fileCount(batch.fileCount))
                                        .font(.callout)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                if !batch.wasUndone {
                                    Button("撤销") {
                                        Task { await model.undo(batchID: batch.id) }
                                    }
                                    .buttonStyle(.bordered)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                        .tag(batch.id)
                    }
                }
            }
        }
        .navigationTitle("历史")
        .focusedSceneValue(\.appModel, model)
    }

    private func fileCount(_ count: Int) -> String {
        count == 1 ? "1 个文件" : "\(count) 个文件"
    }
}
