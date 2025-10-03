import Foundation
import SwiftData

@Model
final class Favor: Identifiable {
    @Attribute(.unique) var id: UUID = UUID()
    var title: String
    var category: String
    var timestamp: Date = Date()
    var latitude: Double
    var longitude: Double

    init(title: String, category: String, latitude: Double, longitude: Double) {
        self.title = title
        self.category = category
        self.latitude = latitude
        self.longitude = longitude
    }
}
