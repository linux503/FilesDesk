import Sparkle
import SwiftUI

struct SettingsView: View {
    @Environment(AppModel.self) private var model
    @Environment(\.updater) private var updater

    var body: some View {
        @Bindable var model = model

        Form {
            Section("重命名") {
                Toggle("重命名前确认", isOn: $model.confirmBeforeRename)
                    .onChange(of: model.confirmBeforeRename) {
                        model.persistSettings()
                    }
            }

            Section("添加内容") {
                Toggle("将文件夹加入重命名列表", isOn: $model.includeFolders)
                    .onChange(of: model.includeFolders) {
                        model.persistSettings()
                    }
                Toggle("导入文件夹内的文件", isOn: $model.includeFolderContents)
                    .onChange(of: model.includeFolderContents) {
                        model.persistSettings()
                    }
                Toggle("包含隐藏文件", isOn: $model.includeHiddenFiles)
                    .onChange(of: model.includeHiddenFiles) {
                        model.persistSettings()
                    }
                Toggle("包含子文件夹中的内容", isOn: $model.includeSubfolders)
                    .onChange(of: model.includeSubfolders) {
                        model.persistSettings()
                    }
            }

            Section("更新") {
                if let updater {
                    Toggle("自动检查更新", isOn: autoCheckBinding(updater))
                    CheckForUpdatesView(updater: updater)
                }
                LabeledContent("当前版本", value: appVersion)
            }

            Section("安全") {
                LabeledContent("覆盖已有文件", value: "永不")
                LabeledContent("预览写入磁盘", value: "永不")
                LabeledContent("跳过校验直接重命名", value: "永不")
            }

            Section("关于") {
                HStack(spacing: 14) {
                    AppLogo(size: 56)
                    VStack(alignment: .leading, spacing: 4) {
                        Text("FilesDesk")
                            .font(.title3.weight(.semibold))
                        Text("Mac 智能批量重命名")
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                }
                .padding(.vertical, 4)
                LabeledContent("版本", value: appVersion)
                Text("简单、原生、安全、快速。FilesDesk 绝不会覆盖已有文件。")
                    .foregroundStyle(.secondary)
                Link("官网", destination: AppLinks.website)
                Link("GitHub", destination: AppLinks.github)
                Link("隐私政策", destination: AppLinks.privacy)
            }
        }
        .formStyle(.grouped)
        .frame(maxWidth: 720)
        .navigationTitle("设置")
        .focusedSceneValue(\.appModel, model)
        .padding()
    }

    private var appVersion: String {
        let short = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0.0"
        let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "1"
        return "\(short) (\(build))"
    }

    private func autoCheckBinding(_ updater: SPUUpdater) -> Binding<Bool> {
        Binding(
            get: { updater.automaticallyChecksForUpdates },
            set: { updater.automaticallyChecksForUpdates = $0 }
        )
    }
}
