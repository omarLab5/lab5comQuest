//
//  ParticipationQuest.swift
//  App
//
//  Created by MacBook Pro on 17/09/2019.
//

import Vapor
import FluentSQLite
import Authentication


final class ParticipationQuest: Codable {
    var id: Int?
    var questionID : Question.ID
    var answerID : Answer.ID
    var userID: User.ID
    var questID : Quest.ID
    
    
    init(questionID: Int , answerID: Int , userID : Int  , questID : Int) {
        self.questionID = questionID
        self.answerID = answerID
        self.userID = userID
        self.questID = questID
    }
    
    
}

extension ParticipationQuest: SQLiteModel {}
extension ParticipationQuest: Migration {}
extension ParticipationQuest: Content {}
extension ParticipationQuest: Parameter {}

extension ParticipationQuest {
    
    var answer: Parent<ParticipationQuest, Answer> {
        return parent(\.answerID)
    }
    
    var question: Parent<ParticipationQuest, Question> {
        return parent(\.questionID)
    }
    
    var user: Parent<ParticipationQuest, User> {
        return parent(\.userID)
    }
    
    var quest : Parent<ParticipationQuest, Quest> {
        return parent(\.questID)
    }
    
}

