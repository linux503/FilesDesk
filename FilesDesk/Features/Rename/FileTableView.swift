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
                    TableColumn("原名称") { item in
                        HStack(spacing: 6) {
                            if item.isDirectory {
                                Image(systemName: "folder.fill")
                                    .foregroundStyle(.secondary)
                                    .font(.caption)
                            }
                            Text(item.originalName)
                                .font(.system(.body, design: .monospaced))
                                .lineLimit(1)
                                .help(item.originalName)
                        }
                    }
                    .width(min: 140, ideal: 200)

                    TableColumn("新名称") { item in
                        Text(item.proposedName)
                            .font(.system(.body, design: .monospaced))
                            .foregroundStyle(item.proposedName == item.originalName ? .secondary : .primary)
                            .lineLimit(1)
                            .help(item.proposedName)
                    }
                    .width(min: 140, ideal: 200)

                    TableColumn("类型") { item in
                        Text(item.typeName)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                    .width(min: 80, ideal: 110)

                    TableColumn("大小") { item in
                        Text(item.isDirectory ? "—" : item.fileSize.formatted(.byteCount(style: .file)))
                            .foregroundStyle(.secondary)
                            .monospacedDigit()
                    }
                    .width(min: 70, ideal: 90)

                    TableColumn("状态") { item in
                        StatusBadge(status: item.status, message: item.statusMessage)
                    }
                    .width(min: 90, ideal: 130)
                }
                .contextMenu(forSelectionType: FileItem.ID.self) { ids in
                    if !ids.isEmpty {
                        Button("快速查看") {
                            model.selection = ids
                            model.quickLookSelected()
                        }
                        Button("在 Finder 中显示") {
                            model.selection = ids
                            model.revealSelected()
                        }
                        Divider()
                        Button("从列表移除", role: .destructive) {
                            model.remove(ids: ids)
                        }
                    }
                }
                .searchable(text: $model.searchText, prompt: "搜索文件或文件夹")
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
                ProgressView("正在添加文件…")
                    .padding(20)
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
            } else if model.isRefreshing {
                ProgressView("正在刷新…")
                    .padding(20)
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
            }
        }
    }
}

private struct FileEmptyState: View {
    @Environment(AppModel.self) private var model

    var body: some View {
        VStack(spacing: 22) {
            Spacer()
            VStack(spacing: 16) {
                AppLogo(size: 72)
                VStack(spacing: 6) {
                    Text("拖入文件开始")
                        .font(.title2.weight(.semibold))
                    Text("添加文件夹会把文件夹本身加入列表，也可导入其中的内容。")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: 360)
                }
            }
            .padding(.vertical, 28)
            .padding(.horizontal, 36)
            .background(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .strokeBorder(style: StrokeStyle(lineWidth: 1.5, dash: [7, 6]))
                    .foregroundStyle(Color.accentColor.opacity(0.35))
            )
            .background(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(Color.accentColor.opacity(0.04))
            )

            HStack(spacing: 10) {
                Button("添加文件", systemImage: "doc.badge.plus") { model.addFiles() }
                Button("添加文件夹", systemImage: "folder.badge.plus") { model.addFolder() }
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
