//
//  QuestQuestionInfoController.swift
//  App
//
//  Created by MacBook Pro on 22/09/2019.
//

import Foundation

import Vapor

final class QuestQuestionInfoController: RouteCollection {
    
    
    
    func getAllHandler(_ req: Request) throws -> Future<[QuestQuestionInfo]> {
        return QuestQuestionInfo.query(on: req).decode(QuestQuestionInfo.self).all()
    }
    
    func getOneHandler(_ req: Request) throws -> Future<QuestQuestionInfo> {
        return try req.parameters.next(QuestQuestionInfo.self)
    }
    
    func createHandler(_ req: Request) throws -> Future<QuestQuestionInfo> {
        return try req.content.decode(QuestQuestionInfo.self).flatMap { (quest) in
            return quest.save(on: req)
        }
    }
    
    
    
    func deleteHandler(_ req: Request) throws -> Future<HTTPStatus> {
        return try req.parameters.next(QuestQuestionInfo.self).flatMap { (quest) in
            return quest.delete(on: req).transform(to: HTTPStatus.noContent)
        }
    }
    
    
    
    
    func boot(router: Router) throws {
        
        let questRoute = router.grouped("api", "questInfo")
        let tokenAuthMiddleware = User.tokenAuthMiddleware()
        let guardAuthMiddleware = User.guardAuthMiddleware()
        let tokenProtected = questRoute.grouped(tokenAuthMiddleware, guardAuthMiddleware)
        tokenProtected.get(use: getAllHandler)
        tokenProtected.get(QuestQuestionInfo.parameter, use: getOneHandler)
        tokenProtected.post(use: createHandler)

        
        
    }
}
