import SwiftUI

enum SidebarItem: String, CaseIterable, Identifiable, Hashable, Sendable {
    case rename
    case presets
    case history
    case settings

    var id: String { rawValue }

    var title: String {
        switch self {
        case .rename: "重命名"
        case .presets: "预设"
        case .history: "历史"
        case .settings: "设置"
        }
    }

    var subtitle: String {
        switch self {
        case .rename: "批量预览与执行"
        case .presets: "一键套用规则"
        case .history: "随时撤销改名"
        case .settings: "导入与安全"
        }
    }

    var systemImage: String {
        switch self {
        case .rename: "wand.and.stars"
        case .presets: "square.stack.3d.up.fill"
        case .history: "clock.arrow.circlepath"
        case .settings: "slider.horizontal.3"
        }
    }

    var tint: Color {
        switch self {
        case .rename: Color(red: 0.18, green: 0.47, blue: 0.98)
        case .presets: Color(red: 0.46, green: 0.32, blue: 0.96)
        case .history: Color(red: 0.96, green: 0.52, blue: 0.16)
        case .settings: Color(red: 0.42, green: 0.49, blue: 0.58)
        }
    }
}
