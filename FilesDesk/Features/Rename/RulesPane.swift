import SwiftUI

struct RulesPane: View {
    @Environment(AppModel.self) private var model

    var body: some View {
        @Bindable var model = model

        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("Rules")
                    .font(.headline)
                Spacer()
                Menu {
                    ForEach(RuleKind.allCases) { kind in
                        Button(kind.title, systemImage: kind.systemImage) {
                            model.addRule(kind)
                        }
                    }
                } label: {
                    Label("Add Rule", systemImage: "plus")
                }
                .menuStyle(.borderlessButton)
                .fixedSize()
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)

            Divider()

            if model.rules.isEmpty {
                VStack(spacing: 8) {
                    Spacer()
                    Text("No rules yet")
                        .font(.headline)
                    Text("Add a prefix, number, date, or other rule. The new names update as you type.")
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
                    .help(rule.isEnabled ? "Disable rule" : "Enable rule")

                Image(systemName: rule.kind.systemImage)
                    .foregroundStyle(.secondary)
                    .frame(width: 16)

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
                .help("Move up")

                Button {
                    onMove(1)
                } label: {
                    Image(systemName: "chevron.down")
                }
                .buttonStyle(.borderless)
                .disabled(!canMoveDown)
                .help("Move down")

                Button(role: .destructive, action: onDelete) {
                    Image(systemName: "trash")
                }
                .buttonStyle(.borderless)
                .help("Delete rule")
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
            LabeledField("Find") {
                TextField("Text to find", text: $rule.parameters.findText)
                    .textFieldStyle(.roundedBorder)
            }
            LabeledField("Replace") {
                TextField("Replacement", text: $rule.parameters.replacementText)
                    .textFieldStyle(.roundedBorder)
            }
            Toggle("Match case", isOn: $rule.parameters.matchCase)
            Toggle("Replace all", isOn: $rule.parameters.replaceAll)

        case .prefix, .suffix:
            LabeledField(rule.kind == .prefix ? "Prefix" : "Suffix") {
                TextField("Text", text: $rule.parameters.affixText)
                    .textFieldStyle(.roundedBorder)
            }

        case .remove:
            LabeledField("Remove") {
                TextField("Text to remove", text: $rule.parameters.findText)
                    .textFieldStyle(.roundedBorder)
            }
            Toggle("Match case", isOn: $rule.parameters.matchCase)
            Toggle("Remove all", isOn: $rule.parameters.replaceAll)

        case .numbering:
            LabeledField("Start") {
                TextField("1", value: $rule.parameters.numberingStart, format: .number)
                    .textFieldStyle(.roundedBorder)
            }
            LabeledField("Step") {
                TextField("1", value: $rule.parameters.numberingStep, format: .number)
                    .textFieldStyle(.roundedBorder)
            }
            LabeledField("Digits") {
                TextField("3", value: $rule.parameters.numberingDigits, format: .number)
                    .textFieldStyle(.roundedBorder)
            }
            LabeledField("Separator") {
                TextField("_", text: $rule.parameters.numberingSeparator)
                    .textFieldStyle(.roundedBorder)
            }
            Picker("Position", selection: $rule.parameters.numberingPosition) {
                ForEach(NumberingPosition.allCases) { position in
                    Text(position.title).tag(position)
                }
            }

        case .caseChange:
            Picker("Style", selection: $rule.parameters.caseStyle) {
                ForEach(CaseStyle.allCases) { style in
                    Text(style.title).tag(style)
                }
            }

        case .date:
            Picker("Source", selection: $rule.parameters.dateSource) {
                ForEach(DateSource.allCases) { source in
                    Text(source.title).tag(source)
                }
            }
            LabeledField("Format") {
                TextField("yyyy-MM-dd", text: $rule.parameters.dateFormat)
                    .textFieldStyle(.roundedBorder)
            }
            LabeledField("Separator") {
                TextField("_", text: $rule.parameters.dateSeparator)
                    .textFieldStyle(.roundedBorder)
            }
            Picker("Position", selection: $rule.parameters.datePosition) {
                ForEach(AffixPosition.allCases) { position in
                    Text(position.title).tag(position)
                }
            }

        case .cleanup:
            Toggle("Trim whitespace", isOn: $rule.parameters.trimWhitespace)
            Toggle("Collapse spaces", isOn: $rule.parameters.collapseWhitespace)
            Toggle("Spaces to underscores", isOn: $rule.parameters.spacesToUnderscores)
                .onChange(of: rule.parameters.spacesToUnderscores) { _, isOn in
                    if isOn { rule.parameters.spacesToHyphens = false }
                }
            Toggle("Spaces to hyphens", isOn: $rule.parameters.spacesToHyphens)
                .onChange(of: rule.parameters.spacesToHyphens) { _, isOn in
                    if isOn { rule.parameters.spacesToUnderscores = false }
                }
            Toggle("Remove special characters", isOn: $rule.parameters.removeSpecialCharacters)
            Toggle("Remove diacritics", isOn: $rule.parameters.removeDiacritics)

        case .regex:
            LabeledField("Pattern") {
                TextField("Regular expression", text: $rule.parameters.regexPattern)
                    .textFieldStyle(.roundedBorder)
                    .font(.system(.body, design: .monospaced))
            }
            LabeledField("Replace") {
                TextField("Template, e.g. $1", text: $rule.parameters.regexTemplate)
                    .textFieldStyle(.roundedBorder)
                    .font(.system(.body, design: .monospaced))
            }
            Toggle("Ignore case", isOn: $rule.parameters.regexCaseInsensitive)
            if !rule.parameters.regexPattern.isEmpty, !RenameEngine.regexIsValid(rule.parameters.regexPattern) {
                Text("This pattern is not valid.")
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
