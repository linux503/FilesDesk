import SwiftUI

struct RulesPane: View {
    @Environment(AppModel.self) private var model

    var body: some View {
        @Bindable var model = model

        VStack(alignment: .leading, spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("规则")
                        .font(.headline)
                    Text(model.rules.isEmpty ? "按顺序应用到新名称" : "\(model.rules.filter(\.isEnabled).count) 条生效")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Menu {
                    ForEach(RuleKind.allCases) { kind in
                        Button(kind.title, systemImage: kind.systemImage) {
                            model.addRule(kind)
                        }
                    }
                } label: {
                    Label("添加规则", systemImage: "plus")
                }
                .menuStyle(.borderlessButton)
                .fixedSize()
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)

            if !model.smartSuggestions.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(model.smartSuggestions) { suggestion in
                        Button {
                            model.applySuggestion(suggestion)
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "sparkles")
                                    .foregroundStyle(.yellow)
                                VStack(alignment: .leading, spacing: 1) {
                                    Text(suggestion.title)
                                        .font(.caption.weight(.semibold))
                                        .foregroundStyle(.primary)
                                    Text(suggestion.reason)
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                        .lineLimit(2)
                                }
                                Spacer(minLength: 0)
                                Text("套用")
                                    .font(.caption.weight(.semibold))
                            }
                            .padding(10)
                            .background(
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .fill(Color.accentColor.opacity(0.08))
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.bottom, 8)
            }

            Divider()

            if model.rules.isEmpty {
                VStack(spacing: 8) {
                    Spacer()
                    Text("还没有规则")
                        .font(.headline)
                    Text("添加前缀、编号、日期等规则。新文件名会随输入即时更新。")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: 240)
                    Spacer()
                }
                .frame(maxWidth: .infinity)
            } else {
                List {
                    ForEach($model.rules) { $rule in
                        RuleEditor(
                            rule: $rule,
                            canMoveUp: model.rules.first?.id != rule.id,
                            canMoveDown: model.rules.last?.id != rule.id,
                            onMove: { offset in
                                model.moveRule(id: rule.id, by: offset)
                            },
                            onDelete: {
                                model.deleteRule(id: rule.id)
                            }
                        )
                        .listRowInsets(EdgeInsets(top: 8, leading: 10, bottom: 8, trailing: 10))
                        .listRowSeparator(.visible)
                        .onChange(of: rule) {
                            model.updateRules()
                        }
                    }
                    .onMove { source, destination in
                        model.moveRules(from: source, to: destination)
                    }
                }
                .listStyle(.inset)
            }
        }
        .background(Color(nsColor: .windowBackgroundColor))
    }
}

struct RuleEditor: View {
    @Binding var rule: RenameRule
    var canMoveUp: Bool
    var canMoveDown: Bool
    var onMove: (Int) -> Void
    var onDelete: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Toggle("", isOn: $rule.isEnabled)
                    .toggleStyle(.checkbox)
                    .labelsHidden()
                    .help(rule.isEnabled ? "停用规则" : "启用规则")

                Image(systemName: rule.kind.systemImage)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 22, height: 22)
                    .background(
                        RoundedRectangle(cornerRadius: 6, style: .continuous)
                            .fill(Color.accentColor.opacity(rule.isEnabled ? 0.9 : 0.35))
                    )

                Text(rule.kind.title)
                    .font(.subheadline.weight(.semibold))

                Spacer()

                Button {
                    onMove(-1)
                } label: {
                    Image(systemName: "chevron.up")
                }
                .buttonStyle(.borderless)
                .disabled(!canMoveUp)
                .help("上移")

                Button {
                    onMove(1)
                } label: {
                    Image(systemName: "chevron.down")
                }
                .buttonStyle(.borderless)
                .disabled(!canMoveDown)
                .help("下移")

                Button(role: .destructive, action: onDelete) {
                    Image(systemName: "trash")
                }
                .buttonStyle(.borderless)
                .help("删除规则")
            }

            if rule.isEnabled {
                ruleFields
                    .padding(.leading, 28)
            } else {
                Text(rule.summary)
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                    .padding(.leading, 28)
            }
        }
        .padding(.vertical, 4)
        .opacity(rule.isEnabled ? 1 : 0.55)
    }

    @ViewBuilder
    private var ruleFields: some View {
        switch rule.kind {
        case .replace:
            LabeledField("查找") {
                TextField("要查找的文本", text: $rule.parameters.findText)
                    .textFieldStyle(.roundedBorder)
            }
            LabeledField("替换为") {
                TextField("替换内容", text: $rule.parameters.replacementText)
                    .textFieldStyle(.roundedBorder)
            }
            Toggle("区分大小写", isOn: $rule.parameters.matchCase)
            Toggle("全部替换", isOn: $rule.parameters.replaceAll)

        case .prefix, .suffix:
            LabeledField(rule.kind == .prefix ? "前缀" : "后缀") {
                TextField("文本", text: $rule.parameters.affixText)
                    .textFieldStyle(.roundedBorder)
            }

        case .remove:
            LabeledField("删除") {
                TextField("要删除的文本", text: $rule.parameters.findText)
                    .textFieldStyle(.roundedBorder)
            }
            Toggle("区分大小写", isOn: $rule.parameters.matchCase)
            Toggle("全部删除", isOn: $rule.parameters.replaceAll)

        case .numbering:
            LabeledField("起始") {
                TextField("1", value: $rule.parameters.numberingStart, format: .number)
                    .textFieldStyle(.roundedBorder)
            }
            LabeledField("步长") {
                TextField("1", value: $rule.parameters.numberingStep, format: .number)
                    .textFieldStyle(.roundedBorder)
            }
            LabeledField("位数") {
                TextField("3", value: $rule.parameters.numberingDigits, format: .number)
                    .textFieldStyle(.roundedBorder)
            }
            LabeledField("分隔符") {
                TextField("_", text: $rule.parameters.numberingSeparator)
                    .textFieldStyle(.roundedBorder)
            }
            Picker("位置", selection: $rule.parameters.numberingPosition) {
                ForEach(NumberingPosition.allCases) { position in
                    Text(position.title).tag(position)
                }
            }

        case .caseChange:
            Picker("样式", selection: $rule.parameters.caseStyle) {
                ForEach(CaseStyle.allCases) { style in
                    Text(style.title).tag(style)
                }
            }

        case .date:
            Picker("来源", selection: $rule.parameters.dateSource) {
                ForEach(DateSource.allCases) { source in
                    Text(source.title).tag(source)
                }
            }
            LabeledField("格式") {
                TextField("yyyy-MM-dd", text: $rule.parameters.dateFormat)
                    .textFieldStyle(.roundedBorder)
            }
            LabeledField("分隔符") {
                TextField("_", text: $rule.parameters.dateSeparator)
                    .textFieldStyle(.roundedBorder)
            }
            Picker("位置", selection: $rule.parameters.datePosition) {
                ForEach(AffixPosition.allCases) { position in
                    Text(position.title).tag(position)
                }
            }

        case .cleanup:
            Toggle("去除首尾空格", isOn: $rule.parameters.trimWhitespace)
            Toggle("合并连续空格", isOn: $rule.parameters.collapseWhitespace)
            Toggle("空格改为下划线", isOn: $rule.parameters.spacesToUnderscores)
                .onChange(of: rule.parameters.spacesToUnderscores) { _, isOn in
                    if isOn { rule.parameters.spacesToHyphens = false }
                }
            Toggle("空格改为连字符", isOn: $rule.parameters.spacesToHyphens)
                .onChange(of: rule.parameters.spacesToHyphens) { _, isOn in
                    if isOn { rule.parameters.spacesToUnderscores = false }
                }
            Toggle("去掉特殊字符", isOn: $rule.parameters.removeSpecialCharacters)
            Toggle("去掉重音符号", isOn: $rule.parameters.removeDiacritics)

        case .regex:
            LabeledField("模式") {
                TextField("正则表达式", text: $rule.parameters.regexPattern)
                    .textFieldStyle(.roundedBorder)
                    .font(.system(.body, design: .monospaced))
            }
            LabeledField("替换为") {
                TextField("模板，例如 $1", text: $rule.parameters.regexTemplate)
                    .textFieldStyle(.roundedBorder)
                    .font(.system(.body, design: .monospaced))
            }
            Toggle("忽略大小写", isOn: $rule.parameters.regexCaseInsensitive)
            if !rule.parameters.regexPattern.isEmpty, !RenameEngine.regexIsValid(rule.parameters.regexPattern) {
                Text("正则表达式无效。")
                    .font(.caption)
                    .foregroundStyle(.red)
            }
        }
    }
}

private struct LabeledField<Content: View>: View {
    let title: String
    @ViewBuilder var content: Content

    init(_ title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        HStack(alignment: .center, spacing: 8) {
            Text(title)
                .foregroundStyle(.secondary)
                .frame(width: 72, alignment: .leading)
            content
        }
    }
}
