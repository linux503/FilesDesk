import Foundation

enum SidebarItem: String, CaseIterable, Identifiable, Hashable, Sendable {
    case rename
    case presets
    case history
    case settings

    var id: String { rawValue }

    var title: String {
        switch self {
        case .rename: "Rename"
        case .presets: "Presets"
        case .history: "History"
        case .settings: "Settings"
        }
    }

    var systemImage: String {
        switch self {
        case .rename: "list.bullet.rectangle"
        case .presets: "square.stack"
        case .history: "clock"
        case .settings: "gearshape"
        }
    }
}
