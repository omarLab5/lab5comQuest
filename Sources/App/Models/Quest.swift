import Vapor
import FluentSQLite

final class Quest: Codable {
    var id: Int?
    var name: String
    var username: String
    var userID: User.ID

    init(name: String, username: String , userID : User.ID) {
        self.name = name
        self.username = username
        self.userID = userID

    }
}

extension Quest: SQLiteModel {}

extension Quest: Content {}
extension Quest: Parameter {}

extension Quest {
    var user: Parent<Quest, User> {
        return parent(\.userID)
    }
    var participationUser: Children<Quest, ParticipationQuest> {
        return children(\.questID)
    }
    
    var questInfo: Children<Quest, QuestQuestionInfo> {
        return children(\.questID)
    }

}

extension Quest: Migration {
    static func prepare(on conn: SQLiteConnection) -> Future<Void> {
        return Database.create(self, on: conn) { (builder) in
            try addProperties(to: builder)
            builder.reference(from: \.userID, to: \User.id)
        }
    }
}
