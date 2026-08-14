import SwiftUI

struct FileTableView: View {
    @Environment(AppModel.self) private var model

    var body: some View {
        @Bindable var model = model

        VStack(spacing: 0) {
            if model.files.isEmpty && !model.isImporting {
                FileEmptyState()
            } else {
                Table(model.filteredFiles, selection: $model.selection) {
                    TableColumn("Original Name") { item in
                        Text(item.originalName)
                            .font(.system(.body, design: .monospaced))
                            .lineLimit(1)
                            .help(item.originalName)
                    }
                    .width(min: 140, ideal: 200)

                    TableColumn("New Name") { item in
                        Text(item.proposedName)
                            .font(.system(.body, design: .monospaced))
                            .foregroundStyle(item.proposedName == item.originalName ? .secondary : .primary)
                            .lineLimit(1)
                            .help(item.proposedName)
                    }
                    .width(min: 140, ideal: 200)

                    TableColumn("Type") { item in
                        Text(item.typeName)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                    .width(min: 80, ideal: 110)

                    TableColumn("Size") { item in
                        Text(item.fileSize.formatted(.byteCount(style: .file)))
                            .foregroundStyle(.secondary)
                            .monospacedDigit()
                    }
                    .width(min: 70, ideal: 90)

                    TableColumn("Status") { item in
                        StatusBadge(status: item.status, message: item.statusMessage)
                    }
                    .width(min: 90, ideal: 130)
                }
                .contextMenu(forSelectionType: FileItem.ID.self) { ids in
                    if !ids.isEmpty {
                        Button("Quick Look") {
                            model.selection = ids
                            model.quickLookSelected()
                        }
                        Button("Reveal in Finder") {
                            model.selection = ids
                            model.revealSelected()
                        }
                        Divider()
                        Button("Remove from List", role: .destructive) {
                            model.remove(ids: ids)
                        }
                    }
                }
                .searchable(text: $model.searchText, prompt: "Search files")
                .onDeleteCommand {
                    model.removeSelected()
                }
                .onKeyPress(.space) {
                    model.quickLookSelected()
                    return .handled
                }
            }
        }
        .dropDestination(for: URL.self) { urls, _ in
            model.importDroppedURLs(urls)
            return true
        } isTargeted: { targeted in
            model.isDropTargeted = targeted
        }
        .overlay {
            if model.isDropTargeted {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .strokeBorder(Color.accentColor, style: StrokeStyle(lineWidth: 2, dash: [7, 5]))
                    .padding(10)
                    .background(Color.accentColor.opacity(0.06))
                    .allowsHitTesting(false)
            }
        }
        .overlay {
            if model.isImporting {
                ProgressView("Adding files…")
                    .padding(20)
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
            }
        }
    }
}

private struct FileEmptyState: View {
    @Environment(AppModel.self) private var model

    var body: some View {
        VStack(spacing: 18) {
            Spacer()
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 42, weight: .light))
                .foregroundStyle(.secondary)
            VStack(spacing: 6) {
                Text("FilesDesk")
                    .font(.system(size: 28, weight: .semibold, design: .default))
                Text("Drop files here, or add a folder to start renaming.")
                    .foregroundStyle(.secondary)
            }
            HStack(spacing: 10) {
                Button("Add Files") { model.addFiles() }
                Button("Add Folder") { model.addFolder() }
            }
            .buttonStyle(.bordered)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
