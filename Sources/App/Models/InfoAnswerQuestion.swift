//
//  InfoAnswerQuestion.swift
//  App
//
//  Created by MacBook Pro on 14/09/2019.
//


import Vapor
import FluentSQLite
import Authentication


final class InfoAnswerQuestion: Codable {
    var id: Int?
    var questionID : Question.ID
    var answerID : Answer.ID
    var ranking: Int
    var status : Bool
    
    
    
    init(questionID: Int , answerID: Int , ranking : Int  , status : Bool) {
        self.questionID = questionID
        self.answerID = answerID
        self.ranking = ranking
        self.status = status
    }
}

extension InfoAnswerQuestion: SQLiteModel {}
extension InfoAnswerQuestion: Migration {}

extension InfoAnswerQuestion: Content {}
extension InfoAnswerQuestion: Parameter {}

extension InfoAnswerQuestion {
    var answer: Parent<InfoAnswerQuestion, Answer> {
        return parent(\.answerID)
    }
    
    var question: Parent<InfoAnswerQuestion, Question> {
        return parent(\.questionID)
    }
    
}


