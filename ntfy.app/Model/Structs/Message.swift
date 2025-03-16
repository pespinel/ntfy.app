import Foundation

struct Message: Identifiable, Codable, Equatable {
    var id = UUID()
    var time: Int
    var message: String
    var topic: String
    var priority: Int
    var tags: [String]?
    var click: String?
}
