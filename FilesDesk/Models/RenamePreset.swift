import Foundation
import SwiftData

@Model
final class RenamePreset {
    var id: UUID
    var name: String
    var createdAt: Date
    var updatedAt: Date
    var isBuiltIn: Bool
    var rulesData: Data

    init(
        id: UUID = UUID(),
        name: String,
        createdAt: Date = .now,
        updatedAt: Date = .now,
        isBuiltIn: Bool = false,
        rules: [RenameRule]
    ) {
        self.id = id
        self.name = name
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.isBuiltIn = isBuiltIn
        self.rulesData = (try? JSONEncoder().encode(rules)) ?? Data()
    }

    func decodedRules() -> [RenameRule] {
        (try? JSONDecoder().decode([RenameRule].self, from: rulesData)) ?? []
    }

    func setRules(_ rules: [RenameRule]) {
        rulesData = (try? JSONEncoder().encode(rules)) ?? Data()
        updatedAt = .now
    }
}
