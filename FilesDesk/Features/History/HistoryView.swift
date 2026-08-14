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
                    "No History",
                    systemImage: "clock",
                    description: Text("Completed renames will appear here, and you can undo them.")
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
                                    Button("Reveal") {
                                        let path = batch.wasUndone ? item.originalPath : item.newPath
                                        model.reveal(url: URL(fileURLWithPath: path))
                                    }
                                    .buttonStyle(.borderless)
                                }
                            }
                        } label: {
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(batch.timestamp.formatted(date: .abbreviated, time: .shortened))
                                    Text(batch.wasUndone
                                         ? "Undone · \(fileCount(batch.fileCount))"
                                         : fileCount(batch.fileCount))
                                        .font(.callout)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                if !batch.wasUndone {
                                    Button("Undo") {
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
        .navigationTitle("History")
        .focusedSceneValue(\.appModel, model)
    }

    private func fileCount(_ count: Int) -> String {
        count == 1 ? "1 file" : "\(count) files"
    }
}
