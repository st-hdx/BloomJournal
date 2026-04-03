import Foundation

struct Vision: Identifiable, Codable {
    let id: UUID
    var title: String
    var details: [String]
    var createdAt: Date

    init(title: String) {
        self.id = UUID()
        self.title = title
        self.details = []
        self.createdAt = Date()
    }
}
