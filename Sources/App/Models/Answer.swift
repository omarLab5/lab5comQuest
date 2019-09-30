import Vapor
import FluentSQLite

final class Answer: Codable {
    var id: Int?
    
    var userID: User.ID
    var mediaID: Media.ID
    
    var answerTitle: String!
    var answerSubject: String!
    
    init(name: String, userID : User.ID, mediaID: Media.ID, title: String, subject: String ) {
        self.userID = userID
        self.mediaID = mediaID
        self.answerTitle = title
        self.answerSubject = subject
    }
}


struct AnswersInfos: Content {
    var answer : Answer?
    var infos : InfoAnswerQuestion?
}


extension Answer: SQLiteModel {}

extension Answer: Content {}
extension Answer: Parameter {}

extension Answer {
    var user: Parent<Answer, User> {
        return parent(\.userID)
    }
 
    var infos: Children<Answer, InfoAnswerQuestion> {
        return children(\.answerID)
    }
    
    
    var participationUser : Children<Answer, ParticipationQuest> {
        return children(\.answerID)
    }
    
}

extension Answer: Migration {
    static func prepare(on conn: SQLiteConnection) -> Future<Void> {
        return Database.create(self, on: conn) { (builder) in
            try addProperties(to: builder)
            builder.reference(from: \.userID, to: \User.id)
        }
    }
}
