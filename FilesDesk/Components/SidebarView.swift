import SwiftData
import SwiftUI

struct SidebarView: View {
    @Environment(AppModel.self) private var model
    @Query(sort: \RenamePreset.createdAt) private var presets: [RenamePreset]
    @Query(sort: \HistoryBatch.timestamp, order: .reverse) private var batches: [HistoryBatch]

    var body: some View {
        VStack(spacing: 0) {
            brandHeader
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    navGroup("工作区", items: [.rename])
                    navGroup("资料库", items: [.presets, .history])
                    if let suggestion = model.smartSuggestions.first {
                        suggestionCard(suggestion)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.top, 8)
                .padding(.bottom, 16)
            }
            settingsFooter
        }
        .background(sidebarBackground)
    }

    private var brandHeader: some View {
        HStack(spacing: 12) {
            AppLogo(size: 36)
            VStack(alignment: .leading, spacing: 2) {
                Text("FilesDesk")
                    .font(.system(size: 16, weight: .semibold))
                Text("智能批量重命名")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 16)
        .padding(.top, 16)
        .padding(.bottom, 12)
    }

    private func navGroup(_ title: String, items: [SidebarItem]) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.tertiary)
                .padding(.horizontal, 8)

            VStack(spacing: 4) {
                ForEach(items) { item in
                    navRow(item)
                }
            }
        }
    }

    private func navRow(_ item: SidebarItem) -> some View {
        let selected = model.sidebar == item
        return Button {
            model.sidebar = item
        } label: {
            HStack(spacing: 10) {
                Image(systemName: item.systemImage)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(selected ? .white : item.tint)
                    .frame(width: 28, height: 28)
                    .background(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(selected ? item.tint : item.tint.opacity(0.14))
                    )

                VStack(alignment: .leading, spacing: 1) {
                    Text(item.title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.primary)
                    Text(item.subtitle)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }

                Spacer(minLength: 0)

                if let badge = badge(for: item) {
                    Text(badge)
                        .font(.caption2.weight(.semibold).monospacedDigit())
                        .foregroundStyle(selected ? item.tint : .secondary)
                        .padding(.horizontal, 7)
                        .padding(.vertical, 3)
                        .background(
                            Capsule(style: .continuous)
                                .fill(selected ? item.tint.opacity(0.16) : Color.primary.opacity(0.06))
                        )
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(selected ? item.tint.opacity(0.12) : Color.clear)
            )
            .overlay {
                if selected {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .strokeBorder(item.tint.opacity(0.22), lineWidth: 1)
                }
            }
            .contentShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .buttonStyle(.plain)
        .help(item.subtitle)
    }

    private func suggestionCard(_ suggestion: SmartSuggestion) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Image(systemName: "sparkles")
                    .foregroundStyle(.yellow)
                Text("智能建议")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
            }

            HStack(alignment: .top, spacing: 10) {
                Image(systemName: suggestion.systemImage)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color(red: 0.18, green: 0.47, blue: 0.98))
                    .frame(width: 26, height: 26)
                    .background(
                        RoundedRectangle(cornerRadius: 7, style: .continuous)
                            .fill(Color(red: 0.18, green: 0.47, blue: 0.98).opacity(0.12))
                    )

                VStack(alignment: .leading, spacing: 3) {
                    Text(suggestion.title)
                        .font(.subheadline.weight(.semibold))
                    Text(suggestion.reason)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            Button("套用建议") {
                model.applySuggestion(suggestion)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.small)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(.background.opacity(0.55))
        )
        .overlay {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .strokeBorder(Color.primary.opacity(0.06), lineWidth: 1)
        }
    }

    private var settingsFooter: some View {
        VStack(spacing: 8) {
            Divider().opacity(0.6)
            navRow(.settings)
                .padding(.horizontal, 4)
        }
        .padding(.horizontal, 8)
        .padding(.bottom, 10)
        .padding(.top, 4)
    }

    private var sidebarBackground: some View {
        ZStack {
            Color(nsColor: .windowBackgroundColor)
            LinearGradient(
                colors: [
                    Color(red: 0.18, green: 0.47, blue: 0.98).opacity(0.06),
                    Color.clear
                ],
                startPoint: .top,
                endPoint: .center
            )
        }
        .ignoresSafeArea()
    }

    private func badge(for item: SidebarItem) -> String? {
        switch item {
        case .rename:
            let count = model.files.count
            return count > 0 ? "\(count)" : nil
        case .presets:
            return presets.isEmpty ? nil : "\(presets.count)"
        case .history:
            let count = batches.filter { !$0.wasUndone }.count
            return count > 0 ? "\(count)" : nil
        case .settings:
            return nil
        }
    }
}
