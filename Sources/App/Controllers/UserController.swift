//
//  UserController.swift
//  App
//
//  Created by MacBook Pro on 04/09/2019.
//

import Foundation
import Vapor
import Crypto

class UserController: RouteCollection {
    //1
    func boot(router: Router) throws {
        let usersRoute = router.grouped("api", "users")
        
        let basicAuthMiddleware = User.basicAuthMiddleware(using: BCryptDigest())
        let guardAuthMiddleware = User.guardAuthMiddleware()
        
        let basicProtected = usersRoute.grouped(basicAuthMiddleware, guardAuthMiddleware)
        basicProtected.post("login", use: loginHandler)
        basicProtected.post(use: createHandler)
        let tokenAuthMiddleware = User.tokenAuthMiddleware()
        let tokenProtected = usersRoute.grouped(tokenAuthMiddleware, guardAuthMiddleware)
        tokenProtected.get(use: getAllHandler)
        tokenProtected.get(User.parameter, use: getOneHandler)
        tokenProtected.put(User.parameter, use: updateHandler)
        tokenProtected.delete(User.parameter, use: deleteHandler)
        //GET : api/users/userId/quests
        tokenProtected.get(User.parameter, "quests", use: getQuestsHandler)
        //add participation
//        tokenProtected.post(User.parameter, "participation", Quest.parameter, use: addParticipationQuestHandler)
        //get participation
        tokenProtected.get(User.parameter, "participation", use: getParticipationsHandler)
        tokenProtected.get(User.parameter,"quest",Quest.parameter,use: getParticipationsAnswerHandler)

//remove participation
//        tokenProtected.delete(User.parameter, "participations", Quest.parameter, use: removeQuestParticpationHandler)

    }
}

//MARK: Helper
private extension UserController {

    func getAllHandler(_ req: Request) throws -> Future<[User.Public]> {
        
        return User.query(on: req).decode(data: User.Public.self).all()
    }
    func getOneHandler(_ req: Request) throws -> Future<User.Public> {
        return try req.parameters.next(User.self).toPublic()
    }
    
    func createHandler(_ req: Request) throws -> Future<User.Public> {
        return try req.content.decode(User.self).flatMap { (user) in
            try user.validate() 
            user.password = try BCrypt.hash(user.password)
            return user.save(on: req).toPublic()
        }
    }
    
    func loginHandler(_ req: Request) throws -> Future<Token> {
        let user = try req.requireAuthenticated(User.self)
        let token = try Token.generate(for: user)
        return token.save(on: req)
    }
    
    func updateHandler(_ req: Request) throws -> Future<User.Public> {
        return try flatMap(to: User.Public.self, req.parameters.next(User.self), req.content.decode(User.self)) { (user, updatedUser) in
            user.email = updatedUser.email
            user.fullName = updatedUser.fullName
            user.password = try BCrypt.hash(updatedUser.password)
            return user.save(on: req).toPublic()
        }
    }
    
    func deleteHandler(_ req: Request) throws -> Future<HTTPStatus> {
        return try req.parameters.next(User.self).flatMap { (user) in
            return user.delete(on: req).transform(to: HTTPStatus.noContent)
        }
    }

    func getQuestsHandler(_ req: Request) throws -> Future<[Quest]> {
        return try req.parameters.next(User.self).flatMap(to: [Quest].self) { (user) in
            return try user.quests.query(on: req).all()
        }
    }


    func getParticipationsAnswerHandler(_ req: Request) throws -> Future<[Answer]> {
        return try flatMap(to: [Answer].self, req.parameters.next(User.self), req.parameters.next(Quest.self)){(user , quest) in
            return  ParticipationQuest.query(on: req).filter(\ParticipationQuest.userID, .equal, user.id!)
                .filter(\ParticipationQuest.questID, .equal, quest.id!)
                .join(\Answer.id , to: \ParticipationQuest.answerID)
                .alsoDecode(Answer.self)
                .all().and(result: user).map({ (data) -> ([Answer]) in
                    var array = [Answer]()
                    for dataInfo in data.0{
                        array.append(dataInfo.1)
                    }
                    return array
                })
            
        }
    }
    
    
    
    func getParticipationsHandler(_ req: Request) throws -> Future<[Quest]> {
        return try req.parameters.next(User.self).flatMap(to: [Quest].self) { (user) in
            return  ParticipationQuest.query(on: req).filter(\ParticipationQuest.userID, .equal, user.id!)
                .join(\Quest.id , to: \ParticipationQuest.questID)
                .alsoDecode(Quest.self)
                .all().and(result: user).map({ (data) -> ([Quest]) in
                    var array = [Quest]()
                    for dataInfo in data.0{
                        if !array.contains(where: {$0.id == dataInfo.1.id}){
                        array.append(dataInfo.1)
                        }
                    }
                    return array
                })
            
        }
    }
        
//
//    func removeQuestParticpationHandler(_ req: Request) throws -> Future<HTTPStatus> {
//        return try flatMap(to: HTTPStatus.self, req.parameters.next(User.self), req.parameters.next(Quest.self)) { (user, quest) in
//            return user.participation.detach(quest, on: req).transform(to: .noContent)
//        }
//    }
}
