//
//  InfoAnswerQuestionController.swift
//  App
//
//  Created by MacBook Pro on 14/09/2019.
//

import Vapor
import FluentSQLite


final class InfoAnswerQuestionController: RouteCollection {
    
    func getAllHandler(_ req: Request) throws -> Future<[InfoAnswerQuestion]> {
        return InfoAnswerQuestion.query(on: req).decode(InfoAnswerQuestion.self).all()
    }
    func getOneHandler(_ req: Request) throws -> Future<InfoAnswerQuestion> {
        return try req.parameters.next(InfoAnswerQuestion.self)
    }
    
    

    
    func checkIfExists(req: Request , infos : EventLoopFuture<[InfoAnswerQuestion]> , infoCreated : InfoAnswerQuestion) -> Future<Bool>{
       return infos.and(result: infoCreated).map { (data) -> (Bool) in
            for infoData in data.0 {
                if infoData.answerID == infoCreated.answerID && infoData.questionID == infoCreated.questionID {
                    return true
                }
            }
        return false
        }
    }
   
    
    
    func createHandler(_ req: Request) throws -> Future<InfoAnswerQuestion> {
        return try req.content.decode(InfoAnswerQuestion.self).flatMap { (infoCreated) in
//            let infos =  InfoAnswerQuestion.query(on: req).all()
//            if self.checkIfExists(req: req, infos: infos, infoCreated: infoCreated){
//
//            }
        infoCreated.save(on: req)
        }
    }
    
    
    func updateHandler(_ req: Request) throws -> Future<InfoAnswerQuestion> {
        return try flatMap(to: InfoAnswerQuestion.self, req.parameters.next(InfoAnswerQuestion.self), req.content.decode(InfoAnswerQuestion.self)) { (quest, updatedQuest) in
            quest.questionID = updatedQuest.questionID
            quest.answerID = updatedQuest.answerID
            quest.ranking = updatedQuest.ranking
            quest.status = updatedQuest.status

            return quest.save(on: req)
        }
    }
    func deleteHandler(_ req: Request) throws -> Future<HTTPStatus> {
        return try req.parameters.next(InfoAnswerQuestion.self).flatMap { (quest) in
            return quest.delete(on: req).transform(to: HTTPStatus.noContent)
        }
    }
    
    
    func getAnswerHandler(_ req: Request) throws -> Future<Answer> {
        return try req.parameters.next(InfoAnswerQuestion.self).flatMap(to: Answer.self) { (info) in
            return info.answer.get(on: req)
        }
    }
    
    
    func getQuestionHandler(_ req: Request) throws -> Future<Question> {
        return try req.parameters.next(InfoAnswerQuestion.self).flatMap(to: Question.self) { (info) in
            return info.question.get(on: req)
        }
    }

    
    func boot(router: Router) throws {
        
        let questRoute = router.grouped("api", "info")
        let tokenAuthMiddleware = User.tokenAuthMiddleware()
        let guardAuthMiddleware = User.guardAuthMiddleware()
        let tokenProtected = questRoute.grouped(tokenAuthMiddleware, guardAuthMiddleware)
        tokenProtected.get(use: getAllHandler)
        tokenProtected.get(InfoAnswerQuestion.parameter, use: getOneHandler)
        tokenProtected.post(use: createHandler)
        tokenProtected.put(InfoAnswerQuestion.parameter, use: updateHandler)
        tokenProtected.delete(InfoAnswerQuestion.parameter, use: deleteHandler)
        
        tokenProtected.get(InfoAnswerQuestion.parameter, "answer", use: getAnswerHandler)
        tokenProtected.get(InfoAnswerQuestion.parameter, "question", use: getQuestionHandler)
    
        
    }
}
