//
//  QuestQuestionInfo.swift
//  App
//
//  Created by MacBook Pro on 22/09/2019.
//

import Vapor
import FluentSQLite
import Authentication


final class QuestQuestionInfo: Codable {
    var id : Int?
    var questionID : Question.ID
    var questID : Quest.ID
    var ranking: Int
    
    
    init(questionID: Int , questID: Int , ranking : Int) {
        self.questionID = questionID
        self.questID = questID
        self.ranking = ranking
    }
}

extension QuestQuestionInfo: SQLiteModel {}
extension QuestQuestionInfo: Migration {}

extension QuestQuestionInfo: Content {}
extension QuestQuestionInfo: Parameter {}

extension QuestQuestionInfo {
    var answer: Parent<QuestQuestionInfo, Quest> {
        return parent(\.questID)
    }
    
    var question: Parent<QuestQuestionInfo, Question> {
        return parent(\.questionID)
    }
    
}


