import Vapor
import FluentSQLite

final class Question: Codable {
    var id: Int?
    
    var userID: User.ID
    var mediaID: Media.ID
    
    var title: String!
    var subject: String!

    
    
    init(name: String, userID : User.ID, mediaID: Media.ID, title: String, subject: String ) {
        self.userID = userID
        self.mediaID = mediaID
        self.title = title
        self.subject = subject
    }
}


struct QuestionInfos: Content {
    var question : Question?
    var infos : QuestQuestionInfo?
}



extension Question: SQLiteModel {}

extension Question: Content {}
extension Question: Parameter {}

extension Question {
    var user: Parent<Question, User> {
        return parent(\.userID)
    }
    
    var questionInfo: Children<Question, QuestQuestionInfo> {
        return children(\.questionID)
    }
    
    
    var infos: Children<Question, InfoAnswerQuestion> {
        return children(\.questionID)
    }
    
    
    var participationUser: Children<Question, ParticipationQuest> {
        return children(\.questionID)
    }
    
    
}

extension Question: Migration {
    static func prepare(on conn: SQLiteConnection) -> Future<Void> {
        return Database.create(self, on: conn) { (builder) in
            try addProperties(to: builder)
            builder.reference(from: \.userID, to: \User.id)
        }
    }
}
