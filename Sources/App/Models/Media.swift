
import Vapor
import FluentSQLite

final class Media: Codable {
    var id: Int?
    var mediaTitle: String
    var mediaDescription: String
    
    init(mediaTitle: String, mediaDescription: String , userID: User.ID) {
        self.mediaTitle = mediaTitle
        self.mediaDescription = mediaDescription
    }
}

extension Media: SQLiteModel {}
extension Media: Parameter {}
extension Media: Content {}
extension Media: Migration {}


