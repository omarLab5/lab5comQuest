//
//  ParticipationController.swift
//  App
//
//  Created by MacBook Pro on 17/09/2019.
//

import Foundation

import Vapor

final class ParticipationController: RouteCollection {
    
    
    
    func getAllHandler(_ req: Request) throws -> Future<[ParticipationQuest]> {
        return ParticipationQuest.query(on: req).decode(ParticipationQuest.self).all()
    }
    
    func getOneHandler(_ req: Request) throws -> Future<ParticipationQuest> {
        return try req.parameters.next(ParticipationQuest.self)
    }
    
    func createHandler(_ req: Request) throws -> Future<ParticipationQuest> {
        return try req.content.decode(ParticipationQuest.self).flatMap { (quest) in
            return quest.save(on: req)
        }
    }
    
  
    
    func deleteHandler(_ req: Request) throws -> Future<HTTPStatus> {
        return try req.parameters.next(ParticipationQuest.self).flatMap { (quest) in
            return quest.delete(on: req).transform(to: HTTPStatus.noContent)
        }
    }
    
    

    
    func boot(router: Router) throws {
        
        let questRoute = router.grouped("api", "participation")
        let tokenAuthMiddleware = User.tokenAuthMiddleware()
        let guardAuthMiddleware = User.guardAuthMiddleware()
        let tokenProtected = questRoute.grouped(tokenAuthMiddleware, guardAuthMiddleware)
        tokenProtected.get(use: getAllHandler)
        tokenProtected.get(ParticipationQuest.parameter, use: getOneHandler)
        tokenProtected.post(use: createHandler)
        tokenProtected.delete(ParticipationQuest.parameter, use: deleteHandler)
        
    }
}
