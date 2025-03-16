import Foundation
import SwiftData

@Model
class Topic: Identifiable {
    @Attribute(.unique)
    var id: String
    var name: String

    init(name: String) {
        id = UUID().uuidString
        self.name = name
    }
}
